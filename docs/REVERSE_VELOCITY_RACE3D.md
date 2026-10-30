# Reverse Velocity 0.2: carrera física en un mundo 3D

La versión anterior podía cambiar la orientación física sin girar de forma
coherente la carretera dibujada. El ancho visible también difería del usado
para detectar fuera de pista. Esta versión reemplaza esas dos geometrías por
un único circuito de mundo en centímetros.

## Reglas y geometría

`world.xi` construye un estadio de 81 vértices y 80 segmentos, aproximadamente
1.598,6 metros. Su tabla de posiciones y tangentes alimenta tanto el detector
de pista como la malla visible. El coche tiene posición x/z, velocidad x/z,
orientación, volante progresivo, adherencia lateral y residuos de integración.
El acelerador, freno, resistencia y derrape afectan esas variables a pasos de
20 ms. Las barreras incluyen el radio del coche y resuelven contacto/reflexión.

La carrera tiene tres vueltas, cuatro sectores ordenados por vuelta, una
cuenta atrás de 150 ticks, tres rivales y clasificación. Los rivales siguen
la misma tabla; los contactos con el jugador se calculan con sus posiciones.
Al terminar, salen de la meta hacia aparcamiento y dejan de bloquear a los
participantes activos. La clasificación conserva el orden de llegada.

El modelo es arcade: no simula neumáticos de competición, suspensión, caja de
cambios ni dinámica de carrocería. Los rivales siguen trayectorias prescritas;
no constituyen otro simulador de vehículo independiente.

## REgraphics y propiedad del estado

XI define vértices, transformaciones de cámara y materiales. Las primitivas
genéricas `meshvertex`, `meshread`, `meshface`, `meshtri` y `meshtri3` aportan
un búfer temporal de vértices, proyección, clipping cercano y rasterización con
z-buffer recíproco. `meshend` resuelve la visibilidad y emite XFS1 revisión 2.
El presentador Java valida todas las filas antes de tocar la imagen. La salida
admite hasta una región por píxel horizontal: una escena con bordes de coches,
árboles y pista puede superar las 47 regiones del primer límite provisional.
La regresión de 640 píxeles alternados verifica el caso máximo válido.

`localget/localset` acceden a 4.096 enteros temporales por ejecución. Los
proyectados, contadores y parámetros de imagen no se escriben en InverseMemory
ni aparecen en RVPC2. Las instrucciones `load16/load32/store16/store32` amplían
el acceso little-endian al estado durable existente. Los programas XI y las
instrucciones de imagen anteriores conservan sus contratos.

La física escribe su RVPC2 privado. Un fotograma captura una copia inmutable,
libera el monitor y ejecuta la observación aparte. El resultado de estado del
render se descarta. Android presenta la imagen y recibe controles; la física
permanece en `drive.xi`.

Se ejecuta fuente XI mediante el runtime existente. El compilador de RXE aún
no admite las nuevas instrucciones mesh, bulk y scratch; no se afirma que el
shader esté compilado a RXE.

## Aspecto y alcance

Los coches tienen malla con carrocería, cristales, cuatro ruedas y alerón.
La pista posee bordillos, líneas y barreras con profundidad real. Hay árboles
volumétricos y un horizonte sencillo. Tres cámaras siguen la orientación del
coche; la vista de capó muestra la geometría pintada del propio vehículo.

El acabado es sencillo, con una paleta de 256 materiales y sombreado por caras.
No incluye PBR, texturas fotográficas, reflejos geométricos, sombras dinámicas
ni el detalle de los juegos Forza mostrados como referencia. Esa dirección
visual exige trabajo adicional en iluminación, assets y ejecución gráfica.

## Evidencia reproducible

`reverse-os-android/tests/velocity-gameplay-contract.cpp` ejecuta los programas
XI reales. Su piloto decide únicamente gas/freno/volante leyendo observaciones;
no escribe posición, vueltas ni sectores durante la carrera. Completó 7.151
entradas y doce sectores, 143,04 segundos virtuales, sin salidas ni paredes.
Las pruebas separadas de contacto sí fuerzan una trayectoria hacia la pared.
También se comparan 1.000 entradas con ejecución residente y con guardado y
restauración RVPC2 en cada tick. La llegada queda congelada bajo nuevas entradas.

La medición local O1 sobre Linux dio 1,892 ms/tick residente y 2,748 ms/tick
incluyendo guardado/restauración. Son tiempos del host, no FPS del teléfono.
El JSON guarda pin, hashes, configuración y alcance de la prueba.

La prueba de escena recorre 45 modos y cuatro poses de inspección. Esas poses
solo prueban imagen/cámara; no se usan como evidencia de completar una vuelta.
Las pruebas JNI incluyen aislamiento y ejecución concurrente con la conducción.
El workflow Android instala el APK real, opera controles y graba vídeo. Ninguna
prueba emulada acredita todavía el rendimiento de un Samsung físico.

El autor de malla es `scripts/author-velocity-scene.cjs`; genera `render.xi` y
`palette.txt` de forma determinista. Es una herramienta de autoría, no el motor
ni la física que ejecuta el APK.

La misma instantánea que rebasaba el límite provisional de 47 regiones ahora
emite 48 regiones válidas. La prueba adicional recorrió tres vueltas con
catorce observaciones privadas en ruta y un resultado físico final idéntico
byte por byte al recorrido sin imágenes. Véanse
`docs/evidence/velocity-race3d-coupled.json` y
`docs/evidence/velocity-race3d-fragmentation-reproduction.json`.
