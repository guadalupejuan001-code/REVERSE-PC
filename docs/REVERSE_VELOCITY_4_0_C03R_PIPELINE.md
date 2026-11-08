# REVERSE VELOCITY C03R — corrección de la ruta de fotogramas

Base de esta reparación: C03, PR #224, commit
`cb7903bd596f1f0c382d3ba880e47086dfc37014`.

APK de referencia: `REVERSE-VELOCITY-4.0-C03-QSSD-GPU.apk`, versión 45,
SHA-256 `b6ddfce4f966e60b69b3113fc09bef92a5d2bce5604a80a2d2ae1d747bb6fde2`,
ejecución Android [42460861055](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/42460861055).

## Problemas comprobados

La C03 ejecuta XI/Ether, REgraphics, la autoridad de estado qSSD y C12. El
alcance de cada componente es distinto. C12 calcula cinco uniformes de
materiales con su intérprete original; las geometrías proceden de XI y la
rasterización final sigue realizándose mediante GLES. La presencia de las
dependencias o una primera traza de ejecución no demuestra una integración
completa de todas las capacidades de los repositorios.

La prueba Android anterior comparaba C03 con 3.9 y registraba una mediana de
7,4970 frente a 6,6224 FPS, una diferencia de −11,67 %. Aun así terminaba con
`passed: true`. Además de las conexiones, esa comparación incluye cambios de
conducción y shaders de C01/C02; por ello no permite atribuir la caída a C12 o
a qSSD por separado. La suite completa de REgraphics no se activaba para la
rama C03 y conservaba dependencias anteriores.

En el código se verificaron estos costes y defectos:

- Cada revisión geométrica reconstruía un atlas de 2.048 bytes antes de
  comprobar si había cambiado. Mover el coche no implica cambiar el atlas.
- Cada plan de subida asignaba un temporal de 512 enteros, incluso cuando la
  paleta no cambiaba.
- La primera subida del atlas realizaba 16 llamadas, una por fila.
- Un plan podía confirmarse después de perder el contexto GL, o después de
  que otra confirmación cambiara la base utilizada para calcular sus deltas.
- Los vértices preparados se marcaban como actuales antes de la aceptación
  del controlador; una transferencia interrumpida debía invalidarlos.
- El juego leía y calculaba el hash de todos los píxeles de cada perfil al
  usarlo por primera vez, aun en una sesión normal de juego.
- El adaptador C12 copiaba repetidamente un campo compacto todavía privado y
  creaba un nuevo arreglo Java de cinco valores por llamada.

## Cambios

`VelocityQssdGraphicsBridge` conserva el atlas tras comparar exactamente sus
bytes originales; solo lo reorganiza cuando cambia. Las paletas utilizan
rangos de cambio exactos, con memoria de trabajo reutilizable. Los planes
incluyen su propietario, la generación del contexto y la residencia contra
la que se calcularon. Los planes ajenos u obsoletos se rechazan, y los cambios
se comparan siempre con el último contenido aceptado por GLES.

El presentador agrupa filas contiguas del atlas en una misma transferencia.
Ante un error invalida tanto la residencia de qSSD como los vértices
preparados. La geometría y el estado de materiales proceden obligatoriamente
de la misma observación retenida. Los uniformes comunes se calculan una vez
para las tres variantes de shader.

C12 utiliza el setter original para construir su campo privado y rellena un
buffer Java de cinco valores propiedad del hilo GL. Sigue ejecutando el
programa C12 real. **No se ha hecho persistente `xgpu::Execution`:** la API
fijada no permite retirar o reiniciar trabajos de forma segura; conservarla
sin ese contrato agotaría el historial de despachos. Se mantienen los
contextos de ejecución aislados y acotados.

La verificación completa de píxeles se activa explícitamente con el extra
Android `velocity_verify_pixels=true` durante las pruebas funcionales. El
arranque normal y las mediciones de conducción no realizan esa lectura. Los
programas XI, shaders, atlas, cinco perfiles y resolución de cada perfil
conservan los bytes de C03; no se reduce calidad para obtener una medida.

## Ruta y límites de integración

La tabla describe la ruta GLES activa. Si el presentador falla, el respaldo
XI de software deja de ejecutar C12 y el puente de residencia GLES por frame.

| Componente | Trabajo ejecutado en esta APK |
| --- | --- |
| CPU XI/Ether | Mundo, física, estado, programas REgraphics y geometría XFG4. |
| qSSD nativo | Estado completo `XiSessionGraph`, recursos, revisiones, historial, checkpoints y proyección inmutable de geometría. |
| Puente qSSD de Android | Planificación y confirmación de residencia de geometría, paleta y atlas para GLES. |
| GPU-VIRTUAL C12 | Ejecución de los cinco valores de materiales; pruebas contra bits float32 independientes. |
| Transporte GPU-VIRTUAL | Vértices exactos de 24 bytes y páginas modificadas de XFG4. |
| GLES / GPU del dispositivo | Texturas, buffers y rasterización de los píxeles finales. |

La versión qSSD C06 queda fijada como dependencia, pero el juego utiliza su
ABI de estado/proyección C03. El adaptador de campos `C12Window` y los
protocolos Bell del laboratorio no pasan a ejecutarse por fotograma por
actualizar una referencia. Esta reparación no introduce esa afirmación ni
equipara una referencia compartida con transferencia cuántica física.

