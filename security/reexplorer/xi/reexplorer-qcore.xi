#!reverse-pc-machine-v1
# REexplorer Q-Core: original XI/Ether navigation policy. No BBY Q integration.
# Input 9100000000000000000: event (0 nav,1 TLS,2 threat,3 permission,
#   4 download,5 renderer,6 cross-origin,7 popup); +1 violations bitmask
#   (bit0 unsafe URL,bit1 local destination,bit2 unknown scheme); +2 mode
#   (0 general,1 financial).
# State +32 quarantine (latch), +33 denied navigations (saturating).
# Output +16 action (0 allow,2 block,3 quarantine) and +17 reason.
# The Android host enforces HTTPS/permissions regardless of XI output.
# This is deterministic minimal-state computation, NOT physical quantum crypto.
store8 9100000000000000016 2
store8 9100000000000000017 99
load8 r0 9100000000000000032
cmp r0 1
je qnav_locked
load8 r0 9100000000000000002
cmp r0 0
jlt qnav_invalid
cmp r0 1
jgt qnav_invalid
load8 r0 9100000000000000000
cmp r0 0
je qnav_url
cmp r0 1
je qnav_tls
cmp r0 2
je qnav_threat
cmp r0 3
je qnav_permission
cmp r0 4
je qnav_download
cmp r0 5
je qnav_renderer
cmp r0 6
je qnav_origin
cmp r0 7
je qnav_popup
jmp qnav_invalid

label qnav_url
load8 r1 9100000000000000001
cmp r1 0
jne qnav_denied_url
jmp qnav_allow

label qnav_origin
load8 r1 9100000000000000001
cmp r1 0
jne qnav_denied_url
store8 9100000000000000016 0
store8 9100000000000000017 7
jmp qnav_output

label qnav_denied_url
load8 r2 9100000000000000033
cmp r2 3
jge qnav_many_unsafe
add r2 1
store8 9100000000000000033 r2
cmp r2 3
jge qnav_many_unsafe
store8 9100000000000000016 2
store8 9100000000000000017 11
jmp qnav_output

label qnav_many_unsafe
store8 9100000000000000032 1
store8 9100000000000000016 3
store8 9100000000000000017 12
jmp qnav_output

label qnav_tls
store8 9100000000000000032 1
store8 9100000000000000016 3
store8 9100000000000000017 21
jmp qnav_output

label qnav_threat
store8 9100000000000000032 1
store8 9100000000000000016 3
store8 9100000000000000017 22
jmp qnav_output

label qnav_permission
store8 9100000000000000016 2
store8 9100000000000000017 31
jmp qnav_output

label qnav_download
store8 9100000000000000016 2
store8 9100000000000000017 41
jmp qnav_output

label qnav_renderer
store8 9100000000000000032 1
store8 9100000000000000016 3
store8 9100000000000000017 51
jmp qnav_output

label qnav_popup
store8 9100000000000000016 2
store8 9100000000000000017 71
jmp qnav_output

label qnav_allow
store8 9100000000000000016 0
store8 9100000000000000017 0
jmp qnav_output

label qnav_invalid
store8 9100000000000000016 2
store8 9100000000000000017 98
jmp qnav_output

label qnav_locked
store8 9100000000000000016 3
store8 9100000000000000017 90

label qnav_output
load8 r0 9100000000000000016
print r0
load8 r1 9100000000000000017
print r1
load8 r2 9100000000000000033
print r2
halt
