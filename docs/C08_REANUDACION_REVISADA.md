# C08 — continuar C07, no repetir C06

Origen inmutable: commit 7c21e6aae7f0528805444910c207e9aef6463573, PR #72.
Checkpoint C07 del run 40975381521: 6.350.795.356 instrucciones, PC 0xffffffc0800dfa28, EL1, 16 módulos cargados.
SHA-256: 845fb40da060147a23449ecfd4e7a3d8b11def8d66696093c6e6728798b82694.

## Corrección

El cargador anterior sólo aceptaba la pareja C06 y la puerta de continuación exigía EL0. C07 está en EL1, dentro del kernel cargando módulos. C08 admite exclusivamente el C07 revisado y conserva C06 como raíz de la primera entrada verificada. Comprueba bytes completos, informe, PC, contador, nivel de excepción y reloj antes de ejecutar.

No se reemplazan CPU, memoria XI/Ether, kernel, ramdisk, disco, RAM ni flujo temporal. No se inventa una pantalla ni se omiten instrucciones del invitado. La modificación usa la capa de control ya existente; no es una migración del lenguaje del proyecto.

## Validación local repetida

24 comprobaciones de la puerta con UBSan y 80 pruebas JavaScript (44 de origen y 36 de resultados) aprobadas. Auditoría del C07 completo aprobada. Estas pruebas no son un nuevo arranque Android.

## Ejecución y continuidad

El workflow android-c08-continue-reviewed.yml se activa con cambios pertinentes publicados en la rama aislada fix/android-c08-reviewed-resume-20261030. No se abre automáticamente una PR que vuelva a disparar el experimento histórico C06→C07.

Antes de continuar, repite las suites nativas de ciclo/journal, caché EL0, FP/SIMD y CRC. Consume el C07 original y el disco del run 40910284394; fija Mundo-X en e2778d962af22f6f1a0794058dd4685fc2573966. Una ausencia de artefactos debe fallar: no hay sustitución silenciosa de medios.

Cada ejecución tiene presupuesto operativo de 300 millones de transiciones o 300.000 ms, con guardado periódico. El journal conserva generaciones completas y la evidencia se sube incluso ante error. Los límites son del experimento, no del dominio lógico XI/Ether. El artefacto incluye el binario de prueba Linux y los fuentes exactos para no depender del estado temporal de un chat; no es una APK.

El resultado real debe consultarse en current.json, milestone.json, progress.log y el checkpoint del artefacto. Un contador mayor no prueba dispositivos enlazados, montajes, servicios ni interfaz. Esos hitos y Wild Rift siguen pendientes hasta evidencia específica. main queda intacto.
