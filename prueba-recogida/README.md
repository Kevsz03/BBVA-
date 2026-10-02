# Prueba de recogida

Prototipo en el navegador: el pin es la persona, un carro aparece sobre la calle y se dibuja la ruta **en auto** hasta ese pin. Si caminar hasta un punto de esa ruta acorta la espera, la página avisa.

Las calles, los sentidos (un sentido, avenidas de doble cuerpo, retornos) y la caminata salen de **OpenStreetMap**, calculados con el motor [Valhalla](https://github.com/valhalla/valhalla) público (`valhalla1.openstreetmap.de`). No hace falta una clave. No se dibuja una línea recta como si fuera una ruta: si el motor no responde, la página lo dice.

## Cómo correrlo

```bash
cd prueba-recogida
python -m pip install -r requirements.txt
python app.py
```

Abre [http://127.0.0.1:8765](http://127.0.0.1:8765).

Al entrar, el mapa se ve dentro de un marco de iPhone y se centra en **Avenida Insurgentes Sur** (Nápoles / Del Valle, Ciudad de México), con un pin y un carro ya puestos. En ese caso el carro toma Insurgentes y después tiene que rodear por calles de un sentido para llegar al pin. Con el umbral de fábrica (250 m) el aviso ocupa la pantalla del teléfono: el ahorro, la caminata, y los botones **Aceptar** y **Rechazar**. Aceptar deja marcado el punto y la caminata. Rechazar cierra el aviso y el pin no se mueve.

## Qué hace el deslizador

El deslizador es el **umbral de caminata en metros por la calle** (de 50 a 800; empieza en 250). No es la distancia en línea recta.

Al moverlo, el servidor vuelve a decidir enseguida:

1. Toma la ruta en auto del carro al pin y la muestrea.
2. Descarta el tramo final: la ruta siempre termina en el pin, y eso no enciende el aviso.
3. Deja solo los puntos a los que la persona llega **caminando por la calle** dentro del umbral.
4. En cada punto P, el tiempo de encuentro es el mayor entre lo que tarda el carro en llegar a P por la ruta y lo que tardas en caminar a P.
5. El ahorro es el tiempo en auto hasta el pin, menos ese encuentro. Se queda con el P que más ahorra.
6. Si el ahorro es de al menos 30 segundos y P no es el pin, la pantalla del teléfono muestra el aviso. Si no, no hay aviso: solo un texto discreto de que no hay un punto útil en ese umbral.

Un clic en el mapa mueve el pin y coloca otro carro al azar, enganchado a la calle, a menos de 2 km. **Avanzar el carro** lo mueve unos 320 m sobre la ruta actual (se puede pulsar varias veces) y recalcula desde ahí hacia el pin original. **Nuevo carro al azar** mantiene el pin.

## Límite

Hace falta red hacia el servidor público de Valhalla. Cubre las calles que trae OpenStreetMap, no solo la Ciudad de México. Si ese servicio no contesta, esta prueba no inventa la ruta.
