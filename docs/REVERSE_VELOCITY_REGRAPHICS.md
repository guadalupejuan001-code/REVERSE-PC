# Reverse Velocity con REgraphics — integración V1

Este documento conserva la prueba de integración V1. El desarrollo actual del
juego y su shader se describe en [Shader costero XI](REVERSE_VELOCITY_SHADER_V2.md).

Reverse Velocity ejecuta su escena XI por la salida binaria directa XFS1 de
REgraphics. Cada región llega al presentador sin convertirse en texto UTF-8,
JSON ni enteros RGB empaquetados de 56 bits. La conducción, el circuito y la
selección de materiales siguen ejecutándose en XI sobre el estado RVPC2 privado.

Se parte del render refinado `c35b41276b252f02ce05682cd9858ed99f4881cc`
(PR #89) y se porta la escena XI de Velocity
`8ad61d5772507b7843d490c0979fef31fa5aabba` (PR #74).
REgraphics es el título de la implementación; se conservan los símbolos internos.
Esta rama no incorpora las actualizaciones independientes de BBY Q o Laplace.

## Conexión implementada

- `drive.xi` conserva las reglas de conducción; `world.xi` conserva sus 241
  muestras en InverseMemory para que el render observe el mismo circuito.
- `render.xi` usa `framebegin`, `framespan` y `frameend`, la familia de
  instrucciones de la versión refinada. Se mantiene su ejecución de fuente
  mediante la API genérica; no se afirma compilación RXE del render.
- `palette.txt` contiene los 217 colores originales. XI calcula el índice por
  fila mediante el recuento de transiciones de los canales, conservando
  exactamente las gradaciones y pinturas anteriores.
- La instrucción genérica `framespan` acepta el campo de material u8 completo
  (0–255); cada presentador comprueba su propia paleta.
- JNI y RXOS1 ya transportaban bytes intactos. `ResultPacket.parseBinary`
  conserva esos bytes y evita la conversión a UTF-8. La API textual conserva su
  comportamiento anterior.
- `RegraphicsFrame` valida la trama completa antes de tocar la imagen:
  dimensiones, presupuesto, materiales, cobertura de filas, orden de profundidad,
  revisiones y final de trama. Materializa intervalos XFS1 inclusivos.
- `VelocityXSurface` presenta esa observación con Canvas. El render no publica
  un nuevo estado del juego ni modifica la siguiente transacción de conducción.

La referencia RGB anterior solo existe en `tests/fixtures` como oráculo de
regresión. La aplicación carga exclusivamente el nuevo `velocity/render.xi`.

## Evidencia ejecutada

Las 51 comparaciones de la VM real conservaron exactamente regiones, RGB y
píxeles. Incluyen tres calidades, tres cámaras, cinco pinturas, giro y posiciones
fuera de carretera. La continuidad del centro de la carretera conserva
608 → 616 → 623; con giro, 627. El estado de entrada permanece intacto.

Las 45 escenas adicionales del puente JNI de producción pasaron en JVM Linux,
incluyendo determinismo, bytes binarios, paleta, presentación y equivalencia de
la siguiente transacción de conducción. También pasaron las regresiones Java
de paquetes y límites del presentador, los 48 casos del contrato de conducción
y la regresión binaria general a tres resoluciones. Materiales -1 y 256 fallan
sin publicar trama ni estado; 0 y 255 se conservan exactamente.

En la escena inicial con cámara 0 y pintura 0:

| Muestreo vertical | Salida anterior | XFS1 | Reducción |
| --- | ---: | ---: | ---: |
| 4 | 43.214 bytes | 9.796 bytes | 77,3 % |
| 2 | 86.495 bytes | 19.582 bytes | 77,4 % |
| 1, 720p completo | 173.181 bytes | 39.182 bytes | 77,4 % |

Las mediciones Linux completas están en
`docs/evidence/velocity-regraphics.json`; las del puente, en
`docs/evidence/velocity-regraphics-jni.json`. Los tiempos de proceso incluyen
arranque, restauración y guardado; las medianas usan tres muestras y las fases
de decodificación/materialización se miden por separado. No representan FPS
en Android. El host usa Mundo X fijado en
`e2778d962af22f6f1a0794058dd4685fc2573966`.

## Validación pendiente

No se ha compilado una APK nueva ni probado la pantalla en Android. El workflow
de esta rama reproduce los contratos y el recorrido JNI en Linux; los workflows
Android conservan su propia dependencia fijada y necesitan su validación de
compilación e interfaz. Las cámaras 0 y 1 todavía comparten la misma perspectiva,
como en la escena XI de origen; la cámara 2 oculta el vehículo.
