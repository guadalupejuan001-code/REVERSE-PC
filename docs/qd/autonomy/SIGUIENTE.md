# Qd (Cody) — siguiente ciclo después de QD-20261029-02

## Estado comprobado, no supuesto

El segundo ciclo está en `qd/cycle-20261029-02-xi-debug`, PR #56, **apilada sobre #35 → #34**. CI nativa de código `4e163f40cec7ec4a750cd9fb6b9701c60767e6d6`: [run 40886521655](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40886521655), **success** (16/16 reparaciones de práctica, 24/24 programas reservados distintos, 164 checks de Qd legado). No hay fusión, compilación RXE nueva ni función Android activa. El registro y la evidencia exactos están en `ejecuciones/ciclo-20261029-02.json` y `evidencias/ciclo-20261029-02-resultados.json`; la fuente de criterio se guardó **antes** de programar en `evidencias/ciclo-20261029-02-criterio.json`.

No repetir ese examen como si fuera aprendizaje autónomo: el depurador actual contiene **siete reglas diseñadas en XI** para errores **únicos** de `set` + una operación aritmética + `print` + `halt`. Las 24 fuentes distintas siguen perteneciendo a esas familias. No hay entrenamiento por demostraciones, corrección multarchivo ni solución a algoritmos desconocidos. El harness JS solo normaliza entradas, aplica la edición que eligió XI y comprueba con un oráculo independiente.

## Verificación previa obligatoria

1. Resolver nuevos HEAD de main BBY-Q y REVERSE-PC, PR #34, #35, #56, `docs/autonomy/` de BBY Q y `docs/qd/autonomy/`. Verificar cambios más recientes, commits, restricciones de rama, workflow y dependencias fijadas.
2. Consultar ejecuciones y bloqueos activos reales del runner, W4u y escritura de RVPC2. No mezclar el BBY Q experimental E034 con el pin E025 de la app sin una migración probada.
3. Reconciliar dependencias apiladas: **#34 antes de #35 antes de #56**; no fusionar en main por aprobar una prueba aislada.
4. Confirmar que el diagnosticador solo se ejecuta sobre `NativeRuntime.initialize()`/estado temporal. No crear un fichero `qd.rvp`, intérprete nuevo o autoridad de memoria paralela.

## Próxima prioridad concreta: integración de diagnóstico seguro en Qd Studio

El punto débil ahora no es la regla XI, sino **su falta de conexión real con la interfaz y las herramientas Android**. Proponer un contrato de solo lectura `diagnose` que normalice un programa acotado, ejecute el diagnosticador XI en una sesión descartable, muestre tipo de causa y un diff mínimo, y permita al operador aprobar explícitamente la edición. `QdEngine` no debe elegir la causa ni el parche; Java solo valida sintaxis/tokens, protege permisos, aplica una acción tipada ya elegida en XI y muestra resultados. No enseñar automáticamente el parche ni escribirlo en la memoria de BBY Q.

### Criterio de aceptación antes de editar

- Ejecución Android 15 real con `mode=qd-debug`: 16 defectos de práctica y **24 fuentes nuevas** con seis pares de examen nuevos; al menos **20/24** reparaciones correctas por decisión XI y un diff de un fallo exclusivamente.
- Rechazo o abstención de al menos ocho fuentes maliciosas, fuera de contrato o con dos defectos; ningún ejecutable externo ni archivo del usuario recibe el cambio.
- CI integral de `qd-native`, Qd Studio, E025/W4u, migración, escritorio y restauración sin regresión; verificar que el `session.rvp` del escritorio y el RVPC2 privado conservan hashes/identidad.
- Registrar tiempo, tamaño y RSS si el runner realmente puede medirlos, especificando el entorno; no prometer equivalencia de rendimiento con un teléfono físico.
- El examen Android debe mostrar de dónde vienen las fuentes, la semilla, el oráculo y los artefactos, diferenciándolos de la práctica. Mantener por defecto el modo **no persistente**.
- Integrar solo mediante rama/PR aislada y revisión tras CI; conservar #34/#35/#56 intactas si la migración o arquitectura difieren.

## Después, no antes

Pasar a depuración de dos fallos, condiciones, bucles y composición de programas XI **solo** después de tener el puente seguro y una rúbrica sobre programas ajenos al patrón canónico. Comparar con el checkpoint anterior y probar abstenciones. El siguiente ciclo debe concluir con evidencias verificables; no ampliar esta tarea ni ejecutar otra activación desde un mismo ciclo.
