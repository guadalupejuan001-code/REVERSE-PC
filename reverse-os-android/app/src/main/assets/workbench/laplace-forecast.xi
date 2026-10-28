#!reverse-pc-machine-v1
# LAPLACE X / XI causal online forecaster v0.2.
# Same QuantumRuntime and Inverse Ether Memory as REVERSE-PC.
# Input contract: store8 4096 N where N=number of observed closes (7..220).
# p[k] is a positive <=2,000,000,000 integer cents, little endian at 10000+4*k.
# CRITICAL: forecasts only use observations k < N. No reading or future labels.
# Expert 0: persistence, expert 1: constant velocity, expert 2: constant acceleration.
# Select the model with smallest last-8 strictly historical absolute error.
# A diagnostic gate checks historical average error only; NOT a confidence probability.
load8 r0 4096
cmp r0 7
jge enough_history
set r15 1
div r15 0
label enough_history
cmp r0 220
jle valid_count
set r15 1
div r15 0
label valid_count
set r7 0
set r8 0
set r9 0
set r12 8
mov r1 r0
sub r1 1
label train_window
# Price p[k] from paired classical bytes; reads only addresses below the staged count.
mov r2 r1
mul r2 4
add r2 10000
load8 r3 $r2
add r2 1
load8 r10 $r2
mul r10 256
add r3 r10
add r2 1
load8 r10 $r2
mul r10 65536
add r3 r10
add r2 1
load8 r10 $r2
mul r10 16777216
add r3 r10
# Price p[k-1] from paired classical bytes; reads only addresses below the staged count.
mov r2 r1
sub r2 1
mul r2 4
add r2 10000
load8 r4 $r2
add r2 1
load8 r10 $r2
mul r10 256
add r4 r10
add r2 1
load8 r10 $r2
mul r10 65536
add r4 r10
add r2 1
load8 r10 $r2
mul r10 16777216
add r4 r10
# Price p[k-2] from paired classical bytes; reads only addresses below the staged count.
mov r2 r1
sub r2 2
mul r2 4
add r2 10000
load8 r5 $r2
add r2 1
load8 r10 $r2
mul r10 256
add r5 r10
add r2 1
load8 r10 $r2
mul r10 65536
add r5 r10
add r2 1
load8 r10 $r2
mul r10 16777216
add r5 r10
# Price p[k-3] from paired classical bytes; reads only addresses below the staged count.
mov r2 r1
sub r2 3
mul r2 4
add r2 10000
load8 r6 $r2
add r2 1
load8 r10 $r2
mul r10 256
add r6 r10
add r2 1
load8 r10 $r2
mul r10 65536
add r6 r10
add r2 1
load8 r10 $r2
mul r10 16777216
add r6 r10

# Expert 0 historical error: |p[k] - p[k-1]|.
mov r11 r3
sub r11 r4
cmp r11 0
jge baseline_nonnegative
mul r11 -1
label baseline_nonnegative
add r7 r11
# Expert 1 historical error: |p[k] -(2p[k-1]-p[k-2])|.
mov r11 r4
mul r11 2
sub r11 r5
sub r11 r3
cmp r11 0
jge velocity_nonnegative
mul r11 -1
label velocity_nonnegative
add r8 r11
# Expert 2 historical error: |p[k] -(3p[k-1]-3p[k-2]+p[k-3])|.
mov r11 r4
mul r11 3
mov r10 r5
mul r10 3
sub r11 r10
add r11 r6
sub r11 r3
cmp r11 0
jge accel_nonnegative
mul r11 -1
label accel_nonnegative
add r9 r11
sub r1 1
sub r12 1
cmp r12 0
je training_complete
cmp r1 3
jge train_window
label training_complete
# r10 counts the training windows actually observed, never future samples.
set r10 8
sub r10 r12
# Reload newest three observations; the backtest loop ended on an older index.
mov r1 r0
sub r1 1
# Price p[k] from paired classical bytes; reads only addresses below the staged count.
mov r2 r1
mul r2 4
add r2 10000
load8 r3 $r2
add r2 1
load8 r10 $r2
mul r10 256
add r3 r10
add r2 1
load8 r10 $r2
mul r10 65536
add r3 r10
add r2 1
load8 r10 $r2
mul r10 16777216
add r3 r10
# Price p[k-1] from paired classical bytes; reads only addresses below the staged count.
mov r2 r1
sub r2 1
mul r2 4
add r2 10000
load8 r4 $r2
add r2 1
load8 r10 $r2
mul r10 256
add r4 r10
add r2 1
load8 r10 $r2
mul r10 65536
add r4 r10
add r2 1
load8 r10 $r2
mul r10 16777216
add r4 r10
# Price p[k-2] from paired classical bytes; reads only addresses below the staged count.
mov r2 r1
sub r2 2
mul r2 4
add r2 10000
load8 r5 $r2
add r2 1
load8 r10 $r2
mul r10 256
add r5 r10
add r2 1
load8 r10 $r2
mul r10 65536
add r5 r10
add r2 1
load8 r10 $r2
mul r10 16777216
add r5 r10

# Must restore window count: address decoding above reused r10 scratch.
set r10 8
sub r10 r12
# Tie-breaking is conservative: persistence wins equal historical loss.
set r13 0
mov r14 r3
mov r15 r7
cmp r8 r15
jge no_velocity
set r13 1
mov r15 r8
mov r14 r3
mul r14 2
sub r14 r4
label no_velocity
cmp r9 r15
jge no_acceleration
set r13 2
mov r15 r9
mov r14 r3
mul r14 3
mov r11 r4
mul r11 3
sub r14 r11
add r14 r5
label no_acceleration
# Saturate to the input schema for a one-step close estimate.
cmp r14 1
jge nonnegative_prediction
set r14 1
label nonnegative_prediction
cmp r14 2000000000
jle within_price_range
set r14 2000000000
label within_price_range
# Gate is a simple, conservative, *uncalibrated* historical loss threshold.
mov r11 r15
div r11 r10
cmp r11 40
jle gate_open
set r11 0
jmp output
label gate_open
set r11 1
label output
# JSONL registers in this exact order (not market quotes or probabilities):
# r0=N, r13=expert index, r14=forecast cents, r15=last-window loss sum,
# r10=training window length, r11=historical-loss gate.
print r0
print r13
print r14
print r15
print r10
print r11
halt
