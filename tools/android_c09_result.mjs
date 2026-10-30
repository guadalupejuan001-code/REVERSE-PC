// Host evidence only. No CPU transition, reconstructed state or emulated Android milestone.
import {readFileSync,writeFileSync,copyFileSync,statSync} from 'node:fs';
import {resolve,join} from 'node:path';
import {pathToFileURL} from 'node:url';
import {hash,C07_PIN} from './android_verified_c07_source.mjs';
import {bindC08Snapshot,classifyC08Report} from './android_c08_result.mjs';
import {auditGkiRvg} from './audit_gki_rvg.mjs';
export const pin=Object.freeze(JSON.parse(readFileSync(new URL('../experiments/android-c09-reviewed-c08.json',import.meta.url))));
const check=(ok,why)=>{if(!ok)throw Error('C09 evidence: '+why);};
const json=p=>JSON.parse(readFileSync(p));
export function verifyC08Source(state,report,originalC07){
  check(hash(report)===pin.report_sha256&&hash(state)===pin.checkpoint_sha256,'source bytes differ');
  check(hash(originalC07)===C07_PIN.report_sha256,'C07 provenance changed');
  const p=JSON.parse(report);const outcome=classifyC08Report(p,JSON.parse(originalC07));
  check(p.stop_reason==='architectural_stop'&&p.error===pin.rejected_error,'rejected boundary changed');
  check(p.guest.instructions===pin.instructions&&p.guest.pc===pin.pc&&p.guest.exception_level===0,'source CPU changed');
  bindC08Snapshot(state,p,{checkpoint_sha256:pin.checkpoint_sha256});
  const a=auditGkiRvg(state,pin.kernel_sha256,pin.checkpoint_sha256);
  check(a.external_disk_sha256===pin.disk_sha256&&a.external_disk_bytes===pin.disk_bytes,'disk identity changed');
  check(outcome.all_observed_loaded_modules.length===19,'source module count differs');
  return {source_checkpoint_sha256:pin.checkpoint_sha256,instructions:pin.instructions,pc:pin.pc,
    source_stop_reason:p.stop_reason,original_entry_root:pin.original_entry_checkpoint_sha256,
    loaded_modules:19,guest_execution_performed:false};
}
export function classifyC09(p){
  const g=p?.guest,v=p?.provenance;
  check(g&&v,'missing guest or provenance');
  check(p.initial_instructions===pin.instructions&&Number.isSafeInteger(p.advanced_instructions)&&p.advanced_instructions>=0&&
    p.advanced_instructions<=pin.instructions_budget&&g.instructions===pin.instructions+p.advanced_instructions,'instruction accounting changed');
  check(p.prior_user_instruction_verified===true&&p.first_user_instruction_verified===false&&
    p.verified_entry_checkpoint_sha256===pin.original_entry_checkpoint_sha256&&v.input_checkpoint_sha256===pin.checkpoint_sha256&&v.stop_after_init===false,'continuity root changed');
  for(const key of ['kernel_sha256','ramdisk_sha256','disk_sha256','disk_bytes'])check(v[key]===pin[key],'changed '+key);
  check(g.system_mode===true&&g.pci_bus===true&&g.logical_ram_bytes===134217728&&g.block_image_bytes===pin.disk_bytes&&[0,1].includes(g.exception_level),'machine profile changed');
  check(v.counter_latency===true&&v.timing_seed_origin==='checkpoint'&&v.counter_rate_origin==='checkpoint'&&
    v.timing_seed_sha256===pin.counter_seed_sha256&&v.counter_instructions_per_tick===64&&g.counter_instructions_per_tick===64&&
    Number.isSafeInteger(g.counter_samples)&&g.counter_samples>=pin.counter_samples&&Number.isSafeInteger(g.counter_subtick)&&g.counter_subtick>=0&&g.counter_subtick<64,'counter stream changed');
  check(typeof p.console==='string'&&Buffer.byteLength(p.console)<=4*1024*1024&&typeof p.error==='string','invalid UART/error');
  for(const key of ['android_services_verified','android_display_verified','native_android_games_verified'])check(v[key]===false,'unproved '+key);
  const panic=/Kernel panic - not syncing|Attempted to kill init!/.test(p.console);
  const clean=['instruction_budget','host_wall_budget'].includes(p.stop_reason)&&!p.error&&!panic&&!g.halted&&!g.waiting&&p.advanced_instructions>0;
  return {status:clean?'native_execution_progress':'saved_requires_diagnosis',checkpoint_sha256:p.checkpoint_sha256,
    source_checkpoint_sha256:pin.checkpoint_sha256,original_entry_checkpoint_sha256:pin.original_entry_checkpoint_sha256,
    instructions:g.instructions,advanced_instructions:p.advanced_instructions,pc:g.pc,exception_level:g.exception_level,
    stop_reason:p.stop_reason,error:p.error,clean_cycle:clean,prior_unsupported_instruction_passed:p.advanced_instructions>0,
    kernel_panic_observed:panic,android_services_verified:false,android_display_verified:false,native_android_games_verified:false};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
  try{
    const [mode,root]=process.argv.slice(2);check(process.argv.length===4,'expected verify-source|preserve directory');
    if(mode==='verify-source'){
      check(statSync(join(root,'current.rvg')).size<256*1024*1024&&statSync(join(root,'current.json')).size<=65536,'source size bound');
      console.log(JSON.stringify(verifyC08Source(readFileSync(join(root,'current.rvg')),readFileSync(join(root,'current.json')),readFileSync(join(root,'source-c07-report.json')))));
    }else{
      check(mode==='preserve','unknown mode');const ptr=json(join(root,'journal/latest.json'));
      check(/^generation-[1-9][0-9]*$/.test(ptr.generation),'unsafe journal generation');
      const dir=join(root,'journal',ptr.generation);check(statSync(join(dir,'checkpoint.rvg')).size<256*1024*1024&&statSync(join(dir,'report.json')).size<8*1024*1024,'output size bound');
      const p=json(join(dir,'report.json'));bindC08Snapshot(readFileSync(join(dir,'checkpoint.rvg')),p,ptr);
      copyFileSync(join(dir,'checkpoint.rvg'),join(root,'current.rvg'));copyFileSync(join(dir,'report.json'),join(root,'current.json'));
      const result=classifyC09(p);writeFileSync(join(root,'console.txt'),p.console);writeFileSync(join(root,'milestone.json'),JSON.stringify(result,null,2)+'\n');
      console.log(JSON.stringify(result));if(!result.clean_cycle)process.exitCode=2;
    }
  }catch(e){console.error(e.message);process.exitCode=1;}
}
