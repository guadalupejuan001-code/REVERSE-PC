# Android C57: floating comparisons with zero

Android reaches `FCMLE V4.2S,V1.2S,#0.0` (`0x2ea0d824`) at instruction 28,563,117,490, PC `0x5cb3fb76ec`. Both source lanes are zero. The expected destination is two all-one 32-bit lanes with the upper 64 bits cleared.

The decoder implements FCMEQ, FCMGE, FCMGT, FCMLE and FCMLT against zero for scalar S/D and vector 2S/4S/2D: 25 allocated forms. It retains the existing ArmFloat comparison implementation and FP access trap. EQ raises invalid for signaling NaNs; ordered comparisons raise invalid for either NaN class. Inactive lanes do not participate. Source/destination aliasing, cumulative FPSR, FZ input handling and register 31 are tested. Reserved vector 1D forms are rejected before state changes.

The test uses an independent bit-level IEEE classification oracle and, on AArch64, executes actual encodings on the physical CPU. It covers all source/destination registers and all 16 existing rounding/FZ/DN combinations. The runtime change is confined to the SIMD decoder; the workflow checks that removing the new block reproduces the original C56 source exactly.

CI authenticates C56 stage 1, independently replays 42,889,855 instructions with the SHA-pinned original C56 executable, and compares the complete pre-comparison checkpoint to the candidate. It crosses the observed instruction once, verifies every remaining architectural byte, then chains genuine continuation. Failed diagnostic tails are never continuation sources.

Original RVG/MXIM formats, strict decoders, XI/Ether state, guest RAM, original disk authentication, seeded clock cadence, IRQ checks and SELinux are preserved. The original C53 frame executable verifies compatibility. Full Android boot and framework display content remain unverified.
