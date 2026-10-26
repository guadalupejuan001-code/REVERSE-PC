# REVERSE OS v0.2 — Welcome, Mr Reverse

**REVERSE OS v0.2 is an Android-hosted graphical operating environment for the real REVERSE-PC XI machine.** It is not yet a standalone bootable hardware operating system.

## The startup sequence

1. Android 12+ platform splash is forced to solid black instead of white.
2. BootActivity shows **"Welcome, Mr Reverse"**, with the dark REVERSE OS crest. No JNI loading or state restoration delays this screen.
3. DesktopActivity displays a dark desktop, status, wallpaper, app grid and bottom dock. The desktop is displayed even if native initialization fails; that failure is reported as CORE ERROR with a readable diagnostic.
4. Six functional apps open from the desktop or dock:
   - **XI Studio:** program editor and actual native XI execution.
   - **Terminal:** help, ls, run, core, edit, clear; the run command calls JNI QuantumRuntime.execute() and persists RVPC2 only on success.
   - **Files:** a sandboxed browser for saved XI programs with editor integration.
   - **Ether Core:** live native InfiniteCore/Ether/InverseMemory stats.
   - **Chromium:** Chromium-based **Android System WebView**, not a Chromium executable running on the XI guest. Can open Android Chrome when installed.
   - **Settings:** reset RVPC2 with confirmation, restart the welcome animation, or close the desktop.

Everything except intentional browser network access works offline. INTERNET permission supports the browser only. No location, contacts, sensors or broad file-management permissions.

## Architecture

JNI uses the existing QuantumRuntime, XI Machine v1 grammar, hash-verified pinned Mundo X source (commit e2778d962af22f6f1a0794058dd4685fc2573966), and existing REVERSE-PC extensions. This implementation does not copy the core or create a second state authority.

XI programs operate with 16 signed 64-bit registers, arithmetic, branches, loops, quantum gates H/CX/T/T†, Ether transformations and Inverse Ether Memory. The UI displays interpreter results, not fabricated outputs. RVPC2 preserves quantum state, revisions, RNG and memory.

## Building and verification

The canonical build is GitHub Actions: **REVERSE OS v0.2 — welcome boot, desktop and native XI**.

Requires the full Git checkout and pinned deps/mundo-x, SDK 35, NDK, CMake 3.22.1, JDK 17 and Gradle 8.9.

Generate the hash-verified Ether overlay using scripts/prepare-ether-compat.py, then run Gradle :app:assembleDebug in reverse-os-android.

Output: REVERSE-OS-v0.2.apk, with ARM64 for the Samsung A16 and x86_64 for the emulator.

Android CI checks the build signature and permissions; actual boot log, desktop icons, tap into XI Studio, real Euclid result 21, persisted RVPC2, and return to desktop. GitHub Actions publishes actual screenshots boot.png, desktop.png and result.png.

## Important installation note

Android development APKs are signed by a debug signing key, which may differ between GitHub Actions builds. If Android refuses to upgrade an older debug APK with a signature error, back up your RVPC2 state first, uninstall the old debug version, then install this version. Uninstalling removes app-private programs and state.

## Limitations

Android remains the host OS providing the real kernel, drivers, scheduler, graphics, I/O and WebView. REVERSE-PC is a programmable guest execution environment, not a bootable new OS yet. It lacks a complete guest binary executable format, generalized filesystem/syscall ABI, guest multitasking and guest device drivers. A Chromium binary compiled for conventional operating systems cannot currently run as a native XI guest process.

Roadmap: docs/REVERSE_OS_ENGINEERING_2026-10-26.md and docs/XI_MACHINE_V2_PLAN_2026-10-26.md.
