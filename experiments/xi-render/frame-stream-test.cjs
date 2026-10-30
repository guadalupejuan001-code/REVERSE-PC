#!/usr/bin/env node
'use strict';
const fs=require('node:fs'),os=require('node:os'),path=require('node:path'),cp=require('node:child_process');
const assert=require('node:assert/strict'),{performance}=require('node:perf_hooks');
const {fromXI,encode,decode}=require('./frame-stream.cjs');
const xi=path.resolve(process.argv[2]),native=path.resolve(process.argv[3]),out=path.resolve(process.argv[4]);
fs.mkdirSync(out,{recursive:true});
const temp=fs.mkdtempSync(path.join(os.tmpdir(),'xfs1-'));
function run(exe,args,binary=false){
 const start=performance.now();
 const p=cp.spawnSync(exe,args,{encoding:binary?null:'utf8',timeout:90000,maxBuffer:24*1024*1024});
 assert.equal(p.status,0,String(p.stderr).slice(-1600));
 return {out:p.stdout,ms:performance.now()-start};
}
function init(w,h){
 const state=path.join(temp,'state-'+w+'.rvp'),ready=path.join(temp,'ready-'+w+'.rvp'),src=path.join(temp,'config-'+w+'.xi');
 fs.writeFileSync(src,'#!reverse-pc-machine-v1\n'+
 [w&255,w>>8,h&255,h>>8].map((v,i)=>'store8 '+(200+i)+' '+v+'\n').join('')+'halt\n');
 run(xi,['init',state]);run(xi,['run',src,state,ready]);return ready;
}
const result={protocol:'XFS1',scenes:[],scope:'two triangles; host presentation adapter, not GPU'};
try{
 for(const [w,h] of [[96,48],[1280,720],[1920,1080]]){
  const state=init(w,h);
  const source=run(xi,['run','experiments/xi-render/span-frame.xi',state,path.join(temp,'out-'+w+'.rvp')]);
  const start=performance.now();
  const wire=fromXI(source.out,w,h,w),frame=decode(wire);
  const adapterMs=performance.now()-start;
  const reference=run(native,[String(w),String(h),'binary'],true);
  assert(frame.pixels.equals(reference.out),'image mismatch');
  const corrupted=Buffer.from(wire);corrupted.writeUInt16LE(w,22);
  assert.throws(()=>decode(corrupted),/invalid span/);
  const rev=Buffer.from(wire);rev.writeUInt32LE(w+1,rev.length-4);
  assert.throws(()=>decode(rev),/frame end/);
  fs.writeFileSync(path.join(out,'xfs1-'+w+'x'+h+'.bin'),wire);
  result.scenes.push({width:w,height:h,pixels:w*h,commands:frame.commands,streamBytes:wire.length,
   xiMs:Number(source.ms.toFixed(3)),adapterMs:Number(adapterMs.toFixed(3)),
   nativeMs:Number(reference.ms.toFixed(3)),sha256:frame.sha256});
  console.log('XI_FRAME_STREAM_EXACT_OK',w,h,frame.commands,wire.length,frame.sha256);
 }
 assert.throws(()=>encode({width:8192,height:8192,revision:1,commands:[]}),/pixel budget/);
 result.passed=true;
 fs.writeFileSync(path.join(out,'frame-stream-results.json'),JSON.stringify(result,null,2)+'\n');
 console.log('XI_FRAME_STREAM_V1_OK',JSON.stringify({passed:true,scenes:result.scenes.length}));
}catch(e){
 result.passed=false;result.error=String(e.stack||e);
 fs.writeFileSync(path.join(out,'frame-stream-failure.json'),JSON.stringify(result,null,2)+'\n');
 console.error(result.error);process.exitCode=1;
}finally{fs.rmSync(temp,{recursive:true,force:true})}
