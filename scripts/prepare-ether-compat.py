#!/usr/bin/env python3
"""Build a hash-checked local extension; never edit the pinned checkout."""
import difflib
import hashlib
from pathlib import Path
import sys
source=Path(sys.argv[1])/'native/include/mundo_x'
output=Path(sys.argv[2])
expected={'exact_t_experiment.hpp':'89be6b63b9787d9ef9fe9ace7d9b507b1586a14e887cc99a42234d1b46488590'}
replacements={'exact_t_experiment.hpp':[(
    '    ReducedExactTRepresentation out(product.size());',
    '    ReducedExactTRepresentation out(product.size(), max_components);') ]}
diffs=[]
for name,digest in expected.items():
    raw=(source/name).read_bytes()
    if hashlib.sha256(raw).hexdigest()!=digest:
        raise SystemExit(f'Unreviewed upstream header: {name}')
    original=raw.decode(); revised=original
    for old,new in replacements[name]:
        if revised.count(old)!=1: raise SystemExit(f'Ambiguous compatibility patch: {name}')
        revised=revised.replace(old,new)
    destination=output/'mundo_x'/name
    destination.parent.mkdir(parents=True,exist_ok=True)
    if not destination.exists() or destination.read_text()!=revised: destination.write_text(revised)
    diffs.extend(difflib.unified_diff(original.splitlines(True),revised.splitlines(True),fromfile=f'upstream/{name}',tofile=f'reverse-pc/{name}'))
(output/'changes.diff').write_text(''.join(diffs))
