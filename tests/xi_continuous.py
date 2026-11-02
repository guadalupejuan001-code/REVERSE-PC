#!/usr/bin/env python3
"""Independent dense oracle, causal width checks, persistence and rollback."""
import hashlib
import json
import math
from pathlib import Path
import random
import subprocess
import sys
import tempfile
import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[1]/'scripts'))
from xi_session_client import XiSession

cli, native = map(lambda s: Path(s).resolve(), sys.argv[1:3])
output = Path(sys.argv[3]).resolve() if len(sys.argv) > 3 else Path('build/xi-continuous')
output.mkdir(parents=True, exist_ok=True)
checks = 0
maximum_error = 0.

def run(session, lines):
    return session.execute('#!reverse-pc-machine-v1\n'+'\n'.join(lines)+'\nhalt\n')[0]

def close(a, b, tol=2e-10):
    global checks, maximum_error
    error = abs(a-b); maximum_error = max(maximum_error, error)
    assert error < tol, (a, b, error)
    checks += 1

def dense_gate(v, q, matrix):
    out = v.copy()
    for i in range(len(v)):
        if i & (1 << q):
            continue
        j = i | (1 << q)
        out[i], out[j] = matrix@v[[i, j]]
    return out

rng = random.Random(328711)
seed = output/'empty.rvp'
if not seed.exists():
    subprocess.run([cli, 'init', seed], check=True)
with XiSession(native, seed) as session:
    for width in [1, 2, 4, 6]:
        for trial in range(3):
            state = np.zeros(1 << width, complex); state[0] = 1
            lines = [f'qprepare 5000 {width}']
            for depth in range(2):
                for q in range(width):
                    axis = rng.choice('xyz'); angle = rng.uniform(-2.8, 2.8)
                    pauli = {'x':np.array([[0, 1], [1, 0]], complex),
                             'y':np.array([[0, -1j], [1j, 0]], complex),
                             'z':np.diag([1, -1])}[axis]
                    matrix = math.cos(angle/2)*np.eye(2)-1j*math.sin(angle/2)*pauli
                    state = dense_gate(state, q, matrix)
                    lines.append(f'r{axis} {5000+q} {angle:.17g}')
                for q in range(width-1):
                    lines.append(f'cx {5000+q} {5001+q}')
                    next_state = state.copy()
                    for i in range(len(state)):
                        next_state[i ^ (1 << (q+1)) if i & (1 << q) else i] = state[i]
                    state = next_state
            expected = []
            for q in range(width):
                for axis in 'XYZ':
                    p = {'X':np.array([[0, 1], [1, 0]], complex),
                         'Y':np.array([[0, -1j], [1j, 0]], complex), 'Z':np.diag([1, -1])}[axis]
                    expected.append(float(np.vdot(state, dense_gate(state, q, p)).real))
                    lines += [f'fexpect f0 {axis}:{5000+q}', 'femit e f0']
            # Reset all earlier oracle blocks first to avoid splitting a wider one.
            session.execute('#!reverse-pc-machine-v1\nbackground zero\nhalt\n')
            observed = [x['value'] for x in run(session, lines) if x['type'] == 'metric']
            for a, b in zip(observed, expected, strict=True):
                close(a, b)
    # 2000 simultaneously materialized qubits, each in a non-Clifford circuit
    # and each causally tested with a local parameter-shift perturbation.
    lines = ['background zero', 'qtrace reset']
    for base in [5000, 7000]:
        for offset in range(0, 1000, 4):
            first = base+offset
            lines.append(f'qprepare {first} 4')
            for q in range(first, first+4):
                lines.append(f'ry {q} {0.31+(q%11)*.027}')
            lines += [f'cx {first+i} {first+i+1}' for i in range(3)]
            for q in range(first, first+4):
                lines += [f'ry {q} 0.29', f'fexpect f0 Z:{q}', f'ry {q} {math.pi/2:.17g}',
                          f'fexpect f1 Z:{q}', f'ry {q} {-math.pi:.17g}', f'fexpect f2 Z:{q}',
                          f'ry {q} {math.pi/2:.17g}', 'fsub f1 f2', 'fmul f1 0.5', 'femit derivative f1']
    # One program per agent remains inside the unchanged instruction budget.
    all_values = run(session, lines+['qtrace report', 'qstats'])
    derivatives = [x['value'] for x in all_values if x.get('name') == 'derivative']
    assert len(derivatives) == 2000 and all(abs(x) > 1e-6 for x in derivatives)
    checks += len(derivatives)
    trace = next(x for x in all_values if x['type'] == 'quantum_trace')
    assert trace['active_qubits'] == trace['distinct_observed_qubits'] == trace['distinct_rotated_qubits'] == 2000
    checks += 1
    saved = output/'continuous.rvp'
    if saved.exists(): saved.unlink()
    session.save(saved)
    before = run(session, ['fexpect f0 Z:5000', 'femit v f0'])[-1]['value']
    try:
        run(session, ['ry 5000 0.8', 'fset f0 1', 'fdiv f0 0'])
        raise AssertionError('bad numeric program committed')
    except RuntimeError as error:
        assert 'division by zero' in str(error)
    after = run(session, ['fexpect f0 Z:5000', 'femit v f0'])[-1]['value']
    close(before, after, 1e-15)
    for invalid in [['qprepare 5001 4'], ['fset f0 nan'], ['ret'], ['fexpect'], ['ftoi r0 9223372036854775808']]:
        try:
            run(session, invalid)
            raise AssertionError(invalid)
        except RuntimeError:
            checks += 1
    usage = session.metrics()
with XiSession(native, saved) as restored:
    close(before, run(restored, ['fexpect f0 Z:5000', 'femit v f0'])[-1]['value'], 1e-15)
summary = {'ok':True, 'checks':checks, 'dense_oracle_max_absolute_error':maximum_error,
           'effective_qubits_per_agent':1000, 'causal_nonzero_derivatives':len(derivatives),
           'trace':trace, 'usage':usage, 'checkpoint_sha256':hashlib.sha256(saved.read_bytes()).hexdigest()}
(output/'summary.json').write_text(json.dumps(summary, indent=2)+'\n')
print(json.dumps(summary))
