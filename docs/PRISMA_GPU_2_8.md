# PRISMA 2.8 — Geometría 3D y lectura de notas

## Cambio de renderizador

En 2.7 los cubos usaban la observación espacial en CPU y GLES presentaba su
textura; los mundos eran decorados dibujados en Canvas. 2.8 añade un backend de
mallas a Ether Render X. En Android, GLES 3 rasteriza y sombrea los triángulos,
con profundidad de 24 bits y MSAA de cuatro muestras cuando la configuración
del dispositivo lo admite. En navegador, WebGL 2 usa los mismos modelos y
shaders. El renderizador CPU anterior conserva sus paquetes v1/v2.

Las cinco escenas tienen geometría: edificios con ventanas y profundidad,
cristales facetados, columnas y medusas, rocas volcánicas, planeta y anillos.
Cada una contiene una pasarela, arcos de escenario y dos bocinas con gabinete,
bafle, conos abiertos, tapas, tornillos y aros LED. La animación de vértices y
el sombreado responden al tiempo y a la energía musical. El HUD, las estelas y
la pirotecnia mantienen su capa vectorial; no se afirma que todo el juego se
calcule en la GPU.

Los modelos se generan una vez y se conservan en VBO. Se precargan antes de
arrancar la música. No se transmiten decenas de miles de vértices por cuadro.
Los shaders compartidos tienen una copia C++ generada y verificada con
`scripts/build-prisma-gpu-shaders.mjs`.

## Llegada y orden

- Anticipación predeterminada de 3,6 segundos; control de 2,8 a 5,2 segundos.
  El tempo de la canción y las marcas de puntuación no se modifican.
- Cubos con biseles geométricos, flechas blancas y cuerpos opacos. Una nota con
  alfa casi nulo ya no escribe profundidad invisible que oculta otra.
- La profundidad del mundo se separa de la de las notas. Una columna o un
  gabinete no pueden borrar un cubo jugable.
- El rango visible depende de la anticipación elegida. Los cubos no se eliminan
  mediante un corte visual fijo a los 250 ms: se retiran al acertar o al recibir
  el juicio de fallo. Un fallo deja brevemente una marca ×.
- El número 1 y su marco claro indican el siguiente golpe. Los ataques
  simultáneos comparten número. La guía PRÓXIMOS mantiene visibles las próximas
  direcciones incluso si se superponen cuerpos en perspectiva.
- El nuevo paquete v3 admite 128 cubos. La prueba de entrada densa produce 68
  notas simultáneamente visibles a 5,2 segundos; no se truncan a 64. Las
  versiones anteriores conservan su límite y su contrato.

La puntuación continúa en XI. Los escenarios y las celebraciones no inventan
aciertos. Se preservan el reloj de salida, el ajuste manual, las sostenidas,
las frases, las constelaciones y los cortes sin sonido añadido.

## Verificación y límites

Las pruebas Node verifican los cinco modelos, sus límites y normales, el bisel,
la paridad de shaders nativos/WebGL, la caché, la anticipación, el orden, los
dobles y la capacidad del paquete. El test C++ conserva la comparación del
observador CPU contra un oráculo independiente y valida la separación v3.

La prueba de navegador juega una pista conocida usando GPU con tres sostenidas,
dos frases y una constelación. La prueba Android comprueba el backend GLES, la
profundidad, la caché de los cinco mundos, la capacidad de 128 descriptores,
la primera nota y la actualización desde 2.7 con un récord conservado.

Los registros separan tiempo CPU de envío y datos del driver. No se presenta
ese tiempo como latencia GPU. Un emulador con SwiftShader valida el camino GLES,
no el rendimiento de la GPU física del Galaxy A16; sus FPS quedan por medir.

Referencias de la API:
- https://developer.android.com/reference/android/opengl/GLSurfaceView
- https://www.khronos.org/developers/linkto/opengl-es-3.1-reference-guide
