"""Decisión de punto de encuentro sobre calles reales.

La geometría y los sentidos vienen de OpenStreetMap a través del motor
público Valhalla (perfil auto y perfil peatonal). No se inventan líneas
rectas: si el motor no responde, la función falla.
"""

from __future__ import annotations

import json
import math
import random
import threading
import time
import urllib.error
import urllib.request
from typing import Any

VALHALLA = "https://valhalla1.openstreetmap.de"
USER_AGENT = "prueba-recogida/1.0 (prototipo de punto de encuentro)"

# Umbral de caminata por la calle, en metros.
THRESHOLD_MIN_M = 50
THRESHOLD_MAX_M = 800
THRESHOLD_DEFAULT_M = 250

# Ahorro mínimo para mostrar el aviso. El final de la ruta no cuenta.
MIN_SAVINGS_S = 30
# Metros finales de la ruta del carro: ahí está el pin, no un desvío.
ROUTE_TAIL_M = 80
# Un punto a menos de esto del pin es el propio pin.
PIN_SEPARATION_M = 30
# Paso al avanzar el carro sobre su ruta.
STEP_M = 320
# Radio para colocar un carro al azar.
CAR_RADIUS_M = 2000
CAR_MIN_M = 350

# Primer plano: Insurgentes Sur (avenida de doble cuerpo) en Nápoles /
# Del Valle. El carro entra a Insurgentes, pasa cerca y luego da la vuelta
# por calles de un sentido para llegar al pin, al poniente de la avenida.
PRESET_USER = {"lat": 19.39146, "lon": -99.17421}
PRESET_CAR = {"lat": 19.38926, "lon": -99.17296}
MAP_CENTER = {"lat": 19.3910, "lon": -99.1735, "zoom": 16}

_lock = threading.Lock()
_analysis_cache: dict[tuple, dict[str, Any]] = {}
_walk_cache: dict[tuple, dict[str, Any]] = {}


class RoutingError(Exception):
    """El motor de rutas no pudo calcular un camino por la calle."""


def clamp_threshold(value: float) -> int:
    try:
        meters = int(round(float(value)))
    except (TypeError, ValueError):
        meters = THRESHOLD_DEFAULT_M
    return max(THRESHOLD_MIN_M, min(THRESHOLD_MAX_M, meters))


def haversine(a: tuple[float, float], b: tuple[float, float]) -> float:
    radius = 6_371_000.0
    lat1, lon1 = math.radians(a[0]), math.radians(a[1])
    lat2, lon2 = math.radians(b[0]), math.radians(b[1])
    dlat, dlon = lat2 - lat1, lon2 - lon1
    h = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ** 2
    return 2 * radius * math.asin(math.sqrt(min(1.0, h)))


def _offset(lat: float, lon: float, distance_m: float, bearing: float) -> tuple[float, float]:
    dlat = (distance_m * math.cos(bearing)) / 111_320.0
    dlon = (distance_m * math.sin(bearing)) / (111_320.0 * math.cos(math.radians(lat)))
    return lat + dlat, lon + dlon


def _post(path: str, body: dict[str, Any]) -> dict[str, Any]:
    url = VALHALLA + path
    data = json.dumps(body).encode("utf-8")
    last_error: Exception | None = None
    for attempt in range(3):
        req = urllib.request.Request(
            url,
            data=data,
            headers={"User-Agent": USER_AGENT, "Content-Type": "application/json"},
        )
        try:
            with urllib.request.urlopen(req, timeout=25) as response:
                payload = json.loads(response.read().decode("utf-8"))
            if isinstance(payload, dict) and payload.get("error"):
                raise RoutingError(str(payload.get("error")))
            return payload
        except RoutingError:
            raise
        except Exception as exc:  # noqa: BLE001 - red de un servicio externo
            last_error = exc
            status = getattr(exc, "code", None)
            if status in (400, 404):
                break
            time.sleep(0.4 * (attempt + 1))
    raise RoutingError(f"No hubo ruta por la calle ({last_error})")


