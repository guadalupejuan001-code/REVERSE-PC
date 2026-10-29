# Qd (Cody) Studio — coding laboratory for BBY Q

Qd is a **specialized skill of the existing BBY Q agent**, not another language model, runtime, agent, state authority, or platform.

## Current scope (v0.1, independent assessment v2 candidate)

REVERSE-PC Control/Workbench 2.5.1 already supplies XI Studio, RXE, WebView desktop, NativeRuntime, BBY Q E025 and W4u 0.1. Qd adds **Qd · Cody** to its application launcher and dock. It uses existing window management and Android JNI; no server.

- Select one of four bounded arithmetic skills (addition, subtraction, multiplication, remainder).
- Edit a small XI Machine v1 program with `{{a}}` and `{{b}}` placeholders. The editor offers starter code; a starter program is **not** already learned by the agent.
- **Probar código** executes 4 practice pairs through real XI/Ether using a fresh initialized runtime for every pair. The desktop state and BBY Q private memory are not mutated.
- **Enseñar a Qd** runs four practice cases and **28 fresh held-out pairs** (four boundary cases and 24 independently drawn pairs, unique within each exam and disjoint from practice). Android's independent host oracle computes all 32 expected results. The XI assessor now requires **32/32**, and only then does the XI lesson program persist the reviewed source template in a reserved range of the **same BBY Q RVPC2 private memory**. This is more rigorous evaluation of symbolic pattern retention, not neural-weight training. Held-out pairs are revealed only in the completed evaluation report, and a new exam is drawn for each subsequent teaching attempt.
- **Qd resuelve** loads the stored template by running XI against a nonpersistent copy of BBY Q state; fills new `a,b` inputs and runs it with real XI/Ether in an isolated temporary state.
- **Crear .RXE** compiles explicitly verified generated XI source using the current `compileApp` path, stores it in `Aplicaciones` and opens the resulting window. A repeated name is rejected by the normal file contract.

No capability for arbitrary code synthesis, full IDE project editing, visual program debugging, autonomous web research, or unrestricted computer use is implied by this version. The test oracle is deterministic Java arithmetic; XI performs program computation and learned template storage/recall. The host must not select answers from predefined strings.

## State and concurrency

- RVPC2 is owned by `RxeAppStore` under the actual BBY Q RXE SHA-256. No Qd-specific model or independently mutating `qd.rvp` file.
- Reserved Qd addresses: B = `8400000000000000000` for the agent's persistent template slots and M = `8410000000000000000` for staged typed input. Slots 1–4 occupy B + 1024 × skill; B+16 counts accepted lessons (saturates at 250).
- `RxeAppStore.runTrustedXi` uses the **existing BBY Q writer.lock**, atomic session.rxas persistence and the original JNI XI backend. It rejects learning while W4u has pending external action.
- No training changes to BBY Q conversation, previously learned E025 language or W4u regions. Exact executable identity must be verified. Unrecognized custom RXE apps cannot access this bridge.
- Evaluation and inferred code execute via `NativeRuntime.initialize()`, never the desktop `session.rvp` and never via `NativeRuntime.execute(session.loadState(),...)`.
- The state store's output and conversation history are preserved together when the Qd skill is taught. Updating the BBY Q binary must explicitly migrate Qd data or preserve the old state—do not replace user data.

## Limits and security

- Accepted source ≤192 ASCII bytes with XI Machine v1 header, exactly bounded instruction subset: `set`, `mov`, `add`, `sub`, `mul`, `div`, `mod`, `print r0`, `halt`. Both `{{a}}` and `{{b}}` must occur, and output must be a single r0.
- No memory writes, labels, branches, quantum gates, host I/O, imports or executable tool grants from student source in v0.1. Native runtime step/resource budgets apply.
- Practice: (6,7), (12,4), (9,3), (15,8). Assessment v2: 28 independent held-out cases per attempt, including (0,1), (99,99), (99,1), (0,99) and 24 SecureRandom-generated unique pairs with a=0..99 and b=1..99. Each report includes the evaluated pairs for audit after execution. These tests demonstrate transfer of the approved arithmetic **template** to changed inputs, not synthesis of a previously unknown algorithm. Repeated trial-and-error against revealed exams can still lead to selection bias; a future offline examiner should score new problem families without prompting with expected operations.
- Only sandbox-isolated test execution may run arbitrary candidate instructions in later phases; do not broaden v0.1 validator without a security review.
- `model: ChatGPT` is not used inside REVERSE; the UI only transports requests from its own local host.

## Workflows and acceptance checks

- UI syntax, registration, editor state, native request routing and rendering: `node reverse-os-android/tests/qd-studio-ui.cjs`.
- Native XI persistence and replay across four skills plus **128 real evaluation executions** (8 smoke + 24 reproducibly seeded unseen input pairs per family), with an explicit 8/8 legacy-verdict denial and 31/32 rejection: `node reverse-os-android/tests/qd-native.cjs <reverse_pc> <output-dir> [BBY-Q.rvp]`. This suite tests the XI persistence protocol and native execution; Android instrumentation is still needed to validate the host's randomized exam flow on a device.
- Android 15 instrumented flow: after isolated `pm clear`, `adb shell am instrument -w -e mode qd com.reversepc.control.workbench.test/com.reversepc.os.WorkbenchTestRunner` checks fresh heldout uniqueness, reject-wrong/learn-correct/recall-solve via the actual Qd host and XI backend, then proves the main desktop `session.rvp` is unchanged. The integrated workflow runs this after prior migration, keyboard and restore cases; completion still must be verified on CI.
- Existing REVERSE 2.5.1 integrated CI must continue to pass for E025, W4u, migrations, keyboard and Android emulator.
- Installable APK must be compiled from this reviewed branch and signed with the intended existing update key before claiming it can update an already installed REVERSE. The disposable CI key does **not** update an installed APK with a different signing certificate.
- No acceptance claim until the relevant CI and/or phone run has actually completed.

