# ReverseCoding — programación mediante órdenes a Qd (Cody)

## ¿Por qué cambió el nombre de Qd Studio?

Qd Studio comenzó como un laboratorio pequeño para practicar y evaluar patrones XI. **ReverseCoding** designa la aplicación de programación completa dentro de REVERSE-PC. **Qd** sigue siendo el módulo programador del mismo agente BBY Q, no un modelo separado. El objetivo final es interpretar solicitudes, planificar cambios, generar código, depurarlo, verificarlo y producir ejecutables. Lo que existe hoy es solo el primer paso medido de esa cadena.

## Flujo real implementado (prototipo v0.2)

1. En **Órdenes a Qd**, se escribe una instrucción en español o inglés, por ejemplo `Crea un programa que multiplique 12 por 7`.
2. El anfitrión Android normaliza caracteres y extrae tokens y hasta dos números. El anfitrión **no elige la operación**. Representa palabras como hashes tipados; esa compactación es de transporte, no comprensión semántica libre.
3. **`qd/understand.xi`** procesa esos símbolos con XI/Ether y devuelve un estado de aprobación/abstención, una operación y los operandos. El vocabulario y la selección están en XI. Hay cinco familias: suma, resta, multiplicación, división entera y resto.
4. **`qd/compose.xi`** genera los **bytes fuente** de un programa XI Machine v1 usando la operación que XI decidió, no una plantilla de código construida por Java.
5. Se verifica el contrato de seguridad, se ejecuta con `NativeRuntime.initialize()` y se compara el resultado con aritmética independiente del anfitrión. Se muestra el resultado real, la fuente XI editable y un botón **Ejecutar en sandbox**.
6. El botón **Crear .RXE** solo se habilita después de comprobar la fuente concreta. La compilación se solicita explícitamente mediante la ruta RXE existente; ninguna generación de código instala o modifica automáticamente una aplicación.
7. La pestaña **Laboratorio de aprendizaje** conserva el entrenamiento aritmético original. No se introduce un segundo intérprete ni otra memoria maestra.

## Ejemplos admitidos por el intérprete actual

- `suma 23 y 18` → `add`
- `quiero un programa para multiplicar 15 por 6` → `mul`
- `divide 84 entre 7` → `div`
- `calculate` solo, sin dos números y una operación reconocida, se rechaza
- `subtract 80 minus 11` → `sub`
- `remainder 92 and 11` → `mod`

El programa generado sigue la estructura **set r0 A / operación r0 B / print r0 / halt**, con un encabezado XI. Solo se admiten dos enteros explícitos entre 0 y 99. La división usa cociente entero. Se rechaza el divisor cero y cualquier solicitud que contenga múltiples operaciones incompatibles, negación, palabras no reconocidas o números fuera de contrato. `por` aislado no significa multiplicación, pues también aparece en `por favor`.

## Seguridad y preservación

- **Solo operaciones aritméticas de dos operandos.** No se interpretan peticiones de archivos, red, comandos del sistema, memoria, interacción con otros procesos o proyectos multarchivo.
- El código de alumno pasa por una lista de instrucciones permitidas y un límite de 192 bytes. Se rechazan escrituras `store8`, saltos y host I/O desde el editor del sandbox.
- Los programas de comprensión, composición y ejecución corren con **`NativeRuntime.initialize()`**, nunca con la memoria principal `session.rvp` ni con el RVPC2 privado de BBY Q. El sandbox no guarda aprendizaje nuevo.
- Los hashes de palabras de 16 bits son un mecanismo léxico **acotado**, susceptible de colisiones; **no** equivalen a un modelo general de lenguaje. No confiar en estas reglas para ejecutar solicitudes privilegiadas.
- W4u, BBY Q E025, la conversación existente y los checkpoints experimentales E034 no se modifican. El uso del E034 experimental dentro de REVERSE requiere una migración separada y pruebas de compatibilidad.
- Se conserva el aspecto de escritorio REVERSE y el nuevo editor responsive. El nombre ReverseCoding aparece en el lanzador y la ventana. No se publica una APK de actualización con la firma del usuario.

## Pruebas reales y trazabilidad

- El criterio se declaró en `docs/qd/autonomy/evidencias/reversecoding-orders-20261029-criterio.json` antes de editar código.
- [CI nativa XI/Ether](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40903779801): 26 órdenes diferentes ES/EN admitidas, 18 negadas/rechazadas (incluidas ambiguas y hostiles), 93 invocaciones del ejecutor XI y hash de estado descartable inalterado; además 164 comprobaciones del módulo de plantillas y 24/24 reparaciones del depurador anterior. Las frases son pruebas de esta gramática, no órdenes de software arbitrarias. Los resultados de la prueba del corrector anterior provienen de las familias ya admitidas.
- [CI integrada Android 15](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40903779746): comprobar su conclusión actual antes de declarar un APK verificable o pruebas de extremo a extremo. El workflow comprueba BBY Q E025, W4u, migración, teclado, escritorio y el nuevo modo de instrumentación `qd-orders`; la compilación debe usar NDK `27.2.12479018` fijado también en Gradle.

## Qué falta para obedecer órdenes de programación amplias

El siguiente avance requiere entender objetivos de programas, entradas/salidas, condiciones, bucles y secuencias de operaciones y **pedir aclaración** cuando falten requisitos. La representación y las reglas de composición deben seguir siendo XI/Ether. Los ejemplos de prueba deben incluir problemas estructuralmente nuevos y errores desconocidos, no solo paráfrasis de suma y multiplicación. Después hay que conectar el diagnosticador `diagnose.xi` al editor con revisión explícita del parche antes de escribir archivos o compilar.

**No se declara comprensión general, aprendizaje por parámetros, agente autónomo de repositorios ni rendimiento superior a otros modelos.**