def decode_polyline(encoded: str, precision: int = 6) -> list[tuple[float, float]]:
    inv = 10 ** precision
    lat = lon = 0
    coords: list[tuple[float, float]] = []
    index = 0
    length = len(encoded)
    while index < length:
        for coord in range(2):
            shift = result = 0
            while True:
                byte = ord(encoded[index]) - 63
                index += 1
                result |= (byte & 0x1F) << shift
                shift += 5
                if byte < 0x20:
                    break
            delta = ~(result >> 1) if (result & 1) else (result >> 1)
            if coord == 0:
                lat += delta
            else:
                lon += delta
        coords.append((lat / inv, lon / inv))
    return coords


def _route(origin: tuple[float, float], dest: tuple[float, float], costing: str) -> dict[str, Any]:
    payload = _post(
        "/route",
        {
            "locations": [
                {"lat": origin[0], "lon": origin[1]},
                {"lat": dest[0], "lon": dest[1]},
            ],
            "costing": costing,
            "units": "kilometers",
            "language": "es-MX",
        },
    )
    trip = payload.get("trip")
    if not trip or not trip.get("legs"):
        raise RoutingError("La respuesta de ruta no trae geometría.")
    leg = trip["legs"][0]
    shape = decode_polyline(leg["shape"])
    if len(shape) < 2:
        raise RoutingError("La ruta no tiene suficientes puntos.")
    summary = trip["summary"]
    return {
        "shape": shape,
        "maneuvers": leg.get("maneuvers") or [],
        "duration_s": float(summary["time"]),
        "distance_m": float(summary["length"]) * 1000.0,
    }


def _metrics(shape: list[tuple[float, float]], maneuvers: list[dict[str, Any]]) -> tuple[list[float], list[float]]:
    """Tiempo y distancia acumulados sobre la geometría de la ruta en auto.

    El tiempo de cada maniobra se reparte según la longitud de sus tramos,
    así el tiempo hasta un punto P es el de ir por esa ruta, no otro camino.
    """
    count = len(shape)
    seg = [0.0] * count
    for index in range(1, count):
        seg[index] = haversine(shape[index - 1], shape[index])
    time_at = [0.0] * count
    dist_at = [0.0] * count
    written = [False] * count
    written[0] = True
    for maneuver in maneuvers:
        start = int(maneuver.get("begin_shape_index") or 0)
        end = int(maneuver.get("end_shape_index") or start)
        span = sum(seg[start + 1 : end + 1])
        maneuver_time = float(maneuver.get("time") or 0)
        if end <= start or span <= 0:
            continue
        acc_t = time_at[start]
        acc_d = dist_at[start]
        for index in range(start, end):
            fraction = seg[index + 1] / span
            acc_t += maneuver_time * fraction
            acc_d += seg[index + 1]
            time_at[index + 1] = acc_t
            dist_at[index + 1] = acc_d
            written[index + 1] = True
    for index in range(1, count):
        if not written[index]:
            time_at[index] = time_at[index - 1]
            dist_at[index] = dist_at[index - 1] + seg[index]
        else:
            if dist_at[index] < dist_at[index - 1]:
                dist_at[index] = dist_at[index - 1] + seg[index]
            if time_at[index] < time_at[index - 1]:
                time_at[index] = time_at[index - 1]
    return time_at, dist_at


def _street_names(maneuvers: list[dict[str, Any]]) -> list[str]:
    names: list[str] = []
    for maneuver in maneuvers:
        street_names = maneuver.get("street_names") or []
        if not street_names:
            continue
        name = str(street_names[0])
        if not names or names[-1] != name:
            names.append(name)
    return names


