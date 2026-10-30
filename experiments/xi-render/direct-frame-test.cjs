#!/usr/bin/env node
'use strict';
// Same XI-authored geometry and XFS1 materializer; only transport differs.
// Primary times include CLI launch, RVPC2 load/save and host image composition.
const fs=require('node:fs'),path=require('node:path'),os=require('node:os');
const cp=require('node:child_process'),crypto=require('node:crypto');
const assert=require('node:assert/strict'),{performance}=require('node:perf_hooks');
const {fromXI,decode}=require('./frame-stream.cjs');
const xi=path.resolve(process.argv[2]||'build/xi-direct/reverse_pc');
const xrender=path.resolve(process.argv[3]||'build/xi-direct/xrender-oracle');
const evidence=path.resolve(process.argv[4]||'build/xi-direct/evidence');
fs.mkdirSync(evidence,{recursive:true});
const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'xi-direct-a-b-'));
const original='experiments/xi-render/span-frame.xi';
const direct='experiments/xi-render/span-direct.xi';
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const median=a=>a.slice().sort((a,b)=>a-b)[Math.floor(a.length/2)];
function run(exe,args,{binary=false,timeout=120000}={}){
 const t=performance.now();
 const p=cp.spawnSync(exe,args,{encoding:binary?null:'utf8',
   timeout,maxBuffer:24*1024*1024});
 const ms=performance.now()-t;
 if(p.status!==0||p.error)
   throw Error(exe+' '+args.join(' ')+' failed: '+p.status+' '+String(p.stderr).slice(-2400)+' '+p.error);
 return {data:p.stdout,ms};
}
function state(width,height){
 const input=path.join(tmp,'uninitialized-'+width+'.rvp'),
  ready=path.join(tmp,'ready-'+width+'.rvp'),
  config=path.join(tmp,'config-'+width+'.xi');
 const dims=[width&255,(width>>8)&255,height&255,(height>>8)&255];
 fs.writeFileSync(config,'#!reverse-pc-machine-v1\n'+dims.map((n,i)=>
   'store8 '+(200+i)+' '+n+'\n').join('')+'halt\n');
 run(xi,['init',input]);run(xi,['run',config,input,ready]);
 return ready;
}
function measure(which,width,height,initial,label,compiled){
 const output=path.join(tmp,which+'-'+width+'-'+label+'.rvp');
 const start=performance.now();
 const res=run(xi,['run',which==='json'?original:which==='rxe'?compiled:direct,initial,output],{binary:which!=='json'});
 const serialStart=performance.now();
 const wire=which==='json'?fromXI(res.data,width,height,1):res.data;
 const transportMs=performance.now()-serialStart;
 const decodeStart=performance.now();
 const image=decode(wire).pixels;
 const composeMs=performance.now()-decodeStart;
 return {ms:performance.now()-start,xiMs:res.ms,transportMs,composeMs,wire,image,
   transportBytes:which==='json'?Buffer.byteLength(res.data):res.data.length,
   finalStateHash:sha(fs.readFileSync(output))};
}
const sizes=[[96,48],[1280,720],[1920,1080],[3840,2160]];
const report={suite:'Direct XI XFS1 binary — controlled host benchmark',
 comparison:'same authored XI geometry, same input RVPC2, same output RVPC2, identical XFS1 bytes and compositor',
 caveats:'CLI timing is not the CPU graphics kernel, sustained FPS or device presentation; host benchmark only',
 environment:{node:process.version,arch:process.arch,platform:process.platform,cpu:os.cpus()[0]?.model},
 frames:[],pass:false};
try{
 const compiled=path.join(tmp,'direct.rxe');
 run(xi,['compile',direct,compiled,'DIRECT FRAME STREAM']);
 const repeats=5;
 for(const [w,h] of sizes){
  const initial=state(w,h);
  const json=measure('json',w,h,initial,'proof',compiled);
  const bin=measure('binary',w,h,initial,'proof',compiled);
  const rx=measure('rxe',w,h,initial,'proof',compiled);
  assert(bin.wire.equals(json.wire),'binary stream differs from original XI at '+w);
  assert(rx.wire.equals(json.wire),'compiled RXE output differs at '+w);
  assert(json.image.equals(bin.image),'geometry mismatch');
  assert(bin.finalStateHash===json.finalStateHash,'binary transport mutated RVPC2');
  const reference=run(xrender,[String(w),String(h),'binary'],{binary:true});
  assert(bin.image.equals(reference.data),'canonical X Render pixels differ at '+w);
  const row={width:w,height:h,pixels:w*h,spanCommands:decode(bin.wire).commands,
   binaryBytes:bin.wire.length,jsonBytes:json.transportBytes,frameHash:sha(bin.image),
   jsonMs:[],directMs:[],rxeMs:[],jsonXIOutputMs:[],directXIOutputMs:[],
   jsonAdapterMs:[],directAdapterMs:[]};
  const order=['binary','json','rxe','json','binary','rxe','binary','rxe','json',
               'rxe','binary','json','binary','json','rxe'];
  for(let i=0;i<repeats*3;i++){
   const which=order[i];
   const v=measure(which,w,h,initial,String(i),compiled);
   assert(v.wire.equals(json.wire),'non-determinism '+which+' at '+w);
   assert.equal(v.finalStateHash,json.finalStateHash,'RVPC2 changed '+which);
   const key=which==='json'?'jsonMs':which==='rxe'?'rxeMs':'directMs';
   row[key].push(Number(v.ms.toFixed(4)));
   if(which==='json'){
    row.jsonXIOutputMs.push(Number(v.xiMs.toFixed(4)));
    row.jsonAdapterMs.push(Number((v.transportMs+v.composeMs).toFixed(4)));
   }else if(which==='binary'){
    row.directXIOutputMs.push(Number(v.xiMs.toFixed(4)));
    row.directAdapterMs.push(Number((v.transportMs+v.composeMs).toFixed(4)));
   }
  }
  row.medianJsonMs=Number(median(row.jsonMs).toFixed(4));
  row.medianDirectMs=Number(median(row.directMs).toFixed(4));
  row.medianRXEMs=Number(median(row.rxeMs).toFixed(4));
  row.speedup=Number((row.medianJsonMs/row.medianDirectMs).toFixed(2));
  row.textReduction=Number((row.jsonBytes/row.binaryBytes).toFixed(2));
  row.medianJsonAdapterMs=Number(median(row.jsonAdapterMs).toFixed(4));
  row.medianDirectAdapterMs=Number(median(row.directAdapterMs).toFixed(4));
  report.frames.push(row);
  console.log('XI_DIRECT_XFS1_EXACT_OK',w,h,
    'json_bytes',row.jsonBytes,'binary_bytes',row.binaryBytes,
    'json_ms',row.medianJsonMs,'direct_ms',row.medianDirectMs,
    'speedup',row.speedup,'sha256',row.frameHash);
 }
 report.pass=true;
 fs.writeFileSync(path.join(evidence,'direct-frame-results.json'),JSON.stringify(report,null,2)+'\n');
 console.log('XI_DIRECT_XFS1_ALL_OK',JSON.stringify({pass:true,frames:report.frames.length,
   speedups:report.frames.map(r=>r.speedup)}));
}catch(e){
 report.error=String(e.stack||e);
 fs.writeFileSync(path.join(evidence,'direct-frame-failure.json'),JSON.stringify(report,null,2)+'\n');
 console.error(report.error);process.exitCode=1;
}finally{fs.rmSync(tmp,{recursive:true,force:true});}
