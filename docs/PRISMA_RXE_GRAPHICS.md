# PRISMA 1.1 · RXE gráfico

PRISMA convierte archivos de audio locales en una pista de cubos para cortar.
Se ejecuta en horizontal, a pantalla completa, con mouse, teclado y varios
punteros táctiles. Flow admite también toques. La calidad automática limita
los píxeles y adapta la resolución a la cadencia observada.

## Usar

Esta extensión requiere el cargador gráfico de **REVERSE 2.5.2 PRISMA**.
REVERSE 2.5.1 conserva sus RXE1/RXE2 y rechaza el perfil RXE3 desconocido.
La existencia previa de la familia gráfica no hacía que el cargador RXE2 de
conversación pudiera abrir cualquier aplicación interactiva.

En Programas, abre **PRISMA** y pulsa **Jugar a pantalla completa**. El adaptador
incluye la app de fábrica sin reemplazar un archivo existente ni reinstalar uno
que el usuario haya eliminado. También permite importar/exportar `PRISMA.rxe`.
La demo musical es original. La música propia se selecciona con el proveedor de
archivos Android, se decodifica localmente y no se envía a servidores.

## Familia gráfica utilizada y límites

El diseño de malla indexada —24 vértices, 36 índices y envío por instancias—
procede de `mundo-X/app/src/main/java/com/mundox/lab/ObjectSceneRenderer.java`,
revisión local auditada `c375159fdb17e202e452af7bd0299b16a3ec6fff` de la familia
Graphics/COSMIC. `gpu-scene.js` porta ese diseño a WebGL 2, la interfaz de
navegador de GLES 3. El conjunto visible de cubos se envía en una sola llamada.
No se ejecutan QuantumRenderer ni el motor Ether Render X dentro de JavaScript;
no se afirma una conexión al estado cuántico ni un motor cuántico nuevo.

Android/WebView proporciona la GPU, audio, selector de archivos y eventos.
Si WebGL 2 no está disponible, Canvas conserva una ruta con resolución acotada.
La preferencia de ahorro reduce detalle. La calidad automática no fuerza 4K/8K:
resolución de salida y coste de rasterización son medidas diferentes.

`apps/prisma/game.xi` contiene las reglas de puntuación, combo, máximo, aciertos
y fallos. Son 169 instrucciones compiladas a RXE1. Cada evento entra una vez al
QuantumRuntime existente. Java solo entrega dos enteros en el buzón del perfil,
guarda el RVPC2 por identidad del ejecutable y publica el resultado después de
la escritura. Los eventos se procesan fuera del hilo de animación. La UI puede
mostrar provisionalmente el cálculo local, pero el resultado final espera todas
las confirmaciones XI. No cambia InfiniteCore, Ether, la ISA ni RXE1/RXE2.

El host gráfico es híbrido: los activos HTML/CSS/JS de presentación están dentro
del ejecutable; las reglas persistentes se ejecutan en XI. No es una traducción
de toda la presentación a XI ni una aplicación Windows ejecutada por REVERSE.

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
carga local, WebGL 2, orientación, confirmación XI y aislamiento del escritorio.
La compilación/validación de GLSL en Mesa y el emulador no equivalen a una medida
de FPS o latencia en el teléfono físico del usuario.
