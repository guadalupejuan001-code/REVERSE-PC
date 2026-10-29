#!reverse-pc-machine-v1
# Browser launch acknowledgement is separate from W4u window-verification state.
load8 r0 8300000000000000080
cmp r0 1
je browser_reply_success
jmp browser_reply_failure
label browser_reply_success
load8 r0 7400000000000000003
cmp r0 2
je browser_success_en
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
set r14 115
print r14
set r14 101
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
set r14 195
print r14
set r14 179
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
jmp browser_reply_done
label browser_success_en
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
set r14 111
print r14
set r14 112
print r14
set r14 101
print r14
set r14 110
print r14
set r14 101
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
set r14 116
print r14
set r14 104
print r14
set r14 101
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
jmp browser_reply_done
label browser_reply_failure
load8 r0 7400000000000000003
cmp r0 2
je browser_failure_en
set r14 78
print r14
set r14 111
print r14
set r14 32
print r14
set r14 115
print r14
set r14 101
print r14
set r14 32
print r14
set r14 112
print r14
set r14 117
print r14
set r14 100
print r14
set r14 111
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
jmp browser_reply_done
label browser_failure_en
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
set r14 99
print r14
set r14 111
print r14
set r14 117
print r14
set r14 108
print r14
set r14 100
print r14
set r14 32
print r14
set r14 110
print r14
set r14 111
print r14
set r14 116
print r14
set r14 32
print r14
set r14 98
print r14
set r14 101
print r14
set r14 32
print r14
set r14 111
print r14
set r14 112
print r14
set r14 101
print r14
set r14 110
print r14
set r14 101
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
set r14 116
print r14
set r14 104
print r14
set r14 101
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
label browser_reply_done
store8 8300000000000000080 0
halt
