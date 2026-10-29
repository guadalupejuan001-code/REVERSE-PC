# C04: continue the actual Android PCI state

C03 implemented the PCI block device, GPT inputs and persisted 2D display.
Its kernel experiment starts a fresh board. C04 resumes the existing complete
RVG at 1,817,250,000 instructions instead of repeating that boot interval.
The source RVG SHA-256 is
`798e68ea6c98a81e4607272cd2f83eefff2a08cb118ccdb1d605c98c8a6c718d`.
The kernel, normal ramdisk, boot profile and 8,738,832,384-byte disk are pinned
independently. Native restore must reproduce every input RVG byte exactly.

The diagnostic frontier is PID 1 validating the genuine kernel BTF. The
earlier trace semaphore is released. A CPU heartbeat or a completed host time
budget is not an Android boot milestone. The next requirements, in order,
are finishing kernel initialization, executing the original `/init`, loading
the actual PCI drivers, discovering the GPT partitions and mounting Android's
logical partitions. Android services, its compositor, user input, audio and
game graphics follow those steps and need their own evidence.

The continuation utility holds one verified immutable disk attachment and one
original XI/Ether guest across transaction chunks. It changes no guest RAM
size, limits, bootargs, instruction pointer, kernel bytes or authority. Host
time only bounds a cycle; it never changes guest timer values. Periodic saves
use two complete generations and an atomically published SHA-bound pointer.
A partially written generation cannot replace the previous complete state.
An existing output directory is rejected. SIGINT/SIGTERM request a checkpoint
at the next transaction boundary.

An unsupported transition rolls back normally. Binary search locates the
last successful prefix using the same native execution path, preserving the
exact CPU/device/XI state and UART output. The rejected instruction remains
unexecuted. Its PC/opcode is recorded for the next repair.

At the first EL0 boundary the tool verifies the original `/init` virtual
address and 64 original entry bytes, executes one actual instruction and
checks its counter/PC transition. It continues execution only after that
verification. This does not establish Android service or game readiness.

`tests/guest_boot_cycle_test.cpp` checks continuation of the actual ARM64 PCI
graphics program against its uninterrupted full snapshot and pixels; exact
budgets, host stop, failed-prefix localization and incomplete-journal recovery
are also covered. These fixtures do not represent Android boot.

The workflow runs those checks under UBSan, obtains the canonical C03 state
and real disk, executes one bounded continuation, and preserves its native
state, original UART, provenance and independent read-only observation.
