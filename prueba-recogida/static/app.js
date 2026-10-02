const MAPA_MS = 6000;
const RADAR_MS = 5000;

const map = L.map("map", { zoomControl: true }).setView([19.391, -99.1735], 16);

L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
  attribution: '&copy; OpenStreetMap',
  maxZoom: 19,
}).addTo(map);

const umbral = document.getElementById("umbral");
const umbralValor = document.getElementById("umbral-valor");
const statusEl = document.getElementById("status");
const notaEl = document.getElementById("nota");
const avanzarBtn = document.getElementById("avanzar");
const aleatorioBtn = document.getElementById("aleatorio");
const aviso = document.getElementById("aviso");
const avisoTexto = document.getElementById("aviso-texto");
const aceptarBtn = document.getElementById("aceptar");
const rechazarBtn = document.getElementById("rechazar");
const controles = document.getElementById("controles");

const capas = L.layerGroup().addTo(map);
let usuario = null;
let carro = null;
let solicitud = 0;
let ajustando = false;
let timer = null;
let firmaAviso = "";
let decision = null;
let ultimo = null;
let radar = null;
let secuencia = [];

function icono(clase) {
  return L.divIcon({
    className: "",
    html: `<div class="marca ${clase}"></div>`,
    iconSize: [32, 32],
    iconAnchor: [16, 16],
  });
}

function iconoRadar() {
  return L.divIcon({
    className: "radar-icono",
    html: '<div class="radar" aria-hidden="true"><i></i><i></i><i></i></div>',
    iconSize: [200, 200],
    iconAnchor: [100, 100],
  });
}

function pintarUmbral() {
  umbralValor.textContent = `${umbral.value} m`;
}

function ocupado(activo) {
  avanzarBtn.disabled = activo;
  aleatorioBtn.disabled = activo;
  aceptarBtn.disabled = activo;
  rechazarBtn.disabled = activo;
}

function firmaDe(datos) {
  if (!datos || !datos.show_popup || !datos.meeting) return "";
  const punto = datos.meeting;
  return [
    datos.threshold_m,
    Number(punto.lat).toFixed(5),
    Number(punto.lon).toFixed(5),
    Number(datos.car.lat).toFixed(5),
    Number(datos.car.lon).toFixed(5),
  ].join("|");
}

function limpiarSecuencia() {
  secuencia.forEach((id) => clearTimeout(id));
  secuencia = [];
  quitarRadar();
}

function quitarRadar() {
  if (radar) {
    map.removeLayer(radar);
    radar = null;
  }
}

function mostrarRadar() {
  if (!usuario || radar) return;
  radar = L.marker([usuario.lat, usuario.lon], {
    icon: iconoRadar(),
    interactive: false,
    zIndexOffset: 350,
  }).addTo(map);
}

function cerrarAviso() {
  aviso.hidden = true;
}

function mensajeError(texto) {
  limpiarSecuencia();
  cerrarAviso();
  controles.hidden = false;
  statusEl.className = "status error";
  statusEl.textContent = texto;
  notaEl.textContent = "";
}

function encuadrar(puntos, conControles) {
  const grupo = L.latLngBounds(puntos[0], puntos[0]);
  puntos.slice(1).forEach((punto) => grupo.extend(punto));
  const abajo = conControles ? 220 : 90;
  map.invalidateSize();
  map.fitBounds(grupo, {
    paddingTopLeft: [48, 96],
    paddingBottomRight: [48, abajo],
    maxZoom: 16,
    animate: false,
  });
}

function programarEntrada() {
  limpiarSecuencia();
  controles.hidden = true;
  cerrarAviso();
  secuencia.push(setTimeout(() => {
    if (decision !== null) return;
    mostrarRadar();
  }, MAPA_MS));
  secuencia.push(setTimeout(() => {
    if (decision !== null || !ultimo || !ultimo.show_popup) return;
    quitarRadar();
    avisoTexto.textContent = ultimo.popup;
    aviso.hidden = false;
  }, MAPA_MS + RADAR_MS));
}

async function pedir(opciones) {
  const id = ++solicitud;
  ocupado(true);
  const cuerpo = {
    user: usuario,
    car: carro,
    threshold_m: Number(umbral.value),
    place_random_car: Boolean(opciones.aleatorio),
    advance: Boolean(opciones.avanzar),
  };
  try {
    const respuesta = await fetch("/api/estado", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(cuerpo),
    });
    const datos = await respuesta.json();
    if (id !== solicitud) return;
    if (!datos.ok) {
      mensajeError(datos.error || "No se pudo calcular la ruta por la calle.");
      return;
    }
    aplicar(datos, opciones.encuadrar !== false);
  } catch (error) {
    if (id !== solicitud) return;
    mensajeError("No se pudo hablar con el servidor de rutas.");
  } finally {
    if (id === solicitud) ocupado(false);
  }
}

function programar(opciones) {
  clearTimeout(timer);
  timer = setTimeout(() => pedir(opciones), 40);
}

