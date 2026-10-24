"""REVERSE-PC: sparse rule-space interpreter, not a quantum computer."""
from __future__ import annotations
from dataclasses import dataclass, field
from hashlib import sha256
import json

@dataclass
class Space:
    default: int = 0
    cells: dict[int, int] = field(default_factory=dict)
    links: dict[int, set[int]] = field(default_factory=dict)
    rules: dict[str, int] = field(default_factory=lambda: {'gain': 1})

    def read(self, address: int) -> int:
        return self.cells.get(address, self.default)

    def write(self, address: int, value: int) -> None:
        if value == self.default:
            self.cells.pop(address, None)
        else:
            self.cells[address] = value

    def connect(self, a: int, b: int) -> None:
        self.links.setdefault(a, set()).add(b)

    def snapshot(self) -> dict:
        return {'default': self.default,
                'cells': {str(k): v for k, v in sorted(self.cells.items())},
                'links': {str(k): sorted(v) for k, v in sorted(self.links.items())},
                'rules': dict(sorted(self.rules.items()))}

    def digest(self) -> str:
        return sha256(json.dumps(self.snapshot(), sort_keys=True,
                                separators=(',', ':')).encode()).hexdigest()

    def clone(self) -> 'Space':
        return Space(self.default, self.cells.copy(),
                     {k: set(v) for k, v in self.links.items()}, self.rules.copy())


def run(space: Space, instructions: list[dict]) -> list[dict]:
    """Execute atomically: commit only if every operation is valid."""
    working = space.clone()
    trace = []
    for step in instructions:
        op = step['op']
        if op == 'connect':
            working.connect(step['a'], step['b'])
        elif op == 'set_rule':
            if step['name'] != 'gain' or not isinstance(step['value'], int):
                raise ValueError('unsupported rule')
            working.rules[step['name']] = step['value']
        elif op == 'propagate':
            source = step['source']
            for target in sorted(working.links.get(source, set())):
                working.write(target, working.read(target) +
                              working.read(source) * working.rules['gain'])
        elif op == 'write':
            working.write(step['address'], step['value'])
        else:
            raise ValueError('unknown instruction: ' + str(op))
        trace.append({'op': op, 'digest': working.digest()})
    space.default, space.cells, space.links, space.rules = (
        working.default, working.cells, working.links, working.rules)
    return trace


def experiment() -> dict:
    initial = Space()
    initial.write(10**80 + 7, 3)
    initial.write(10**80 + 8, 2)
    a = initial.clone()
    b = initial.clone()
    source, target = 10**80 + 7, 10**80 + 8
    program_a = [{'op': 'connect', 'a': source, 'b': target},
                 {'op': 'propagate', 'source': source}]
    program_b = [{'op': 'set_rule', 'name': 'gain', 'value': 4},
                 {'op': 'connect', 'a': source, 'b': target},
                 {'op': 'propagate', 'source': source}]
    trace_a = run(a, program_a)
    trace_b = run(b, program_b)
    return {'initial': initial.snapshot(), 'initial_hash': initial.digest(),
            'program_a': program_a, 'program_b': program_b,
            'result_a': a.snapshot(), 'result_b': b.snapshot(),
            'hash_a': a.digest(), 'hash_b': b.digest(),
            'trace_a': trace_a, 'trace_b': trace_b,
            'distinct': a.digest() != b.digest(),
            'allocated_cells_a': len(a.cells), 'allocated_cells_b': len(b.cells)}

if __name__ == '__main__':
    print(json.dumps(experiment(), indent=2, ensure_ascii=False))
