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
    ('#include <array>', '#include <array>\n#include <memory>\n#include <mutex>\n#include "integration/state_io.hpp"'),
    ('  std::size_t n_;\n  std::size_t max_components_;', '#include "integration/reduced_state_extensions.inc"\n  std::size_t n_;\n  std::size_t max_components_;'),
    ('    CompactCore next_base = base_;', '    auto next_integration_cache = std::make_shared<IntegrationBasisCache>();\n    CompactCore next_base = base_;'),
    ('    base_ = std::move(next_base);', '    base_ = std::move(next_base);\n    integration_basis_ = std::move(next_integration_cache);'),
]
from ether_integration import configure
configure(expected,replacements)
# E025 retains the larger learned vocabulary and live working memory. Keep the
# upstream checkout pinned and change only this verified, local compatibility copy.
replacements['inverse_memory.hpp'].append((
    '    std::size_t max_overrides = 65536;',
    '    std::size_t max_overrides = 524288;'))
# REVERSE-PC's experimental programmable XI profile is explicitly opted in by
# a first-line marker. Historical XI keeps the original interpreter byte-for-byte.
replacements['infinite_program.hpp'] += [
    ('#include <array>',
     '#include <array>\n#include <map>\n#include <limits>\n#include <atomic>\n#include <thread>\n#include <exception>\n#include <cstring>\n#include <system_error>'),
    ('// This function acts on a private candidate owned by InfiniteSession.',
     '#include "integration/xi_machine_extension.inc"\n\n'
     '// This function acts on a private candidate owned by InfiniteSession.'),
    ('  if (program.size() > max_program_bytes)\n'
     '    throw std::length_error("program exceeds 16 MiB transport budget");\n'
     '  ProgramResult result;',
     """  if (program.rfind(machine_header, 0) == 0 &&
      (program.size() == sizeof(machine_header) - 1 ||
       program[sizeof(machine_header) - 1] == '\\n' ||
       program[sizeof(machine_header) - 1] == '\\r'))
    return run_machine(core, memory, program, require_matching_background);
  if (program.size() > max_program_bytes)
    throw std::length_error("program exceeds 16 MiB transport budget");
  ProgramResult result;""")
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
