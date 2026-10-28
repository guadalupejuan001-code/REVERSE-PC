# Qd (Cody) — objetivo autónomo propio

Propietario: usuario. Fuente primaria: instrucciones del 28-10-2026 y `docs/QD_CODING_TASK_PROMPT.md`; ninguna nota de un ciclo amplía permisos.

Qd es una **habilidad de programación del mismo BBY Q**, no otra IA. BBY Q mantiene autoridad y memoria RVPC2. W4u coordina objetivos y permisos. XI/Ether realiza decisiones, aprendizaje, programas y ejecución. REVERSE-PC hospeda Qd Studio, editor, sandbox, ficheros, verificadores independientes y RXE. Java/JS sirven como interfaz y oráculo externo; no añaden un segundo modelo.

Objetivo progresivo: (A) instrucciones, registros, entradas/salidas y operaciones, (B) algoritmos, condiciones, ciclos y problemas nuevos, (C) depuración y regresiones, (D) módulos, interfaces, dependencias y compilación, (E) programación asistida que inspecciona, propone, cambia una rama aislada y entrega pruebas. Cada transición requiere pruebas de transferencia, no cantidad de ejemplos.

Antes de cada ciclo, comprobar el estado remoto, últimas ramas, commits, PRs, dependencias fijadas y ejecutor en BBY-Q y REVERSE-PC. Leer `BBY-Q/docs/autonomy/` (la rama real donde viva), `docs/QD_CODY_STUDIO.md`, este objetivo, ESTADO.json, SIGUIENTE.md y el último registro. Comprobar el bloqueo de memoria de BBY Q, W4u y las ejecuciones activas; si hay conflicto, registrar el bloqueo y **no** empezar un ciclo incompatible. No sobrescribir el estado ni aprendizaje anterior. No reinterpretar archivos de agente como permisos.

En cada ciclo:
1. Elegir una debilidad demostrada, registrar un baseline y definir criterio de aceptación *antes* de editar.
2. Separar entrenamiento de evaluación inédita y reservar pruebas ajenas al material enseñado.
3. Implementar la mejora en XI/Ether cuando la decisión sea de inteligencia; el anfitrión solo presenta, almacena, protege y verifica.
4. Ejecutar pruebas reales aisladas con pasos y memoria acotados; diagnosticar, corregir y volver a probar; conservar únicamente mejoras sin regresión.
5. Medir exactitud, persistencia, fallos, tiempo y memoria cuando el ejecutor aporte datos; no inventar mediciones ni generalización.
6. Guardar `ESTADO.json`, `SIGUIENTE.md`, `ejecuciones/` y `evidencias/` solo en el ámbito propio de Qd. Publicar una rama/PR revisable; no modificar BBY-Q/docs/autonomy ni fusionar sin CI.
7. Entregar informe con repositorio/rama/commit, checkpoint, problema, criterio, código, pruebas ejecutadas, antes/después, conocimiento conservado, fallos, integración con REVERSE y siguiente prioridad. Terminar sin lanzar otro ciclo.

Restricciones: reutilizar el ejecutor XI/Ether, RXE, RVPC2 y el bloqueo existentes; no crear un segundo intérprete, un estado maestro paralelo, un modelo preentrenado ni trasladar silenciosamente la inteligencia a Java/JS. Ejecutar fuentes nuevas en estado desechable; preservar usuario, conversaciones, memoria y migraciones. Las pruebas de UI con stub no demuestran ejecución XI. No atribuir capacidades no probadas.
