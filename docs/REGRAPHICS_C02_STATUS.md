# C02 — Materialización mínima (checkpoint de fuente, sin APK)

## Estado
C01 se reconstruyó y pasó gates en GitHub Actions como **fuente únicamente**:
- Run: https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/43136476049
- Artefacto: REgraphics-C01-Source-Only
- Los workflows heredados de APK fueron desactivados en esta rama para respetar la regla **no APK hasta C03**.

## C02 implementado y validado en fuente de trabajo
- `visual_damage.hpp`: caché de tiles con firma de escena, comparaciones RGBA/depth/posición/tamaño, union de footprints viejo+nuevo, rectángulos en origen inferior izquierdo, historial de 4 daños.
- `scene_renderer.cpp`: invalidación por cambio de escena/efectos, efecto FBO retained con `glScissor`, composite parcial con `glScissor` y fallback completo si no hay buffer previo fiable.
- `android_bridge.cpp`: consulta opcional de `EGL_EXT_buffer_age`; swap con daño KHR/EXT solo si extensión y rectángulo real están disponibles; fallback a `eglSwapBuffers`.
- No se cambian los 90 Hz físicos ni se afirma mejora de FPS sin prueba física.

## Resultados host
- **123 comprobaciones**.
- **120 fotogramas** de comparación contra full redraw: **PASS**.
- 71 parciales / 40 sin cambios / 9 completos.
- Escenarios: movimiento, altas y bajas, cambio de color, scene signature, resize, buffer age 0–3.
- C01 visual-field 1024→815 y tests FrameStats/VSync/Campaign/GPU Virtual/Render Final: PASS.

## Fuente checkpoint C02
Se generó un `XGamingLab-REgraphics-C02-Source.tar.gz` en la conversación del proyecto.
SHA-256:
`9a6aed67becfd02010c75e431768d532baea13844512587c42810056b3269eaf`.

**Limitación:** la fuente C02 completa está en ese paquete de conversación; este PR incluye todavía la implementación de C01 y los controles de workflow, no el diff C02 de 32 KiB. Para C03 se debe importar este checkpoint, compilar Android y ejecutar las pruebas físicas A/B, especialmente superficie retained y context loss. No marcar C02 como validado en Mali antes de hacerlo.

## Regla
No APK ni merge automático antes de C03.
