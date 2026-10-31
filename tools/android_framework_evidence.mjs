// Combine authenticated, read-only evidence from one exact Android checkpoint.
// Policy fixtures are not boot results. Exported pixels still need visual review.
import assert from 'node:assert/strict';
import {sha} from './android_c13_avb.mjs';
import {analyzeGuestConsole} from './android_guest_outcome.mjs';
const KERNEL='f722bdd809bfd3485917a564b053b8a6d4938408734091f420c3297a8e3b20c8';
export function evaluateFrameworkEvidence({checkpointSha,report,result,host,kernel,frame,ppm}){
 assert.match(checkpointSha,/^[0-9a-f]{64}$/);
 assert.equal(report.checkpoint_sha256,checkpointSha);assert.equal(result.checkpoint_sha256,checkpointSha);
 assert.equal(result.instructions,report.guest.instructions);
 assert.equal(kernel.status,'read_only_kernel_observation');assert.equal(kernel.checkpoint_sha256,checkpointSha);assert.equal(kernel.kernel_sha256,KERNEL);assert.equal(kernel.input_unchanged,true);
 assert.equal(kernel.instructions,report.guest.instructions);assert.equal(kernel.pc,report.guest.pc);assert.equal(kernel.ticks,String(report.guest.virtual_ticks));assert.equal(kernel.exceptions,String(report.guest.exceptions));
 assert.equal(frame.schema,'reverse-snapshot-scanout-v1');assert.equal(frame.source_checkpoint_sha256,checkpointSha);assert.equal(frame.cpu_instructions_executed,0);assert.equal(frame.original_snapshot_unchanged,true);
 const reasons=[],need=(ok,reason)=>{if(!ok)reasons.push(reason);};
 need(host.status==='process_completed'&&host.exit_code===0&&host.trigger===null&&!host.forced_kill&&host.checkpoint_bytes_modified_by_supervisor===false,'native_process_not_cleanly_completed');
 const outcome=analyzeGuestConsole(report.console);
 need(result.execution_progress_accepted===true&&!outcome.guest_boot_failure&&!outcome.guest_reboot_requested&&['guest_kernel_panic','guest_boot_failure','guest_terminal_failure','guest_reboot_requested'].every(key=>result[key]===false),'guest_progress_not_accepted');
 need(report.error===''&&['host_wall_budget','instruction_budget'].includes(report.stop_reason)&&!report.guest.halted&&!report.guest.waiting,'checkpoint_not_a_clean_budget');
 const security=kernel.live_kernel_security;
 need(security?.read_only===true&&security.btf_layout_verified===true&&security.selinux_initialized===true&&security.selinux_enforcing===true&&security.policy_present===true&&!security.read_error,'live_selinux_enforcement_unverified');
 const processEvidence=[];
 for(const name of ['init','zygote64','system_server','surfaceflinger']){
  const found=kernel.tasks.filter(t=>t.name===name&&(name!=='init'||t.pid===1));
  const alive=found.length===1&&found[0].exit_state===0&&found[0].has_user_mm===true&&[0,1,2].includes(found[0].state);
  need(alive,'live_process_missing:'+name);processEvidence.push({name,verified:alive,pid:alive?found[0].pid:null});
 }
 const p=kernel.live_boot_property,init=kernel.tasks.find(t=>t.pid===1);
 const validProperty=o=>o.status==='property_observed'&&o.name==='sys.boot_completed'&&o.value==='1'&&Number.isSafeInteger(o.serial)&&o.serial>=0&&o.serial<=0xffffffff&&!(o.serial&1)&&o.serial>>>24===1&&!(o.serial&0x10000)&&o.vma_shared===true&&o.live_pid1_mapping_verified===true&&/^\/dev\/__properties__\/u:object_r:[a-zA-Z0-9_]+:s0$/.test(o.file);
 need(p?.schema==='reverse-live-pid1-property-v1'&&p.read_only===true&&p.pid===1&&p.task===init?.task&&p.live_property_mapping_verified===true&&p.boot_completed_property_live===true&&p.ambiguous_property_values===false&&p.observations?.length>0&&p.observations.every(validProperty),'live_sys_boot_completed_unverified');
 let scanout=false;
 if(frame.status==='scanout_exported'){
  assert.equal(frame.instructions,report.guest.instructions);assert.equal(frame.pc,report.guest.pc);assert.equal(frame.frame_counter,report.guest.display_frame);
  assert.equal(frame.width,report.guest.display_width);assert.equal(frame.height,report.guest.display_height);assert.ok(frame.width>0&&frame.width<=1280&&frame.height>0&&frame.height<=1024);
  assert.ok(Buffer.isBuffer(ppm));const header=Buffer.from(`P6\n${frame.width} ${frame.height}\n255\n`);
  assert.equal(ppm.length,header.length+frame.width*frame.height*3);assert.ok(ppm.subarray(0,header.length).equals(header));assert.equal(sha(ppm),frame.ppm_sha256);assert.equal(sha(ppm.subarray(header.length)),frame.rgb_sha256);scanout=true;
 }else{assert.equal(frame.status,'no_scanout');assert.equal(ppm,undefined);}
 const framework=reasons.length===0;
 return {schema:'reverse-android-runtime-evidence-v1',checkpoint_sha256:checkpointSha,instructions:report.guest.instructions,framework_runtime_verified:framework,sys_boot_completed_live:!reasons.includes('live_sys_boot_completed_unverified'),selinux_enforcing_live:!reasons.includes('live_selinux_enforcement_unverified'),processes:processEvidence,reasons,scanout_exported:scanout,ready_for_visual_review:framework&&scanout,android_display_content_verified:false,original_snapshot_unchanged:true};
}
