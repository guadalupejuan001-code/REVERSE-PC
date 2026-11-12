# REgraphics 4.0 — Fidelidad Adaptativa (experimento)

Esta rama amplía **REVERSE-PC / GPU Virtual / REgraphics** con una ruta **5** independiente: conservar efectos visuales distintos (color, profundidad, tamaño y alpha) cuando fusionarlos destruiría información.

La ruta **4** permanece como línea base de rendimiento, sin afirmar que la ruta 5 sea más rápida.

## Archivos

- `.xgaminglab-four/adaptive-fidelity.patch`: **parche completo legible** de C03 -> 4.0, incluyendo cambios del renderer, Android, tests y documentación.
- `.xgaminglab-four/source/`: archivos **nuevos** C++/scripts/docs extraídos del parche para inspección directa.
- `.xgaminglab-four/apply.sh`: reproduce el árbol 4.0 desde el artefacto C03 verificando su SHA-256 antes de aplicar el parche.
- `.github/workflows/regraphics-adaptive-fidelity.yml`: verifica que el parche se aplique, ejecuta pruebas host y EGL/GLES software; guarda el árbol de código resultante. **No compila APK**.

## Fuente de referencia fija

C03, workflow run `43142478902`, archivo `regraphics-c03-canonical-source.tar.gz`, SHA-256 `c0b6b149eda24ff18a418608349d87669fba70f7989f15672cbdc57d0d287880`.

Parche 4.0 original del prototipo local: SHA-256 `00b5f78d1bebfa223de4f92e930f7e943d65414b628652d53a0ba88b0887ecd8`.

## Alcances comprobados localmente

`bash tests/run-adaptive-fidelity.sh` pasa: 4 contraejemplos visuales, mezcla de splats seguros, historia de daños multicapa y **100,000 splats independientes retenidos como 100,000**. La prueba de 100,000 es de **preparación CPU**, no de rasterización GPU ni meshes independientes.

**Pendientes:** pruebas CI EGL/GLES, Android ARM64, render/píxeles y FPS en la Mali-G68 real. No contar objetos procedurales como geometría independiente.

## Integración

- Rama: `feature/regraphics-adaptive-fidelity-20261112`, a partir de `feature/regraphics-three-cycles-20261111`.
- PR de revisión; no mezclar automáticamente.
- El repo base mantiene los ciclos anteriores. Este parche/materialización permite revisar y reproducir el código real sin sustituir ni mutilar la fuente original.
