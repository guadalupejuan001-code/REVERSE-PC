# Reverse Velocity 3.1 — Reversa y REgraphics nativo durante la conducción

## Fallos reproducidos de 3.0

Al tocar el lado izquierdo del puente, `groundXi` escribía `-120` con
`store16 542`. Ese campo acepta valores sin signo. XI rechazaba correctamente
la transacción y los trabajadores de la aplicación se detenían. El lado derecho
escribía `120` y pasaba. No era un límite de 16 bits del mundo ni de la capacidad
general del motor: los registros de cálculo son enteros de 64 bits y las
posiciones del mapa ya usan campos de 32 bits.

El contacto lateral ahora conserva el signo con sesgo de 32.768 dentro del campo
compacto existente. Se mantienen las comprobaciones de rango y el rollback.

Además, la asistencia frenaba al llegar al claro final antes de comprobar la
marcha R. Las pruebas de 3.0 comprobaban el regreso con asistencia desactivada,
por lo que no detectaron el bloqueo en Asistida/Piloto. Ahora la reversa evita
las órdenes automáticas de avance/frenada y se comprueba en los tres modos.

## Control visible de la reversa

El botón muestra `Reversa R` y, después de seleccionar R, `Avance D`. El indicador
de velocidad añade `R` al retroceder. Una petición de cambio con el coche en
movimiento queda pendiente, muestra `Frenando` y envía el freno real a XI hasta
que XI observa una velocidad menor o igual a 25 cm/s. Entonces se aplica la
marcha. El acelerador permite retroceder y otra pulsación cancela una petición
pendiente. No se invierte instantáneamente una velocidad existente.

`VelocityGearbox` solo secuencia entradas: las fuerzas, posición, frenada,
agarre y velocidad continúan calculándose en `drive.xi`. Reiniciar también
reactiva los trabajadores después de un fallo, en lugar de dejar la vista
detenida hasta salir de la aplicación.

## Renderizadores comparados

Se revisaron las fuentes actuales de Mundo X: el inventario de motores,
`SolarRenderer`, `SolarAdaptiveQuality`, el informe de integración Solar y
la ruta de planificación espacial. Solar usa GLES/shaders y representa un
catálogo compacto de cuerpos; la escala espacial de esos cuerpos no equivale
a enumerar geometría por cada metro del universo. Velocity conserva la petición
previa de usar la rasterización propia REgraphics/XI por software.

La comparación útil dentro de esa arquitectura es:

| Ruta | Preparación y píxeles | Uso en 3.1 |
|---|---|---|
| XI revisión 2 / XFS1 | Escena XI, raster serial, empaquetado/validación por intervalos | Referencia de exactitud conservada en `render.xi` |
| REgraphics nativo / XFB5 | La misma escena, franjas de 32 filas, candidatos espaciales conservadores y píxeles indexados directos | Conducción en `render-live.xi` |
| REgraphics nativo 4K | El mismo núcleo, más franjas y hasta cuatro trabajadores | Fotografía en pausa |

La conducción adapta su resolución entre 320×180, 480×270 y 640×360 y usa hasta
dos trabajadores de raster. Las franjas poseen zonas disjuntas de la imagen y
su propio buffer de profundidad. Se conservan la regla top-left, profundidad,
perspectiva, materiales, texturas y desempates. La limitación de trabajadores
reserva capacidad para física y presentación. Si no se puede crear un hilo,
la reconstrucción serial existente sigue disponible.

La salida directa elimina el análisis y la expansión de miles de intervalos
XFS1 en Java. La imagen sigue siendo calculada por XI/REgraphics: Android
presenta los píxeles. `RegraphicsFrame` valida tamaño, resolución, revisión,
paleta y longitud exactos para cada perfil; la foto 4K conserva su contrato
estricto de 3840×2160.

## Pruebas y medidas reproducibles

- `open-forest-contract.cpp`: recorrido de ocho sectores, reversa al final en
  los tres modos y contactos con ambos lados del puente, además de persistencia,
  suspensión, colisiones y tiempo.
- `open-forest-reliability.cpp`: 54 posturas, 2.592 pasos físicos con aceleración,
  salto, nitro, derrape, frenada y marcha inversa en distintas superficies.
  Compara los píxeles de la ruta activa con la referencia en 54 imágenes,
  cubriendo tres coches, tres cámaras y las tres resoluciones de conducción.
- `open-forest-render-ab.cpp`: cuatro estados congelados y tres resoluciones,
  tres lotes alternados, dos cuadros de calentamiento por lote y 18 muestras
  por variante. Compara cada imagen y escribe p50/p95 y bytes en `render-ab.json`.
  Mide ejecución XI en el anfitrión, excluyendo restauración RVPC2 y presentación
  Java. No convierte esos milisegundos en una promesa de FPS del teléfono.
- `xi_native_tile_raster.cpp`: exactitud de las franjas a las tres resoluciones
  de conducción, profundidad, cobertura, fotografía nativa y límites.
- Pruebas Java: secuencia de marcha, formato directo, compatibilidad 4K y
  conservación de la validación XFS1.
- Android: la prueba debe solicitar R desde un coche en movimiento, observar la
  frenada, aplicar el acelerador y verificar más de un metro real de desplazamiento
  hacia atrás. También verifica garaje, hora, sonido, cámara, foto y reanudación.

La versión es `3.1.0-native-live-xi`, código 31, con el paquete y la firma
originales para actualizar 3.0. El detalle artístico continúa siendo estilizado.
La integración mejora la ruta de ejecución y corrige fallos demostrados; la
calidad Horizon, FPS sostenidos y temperatura del Galaxy A16 no quedan
demostrados por pruebas de anfitrión o emulador.
