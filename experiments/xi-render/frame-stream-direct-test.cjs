#!/usr/bin/env node
'use strict';
// No simulation: run the actual XI Machine and read its XFS1 binary stdout.
// Compare each byte to the previous XI JSON->XFS1 transport, then each
// materialized pixel to the original Mundo X EtherRenderEngine.
const fs=require('node:fs'),path=require('node:path'),os=require('node:os');
const cp=require('node:child_process'),crypto=require('node:crypto');
const assert=require('node:assert/strict'),{performance}=require('node:perf_hooks');
const {fromXI,decode}=require('./frame-stream.cjs');
const exe=path.resolve(process.argv[2]||'build/xi-render/reverse_pc');
const native=path.resolve(process.argv[3]||'build/xi-render/xrender-oracle');
const evidence=path.resolve(process.argv[4]||'build/xi-render/evidence');
const oldSource='experiments/xi-render/span-frame.xi';
const directSource='experiments/xi-render/span-frame-direct.xi';
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'xi-direct-xfs1-'));
fs.mkdirSync(evidence,{recursive:true});
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
const med=a=>a.slice().sort((a,b)=>a-b)[Math.floor(a.length/2)];
function run(bin,args,timeout=90000){
 const started=performance.now();
 const p=cp.spawnSync(bin,args,{timeout,maxBuffer:20*1024*1024});
 return {code:p.status,stdout:p.stdout||Buffer.alloc(0),stderr:String(p.stderr||''),
   error:p.error?String(p.error):'',elapsedMs:Number((performance.now()-started).toFixed(4))};
}
function success(r,label){
 assert.equal(r.code,0,label+' failed '+r.error+' '+r.stderr.slice(-1000));return r;
}
function setup(w,h){
 const fresh=path.join(dir,'fresh-'+w+'.rvp'),config=path.join(dir,'config-'+w+'.rvp');
 const source=path.join(dir,'config-'+w+'.xi');
 fs.writeFileSync(source,'#!reverse-pc-machine-v1\n'+
   [w&255,(w>>8)&255,h&255,(h>>8)&255].map((v,i)=>'store8 '+(200+i)+' '+v+'\n').join('')+'halt\n');
 success(run(exe,['init',fresh]),'init');
 success(run(exe,['run',source,fresh,config]),'configure');
 return config;
}
function reject(state,source,error,label){
 const script=path.join(dir,'invalid-'+label+'.xi'),destination=path.join(dir,'rollback-'+label+'.rvp');
 fs.writeFileSync(script,'#!reverse-pc-machine-v1\n'+source);
 const marker=Buffer.from('unchanged-on-error');
 fs.writeFileSync(destination,marker);
 const before=sha(fs.readFileSync(state));
 const got=run(exe,['run',script,state,destination],15000);
 assert.notEqual(got.code,0,'accepted invalid '+label);
 assert(got.stderr.includes(error),'unexpected error for '+label+': '+got.stderr);
 assert(fs.readFileSync(destination).equals(marker),'destination overwritten on '+label);
 assert.equal(sha(fs.readFileSync(state)),before,'source state changed on '+label);
}
const result={suite:'XI native XFS1 binary output',
 input:'identical XI triangle rules, identical RVPC2 states, no JSON in direct output',
 benchmark:'5 alternating CLI runs; includes runtime load/save and stdout; no GPU',
 machine:process.arch,node:process.version,platform:process.platform,
 frames:[],negativeCases:0,compiledRXE:false,passed:false};
