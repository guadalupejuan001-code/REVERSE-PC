# REgraphics — tres ciclos de cierre

Base verificada: XGamingLab REgraphics Final 3.6.1 (PR #233), ruta física `gpu_virtual_regraphics_final`. No cambiar la fuente canónica ni apilar parches C04-C07.

## C01 — Campo visual (geometry -> screen field)

- Contrato `VisualTile`: coordenadas, cobertura, RGBA premultiplicado, profundidad, firma temporal, resolución.
- Clasificar cada primitiva como `EXACT_GEOMETRY`, `SPLAT` o `RESOLVED_TILE`; nunca reducir geometría arbitraria cuando afecta silueta, profundidad o materiales.
- Bin por tiles; acumulación alpha y orden de profundidad definidos; pruebas de referencia para imágenes y diferencias de color.
- Mantener `COMPACT_EFFECTS_FIELD` en detección de effects mode, pass 2, FBO y composite. Guardar regresión de pantalla vacía.
- Gate: cero pérdidas de dibujo, RGBA correcto, error de imagen acotado y medición de coste CPU/GPU.

## C02 — Materialización mínima

- Cache de tiles con invalidación por movimiento, cámara, luces, textura y resolución.
- Lista de tiles dirty; framebuffer retained con `EGL_EXT_buffer_age` cuando esté disponible, y fallback completo cuando no.
- `eglSwapBuffersWithDamageKHR/EXT` solo con extensión válida, historial de daño suficiente y semántica de superficie confirmada.
- Evitar copiar/recomponer toda la imagen cuando no cambia; medir gpuSceneMs, gpuCompositeMs, uploadBytes, latencia y P95/P99.
- Separar ticks de estado del render físico. No equiparar 333 estados/segundo con 333 presentaciones/segundo.
- Gate: paridad visual contra full redraw, no ghosting ni frame negro en cambios de contexto, rendimiento medido en Mali.

## C03 — Integración para juegos

- API de materiales, mallas, texturas, instancias, transparencias, luces, animación y movimiento con fallback correcto.
- Integrar un escenario de juego real de prueba, además del benchmark procedural de 369B.
- Configuración simple: `Automática`, `Calidad`, `Rendimiento`; benchmarks avanzados separados.
- Comparar A/B en mismo dispositivo, escena, seed, resolución y pacing; capturar imágenes y métricas.
- Entregar APK firmado ARM64, fuente canónica completa y evidencias; mantener PR draft sin merge automático.

## Criterios de aceptación

1. Imagen real visible y colores correctos; tests de píxeles, capturas y render real.
2. La ruta de 369B es población lógica representada por 1,024 anclas, no 369B objetos independientes.
3. No degradar sin justificación la referencia C05/C07 y la prueba 3.6.1 de 182.67 FPS internos. FPS físicos limitados por 90 Hz.
4. Sin afirmar FPS, ahorro energético o compatibilidad con juegos hasta pruebas físicas.
5. Cada ciclo se implementa, se prueba y se documenta antes de pasar al siguiente.
