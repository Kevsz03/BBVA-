"""Servidor del prototipo. La decisión (umbral, ahorro, aviso) vive aquí."""

from __future__ import annotations

import json
from pathlib import Path

from flask import Flask, request, send_from_directory

import recogida

BASE = Path(__file__).resolve().parent
STATIC = BASE / "static"

app = Flask(__name__, static_folder=str(STATIC))
app.json.ensure_ascii = False
app.config["SEND_FILE_MAX_AGE_DEFAULT"] = 0


def _json(payload: dict, status: int = 200):
    return app.response_class(
        response=json.dumps(payload, ensure_ascii=False),
        status=status,
        mimetype="application/json; charset=utf-8",
    )


def _point(raw, name: str):
    if not isinstance(raw, dict):
        raise ValueError(f"Falta {name}.")
    lat = float(raw["lat"])
    lon = float(raw["lon"])
    if not (-90 <= lat <= 90 and -180 <= lon <= 180):
        raise ValueError(f"{name} está fuera de rango.")
    return {"lat": lat, "lon": lon}


@app.get("/")
def home():
    return send_from_directory(STATIC, "index.html")


@app.get("/api/inicio")
def api_inicio():
    threshold = request.args.get("threshold_m", recogida.THRESHOLD_DEFAULT_M)
    try:
        return _json(recogida.inicio(threshold))
    except recogida.RoutingError as exc:
        return _json({"ok": False, "error": str(exc), "show_popup": False}, 502)


@app.post("/api/estado")
def api_estado():
    body = request.get_json(silent=True) or {}
    try:
        user = _point(body.get("user"), "el pin")
        car = body.get("car")
        if car is not None:
            car = _point(car, "el carro")
        result = recogida.evaluar(
            user,
            car,
            body.get("threshold_m", recogida.THRESHOLD_DEFAULT_M),
            place_random_car=bool(body.get("place_random_car")),
            advance=bool(body.get("advance")),
        )
        return _json(result)
    except (TypeError, ValueError) as exc:
        return _json({"ok": False, "error": str(exc), "show_popup": False}, 400)
    except recogida.RoutingError as exc:
        return _json({"ok": False, "error": str(exc), "show_popup": False}, 502)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8765, threaded=True)