Cada revisión nueva de geometría todavía se copia íntegra a un buffer Java
en JNI. La lease nativa de qSSD no mantiene por sí sola la memoria viva para
todas las vistas Java retenidas: eliminar esa copia exige un contrato de
propiedad y liberación entre JNI y Java. Esta reparación no lo modifica ni
afirma haber medido aisladamente el coste de esa copia.

## Validación y entrega

- Pruebas JVM: atlas exacto, cambio aislado de cada texel, publicaciones
  saltadas, reversiones de paleta, planes ajenos, bases de residencia
  obsoletas, pérdida de contexto y transferencia interrumpida.
- C12: comparación bit a bit float32, enteros grandes hasta `INT_MAX`,
  entradas inválidas y llamadas concurrentes independientes.
- Suite completa: se activa para C03 con los mismos SHA de CPU/GPU/qSSD que
  la compilación Android; conserva las pruebas de física, estado, JNI y
  equivalencia de píxeles.
- Android: cinco perfiles con lectura real de píxeles, conducción, marcha
  atrás, efectos, continuidad de C12 y de las revisiones qSSD, pausa y
  recuperación tras cerrar el proceso.
- Actualización: instalar C03 y después C03R mediante `adb install -r`,
  comprobando paquete y firmante idénticos. La ausencia de la clave original
  detiene la compilación destinada a entrega.
- A/B: tres ensayos alternados por APK sobre el mismo emulador, 960×540 y
  conducción real de 24 segundos; referencia inmediata C03. Registra FPS de
  fotogramas presentados, tiempos P50/P95 por ventanas y PSS. Una regresión
  de FPS superior al 5 % o un aumento superior al 10 % en la mediana de P95
  de ventanas impide publicar la APK. Las diferencias dentro de esos márgenes
  se clasifican como inconclusas, no como mejoras demostradas.

Los percentiles agregados son medianas de percentiles de ventanas, no un
percentil calculado sobre todos los fotogramas originales. Los estados
evolucionan libremente: este A/B no es una reproducción de poses idénticas
ni demuestra significación estadística o rendimiento en el teléfono físico.

El artefacto instalable se publica al terminar los controles Android y la
comparación. La prueba JVM de transferencia interrumpida cubre una subida
sin confirmar y su invalidación; no inyecta fallos en un controlador GLES
real. La pausa Android conserva el contexto EGL: tampoco equivale a forzar
su destrucción durante la sesión.

## Resultado medido de C03R

Código compilado y probado: `8300f41c11e14872251d951e65ca7a927b9c2f1a`;
merge usado por CI: `e3f029d4ecba213e23c23714f0ac2ffe2438b33a`;
árbol exacto: `05fe2050fbaa3f824e6ffb6cf1e8e382485e3ea1`.
Este registro posterior solo añade documentación y evidencia.

Las tres ejecuciones de esa revisión terminaron correctamente:

- [APK y Android 35 — 42467454708](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/42467454708).
- [Suite nativa y REgraphics — 42467454678](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/42467454678).
- [Componentes C12/qSSD — 42467454653](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/42467454653).

Android completó 52 controles funcionales, lectura real de los cinco perfiles,
actividad continuada de C12/qSSD y siete controles de guardado/recuperación
tras cerrar el proceso. Se verificó la actualización real de versión 45 a 46
con el mismo paquete y firmante. La suite nativa confirmó 16 pares de píxeles
idénticos hasta 4K y el estado JNI con sus 20 recursos. Estos casos a 4K son
pruebas del transporte gráfico; los perfiles del juego siguen llegando a 1080p.

Tres ensayos alternados por versión, Medio 960×540, en el mismo emulador:

| Medida | C03 entregada | C03R |
| --- | ---: | ---: |
| Mediana de FPS presentados | 6,6639 | 6,7559 |
| Mediana de P95 por ventanas | 166,900 ms | 167,367 ms |
| PSS mediana después de conducir | 85.413 KiB | 83.433 KiB |
| Frecuencia mediana de física | 50 Hz | 50 Hz |

El cambio de FPS es **+1,38 %**, clasificado como
`inconclusive_within_tolerance`. La medida P95 aumenta **0,28 %**. Superar los
márgenes de no regresión no demuestra una mejora global de fluidez ni 30 FPS.
La PSS es una observación de estos ensayos y varía con el proceso y el GC.
No hay una medición de rendimiento, temperatura o estabilidad sostenida en
un teléfono ARM64 físico.

El microbenchmark CI del puente, separado del juego, confirma una reducción
de unas 4.248 a 128 bytes asignados por frame al mover vértices con atlas fijo.
En cambios de paleta y atlas también se asignan menos bytes, aunque su tiempo
CPU local aumenta; no se generaliza la mejora temporal a todos los casos.

Archivo: `REVERSE-VELOCITY-4.0-C03R.apk`, 5.125.106 bytes,
versión `46 / 4.0.0-c03r-pipeline`, ARM64 y x86_64, Android 10 o posterior.
SHA-256: `3ba8da4fdec9c888071a6a527dafe363107718714a8555fe779fa73d97917e7a`.

Los resultados completos y sus identidades están en
[`docs/evidence/velocity-c03r-results.json`](evidence/velocity-c03r-results.json).
La PR #224 permanece sin fusionar.
