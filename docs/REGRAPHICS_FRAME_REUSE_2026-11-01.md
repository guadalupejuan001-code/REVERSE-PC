# REgraphics XI — optimización de fotogramas congelados

## Problema observado
El smoke test de Reverse Velocity 1.1 ejecutaba el renderizador completo a 3840×2160 incluso con la carrera pausada. La GPU no se usaba; los ciclos eran de XI/REgraphics y de copias de 8.294.400 índices a Bitmap.

## Implementación
- VelocityFrameReuse conserva identidad del último estado XI inmutable, cámara, pintura, calidad y modo 4K realmente publicados.
- En pausa, si nada cambió, se mantiene la última imagen de SurfaceView: no se vuelve a rasterizar, convertir, subir ni dibujar.
- El HUD y la telemetría mantienen su propio refresco; los registros FRAME_STATS muestran cacheHits y xiRenders por ventana de tiempo.
- Reinicio, nuevo estado XI, cámara, pintura, calidad, cambio 4K, recreación o redimensión de superficie invalidan la reutilización.
- Un fotograma calculado durante un cambio de cámara o perfil se descarta antes de presentarlo.
- La simulación activa no utiliza la caché; REgraphics sigue siendo el único autor de geometría y píxeles.

## Interfaz corregida
La cuenta regresiva utiliza una vista central independiente. El número de 64 puntos ya no se recorta en la banda de 26 dp. El aviso de cambio de marcha inválido permanece visible 1600 ms. Durante la pausa, las métricas indican PAUSA en lugar de confundir el último FPS con la velocidad de render.

## Pruebas
VelocityFrameReuseTest verifica cien reutilizaciones de 4K y todas las invalidaciones. La prueba Android valida cacheHits >= 3 y xiRenders <= 2 durante pausa 4K, y que al reanudar vuelven a calcularse escenas desde XI.

## Lo que no afirma esta mejora
La optimización elimina trabajo repetido cuando el estado está congelado; no se anuncia mejora de FPS 4K mientras el coche se mueve sin benchmarks en el mismo hardware. La prioridad siguiente sigue siendo render incremental por regiones y optimización de material/fill rate.
