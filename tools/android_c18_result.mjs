// Bind the clean C17 budget boundary to a new, unmodified native continuation.
import assert from 'node:assert/strict';
import {readFileSync as read,writeFileSync as write,copyFileSync as copy,statSync} from 'node:fs';
import {join,resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {verifyBinary,acceptsProgress} from './android_c15_result.mjs';
import {analyzeGuestConsole} from './android_guest_outcome.mjs';
import {sha,PIN} from './android_c13_avb.mjs';
export const INPUT_SHA='ff336b8dac31c8059259e8ae2fc9a043626f6f57a84f1061d56fed77c90e8a31';
export const REPORT_SHA='f3b13ca1e2b69fdafe223da565bfab069b53c2cff3d6d69c55f02526a5774407';
const RESULT_SHA='90f6844a6536d88bcd45ff13bf833ac4cc7e3076cd8bffa7e5a61b71e3521301';
const initial=1445008639,seed='78b0aeb569a7e87dc9e970bd1a46c57dfe3364c2f49f41cf688a57f0afa1b12f';
const bounded=(p,n)=>{assert.ok(statSync(p).size<=n,'Oversized evidence');return read(p);};
const json=p=>JSON.parse(bounded(p,8*1024*1024));
export function checkInputHashes(state,report,result){assert.equal(sha(state),INPUT_SHA);assert.equal(sha(report),REPORT_SHA);assert.equal(sha(result),RESULT_SHA);}
export function preflight(root){
 const state=bounded(join(root,'current.rvg'),256*1024*1024),report=bounded(join(root,'current.json'),131072),result=bounded(join(root,'result.json'),131072);
 checkInputHashes(state,report,result);const r=JSON.parse(report),prior=JSON.parse(result),a=verifyBinary(state,r,INPUT_SHA);
 assert.equal(r.guest.instructions,initial);assert.equal(r.guest.pc,'0xffffffc0804973c8');assert.equal(r.guest.exception_level,1);assert.equal(r.guest.halted,false);assert.equal(r.guest.waiting,false);
 assert.ok(['host_wall_budget','instruction_budget'].includes(r.stop_reason));assert.equal(r.error,'');assert.equal(prior.execution_progress_accepted,true);
 assert.equal(r.provenance.experiment,'c17-c16-minmax-continuation');assert.equal(r.provenance.input_checkpoint_sha256,'d2ef1f650948453e902122a7bcf6ddda577effb469c5c101a0eaec5f25394df5');assert.equal(r.provenance.original_state_modified,false);
 assert.equal(prior.checkpoint_sha256,INPUT_SHA);assert.equal(prior.c13_system_root_switched,true);assert.equal(prior.guest_terminal_failure,false);
 for(const target of ['/system','/vendor','/product','/system_ext','/odm','/vendor_dlkm','/odm_dlkm','/system_dlkm'])assert.ok(prior.c13_mounted_targets.includes(target));
 assert.ok(/audit: type=1404[^\r\n]*enforcing=1/.test(r.console),'SELinux enforcement missing');assert.ok(r.console.includes('init: init second stage started!'),'Second stage not verified');assert.ok(r.console.includes('/system/etc/selinux/plat_file_contexts'),'Source contexts missing');
 return {report:r,binary:a,selinux_policy_loaded_in_source:true,second_stage_init_verified_in_source:true,mounted_targets:prior.c13_mounted_targets,system_mount_evidence_source:'C13 run 41009073891 through pinned C14/C15/C16/C17 proof chain',source_boundary:'Clean host time budget after second-stage init',android_display_verified:false};
}
export function audit(source,root){
 const input=preflight(source),pointer=json(join(root,'journal/latest.json'));assert.match(pointer.generation,/^generation-[1-9][0-9]*$/);
 const dir=join(root,'journal',pointer.generation),state=bounded(join(dir,'checkpoint.rvg'),256*1024*1024),r=json(join(dir,'report.json')),v=r.provenance,digest=sha(state);
 assert.equal(digest,pointer.checkpoint_sha256);const a=verifyBinary(state,r,digest);
 assert.equal(a.immutable_image_sha256,input.binary.immutable_image_sha256);assert.equal(r.initial_instructions,initial);
 assert.equal(v.experiment,'c18-c17-continuous-budget-boot');assert.equal(v.input_checkpoint_sha256,INPUT_SHA);assert.equal(v.input_report_sha256,REPORT_SHA);
 assert.equal(v.snapshot_round_trip_verified,true);assert.equal(v.cycle_limit,3);assert.equal(v.original_state_modified,false);assert.equal(v.ram_profile_changed,false);assert.equal(v.timing_seed_sha256,seed);assert.equal(v.disk_sha256,PIN.diskSha);
 assert.equal(r.first_user_instruction_verified,false);assert.equal(r.prior_user_instruction_verified,false);assert.equal(r.verified_entry_checkpoint_sha256,'');
 const outcome=analyzeGuestConsole(r.console);
 const result={schema:'reverse-c18-result-v1',checkpoint_sha256:digest,input_checkpoint_sha256:INPUT_SHA,instructions:r.guest.instructions,advanced_instructions:r.advanced_instructions,total_advanced_since_c14:r.guest.instructions-910037410,pc:r.guest.pc,stop_reason:r.stop_reason,error:r.error,source_snapshot_round_trip_verified:true,execution_progress_accepted:acceptsProgress(r,outcome),...outcome,second_stage_init_verified:input.second_stage_init_verified_in_source,selinux_policy_loaded_in_source:input.selinux_policy_loaded_in_source,c13_mounted_targets:input.mounted_targets,c13_system_root_switched:true,system_mount_evidence_source:input.system_mount_evidence_source,android_framework_verified:false,android_display_verified:false,native_android_games_verified:false};
 copy(join(dir,'checkpoint.rvg'),join(root,'current.rvg'));copy(join(dir,'report.json'),join(root,'current.json'));write(join(root,'console-new.txt'),r.console);write(join(root,'result.json'),JSON.stringify(result,null,2)+'\n');return result;
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){try{
 const [mode,source,output]=process.argv.slice(2);assert.ok(source&&['preflight','audit'].includes(mode));
 if(mode==='preflight'){const {report,binary,...result}=preflight(source);console.log(JSON.stringify(result,null,2));}
 else{assert.ok(output);const result=audit(source,output);console.log(JSON.stringify(result,null,2));if(!result.execution_progress_accepted)process.exitCode=2;}
}catch(e){console.error(e.stack);process.exitCode=1;}}
