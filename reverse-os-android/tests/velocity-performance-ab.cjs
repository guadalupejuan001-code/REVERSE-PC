#!/usr/bin/env node
'use strict';
// Same AVD, real APKs, real accelerator, and completed presentation counters.
// This is a free-running driving probe, not identical-pose replay or phone proof.
const cp=require('node:child_process'),fs=require('node:fs'),path=require('node:path');
const assert=require('node:assert/strict'),crypto=require('node:crypto');
assert(process.argv.length===8,
 'velocity-performance-ab.cjs ADB BASELINE_APK CANDIDATE_APK OUTPUT BASELINE_IDENTITY_JSON CANDIDATE_IDENTITY_JSON');
const [adb,before,after,out,beforeIdentity,afterIdentity]=process.argv.slice(2);
const tolerance=0.05,latencyTolerance=0.10,driveMilliseconds=24000;
fs.mkdirSync(out,{recursive:true});
const sleep=ms=>Atomics.wait(new Int32Array(new SharedArrayBuffer(4)),0,0,ms);
function execute(binary,args,timeout=30000){
 const r=cp.spawnSync(binary,args,{encoding:'utf8',timeout,maxBuffer:20*1024*1024});
 assert.ifError(r.error);assert.equal(r.status,0,String(r.stderr||r.stdout));return r.stdout;
}
function run(args,timeout){return execute(adb,args,timeout);}
function logs(){return run(['logcat','-d','-v','brief','ReverseVelocity:I','AndroidRuntime:E','*:S']);}
function fields(line){return Object.fromEntries([...line.matchAll(/\b(\w+)=(-?\d+(?:\.\d+)?|true|false)\b/g)]
 .map(m=>[m[1],m[2]==='true'?true:m[2]==='false'?false:Number(m[2])]));}
