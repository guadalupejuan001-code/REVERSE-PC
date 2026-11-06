#!/usr/bin/env node
'use strict';
// Operates two real APKs on the same running AVD. No state injection, fake
// frame counter, resolution override or screenshot-derived FPS measurement.
const cp=require('node:child_process'),fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
assert(process.argv.length===6,'velocity-performance-ab.cjs ADB BASELINE_APK CANDIDATE_APK OUTPUT');
const [adb,before,after,out]=process.argv.slice(2),pkg='com.reversepc.velocity';
fs.mkdirSync(out,{recursive:true});
const sleep=ms=>Atomics.wait(new Int32Array(new SharedArrayBuffer(4)),0,0,ms);
function run(args,timeout=30000){const r=cp.spawnSync(adb,args,{encoding:'utf8',timeout,maxBuffer:20*1024*1024});assert.ifError(r.error);assert.equal(r.status,0,String(r.stderr));return r.stdout;}
function logs(){return run(['logcat','-d','-v','brief','ReverseVelocity:I','AndroidRuntime:E','*:S']);}
function fields(line){return Object.fromEntries([...line.matchAll(/\b(\w+)=(-?\d+(?:\.\d+)?|true|false)\b/g)].map(m=>[m[1],m[2]==='true'?true:m[2]==='false'?false:Number(m[2])]));}
function memory(name,round,phase){
 const text=run(['shell','dumpsys','meminfo',pkg]);fs.writeFileSync(path.join(out,`${name}-${round}-${phase}-meminfo.txt`),text);
 const pss=/TOTAL PSS:\s*(\d+)/.exec(text)||/^\s*TOTAL\s+(\d+)/m.exec(text);
 return {phase,totalPssKiB:pss?Number(pss[1]):null};
}
const med=v=>{const a=[...v].sort((x,y)=>x-y);return a[Math.floor(a.length/2)];};
function trial(name,apk,round){
 run(['shell','am','force-stop',pkg]);run(['install','-r','-d',path.resolve(apk)],60000);run(['logcat','-c']);
 run(['shell','am','start','-W','-n',pkg+'/com.reversepc.os.VelocityActivity']);
 let ready=false;const deadline=Date.now()+60000;
 while(Date.now()<deadline){const l=logs();assert(!/GPU_FALLBACK|Race worker failed|FATAL EXCEPTION/.test(l),'real APK failed during warm-up');if(/GPU_FRAME_READY .*width=960 height=540/.test(l)&&/GPU_PRESET_PIXELS preset=2 .*pixels=518400/.test(l)){ready=true;break;}sleep(500);}
 assert(ready,'actual Medio GPU warm-up timed out');
 const memorySamples=[memory(name,round,'warm')];
 // Fullscreen education was dismissed by the preceding functional smoke.
 // R is the actual restart control, and W is the actual accelerator. Shift
 // is an unbound companion because Android keycombination expects two keys.
 run(['shell','input','keyevent','KEYCODE_R']);sleep(1000);run(['logcat','-c']);
 run(['shell','input','keycombination','-t','14000','KEYCODE_W','KEYCODE_SHIFT_LEFT'],22000);
 sleep(1200);memorySamples.push(memory(name,round,'after-driving'));const text=logs();run(['shell','am','force-stop',pkg]);
 fs.writeFileSync(path.join(out,name+'-'+round+'.log'),text);
 assert(!/GPU_FALLBACK|Race worker failed|FATAL EXCEPTION/.test(text),'APK failed during sustained driving');
 const records=text.split(/\r?\n/).filter(l=>l.includes('FRAME_STATS ')).map(fields);
 const active=records.filter(x=>!x.paused&&x.speed>0&&x.physicsHz>0);
 assert(active.length>=3&&active.every(x=>x.width===960&&x.height===540&&x.preset===2),'both APKs must retain the same Medio target and effects in sustained driving');
 assert(active.at(-1).ticks>active[0].ticks&&active.at(-1).zCm>active[0].zCm,'accelerator must move the physical car');
 const frames=active.reduce((s,x)=>s+x.frames,0),nanos=active.reduce((s,x)=>s+x.elapsedNanos,0);
 const pipeline=text.split(/\r?\n/).filter(l=>l.includes('FRAME_PIPELINE mode=XI_STANDARD ')).map(fields);
 const gpu=text.split(/\r?\n/).filter(l=>l.includes('GPU_PIPELINE ')).map(fields);
 const physics=text.split(/\r?\n/).filter(l=>l.includes('PHYSICS_STATS ')).map(fields);
 const summarize=(rows,keys)=>Object.fromEntries(keys.filter(k=>rows.some(x=>Number.isFinite(x[k]))).map(k=>[k,med(rows.map(x=>x[k]).filter(Number.isFinite))]));
 const link=text.split(/\r?\n/).filter(l=>l.includes('CPU_GPU_LINK ')).map(fields);
 const coordination=text.split(/\r?\n/).filter(l=>l.includes('CPU_GPU_COORDINATION ')).map(fields);
 if(name==='after'){
  assert(link.length>0&&link.at(-1).deltaFrames>0&&link.at(-1).wireBytes<link.at(-1).geometryBytes,'candidate must execute exact reduced transport');
  assert(coordination.length>0&&coordination.every(x=>x.maxQueued===1&&x.queued<=1),'candidate preparation must stay bounded');
 }
 const result={name,round,activeWindows:active.length,frames,elapsedNanos:nanos,drawFps:frames*1e9/nanos,physicsHzMedian:med(active.map(x=>x.physicsHz)),width:960,height:540,memorySamples,link,coordination,
  gpuVirtualResources:text.split(/\r?\n/).filter(l=>l.includes('GPU_VIRTUAL_RESOURCES ')).map(fields),
  pipelineMedianOfWindowP50Ms:summarize(pipeline,['xiP50Ms','verifyP50Ms','presentP50Ms','totalP50Ms','setupP50Ms']),
  gpuMedianOfWindowMeansMs:summarize(gpu,['queueMeanMs','commandsMeanMs','swapMeanMs']),
  physicsMedianOfWindowMeansMs:summarize(physics,['stepMeanMs','stepMaxMs']),frameStats:active};
 console.log('VELOCITY_PERFORMANCE_TRIAL '+JSON.stringify({...result,frameStats:undefined}));return result;
}
const report={passed:false,emulator:true,physicalPhoneVerified:false,scope:'same AVD, same Medio effects and real 960x540 target, alternating APK order; free-running physical states, not identical pose replay or thermal-phone certification',trials:[]};
try{
 for(let round=0;round<3;round++)for(const name of round%2?['after','before']:['before','after'])report.trials.push(trial(name,name==='before'?before:after,round));
 const group=name=>report.trials.filter(t=>t.name===name);
 report.beforeMedianFps=med(group('before').map(x=>x.drawFps));report.afterMedianFps=med(group('after').map(x=>x.drawFps));
 report.medianFpsRatio=report.afterMedianFps/report.beforeMedianFps;
 report.beforeMedianPssKiB=med(group('before').map(x=>x.memorySamples.at(-1).totalPssKiB));
 report.afterMedianPssKiB=med(group('after').map(x=>x.memorySamples.at(-1).totalPssKiB));
 report.beforePhysicsHzMedian=med(group('before').map(x=>x.physicsHzMedian));
 report.afterPhysicsHzMedian=med(group('after').map(x=>x.physicsHzMedian));
 report.functionalPerformanceProbePassed=true;report.smoothnessVerified=report.afterMedianFps>=30;
 report.passed=true;
 console.log('VELOCITY_PERFORMANCE_AB_PASS '+JSON.stringify({before:report.beforeMedianFps,after:report.afterMedianFps,ratio:report.medianFpsRatio,smoothnessVerified:report.smoothnessVerified}));
}finally{fs.writeFileSync(path.join(out,'performance-ab.json'),JSON.stringify(report,null,2)+'\n');}
