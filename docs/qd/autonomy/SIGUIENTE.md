# Próximo ciclo de Qd (Cody)

## Primero: confirmar el estado del ciclo previo

- Resolver `main`, el HEAD actual de `feature/qd-cody-studio-xi` (PR #34) y la rama independiente `qd/cycle-20261028-independent-exams` (PR #35). Si el código o los tests cambiaron, conciliar antes de asumir estos resultados.
- Leer `ESTADO.json`, el último `ejecuciones/`, `docs/QD_CODY_STUDIO.md` y el historial CI de PR #35. Distinguir **éxito del compilador/reproducción E025** de **validación de examen nuevo sobre Android**.
- Verificar la actividad real del workflow, del bloqueo compartido BBY Q `writer.lock`, de W4u y de la tarea general BBY Q/W4u. No entrenar sobre el RVPC2 real cuando otro ciclo lo usa.
- Asegurar que PR #35 permanece separada de `main` y que PR #34 se integra primero, con revisión y CI verde. Si la rama base ya cambió, no reabrir cambios antiguos.

## Debilidad a diagnosticar

Qd v0.1 recupera y adapta patrones aritméticos enseñados. Aprobar 32/32 entradas nuevas demuestra la ejecución de esas plantillas bajo nuevas entradas; **no** demuestra generación de algoritmos no vistos ni depuración de programas arbitrarios.

## Objetivo medible para el siguiente ciclo

**Diagnosticar si Qd puede localizar y corregir errores reales de XI con su propio razonamiento XI/Ether, sin un segundo compilador ni corrector heurístico en Java.** No asumir una tasa de acierto.

1. Ejecutar una evaluación inicial sobre 16 fallos deliberados y distintos en programas XI (registro incorrecto, operación errónea, salida faltante, división por cero, orden de instrucciones), con fuentes y errores separados del material de práctica. Usar el backend actual y presupuestos de ejecución.
2. Definir antes de editar una rúbrica por caso: diagnóstico correcto del fallo, propuesta de modificación mínima, pruebas positivas/negativas, invariantes de seguridad y regresión.
3. Aplicar una mejora en XI/Ether únicamente si las pruebas iniciales demuestran una carencia específica. Java/JS puede instrumentar oráculos y archivos, pero no decidir el parche de Qd.
4. Evaluar al final con **24 programas inéditos** no reutilizados del entrenamiento. Para aceptar, exigir al menos 20/24 correcciones correctas con causas justificadas en el registro, cero ejecución sobre la memoria real de BBY Q, y mantenimiento de las 4 destrezas aritméticas y persistencia RVPC2.
5. Comparar duración, programa y memoria si se obtienen métricas reales. En caso contrario, registrar lo no medido sin inventarlo.

Si todavía no hay infraestructura segura de diagnóstico/edición, el primer objetivo del ciclo será implementar y validar el evaluador aislado y **no** declarar entrenamiento logrado. Al terminar, actualizar solo `docs/qd/autonomy/` con evidencia, siguiente paso y un PR revisable; detenerse hasta la siguiente activación.