function aplicar(datos, reencuadrar) {
  usuario = datos.user;
  carro = datos.car;
  ultimo = datos;
  if (!ajustando) {
    ajustando = true;
    umbral.value = String(datos.threshold_m);
    pintarUmbral();
    ajustando = false;
  }

  const firma = firmaDe(datos);
  const firmaNueva = firma !== firmaAviso;
  if (firmaNueva) {
    firmaAviso = firma;
    decision = null;
    limpiarSecuencia();
  }

  const hayAviso = Boolean(datos.show_popup && datos.meeting && datos.popup);
  const mostrarPunto = hayAviso && decision === "aceptada";
  const enEntrada = hayAviso && decision === null;

  capas.clearLayers();
  L.polyline(datos.drive.geometry, {
    color: "#1565c0",
    weight: 6,
    opacity: 0.95,
  }).addTo(capas);

  L.marker([datos.user.lat, datos.user.lon], { icon: icono("tu"), zIndexOffset: 500 })
    .addTo(capas)
    .bindTooltip("Tú", { permanent: true, direction: "top", offset: [0, -12], className: "etiqueta etiqueta-tu" });

  L.marker([datos.car.lat, datos.car.lon], { icon: icono("carro"), zIndexOffset: 520 })
    .addTo(capas)
    .bindTooltip("Carro", { permanent: true, direction: "top", offset: [0, -12], className: "etiqueta etiqueta-carro" });

  if (mostrarPunto) {
    L.polyline(datos.meeting.walk_geometry, {
      color: "#2e7d32",
      weight: 5,
      dashArray: "8 8",
    }).addTo(capas);
    L.marker([datos.meeting.lat, datos.meeting.lon], {
      icon: icono("punto"),
      zIndexOffset: 640,
    }).addTo(capas)
      .bindTooltip("Punto nuevo", { permanent: true, direction: "top", offset: [0, -12], className: "etiqueta etiqueta-punto" });
  }

  if (enEntrada && firmaNueva) {
    statusEl.className = "status quiet";
    statusEl.textContent = "Buscando un punto mejor sobre la ruta…";
    programarEntrada();
  } else if (hayAviso && decision === "aceptada") {
    controles.hidden = false;
    cerrarAviso();
    statusEl.className = "status aviso";
    statusEl.textContent = datos.popup;
  } else if (hayAviso && decision === "rechazada") {
    controles.hidden = false;
    cerrarAviso();
    statusEl.className = "status quiet";
    statusEl.textContent = "Seguimos en tu pin. El carro va hacia donde estás.";
  } else if (!hayAviso) {
    controles.hidden = false;
    cerrarAviso();
    statusEl.className = "status quiet";
    statusEl.textContent = datos.status || "Dentro de este umbral no hay un punto útil sobre la ruta del carro.";
  }

  notaEl.textContent = datos.note || "";

  const puntos = [
    [datos.user.lat, datos.user.lon],
    [datos.car.lat, datos.car.lon],
  ];
  if (mostrarPunto) {
    puntos.push([datos.meeting.lat, datos.meeting.lon]);
  }
  if (reencuadrar !== false) {
    encuadrar(puntos, !enEntrada);
  }
}

umbral.addEventListener("input", () => {
  pintarUmbral();
  if (!usuario || ajustando) return;
  programar({ encuadrar: true });
});

aceptarBtn.addEventListener("click", () => {
  if (!ultimo || !ultimo.show_popup) return;
  limpiarSecuencia();
  decision = "aceptada";
  aplicar(ultimo, true);
});

rechazarBtn.addEventListener("click", () => {
  if (!ultimo || !ultimo.show_popup) return;
  const pin = usuario ? { lat: usuario.lat, lon: usuario.lon } : null;
  limpiarSecuencia();
  decision = "rechazada";
  aplicar(ultimo, true);
  if (pin) usuario = pin;
});

avanzarBtn.addEventListener("click", () => {
  if (!usuario || !carro) return;
  pedir({ avanzar: true });
});

aleatorioBtn.addEventListener("click", () => {
  if (!usuario) return;
  statusEl.className = "status quiet";
  statusEl.textContent = "Buscando un carro sobre una calle, a menos de 2 km…";
  pedir({ aleatorio: true });
});

map.on("click", (evento) => {
  if (!aviso.hidden) return;
  usuario = { lat: evento.latlng.lat, lon: evento.latlng.lng };
  carro = null;
  statusEl.className = "status quiet";
  statusEl.textContent = "Nuevo pin. Colocando un carro sobre la calle…";
  pedir({ aleatorio: true });
});

pintarUmbral();
map.invalidateSize();

fetch("/api/inicio")
  .then((respuesta) => respuesta.json())
  .then((datos) => {
    if (!datos.ok) {
      mensajeError(datos.error || "No se pudo calcular la ruta inicial.");
      return;
    }
    aplicar(datos, true);
  })
  .catch(() => mensajeError("No se pudo cargar el escenario inicial."));

window.addEventListener("resize", () => map.invalidateSize());