See [Qd autonomous coding prompt](QD_CODING_TASK_PROMPT.md) for the complementary daily training task. That task must not duplicate BBY Q/W4u's existing daily cycle.

## Assessment v2 compatibility note

The assessment contract has changed from eight to 32 required results in both `qd/judge.xi` and `qd/learn.xi`. Stored template bytes, memory addresses and RVPC2 format have **not** changed. The v2 host and XI assets must ship together; do not mix new XI assets with an old host that reports only eight results. This is a **candidate on an isolated review branch** until the relevant CI checks pass. The general BBY Q/W4u autonomy state remains separate.


## Qd ciclo 02 — depuración simbólica XI en laboratorio nativo (PR #56)

La rama `qd/cycle-20261029-02-xi-debug`, apilada sobre #35 y #34, incorpora `workbench/qd/diagnose.xi`: un diagnosticador de **una única anomalía estructural** en programas XI aritméticos canónicos. En un estado RVPC2 descartable recibe diez campos tipados sobre operación, registros, orden y salida; devuelve estado y acción de reparación. Las **siete reglas de selección están programadas en XI**. El anfitrión JS solo restringe/tokeniza fuentes, aplica la acción explícita de XI y contrasta el resultado con un oráculo independiente; no realiza un segundo diagnóstico ni toma decisiones de aprendizaje.

La evaluación CI [40886521655](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40886521655), sobre código `4e163f40cec7ec4a750cd9fb6b9701c60767e6d6`, completó con **success**: 16/16 defectos reproducidos y reparados en práctica; 24/24 programas reservados de fuente distinta con seis entradas nuevas por programa; abstención frente a dos defectos, rechazo de fuentes fuera de contrato y byte de contrato inválido, paso inalterado del programa correcto. Ejecutó 435 invocaciones nativas, incluidas 82 consultas del diagnosticador, y 164 comprobaciones de regresión previa con cuatro plantillas aritméticas y 128 evaluaciones. El estado inicial RVPC2 temporal mantuvo su SHA-256 idéntica; el resultado no se escribió en memoria personal. El primer CI falló por repetición de una fuente entre práctica y reserva, detectada y corregida antes del CI aprobado. Evidencias: `docs/qd/autonomy/evidencias/ciclo-20261029-02-resultados.json` y [artefacto 12901774917](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40886521655/artifacts/12901774917).

**Límite fundamental:** esta entrega prueba un **laboratorio XI de línea de comandos/CI**, no una capacidad disponible en la interfaz Android. No se ha añadido la acción `diagnose` a `QdEngine.java`, un botón de reparar en Qd Studio, compilación RXE de lo corregido ni una prueba Android nueva. Los 24 casos reservados son fuentes e entradas diferentes **dentro de familias ya especificadas**, no algoritmos inéditos ni entrenamiento de parámetros. No se midió RAM pico, energía ni rendimiento en teléfono físico. El antecedente Android aprobado para la evaluación aritmética sigue siendo el CI de #35, y no se reejecutó aquí. Ningún checkpoint E034/E025 personal, memoria de conversación ni estado W4u se cambió.

La siguiente prioridad es el puente Android de solo lectura y revisión explícita del parche por el operador, con instrumentación propia y regresiones integradas antes de cualquier integración o publicación. Conservar el orden de revisión/fusión #34 → #35 → #56 y no presentar esta rama como APK instalada.


## ReverseCoding v0.2: interpretar órdenes y construir código en XI (PR #59)

La antigua aplicación «Qd Studio» se presenta ahora como **ReverseCoding**, entorno de programación del módulo **Qd** perteneciente a BBY Q. El operador escribe una orden ES/EN, `understand.xi` elige una operación aritmética admitida con rechazo de ambigüedad y `compose.xi` emite bytes de código fuente XI real. La interfaz deja inspeccionar/editar esa fuente, ejecutarla en un estado desechable y crear un RXE solo tras ejecución y aprobación explícitas. **No** se introduce una IA separada, se modifica la memoria maestra, se aprende un algoritmo desconocido ni se permite código arbitrario en el sandbox.

Es una capacidad inicial **solo para cinco operaciones binarias con números 0..99**. La gramática XI restringe sinónimos y frases de apoyo conocidas. Las órdenes negativas, parcialmente desconocidas, de múltiples acciones o con acceso a archivos, red o sistema son rechazadas. El compilador RXE y el ejecutor originales se conservan. No sustituye BBY Q E025 con E034 experimental.

La CI nativa [ReverseCoding órdenes XI](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40903779801) demostró 26/26 órdenes admitidas y 18/18 rechazos, 93 ejecuciones XI, checkpoint temporal idéntico, Qd 164 checks y 24/24 reparaciones previas. La CI [Android integrado](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40903779746) verifica además el puente real JNI y la nueva ventana `qd-orders`; **completada con éxito** en Android 15 sobre `77a863656f57c0e7bedee22d70d27e35569f32a0` (migración, escritorio, restauración, Qd anterior y ReverseCoding con sandbox). La firma del APK es temporal de CI; no es una actualización compatible garantizada para el teléfono. Véase [ReverseCoding](REVERSECODING.md) para contratos, flujo y límites.