def _sample_indexes(
    shape: list[tuple[float, float]],
    dist_at: list[float],
    user: tuple[float, float],
) -> list[int]:
    total = dist_at[-1]
    chosen: list[int] = []
    next_mark = 0.0
    closest: tuple[float, int] | None = None
    for index, point in enumerate(shape):
        remaining = total - dist_at[index]
        if remaining < ROUTE_TAIL_M:
            continue
        if haversine(point, user) < PIN_SEPARATION_M:
            continue
        distance = haversine(point, user)
        if closest is None or distance < closest[0]:
            closest = (distance, index)
        if dist_at[index] + 1e-6 >= next_mark:
            chosen.append(index)
            next_mark = dist_at[index] + 45.0
    if closest and closest[1] not in chosen:
        chosen.append(closest[1])
    # Solo pueden entrar al umbral máximo los que están a esa distancia en
    # línea recta o menos: la caminata por la calle nunca es más corta.
    within = [index for index in chosen if haversine(shape[index], user) <= THRESHOLD_MAX_M]
    if len(within) > 36:
        step = len(within) / 36
        reduced = [within[int(i * step)] for i in range(36)]
        if closest and closest[1] in within and closest[1] not in reduced:
            reduced.append(closest[1])
        within = reduced
    return within


def _walk_matrix(user: tuple[float, float], points: list[tuple[float, float]]) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    for offset in range(0, len(points), 20):
        chunk = points[offset : offset + 20]
        payload = _post(
            "/sources_to_targets",
            {
                "sources": [{"lat": user[0], "lon": user[1]}],
                "targets": [{"lat": point[0], "lon": point[1]} for point in chunk],
                "costing": "pedestrian",
            },
        )
        rows = payload.get("sources_to_targets") or []
        if not rows:
            raise RoutingError("No se pudo medir la caminata por la calle.")
        for cell in rows[0]:
            distance = cell.get("distance")
            duration = cell.get("time")
            if distance is None or duration is None:
                results.append({"walk_m": None, "walk_s": None})
            else:
                results.append({"walk_m": float(distance) * 1000.0, "walk_s": float(duration)})
    return results


def snap_to_road(lat: float, lon: float, max_snap_m: float = 55.0) -> tuple[float, float] | None:
    payload = _post(
        "/locate",
        {"locations": [{"lat": lat, "lon": lon}], "costing": "auto", "verbose": True},
    )
    if not isinstance(payload, list) or not payload:
        return None
    edges = payload[0].get("edges") or []
    if not edges:
        return None
    best = min(edges, key=lambda edge: float(edge.get("distance") or 1e9))
    if float(best.get("distance") or 1e9) > max_snap_m:
        return None
    return float(best["correlated_lat"]), float(best["correlated_lon"])


def random_car(user: tuple[float, float]) -> tuple[float, float]:
    for _ in range(14):
        bearing = random.random() * math.tau
        distance = math.sqrt(random.random() * (CAR_RADIUS_M**2 - CAR_MIN_M**2) + CAR_MIN_M**2)
        lat, lon = _offset(user[0], user[1], distance, bearing)
        try:
            snapped = snap_to_road(lat, lon)
        except RoutingError:
            continue
        if snapped is None:
            continue
        if CAR_MIN_M * 0.7 <= haversine(snapped, user) <= CAR_RADIUS_M:
            return snapped
    raise RoutingError("No encontré una calle para el carro dentro de 2 km.")


def _point_at(shape: list[tuple[float, float]], dist_at: list[float], target_m: float) -> tuple[float, float]:
    if target_m <= 0:
        return shape[0]
    for index in range(1, len(shape)):
        if dist_at[index] + 1e-6 >= target_m:
            span = dist_at[index] - dist_at[index - 1]
            if span <= 1e-6:
                return shape[index]
            fraction = (target_m - dist_at[index - 1]) / span
            lat = shape[index - 1][0] + fraction * (shape[index][0] - shape[index - 1][0])
            lon = shape[index - 1][1] + fraction * (shape[index][1] - shape[index - 1][1])
            return (lat, lon)
    return shape[-1]


def _cache_key(user: tuple[float, float], car: tuple[float, float]) -> tuple:
    return (round(user[0], 5), round(user[1], 5), round(car[0], 5), round(car[1], 5))


