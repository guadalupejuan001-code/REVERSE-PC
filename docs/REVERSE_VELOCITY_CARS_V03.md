# Reverse Velocity 0.3: coches con curvas y materiales

El modelo anterior tenía una carrocería formada por cajas, un alerón rectangular
y ruedas de ocho lados. La iluminación por caras hacía difícil percibir volumen.
Esta versión cambia tanto la malla como la forma de sombrearla dentro de REgraphics.

## Modelo y escala

El deportivo es original, sin marcas ni modelos comerciales copiados. Mide
4,50 m de largo, 2,00 m de ancho y 1,15 m de alto, con batalla de 2,80 m.
La carrocería se construye con secciones curvas, pasos de rueda abiertos,
fastback bajo, cristales inclinados y ducktail integrado en el maletero.
Incluye faros LED, tomas laterales, espejos, difusor, escapes y llantas de cinco
radios. La malla alta usa neumáticos de dieciséis segmentos.

| Malla | Posiciones de autoría | Triángulos |
| --- | ---: | ---: |
| Jugador, detalle alto | 693 | 886 |
| Rivales cercanos | 223 | 300 |
| Rivales lejanos | 102 | 110 |

Las normales por esquina respetan pliegues y separaciones entre pintura,
cristal, goma y metal. Esto requiere 947/370/174 entradas de vértice para
sombrear las tres mallas, aunque varias comparten posición. La transformación
reutiliza cada posición ya calculada para evitar repetir las mismas cuentas.
Los arcos se verificaron con holgura sobre los neumáticos, incluidos los LOD.

## Iluminación ejecutada en XI

XI transforma la luz y la vista al espacio local del coche y calcula iluminación
por grupos de normales. La pintura combina luz difusa, ambiente del cielo y un
highlight de exponente 16 aproximando una capa brillante. El cristal emplea la
componente vertical del vector reflejado para elegir una aproximación de cielo
y suelo, con tinte oscuro. Las sombras de contacto son elipses con gradiente.

El cálculo usa 83 grupos de normales, con 24 tonos por pintura y 24 para cristal.
Solo se calculan los grupos que necesita el LOD y el material activos; los trece
grupos de cristal no obligan a evaluar reflejos para toda la carrocería.

`meshshade` asigna una intensidad temporal a un vértice. `meshfacegradient`
interpola ese atributo con perspectiva y clipping cercano y selecciona una
rampa de la paleta. La nueva primitiva es genérica; las ecuaciones de iluminación
y las transformaciones del juego siguen en XI. Se conserva XFS1 y el presentador.

Son reflejos de un entorno aproximado y sombreado interpolado. Todavía no hay
texturas fotográficas, interior completo, transparencia física ni reflexión de
la escena mediante trazado de rayos. El resultado sigue siendo simplificado.

## Ejecución y límites

El presupuesto conserva 4.096 triángulos, 4.096 IDs de vértice, ocho millones de
pruebas de píxel y el máximo natural de una región visible por píxel de fila.
La cota del escenario completo es 4.056 triángulos; los árboles usan geometría
más ligera para reservar detalle a los vehículos sin reducir su cantidad.

Los IDs locales de modelo están por debajo de 1600, la pista usa 1600..1761 y
los vértices transformados comienzan en 2048. La intensidad, las tablas y los
búferes del render son temporales y no se publican como estado de conducción.
Las fuentes `drive.xi` y `world.xi` conservan los hashes de la versión 0.2.

El runtime mantiene una sola entrada de programa ya parseado por hilo, comparada
por fuente exacta y limitada a 512 KiB. Los registros, el estado y los resultados
siguen siendo nuevos en cada ejecución. Java también reutiliza una sola cadena
de programa para cada entrada/perfil actual, evitando reconstruir el shader
entero en cada fotograma. Ninguna caché conserva estado físico ni imágenes.

`Nitidez` permite elegir `Alta`, a 640×360, manteniendo esa resolución aunque
cueste más tiempo por imagen. `Auto` restaura 480×270 con reducción adaptativa
a 320×180. La física sigue en su trabajador independiente. La aplicación no
presenta 640×360 como resolución HD.

## Autoría y validación

Los módulos de autoría son `velocity-car-mesh.cjs`, `velocity-materials.cjs`
y `emit-velocity-car-scene.cjs`; `author-velocity-scene.cjs` produce los assets
XI y la paleta. El APK ejecuta esos assets mediante XI, no el código Node.
El compilador RXE todavía no codifica las primitivas nuevas.

Las pruebas cubren normales, holgura de ruedas, rangos de vértices, presupuesto,
interpolación con perspectiva y clipping, casos planos anteriores, rollback,
caché por hilo y conservación del estado físico. Las vistas de inspección son
renders reales del mismo modelo y motor; no son imágenes generadas por IA.
Los resultados de Android y la APK se registran en `REVERSE_VELOCITY_APK.md`.
