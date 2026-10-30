# SUPER RENDER XI — núcleo gráfico programado en XI

## Arquitectura comprobada

Estos tres programas constituyen el núcleo inicial de renderizado por
estados mínimos de REVERSE VELOCITY. Su geometría y sus operaciones se
expresan únicamente en XI Machine v1, ejecutado por el QuantumRuntime/Ether
original del proyecto.

- scene.xi: horizonte, asfalto procedural, curvas, arcenes, marcas viales,
  material de fondo, distancia y fase de las líneas. Emite regiones por fila,
  no asigna por adelantado un arreglo de píxeles por cada imagen.
- triangle.xi: rasterización exacta por filas de triángulos arbitrarios,
  recorte a ventana y publicación de material y profundidad. El motor puede
  procesar nuevas primitivas de forma sucesiva, sin tabla global de cuerpos.
- project.xi: proyección 3D a 2D con cámara dirigida al eje -Z, enteros de
  64 bits y escritura de vértices proyectados en la misma memoria Ether.
  Los triángulos usan directamente esos vértices, sin recalcular geometría
  fuera de XI. Un plano cercano inválido rechaza la transacción completa.

El anfitrión actual de las pruebas descodifica los descriptores en filas de
píxeles y puede generar una vista de 1280×720. Ese presentador no contiene
las ecuaciones del escenario, intersección de triángulos ni proyección 3D.
La salida física al dispositivo sigue siendo una integración pendiente.

## Compilación y archivos

El workflow de este directorio genera tres ejecutables originales:

- SUPER-RENDER-XI.rxe
- SUPER-TRIANGLE-XI.rxe
- SUPER-PROJECT-XI.rxe

Usa la rama exacta de Mundo X fijada por REVERSE-PC, prepara el
QuantumRuntime propio y compila los tres fuentes XI. Los archivos .rxe,
sus SHA-256, las vistas generadas y las evidencias se publican como
artefactos de GitHub Actions. Los ejecutables no representan una APK.

## Contratos de memoria

scene.xi:

- 200..203 uint32 LE ancho lógico
- 204..207 uint32 LE alto lógico
- 208..211 uint32 LE primera fila
- 212..215 uint32 LE cantidad de filas
- 216 uint8 curvatura, 128 equivale a sin giro
- 217 uint8 fase de las líneas

triangle.xi utiliza las mismas cuatro ventanas uint32; interpreta
los seis valores de coordenadas XY32 en 216..239 como enteros con sesgo
2.147.483.648, profundidad en 240 y material en 241.

project.xi lee tres posiciones de vértices XYZ32 con sesgo en
300..335, la cámara XYZ32 con sesgo en 336..347, distancia focal
uint32 en 348..351, y escribe las coordenadas XY32 directamente
en 216..239 para triangle.xi.

Las unidades son enteras con truncamiento hacia cero. Los programas
no escriben en la sesión RVPC2 del escritorio ni de BBY Q: el ejecutor
de prueba utiliza una instantánea privada de Ether.

## Límites, físicos y de configuración

El X Render espacial anterior incluye 4.096 cuerpos/IDs y 8.192 como
límite por dimensión. El nuevo núcleo XI no necesita una reserva de
todos los cuerpos ni una dimensión máxima de 8.192 píxeles; trabaja
en ventanas de filas y en primitivas transmitidas sucesivamente.

XI Machine v1 todavía tiene 16 registros, 1.000.000 de instrucciones
por ejecución y un presupuesto de salida de 16 MiB. No se desactivan
las comprobaciones: se divide la tarea y se continúa con el bloque
siguiente. Las dimensiones del protocolo se codifican en uint32;
las coordenadas del triángulo en int32. El rendimiento, la aritmética,
la memoria física, el ancho de banda y el dispositivo siguen siendo
recursos finitos.

## Pruebas realizadas

- Escenario procedural de 640×360, 720p, 1080p, 4K, 8K y 16K como
  flujo de reglas y expansión en host, incluyendo invariancia de bloques.
- 20 triángulos, ambos sentidos de recorrido, recorte, geometría
  degenerada, muestras aleatorias y 287.691 comprobaciones de píxeles
  independientes; rasterización por filas también a 16K lógico.
- Cuatro escenas con proyección 3D, persistencia en Ether, ejecución
  encadenada del rasterizador y rechazo transaccional de plano cercano.
- Verificación de equivalencia entre fuente XI y ejecutables compilados.

**16K lógico no implica 16K presentado, ni 60/120 FPS.** Las pruebas
de escenario no incluyen sombras físicas, múltiples mallas con
oclusión general, texturas PBR ni presentación GPU. La cámara de la
primera etapa mantiene orientación fija; la rotación y clipping
de triángulos que cruzan el plano cercano siguen pendientes.

## Estado de integración

Este paquete pertenece a una rama de incorporación al videojuego y
aún no sustituye la visualización Android actual. Para REVERSE VELOCITY
la próxima conexión funcional es transportar los descriptores XI al
presentador de pantalla, sincronizarlos con el estado de drive.xi,
y medir FPS, latencia, memoria y temperatura en hardware real.
