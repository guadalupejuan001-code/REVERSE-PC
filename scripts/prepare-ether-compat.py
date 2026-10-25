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
# Whole-program candidates are never published until parsing, observations,
# memory mutations and all gates succeed. Standalone InfiniteCore keeps its
# original strong per-operation guarantee; only the private runtime candidate
# may mutate uniquely owned metadata in place.
expected.update({
    'infinite_core.hpp':'ff18ec11360f90387ee86a8ca6aa42e8841cfa56fa74d27a7efc88024abe7791',
    'quantum_runtime.hpp':'ed721c2e6d45037ac34784437abfd61265d62917fb8e45bd67fbd92aa5fda64f',
})
replacements['infinite_core.hpp']=[(
    '    const auto normalized = normalize_gates(gates);\n    require_next_revision();\n    auto candidate = std::make_shared<State>(*state_);',
    '    const auto normalized = normalize_gates(gates);\n    require_next_revision();\n'
    '    if (program_candidate_ && state_.unique()) {\n'
    '      for (const auto& gate : normalized) apply_physical_gate(*state_, gate);\n'
    '      ++state_->revision;\n'
    '      return;\n'
    '    }\n'
    '    auto candidate = std::make_shared<State>(*state_);'),(
    '  Background background_;',
    '  friend class QuantumRuntime;\n'
    '  bool program_candidate_ = false;\n'
    '  Background background_;')]
replacements['quantum_runtime.hpp']=[(
    '    auto candidate_core = core_;',
    '    auto candidate_core = core_;\n    candidate_core.program_candidate_ = true;'),(
    '        candidate_core, &candidate_memory, program, require_matching_background);',
    '        candidate_core, &candidate_memory, program, require_matching_background);\n'
    '    candidate_core.program_candidate_ = false;')]
replacements['exact_t_experiment.hpp'] += [
    ('#include <array>', '#include <array>\n#include <memory>\n#include "integration/state_io.hpp"'),
    ('  std::size_t n_;\n  std::size_t max_components_;', '#include "integration/reduced_state_extensions.inc"\n  std::size_t n_;\n  std::size_t max_components_;'),
    ('    base_ = std::move(next_base);', '    base_ = std::move(next_base);\n    integration_basis_.reset();'),
]
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
