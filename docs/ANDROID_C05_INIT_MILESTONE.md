# C05: continue the enumerated PCI state to the original /init

C04 run 40933488319 reached 4,187,300,000 retired instructions and genuinely
enumerated both 1af4:1042 block and 1af4:1050 GPU PCI endpoints, including BAR
resource assignment. Its checkpoint SHA-256 is
`1e06d2f22b6f34f0ec6a27f21e937b1a814267e2ac3b5634bd88cf4e3d5c7086`.
PID 1 had left the jitterentropy allocation path and was registering the
serial driver. It had not executed the original Android init.

C05 resumes that exact state, with its original disk attachment, RAM and
persisted counter seed/cursor. It never draws a replacement seed. The source
checkpoint, complete source report and timing seed identity are independently
pinned in `experiments/android-init-cycle.json`.

The optional `--stop-after-init` policy commits only the single independently
verified original first instruction and saves the resulting EL0 boundary
immediately. Native verification still requires PC 0x2a4000, all 64 original
entry bytes and an actual one-instruction transition to 0x2a4004. A stopped
fixture exercises real ERET/EL0 execution; tests also prove that the verifier
is mandatory and its rejection cannot mutate the caller's state.

The bounded genuine cycle runs for at most ten minutes or two billion
instructions and preserves its last successful state on an architectural
stop. A completed time budget does not count as a successful init milestone.
Only `milestone.json.original_init_first_instruction_verified` attests the
actual native entry check; the read-only observer does not infer execution.

This boundary establishes one Android userspace instruction, not framework,
composer, filesystem-mount or game readiness. The C04 fstab audit's missing
userdata requirement and the memory, input, audio, network and 3D milestones
remain separate work. A later automated continuation beyond this EL0 stop
must consume its hash-bound first-entry proof; the pre-entry CLI deliberately
rejects treating an arbitrary later userspace PC as a fresh init entry.
