# Continuous XI quantum primitives

The new machine instructions extend the existing hash-checked compatibility
overlay over Mundo X `e2778d962af22f6f1a0794058dd4685fc2573966`. The pinned
upstream files are unchanged. QuantumRuntime still commits the quantum state
and InverseMemory together, only after an entire XI program succeeds.

- `rx/ry/rz address angle`: radians, binary64; `angle` may be a float register.
- `qprepare first width`: explicitly prepare a complete local block in zero.
  Existing entangled partners outside that block cause rejection. This is a
  nonunitary reset, not a claim that arbitrary states can be uncomputed.
- `fexpect f0 X:address ...`, `fprobz f0 address`: exact simulated expectation
  or Born probability available to XI arithmetic. They do not sample shots.
- `f0..f31`, `fset/fmov/fadd/fsub/fmul/fdiv/fmin/fmax`, `fsin/fcos/fexp/flog/fsqrt`,
  `fcmp`, `itof`, `ftoi`: checked finite binary64 numeric operations.
- `fload/fstore`, `load64/store64`: eight little-endian bytes in the existing
  InverseMemory, not a second parameter store. Integer values are signed.
- `call label`, `ret`: bounded subroutines; original instruction budget retained.
- `clock f0`: monotonic milliseconds; `femit metric_name f0`: JSON metric.
- `qtrace reset/report`: counts actual rotations, observations and distinct
  addresses encountered by the current XI execution.

Small blocks use the existing AdaptiveReduced state authority. Wider rotations
use the existing Reduced Pauli expansion, whose component cost may grow
exponentially. No coefficients are pruned. Numerical roundoff remains binary64;
there is no exact real-number arithmetic claim and no general 1000-qubit dense
statevector claim. Local block size is a circuit topology choice, not the
number of participating qubits in an agent.

`xi_session` is a persistent byte transport. `EXEC n` sends n source bytes,
`SAVE n` sends a new checkpoint path, and `METRICS` reads process resource use.
It does not contain agent logic or update parameters. Explicit checkpoint
publication uses the same RVPC2 serializer as the existing CLI and refuses to
overwrite an existing checkpoint. Original `reverse_pc run` remains available.

Validation uses an independent NumPy dense oracle for random 1/2/4/6-qubit
circuits, simultaneous local circuits on 2000 qubits, a nonzero parameter-shift
derivative on every address, persistence, malformed input and transactional
rollback. Run `bash scripts/build-xi-session.sh` then
`python tests/xi_continuous.py build/xi-learning/reverse_pc build/xi-learning/xi_session`.
