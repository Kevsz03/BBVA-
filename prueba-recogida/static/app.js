const map = L.map("map", { zoomControl: true }).setView([19.391, -99.1735], 16);

L.tileLayer("https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png", {
  attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; CARTO',
  subdomains: "abcd",
  maxZoom: 20,
}).addTo(map);

const umbral = document.getElementById("umbral");
const umbralValor = document.getElementById("umbral-valor");
const statusEl = document.getElementById("status");
const callesEl = document.getElementById("calles");
const notaEl = document.getElementById("nota");
const avanzarBtn = document.getElementById("avanzar");
const aleatorioBtn = document.getElementById("aleatorio");

const capas = L.layerGroup().addTo(map);
let usuario = null;
let carro = null;
let solicitud = 0;
let ajustando = false;
let timer = null;

function icono(clase) {
  return L.divIcon({
    className: "",
    html: `<div class="marca ${clase}"></div>`,
    iconSize: [28, 28],
    iconAnchor: [14, 14],
    popupAnchor: [0, -16],
  });
}

function pintarUmbral() {
  umbralValor.textContent = `${umbral.value} m`;
}

function ocupado(activo) {
  avanzarBtn.disabled = activo;
  aleatorioBtn.disabled = activo;
}

function mensajeError(texto) {
  statusEl.className = "status error";
  statusEl.textContent = texto;
  callesEl.textContent = "";
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
  if (!ajustando) {
    ajustando = true;
    umbral.value = String(datos.threshold_m);
    pintarUmbral();
    ajustando = false;
  }
  capas.clearLayers();
  capas._punto = null;

  const ruta = L.polyline(datos.drive.geometry, {
    color: "#1565c0",
    weight: 6,
    opacity: 0.9,
  }).addTo(capas);

  L.marker([datos.user.lat, datos.user.lon], { icon: icono("tu"), zIndexOffset: 400 })
    .addTo(capas)
    .bindTooltip("Tú", { permanent: true, direction: "right", offset: [12, 0] });

  L.marker([datos.car.lat, datos.car.lon], { icon: icono("carro"), zIndexOffset: 500 })
    .addTo(capas)
    .bindTooltip("Carro", { permanent: true, direction: "left", offset: [-12, 0] });

  const limites = [ruta.getBounds()];

  if (datos.show_popup && datos.meeting && datos.popup) {
    const caminata = L.polyline(datos.meeting.walk_geometry, {
      color: "#2e7d32",
      weight: 5,
      dashArray: "8 8",
    }).addTo(capas);
    limites.push(caminata.getBounds());
    const punto = L.marker([datos.meeting.lat, datos.meeting.lon], {
      icon: icono("punto"),
      zIndexOffset: 600,
    }).addTo(capas);
    punto.bindPopup(datos.popup, {
      className: "aviso-popup",
      maxWidth: 320,
      autoPan: true,
      keepInView: true,
      closeOnClick: false,
    });
    statusEl.className = "status aviso";
    statusEl.textContent = datos.popup;
    capas._punto = punto;
  } else {
    statusEl.className = "status quiet";
    statusEl.textContent = datos.status || "Dentro de este umbral no hay un punto útil sobre la ruta del carro.";
  }

  const calles = (datos.drive.streets || []).slice(0, 6);
  callesEl.textContent = calles.length ? `Ruta del carro: ${calles.join(" → ")}` : "";
  notaEl.textContent = datos.note || "";

  if (encuadrar) {
    const grupo = L.latLngBounds(limites[0]);
    limites.slice(1).forEach((marco) => grupo.extend(marco));
    map.fitBounds(grupo, { padding: [48, 48], maxZoom: 16, animate: false });
  }
  if (capas._punto) capas._punto.openPopup();
}

umbral.addEventListener("input", () => {
  pintarUmbral();
  if (!usuario || ajustando) return;
  programar({ encuadrar: false });
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
  usuario = { lat: evento.latlng.lat, lon: evento.latlng.lng };
  carro = null;
  statusEl.className = "status quiet";
  statusEl.textContent = "Nuevo pin. Colocando un carro sobre la calle…";
  pedir({ aleatorio: true, encuadrar: true });
});

pintarUmbral();

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
