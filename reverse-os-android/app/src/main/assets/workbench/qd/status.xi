#!reverse-pc-machine-v1
# Qd state is a reserved memory region of the original BBY Q agent, not a second agent.
load8 r0 8440000000000000000
print r0
load8 r0 8440000000000001024
print r0
load8 r0 8440000000000002048
print r0
load8 r0 8440000000000003072
print r0
load8 r0 8440000000000004096
print r0
load8 r0 8440000000000000016
print r0
halt
