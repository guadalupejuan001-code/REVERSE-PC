# Android C60: widening shifts by element width

Android reaches `SHLL V1.2D,V1.2S,#32` (`0x2ea13821`) at instruction 28,563,139,583, PC `0x5cb4183460`. V1 changes from `(0x25800000000,0)` to `(0,0x25800000000)` in low/high order, moving the source integer value 600 into the high destination lane.

Implement SHLL/SHLL2 for byte, halfword and word source elements. Q selects the source half; every destination is 128 bits. Capture the complete source before writes, preserve FPCR/FPSR, all other registers and memory, retain the SIMD access trap, and reject reserved size 3 before changes. Unsigned shifts safely reproduce the architectural low bits even for negative source bit patterns.

Tests use an independent byte permutation oracle, every source/destination register, upper/lower halves, aliases, IEEE-looking integer data under every FPCR mode, exact checkpoint restore, traps and actual encodings on physical AArch64. CI authenticates C59 stage 1, pins its original executable, independently replays 48 instructions and compares all reference/candidate bytes. It crosses the actual instruction once with a complete state-delta check, then chains genuine Android continuation. The local clean replay uses 47 instructions from C59 stage 2; failed tails are never sources.

Original RVG/MXIM formats and strict decoders, XI/Ether state, 2-GiB guest RAM, disk authentication, seeded cadence, IRQ checks and SELinux are preserved. The original C53 frame executable verifies compatibility. Full Android boot and framework display content remain unverified.
