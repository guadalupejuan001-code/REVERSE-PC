# REgraphics XI + Ether Spatial: núcleo integrado (2026-11-01)

## Elección de núcleo

El algoritmo más útil inmediatamente para Reverse Velocity es la **planificación espacial conservadora** de EtherRenderSpatial, aplicada dentro del rasterizador MachineMeshRaster de XI. No se reemplaza el rasterizador de triángulos, el z-buffer ni la iluminación de REgraphics por un raytracer distinto; eso perdería atributos, texturas y compatibilidad. La ruta Android sigue sin OpenGL/Vulkan.

Fuentes de diseño:
- Mundo X: native/include/mundo_x/ether_render_spatial.hpp (candidatos espaciales)
- Mundo X: native/include/mundo_x/ether_surface_buffer.hpp (salida dispersa)
- REVERSE-PC: src/integration/xi_mesh_raster.inc (geometría, color y profundidad)
- REVERSE-PC: experiments/xi-render/SUPER_RENDER_XI.md (representación por regiones)

## Integración concreta

La salida 4K, revisión 5, sigue procesando franjas de 32 filas y **un solo rasterizador XI**. Para caras con cajas grandes de pantalla, determina qué columnas de 32 píxeles pueden contener píxeles visibles:

1. Calcula, para cada lado orientado del triángulo, la función de borde exacta.
2. Evalúa el máximo de esa función en las cuatro esquinas de los centros de píxel de una subregión.
3. Rechaza la subregión únicamente si un lado la excluye por completo. Es una cota conservadora: puede conservar regiones vacías, pero nunca omite una con un píxel cubierto, incluidos empates top-left.
4. Avanza los valores afines a lo largo de toda la región rechazada, sin evaluar píxel por píxel.
5. Las regiones candidatas siguen usando el mismo z-buffer, test de profundidad recíproca, perspectiva, UV y materiales originales.

Se evita planificar para caras pequeñas: costaría más calcular candidatos que rasterizarlas directamente.

La bandera REGRAPHICS_DISABLE_SPATIAL_CANDIDATES desactiva solo el descarte para pruebas A/B; no crea un segundo motor. La compilación normal lo lleva activado.

## Validación ejecutada

- 4.196 comprobaciones originales de XI MeshRaster.
- Pruebas UBSan con referencia y nueva versión en un ejecutable; comparan cada byte en 8x8, 320x180, 640x360, 1536x864 y 3840x2160, con cámaras proyectadas, orden inverso, materiales, iluminación y texturas.
- Escena 4K diagonal: pruebas de píxel del bounding-box de **98.054.400 a 2.547.584**, con idénticos los 8.294.400 píxeles. El cociente es trabajo evitado, NO FPS.
- A/B real de Reverse Velocity (mismo estado Ether y escena XI, ejecución completa en host GitHub):

| Cámara | Referencia ms | Ether Spatial ms | Resultado |
|---|---:|---:|---|
| trasera | 289,384 | 266,094 | píxeles idénticos |
| cercana | 296,589 | 281,807 | píxeles idénticos |
| capó | 334,867 | 308,249 | píxeles idénticos |

El script scripts/velocity-spatial-ab.cjs reproduce este contrato y deja un reporte JSON en CI. Los tiempos son del host, no de Galaxy A16 ni de Android.

Ensayos locales de región de 16, 32 y 64: **32** obtuvo el menor tiempo mediano conjunto de las tres cámaras. No significa que sea el mejor tamaño para cualquier escena.

## Límites y siguientes decisiones

El núcleo genera píxeles 4K con paleta de 256 materiales y salida máxima XI de 16 MiB. PBR, espejos, rayos de esferas, 8K incremental, HDR, paralelismo y aceleración física siguen siendo capacidades separadas, no integradas por esta optimización.

No retirar Ether Render X, Solar, COSMIC ni Super Render XI hasta verificar paridad y costes en el mismo dispositivo. La meta es combinar algoritmos compatibles dentro de un solo núcleo, sin copiar backends gráficos incompatibles.
