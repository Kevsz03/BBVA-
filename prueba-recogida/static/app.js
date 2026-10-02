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

const capas = L.layerGroup().addTo(map);
let usuario = null;
let carro = null;
let solicitud = 0;
let ajustando = false;
let timer = null;
let firmaAviso = "";
let decision = null;
let ultimo = null;

function icono(clase) {
  return L.divIcon({
    className: "",
    html: `<div class="marca ${clase}"></div>`,
    iconSize: [22, 22],
    iconAnchor: [11, 11],
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

function cerrarAviso() {
  aviso.hidden = true;
}

function mensajeError(texto) {
  cerrarAviso();
  statusEl.className = "status error";
  statusEl.textContent = texto;
  notaEl.textContent = "";
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
    aplicar(datos, opciones.encuadrar);
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

function aplicar(datos, encuadrar) {
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
  if (firma !== firmaAviso) {
    firmaAviso = firma;
    decision = null;
  }

  const hayAviso = Boolean(datos.show_popup && datos.meeting && datos.popup);
  const mostrarPunto = hayAviso && decision !== "rechazada";

  capas.clearLayers();
  const ruta = L.polyline(datos.drive.geometry, {
    color: "#1565c0",
    weight: 5,
    opacity: 0.92,
  }).addTo(capas);

  L.marker([datos.user.lat, datos.user.lon], { icon: icono("tu"), zIndexOffset: 400 })
    .addTo(capas)
    .bindTooltip("Tú", { permanent: true, direction: "right", offset: [8, 0] });

  L.marker([datos.car.lat, datos.car.lon], { icon: icono("carro"), zIndexOffset: 500 })
    .addTo(capas)
    .bindTooltip("Carro", { permanent: true, direction: "left", offset: [-8, 0] });

  const limites = [ruta.getBounds()];
  if (mostrarPunto) {
    const caminata = L.polyline(datos.meeting.walk_geometry, {
      color: "#2e7d32",
      weight: 4,
      dashArray: "7 7",
    }).addTo(capas);
    limites.push(caminata.getBounds());
    L.marker([datos.meeting.lat, datos.meeting.lon], {
      icon: icono("punto"),
      zIndexOffset: 600,
    }).addTo(capas);
  }

  if (hayAviso && decision === null) {
    avisoTexto.textContent = datos.popup;
    aviso.hidden = false;
    statusEl.className = "status aviso";
    statusEl.textContent = "Hay un punto más corto. Elige si te mueves.";
  } else if (hayAviso && decision === "aceptada") {
    cerrarAviso();
    statusEl.className = "status aviso";
    statusEl.textContent = datos.popup;
  } else if (hayAviso && decision === "rechazada") {
    cerrarAviso();
    statusEl.className = "status quiet";
    statusEl.textContent = "Seguimos en tu pin. El carro va hacia donde estás.";
  } else {
    cerrarAviso();
    statusEl.className = "status quiet";
    statusEl.textContent = datos.status || "Dentro de este umbral no hay un punto útil sobre la ruta del carro.";
  }

  notaEl.textContent = datos.note || "";

  if (encuadrar) {
    const grupo = L.latLngBounds(limites[0]);
    limites.slice(1).forEach((marco) => grupo.extend(marco));
    map.fitBounds(grupo, { paddingTopLeft: [24, 56], paddingBottomRight: [24, 210], maxZoom: 16, animate: false });
  }
  map.invalidateSize();
}

umbral.addEventListener("input", () => {
  pintarUmbral();
  if (!usuario || ajustando) return;
  programar({ encuadrar: false });
});

aceptarBtn.addEventListener("click", () => {
  if (!ultimo || !ultimo.show_popup) return;
  decision = "aceptada";
  aplicar(ultimo, false);
});

rechazarBtn.addEventListener("click", () => {
  if (!ultimo || !ultimo.show_popup) return;
  const pin = usuario ? { lat: usuario.lat, lon: usuario.lon } : null;
  decision = "rechazada";
  aplicar(ultimo, false);
  if (pin) {
    usuario = pin;
  }
});

avanzarBtn.addEventListener("click", () => {
  if (!usuario || !carro) return;
  pedir({ avanzar: true, encuadrar: true });
});

aleatorioBtn.addEventListener("click", () => {
  if (!usuario) return;
  statusEl.className = "status quiet";
  statusEl.textContent = "Buscando un carro sobre una calle, a menos de 2 km…";
  pedir({ aleatorio: true, encuadrar: true });
});

map.on("click", (evento) => {
  if (!aviso.hidden) return;
  usuario = { lat: evento.latlng.lat, lon: evento.latlng.lng };
  carro = null;
  statusEl.className = "status quiet";
  statusEl.textContent = "Nuevo pin. Colocando un carro sobre la calle…";
  pedir({ aleatorio: true, encuadrar: true });
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