function median(values){
 assert(values.length>0&&values.every(Number.isFinite),'finite measurement samples required');
 const a=[...values].sort((x,y)=>x-y),i=Math.floor(a.length/2);
 return a.length%2?a[i]:(a[i-1]+a[i])/2;
}
function inspectApk(apk,metadataFile){
 const identity=JSON.parse(fs.readFileSync(metadataFile,'utf8'));
 const bytes=fs.readFileSync(apk),sha256=crypto.createHash('sha256').update(bytes).digest('hex');
 assert.equal(identity.apkSha256,sha256,'identity JSON must describe these exact APK bytes');
 assert.equal(identity.apkBytes,bytes.length,'APK byte count differs from identity evidence');
 const badging=execute(process.env.VELOCITY_AAPT||'aapt',['dump','badging',path.resolve(apk)]);
 const pkg=/^package: name='([^']+)' versionCode='(\d+)' versionName='([^']+)'/m.exec(badging);
 const launcher=/^launchable-activity: name='([^']+)'/m.exec(badging);
 assert(pkg&&launcher,'aapt must identify the actual package and launcher');
 assert.equal(pkg[1],identity.applicationId,'actual APK package differs from identity evidence');
 assert.equal(Number(pkg[2]),identity.versionCode,'actual APK versionCode differs');
 assert.equal(pkg[3],identity.versionName,'actual APK versionName differs');
 assert.equal(launcher[1],identity.launcher,'actual APK launcher differs');
 const signature=execute(process.env.VELOCITY_APKSIGNER||'apksigner',
  ['verify','--verbose','--print-certs',path.resolve(apk)]);
 assert.match(signature,/^Verifies\s*$/m,'APK signature must verify before any trial');
 assert.match(signature,/Number of signers: 1/,'unexpected APK signer count');
 const signer=/Signer #1 certificate SHA-256 digest:\s*([0-9a-f]{64})/i.exec(signature)?.[1].toLowerCase();
 assert.equal(signer,identity.signerCertificateSha256,'actual APK certificate differs from identity evidence');
 assert.match(identity.sourceCommit,/^[0-9a-f]{40}$/,'exact build source commit required');
 assert.match(identity.sourceHeadCommit,/^[0-9a-f]{40}$/,'exact source head commit required');
 return {apkFile:path.basename(apk),apkSha256:sha256,apkBytes:bytes.length,
  applicationId:pkg[1],versionCode:Number(pkg[2]),versionName:pkg[3],launcher:launcher[1],
  signerCertificateSha256:signer,sourceCommit:identity.sourceCommit,sourceHeadCommit:identity.sourceHeadCommit,
  sourceTree:identity.sourceTree||null,workflowRun:identity.workflowRun||null,
  dependencies:identity.dependencies||null,identityVerifiedFromApk:true};
}
function memory(pkg,name,round,phase){
 const text=run(['shell','dumpsys','meminfo',pkg]);
 fs.writeFileSync(path.join(out,name+'-'+round+'-'+phase+'-meminfo.txt'),text);
 const pss=/TOTAL PSS:\s*(\d+)/.exec(text)||/^\s*TOTAL\s+(\d+)/m.exec(text);
 assert(pss&&Number(pss[1])>0,'actual process PSS is required');
 return {phase,totalPssKiB:Number(pss[1])};
}
function summarize(rows,keys){
 return Object.fromEntries(keys.filter(k=>rows.some(x=>Number.isFinite(x[k])))
  .map(k=>[k,median(rows.map(x=>x[k]).filter(Number.isFinite))]));
}
function trial(name,apk,identity,round){
 const pkg=identity.applicationId;
 run(['shell','am','force-stop',pkg]);
 // Both C03 and C03R use the same verified signer/package. -d is needed when
 // an alternating trial installs the older debuggable C03 over the candidate.
 run(['install','-r','-d',path.resolve(apk)],60000);run(['logcat','-c']);
 run(['shell','am','start','-W','-n',pkg+'/'+identity.launcher]);
 let warmup='',ready=false;const deadline=Date.now()+60000;
 while(Date.now()<deadline){
  warmup=logs();assert(!/GPU_FALLBACK|Race worker failed|FATAL EXCEPTION/.test(warmup),'real APK failed during warm-up');
  if(/GPU_FRAME_READY .*width=960 height=540/.test(warmup)&&
     /GRAPHICS_FRAME preset=2 .*width=960 height=540 .*gpu=true/.test(warmup)){ready=true;break;}
  sleep(500);
 }
 assert(ready,'actual Medio GPU warm-up timed out');
 // Pixel diagnostics are opt-in in C03R. Normal gameplay must not perform a
 // full-frame readback; C03's old initial readback is outside the timed sample.
 if(name==='after')assert(!/GPU_PRESET_PIXELS/.test(warmup),'normal candidate launch unexpectedly reads back the entire framebuffer');
 assert(/GPU_C12_EXECUTED frames=[1-9][0-9]* /.test(warmup),'actual C12 execution is required before driving');
 assert(/QSSD_GPU_BRIDGE_ACTIVE .*route=REgraphics_QSSD_GLES/.test(warmup),'actual qSSD bridge is required before driving');
 fs.writeFileSync(path.join(out,name+'-'+round+'-warmup.log'),warmup);
 const memorySamples=[memory(pkg,name,round,'warm')];
 // R and W are actual game controls, not injected simulation state. Shift is
 // an unbound companion because Android keycombination expects two keys.
 run(['shell','input','keyevent','KEYCODE_R']);sleep(1000);run(['logcat','-c']);
 run(['shell','input','keycombination','-t',String(driveMilliseconds),'KEYCODE_W','KEYCODE_SHIFT_LEFT'],driveMilliseconds+8000);
 sleep(1200);memorySamples.push(memory(pkg,name,round,'after-driving'));
 const text=logs();run(['shell','am','force-stop',pkg]);
 fs.writeFileSync(path.join(out,name+'-'+round+'.log'),text);
 assert(!/GPU_FALLBACK|Race worker failed|FATAL EXCEPTION/.test(text),'APK failed during sustained driving');
 if(name==='after')assert(!/GPU_PRESET_PIXELS/.test(text),'candidate measured driving unexpectedly performs diagnostic framebuffer readback');
 const lines=text.split(/\r?\n/),active=[],pipeline=[];let movingWindow=false;
 for(const line of lines){
  if(line.includes('FRAME_STATS ')){
   const row=fields(line);movingWindow=!row.paused&&row.speed>0&&row.physicsHz>0;
   if(movingWindow)active.push(row);
  }else if(movingWindow&&line.includes('FRAME_PIPELINE mode=XI_STANDARD '))pipeline.push(fields(line));
 }
 assert(active.length>=3&&active.every(x=>x.width===960&&x.height===540&&x.preset===2),
  'both APKs must retain the same real Medio target during sustained driving');
 assert(active.at(-1).ticks>active[0].ticks&&active.at(-1).zCm>active[0].zCm,'accelerator must move the physical car');
 assert(pipeline.length>=3&&pipeline.every(x=>x.samples>0&&x.totalP95Ms>=x.totalP50Ms),
  'actual completed-frame timing quantiles are required');
 const frames=active.reduce((s,x)=>s+x.frames,0),nanos=active.reduce((s,x)=>s+x.elapsedNanos,0);
 assert(frames>0&&Number.isFinite(frames)&&nanos>0&&Number.isFinite(nanos),'actual completed frames and elapsed time are required');
 const records=marker=>lines.filter(l=>l.includes(marker)).map(fields);
 const gpu=records('GPU_PIPELINE '),physics=records('PHYSICS_STATS '),link=records('CPU_GPU_LINK ');
 const qssd=records('QSSD_LINK '),coordination=records('CPU_GPU_COORDINATION ');
 const c12=records('GPU_C12_EXECUTED '),renderBus=records('QSSD_RENDER_BUS ');
 assert(qssd.length>0&&qssd.every(x=>x.readOnly===true&&x.deltaReconstructions===0&&x.projectionBytes>0&&x.projectionBytes<=x.geometryBytes&&x.executions>0),
  'measured driving must use real bounded qSSD projections without delta reconstruction');
 assert(coordination.length>0&&coordination.every(x=>x.maxQueued===1&&x.queued<=1),'preparation must stay bounded');
 assert(c12.some(x=>x.frames>1&&x.steps>0),'C12 must continue executing during measured driving');
 assert(renderBus.length>0&&renderBus.every(x=>x.gpuUploadCommits>0),'qSSD must continue acknowledging uploads during measured driving');
 const result={name,round,applicationId:pkg,apkSha256:identity.apkSha256,activeWindows:active.length,
  frames,elapsedNanos:nanos,drawFps:frames*1e9/nanos,physicsHzMedian:median(active.map(x=>x.physicsHz)),
  width:960,height:540,driveMilliseconds,memorySamples,link,qssd,coordination,c12,renderBus,
  diagnosticPixelReadbackRequested:false,diagnosticPixelReadbackInWarmup:/GPU_PRESET_PIXELS/.test(warmup),
  diagnosticPixelReadbackInMeasuredDriving:/GPU_PRESET_PIXELS/.test(text),
  gpuVirtualResources:records('GPU_VIRTUAL_RESOURCES '),
  pipelineMedianOfWindowP50Ms:summarize(pipeline,['xiP50Ms','verifyP50Ms','presentP50Ms','totalP50Ms','setupP50Ms']),
  pipelineMedianOfWindowP95Ms:summarize(pipeline,['xiP95Ms','totalP95Ms','setupP95Ms']),
  maximumWindowTotalP95Ms:Math.max(...pipeline.map(x=>x.totalP95Ms)),
  timingScope:'medians of quantiles measured per completed-frame window; not a pooled all-frame p95 or GPU timestamps',
  gpuMedianOfWindowMeansMs:summarize(gpu,['queueMeanMs','commandsMeanMs','swapMeanMs']),
  physicsMedianOfWindowMeansMs:summarize(physics,['stepMeanMs','stepMaxMs']),frameStats:active,framePipeline:pipeline};
 console.log('VELOCITY_PERFORMANCE_TRIAL '+JSON.stringify({...result,frameStats:undefined,framePipeline:undefined}));
 return result;
}
const report={passed:false,emulator:null,physicalPhoneVerified:false,smoothnessVerified:false,
 functional:{passed:false},performance:{evaluated:false,gatePassed:false,toleranceFraction:tolerance},
 scope:'same AVD and actual Medio 960x540 target, alternating APK order; free-running driving states, not identical-pose replay, causal isolation or thermal-phone certification',
 deterministicEqualityScope:'separate host JNI/geometry/checkpoint and shader tests; this APK probe does not establish deterministic equality',
 sources:{},trials:[]};
