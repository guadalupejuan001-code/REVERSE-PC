# REVERSE OS · native XI workstation (Android)

This application is an **offline, installable user-space environment** for the actual C++17 REVERSE-PC XI programmable machine. It is **not** a replacement Android kernel or a standalone bootable OS.

## Experience
- Four mobile-friendly panels: PROGRAMAS (XI editor/run), CONSOLA (shell and execution JSONL), ARCHIVOS (sandboxed .xi files), SISTEMA (real Ether/QuantumRuntime telemetry and RVPC2 import/export).
- Working examples: Euclidean GCD, Fibonacci, 128-qubit GHZ with non-Clifford T, far-address Ether observation.
- Native JNI compiles the same reviewed and SHA-256 verified pinned Mundo X headers, REVERSE-PC integration and XI Machine v1 profile. No external cloud AI or fake renderer is involved.
- Every program runs inside the existing candidate transactional model, without implicitly measuring quantum handles.
- The resulting mixed quantum+memory snapshot is saved as the **same RVPC2 binary envelope** produced by the original CLI. Android uses AtomicFile to preserve the old snapshot if writing fails.
- Programs and state are app-private. Users explicitly select any file to import/export via the Android document picker. No INTERNET, sensor or file-management permissions.

## Build (the canonical path)
1. Checkout REVERSE-PC including history.
2. Checkout pinned Mundo X at \`deps/mundo-x\` and verify exact commit \`e2778d962af22f6f1a0794058dd4685fc2573966\`.
3. \`python3 scripts/prepare-ether-compat.py deps/mundo-x build/ether-compat\`
4. Install Android SDK 35, NDK 27.2, CMake 3.22.1, JDK 17, Gradle 8.9.
5. \`gradle -p reverse-os-android :app:assembleDebug\`.

Alternatively, open **Actions → REVERSE OS — native XI Android workstation** and download \`REVERSE-OS-ANDROID-APK\`. Android APK architectures: arm64-v8a (Samsung A16) and x86_64 (Android emulator).

## Host native contract
\`\`\`sh
g++ -std=c++17 -O1 -Ibuild/ether-compat -Ideps/mundo-x/native/include -Isrc \
  tests/reverse_os_transport.cpp -o build/reverse_os_transport
./build/reverse_os_transport
\`\`\`
This test checks native XI GCD, memory, rollback, corruption rejection, 128-qubit quantum state and RVPC2 byte-identical restoration.

## Honest limitations
This v0.1 runs as an Android application. Android is responsible for actual process scheduling, hardware, graphics, permissions, keyboard and persistent storage. XI currently executes one bounded program at a time; registers reset for each run, there is no general guest filesystem, process isolation, multitasking, VM drivers or hardware boot path. The console contains sandbox management commands, not a general Unix shell.

A future release will need a versioned binary ISA, guest filesystem and explicit guest syscalls, process scheduler, memory isolation and independently tested device integration before calling the underlying guest a full OS.
