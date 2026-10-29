#!reverse-pc-machine-v1
# REexplorer Citadel typed policy prototype. Not wired into web/network stack.
# No URLs, DOM, cookies, forms or secrets: C3 event bits, mode, proof-of-boundary only.
# Inputs @920...0000 event bits, +1 mode (0/1/2), +2 security boundary ready (1).
# Output +16 action (0 allow,1 ask,2 block,4 terminate), +17 reason.
store8 9200000000000000016 2
store8 9200000000000000017 90
load8 r0 9200000000000000002
cmp r0 1
jne citadel_output
load8 r0 9200000000000000001
cmp r0 0
jlt citadel_unknown_mode
cmp r0 2
jgt citadel_unknown_mode
load8 r1 9200000000000000000
label citadel_scan_0
mov r2 r1
mod r2 2
cmp r2 1
jne citadel_scan_1
set r3 2
set r4 1
jmp citadel_commit
label citadel_scan_1
mov r2 r1
div r2 2
mod r2 2
cmp r2 1
jne citadel_scan_2
set r3 2
set r4 2
jmp citadel_commit
label citadel_scan_2
mov r2 r1
div r2 4
mod r2 2
cmp r2 1
jne citadel_scan_3
set r3 2
set r4 3
jmp citadel_commit
label citadel_scan_3
mov r2 r1
div r2 128
mod r2 2
cmp r2 1
jne citadel_scan_4
set r3 2
set r4 4
jmp citadel_commit
label citadel_scan_4
mov r2 r1
div r2 64
mod r2 2
cmp r2 1
jne citadel_scan_5
set r3 4
set r4 64
jmp citadel_commit
label citadel_scan_5
mov r2 r1
div r2 8
mod r2 2
cmp r2 1
jne citadel_scan_6
cmp r0 1
jne citadel_not_finance_5
set r3 2
set r4 8
jmp citadel_commit
label citadel_not_finance_5
set r3 1
set r4 8
jmp citadel_commit
label citadel_scan_6
mov r2 r1
div r2 32
mod r2 2
cmp r2 1
jne citadel_scan_7
cmp r0 1
jne citadel_not_finance_6
set r3 2
set r4 32
jmp citadel_commit
label citadel_not_finance_6
set r3 1
set r4 32
jmp citadel_commit
label citadel_scan_7
mov r2 r1
div r2 16
mod r2 2
cmp r2 1
jne citadel_scan_8
set r3 1
set r4 16
jmp citadel_commit
label citadel_scan_8
set r3 0
set r4 0
jmp citadel_commit
label citadel_unknown_mode
set r3 2
set r4 91
label citadel_commit
store8 9200000000000000016 r3
store8 9200000000000000017 r4
label citadel_output
load8 r0 9200000000000000016
print r0
load8 r1 9200000000000000017
print r1
halt
