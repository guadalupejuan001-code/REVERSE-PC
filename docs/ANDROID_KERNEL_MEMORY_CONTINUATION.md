# Android kernel CPU enumeration and memory initialization

Starting source: PR #52, 06373c2cdc0270013e31c94de8d4378acbc2ffc2.
Starting RVG SHA-256:
73cc99ba20eed6488858db212aef0473998d482de1462f6c9c6f1479866464e3
at 65,788,362 original ARM64 instructions.

The immutable official Cuttlefish build 16644040 GKI and combined initrd
remain byte identical. The kernel identifies itself as
6.12.74-android16-6-g3ec022196c4e-ab15076761-4k. The pinned Mundo-X dependency
is e2778d962af22f6f1a0794058dd4685fc2573966.

## Explicit CPU identification

The exact upcoming kernel instructions read MMFR4, PFR2 and FPFR0.
These three named identification registers now return the baseline value
zero, with existing EL0 traps and read-only rejection. PFR2 advertises no
FPMR/MTE extensions; FPFR0 advertises no FP8 instructions. MMFR4 E2H0 does
not create an EL2 mode: PFR0 continues to advertise EL2 absent.

The definitions and encodings are independently specified in:
https://github.com/torvalds/linux/blob/v6.12/arch/arm64/tools/sysreg

The kernel passes CPU identification, detects its supported Cortex-A53
errata, applies its own boot alternatives, and parses the real command line.

## Actual paired-exclusive failure and repair

At instruction 69,126,117, the original kernel rejects opcode 0xc87f06c0
at PC 0xffffffc0800e0120: LDXP X0,X1,[X22]. The exact pre-instruction RVG is:
fc84fb8d6f9312d239be2d1365ed72aaa46c7c7e491d0d2b6f3779f438f7588d.

The original CPU now implements the 32/64-bit pair forms of LDXP, LDAXP,
STXP and STLXP using the same XI/Ether bytes. It validates the entire access
before changing either half, tracks physical reservations, respects CLREX
and XI-write invalidation, and retains acquire/release ordering in the
existing coherent single-core machine. It does not enable LSE/CASP.

A live 16-byte reservation uses inner machine-state v4, including its
existing IFLS field. Historical states retain exact v2/v3 serialization.
Once the reservation is cleared, legacy serialization is retained when
the other state fields permit it. No second RAM/runtime is introduced.

1,941 local system checks pass, including both pair widths, all
acquire/release combinations, success/failure status, no-reservation
rejection, CLREX, shared XI invalidation, alignment aborts and byte-exact
restoration. A separately assembled bare-metal pair witness is compared
with QEMU in the existing ARM64 compatibility workflow. QEMU is only an
independent development oracle.

The older ISAR3 milestone test now stops before MMFR4 without requiring
that future register support remain absent. The RAM-formatting performance
oracle compares only its intended bounds-formatting difference; subsequent
CPU instructions are present in both measured variants.

## Observed kernel progress

The actual guest reached and passed 106 million instructions with zero
architectural exceptions. Real UART includes CPU features, command-line
processing, cache tables, zones, software IO TLB and:

    SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1

The dedicated continuation CI replays the real MMFR4 failure from the
published input, reaches the exact pre-LDXP RVG, proves that the old CPU
rejects LDXP without modifying it, then compares continuous and resumed
100,000-step execution across the live pair reservation. It continues the
unmodified kernel to the real allocator milestone and preserves the RVG.

Read-only initrd analysis found 42,513,920 vendor CPIO bytes and 5,680,128
generic CPIO bytes (48,194,048 total). The original guest still has 128 MiB
logical RAM; an analysis of its size is not proof that Android services fit.

Continue from the latest genuine checkpoint rather than repeating SCS.
Next gates are actual first-stage /init execution, required storage and
partition devices, Android services and display. None is claimed complete
by the CPU-identification or allocator milestones alone.