try{
 for(const [w,h] of [[96,48],[1280,720],[1920,1080]]){
  const state=setup(w,h);
  const before=success(run(exe,['run',oldSource,state,path.join(dir,'first-old-'+w+'.rvp')]),'old XI');
  const expected=fromXI(before.stdout.toString('utf8'),w,h,1);
  const direct=success(run(exe,['run',directSource,state,path.join(dir,'first-direct-'+w+'.rvp')]),'direct XI');
  assert.equal(direct.stdout.toString('ascii',0,4),'XFS1','XI did not publish XFS1 bytes');
  assert(direct.stdout.equals(expected),'XI output differs from previous XFS1 transport bytes');
  const image=decode(direct.stdout);
  const oracle=success(run(native,[String(w),String(h),'binary']),'native X Render');
  assert(image.pixels.equals(oracle.stdout),'XI and Mundo X pixels differ');
  fs.writeFileSync(path.join(evidence,'xi-direct-'+w+'x'+h+'.xfs1'),direct.stdout);
  const record={width:w,height:h,pixels:w*h,spans:image.commands,
   textBytes:before.stdout.length,directBytes:direct.stdout.length,
   streamSHA256:sha(direct.stdout),imageSHA256:image.sha256,
   oldMs:[],directMs:[]};
  for(let i=0;i<5;i++){
   for(const variant of i%2?['direct','old']:['old','direct']){
    const output=success(run(exe,['run',variant==='direct'?directSource:oldSource,state,
      path.join(dir,variant+'-'+w+'-'+i+'.rvp')]),variant+' repeat');
    if(variant==='direct')assert(output.stdout.equals(expected),'direct binary is nondeterministic');
    else assert(fromXI(output.stdout.toString('utf8'),w,h,1).equals(expected),'old XI output changed');
    record[variant==='direct'?'directMs':'oldMs'].push(output.elapsedMs);
   }
  }
  record.oldMedianMs=med(record.oldMs);record.directMedianMs=med(record.directMs);
  record.speedup=Number((record.oldMedianMs/record.directMedianMs).toFixed(3));
  result.frames.push(record);
  console.log('XI_XFS1_DIRECT_EXACT_OK',w,h,'bytes',record.directBytes,
    'oldJson',record.textBytes,'oldMs',record.oldMedianMs,
    'directMs',record.directMedianMs,'speedup',record.speedup);
 }
 const state=setup(48,24);
 const failures=[
  ['frame_span 0 0 5 2 100\n','requires open frame','no_begin'],
  ['frame_end\n','requires open frame','no_end_begin'],
  ['frame_begin 0 24 1\nframe_end\n','invalid dimensions','zero_width'],
  ['frame_begin 8192 8192 1\nframe_end\n','pixel budget','huge_frame'],
  ['frame_begin 48 24 -1\nframe_end\n','invalid revision','negative_revision'],
  ['frame_begin 48 24 4294967296\nframe_end\n','invalid revision','revision_range'],
  ['frame_begin 48 24 1\nframe_span 0 0 48 2 100\nframe_end\n','invalid span','overflow_x'],
  ['frame_begin 48 24 1\nframe_span 24 0 10 2 100\nframe_end\n','invalid span','overflow_y'],
  ['frame_begin 48 24 1\nframe_span 0 0 10 4 100\nframe_end\n','invalid span','invalid_palette'],
  ['frame_begin 48 24 1\nframe_span 0 0 10 2 0\nframe_end\n','invalid span','zero_depth'],
  ['frame_begin 48 24 1\nframe_span 0 0 10 2 100\nhalt\n','missing frame_end','missing_end'],
  ['frame_begin 48 24 1\nprint r0\nframe_end\n','cannot mix with text','mixed_output'],
  ['print r0\nframe_begin 48 24 1\nframe_end\n','text output exists','text_first'],
  ['frame_begin 48 24 1\nframe_end\nprint r0\n','frame must end with halt','text_after'],
  ['frame_begin 48 24 1\nframe_begin 48 24 1\nframe_end\n','already open','nested'],
  ['store8 253 99\nframe_begin 48 24 1\nframe_span 0 0 48 2 100\nframe_end\n','invalid span','rollback']
 ];
 for(const [src,error,label] of failures){reject(state,src,error,label);result.negativeCases++;}
 const rxe=path.join(dir,'direct.rxe'),disassembled=path.join(dir,'disassembled.xi');
 success(run(exe,['compile',directSource,rxe,'XFS1 DIRECT XI']),'compile');
 success(run(exe,['disassemble',rxe,disassembled]),'disassemble');
 assert(fs.readFileSync(disassembled,'utf8').includes('frame_span'),'RXE removed frame_span');
 const fromRXE=success(run(exe,['run',rxe,setup(96,48),path.join(dir,'rxe-state.rvp')]),'run RXE');
 assert(fromRXE.stdout.equals(fs.readFileSync(path.join(evidence,'xi-direct-96x48.xfs1'))),'compiled RXE differs');
 result.compiledRXE=true;
 result.passed=true;
 fs.writeFileSync(path.join(evidence,'xi-direct-results.json'),JSON.stringify(result,null,2)+'\n');
 console.log('XI_XFS1_DIRECT_ALL_OK',JSON.stringify({passed:true,scenes:result.frames.length,
  rejected:result.negativeCases,compiledRXE:true,
  speedups:result.frames.map(f=>f.speedup)}));
}catch(error){
 result.error=String(error.stack||error);result.passed=false;
 fs.writeFileSync(path.join(evidence,'xi-direct-failure.json'),JSON.stringify(result,null,2)+'\n');
 console.error(result.error);process.exitCode=1;
}finally{fs.rmSync(dir,{recursive:true,force:true})}
