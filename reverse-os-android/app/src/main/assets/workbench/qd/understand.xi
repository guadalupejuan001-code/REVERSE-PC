#!reverse-pc-machine-v1
# ReverseCoding: Qd intent selector (original XI/Ether, never JS policy).
# Input at N=8430000000000000000: magic81,version1,words<=18,nums<=2,a,b;
# N+16+2*i: u16 normalized word hash, polynomial 31 modulo 65521.
# Output: status(0 accepted,1 unknown,2 numbers,3 ambiguous,4 negated,5 zero,6 invalid),op,a,b.
# Rules recognize a bounded vocabulary; unknown words cause abstention, not partial interpretation.
load8 r0 8430000000000000000
cmp r0 81
jne invalid
load8 r0 8430000000000000001
cmp r0 1
jne invalid
load8 r8 8430000000000000002
cmp r8 18
jgt invalid
load8 r0 8430000000000000003
cmp r0 2
jgt invalid
load8 r2 8430000000000000004
cmp r2 99
jgt invalid
load8 r3 8430000000000000005
cmp r3 99
jgt invalid
set r11 0
set r1 0
set r9 0
set r10 0
set r0 0
label word_scan
cmp r11 r8
jge scan_done
set r4 8430000000000000016
mov r5 r11
mul r5 2
add r4 r5
load8 r6 $r4
add r4 1
load8 r5 $r4
mul r5 256
add r6 r5
cmp r6 3744
je word_1
cmp r6 50657
je word_1
cmp r6 3748
je word_1
cmp r6 50782
je word_1
cmp r6 64162
je word_1
cmp r6 62323
je word_1
cmp r6 61187
je word_1
cmp r6 46187
je word_1
cmp r6 56094
je word_1
cmp r6 31439
je word_1
cmp r6 42350
je word_1
cmp r6 30896
je word_1
cmp r6 37030
je word_1
cmp r6 48730
je word_1
cmp r6 32759
je word_2
cmp r6 32828
je word_2
cmp r6 32763
je word_2
cmp r6 62203
je word_2
cmp r6 19291
je word_2
cmp r6 16084
je word_2
cmp r6 34432
je word_2
cmp r6 50511
je word_2
cmp r6 48719
je word_2
cmp r6 41128
je word_2
cmp r6 24473
je word_3
cmp r6 38046
je word_3
cmp r6 52107
je word_3
cmp r6 31324
je word_3
cmp r6 56316
je word_3
# 'por' alone is not an operation: it also appears in 'por favor'.
# Multiplication requires an explicit verb/product noun or 'times'.
cmp r6 27242
je word_3
cmp r6 27122
je word_3
cmp r6 52539
je word_3
cmp r6 54940
je word_4
cmp r6 65353
je word_4
cmp r6 48548
je word_4
cmp r6 24267
je word_4
cmp r6 11792
je word_4
cmp r6 65215
je word_4
cmp r6 33952
je word_4
cmp r6 15053
je word_4
cmp r6 32773
je word_5
cmp r6 37844
je word_5
cmp r6 60288
je word_5
cmp r6 42769
je word_5
cmp r6 34641
je word_5
cmp r6 44598
je word_5
cmp r6 3521
je word_6
cmp r6 48359
je word_6
cmp r6 10286
je word_6
cmp r6 9810
je word_6
cmp r6 43746
je word_6
cmp r6 48125
je filler_word
cmp r6 50527
je filler_word
cmp r6 59300
je filler_word
cmp r6 3737
je filler_word
cmp r6 50423
je filler_word
cmp r6 48992
je filler_word
cmp r6 7918
je filler_word
cmp r6 46800
je filler_word
cmp r6 3480
je filler_word
cmp r6 26348
je filler_word
cmp r6 45666
je filler_word
cmp r6 38179
je filler_word
cmp r6 43785
je filler_word
cmp r6 47029
je filler_word
cmp r6 3239
je filler_word
cmp r6 3445
je filler_word
cmp r6 41823
je filler_word
cmp r6 41389
je filler_word
cmp r6 3201
je filler_word
cmp r6 33818
je filler_word
cmp r6 3115
je filler_word
cmp r6 121
je filler_word
cmp r6 101
je filler_word
cmp r6 31206
je filler_word
cmp r6 97
je filler_word
cmp r6 3117
je filler_word
cmp r6 49280
je filler_word
cmp r6 3707
je filler_word
cmp r6 3365
je filler_word
cmp r6 41807
je filler_word
cmp r6 20748
je filler_word
cmp r6 58864
je filler_word
cmp r6 37552
je filler_word
cmp r6 32064
je filler_word
cmp r6 35785
je filler_word
cmp r6 54402
je filler_word
cmp r6 34792
je filler_word
cmp r6 24368
je filler_word
cmp r6 53304
je filler_word
cmp r6 9647
je filler_word
cmp r6 37211
je filler_word
cmp r6 48445
je filler_word
cmp r6 2283
je filler_word
cmp r6 59517
je filler_word
cmp r6 45215
je filler_word
cmp r6 18340
je filler_word
cmp r6 32721
je filler_word
cmp r6 52524
je filler_word
cmp r6 48910
je filler_word
cmp r6 39796
je filler_word
cmp r6 54412
je filler_word
cmp r6 48374
je filler_word
cmp r6 9342
je filler_word
cmp r6 34132
je filler_word
cmp r6 36920
je filler_word
cmp r6 10436
je filler_word
cmp r6 3211
je filler_word
cmp r6 46079
je filler_word
cmp r6 33169
je filler_word
cmp r6 77
je filler_word
cmp r6 26161
je filler_word
cmp r6 45662
je filler_word
cmp r6 50878
je filler_word
cmp r6 61831
je filler_word
cmp r6 3603
je filler_word
cmp r6 22114
je filler_word
add r0 1
jmp next_word
label filler_word
jmp next_word
label word_1
set r7 1
jmp compare_word
label word_2
set r7 2
jmp compare_word
label word_3
set r7 3
jmp compare_word
label word_4
set r7 4
jmp compare_word
label word_5
set r7 5
jmp compare_word
label word_6
set r10 1
jmp next_word
label compare_word
cmp r1 0
je accept_word
cmp r1 r7
jne conflicting_words
jmp next_word
label accept_word
mov r1 r7
jmp next_word
label conflicting_words
set r9 1
label next_word
add r11 1
jmp word_scan
label scan_done
cmp r10 0
jne negated
cmp r9 0
jne ambiguous
cmp r0 0
jne unknown
cmp r1 0
je unknown
load8 r4 8430000000000000003
cmp r4 2
jne incomplete
cmp r1 4
je check_zero
cmp r1 5
je check_zero
jmp accepted
label check_zero
cmp r3 0
je zero_divisor
label accepted
set r0 0
jmp emit
label unknown
set r0 1
jmp emit
label incomplete
set r0 2
jmp emit
label ambiguous
set r0 3
jmp emit
label negated
set r0 4
jmp emit
label zero_divisor
set r0 5
jmp emit
label invalid
set r0 6
set r1 0
set r2 0
set r3 0
label emit
print r0
mov r0 r1
print r0
mov r0 r2
print r0
mov r0 r3
print r0
halt