def _analyze(user: tuple[float, float], car: tuple[float, float]) -> dict[str, Any]:
    key = _cache_key(user, car)
    with _lock:
        cached = _analysis_cache.get(key)
    if cached is not None:
        return cached

    drive = _route(car, user, "auto")
    shape: list[tuple[float, float]] = drive["shape"]
    time_at, dist_at = _metrics(shape, drive["maneuvers"])
    # El carro queda sobre la geometría real, no en el punto suelto.
    snapped_car = shape[0]
    indexes = _sample_indexes(shape, dist_at, user)
    points = [shape[index] for index in indexes]
    walks = _walk_matrix(user, points) if points else []
    candidates = []
    for index, walk in zip(indexes, walks):
        candidates.append(
            {
                "lat": shape[index][0],
                "lon": shape[index][1],
                "drive_s": time_at[index],
                "along_m": dist_at[index],
                "walk_m": walk["walk_m"],
                "walk_s": walk["walk_s"],
            }
        )
    analysis = {
        "user": user,
        "car": snapped_car,
        "shape": shape,
        "dist_at": dist_at,
        "duration_s": drive["duration_s"],
        "distance_m": drive["distance_m"],
        "streets": _street_names(drive["maneuvers"]),
        "candidates": candidates,
    }
    with _lock:
        if len(_analysis_cache) > 24:
            _analysis_cache.pop(next(iter(_analysis_cache)))
        _analysis_cache[key] = analysis
        # También bajo la posición ya ajustada a la calle, que es la que
        # vuelve al navegador y se reenvía al mover el deslizador.
        _analysis_cache[_cache_key(user, snapped_car)] = analysis
    return analysis


def _walk_route(user: tuple[float, float], point: tuple[float, float]) -> dict[str, Any]:
    key = (
        round(user[0], 5),
        round(user[1], 5),
        round(point[0], 5),
        round(point[1], 5),
    )
    with _lock:
        cached = _walk_cache.get(key)
    if cached is not None:
        return cached
    route = _route(user, point, "pedestrian")
    stored = {
        "geometry": [[lat, lon] for lat, lon in route["shape"]],
        "distance_m": route["distance_m"],
        "duration_s": route["duration_s"],
    }
    with _lock:
        if len(_walk_cache) > 48:
            _walk_cache.pop(next(iter(_walk_cache)))
        _walk_cache[key] = stored
    return stored


def format_duration(seconds: float) -> str:
    total = int(round(seconds))
    if total < 60:
        word = "segundo" if total == 1 else "segundos"
        return f"{total} {word}"
    minutes, remainder = divmod(total, 60)
    minute_word = "minuto" if minutes == 1 else "minutos"
    if remainder == 0:
        return f"{minutes} {minute_word}"
    second_word = "segundo" if remainder == 1 else "segundos"
    return f"{minutes} {minute_word} y {remainder} {second_word}"


def rough_meters(distance_m: float) -> int:
    meters = int(round(distance_m))
    if meters >= 100:
        return int(round(meters / 10.0) * 10)
    return meters


def _popup_text(savings_s: float, walk_m: float, walk_s: float) -> str:
    return (
        "Detectamos que si te mueves a este punto puedes ahorrarte "
        f"{format_duration(savings_s)}. "
        f"Caminarías unos {rough_meters(walk_m)} metros, "
        f"cerca de {format_duration(walk_s)}."
    )


def _choose(analysis: dict[str, Any], threshold_m: int) -> dict[str, Any] | None:
    user: tuple[float, float] = analysis["user"]
    total_drive = float(analysis["duration_s"])
    ranked = []
    for candidate in analysis["candidates"]:
        walk_m = candidate["walk_m"]
        walk_s = candidate["walk_s"]
        if walk_m is None or walk_s is None:
            continue
        if walk_m > threshold_m:
            continue
        point = (candidate["lat"], candidate["lon"])
        if haversine(point, user) < PIN_SEPARATION_M:
            continue
        meeting_s = max(float(candidate["drive_s"]), float(walk_s))
        savings_s = total_drive - meeting_s
        if int(round(savings_s)) < MIN_SAVINGS_S:
            continue
        ranked.append((savings_s, walk_m, candidate))
    ranked.sort(key=lambda item: (-item[0], item[1]))

    for savings_s, _walk_m, candidate in ranked[:4]:
        point = (candidate["lat"], candidate["lon"])
        try:
            walked = _walk_route(user, point)
        except RoutingError:
            continue
        if walked["distance_m"] > threshold_m:
            continue
        if haversine(point, user) < PIN_SEPARATION_M:
            continue
        meeting_s = max(float(candidate["drive_s"]), float(walked["duration_s"]))
        confirmed = total_drive - meeting_s
        if int(round(confirmed)) < MIN_SAVINGS_S:
            continue
        return {
            "lat": point[0],
            "lon": point[1],
            "drive_s": float(candidate["drive_s"]),
            "walk_m": float(walked["distance_m"]),
            "walk_s": float(walked["duration_s"]),
            "meeting_s": meeting_s,
            "savings_s": confirmed,
            "geometry": walked["geometry"],
            "popup": _popup_text(confirmed, walked["distance_m"], walked["duration_s"]),
            "matrix_savings_s": savings_s,
        }
    return None