try{
 report.sources.before=inspectApk(before,beforeIdentity);report.sources.after=inspectApk(after,afterIdentity);
 assert.equal(report.sources.before.applicationId,report.sources.after.applicationId,'C03 correction must retain the actual package');
 assert.equal(report.sources.before.signerCertificateSha256,report.sources.after.signerCertificateSha256,'C03 correction must retain the actual signer');
 assert(report.sources.after.versionCode>report.sources.before.versionCode,'candidate must be a real version upgrade');
 assert.notEqual(report.sources.before.apkSha256,report.sources.after.apkSha256,'baseline and candidate must be distinct artifacts');
 report.device={model:run(['shell','getprop','ro.product.model']).trim(),sdk:run(['shell','getprop','ro.build.version.sdk']).trim(),
  hardware:run(['shell','getprop','ro.hardware']).trim(),qemu:run(['shell','getprop','ro.kernel.qemu']).trim()};
 report.emulator=report.device.qemu==='1';
 for(let round=0;round<3;round++)for(const name of round%2?['after','before']:['before','after'])
  report.trials.push(trial(name,name==='before'?before:after,report.sources[name],round));
 const group=name=>report.trials.filter(t=>t.name===name);
 report.beforeMedianFps=median(group('before').map(x=>x.drawFps));
 report.afterMedianFps=median(group('after').map(x=>x.drawFps));
 report.medianFpsRatio=report.afterMedianFps/report.beforeMedianFps;
 for(const name of ['before','after']){
  const trials=group(name);
  report[name+'MedianPssKiB']=median(trials.map(x=>x.memorySamples.at(-1).totalPssKiB));
  report[name+'PhysicsHzMedian']=median(trials.map(x=>x.physicsHzMedian));
  report[name+'MedianOfTrialWindowP50Ms']=median(trials.map(x=>x.pipelineMedianOfWindowP50Ms.totalP50Ms));
  report[name+'MedianOfTrialWindowP95Ms']=median(trials.map(x=>x.pipelineMedianOfWindowP95Ms.totalP95Ms));
  report[name+'MaximumWindowP95Ms']=Math.max(...trials.map(x=>x.maximumWindowTotalP95Ms));
 }
 const fpsRegression=report.medianFpsRatio<1-tolerance;
 const p95Ratio=report.afterMedianOfTrialWindowP95Ms/report.beforeMedianOfTrialWindowP95Ms;
 assert(Number.isFinite(p95Ratio)&&p95Ratio>0,'finite positive frame-latency comparison required');
 const latencyRegression=p95Ratio>1+latencyTolerance;
 const regression=fpsRegression||latencyRegression,improvement=report.medianFpsRatio>1+tolerance;
 report.functional={passed:true,trialCount:report.trials.length,actualDriving:true,continuedC12AndQssd:true};
 report.performance={evaluated:true,gatePassed:!regression,toleranceFraction:tolerance,
  criterion:'candidate median completed-draw FPS must be at least 95% of C03; median of window p95 frame time must not exceed 110% of C03',
  status:regression?'regression':improvement?'improvement_observed':'inconclusive_within_tolerance',
  medianFpsRatio:report.medianFpsRatio,relativeChangePercent:(report.medianFpsRatio-1)*100,
  fpsRegression,latencyRegression,latencyToleranceFraction:latencyTolerance,
  medianOfWindowP95Ratio:p95Ratio,
  statisticalSignificanceEstablished:false,physicalPhoneVerified:false,
  uncertainty:'three alternating trials of freely evolving driving states on one emulator; FPS differences within 5% and p95 differences within 10% are inconclusive; not a stutter-free or phone certification'};
 report.functionalDrivingProbePassed=true;
 report.emulatorMedianAtLeast30Fps=report.afterMedianFps>=30;
 report.passed=report.functional.passed&&report.performance.gatePassed;
 console.log('VELOCITY_FUNCTIONAL_DRIVING_PASS '+JSON.stringify(report.functional));
 console.log('VELOCITY_PERFORMANCE_COMPARISON '+JSON.stringify(report.performance));
 if(regression){console.error('VELOCITY_PERFORMANCE_REGRESSION: FPS or p95 frame time exceeds its explicit regression tolerance');process.exitCode=1;}
}catch(error){
 report.error=String(error.stack||error);console.error(report.error);process.exitCode=1;
}finally{
 fs.writeFileSync(path.join(out,'performance-ab.json'),JSON.stringify(report,null,2)+'\n');
}
