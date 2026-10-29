#!reverse-pc-machine-v1
# REexplorer native XI/Ether streaming text-view core. NOT full HTML/CSS/JS browser.
# Self-contained state on InverseMemory region 8755e15, completely separate from BBY Q.
# +0 command 1=chunk,2=status,3=reset; +1 payload length <=224; +128 payload;
# +4096 parser mode (0 text,1 tag,2 script,3 style,4 script close,5 style close)
# +4097..4099 total bytes; +4100..4102 visible; +4103..4104 tag count;
# +4105..4106 suppressed; +4107 tag prefix length; +4108 budget exceeded;
# +4120..4131 capped tag prefix. All response text appears in r14 only.
load8 r4 8755000000000000000
cmp r4 3
je rx_reset
cmp r4 2
je rx_restore
cmp r4 1
je rx_restore_chunk
div r0 0
label rx_restore_chunk
load8 r9 8755000000000000001
cmp r9 224
jgt rx_reject_oversize
cmp r9 0
jlt rx_reject_oversize
jmp rx_restore
label rx_reject_oversize
store8 8755000000000004108 1
jmp rx_restore
label rx_restore
load8 r0 8755000000000004097
load8 r15 8755000000000004098
mul r15 256
add r0 r15
load8 r15 8755000000000004099
mul r15 65536
add r0 r15
load8 r1 8755000000000004100
load8 r15 8755000000000004101
mul r15 256
add r1 r15
load8 r15 8755000000000004102
mul r15 65536
add r1 r15
load8 r2 8755000000000004103
load8 r15 8755000000000004104
mul r15 256
add r2 r15
load8 r3 8755000000000004105
load8 r15 8755000000000004106
mul r15 256
add r3 r15
load8 r12 8755000000000004096
load8 r6 8755000000000004107
load8 r13 8755000000000004108
cmp r4 1
jne rx_report
cmp r13 0
jne rx_report
set r5 0
label rx_loop
cmp r5 r9
jge rx_commit
cmp r0 1048576
jge rx_full
set r11 8755000000000000128
add r11 r5
load8 r7 $r11
add r0 1
cmp r12 0
je rx_text
cmp r12 1
je rx_tag
cmp r12 2
je rx_script
cmp r12 3
je rx_style
cmp r12 4
je rx_tag
cmp r12 5
je rx_tag
div r0 0
label rx_text
cmp r7 60
je rx_text_open_tag
cmp r7 10
je rx_space
cmp r7 13
je rx_space
cmp r7 9
je rx_space
cmp r7 32
jlt rx_skip_text_control
cmp r7 127
je rx_skip_text_control
mov r14 r7
print r14
add r1 1
jmp rx_next
label rx_space
set r14 32
print r14
add r1 1
jmp rx_next
label rx_skip_text_control
add r3 1
jmp rx_next
label rx_text_open_tag
set r12 1
set r6 0
add r2 1
add r3 1
jmp rx_next
label rx_script
cmp r7 60
je rx_script_open
add r3 1
jmp rx_next
label rx_script_open
set r12 4
set r6 0
add r2 1
add r3 1
jmp rx_next
label rx_style
cmp r7 60
je rx_style_open
add r3 1
jmp rx_next
label rx_style_open
set r12 5
set r6 0
add r2 1
add r3 1
jmp rx_next
label rx_tag
cmp r7 62
je rx_close_tag
cmp r6 12
jge rx_tag_skip_store
mov r8 r7
cmp r8 65
jlt rx_tag_lower_end
cmp r8 90
jgt rx_tag_lower_end
add r8 32
label rx_tag_lower_end
set r11 8755000000000004120
add r11 r6
store8 $r11 r8
add r6 1
label rx_tag_skip_store
add r3 1
jmp rx_next
label rx_close_tag
add r3 1
cmp r12 1
je rx_tag_normal
cmp r12 4
je rx_tag_script_end
cmp r12 5
je rx_tag_style_end
div r0 0
label rx_tag_normal
set r12 0
label rx_check_script
cmp r6 6
jlt rx_check_style
load8 r15 8755000000000004120
cmp r15 115
jne rx_check_style
load8 r15 8755000000000004121
cmp r15 99
jne rx_check_style
load8 r15 8755000000000004122
cmp r15 114
jne rx_check_style
load8 r15 8755000000000004123
cmp r15 105
jne rx_check_style
load8 r15 8755000000000004124
cmp r15 112
jne rx_check_style
load8 r15 8755000000000004125
cmp r15 116
jne rx_check_style
cmp r6 6
je rx_to_script
load8 r15 8755000000000004126
cmp r15 32
je rx_to_script
cmp r15 9
je rx_to_script
cmp r15 47
je rx_to_script
jmp rx_check_style
label rx_check_style
cmp r6 5
jlt rx_tag_end
load8 r15 8755000000000004120
cmp r15 115
jne rx_tag_end
load8 r15 8755000000000004121
cmp r15 116
jne rx_tag_end
load8 r15 8755000000000004122
cmp r15 121
jne rx_tag_end
load8 r15 8755000000000004123
cmp r15 108
jne rx_tag_end
load8 r15 8755000000000004124
cmp r15 101
jne rx_tag_end
cmp r6 5
je rx_to_style
load8 r15 8755000000000004125
cmp r15 32
je rx_to_style
cmp r15 9
je rx_to_style
cmp r15 47
je rx_to_style
jmp rx_tag_end
label rx_to_script
set r12 2
jmp rx_tag_end
label rx_to_style
set r12 3
jmp rx_tag_end
label rx_tag_script_end
label rx_check_end_script
cmp r6 7
jlt rx_back_script
load8 r15 8755000000000004120
cmp r15 47
jne rx_back_script
load8 r15 8755000000000004121
cmp r15 115
jne rx_back_script
load8 r15 8755000000000004122
cmp r15 99
jne rx_back_script
load8 r15 8755000000000004123
cmp r15 114
jne rx_back_script
load8 r15 8755000000000004124
cmp r15 105
jne rx_back_script
load8 r15 8755000000000004125
cmp r15 112
jne rx_back_script
load8 r15 8755000000000004126
cmp r15 116
jne rx_back_script
jmp rx_to_text
label rx_back_script
set r12 2
jmp rx_tag_end
label rx_tag_style_end
label rx_check_end_style
cmp r6 6
jlt rx_back_style
load8 r15 8755000000000004120
cmp r15 47
jne rx_back_style
load8 r15 8755000000000004121
cmp r15 115
jne rx_back_style
load8 r15 8755000000000004122
cmp r15 116
jne rx_back_style
load8 r15 8755000000000004123
cmp r15 121
jne rx_back_style
load8 r15 8755000000000004124
cmp r15 108
jne rx_back_style
load8 r15 8755000000000004125
cmp r15 101
jne rx_back_style
jmp rx_to_text
label rx_back_style
set r12 3
jmp rx_tag_end
label rx_to_text
set r12 0
jmp rx_tag_end
label rx_tag_end
set r6 0
jmp rx_next
label rx_next
add r5 1
jmp rx_loop
label rx_full
set r13 1
label rx_commit
store8 8755000000000004096 r12
store8 8755000000000004107 r6
store8 8755000000000004108 r13
mov r15 r0
mod r15 256
store8 8755000000000004097 r15
mov r15 r0
div r15 256
mod r15 256
store8 8755000000000004098 r15
mov r15 r0
div r15 65536
mod r15 256
store8 8755000000000004099 r15
mov r15 r1
mod r15 256
store8 8755000000000004100 r15
mov r15 r1
div r15 256
mod r15 256
store8 8755000000000004101 r15
mov r15 r1
div r15 65536
mod r15 256
store8 8755000000000004102 r15
mov r15 r2
mod r15 256
store8 8755000000000004103 r15
mov r15 r2
div r15 256
mod r15 256
store8 8755000000000004104 r15
mov r15 r3
mod r15 256
store8 8755000000000004105 r15
mov r15 r3
div r15 256
mod r15 256
store8 8755000000000004106 r15
label rx_report
print r0
print r1
print r2
print r3
print r12
print r13
halt
label rx_reset
store8 8755000000000004096 0
store8 8755000000000004097 0
store8 8755000000000004098 0
store8 8755000000000004099 0
store8 8755000000000004100 0
store8 8755000000000004101 0
store8 8755000000000004102 0
store8 8755000000000004103 0
store8 8755000000000004104 0
store8 8755000000000004105 0
store8 8755000000000004106 0
store8 8755000000000004107 0
store8 8755000000000004108 0
store8 8755000000000004109 0
store8 8755000000000004110 0
store8 8755000000000004111 0
store8 8755000000000004112 0
store8 8755000000000004113 0
store8 8755000000000004114 0
store8 8755000000000004115 0
store8 8755000000000004116 0
store8 8755000000000004117 0
store8 8755000000000004118 0
store8 8755000000000004119 0
store8 8755000000000004120 0
store8 8755000000000004121 0
store8 8755000000000004122 0
store8 8755000000000004123 0
store8 8755000000000004124 0
store8 8755000000000004125 0
store8 8755000000000004126 0
store8 8755000000000004127 0
store8 8755000000000004128 0
store8 8755000000000004129 0
store8 8755000000000004130 0
store8 8755000000000004131 0
set r0 0
set r1 0
set r2 0
set r3 0
set r12 0
set r13 0
jmp rx_report
