// Synthetic console tests only; no Android boot is performed here.
import test from 'node:test';
import assert from 'node:assert/strict';
import {analyzeGuestConsole} from '../tools/android_guest_outcome.mjs';
const signatures = [
 ['Kernel panic - not syncing: fixture', 'kernel_panic'],
 ['Attempted to kill init! exitcode=0x0000000b', 'kernel_panic'],
 ['init: InitFatalReboot: signal 6', 'init_fatal_reboot'],
 ['init: Failed to mount required partitions early ...', 'required_mount_failure'],
 ['init: Failed to mount /system: No such file or directory', 'system_mount_failure'],
 ['init: [libfs_avb] Invalid hash size: ', 'avb_invalid_size'],
 ['init: [libfs_avb] Failed to verify vbmeta digest', 'avb_digest_failure'],
 ["init: [libfs_avb] vbmeta digest error isn't allowed", 'avb_digest_failure'],
 ['Reboot failed -- System halted', 'reboot_failed_halt'],
];
for(const [message,signal] of signatures) {
 test('recognizes fatal/boot error '+signal+': '+message, () => {
   for(const prefix of ['', '[ 6176.388701][    T1] ', '\x1b[31m[ 6176.388701][    T1] ']) {
     const r=analyzeGuestConsole(prefix+message+'\r\n'+prefix+message+'\x1b[0m\r\n');
     assert.equal(r.guest_boot_failure,true);assert.ok(r.guest_failure_signals.includes(signal));
     assert.equal(new Set(r.guest_failure_signals).size,r.guest_failure_signals.length);
     assert.equal(r.android_boot_verified,false);
   }
 });
}
for(const message of ["reboot: Restarting system with command 'bootloader'",'reboot: Restarting system'])
 test('restart is interruption, not boot success: '+message, () => {
   const r=analyzeGuestConsole('[ 6.1][ T1] '+message);assert.equal(r.guest_reboot_requested,true);
   assert.equal(r.guest_boot_failure,false);assert.equal(r.android_boot_verified,false);
 });
for(const message of ['', 'init: starting service foo', 'init: __mount(...)=0: Success',
 'init: No InitFatalReboot observed', 'init: Reboot failed diagnostic handler installed',
 'init: [libfs_avb] verification passed'])
 test('does not invent failure or success from '+JSON.stringify(message), () => {
   const r=analyzeGuestConsole(message);assert.equal(r.guest_boot_failure,false);
   assert.equal(r.guest_reboot_requested,false);assert.equal(r.android_boot_verified,false);
 });
test('rejects non-text evidence',()=>{for(const value of [null,undefined,1,{},[]])assert.throws(()=>analyzeGuestConsole(value));});
