# Android C58: indexed floating multiplication

Android reaches `FMUL V1.2S,V5.2S,V1.S[0]` (`0x0f8190a1`) at instruction 28,563,139,498, PC `0x725e86ceb8`. V1 is zero and the two V5 lanes are 1.0 and 0.0. Both resulting lanes are zero.

Implement FMUL and FMULX for scalar S/D and vector 2S/4S/2D, including every legal indexed source lane and register. Capture all operands before writing the destination, including when the destination is the indexed source. Retain original arithmetic, rounding, exception flags, FZ/DN and FP access traps. FMULX implements signed 2.0 for zero times infinity, including FZ input handling. Reject reserved D/L and vector 1D forms before state changes.

Tests use independently specified exact products and IEEE edge cases, complete checkpoint/alias/state checks and physical AArch64 execution of actual encodings. CI authenticates verified C57 stage 2 and its SHA-pinned original executable. It independently replays 22,007 instructions, compares every reference/candidate checkpoint byte, crosses the observed instruction once with a complete state-delta check, and then continues genuine Android stages. Failed tails are diagnostic only.

Original RVG/MXIM formats and strict decoders, XI/Ether state, 2-GiB guest RAM, original disk authentication, seeded cadence, IRQ checks and SELinux are preserved. The original C53 frame executable verifies compatibility. Full Android boot and framework display content remain unverified.
