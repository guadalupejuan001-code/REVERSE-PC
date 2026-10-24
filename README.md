# REVERSE-PC

Experimental computer model in which sparse spatial relations, data and mutable rules constitute persistent computational state.

## First experiment: one space, two programs

- Same initial data at logical addresses greater than 10^80.
- Program A links two locations and propagates the value using gain=1.
- Program B changes the persistent gain rule to 4, creates the same link, then propagates.
- Results: A=5, B=14, deterministic and tested. Only two cells are materialized.
- A failed program rolls back the entire transaction.

Run locally:

    python3 -m src.reverse_pc
    python3 -m unittest discover -s tests -v

This is a classical Python interpreter, not a quantum computer. It does not demonstrate hardware acceleration or new physics. The aim is to isolate computational semantics before coupling to MIL Core, Ether Memory and graphics.

Next: adapt the same state operations to Mundo X QuantumRuntime and compare state transitions, memory and execution costs without copying or modifying its original code.
