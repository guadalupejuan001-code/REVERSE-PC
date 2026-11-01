# REVERSE Velocity 1.0 — renderizado exclusivo REgraphics XI

## Contrato de arquitectura (vigente)

**XI es la autoridad visual.** `world.xi` define el circuito, `drive.xi` calcula física y posiciones y `render.xi` calcula mallas, cámara, iluminación y materiales. El runtime `MachineMeshRaster` implementa rasterización por triángulos con clipping, test top-left, z-buffer por profundidad inversa, interpolación con perspectiva y textura XI de 8 tiles de 16×16. El resultado se codifica en **XFS1**.

El bucle gráfico Android solo valida XFS1, expande sus intervalos en un `Bitmap` y solicita a `SurfaceView/Canvas` que lo muestre. Android es el adaptador de pantalla y tacto, **no la fuente de triángulos, iluminación, físicas, materiales ni píxeles**. El producto no crea un contexto EGL, ni compila GLSL ni llama a OpenGL ES para renderizar el juego.

Por compatibilidad histórica, `render4k.xi` permanece como captura geométrica XFG4 generada en XI. **No es una salida de píxeles 4K**. Se conserva para diseñar el siguiente rasterizador propio. La antigua implementación Android GLES3 está disponible en el historial Git, pero no forma parte de la nueva APK.

## Límites medidos en código (sin inventar FPS)

| Recurso | Cota actual | Sitio |
| --- | --- | --- |
| Raster nativo | 640×360 máximo | `src/integration/xi_mesh_raster.inc`, `max_width/height` |
| Trabajo por imagen | 8.000.000 muestras de bounding-box | `max_pixel_tests` |
| Salida de XI | 16 MiB por transacción | `src/integration/xi_machine_extension.inc` / `ResultPacket.java` |
| Geometría | 4.096 triángulos, 4.096 IDs de vértices | `MachineMeshRaster` |
| Texturas | 8 patrones XI de 16×16, 4 bits | `MachineMeshRaster` |
| Color | 256 colores indexados con ramps de iluminación | `palette.txt`, XFS1 |

**4K exacto** necesita 3840×2160=8.294.400 píxeles finales, 36 veces el número de píxeles de 640×360. Solo el material de cada píxel requiere unos 8,3 MB; almacenar profundidad de 64 bits suma aproximadamente 66,4 MB, sin contar geometría, snapshots de Ether, buffers Android ni memoria del driver.

No basta con cambiar `max_width`: el límite de trabajo se agotaría durante la rasterización y el paquete XFS1 podría superar su límite de 16 MiB en una imagen con muchos cambios de materiales. Elevar límites de golpe causaría latencia extrema o cierres.

## Camino de ingeniería 4K sin OpenGL/Vulkan

1. **REgraphics Tile Raster XI**: una única implementación dentro de `MachineMeshRaster`, no un segundo motor. Bin de triángulos por bloques 32×32 o 64×64, rechazo de regiones vacías y frustum/occlusion antes del bucle de píxeles.
2. **Z-buffer compacto**: profundidad fija de 24/32 bits con política explícita de empate y prueba de exactitud frente a la implementación de 64 bits. Conservar clipping determinista y cálculos XI de normales.
3. **Materiales propios**: mover los materiales avanzados del antiguo GLSL a fórmulas XI / shaders software de REgraphics; usar tablas y LUT de reflejo, ruido espacial estable y texturas jerárquicas en coordenadas de escena.
4. **Presentación incremental**: sustituir XFS1 de intervalos de pantalla entera por paquetes de tiles (nuevo tipo/versionado) con máximo definido, verificación binaria y reciclaje de buffers, sin copias innecesarias del fotograma completo.
5. **Presupuesto de tiempo real**: mantener física XI a 50 Hz aislada del render, frame pacing adaptativo y medición de p50/p95 de procesamiento y presentación; no confundir precisión interna con resolución real.
6. **Validación sin aproximaciones**: probar exactamente 3840×2160 en la misma escena y sus 3 cámaras; comprobar z-buffer, colores, cobertura y ausencia de mutación del snapshot; medir sobre Galaxy A16 (u otro hardware elegido) y no anunciar 60/120 FPS hasta comprobarlos.

## Qué se necesita para abrir el camino

Para acelerar 4K a 60/120 Hz **sin usar APIs de gráficos externas**, habría que disponer de una vía propia de cálculo acelerado a hardware (controladores, compilador de kernels o interfaz directa compatible con el dispositivo), o demostrar un rasterizador software suficientemente rápido. El hardware Android no se vuelve directamente programable por evitar OpenGL: el desafío pasa a ser la implementación y el acceso a GPU/dispositivo.

La vía ejecutable hoy es REgraphics XI software, con salida nativa hasta 640×360. Cualquier resolución mostrada mayor por Android es presentación ampliada, **no render 4K**.

## Criterios para integrar un nuevo 4K

- Cero llamadas EGL/GLES/Vulkan en la ruta jugable.
- Malla/materials/iluminación autorados por XI.
- Mapa del circuito, cambio de marcha, luces y estado físico idénticos en REgraphics low y high.
- Resultado binario reproducible y lectura de transportes en Android con límites explícitos.
- Capturas y tiempos reales de Android, con hardware, resolución interna, temperatura y versión registrados.
