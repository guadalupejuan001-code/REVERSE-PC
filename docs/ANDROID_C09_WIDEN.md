# C09: repair the real C08 widening-instruction stop

## Recovered evidence

C08 run 40982823290 / artifact 12945458506 reached 6,450,570,741 native transitions, EL0 PC `0x4cc358`, then stopped on `0x2f10a442`. LLVM disassembles this as `ushll v2.4s, v2.4h, #0`. Its original state SHA-256 is `547b7245def6e27a60201744a5837e8bbb0a4c2e9bf6eab4b2ecefa61dde9397`.

The captured original UART confirms all 19 normal-profile modules loaded, virtio block/GPU binding, the eight GPT partitions, a successful `/metadata` mount, and creation of logical device-mapper partitions including `system_a`, `vendor_a` and `product_a`. This does NOT establish their filesystem mounts, AVB completion, Android framework/display or games.

## Change

Add SSHLL/USHLL and their upper-half forms to the existing interpreter. Q selects the source half, while the destination is always 128 bits. Capture source before writing for register aliasing; sign-extend before unsigned left shifts; reject immh[3] reserved encodings; leave immh=0 to modified-immediate decoding. Use the original FP access trap. No new emulator, RAM authority, artificial guest instruction, disk, or changed timer stream.

## Local validation

- 70,675 new UBSan checks across 1,792 widening cases pass, including every valid shift/width, signed/unsigned, either source half, aliasing, boundary values, bit-position oracle, whole-state restore, register/memory preservation, reserved encodings, FP access trap, modified-immediate separation, and the exact C08 opcode with a 4,096-qubit witness.
- All 11,675 existing FP/SIMD checks pass under UBSan.
- C09 source audit accepts the downloaded original C08 artifact and pinned C07/C06 reports.
- The continuation host passes local syntax checking. The original 1.1 GB disk artifact exceeds this session's 512 MiB download limit, so no local Android continuation is claimed.

## Continuation

The dedicated workflow downloads that same original disk directly, rechecks all input identities and resumes exactly at the preserved failing opcode. It preserves the 128 MiB RAM profile, XI/Ether memory, immutable kernel/ramdisk/disk, counter seed/cadence/phase and existing journal semantics. Any subsequent architectural failure remains a failed run with a recoverable exact prefix. It does not replay or claim a new first-init milestone. No Android framework, display or native-game readiness is inferred from instruction counts.

C09 execution results must be read from its completed workflow, not inferred from these unit checks. Do not merge into main or publish an Android-ready APK on this evidence alone.
