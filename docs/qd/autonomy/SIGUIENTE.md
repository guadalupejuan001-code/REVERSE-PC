# ReverseCoding / Qd — siguiente ciclo después de QD-20261029-03

## Estado verificado al cierre del ciclo

La [CI nativa](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40903779801) y la [CI integrada Android 15](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40903779746) terminaron en **success** para la revisión de código `77a863656f57c0e7bedee22d70d27e35569f32a0`. No equivalen a instalación en teléfono físico ni a comprensión general de programas. El run Android verificó `mode=qd-orders` con la UI real, generación XI y sandbox, más migración, escritorio, restauración y modo Qd previo. PR #59 continúa abierta como borrador sobre #56.

## Verificación obligatoria

Al empezar, resolver HEAD de BBY-Q y REVERSE-PC; comprobar PR #34, #35, #56 y #59, restricciones, dependencia fijada de Mundo X, E025 en Android y E034 experimental de BBY Q. Leer ESTADO.json, el registro del ciclo y los logs reales [CI nativa](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40903779801) y [Android](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40903779746); no reutilizar sus resultados como ejecución del siguiente ciclo. Comprobar escritor de RVPC2, W4u y runs en progreso. No cambiar estado vivo ni sobrescribir memoria del usuario.

## Siguiente objetivo de inteligencia

**Pasar de cinco operaciones aisladas a comprensión programática composicional**, sin crear un segundo motor ni trasladar lógica a Java. Antes de escribir código:

1. Medir qué sucede con peticiones de programa más complejas: «suma 8 y 4, después multiplica el resultado por 3», «si X es mayor que Y devuelve X» y «calcula la suma de una lista». Registrar rechazo/abstención inicial; no inventar un acierto.
2. Construir un protocolo XI de objetivo/entradas/salida, secuencia de pasos y dependencias tipadas; rechazar solicitudes con requisitos ausentes o contradictorios. No dar al anfitrión la decisión semántica ni el algoritmo.
3. Primera meta pequeña: dos pasos aritméticos encadenados con resultados intermedios y orden de evaluación, en español e inglés, dentro de un sandbox con límites de pasos y sin permisos de archivos o sistema.
4. Aceptación antes de editar: >=20/24 problemas nuevos de composición con números y formulaciones distintos, 16 controles ambiguos/negativos rechazados, sin fuga de respuestas de examen al intérprete, regresión de 26/26 casos originales y de 18/18 rechazos, Qd 164 checks y depuración 24/24. Verificar equivalencia XI vs oráculo independiente y persistencia del checkpoint base.
5. En paralelo revisar las colisiones del hash léxico de 16 bits con pruebas adversariales; no ampliar permisos hasta endurecer la identificación.
6. Después del generador, integrar el diagnosticador `diagnose.xi` en ReverseCoding con diff y confirmación explícita del usuario para aplicar una reparación. Nunca editar automáticamente archivos ni estado maestro de BBY Q.
7. Ejecutar en CI nativa y Android 15, comparando contra el checkpoint y la revisión anterior. Medir tamaño/RSS/latencia si son medibles y distinguir estimaciones de datos físicos.

### Dependencias y bloqueos

PR #59 es borrador apilado sobre PR #56 → #35 → #34. La aplicación no está instalada ni firmada como actualización del usuario. La primera capacidad de órdenes es una gramática simbólica ES/EN para operaciones binarias, **no** un agente programador general. No fusionar ni crear un nuevo intérprete o programación automática. Registrar todas las conclusiones verificadas, pruebas, limitaciones y siguiente tarea en docs/qd/autonomy/ y detenerse.
