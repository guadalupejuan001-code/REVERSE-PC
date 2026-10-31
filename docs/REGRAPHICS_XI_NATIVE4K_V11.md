# REgraphics 1.1 — rasterización 4K nativa de XI

## Cambio de arquitectura real

El nuevo perfil `meshbegin ... 5` **produce píxeles completos**. No entrega triángulos a OpenGL, Vulkan ni otro rasterizador. El mismo lenguaje XI calcula la cámara, la iluminación, la textura y la geometría, mientras que `MachineMeshRaster` aplica su rasterización, clipping, cobertura top-left y profundidad perspectiva.

`render-native4k.xi` se genera determinísticamente desde la escena original `render4k.xi` cambiando solo el modo de salida de XFG4 (captura de geometría) a **XFB5 (píxeles nativos)**.

El paquete `XFB5` lleva 16 bytes de cabecera y una muestra indexada por píxel en orden de filas. Para 3840 × 2160: **8.294.416 bytes**, incluidos los 8.294.400 píxeles. Android valida el paquete y muestra exactamente el `Bitmap` calculado; el escalado a la superficie del teléfono no se presenta como aumento de resolución interna.

## Capacidades ampliadas

| Componente | Perfil anterior | Perfil nativo v5 |
| --- | ---: | ---: |
| Resolución rasterizada | 640 × 360 | 3840 × 2160 |
| Triángulos admitidos | 4.096 | 32.768 |
| IDs de vértice | 4.096 | 16.384 |
| Texturas indexadas de 16 × 16 | 8 | 16 |
| Z-buffer | Completo, 64 bits por píxel | Franjas independientes de 32 filas |
| Trabajo de píxeles | 8 millones fijos | Escala con la resolución, con límite defensivo |
| Transporte visual | XFS1, intervalos | XFB5, píxeles exactos |

Los presupuestos son configurables y siguen siendo finitos para proteger la memoria y el tiempo de cálculo. La aplicación mantiene 640 × 360 y resoluciones menores como perfil normal, con el modo 4K XI **experimental y opcional**.

## Algoritmo de franjas

1. XI proyecta y define una lista temporal de triángulos con coordenadas, iluminación y textura.
2. Un índice espacial conservador asigna cada cara a las franjas de 32 filas que podrían cubrirla.
3. Para cada franja, REgraphics reserva únicamente material y profundidad para esas filas.
4. El **mismo rasterizador existente** ejecuta z-test, interpolación perspectiva, texelado y reglas de desempate; no hay una segunda implementación incompatible.
5. Cada franja se incorpora a XFB5 y los buffers de profundidad se reutilizan.

No se asigna un z-buffer de 64 bits para los 8,3 millones de píxeles completos. Tampoco se escribe estado persistente Ether desde un render de observación.

## Evidencia medible

- Prueba directa XI nativa con UBSan: 3840 × 2160, 8.294.400 píxeles, igualdad bit a bit frente al perfil v2 en una escena de referencia a 640 × 360, y prueba de frontera de franja Y=31/32.
- Prueba de la **escena real del juego**: 124 colores/materiales indexados visibles, XFB5 reproducible y snapshot Ether intacto.
- SHA-256 de la imagen de prueba inicial: `51cf7f1e346877bf8eb1f6efc1a05a41ea09cedb1bbeb37f6e8b2c41434e3fe5`.
- Tiempo local de raster completo en host: ~0,31 segundos por fotograma; RSS máximo del proceso: ~16 MB. **No es una medición Android ni garantiza FPS sostenidos.**

Las pruebas tradicionales de XI (malla 2D/3D, texturas, XFG4 legado, carrera, cámaras y Java) siguen ejecutándose.

## Límites que permanecen y por qué

**8K UHD** son 33.177.600 píxeles. A un byte por píxel requeriría ~33,2 MB de salida en un solo fotograma, superior a los 16 MiB de transporte XI/RXOS1. Aumentar solamente la cota no resolvería las copias de memoria ni la latencia Android. Es necesario crear un **XFT6** por bloques con verificación, transporte incremental y reconstructor de superficies, sin duplicar todo el fotograma.

La paleta continúa siendo de 256 colores. La calidad visual está limitada por texturas de 16 × 16, polígonos de árboles/coches y técnicas de sombreado. El 4K aumenta la precisión espacial, pero no convierte por sí mismo los materiales en PBR, ni genera normal maps o iluminación global.

**Prioridades técnicas siguientes:** binning 2D 64×64, raster paralelo determinista, perfiles p50/p95 por etapa, XFT6 por bloques para 8K, y materiales XI HDR/normal/specular con formato de salida de mayor precisión. Acceder directamente a una GPU Android sin OpenGL/Vulkan necesitaría una ruta de hardware y controlador propia; no existe por simple cambio de nombre.

El 4K de la versión 1.1 es nativo, software y verificable. El objetivo de 60/120 FPS en dispositivos reales sigue pendiente de medición y optimización.
