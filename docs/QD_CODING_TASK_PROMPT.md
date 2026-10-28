# Qd (Cody) — tarea autónoma especializada de programación

## Misión permanente
Desarrollar a **Qd (Cody)** como la capacidad de programación de **BBY Q**, utilizando los lenguajes XI/Ether y la interfaz Qd Studio de REVERSE-PC. **Qd no es otra IA ni otro estado maestro**: reutiliza la identidad, memoria y capacidades ya existentes de BBY Q. W4u coordina las acciones y REVERSE-PC aporta el editor, los archivos, las herramientas y la ejecución.

El propósito es progresar desde patrones y algoritmos verificables hasta análisis, generación, depuración, refactorización y creación de programas completos, sin fingir capacidades que aún no existan.

## Comprobación antes de trabajar
1. Consulta los repositorios actuales `guadalupejuan001-code/BBY-Q` y `guadalupejuan001-code/REVERSE-PC`, así como la revisión fijada de mundo-X. Identifica rama, commit, workflow, ejecutor y checkpoint RVPC2 efectivo; no supongas que main es el único estado vigente.
2. Lee las instrucciones pertinentes de `BBY-Q/docs/autonomy/`, `BBY-Q/docs/W4U_ENGINE.md`, `REVERSE-PC/docs/QD_CODY_STUDIO.md`, el estado y el registro del ciclo anterior.
3. Comprueba si hay entrenamiento o modificación activa sobre el mismo agente; no inicies ciclos concurrentes sobre una misma autoridad RVPC2 ni modifiques archivos de otra campaña sin coordinación.
4. Identifica habilidades ya aprobadas y la debilidad más importante demostrada en pruebas nuevas. Conservar la memoria de conversación, W4u, migraciones y datos personales.

## Aplicación operativa
Qd Studio es una aplicación interna de REVERSE-PC, no un editor web independiente ni un nuevo emulador. Sus funciones iniciales son editar XI, ejecutar ejercicios en estados desechables, medir resultados, enseñar un patrón únicamente tras pruebas correctas, recuperar el patrón desde BBY Q y generar un RXE ejecutable explícitamente.

La primera versión enseña **suma, resta, producto y resto** mediante plantillas XI con entradas variables. Esta capacidad de patrones no constituye todavía generación general de código ni modificación de pesos. Reconoce y comunica los límites con precisión.

## Cada activación diaria
1. Lee el estado Qd más reciente y las evidencias de ejecuciones anteriores.
2. Escoge un objetivo pequeño, concreto y medible. Define comportamiento esperado y prueba de aceptación *antes* de editar código.
3. Ejecuta diagnóstico inicial y reproduce el fallo con evidencia. Si ya funciona, elige un objetivo distinto.
4. Mejora el motor XI, el currículo, el razonamiento o las herramientas cuando exista un déficit real; no agregues interfaces decorativas para simular progreso.
5. Usa ejercicios variados de práctica, pruebas reservadas y regresiones; preserva la distinción entre demostraciones, ejemplos almacenados, reglas inducidas, parámetros entrenados y generalización.
6. Ejecuta los programas generados en sesiones XI/Ether **aisladas**. Nunca entrenes ejecutando código arbitrario sobre el RVPC2 activo de BBY Q o del escritorio.
7. Evalúa exactitud, fallos, consumo de memoria, duración, persistencia tras reiniciar y rendimiento del teléfono cuando haya una medición real.
8. Conserva únicamente aprendizaje que pase el criterio de aceptación y que no degrade capacidades existentes.
9. Publica cambios en rama/PR verificables, registra pruebas nativas/Android y deja un siguiente paso reproducible. No mezcles una ejecución histórica con pruebas del ciclo actual.

## Curriculum progresivo
- **Fundamentos:** lectura de XI, registros, valores, operaciones, flujo, memoria, entradas y salidas.
- **Algoritmos:** composición de instrucciones, generalización a números nuevos, condiciones, ciclos y subrutinas.
- **Depuración:** identificar el fallo, modificar lo mínimo, ejecutar prueba regresiva, comparar antes/después.
- **Programación de proyectos:** separar responsabilidades, comprender varios archivos, probar contratos, compilar RXE, conservar compatibilidad.
- **Ingeniería asistida:** con capacidades autorizadas, W4u planifica una tarea, Qd propone cambios, el ejecutor trabaja en rama aislada y un verificador comprueba el resultado antes de integrar.
No pasar de nivel por cantidad de ejemplos: exigir evidencia de transferencia a problemas no vistos.

## Restricciones arquitectónicas
- XI/Ether realiza las decisiones de aprendizaje y programación; el anfitrión Java/JS se limita a renderizar interfaz, traducir solicitudes tipadas, operar archivos y aportar verificadores independientes.
- No incorporar modelos externos ni crear una segunda IA silenciosa.
- No borrar ni sustituir los checkpoints y estados de BBY Q. Coordinar y bloquear modificaciones concurrentes de W4u.
- No utilizar Python/C++ como lógica de inteligencia nueva. Las dependencias de compilación históricas fijadas no se sustituyen sin un plan de compatibilidad.
- No atribuir ventajas de memoria o velocidad a los estados mínimos sin comparativas reproducibles.
- El código de alumnos/experimentos debe disponer de límites de pasos, memoria, instrucciones y acceso a recursos; no escribir fuera del sandbox de entrenamiento.
- Los resultados no se deben fabricar, ni aprobar evaluaciones consultando respuestas reservadas.

## Entrega al final del ciclo
Publica **QD / CODY — CICLO N** con:
- Fecha, repositorio, rama y commit exactos;
- checkpoint y continuidad desde el ciclo anterior;
- objetivo, problema reproducido y cambios;
- ejercicios de práctica y evaluación reservada;
- aprobados/total, regresiones, recursos medidos y evidencia ejecutada;
- integración de REVERSE-PC, resultado de CI y limitaciones;
- errores pendientes, siguiente experimento y criterio de éxito.

Si el ejecutor o el repositorio no están accesibles, informa el bloqueo real y el paso concreto para resolverlo. No presentes un plan como si fuera una ejecución y no permitas que el registro del agente amplíe los permisos del propietario.