# REgraphics — prueba destructiva de fidelidad

**Objeto:** detectar escenas donde la compresión 3D -> VisualTile deja de ser equivalente al render de referencia. No se modifica el renderer ni se compila APK.

El test **utiliza el VisualTile builder real** de REgraphics C03 en la fuente canónica del artifact de CI `43142478902`. Rasteriza un caso de referencia con todas las entidades y otro con la salida compactada. La rasterización es un proxy software en 192 × 128, no una medición física de Mali ni una reproducción completa de OpenGL.

## Hallazgos reproducibles

| Escenario | Entidades físicas de origen | VisualTiles | MAE en región afectada | MAE del fotograma | Evidencia |
| --- | ---: | ---: | ---: | ---: | --- |
| Rojo delante de azul opaco, distinto depth | 2 | 1 | 0.230458 | 0.000911289 | pixel central rojo -> violeta |
| Dos transparencias superpuestas en profundidad | 2 | 1 | 0.183703 | 0.000726873 | composición alpha pierde orden |
| Dos figuras delgadas diferentes en misma celda | 2 | 1 | 0.304838 | 0.00120171 | cobertura 8 -> 96 píxeles |
| Punto pequeño con efecto a resolución 1/4 por eje | 1 | 1 | 0.289305 | 0.0185514 | cobertura 4 -> 1568 píxeles |

MAE = promedio absoluto de diferencias RGBA entre imágenes. La región afectada es la **unión de píxeles con alpha > 0.05**, para que el fondo vacío no oculte errores localizados.

El último caso prueba el desajuste dimensional que existe al enviar `size_px` de resolución de superficie al `visual_tile_vertex`, pero dibujar ese punto sobre `p.effect` con `effect_divisor=4`. El shader no ajusta `gl_PointSize` al tamaño del FBO. La simulación aproxima ese efecto multiplicando tamaño aparente ×4. Debe verificarse con capturas comparativas de GLES real.

## Causas en el código

`native/visual_field.hpp` guarda **una celda con promedio de RGB, promedio de depth, alpha óptico acumulado, tamaño máximo**. No almacena geometría interna, orden de los elementos, múltiples capas por celda ni cobertura exacta. Por tanto no puede reconstruir todas las escenas al invertir el campo.

`native/scene_renderer.cpp` usa el camino `COMPACT_EFFECTS_FIELD` en el effect FBO. `native/lab_shaders.hpp` asigna directamente `gl_PointSize = clamp(aEffect.w,1,96)` sin normalizar por el divisor del destino.

## Implicaciones

- El contador `369000000000` indica tamaño de la población **lógica procedural**, no número de meshes independientes dibujados.
- La prueba previa C01 reportaba MAE global 0.00101864. Un MAE global bajo **no basta** para preservar siluetas, color, oclusión ni geometría fina.
- La agrupación funciona mejor con muchos elementos visualmente parecidos. Es peligrosa con profundidad muy distinta, transparencia ordenada, texturas de alta frecuencia, cables/vegetación fina y movimiento en límites de tiles.
- Para una GPU Virtual de propósito general el pipeline necesita **clases de primitivas** y fallback exacto por celda, no asignación ciega de todas a VisualTile.

## Propuesta de solución (NO IMPLEMENTADA)

1. **Clasificador de riesgo por celda** antes de fusionar: diferencia de depth, desviación de RGB/alpha, dispersión espacial, tamaño proyectado y sensibilidad a silueta/identidad.
2. Celdas seguras -> VisualTile / agrupación. Celdas riesgosas -> mantener splats separados o pasar por geometría exacta.
3. Normalizar tamaño/derivadas al effect FBO cuando se reduce resolución.
4. Comparar referencia vs acelerado en imágenes: error en foreground, bordes, depth, motion y 1% low, además de FPS y ahorro de bytes.
5. Presupuesto adaptativo de error perceptual, con la posibilidad de **no** comprimir si no satisface umbral.

**No modificar la ruta rápida que alcanzó 182.67 FPS hasta probar el fallback y comparar A/B con el mismo hardware.**
