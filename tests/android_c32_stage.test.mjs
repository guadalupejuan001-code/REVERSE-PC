// Host-only synthetic fixtures. These are NOT Android runtime evidence.
import test from 'node:test';
import assert from 'node:assert/strict';
import {SOURCE_C31,evaluateC32} from '../tools/android_c32_stage.mjs';
function fixture(suffix=''){
 const sha='e'.repeat(64),n=SOURCE_C31.instructions+1000;
 const consolePrior="init: starting service 'derive_classpath'...\ninit: Command 'exec_start derive_classpath' action=post-fs-data took 95ms and succeeded\n";
 const sourceReport={checkpoint_sha256:SOURCE_C31.sha256,guest:{instructions:SOURCE_C31.instructions},console:consolePrior};
 const report={checkpoint_sha256:sha,initial_instructions:SOURCE_C31.instructions,advanced_instructions:1000,guest:{instructions:n},console:consolePrior+suffix};
 const result={checkpoint_sha256:sha,instructions:n,execution_progress_accepted:true,guest_boot_failure:false,guest_reboot_requested:false,guest_kernel_panic:false,guest_terminal_failure:false};
 const host={status:'process_completed',exit_code:0,trigger:null,forced_kill:false};
 const boundary={checkpoint_sha256:sha,instructions:n,clean_completed:true};
 const tasks=[{pid:1,task:'0xffff01',name:'init',state:0,exit_state:0,has_user_mm:true}];
 const kernel={status:'read_only_kernel_observation',checkpoint_sha256:sha,input_unchanged:true,instructions:n,tasks,task_count:1,current_task_details:{pid:1,task:'0xffff01',name:'init',verification:'process_list'},current_task:'0xffff01',current_pid:1};
 const frame={source_checkpoint_sha256:sha,cpu_instructions_executed:0,original_snapshot_unchanged:true,status:'no_scanout'};
 const framework={checkpoint_sha256:sha,instructions:n,framework_runtime_verified:false,sys_boot_completed_live:false,scanout_exported:false,ready_for_visual_review:false,android_display_content_verified:false,reasons:['live_process_missing:zygote64']};
 return {sourceContract:{source_commit:SOURCE_C31.commit,checkpoint_sha256:SOURCE_C31.sha256},sourceReport,
  sourceBoundary:{schema:'reverse-c27-sequence-boundary-v1',checkpoint_sha256:SOURCE_C31.sha256,instructions:SOURCE_C31.instructions,clean_completed:true},
  report,result,host,boundary,kernel,frame,framework,sourceAuthenticated:true};
}
test('launching a classpath service is NOT successful service completion',()=>{
 const r=evaluateC32(fixture());
 assert.equal(r.stage,'post_fs_data_continuing');
 assert.equal(r.derive_classpath_service_exit_zero_verified,false);
 assert.equal(r.total_instructions,SOURCE_C31.instructions+1000);
 assert.equal(r.android_display_content_verified,false);
});
test('completed classpath process is confirmed only by successful exit',()=>{
 const r=evaluateC32(fixture("[ 219.5] init: Service 'derive_classpath' (pid 552) exited with status 0 waiting took 2.7 seconds\n"));
 assert.equal(r.derive_classpath_service_exit_zero_verified,true);
 assert.equal(r.stage,'derive_classpath_completed');
});
test('nonzero classpath process exit is not completion',()=>{
 const r=evaluateC32(fixture("init: Service 'derive_classpath' (pid 552) exited with status 1 waiting took 2.7 seconds\n"));
 assert.equal(r.derive_classpath_service_exit_zero_verified,false);
 assert.equal(r.derive_classpath_service_nonzero_exit_observed,true);
 assert.equal(r.stage,'derive_classpath_failed');
});
test('unproven console difference does not assert a new classpath event',()=>{
 const x=fixture("init: Service 'derive_classpath' (pid 552) exited with status 0\n");
 x.report.console=x.report.console.slice(5);
 const r=evaluateC32(x);assert.equal(r.source_console_prefix_verified,false);
 assert.equal(r.derive_classpath_service_exit_zero_verified,false);
 assert.equal(r.stage,'console_delta_not_proven');
});
test('kernel userspace task liveness must be verified before listing framework processes',()=>{
 const x=fixture();x.kernel.tasks.push({pid:30,task:'0xffff30',name:'zygote64',state:8193,exit_state:0,has_user_mm:true},
 {pid:32,task:'0xffff32',name:'surfaceflinger',state:1,exit_state:32,has_user_mm:true});
 x.kernel.task_count=3;
 const r=evaluateC32(x);assert.deepEqual(r.live_framework_processes,['zygote64']);
 assert.equal(r.stage,'framework_processes_observed');
});
const invalid=[
 ['unauthenticated source',x=>x.sourceAuthenticated=false],
 ['source from another commit',x=>x.sourceContract.source_commit='0'.repeat(40)],
 ['source from wrong state',x=>x.sourceContract.checkpoint_sha256='0'.repeat(64)],
 ['source report mismatch',x=>x.sourceReport.guest.instructions++],
 ['uncompleted source',x=>x.sourceBoundary.clean_completed=false],
 ['no new instructions',x=>{x.report.guest.instructions=SOURCE_C31.instructions;x.report.advanced_instructions=0;x.result.instructions=SOURCE_C31.instructions;x.boundary.instructions=SOURCE_C31.instructions;}],
 ['new result mismatch',x=>x.result.checkpoint_sha256='0'.repeat(64)],
 ['false clean boundary',x=>x.boundary.clean_completed=false],
 ['CPU not accepted',x=>x.result.execution_progress_accepted=false],
 ['guest reboot',x=>x.result.guest_reboot_requested=true],
 ['guest failure',x=>x.result.guest_boot_failure=true],
 ['host killed',x=>x.host.trigger='host_watchdog'],
 ['nonzero host exit',x=>x.host.exit_code=2],
 ['mixed observer checkpoint',x=>x.kernel.checkpoint_sha256='0'.repeat(64)],
 ['observer mutates snapshot',x=>x.kernel.input_unchanged=false],
 ['frame from wrong state',x=>x.frame.source_checkpoint_sha256='0'.repeat(64)],
 ['frame mutates checkpoint',x=>x.frame.cpu_instructions_executed=1],
 ['framework from wrong snapshot',x=>x.framework.checkpoint_sha256='0'.repeat(64)],
 ['frame and framework disagree',x=>x.framework.scanout_exported=true]
];
for(const [name,mutate] of invalid)test('rejects '+name,()=>{
 const x=fixture();mutate(x);assert.throws(()=>evaluateC32(x));
});
