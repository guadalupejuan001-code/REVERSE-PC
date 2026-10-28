# Qd (Cody) Studio — coding laboratory for BBY Q

Qd is a **specialized skill of the existing BBY Q agent**, not another language model, runtime, agent, state authority, or platform.

## Current scope (v0.1)

REVERSE-PC Control/Workbench 2.5.1 already supplies XI Studio, RXE, WebView desktop, NativeRuntime, BBY Q E025 and W4u 0.1. Qd adds **Qd · Cody** to its application launcher and dock. It uses existing window management and Android JNI; no server.

- Select one of four bounded arithmetic skills (addition, subtraction, multiplication, remainder).
- Edit a small XI Machine v1 program with `{{a}}` and `{{b}}` placeholders. The editor offers starter code; a starter program is **not** already learned by the agent.
- **Probar código** executes 4 practice pairs through real XI/Ether using a fresh initialized runtime for every pair. The desktop state and BBY Q private memory are not mutated.
- **Enseñar a Qd** runs those cases plus four held-out pairs. Only on 8/8 correct outcomes does an XI program persist the reviewed source template in a reserved range of the **same BBY Q RVPC2 private memory**. This is tested symbolic pattern retention, not neural-weight training.
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
- Practice: (6,7), (12,4), (9,3), (15,8). Holdout: (23,11), (7,19), (38,5), (61,9). They are fixed transparent smoke-test fixtures, **not** evidence of robust generalization. Later curricula should use independent, randomized, versioned holdouts.
- Only sandbox-isolated test execution may run arbitrary candidate instructions in later phases; do not broaden v0.1 validator without a security review.
- `model: ChatGPT` is not used inside REVERSE; the UI only transports requests from its own local host.

## Workflows and acceptance checks

- UI syntax, registration, editor state, native request routing and rendering: `node reverse-os-android/tests/qd-studio-ui.cjs`.
- Native XI persistence and replay across four skills plus 32 real evaluations: `node reverse-os-android/tests/qd-native.cjs <reverse_pc> <output-dir> [BBY-Q.rvp]`.
- Existing REVERSE 2.5.1 integrated CI must continue to pass for E025, W4u, migrations, keyboard and Android emulator.
- Installable APK must be compiled from this reviewed branch and signed with the intended existing update key before claiming it can update an already installed REVERSE. The disposable CI key does **not** update an installed APK with a different signing certificate.
- No acceptance claim until the relevant CI and/or phone run has actually completed.

See [Qd autonomous coding prompt](QD_CODING_TASK_PROMPT.md) for the complementary daily training task. That task must not duplicate BBY Q/W4u's existing daily cycle.
