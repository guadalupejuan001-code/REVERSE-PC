# Fuentes y límites — Boardwalk → Espacio

## Datos de la Tierra y atmósfera

- NASA Goddard Scientific Visualization Studio, Blue Marble, mosaico
  terrestre equirectangular, 1024×512 PNG:
  https://svs.gsfc.nasa.gov/2915
- Archivo descargado durante la compilación:
  https://svs.gsfc.nasa.gov/vis/a000000/a002900/a002915/bluemarble-1024.png
- Crédito: NASA/Goddard Space Flight Center Scientific Visualization Studio;
  NASA Earth Observatory y Reto Stöckli.
- Radio esférico medio: 6.371 km. Escala de altura atmosférica
  aproximada: 8,5 km. Fuente: NASA Earth Fact Sheet:
  https://nssdc.gsfc.nasa.gov/planetary/factsheet/earthfact.html

La imagen NASA es un mosaico satelital histórico, no el aspecto en tiempo
real de las nubes, hielo u océano. El cálculo de dispersión atmosférica es una
aproximación de dispersión simple a ocho muestras. No reproduce de forma
exhaustiva condiciones meteorológicas, absorción espectral ni nubes 3D.

## Ubicación inicial

- Origen nominal: 39.3584° N, 74.4214° W, Boardwalk, lado tierra, cerca
  de Steel Pier; aproximación para esta demostración, no levantamiento GNSS.
- Steel Pier está aproximadamente en 39.35755° N, -74.41902° W,
  según cartografía pública.
- Steel Pier oficial: https://steelpier.com/contact/
- Referencia geográfica NOAA de la estación Atlantic City:
  https://tidesandcurrents.noaa.gov/benchmarks/8534720.html

Los hoteles, el muelle, la rueda y las tablas del Boardwalk próximos a cámara
son geometría procedimental esquemática, no una reconstrucción 3D a escala
de cada edificio ni un modelo LIDAR de Atlantic City. La textura satelital
global conserva continentes y costa a escala regional.

## ¿Quién sube?

Nadie vuela físicamente. La única entidad que cambia de altitud es el
observador matemático (la cámara), manteniendo una latitud y longitud
fijas en el modelo. No se modelan aceleración de cohete, vida humana,
gravedad como fuerza de movimiento ni órbita balística. A 400 km se encuentra
en una altura semejante a la órbita baja, pero no está orbitando.

La cámara usa un perfil logarítmico de altitud, no un movimiento físicamente
alcanzable por una persona. La curvatura/horizonte se obtiene por
intersección de rayos con la esfera, no por deformar una foto.
Las medidas de gravedad/densidad del HUD son aproximaciones basadas en el
radio esférico y una atmósfera exponencial.

## Continuidad de estado

El observador permanece en el mismo sistema geodético local/ECEF para
todos los fotogramas. La observación local se mezcla con la esfera
NASA en kilómetros cercanos y se conserva el raycast esférico al cruzar
la atmósfera. Los hoteles no se cargan en el shader por encima de 7 km;
la transición de visibilidad se controla por distancia y escala.

Esta demo no ejecuta el núcleo cuántico ni demuestra aceleración cuántica.
Está encapsulada, para no modificar los contratos de Mundo X/REVERSE-PC.

## Grabación del POV

Usar la grabación de pantalla integrada del dispositivo y pulsar
«INICIAR POV». Ocultar el panel para un resultado limpio. La app guarda
capturas PNG en Imágenes/BoardwalkSpace, pero aún no exporta video interno.