def _public_point(point: tuple[float, float]) -> dict[str, float]:
    return {"lat": point[0], "lon": point[1]}


def _result(
    analysis: dict[str, Any],
    threshold_m: int,
    *,
    note: str | None = None,
    moved_m: float | None = None,
) -> dict[str, Any]:
    chosen = _choose(analysis, threshold_m)
    quiet = "Dentro de este umbral no hay un punto útil sobre la ruta del carro."
    payload: dict[str, Any] = {
        "ok": True,
        "threshold_m": threshold_m,
        "user": _public_point(analysis["user"]),
        "car": _public_point(analysis["car"]),
        "drive": {
            "geometry": [[lat, lon] for lat, lon in analysis["shape"]],
            "distance_m": round(analysis["distance_m"]),
            "duration_s": round(analysis["duration_s"]),
            "streets": analysis["streets"],
        },
        "show_popup": chosen is not None,
        "meeting": None,
        "popup": None,
        "status": quiet,
        "note": note,
        "moved_m": None if moved_m is None else round(moved_m),
        "center": MAP_CENTER,
    }
    if chosen is not None:
        payload["meeting"] = {
            "lat": chosen["lat"],
            "lon": chosen["lon"],
            "walk_geometry": chosen["geometry"],
            "walk_m": round(chosen["walk_m"]),
            "walk_s": round(chosen["walk_s"]),
            "drive_s": round(chosen["drive_s"]),
            "meeting_s": round(chosen["meeting_s"]),
            "savings_s": round(chosen["savings_s"]),
        }
        payload["popup"] = chosen["popup"]
        payload["status"] = chosen["popup"]
    return payload


def _advance(user: tuple[float, float], car: tuple[float, float]) -> tuple[tuple[float, float], float | None, str | None]:
    analysis = _analyze(user, car)
    dist_at: list[float] = analysis["dist_at"]
    total = dist_at[-1] if dist_at else 0.0
    room = total - ROUTE_TAIL_M
    if room < 80:
        return analysis["car"], None, "El carro ya está junto al pin. No queda un tramo claro por avanzar."
    goal = min(float(STEP_M), room)
    destination = _point_at(analysis["shape"], dist_at, goal)
    return destination, goal, f"El carro avanzó unos {int(round(goal))} m por su ruta."


def evaluar(
    user: dict[str, Any],
    car: dict[str, Any] | None,
    threshold_m: float,
    *,
    place_random_car: bool = False,
    advance: bool = False,
) -> dict[str, Any]:
    threshold = clamp_threshold(threshold_m)
    origin = (float(user["lat"]), float(user["lon"]))
    note = None
    moved_m = None
    if place_random_car or car is None:
        vehicle = random_car(origin)
        note = "Hay un carro nuevo sobre la calle, a menos de 2 km."
    else:
        vehicle = (float(car["lat"]), float(car["lon"]))
        if advance:
            vehicle, moved_m, note = _advance(origin, vehicle)
    analysis = _analyze(origin, vehicle)
    return _result(analysis, threshold, note=note, moved_m=moved_m)


def inicio(threshold_m: float = THRESHOLD_DEFAULT_M) -> dict[str, Any]:
    result = evaluar(PRESET_USER, PRESET_CAR, threshold_m)
    result["preset"] = True
    result["place"] = "Avenida Insurgentes Sur, Nápoles, Ciudad de México"
    return result
