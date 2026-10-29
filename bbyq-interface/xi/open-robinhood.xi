#!reverse-pc-machine-v1
# Trusted BBY Q browser action: only exact, affirmative Robinhood open commands.
# Every lexical decision is in XI. Host observes only op=11,target=11.
store8 8200000000000000064 0
store8 8200000000000000065 0
store8 8200000000000000067 0
load8 r9 7400000000000000017
cmp r9 5
jlt no_browser_command
set r8 0
load8 r3 7400000000000000128
cmp r3 194
jne trim_browser_terminator
load8 r3 7400000000000000129
cmp r3 191
jne trim_browser_terminator
set r8 2
label trim_browser_terminator
mov r7 r9
sub r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 46
je strip_browser_terminator
cmp r3 63
jne browser_match_start
label strip_browser_terminator
sub r9 1
label browser_match_start
label browser_pattern_0
mov r4 r9
sub r4 r8
cmp r4 14
jne browser_pattern_1
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_0
cmp r3 90
jgt browser_char_0_0
add r3 32
label browser_char_0_0
cmp r3 97
jne browser_pattern_1
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_1
cmp r3 90
jgt browser_char_0_1
add r3 32
label browser_char_0_1
cmp r3 98
jne browser_pattern_1
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_2
cmp r3 90
jgt browser_char_0_2
add r3 32
label browser_char_0_2
cmp r3 114
jne browser_pattern_1
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_3
cmp r3 90
jgt browser_char_0_3
add r3 32
label browser_char_0_3
cmp r3 101
jne browser_pattern_1
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_4
cmp r3 90
jgt browser_char_0_4
add r3 32
label browser_char_0_4
cmp r3 32
jne browser_pattern_1
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_5
cmp r3 90
jgt browser_char_0_5
add r3 32
label browser_char_0_5
cmp r3 114
jne browser_pattern_1
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_6
cmp r3 90
jgt browser_char_0_6
add r3 32
label browser_char_0_6
cmp r3 111
jne browser_pattern_1
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_7
cmp r3 90
jgt browser_char_0_7
add r3 32
label browser_char_0_7
cmp r3 98
jne browser_pattern_1
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_8
cmp r3 90
jgt browser_char_0_8
add r3 32
label browser_char_0_8
cmp r3 105
jne browser_pattern_1
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_9
cmp r3 90
jgt browser_char_0_9
add r3 32
label browser_char_0_9
cmp r3 110
jne browser_pattern_1
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_10
cmp r3 90
jgt browser_char_0_10
add r3 32
label browser_char_0_10
cmp r3 104
jne browser_pattern_1
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_11
cmp r3 90
jgt browser_char_0_11
add r3 32
label browser_char_0_11
cmp r3 111
jne browser_pattern_1
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_12
cmp r3 90
jgt browser_char_0_12
add r3 32
label browser_char_0_12
cmp r3 111
jne browser_pattern_1
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_0_13
cmp r3 90
jgt browser_char_0_13
add r3 32
label browser_char_0_13
cmp r3 100
jne browser_pattern_1
jmp browser_open_found
label browser_pattern_1
mov r4 r9
sub r4 r8
cmp r4 15
jne browser_pattern_2
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_0
cmp r3 90
jgt browser_char_1_0
add r3 32
label browser_char_1_0
cmp r3 97
jne browser_pattern_2
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_1
cmp r3 90
jgt browser_char_1_1
add r3 32
label browser_char_1_1
cmp r3 98
jne browser_pattern_2
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_2
cmp r3 90
jgt browser_char_1_2
add r3 32
label browser_char_1_2
cmp r3 114
jne browser_pattern_2
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_3
cmp r3 90
jgt browser_char_1_3
add r3 32
label browser_char_1_3
cmp r3 101
jne browser_pattern_2
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_4
cmp r3 90
jgt browser_char_1_4
add r3 32
label browser_char_1_4
cmp r3 32
jne browser_pattern_2
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_5
cmp r3 90
jgt browser_char_1_5
add r3 32
label browser_char_1_5
cmp r3 114
jne browser_pattern_2
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_6
cmp r3 90
jgt browser_char_1_6
add r3 32
label browser_char_1_6
cmp r3 111
jne browser_pattern_2
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_7
cmp r3 90
jgt browser_char_1_7
add r3 32
label browser_char_1_7
cmp r3 111
jne browser_pattern_2
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_8
cmp r3 90
jgt browser_char_1_8
add r3 32
label browser_char_1_8
cmp r3 98
jne browser_pattern_2
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_9
cmp r3 90
jgt browser_char_1_9
add r3 32
label browser_char_1_9
cmp r3 105
jne browser_pattern_2
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_10
cmp r3 90
jgt browser_char_1_10
add r3 32
label browser_char_1_10
cmp r3 110
jne browser_pattern_2
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_11
cmp r3 90
jgt browser_char_1_11
add r3 32
label browser_char_1_11
cmp r3 104
jne browser_pattern_2
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_12
cmp r3 90
jgt browser_char_1_12
add r3 32
label browser_char_1_12
cmp r3 111
jne browser_pattern_2
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_13
cmp r3 90
jgt browser_char_1_13
add r3 32
label browser_char_1_13
cmp r3 111
jne browser_pattern_2
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_1_14
cmp r3 90
jgt browser_char_1_14
add r3 32
label browser_char_1_14
cmp r3 100
jne browser_pattern_2
jmp browser_open_found
label browser_pattern_2
mov r4 r9
sub r4 r8
cmp r4 15
jne browser_pattern_3
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_0
cmp r3 90
jgt browser_char_2_0
add r3 32
label browser_char_2_0
cmp r3 97
jne browser_pattern_3
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_1
cmp r3 90
jgt browser_char_2_1
add r3 32
label browser_char_2_1
cmp r3 98
jne browser_pattern_3
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_2
cmp r3 90
jgt browser_char_2_2
add r3 32
label browser_char_2_2
cmp r3 114
jne browser_pattern_3
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_3
cmp r3 90
jgt browser_char_2_3
add r3 32
label browser_char_2_3
cmp r3 105
jne browser_pattern_3
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_4
cmp r3 90
jgt browser_char_2_4
add r3 32
label browser_char_2_4
cmp r3 114
jne browser_pattern_3
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_5
cmp r3 90
jgt browser_char_2_5
add r3 32
label browser_char_2_5
cmp r3 32
jne browser_pattern_3
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_6
cmp r3 90
jgt browser_char_2_6
add r3 32
label browser_char_2_6
cmp r3 114
jne browser_pattern_3
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_7
cmp r3 90
jgt browser_char_2_7
add r3 32
label browser_char_2_7
cmp r3 111
jne browser_pattern_3
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_8
cmp r3 90
jgt browser_char_2_8
add r3 32
label browser_char_2_8
cmp r3 98
jne browser_pattern_3
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_9
cmp r3 90
jgt browser_char_2_9
add r3 32
label browser_char_2_9
cmp r3 105
jne browser_pattern_3
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_10
cmp r3 90
jgt browser_char_2_10
add r3 32
label browser_char_2_10
cmp r3 110
jne browser_pattern_3
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_11
cmp r3 90
jgt browser_char_2_11
add r3 32
label browser_char_2_11
cmp r3 104
jne browser_pattern_3
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_12
cmp r3 90
jgt browser_char_2_12
add r3 32
label browser_char_2_12
cmp r3 111
jne browser_pattern_3
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_13
cmp r3 90
jgt browser_char_2_13
add r3 32
label browser_char_2_13
cmp r3 111
jne browser_pattern_3
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_2_14
cmp r3 90
jgt browser_char_2_14
add r3 32
label browser_char_2_14
cmp r3 100
jne browser_pattern_3
jmp browser_open_found
label browser_pattern_3
mov r4 r9
sub r4 r8
cmp r4 22
jne browser_pattern_4
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_0
cmp r3 90
jgt browser_char_3_0
add r3 32
label browser_char_3_0
cmp r3 113
jne browser_pattern_4
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_1
cmp r3 90
jgt browser_char_3_1
add r3 32
label browser_char_3_1
cmp r3 117
jne browser_pattern_4
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_2
cmp r3 90
jgt browser_char_3_2
add r3 32
label browser_char_3_2
cmp r3 105
jne browser_pattern_4
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_3
cmp r3 90
jgt browser_char_3_3
add r3 32
label browser_char_3_3
cmp r3 101
jne browser_pattern_4
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_4
cmp r3 90
jgt browser_char_3_4
add r3 32
label browser_char_3_4
cmp r3 114
jne browser_pattern_4
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_5
cmp r3 90
jgt browser_char_3_5
add r3 32
label browser_char_3_5
cmp r3 111
jne browser_pattern_4
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_6
cmp r3 90
jgt browser_char_3_6
add r3 32
label browser_char_3_6
cmp r3 32
jne browser_pattern_4
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_7
cmp r3 90
jgt browser_char_3_7
add r3 32
label browser_char_3_7
cmp r3 97
jne browser_pattern_4
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_8
cmp r3 90
jgt browser_char_3_8
add r3 32
label browser_char_3_8
cmp r3 98
jne browser_pattern_4
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_9
cmp r3 90
jgt browser_char_3_9
add r3 32
label browser_char_3_9
cmp r3 114
jne browser_pattern_4
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_10
cmp r3 90
jgt browser_char_3_10
add r3 32
label browser_char_3_10
cmp r3 105
jne browser_pattern_4
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_11
cmp r3 90
jgt browser_char_3_11
add r3 32
label browser_char_3_11
cmp r3 114
jne browser_pattern_4
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_12
cmp r3 90
jgt browser_char_3_12
add r3 32
label browser_char_3_12
cmp r3 32
jne browser_pattern_4
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_13
cmp r3 90
jgt browser_char_3_13
add r3 32
label browser_char_3_13
cmp r3 114
jne browser_pattern_4
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_14
cmp r3 90
jgt browser_char_3_14
add r3 32
label browser_char_3_14
cmp r3 111
jne browser_pattern_4
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_15
cmp r3 90
jgt browser_char_3_15
add r3 32
label browser_char_3_15
cmp r3 98
jne browser_pattern_4
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_16
cmp r3 90
jgt browser_char_3_16
add r3 32
label browser_char_3_16
cmp r3 105
jne browser_pattern_4
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_17
cmp r3 90
jgt browser_char_3_17
add r3 32
label browser_char_3_17
cmp r3 110
jne browser_pattern_4
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_18
cmp r3 90
jgt browser_char_3_18
add r3 32
label browser_char_3_18
cmp r3 104
jne browser_pattern_4
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_19
cmp r3 90
jgt browser_char_3_19
add r3 32
label browser_char_3_19
cmp r3 111
jne browser_pattern_4
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_20
cmp r3 90
jgt browser_char_3_20
add r3 32
label browser_char_3_20
cmp r3 111
jne browser_pattern_4
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_3_21
cmp r3 90
jgt browser_char_3_21
add r3 32
label browser_char_3_21
cmp r3 100
jne browser_pattern_4
jmp browser_open_found
label browser_pattern_4
mov r4 r9
sub r4 r8
cmp r4 22
jne browser_pattern_5
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_0
cmp r3 90
jgt browser_char_4_0
add r3 32
label browser_char_4_0
cmp r3 112
jne browser_pattern_5
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_1
cmp r3 90
jgt browser_char_4_1
add r3 32
label browser_char_4_1
cmp r3 117
jne browser_pattern_5
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_2
cmp r3 90
jgt browser_char_4_2
add r3 32
label browser_char_4_2
cmp r3 101
jne browser_pattern_5
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_3
cmp r3 90
jgt browser_char_4_3
add r3 32
label browser_char_4_3
cmp r3 100
jne browser_pattern_5
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_4
cmp r3 90
jgt browser_char_4_4
add r3 32
label browser_char_4_4
cmp r3 101
jne browser_pattern_5
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_5
cmp r3 90
jgt browser_char_4_5
add r3 32
label browser_char_4_5
cmp r3 115
jne browser_pattern_5
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_6
cmp r3 90
jgt browser_char_4_6
add r3 32
label browser_char_4_6
cmp r3 32
jne browser_pattern_5
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_7
cmp r3 90
jgt browser_char_4_7
add r3 32
label browser_char_4_7
cmp r3 97
jne browser_pattern_5
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_8
cmp r3 90
jgt browser_char_4_8
add r3 32
label browser_char_4_8
cmp r3 98
jne browser_pattern_5
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_9
cmp r3 90
jgt browser_char_4_9
add r3 32
label browser_char_4_9
cmp r3 114
jne browser_pattern_5
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_10
cmp r3 90
jgt browser_char_4_10
add r3 32
label browser_char_4_10
cmp r3 105
jne browser_pattern_5
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_11
cmp r3 90
jgt browser_char_4_11
add r3 32
label browser_char_4_11
cmp r3 114
jne browser_pattern_5
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_12
cmp r3 90
jgt browser_char_4_12
add r3 32
label browser_char_4_12
cmp r3 32
jne browser_pattern_5
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_13
cmp r3 90
jgt browser_char_4_13
add r3 32
label browser_char_4_13
cmp r3 114
jne browser_pattern_5
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_14
cmp r3 90
jgt browser_char_4_14
add r3 32
label browser_char_4_14
cmp r3 111
jne browser_pattern_5
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_15
cmp r3 90
jgt browser_char_4_15
add r3 32
label browser_char_4_15
cmp r3 98
jne browser_pattern_5
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_16
cmp r3 90
jgt browser_char_4_16
add r3 32
label browser_char_4_16
cmp r3 105
jne browser_pattern_5
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_17
cmp r3 90
jgt browser_char_4_17
add r3 32
label browser_char_4_17
cmp r3 110
jne browser_pattern_5
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_18
cmp r3 90
jgt browser_char_4_18
add r3 32
label browser_char_4_18
cmp r3 104
jne browser_pattern_5
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_19
cmp r3 90
jgt browser_char_4_19
add r3 32
label browser_char_4_19
cmp r3 111
jne browser_pattern_5
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_20
cmp r3 90
jgt browser_char_4_20
add r3 32
label browser_char_4_20
cmp r3 111
jne browser_pattern_5
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_4_21
cmp r3 90
jgt browser_char_4_21
add r3 32
label browser_char_4_21
cmp r3 100
jne browser_pattern_5
jmp browser_open_found
label browser_pattern_5
mov r4 r9
sub r4 r8
cmp r4 30
jne browser_pattern_6
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_0
cmp r3 90
jgt browser_char_5_0
add r3 32
label browser_char_5_0
cmp r3 97
jne browser_pattern_6
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_1
cmp r3 90
jgt browser_char_5_1
add r3 32
label browser_char_5_1
cmp r3 98
jne browser_pattern_6
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_2
cmp r3 90
jgt browser_char_5_2
add r3 32
label browser_char_5_2
cmp r3 114
jne browser_pattern_6
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_3
cmp r3 90
jgt browser_char_5_3
add r3 32
label browser_char_5_3
cmp r3 101
jne browser_pattern_6
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_4
cmp r3 90
jgt browser_char_5_4
add r3 32
label browser_char_5_4
cmp r3 32
jne browser_pattern_6
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_5
cmp r3 90
jgt browser_char_5_5
add r3 32
label browser_char_5_5
cmp r3 114
jne browser_pattern_6
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_6
cmp r3 90
jgt browser_char_5_6
add r3 32
label browser_char_5_6
cmp r3 111
jne browser_pattern_6
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_7
cmp r3 90
jgt browser_char_5_7
add r3 32
label browser_char_5_7
cmp r3 98
jne browser_pattern_6
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_8
cmp r3 90
jgt browser_char_5_8
add r3 32
label browser_char_5_8
cmp r3 105
jne browser_pattern_6
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_9
cmp r3 90
jgt browser_char_5_9
add r3 32
label browser_char_5_9
cmp r3 110
jne browser_pattern_6
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_10
cmp r3 90
jgt browser_char_5_10
add r3 32
label browser_char_5_10
cmp r3 104
jne browser_pattern_6
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_11
cmp r3 90
jgt browser_char_5_11
add r3 32
label browser_char_5_11
cmp r3 111
jne browser_pattern_6
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_12
cmp r3 90
jgt browser_char_5_12
add r3 32
label browser_char_5_12
cmp r3 111
jne browser_pattern_6
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_13
cmp r3 90
jgt browser_char_5_13
add r3 32
label browser_char_5_13
cmp r3 100
jne browser_pattern_6
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_14
cmp r3 90
jgt browser_char_5_14
add r3 32
label browser_char_5_14
cmp r3 32
jne browser_pattern_6
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_15
cmp r3 90
jgt browser_char_5_15
add r3 32
label browser_char_5_15
cmp r3 101
jne browser_pattern_6
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_16
cmp r3 90
jgt browser_char_5_16
add r3 32
label browser_char_5_16
cmp r3 110
jne browser_pattern_6
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_17
cmp r3 90
jgt browser_char_5_17
add r3 32
label browser_char_5_17
cmp r3 32
jne browser_pattern_6
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_18
cmp r3 90
jgt browser_char_5_18
add r3 32
label browser_char_5_18
cmp r3 101
jne browser_pattern_6
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_19
cmp r3 90
jgt browser_char_5_19
add r3 32
label browser_char_5_19
cmp r3 108
jne browser_pattern_6
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_20
cmp r3 90
jgt browser_char_5_20
add r3 32
label browser_char_5_20
cmp r3 32
jne browser_pattern_6
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_21
cmp r3 90
jgt browser_char_5_21
add r3 32
label browser_char_5_21
cmp r3 110
jne browser_pattern_6
mov r7 r8
add r7 22
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_22
cmp r3 90
jgt browser_char_5_22
add r3 32
label browser_char_5_22
cmp r3 97
jne browser_pattern_6
mov r7 r8
add r7 23
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_23
cmp r3 90
jgt browser_char_5_23
add r3 32
label browser_char_5_23
cmp r3 118
jne browser_pattern_6
mov r7 r8
add r7 24
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_24
cmp r3 90
jgt browser_char_5_24
add r3 32
label browser_char_5_24
cmp r3 101
jne browser_pattern_6
mov r7 r8
add r7 25
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_25
cmp r3 90
jgt browser_char_5_25
add r3 32
label browser_char_5_25
cmp r3 103
jne browser_pattern_6
mov r7 r8
add r7 26
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_26
cmp r3 90
jgt browser_char_5_26
add r3 32
label browser_char_5_26
cmp r3 97
jne browser_pattern_6
mov r7 r8
add r7 27
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_27
cmp r3 90
jgt browser_char_5_27
add r3 32
label browser_char_5_27
cmp r3 100
jne browser_pattern_6
mov r7 r8
add r7 28
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_28
cmp r3 90
jgt browser_char_5_28
add r3 32
label browser_char_5_28
cmp r3 111
jne browser_pattern_6
mov r7 r8
add r7 29
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_5_29
cmp r3 90
jgt browser_char_5_29
add r3 32
label browser_char_5_29
cmp r3 114
jne browser_pattern_6
jmp browser_open_found
label browser_pattern_6
mov r4 r9
sub r4 r8
cmp r4 31
jne browser_pattern_7
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_0
cmp r3 90
jgt browser_char_6_0
add r3 32
label browser_char_6_0
cmp r3 97
jne browser_pattern_7
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_1
cmp r3 90
jgt browser_char_6_1
add r3 32
label browser_char_6_1
cmp r3 98
jne browser_pattern_7
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_2
cmp r3 90
jgt browser_char_6_2
add r3 32
label browser_char_6_2
cmp r3 114
jne browser_pattern_7
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_3
cmp r3 90
jgt browser_char_6_3
add r3 32
label browser_char_6_3
cmp r3 101
jne browser_pattern_7
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_4
cmp r3 90
jgt browser_char_6_4
add r3 32
label browser_char_6_4
cmp r3 32
jne browser_pattern_7
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_5
cmp r3 90
jgt browser_char_6_5
add r3 32
label browser_char_6_5
cmp r3 114
jne browser_pattern_7
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_6
cmp r3 90
jgt browser_char_6_6
add r3 32
label browser_char_6_6
cmp r3 111
jne browser_pattern_7
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_7
cmp r3 90
jgt browser_char_6_7
add r3 32
label browser_char_6_7
cmp r3 111
jne browser_pattern_7
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_8
cmp r3 90
jgt browser_char_6_8
add r3 32
label browser_char_6_8
cmp r3 98
jne browser_pattern_7
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_9
cmp r3 90
jgt browser_char_6_9
add r3 32
label browser_char_6_9
cmp r3 105
jne browser_pattern_7
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_10
cmp r3 90
jgt browser_char_6_10
add r3 32
label browser_char_6_10
cmp r3 110
jne browser_pattern_7
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_11
cmp r3 90
jgt browser_char_6_11
add r3 32
label browser_char_6_11
cmp r3 104
jne browser_pattern_7
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_12
cmp r3 90
jgt browser_char_6_12
add r3 32
label browser_char_6_12
cmp r3 111
jne browser_pattern_7
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_13
cmp r3 90
jgt browser_char_6_13
add r3 32
label browser_char_6_13
cmp r3 111
jne browser_pattern_7
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_14
cmp r3 90
jgt browser_char_6_14
add r3 32
label browser_char_6_14
cmp r3 100
jne browser_pattern_7
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_15
cmp r3 90
jgt browser_char_6_15
add r3 32
label browser_char_6_15
cmp r3 32
jne browser_pattern_7
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_16
cmp r3 90
jgt browser_char_6_16
add r3 32
label browser_char_6_16
cmp r3 101
jne browser_pattern_7
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_17
cmp r3 90
jgt browser_char_6_17
add r3 32
label browser_char_6_17
cmp r3 110
jne browser_pattern_7
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_18
cmp r3 90
jgt browser_char_6_18
add r3 32
label browser_char_6_18
cmp r3 32
jne browser_pattern_7
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_19
cmp r3 90
jgt browser_char_6_19
add r3 32
label browser_char_6_19
cmp r3 101
jne browser_pattern_7
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_20
cmp r3 90
jgt browser_char_6_20
add r3 32
label browser_char_6_20
cmp r3 108
jne browser_pattern_7
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_21
cmp r3 90
jgt browser_char_6_21
add r3 32
label browser_char_6_21
cmp r3 32
jne browser_pattern_7
mov r7 r8
add r7 22
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_22
cmp r3 90
jgt browser_char_6_22
add r3 32
label browser_char_6_22
cmp r3 110
jne browser_pattern_7
mov r7 r8
add r7 23
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_23
cmp r3 90
jgt browser_char_6_23
add r3 32
label browser_char_6_23
cmp r3 97
jne browser_pattern_7
mov r7 r8
add r7 24
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_24
cmp r3 90
jgt browser_char_6_24
add r3 32
label browser_char_6_24
cmp r3 118
jne browser_pattern_7
mov r7 r8
add r7 25
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_25
cmp r3 90
jgt browser_char_6_25
add r3 32
label browser_char_6_25
cmp r3 101
jne browser_pattern_7
mov r7 r8
add r7 26
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_26
cmp r3 90
jgt browser_char_6_26
add r3 32
label browser_char_6_26
cmp r3 103
jne browser_pattern_7
mov r7 r8
add r7 27
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_27
cmp r3 90
jgt browser_char_6_27
add r3 32
label browser_char_6_27
cmp r3 97
jne browser_pattern_7
mov r7 r8
add r7 28
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_28
cmp r3 90
jgt browser_char_6_28
add r3 32
label browser_char_6_28
cmp r3 100
jne browser_pattern_7
mov r7 r8
add r7 29
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_29
cmp r3 90
jgt browser_char_6_29
add r3 32
label browser_char_6_29
cmp r3 111
jne browser_pattern_7
mov r7 r8
add r7 30
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_6_30
cmp r3 90
jgt browser_char_6_30
add r3 32
label browser_char_6_30
cmp r3 114
jne browser_pattern_7
jmp browser_open_found
label browser_pattern_7
mov r4 r9
sub r4 r8
cmp r4 27
jne browser_pattern_8
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_0
cmp r3 90
jgt browser_char_7_0
add r3 32
label browser_char_7_0
cmp r3 97
jne browser_pattern_8
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_1
cmp r3 90
jgt browser_char_7_1
add r3 32
label browser_char_7_1
cmp r3 98
jne browser_pattern_8
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_2
cmp r3 90
jgt browser_char_7_2
add r3 32
label browser_char_7_2
cmp r3 114
jne browser_pattern_8
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_3
cmp r3 90
jgt browser_char_7_3
add r3 32
label browser_char_7_3
cmp r3 101
jne browser_pattern_8
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_4
cmp r3 90
jgt browser_char_7_4
add r3 32
label browser_char_7_4
cmp r3 32
jne browser_pattern_8
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_5
cmp r3 90
jgt browser_char_7_5
add r3 32
label browser_char_7_5
cmp r3 114
jne browser_pattern_8
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_6
cmp r3 90
jgt browser_char_7_6
add r3 32
label browser_char_7_6
cmp r3 111
jne browser_pattern_8
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_7
cmp r3 90
jgt browser_char_7_7
add r3 32
label browser_char_7_7
cmp r3 98
jne browser_pattern_8
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_8
cmp r3 90
jgt browser_char_7_8
add r3 32
label browser_char_7_8
cmp r3 105
jne browser_pattern_8
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_9
cmp r3 90
jgt browser_char_7_9
add r3 32
label browser_char_7_9
cmp r3 110
jne browser_pattern_8
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_10
cmp r3 90
jgt browser_char_7_10
add r3 32
label browser_char_7_10
cmp r3 104
jne browser_pattern_8
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_11
cmp r3 90
jgt browser_char_7_11
add r3 32
label browser_char_7_11
cmp r3 111
jne browser_pattern_8
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_12
cmp r3 90
jgt browser_char_7_12
add r3 32
label browser_char_7_12
cmp r3 111
jne browser_pattern_8
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_13
cmp r3 90
jgt browser_char_7_13
add r3 32
label browser_char_7_13
cmp r3 100
jne browser_pattern_8
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_14
cmp r3 90
jgt browser_char_7_14
add r3 32
label browser_char_7_14
cmp r3 32
jne browser_pattern_8
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_15
cmp r3 90
jgt browser_char_7_15
add r3 32
label browser_char_7_15
cmp r3 101
jne browser_pattern_8
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_16
cmp r3 90
jgt browser_char_7_16
add r3 32
label browser_char_7_16
cmp r3 110
jne browser_pattern_8
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_17
cmp r3 90
jgt browser_char_7_17
add r3 32
label browser_char_7_17
cmp r3 32
jne browser_pattern_8
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_18
cmp r3 90
jgt browser_char_7_18
add r3 32
label browser_char_7_18
cmp r3 110
jne browser_pattern_8
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_19
cmp r3 90
jgt browser_char_7_19
add r3 32
label browser_char_7_19
cmp r3 97
jne browser_pattern_8
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_20
cmp r3 90
jgt browser_char_7_20
add r3 32
label browser_char_7_20
cmp r3 118
jne browser_pattern_8
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_21
cmp r3 90
jgt browser_char_7_21
add r3 32
label browser_char_7_21
cmp r3 101
jne browser_pattern_8
mov r7 r8
add r7 22
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_22
cmp r3 90
jgt browser_char_7_22
add r3 32
label browser_char_7_22
cmp r3 103
jne browser_pattern_8
mov r7 r8
add r7 23
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_23
cmp r3 90
jgt browser_char_7_23
add r3 32
label browser_char_7_23
cmp r3 97
jne browser_pattern_8
mov r7 r8
add r7 24
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_24
cmp r3 90
jgt browser_char_7_24
add r3 32
label browser_char_7_24
cmp r3 100
jne browser_pattern_8
mov r7 r8
add r7 25
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_25
cmp r3 90
jgt browser_char_7_25
add r3 32
label browser_char_7_25
cmp r3 111
jne browser_pattern_8
mov r7 r8
add r7 26
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_7_26
cmp r3 90
jgt browser_char_7_26
add r3 32
label browser_char_7_26
cmp r3 114
jne browser_pattern_8
jmp browser_open_found
label browser_pattern_8
mov r4 r9
sub r4 r8
cmp r4 33
jne browser_pattern_9
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_0
cmp r3 90
jgt browser_char_8_0
add r3 32
label browser_char_8_0
cmp r3 97
jne browser_pattern_9
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_1
cmp r3 90
jgt browser_char_8_1
add r3 32
label browser_char_8_1
cmp r3 98
jne browser_pattern_9
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_2
cmp r3 90
jgt browser_char_8_2
add r3 32
label browser_char_8_2
cmp r3 114
jne browser_pattern_9
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_3
cmp r3 90
jgt browser_char_8_3
add r3 32
label browser_char_8_3
cmp r3 101
jne browser_pattern_9
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_4
cmp r3 90
jgt browser_char_8_4
add r3 32
label browser_char_8_4
cmp r3 32
jne browser_pattern_9
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_5
cmp r3 90
jgt browser_char_8_5
add r3 32
label browser_char_8_5
cmp r3 114
jne browser_pattern_9
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_6
cmp r3 90
jgt browser_char_8_6
add r3 32
label browser_char_8_6
cmp r3 111
jne browser_pattern_9
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_7
cmp r3 90
jgt browser_char_8_7
add r3 32
label browser_char_8_7
cmp r3 98
jne browser_pattern_9
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_8
cmp r3 90
jgt browser_char_8_8
add r3 32
label browser_char_8_8
cmp r3 105
jne browser_pattern_9
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_9
cmp r3 90
jgt browser_char_8_9
add r3 32
label browser_char_8_9
cmp r3 110
jne browser_pattern_9
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_10
cmp r3 90
jgt browser_char_8_10
add r3 32
label browser_char_8_10
cmp r3 104
jne browser_pattern_9
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_11
cmp r3 90
jgt browser_char_8_11
add r3 32
label browser_char_8_11
cmp r3 111
jne browser_pattern_9
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_12
cmp r3 90
jgt browser_char_8_12
add r3 32
label browser_char_8_12
cmp r3 111
jne browser_pattern_9
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_13
cmp r3 90
jgt browser_char_8_13
add r3 32
label browser_char_8_13
cmp r3 100
jne browser_pattern_9
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_14
cmp r3 90
jgt browser_char_8_14
add r3 32
label browser_char_8_14
cmp r3 32
jne browser_pattern_9
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_15
cmp r3 90
jgt browser_char_8_15
add r3 32
label browser_char_8_15
cmp r3 100
jne browser_pattern_9
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_16
cmp r3 90
jgt browser_char_8_16
add r3 32
label browser_char_8_16
cmp r3 101
jne browser_pattern_9
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_17
cmp r3 90
jgt browser_char_8_17
add r3 32
label browser_char_8_17
cmp r3 115
jne browser_pattern_9
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_18
cmp r3 90
jgt browser_char_8_18
add r3 32
label browser_char_8_18
cmp r3 100
jne browser_pattern_9
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_19
cmp r3 90
jgt browser_char_8_19
add r3 32
label browser_char_8_19
cmp r3 101
jne browser_pattern_9
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_20
cmp r3 90
jgt browser_char_8_20
add r3 32
label browser_char_8_20
cmp r3 32
jne browser_pattern_9
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_21
cmp r3 90
jgt browser_char_8_21
add r3 32
label browser_char_8_21
cmp r3 101
jne browser_pattern_9
mov r7 r8
add r7 22
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_22
cmp r3 90
jgt browser_char_8_22
add r3 32
label browser_char_8_22
cmp r3 108
jne browser_pattern_9
mov r7 r8
add r7 23
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_23
cmp r3 90
jgt browser_char_8_23
add r3 32
label browser_char_8_23
cmp r3 32
jne browser_pattern_9
mov r7 r8
add r7 24
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_24
cmp r3 90
jgt browser_char_8_24
add r3 32
label browser_char_8_24
cmp r3 110
jne browser_pattern_9
mov r7 r8
add r7 25
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_25
cmp r3 90
jgt browser_char_8_25
add r3 32
label browser_char_8_25
cmp r3 97
jne browser_pattern_9
mov r7 r8
add r7 26
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_26
cmp r3 90
jgt browser_char_8_26
add r3 32
label browser_char_8_26
cmp r3 118
jne browser_pattern_9
mov r7 r8
add r7 27
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_27
cmp r3 90
jgt browser_char_8_27
add r3 32
label browser_char_8_27
cmp r3 101
jne browser_pattern_9
mov r7 r8
add r7 28
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_28
cmp r3 90
jgt browser_char_8_28
add r3 32
label browser_char_8_28
cmp r3 103
jne browser_pattern_9
mov r7 r8
add r7 29
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_29
cmp r3 90
jgt browser_char_8_29
add r3 32
label browser_char_8_29
cmp r3 97
jne browser_pattern_9
mov r7 r8
add r7 30
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_30
cmp r3 90
jgt browser_char_8_30
add r3 32
label browser_char_8_30
cmp r3 100
jne browser_pattern_9
mov r7 r8
add r7 31
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_31
cmp r3 90
jgt browser_char_8_31
add r3 32
label browser_char_8_31
cmp r3 111
jne browser_pattern_9
mov r7 r8
add r7 32
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_8_32
cmp r3 90
jgt browser_char_8_32
add r3 32
label browser_char_8_32
cmp r3 114
jne browser_pattern_9
jmp browser_open_found
label browser_pattern_9
mov r4 r9
sub r4 r8
cmp r4 40
jne browser_pattern_10
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_0
cmp r3 90
jgt browser_char_9_0
add r3 32
label browser_char_9_0
cmp r3 97
jne browser_pattern_10
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_1
cmp r3 90
jgt browser_char_9_1
add r3 32
label browser_char_9_1
cmp r3 98
jne browser_pattern_10
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_2
cmp r3 90
jgt browser_char_9_2
add r3 32
label browser_char_9_2
cmp r3 114
jne browser_pattern_10
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_3
cmp r3 90
jgt browser_char_9_3
add r3 32
label browser_char_9_3
cmp r3 101
jne browser_pattern_10
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_4
cmp r3 90
jgt browser_char_9_4
add r3 32
label browser_char_9_4
cmp r3 32
jne browser_pattern_10
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_5
cmp r3 90
jgt browser_char_9_5
add r3 32
label browser_char_9_5
cmp r3 114
jne browser_pattern_10
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_6
cmp r3 90
jgt browser_char_9_6
add r3 32
label browser_char_9_6
cmp r3 111
jne browser_pattern_10
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_7
cmp r3 90
jgt browser_char_9_7
add r3 32
label browser_char_9_7
cmp r3 98
jne browser_pattern_10
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_8
cmp r3 90
jgt browser_char_9_8
add r3 32
label browser_char_9_8
cmp r3 105
jne browser_pattern_10
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_9
cmp r3 90
jgt browser_char_9_9
add r3 32
label browser_char_9_9
cmp r3 110
jne browser_pattern_10
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_10
cmp r3 90
jgt browser_char_9_10
add r3 32
label browser_char_9_10
cmp r3 104
jne browser_pattern_10
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_11
cmp r3 90
jgt browser_char_9_11
add r3 32
label browser_char_9_11
cmp r3 111
jne browser_pattern_10
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_12
cmp r3 90
jgt browser_char_9_12
add r3 32
label browser_char_9_12
cmp r3 111
jne browser_pattern_10
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_13
cmp r3 90
jgt browser_char_9_13
add r3 32
label browser_char_9_13
cmp r3 100
jne browser_pattern_10
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_14
cmp r3 90
jgt browser_char_9_14
add r3 32
label browser_char_9_14
cmp r3 32
jne browser_pattern_10
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_15
cmp r3 90
jgt browser_char_9_15
add r3 32
label browser_char_9_15
cmp r3 101
jne browser_pattern_10
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_16
cmp r3 90
jgt browser_char_9_16
add r3 32
label browser_char_9_16
cmp r3 110
jne browser_pattern_10
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_17
cmp r3 90
jgt browser_char_9_17
add r3 32
label browser_char_9_17
cmp r3 32
jne browser_pattern_10
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_18
cmp r3 90
jgt browser_char_9_18
add r3 32
label browser_char_9_18
cmp r3 101
jne browser_pattern_10
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_19
cmp r3 90
jgt browser_char_9_19
add r3 32
label browser_char_9_19
cmp r3 108
jne browser_pattern_10
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_20
cmp r3 90
jgt browser_char_9_20
add r3 32
label browser_char_9_20
cmp r3 32
jne browser_pattern_10
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_21
cmp r3 90
jgt browser_char_9_21
add r3 32
label browser_char_9_21
cmp r3 110
jne browser_pattern_10
mov r7 r8
add r7 22
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_22
cmp r3 90
jgt browser_char_9_22
add r3 32
label browser_char_9_22
cmp r3 97
jne browser_pattern_10
mov r7 r8
add r7 23
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_23
cmp r3 90
jgt browser_char_9_23
add r3 32
label browser_char_9_23
cmp r3 118
jne browser_pattern_10
mov r7 r8
add r7 24
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_24
cmp r3 90
jgt browser_char_9_24
add r3 32
label browser_char_9_24
cmp r3 101
jne browser_pattern_10
mov r7 r8
add r7 25
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_25
cmp r3 90
jgt browser_char_9_25
add r3 32
label browser_char_9_25
cmp r3 103
jne browser_pattern_10
mov r7 r8
add r7 26
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_26
cmp r3 90
jgt browser_char_9_26
add r3 32
label browser_char_9_26
cmp r3 97
jne browser_pattern_10
mov r7 r8
add r7 27
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_27
cmp r3 90
jgt browser_char_9_27
add r3 32
label browser_char_9_27
cmp r3 100
jne browser_pattern_10
mov r7 r8
add r7 28
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_28
cmp r3 90
jgt browser_char_9_28
add r3 32
label browser_char_9_28
cmp r3 111
jne browser_pattern_10
mov r7 r8
add r7 29
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_29
cmp r3 90
jgt browser_char_9_29
add r3 32
label browser_char_9_29
cmp r3 114
jne browser_pattern_10
mov r7 r8
add r7 30
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_30
cmp r3 90
jgt browser_char_9_30
add r3 32
label browser_char_9_30
cmp r3 32
jne browser_pattern_10
mov r7 r8
add r7 31
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_31
cmp r3 90
jgt browser_char_9_31
add r3 32
label browser_char_9_31
cmp r3 112
jne browser_pattern_10
mov r7 r8
add r7 32
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_32
cmp r3 90
jgt browser_char_9_32
add r3 32
label browser_char_9_32
cmp r3 111
jne browser_pattern_10
mov r7 r8
add r7 33
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_33
cmp r3 90
jgt browser_char_9_33
add r3 32
label browser_char_9_33
cmp r3 114
jne browser_pattern_10
mov r7 r8
add r7 34
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_34
cmp r3 90
jgt browser_char_9_34
add r3 32
label browser_char_9_34
cmp r3 32
jne browser_pattern_10
mov r7 r8
add r7 35
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_35
cmp r3 90
jgt browser_char_9_35
add r3 32
label browser_char_9_35
cmp r3 102
jne browser_pattern_10
mov r7 r8
add r7 36
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_36
cmp r3 90
jgt browser_char_9_36
add r3 32
label browser_char_9_36
cmp r3 97
jne browser_pattern_10
mov r7 r8
add r7 37
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_37
cmp r3 90
jgt browser_char_9_37
add r3 32
label browser_char_9_37
cmp r3 118
jne browser_pattern_10
mov r7 r8
add r7 38
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_38
cmp r3 90
jgt browser_char_9_38
add r3 32
label browser_char_9_38
cmp r3 111
jne browser_pattern_10
mov r7 r8
add r7 39
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_9_39
cmp r3 90
jgt browser_char_9_39
add r3 32
label browser_char_9_39
cmp r3 114
jne browser_pattern_10
jmp browser_open_found
label browser_pattern_10
mov r4 r9
sub r4 r8
cmp r4 27
jne browser_pattern_11
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_0
cmp r3 90
jgt browser_char_10_0
add r3 32
label browser_char_10_0
cmp r3 97
jne browser_pattern_11
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_1
cmp r3 90
jgt browser_char_10_1
add r3 32
label browser_char_10_1
cmp r3 98
jne browser_pattern_11
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_2
cmp r3 90
jgt browser_char_10_2
add r3 32
label browser_char_10_2
cmp r3 114
jne browser_pattern_11
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_3
cmp r3 90
jgt browser_char_10_3
add r3 32
label browser_char_10_3
cmp r3 101
jne browser_pattern_11
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_4
cmp r3 90
jgt browser_char_10_4
add r3 32
label browser_char_10_4
cmp r3 32
jne browser_pattern_11
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_5
cmp r3 90
jgt browser_char_10_5
add r3 32
label browser_char_10_5
cmp r3 108
jne browser_pattern_11
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_6
cmp r3 90
jgt browser_char_10_6
add r3 32
label browser_char_10_6
cmp r3 97
jne browser_pattern_11
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_7
cmp r3 90
jgt browser_char_10_7
add r3 32
label browser_char_10_7
cmp r3 32
jne browser_pattern_11
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_8
cmp r3 90
jgt browser_char_10_8
add r3 32
label browser_char_10_8
cmp r3 112
jne browser_pattern_11
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_9
cmp r3 90
jgt browser_char_10_9
add r3 32
label browser_char_10_9
cmp r3 97
jne browser_pattern_11
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_10
cmp r3 90
jgt browser_char_10_10
add r3 32
label browser_char_10_10
cmp r3 103
jne browser_pattern_11
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_11
cmp r3 90
jgt browser_char_10_11
add r3 32
label browser_char_10_11
cmp r3 105
jne browser_pattern_11
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_12
cmp r3 90
jgt browser_char_10_12
add r3 32
label browser_char_10_12
cmp r3 110
jne browser_pattern_11
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_13
cmp r3 90
jgt browser_char_10_13
add r3 32
label browser_char_10_13
cmp r3 97
jne browser_pattern_11
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_14
cmp r3 90
jgt browser_char_10_14
add r3 32
label browser_char_10_14
cmp r3 32
jne browser_pattern_11
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_15
cmp r3 90
jgt browser_char_10_15
add r3 32
label browser_char_10_15
cmp r3 100
jne browser_pattern_11
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_16
cmp r3 90
jgt browser_char_10_16
add r3 32
label browser_char_10_16
cmp r3 101
jne browser_pattern_11
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_17
cmp r3 90
jgt browser_char_10_17
add r3 32
label browser_char_10_17
cmp r3 32
jne browser_pattern_11
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_18
cmp r3 90
jgt browser_char_10_18
add r3 32
label browser_char_10_18
cmp r3 114
jne browser_pattern_11
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_19
cmp r3 90
jgt browser_char_10_19
add r3 32
label browser_char_10_19
cmp r3 111
jne browser_pattern_11
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_20
cmp r3 90
jgt browser_char_10_20
add r3 32
label browser_char_10_20
cmp r3 98
jne browser_pattern_11
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_21
cmp r3 90
jgt browser_char_10_21
add r3 32
label browser_char_10_21
cmp r3 105
jne browser_pattern_11
mov r7 r8
add r7 22
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_22
cmp r3 90
jgt browser_char_10_22
add r3 32
label browser_char_10_22
cmp r3 110
jne browser_pattern_11
mov r7 r8
add r7 23
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_23
cmp r3 90
jgt browser_char_10_23
add r3 32
label browser_char_10_23
cmp r3 104
jne browser_pattern_11
mov r7 r8
add r7 24
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_24
cmp r3 90
jgt browser_char_10_24
add r3 32
label browser_char_10_24
cmp r3 111
jne browser_pattern_11
mov r7 r8
add r7 25
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_25
cmp r3 90
jgt browser_char_10_25
add r3 32
label browser_char_10_25
cmp r3 111
jne browser_pattern_11
mov r7 r8
add r7 26
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_10_26
cmp r3 90
jgt browser_char_10_26
add r3 32
label browser_char_10_26
cmp r3 100
jne browser_pattern_11
jmp browser_open_found
label browser_pattern_11
mov r4 r9
sub r4 r8
cmp r4 28
jne browser_pattern_12
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_0
cmp r3 90
jgt browser_char_11_0
add r3 32
label browser_char_11_0
cmp r3 97
jne browser_pattern_12
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_1
cmp r3 90
jgt browser_char_11_1
add r3 32
label browser_char_11_1
cmp r3 98
jne browser_pattern_12
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_2
cmp r3 90
jgt browser_char_11_2
add r3 32
label browser_char_11_2
cmp r3 114
jne browser_pattern_12
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_3
cmp r3 90
jgt browser_char_11_3
add r3 32
label browser_char_11_3
cmp r3 101
jne browser_pattern_12
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_4
cmp r3 90
jgt browser_char_11_4
add r3 32
label browser_char_11_4
cmp r3 32
jne browser_pattern_12
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_5
cmp r3 90
jgt browser_char_11_5
add r3 32
label browser_char_11_5
cmp r3 108
jne browser_pattern_12
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_6
cmp r3 90
jgt browser_char_11_6
add r3 32
label browser_char_11_6
cmp r3 97
jne browser_pattern_12
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_7
cmp r3 90
jgt browser_char_11_7
add r3 32
label browser_char_11_7
cmp r3 32
jne browser_pattern_12
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_8
cmp r3 90
jgt browser_char_11_8
add r3 32
label browser_char_11_8
cmp r3 112
jne browser_pattern_12
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_9
cmp r3 90
jgt browser_char_11_9
add r3 32
label browser_char_11_9
cmp r3 195
jne browser_pattern_12
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_10
cmp r3 90
jgt browser_char_11_10
add r3 32
label browser_char_11_10
cmp r3 161
jne browser_pattern_12
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_11
cmp r3 90
jgt browser_char_11_11
add r3 32
label browser_char_11_11
cmp r3 103
jne browser_pattern_12
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_12
cmp r3 90
jgt browser_char_11_12
add r3 32
label browser_char_11_12
cmp r3 105
jne browser_pattern_12
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_13
cmp r3 90
jgt browser_char_11_13
add r3 32
label browser_char_11_13
cmp r3 110
jne browser_pattern_12
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_14
cmp r3 90
jgt browser_char_11_14
add r3 32
label browser_char_11_14
cmp r3 97
jne browser_pattern_12
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_15
cmp r3 90
jgt browser_char_11_15
add r3 32
label browser_char_11_15
cmp r3 32
jne browser_pattern_12
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_16
cmp r3 90
jgt browser_char_11_16
add r3 32
label browser_char_11_16
cmp r3 100
jne browser_pattern_12
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_17
cmp r3 90
jgt browser_char_11_17
add r3 32
label browser_char_11_17
cmp r3 101
jne browser_pattern_12
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_18
cmp r3 90
jgt browser_char_11_18
add r3 32
label browser_char_11_18
cmp r3 32
jne browser_pattern_12
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_19
cmp r3 90
jgt browser_char_11_19
add r3 32
label browser_char_11_19
cmp r3 114
jne browser_pattern_12
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_20
cmp r3 90
jgt browser_char_11_20
add r3 32
label browser_char_11_20
cmp r3 111
jne browser_pattern_12
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_21
cmp r3 90
jgt browser_char_11_21
add r3 32
label browser_char_11_21
cmp r3 98
jne browser_pattern_12
mov r7 r8
add r7 22
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_22
cmp r3 90
jgt browser_char_11_22
add r3 32
label browser_char_11_22
cmp r3 105
jne browser_pattern_12
mov r7 r8
add r7 23
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_23
cmp r3 90
jgt browser_char_11_23
add r3 32
label browser_char_11_23
cmp r3 110
jne browser_pattern_12
mov r7 r8
add r7 24
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_24
cmp r3 90
jgt browser_char_11_24
add r3 32
label browser_char_11_24
cmp r3 104
jne browser_pattern_12
mov r7 r8
add r7 25
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_25
cmp r3 90
jgt browser_char_11_25
add r3 32
label browser_char_11_25
cmp r3 111
jne browser_pattern_12
mov r7 r8
add r7 26
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_26
cmp r3 90
jgt browser_char_11_26
add r3 32
label browser_char_11_26
cmp r3 111
jne browser_pattern_12
mov r7 r8
add r7 27
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_11_27
cmp r3 90
jgt browser_char_11_27
add r3 32
label browser_char_11_27
cmp r3 100
jne browser_pattern_12
jmp browser_open_found
label browser_pattern_12
mov r4 r9
sub r4 r8
cmp r4 14
jne browser_pattern_13
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_0
cmp r3 90
jgt browser_char_12_0
add r3 32
label browser_char_12_0
cmp r3 111
jne browser_pattern_13
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_1
cmp r3 90
jgt browser_char_12_1
add r3 32
label browser_char_12_1
cmp r3 112
jne browser_pattern_13
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_2
cmp r3 90
jgt browser_char_12_2
add r3 32
label browser_char_12_2
cmp r3 101
jne browser_pattern_13
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_3
cmp r3 90
jgt browser_char_12_3
add r3 32
label browser_char_12_3
cmp r3 110
jne browser_pattern_13
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_4
cmp r3 90
jgt browser_char_12_4
add r3 32
label browser_char_12_4
cmp r3 32
jne browser_pattern_13
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_5
cmp r3 90
jgt browser_char_12_5
add r3 32
label browser_char_12_5
cmp r3 114
jne browser_pattern_13
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_6
cmp r3 90
jgt browser_char_12_6
add r3 32
label browser_char_12_6
cmp r3 111
jne browser_pattern_13
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_7
cmp r3 90
jgt browser_char_12_7
add r3 32
label browser_char_12_7
cmp r3 98
jne browser_pattern_13
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_8
cmp r3 90
jgt browser_char_12_8
add r3 32
label browser_char_12_8
cmp r3 105
jne browser_pattern_13
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_9
cmp r3 90
jgt browser_char_12_9
add r3 32
label browser_char_12_9
cmp r3 110
jne browser_pattern_13
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_10
cmp r3 90
jgt browser_char_12_10
add r3 32
label browser_char_12_10
cmp r3 104
jne browser_pattern_13
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_11
cmp r3 90
jgt browser_char_12_11
add r3 32
label browser_char_12_11
cmp r3 111
jne browser_pattern_13
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_12
cmp r3 90
jgt browser_char_12_12
add r3 32
label browser_char_12_12
cmp r3 111
jne browser_pattern_13
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_12_13
cmp r3 90
jgt browser_char_12_13
add r3 32
label browser_char_12_13
cmp r3 100
jne browser_pattern_13
jmp browser_open_found
label browser_pattern_13
mov r4 r9
sub r4 r8
cmp r4 15
jne browser_pattern_14
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_0
cmp r3 90
jgt browser_char_13_0
add r3 32
label browser_char_13_0
cmp r3 111
jne browser_pattern_14
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_1
cmp r3 90
jgt browser_char_13_1
add r3 32
label browser_char_13_1
cmp r3 112
jne browser_pattern_14
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_2
cmp r3 90
jgt browser_char_13_2
add r3 32
label browser_char_13_2
cmp r3 101
jne browser_pattern_14
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_3
cmp r3 90
jgt browser_char_13_3
add r3 32
label browser_char_13_3
cmp r3 110
jne browser_pattern_14
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_4
cmp r3 90
jgt browser_char_13_4
add r3 32
label browser_char_13_4
cmp r3 32
jne browser_pattern_14
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_5
cmp r3 90
jgt browser_char_13_5
add r3 32
label browser_char_13_5
cmp r3 114
jne browser_pattern_14
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_6
cmp r3 90
jgt browser_char_13_6
add r3 32
label browser_char_13_6
cmp r3 111
jne browser_pattern_14
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_7
cmp r3 90
jgt browser_char_13_7
add r3 32
label browser_char_13_7
cmp r3 111
jne browser_pattern_14
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_8
cmp r3 90
jgt browser_char_13_8
add r3 32
label browser_char_13_8
cmp r3 98
jne browser_pattern_14
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_9
cmp r3 90
jgt browser_char_13_9
add r3 32
label browser_char_13_9
cmp r3 105
jne browser_pattern_14
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_10
cmp r3 90
jgt browser_char_13_10
add r3 32
label browser_char_13_10
cmp r3 110
jne browser_pattern_14
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_11
cmp r3 90
jgt browser_char_13_11
add r3 32
label browser_char_13_11
cmp r3 104
jne browser_pattern_14
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_12
cmp r3 90
jgt browser_char_13_12
add r3 32
label browser_char_13_12
cmp r3 111
jne browser_pattern_14
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_13
cmp r3 90
jgt browser_char_13_13
add r3 32
label browser_char_13_13
cmp r3 111
jne browser_pattern_14
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_13_14
cmp r3 90
jgt browser_char_13_14
add r3 32
label browser_char_13_14
cmp r3 100
jne browser_pattern_14
jmp browser_open_found
label browser_pattern_14
mov r4 r9
sub r4 r8
cmp r4 21
jne browser_pattern_15
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_0
cmp r3 90
jgt browser_char_14_0
add r3 32
label browser_char_14_0
cmp r3 112
jne browser_pattern_15
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_1
cmp r3 90
jgt browser_char_14_1
add r3 32
label browser_char_14_1
cmp r3 108
jne browser_pattern_15
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_2
cmp r3 90
jgt browser_char_14_2
add r3 32
label browser_char_14_2
cmp r3 101
jne browser_pattern_15
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_3
cmp r3 90
jgt browser_char_14_3
add r3 32
label browser_char_14_3
cmp r3 97
jne browser_pattern_15
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_4
cmp r3 90
jgt browser_char_14_4
add r3 32
label browser_char_14_4
cmp r3 115
jne browser_pattern_15
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_5
cmp r3 90
jgt browser_char_14_5
add r3 32
label browser_char_14_5
cmp r3 101
jne browser_pattern_15
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_6
cmp r3 90
jgt browser_char_14_6
add r3 32
label browser_char_14_6
cmp r3 32
jne browser_pattern_15
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_7
cmp r3 90
jgt browser_char_14_7
add r3 32
label browser_char_14_7
cmp r3 111
jne browser_pattern_15
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_8
cmp r3 90
jgt browser_char_14_8
add r3 32
label browser_char_14_8
cmp r3 112
jne browser_pattern_15
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_9
cmp r3 90
jgt browser_char_14_9
add r3 32
label browser_char_14_9
cmp r3 101
jne browser_pattern_15
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_10
cmp r3 90
jgt browser_char_14_10
add r3 32
label browser_char_14_10
cmp r3 110
jne browser_pattern_15
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_11
cmp r3 90
jgt browser_char_14_11
add r3 32
label browser_char_14_11
cmp r3 32
jne browser_pattern_15
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_12
cmp r3 90
jgt browser_char_14_12
add r3 32
label browser_char_14_12
cmp r3 114
jne browser_pattern_15
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_13
cmp r3 90
jgt browser_char_14_13
add r3 32
label browser_char_14_13
cmp r3 111
jne browser_pattern_15
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_14
cmp r3 90
jgt browser_char_14_14
add r3 32
label browser_char_14_14
cmp r3 98
jne browser_pattern_15
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_15
cmp r3 90
jgt browser_char_14_15
add r3 32
label browser_char_14_15
cmp r3 105
jne browser_pattern_15
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_16
cmp r3 90
jgt browser_char_14_16
add r3 32
label browser_char_14_16
cmp r3 110
jne browser_pattern_15
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_17
cmp r3 90
jgt browser_char_14_17
add r3 32
label browser_char_14_17
cmp r3 104
jne browser_pattern_15
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_18
cmp r3 90
jgt browser_char_14_18
add r3 32
label browser_char_14_18
cmp r3 111
jne browser_pattern_15
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_19
cmp r3 90
jgt browser_char_14_19
add r3 32
label browser_char_14_19
cmp r3 111
jne browser_pattern_15
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_14_20
cmp r3 90
jgt browser_char_14_20
add r3 32
label browser_char_14_20
cmp r3 100
jne browser_pattern_15
jmp browser_open_found
label browser_pattern_15
mov r4 r9
sub r4 r8
cmp r4 25
jne browser_pattern_16
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_0
cmp r3 90
jgt browser_char_15_0
add r3 32
label browser_char_15_0
cmp r3 111
jne browser_pattern_16
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_1
cmp r3 90
jgt browser_char_15_1
add r3 32
label browser_char_15_1
cmp r3 112
jne browser_pattern_16
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_2
cmp r3 90
jgt browser_char_15_2
add r3 32
label browser_char_15_2
cmp r3 101
jne browser_pattern_16
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_3
cmp r3 90
jgt browser_char_15_3
add r3 32
label browser_char_15_3
cmp r3 110
jne browser_pattern_16
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_4
cmp r3 90
jgt browser_char_15_4
add r3 32
label browser_char_15_4
cmp r3 32
jne browser_pattern_16
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_5
cmp r3 90
jgt browser_char_15_5
add r3 32
label browser_char_15_5
cmp r3 114
jne browser_pattern_16
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_6
cmp r3 90
jgt browser_char_15_6
add r3 32
label browser_char_15_6
cmp r3 111
jne browser_pattern_16
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_7
cmp r3 90
jgt browser_char_15_7
add r3 32
label browser_char_15_7
cmp r3 98
jne browser_pattern_16
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_8
cmp r3 90
jgt browser_char_15_8
add r3 32
label browser_char_15_8
cmp r3 105
jne browser_pattern_16
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_9
cmp r3 90
jgt browser_char_15_9
add r3 32
label browser_char_15_9
cmp r3 110
jne browser_pattern_16
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_10
cmp r3 90
jgt browser_char_15_10
add r3 32
label browser_char_15_10
cmp r3 104
jne browser_pattern_16
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_11
cmp r3 90
jgt browser_char_15_11
add r3 32
label browser_char_15_11
cmp r3 111
jne browser_pattern_16
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_12
cmp r3 90
jgt browser_char_15_12
add r3 32
label browser_char_15_12
cmp r3 111
jne browser_pattern_16
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_13
cmp r3 90
jgt browser_char_15_13
add r3 32
label browser_char_15_13
cmp r3 100
jne browser_pattern_16
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_14
cmp r3 90
jgt browser_char_15_14
add r3 32
label browser_char_15_14
cmp r3 32
jne browser_pattern_16
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_15
cmp r3 90
jgt browser_char_15_15
add r3 32
label browser_char_15_15
cmp r3 105
jne browser_pattern_16
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_16
cmp r3 90
jgt browser_char_15_16
add r3 32
label browser_char_15_16
cmp r3 110
jne browser_pattern_16
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_17
cmp r3 90
jgt browser_char_15_17
add r3 32
label browser_char_15_17
cmp r3 32
jne browser_pattern_16
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_18
cmp r3 90
jgt browser_char_15_18
add r3 32
label browser_char_15_18
cmp r3 98
jne browser_pattern_16
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_19
cmp r3 90
jgt browser_char_15_19
add r3 32
label browser_char_15_19
cmp r3 114
jne browser_pattern_16
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_20
cmp r3 90
jgt browser_char_15_20
add r3 32
label browser_char_15_20
cmp r3 111
jne browser_pattern_16
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_21
cmp r3 90
jgt browser_char_15_21
add r3 32
label browser_char_15_21
cmp r3 119
jne browser_pattern_16
mov r7 r8
add r7 22
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_22
cmp r3 90
jgt browser_char_15_22
add r3 32
label browser_char_15_22
cmp r3 115
jne browser_pattern_16
mov r7 r8
add r7 23
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_23
cmp r3 90
jgt browser_char_15_23
add r3 32
label browser_char_15_23
cmp r3 101
jne browser_pattern_16
mov r7 r8
add r7 24
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_15_24
cmp r3 90
jgt browser_char_15_24
add r3 32
label browser_char_15_24
cmp r3 114
jne browser_pattern_16
jmp browser_open_found
label browser_pattern_16
mov r4 r9
sub r4 r8
cmp r4 29
jne browser_pattern_17
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_0
cmp r3 90
jgt browser_char_16_0
add r3 32
label browser_char_16_0
cmp r3 111
jne browser_pattern_17
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_1
cmp r3 90
jgt browser_char_16_1
add r3 32
label browser_char_16_1
cmp r3 112
jne browser_pattern_17
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_2
cmp r3 90
jgt browser_char_16_2
add r3 32
label browser_char_16_2
cmp r3 101
jne browser_pattern_17
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_3
cmp r3 90
jgt browser_char_16_3
add r3 32
label browser_char_16_3
cmp r3 110
jne browser_pattern_17
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_4
cmp r3 90
jgt browser_char_16_4
add r3 32
label browser_char_16_4
cmp r3 32
jne browser_pattern_17
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_5
cmp r3 90
jgt browser_char_16_5
add r3 32
label browser_char_16_5
cmp r3 114
jne browser_pattern_17
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_6
cmp r3 90
jgt browser_char_16_6
add r3 32
label browser_char_16_6
cmp r3 111
jne browser_pattern_17
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_7
cmp r3 90
jgt browser_char_16_7
add r3 32
label browser_char_16_7
cmp r3 98
jne browser_pattern_17
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_8
cmp r3 90
jgt browser_char_16_8
add r3 32
label browser_char_16_8
cmp r3 105
jne browser_pattern_17
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_9
cmp r3 90
jgt browser_char_16_9
add r3 32
label browser_char_16_9
cmp r3 110
jne browser_pattern_17
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_10
cmp r3 90
jgt browser_char_16_10
add r3 32
label browser_char_16_10
cmp r3 104
jne browser_pattern_17
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_11
cmp r3 90
jgt browser_char_16_11
add r3 32
label browser_char_16_11
cmp r3 111
jne browser_pattern_17
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_12
cmp r3 90
jgt browser_char_16_12
add r3 32
label browser_char_16_12
cmp r3 111
jne browser_pattern_17
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_13
cmp r3 90
jgt browser_char_16_13
add r3 32
label browser_char_16_13
cmp r3 100
jne browser_pattern_17
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_14
cmp r3 90
jgt browser_char_16_14
add r3 32
label browser_char_16_14
cmp r3 32
jne browser_pattern_17
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_15
cmp r3 90
jgt browser_char_16_15
add r3 32
label browser_char_16_15
cmp r3 105
jne browser_pattern_17
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_16
cmp r3 90
jgt browser_char_16_16
add r3 32
label browser_char_16_16
cmp r3 110
jne browser_pattern_17
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_17
cmp r3 90
jgt browser_char_16_17
add r3 32
label browser_char_16_17
cmp r3 32
jne browser_pattern_17
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_18
cmp r3 90
jgt browser_char_16_18
add r3 32
label browser_char_16_18
cmp r3 116
jne browser_pattern_17
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_19
cmp r3 90
jgt browser_char_16_19
add r3 32
label browser_char_16_19
cmp r3 104
jne browser_pattern_17
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_20
cmp r3 90
jgt browser_char_16_20
add r3 32
label browser_char_16_20
cmp r3 101
jne browser_pattern_17
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_21
cmp r3 90
jgt browser_char_16_21
add r3 32
label browser_char_16_21
cmp r3 32
jne browser_pattern_17
mov r7 r8
add r7 22
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_22
cmp r3 90
jgt browser_char_16_22
add r3 32
label browser_char_16_22
cmp r3 98
jne browser_pattern_17
mov r7 r8
add r7 23
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_23
cmp r3 90
jgt browser_char_16_23
add r3 32
label browser_char_16_23
cmp r3 114
jne browser_pattern_17
mov r7 r8
add r7 24
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_24
cmp r3 90
jgt browser_char_16_24
add r3 32
label browser_char_16_24
cmp r3 111
jne browser_pattern_17
mov r7 r8
add r7 25
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_25
cmp r3 90
jgt browser_char_16_25
add r3 32
label browser_char_16_25
cmp r3 119
jne browser_pattern_17
mov r7 r8
add r7 26
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_26
cmp r3 90
jgt browser_char_16_26
add r3 32
label browser_char_16_26
cmp r3 115
jne browser_pattern_17
mov r7 r8
add r7 27
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_27
cmp r3 90
jgt browser_char_16_27
add r3 32
label browser_char_16_27
cmp r3 101
jne browser_pattern_17
mov r7 r8
add r7 28
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_16_28
cmp r3 90
jgt browser_char_16_28
add r3 32
label browser_char_16_28
cmp r3 114
jne browser_pattern_17
jmp browser_open_found
label browser_pattern_17
mov r4 r9
sub r4 r8
cmp r4 22
jne browser_pattern_18
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_0
cmp r3 90
jgt browser_char_17_0
add r3 32
label browser_char_17_0
cmp r3 111
jne browser_pattern_18
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_1
cmp r3 90
jgt browser_char_17_1
add r3 32
label browser_char_17_1
cmp r3 112
jne browser_pattern_18
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_2
cmp r3 90
jgt browser_char_17_2
add r3 32
label browser_char_17_2
cmp r3 101
jne browser_pattern_18
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_3
cmp r3 90
jgt browser_char_17_3
add r3 32
label browser_char_17_3
cmp r3 110
jne browser_pattern_18
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_4
cmp r3 90
jgt browser_char_17_4
add r3 32
label browser_char_17_4
cmp r3 32
jne browser_pattern_18
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_5
cmp r3 90
jgt browser_char_17_5
add r3 32
label browser_char_17_5
cmp r3 114
jne browser_pattern_18
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_6
cmp r3 90
jgt browser_char_17_6
add r3 32
label browser_char_17_6
cmp r3 111
jne browser_pattern_18
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_7
cmp r3 90
jgt browser_char_17_7
add r3 32
label browser_char_17_7
cmp r3 98
jne browser_pattern_18
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_8
cmp r3 90
jgt browser_char_17_8
add r3 32
label browser_char_17_8
cmp r3 105
jne browser_pattern_18
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_9
cmp r3 90
jgt browser_char_17_9
add r3 32
label browser_char_17_9
cmp r3 110
jne browser_pattern_18
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_10
cmp r3 90
jgt browser_char_17_10
add r3 32
label browser_char_17_10
cmp r3 104
jne browser_pattern_18
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_11
cmp r3 90
jgt browser_char_17_11
add r3 32
label browser_char_17_11
cmp r3 111
jne browser_pattern_18
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_12
cmp r3 90
jgt browser_char_17_12
add r3 32
label browser_char_17_12
cmp r3 111
jne browser_pattern_18
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_13
cmp r3 90
jgt browser_char_17_13
add r3 32
label browser_char_17_13
cmp r3 100
jne browser_pattern_18
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_14
cmp r3 90
jgt browser_char_17_14
add r3 32
label browser_char_17_14
cmp r3 32
jne browser_pattern_18
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_15
cmp r3 90
jgt browser_char_17_15
add r3 32
label browser_char_17_15
cmp r3 119
jne browser_pattern_18
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_16
cmp r3 90
jgt browser_char_17_16
add r3 32
label browser_char_17_16
cmp r3 101
jne browser_pattern_18
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_17
cmp r3 90
jgt browser_char_17_17
add r3 32
label browser_char_17_17
cmp r3 98
jne browser_pattern_18
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_18
cmp r3 90
jgt browser_char_17_18
add r3 32
label browser_char_17_18
cmp r3 115
jne browser_pattern_18
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_19
cmp r3 90
jgt browser_char_17_19
add r3 32
label browser_char_17_19
cmp r3 105
jne browser_pattern_18
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_20
cmp r3 90
jgt browser_char_17_20
add r3 32
label browser_char_17_20
cmp r3 116
jne browser_pattern_18
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_17_21
cmp r3 90
jgt browser_char_17_21
add r3 32
label browser_char_17_21
cmp r3 101
jne browser_pattern_18
jmp browser_open_found
label browser_pattern_18
mov r4 r9
sub r4 r8
cmp r4 26
jne no_browser_command
mov r7 r8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_0
cmp r3 90
jgt browser_char_18_0
add r3 32
label browser_char_18_0
cmp r3 111
jne no_browser_command
mov r7 r8
add r7 1
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_1
cmp r3 90
jgt browser_char_18_1
add r3 32
label browser_char_18_1
cmp r3 112
jne no_browser_command
mov r7 r8
add r7 2
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_2
cmp r3 90
jgt browser_char_18_2
add r3 32
label browser_char_18_2
cmp r3 101
jne no_browser_command
mov r7 r8
add r7 3
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_3
cmp r3 90
jgt browser_char_18_3
add r3 32
label browser_char_18_3
cmp r3 110
jne no_browser_command
mov r7 r8
add r7 4
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_4
cmp r3 90
jgt browser_char_18_4
add r3 32
label browser_char_18_4
cmp r3 32
jne no_browser_command
mov r7 r8
add r7 5
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_5
cmp r3 90
jgt browser_char_18_5
add r3 32
label browser_char_18_5
cmp r3 116
jne no_browser_command
mov r7 r8
add r7 6
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_6
cmp r3 90
jgt browser_char_18_6
add r3 32
label browser_char_18_6
cmp r3 104
jne no_browser_command
mov r7 r8
add r7 7
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_7
cmp r3 90
jgt browser_char_18_7
add r3 32
label browser_char_18_7
cmp r3 101
jne no_browser_command
mov r7 r8
add r7 8
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_8
cmp r3 90
jgt browser_char_18_8
add r3 32
label browser_char_18_8
cmp r3 32
jne no_browser_command
mov r7 r8
add r7 9
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_9
cmp r3 90
jgt browser_char_18_9
add r3 32
label browser_char_18_9
cmp r3 114
jne no_browser_command
mov r7 r8
add r7 10
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_10
cmp r3 90
jgt browser_char_18_10
add r3 32
label browser_char_18_10
cmp r3 111
jne no_browser_command
mov r7 r8
add r7 11
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_11
cmp r3 90
jgt browser_char_18_11
add r3 32
label browser_char_18_11
cmp r3 98
jne no_browser_command
mov r7 r8
add r7 12
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_12
cmp r3 90
jgt browser_char_18_12
add r3 32
label browser_char_18_12
cmp r3 105
jne no_browser_command
mov r7 r8
add r7 13
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_13
cmp r3 90
jgt browser_char_18_13
add r3 32
label browser_char_18_13
cmp r3 110
jne no_browser_command
mov r7 r8
add r7 14
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_14
cmp r3 90
jgt browser_char_18_14
add r3 32
label browser_char_18_14
cmp r3 104
jne no_browser_command
mov r7 r8
add r7 15
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_15
cmp r3 90
jgt browser_char_18_15
add r3 32
label browser_char_18_15
cmp r3 111
jne no_browser_command
mov r7 r8
add r7 16
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_16
cmp r3 90
jgt browser_char_18_16
add r3 32
label browser_char_18_16
cmp r3 111
jne no_browser_command
mov r7 r8
add r7 17
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_17
cmp r3 90
jgt browser_char_18_17
add r3 32
label browser_char_18_17
cmp r3 100
jne no_browser_command
mov r7 r8
add r7 18
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_18
cmp r3 90
jgt browser_char_18_18
add r3 32
label browser_char_18_18
cmp r3 32
jne no_browser_command
mov r7 r8
add r7 19
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_19
cmp r3 90
jgt browser_char_18_19
add r3 32
label browser_char_18_19
cmp r3 119
jne no_browser_command
mov r7 r8
add r7 20
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_20
cmp r3 90
jgt browser_char_18_20
add r3 32
label browser_char_18_20
cmp r3 101
jne no_browser_command
mov r7 r8
add r7 21
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_21
cmp r3 90
jgt browser_char_18_21
add r3 32
label browser_char_18_21
cmp r3 98
jne no_browser_command
mov r7 r8
add r7 22
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_22
cmp r3 90
jgt browser_char_18_22
add r3 32
label browser_char_18_22
cmp r3 115
jne no_browser_command
mov r7 r8
add r7 23
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_23
cmp r3 90
jgt browser_char_18_23
add r3 32
label browser_char_18_23
cmp r3 105
jne no_browser_command
mov r7 r8
add r7 24
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_24
cmp r3 90
jgt browser_char_18_24
add r3 32
label browser_char_18_24
cmp r3 116
jne no_browser_command
mov r7 r8
add r7 25
add r7 7400000000000000128
load8 r3 $r7
cmp r3 65
jlt browser_char_18_25
cmp r3 90
jgt browser_char_18_25
add r3 32
label browser_char_18_25
cmp r3 101
jne no_browser_command
jmp browser_open_found
label browser_open_found
store8 8200000000000000064 11
store8 8200000000000000065 11
store8 8200000000000000067 1
load8 r0 7400000000000000003
cmp r0 2
je browser_open_en
set r14 86
print r14
set r14 111
print r14
set r14 121
print r14
set r14 32
print r14
set r14 97
print r14
set r14 32
print r14
set r14 97
print r14
set r14 98
print r14
set r14 114
print r14
set r14 105
print r14
set r14 114
print r14
set r14 32
print r14
set r14 82
print r14
set r14 111
print r14
set r14 98
print r14
set r14 105
print r14
set r14 110
print r14
set r14 104
print r14
set r14 111
print r14
set r14 111
print r14
set r14 100
print r14
set r14 32
print r14
set r14 101
print r14
set r14 110
print r14
set r14 32
print r14
set r14 101
print r14
set r14 108
print r14
set r14 32
print r14
set r14 110
print r14
set r14 97
print r14
set r14 118
print r14
set r14 101
print r14
set r14 103
print r14
set r14 97
print r14
set r14 100
print r14
set r14 111
print r14
set r14 114
print r14
set r14 46
print r14
jmp browser_open_done
label browser_open_en
set r14 79
print r14
set r14 112
print r14
set r14 101
print r14
set r14 110
print r14
set r14 105
print r14
set r14 110
print r14
set r14 103
print r14
set r14 32
print r14
set r14 82
print r14
set r14 111
print r14
set r14 98
print r14
set r14 105
print r14
set r14 110
print r14
set r14 104
print r14
set r14 111
print r14
set r14 111
print r14
set r14 100
print r14
set r14 32
print r14
set r14 105
print r14
set r14 110
print r14
set r14 32
print r14
set r14 121
print r14
set r14 111
print r14
set r14 117
print r14
set r14 114
print r14
set r14 32
print r14
set r14 98
print r14
set r14 114
print r14
set r14 111
print r14
set r14 119
print r14
set r14 115
print r14
set r14 101
print r14
set r14 114
print r14
set r14 46
print r14
label browser_open_done
halt
label no_browser_command
halt
