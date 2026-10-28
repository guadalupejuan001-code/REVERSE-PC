# PRISMA 1.2 · Ether Render X y RXE gráfico

PRISMA convierte archivos de audio locales en una pista de cubos para cortar.
Se ejecuta en horizontal, a pantalla completa, con mouse, teclado y varios
punteros táctiles. Flow admite también toques. La calidad automática limita
los píxeles y adapta la resolución a la cadencia observada.

## Usar

La ruta nativa de X Render requiere **REVERSE 2.5.3 PRISMA X Render**.
REVERSE 2.5.1 conserva sus RXE1/RXE2 y rechaza el perfil RXE3 desconocido.
La existencia previa de la familia gráfica no hacía que el cargador RXE2 de
conversación pudiera abrir cualquier aplicación interactiva.

En Programas, abre **PRISMA** y pulsa **Jugar a pantalla completa**. El adaptador
incluye la app de fábrica y actualiza únicamente el binario oficial 1.1 identificado
por su SHA-256. Conserva ejecutables personalizados y aplicaciones eliminadas.
También permite importar/exportar `PRISMA.rxe`.
La demo musical es original. La música propia se selecciona con el proveedor de
archivos Android, se decodifica localmente y no se envía a servidores.

## Familia gráfica utilizada y límites

Android utiliza el **observador espacial nativo de Ether Render X**, de
`mundo-X` `e2778d962af22f6f1a0794058dd4685fc2573966`. La extensión verificada
`scripts/xrender_extension.py` añade cubos orientados, materiales para sus
bordes/flechas y centro de proyección desplazable. Conserva su planificación
por regiones, candidatos conservadores, orden por profundidad y observación
dispersa. No añade otro planificador ni sustituye el núcleo MIL/Ether.

El radio de cada cubo es su esfera envolvente conservadora. El observador
resuelve intersecciones exactas de rayos con cajas orientadas y calcula el
color solo dentro de sus huellas. JNI entrega esos colores a una textura
GLES 3: la GPU compone el fondo y presenta la textura, sin rasterizar cubos.
El archivo `src/prisma_xrender.hpp` une los descriptores de la escena con ese
observador. `XRenderSurface` mantiene una única ranura de cuadro reemplazable;
una escena nueva descarta la pendiente, evitando acumular cuadros atrasados.
La resolución CPU se adapta a su tiempo observado; los controles/tacto y XI
no esperan a que termine el render. La textura de pantalla sí tiene tamaño
proporcional a sus píxeles; la observación dispersa no elimina ese coste.

WebView conserva controles, audio local, efectos y selector de archivos sobre
la superficie nativa. El motor no se ejecuta dentro de JavaScript. El navegador
independiente conserva WebGL 2 basado en Graphics/COSMIC y, si falta, Canvas.
Esas rutas de navegador no se presentan como Ether Render X. La calidad no
fuerza 4K/8K; cualquier mejora de FPS requiere medir la presentación completa
en el mismo dispositivo. No hay afirmación de aceleración cuántica física.

`apps/prisma/game.xi` contiene las reglas de puntuación, combo, máximo, aciertos
y fallos. Son 169 instrucciones compiladas a RXE1. Cada evento entra una vez al
QuantumRuntime existente. Java solo entrega dos enteros en el buzón del perfil,
guarda el RVPC2 por identidad del ejecutable y publica el resultado después de
la escritura. Los eventos se procesan fuera del hilo de animación. La UI puede
mostrar provisionalmente el cálculo local, pero el resultado final espera todas
las confirmaciones XI. No cambia InfiniteCore, Ether, la ISA ni RXE1/RXE2.

El host gráfico es híbrido: UI/audio HTML/CSS/JS dentro del ejecutable,
observación geométrica en Ether Render X C++, presentación GLES y reglas
persistentes en XI. El programa transmite solo descriptores acotados de cubos,
sin acceso a punteros nativos ni al estado del escritorio.

## RXE3, perfil XI-graphics-v1

Enteros little-endian. Cabecera de 80 bytes.

| Offset | Tipo | Contenido |
| --- | --- | --- |
| 0 | 8 bytes | RXE3 + CR LF 1A LF |
| 8, 10 | 2 × u16 | Formato 3, ABI 3 |
| 12, 16 | 2 × u32 | Cabecera 80, longitud total exacta |
| 20–36 | 5 × u32 | Bytes id, título, versión, código RXE1, semilla RVPC2 |
| 40 | u64 | FNV-1a64 del archivo excluyendo este campo |
| 48 | u32 | Activos: 1–64 |
| 52, 56, 60 | 3 × u32 | SHA de origen: 40 bytes; perfil: 1; campos de evento: 2 |
| 64, 72 | 2 × u64 | Reservado: cero |

Siguen id, título, versión, SHA, código RXE1 y semilla RVPC2. Después, cada
activo incluye longitud de ruta u16, reservado u16 cero, longitud u32, ruta y
bytes. `index.html` es obligatorio. Límite total 8 MiB y por activo 2 MiB.
Rutas duplicadas, absolutas, vacías, traversal, versiones y campos desconocidos,
checksum inválido y bytecode/semillas no válidos se rechazan. FNV detecta
corrupción; no autentica al publicador.

El buzón empieza en `7500000000000000000`. Dos bytes transportan el evento
(0 reiniciar, 1 corte, 2 fallo, 3 consultar) y calidad (0–150, cero salvo corte).
Los cinco contadores u32 residen desde `base+128`, sin compartir el RVPC2 del
escritorio o de BBY Q. La salida del programa debe contener exactamente r0–r4
con valores u32 válidos. Un error no sustituye el estado persistente.

Cada imagen tiene un origen HTTPS local distinto y memoria propia por SHA-256.
El adaptador no permite navegación, conexiones de red, marcos externos, acceso
a `file://`, puentes del escritorio o sistema de archivos arbitrario. Solo sirve
los activos validados del ejecutable. La selección de música requiere la acción
del usuario. La cola admite hasta 64 eventos pendientes.

## Construir y comprobar

```sh
node scripts/build-prisma.mjs build/reverse_pc build/prisma SOURCE_SHA
python3 tests/rxe_graphics_cli.py build/reverse_pc build/prisma/PRISMA.rxe
python3 tests/rxe_cli.py build/reverse_pc
python3 tests/rxe_app_cli.py build/reverse_pc
```

El constructor conserva salidas previas y produce `PRISMA.rxe` y un manifiesto
con SHA-256 de la imagen y de cada activo. El CLI también ofrece `pack-graphics`
y `graphics-event`; `-` selecciona expresamente la semilla inmutable.

Las pruebas comparan 112 eventos contra un modelo independiente, reinician el
proceso por evento, comprueban 16 imágenes inválidas, argumentos inválidos,
rollback, memoria existente e invariancia de los perfiles anteriores. CI compila
ARM64/x86_64 y usa el modo `graphics` de la instrumentación Android para comprobar
carga local, superficies reales de Ether Render X, ausencia de cubos WebGL,
orientación, inicio/pausa/continuación táctil, confirmación XI y aislamiento.
`tests/prisma_xrender.cpp` compara ID y profundidad con un oráculo independiente
de 12 triángulos por cubo, comprueba regiones/RGBA, huellas dispersas, cámara
interior y campos inválidos. Las pruebas originales de esferas y surface buffer
se ejecutan con la extensión para detectar regresiones. El emulador y los
tiempos CPU del host no equivalen a FPS/latencia en el teléfono físico.
