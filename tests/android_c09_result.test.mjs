import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {pin,classifyC09,verifyC08Source} from '../tools/android_c09_result.mjs';
assert.ok(process.env.C08_DIR,'C08_DIR must contain the downloaded real C08 artifact');
const root=process.env.C08_DIR,bytes=readFileSync(root+'/current.json'),source=JSON.parse(bytes);
const state=readFileSync(root+'/current.rvg'),ancestor=readFileSync(root+'/source-c07-report.json');
const fixture=()=>{const p=structuredClone(source);p.initial_instructions=pin.instructions;p.advanced_instructions=1;p.guest.instructions=pin.instructions+1;p.provenance.input_checkpoint_sha256=pin.checkpoint_sha256;p.stop_reason='instruction_budget';p.error='';p.console='';return p;};
test('real failed C08 is reviewed as a resumable source, not a successful boot',()=>assert.equal(verifyC08Source(state,bytes,ancestor).source_stop_reason,'architectural_stop'));
test('report corruption rejected',()=>assert.throws(()=>verifyC08Source(state,Buffer.concat([bytes,Buffer.from(' ')]),ancestor)));
test('checkpoint corruption rejected',()=>assert.throws(()=>verifyC08Source(Buffer.from('invalid'),bytes,ancestor)));
test('C07 ancestor corruption rejected',()=>assert.throws(()=>verifyC08Source(state,bytes,Buffer.concat([ancestor,Buffer.from(' ')]))));
test('synthetic clean continuation classification is not a real Android run',()=>{const r=classifyC09(fixture());assert.equal(r.clean_cycle,true);assert.equal(r.android_display_verified,false);});
for(const [name,change] of [
  ['count',p=>p.guest.instructions++],['source',p=>p.provenance.input_checkpoint_sha256='0'.repeat(64)],
  ['root',p=>p.verified_entry_checkpoint_sha256=pin.checkpoint_sha256],['kernel',p=>p.provenance.kernel_sha256='0'.repeat(64)],
  ['disk',p=>p.provenance.disk_bytes--],['RAM',p=>p.guest.logical_ram_bytes*=2],
  ['clock',p=>p.guest.counter_samples=0],['phase',p=>p.guest.counter_subtick=64],
  ['display claim',p=>p.provenance.android_display_verified=true]])
  test('rejects changed '+name,()=>{const p=fixture();change(p);assert.throws(()=>classifyC09(p));});
for(const reason of ['architectural_stop','host_interrupted','waiting_for_device_or_interrupt'])test('preserves but does not certify '+reason,()=>{const p=fixture();p.stop_reason=reason;assert.equal(classifyC09(p).clean_cycle,false);});
test('panic text prevents clean classification',()=>{const p=fixture();p.console='Kernel panic - not syncing';assert.equal(classifyC09(p).clean_cycle,false);});
