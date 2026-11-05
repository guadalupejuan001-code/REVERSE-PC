# Android C59: vector integral rounding

Android reaches `FRINTM V1.2S,V1.2S` (`0x0e219821`) at instruction 28,563,139,535, PC `0x725e86cf4c`. The source and result are zero. A clean 36-instruction replay from verified C58 stage 2 reproduces the pre-instruction checkpoint.

Implement the 21 allocated 2S/4S/2D forms of FRINTN, FRINTP, FRINTM, FRINTZ, FRINTA, FRINTX and FRINTI. Reuse original arithmetic and access traps. Fixed rounding ignores FPCR RMode; I/X use it. Only X requests an inexact flag. Preserve signed zero, NaN handling, FZ/DN, aliases and inactive-lane clearing; reject vector 1D before changes. Original scalar rounding is unchanged.

Tests use an independent integer/IEEE-bit oracle with exact small-integer conversion and actual encodings on physical AArch64. CI authenticates C58 stage 1 and its SHA-pinned original CPU, independently replays 37 instructions, compares all reference/candidate bytes, crosses the observed instruction once with a complete state-delta check, then continues verified Android stages. Failed tails are never continuation sources.

Original RVG/MXIM formats and strict decoders, XI/Ether state, 2-GiB guest RAM, disk authentication, seeded cadence, IRQ checks and SELinux are preserved. The original C53 frame executable verifies compatibility. Full Android boot and actual framework display content remain unverified.
