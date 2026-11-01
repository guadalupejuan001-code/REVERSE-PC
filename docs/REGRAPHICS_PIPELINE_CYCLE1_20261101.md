# REgraphics — ciclo 1: medición de etapas y observación XI directa

## Objetivo ejecutado

Eliminar trabajo redundante **posterior al rasterizado** sin modificar el cálculo de física, triángulos, texturas, z-buffer, cámara, paleta o el transporte XFB5. La arquitectura gráfica sigue siendo la máquina XI con Ether Spatial. Android únicamente presenta los píxeles.

## Antes: ejecución genérica con estado transaccional

1. Java construía el programa XI de cámara y pintura y clonaba un snapshot RVPC2.
2. JNI restauraba un Runtime XI, ejecutaba el programa gráfico y guardaba otra vez todo el estado.
3. JNI empaquetaba salida + estado en RXOS1 y devolvía un byte[] Java.
4. ResultPacket.parseBinary copiaba XFB5 a un segundo byte[] (~8,29 MB a 4K).
5. RegraphicsFrame.decodeNative4K copiaba el frame de nuevo (~8,29 MB).
6. RegraphicsFrame.present expandía índices a ARGB (33,18 MB), Bitmap.setPixels cargaba otro búfer y Android dibujaba la imagen.

## Ahora: ejecución XI de solo lectura

- NativeRuntime.observeFrame(snapshot, programa) restaura el mismo Runtime XI y ejecuta **exactamente el mismo programa**. El estado resultante se descarta; no se serializa en RVPC2 ni se publica un paquete RXOS1 de salida.
- JNI copia el std::string binario XI directamente al byte[] Java. Rechaza la salida que no tenga encabezado XFS1/XFB5.
- RegraphicsFrame.decodeOwned / decodeNative4KOwned aceptan **propiedad exclusiva** de ese nuevo buffer JNI, verifican formato/dimensiones y evitan copiarlo otra vez. La API histórica decode/decodeNative4K conserva su copia defensiva para entradas no confiables.
- ResultPacket y NativeRuntime.execute conservan su contrato sin modificaciones; la física XI sigue guardando su estado transaccional.
- RegraphicsFrame.present todavía expande los 8,29 millones de índices y Bitmap.setPixels todavía copia valores ARGB. No es una ruta de GPU propia ni un pipeline cero-copias.

### Contabilidad de memoria por fotograma 4K

- Bytes de píxeles XI: **8.294.416**, sin cambios.
- Copias de arreglo Java evitadas: **dos copias de 8.294.416 bytes por fotograma** (~16,59 MB de tráfico de copia) con respecto a parseBinary + decodeNative4K.
- Ahorro de datos de transporte RXOS1+RVPC2: medido en el test de 12 escenas, **129.640 bytes agregados**, sin contar copias temporales y serialización de RVPC2 en C++.
- Los buffers ARGB y Bitmap siguen requiriendo ~33,18 MB cada uno. El consumo máximo real depende también del recolector, del allocator y del driver.

## Instrumentación FRAME_PIPELINE

Se registran etapas de un fotograma **realmente presentado**, separando resolución normal y 4K:

| Campo | Intervalo medido |
|---|---|
| xiP50Ms / xiP95Ms | Restauración nativa, ejecución XI y recepción de píxeles JNI |
| verifyP50Ms | Validación XFS1/XFB5 y transferencia de propiedad en Java |
| expandP50Ms | Conversión de índices XFB5/XFS1 a arreglo de píxeles ARGB |
| bitmapP50Ms | Bitmap.setPixels |
| presentP50Ms | SurfaceHolder lockCanvas/draw/unlockCanvasAndPost |
| totalP50Ms / totalP95Ms | Tiempo total del bucle gráfico para fotogramas presentados |
| samples | Cantidad de observaciones de esa resolución en la ventana |
| payloadBytes | Longitud binaria de la última imagen XI |

El muestreo no asigna estructuras por fotograma (anillos de 96 muestras); percentiles se ordenan una vez al informar. Las ventanas se reinician después del log. No representan tiempos de GPU, y un valor de etapa no debe confundirse con los FPS del panel.

**Inspección Android:** adb logcat -s ReverseVelocity:I | grep FRAME_PIPELINE. La APK y su prueba automática conservan los marcadores FRAME_STATS existentes.

## Pruebas ejecutadas (GitHub REgraphics CI)

- NativeXiDirectFrameTest: **12 escenas reales**, 3 cámaras, 2 pinturas, perfil XFS1 y 4K XFB5, comparadas byte a byte contra el Runtime.execute/RXOS1 original.
- Resultado: **77 comprobaciones**, mismo hash SHA-256 para ambas rutas, mismo snapshot Ether y física operativa después de cada observación.
- Contrato: salida binaria no gráfica rechazada; XFB5 exacto de 8.294.416 bytes.
- VelocityFrameProfilerTest: **11 comprobaciones** de p50/p95, anillos, datos de dos resoluciones y entradas inválidas.
- Suite original de XI MeshRaster: 4.196 comprobaciones; escena 4K y Ether Spatial conservan su hash y sus pruebas.

El workflow de Android ejecutará además una comprobación de registros FRAME_PIPELINE para ambas resoluciones. No se anuncian incrementos de FPS en un Galaxy A16 ni 120 FPS 4K sin medir.

## Siguiente ciclo: render incremental

Dependerá de un planificador de regiones cuya invalidación tenga en cuenta cámara, profundidad y sombra. Cuando toda la cámara se mueve, **no** es válido reutilizar indiscriminadamente la imagen anterior. El siguiente ciclo debe comparar cada bloque reconstruido contra un render completo y exigir cero diferencias en sus escenas de referencia.
