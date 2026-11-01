#!/usr/bin/env node
'use strict';
// Paired, exact XI scene comparison: same renderer, one vs up to four workers.
const assert=require('node:assert/strict');
const fs=require('node:fs'),os=require('node:os'),path=require('node:path');
const cp=require('node:child_process'),crypto=require('node:crypto');
const serial=path.resolve(process.argv[2]||'build/velocity/reverse_pc_serial');
const parallel=path.resolve(process.argv[3]||'build/velocity/reverse_pc');
const reportPath=process.argv[4];
const root=path.resolve('reverse-os-android/app/src/main/assets/velocity');
const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'regraphics-parallel-ab-'));
const header='#!reverse-pc-machine-v1\n';
const sha=data=>crypto.createHash('sha256').update(data).digest('hex');
const median=values=>values.slice().sort((a,b)=>a-b)[Math.floor(values.length/2)];
function run(cli,...args){
 const begin=process.hrtime.bigint();
 const p=cp.spawnSync(cli,args,{encoding:null,maxBuffer:16*1024*1024,timeout:45000});
 assert.ifError(p.error);assert.equal(p.status,0,String(p.stderr).slice(-2500));
 return {data:p.stdout,ms:Number(process.hrtime.bigint()-begin)/1e6};
}
try{
 const init=path.join(tmp,'initial.rvp'),world=path.join(tmp,'world.rvp'),ready=path.join(tmp,'ready.rvp');
 run(serial,'init',init);
 run(serial,'run',path.join(root,'world.xi'),init,world);
 const drive=fs.readFileSync(path.join(root,'drive.xi'),'utf8');
 assert(drive.startsWith(header));
 const reset=path.join(tmp,'reset.xi'),accelerate=path.join(tmp,'accelerate.xi');
 fs.writeFileSync(reset,header+'store8 128 0\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 1\n'+drive.slice(header.length));
 fs.writeFileSync(accelerate,header+'store8 128 1\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 0\n'+drive.slice(header.length));
 run(serial,'run',reset,world,ready);
 const moving=path.join(tmp,'moving.rvp');
 fs.copyFileSync(ready,moving);
 for(let tick=0;tick<220;tick++)
   run(serial,'run',accelerate,moving,moving);
 const scene=fs.readFileSync(path.join(root,'render-native4k.xi'),'utf8');
 assert(scene.startsWith(header)&&scene.includes('meshbegin r0 r1 5 0'));
 const cases=[];
 for(const [label,state] of [['stationary',ready],['moving',moving]]){
  const beforeStateHash=sha(fs.readFileSync(state));
  for(let camera=0;camera<3;camera++)for(const paint of [0,3]){
   const program=path.join(tmp,'scene.xi');
   fs.writeFileSync(program,header+'store8 200 1\nstore8 201 '+camera+
       '\nstore8 202 '+paint+'\n'+scene.slice(header.length));
   const measurements={};
   for(const [name,cli] of [['serial',serial],['parallel',parallel]]){
    const samples=[],hashes=[];
    for(let repetition=0;repetition<3;repetition++){
     const result=run(cli,'run',program,state,path.join(tmp,name+'-result.rvp'));
     assert.equal(result.data.length,8294416,'must be true 3840x2160 native frame');
     assert.equal(result.data.toString('ascii',0,4),'XFB5');
     samples.push(result.ms);hashes.push(sha(result.data));
    }
    assert(hashes.every(x=>x===hashes[0]),'XI frame changed across identical runs');
    measurements[name]={medianMs:median(samples.slice(1)),sha256:hashes[0]};
   }
   assert.equal(measurements.serial.sha256,measurements.parallel.sha256,
       'parallel raster modified a pixel at '+label+' camera '+camera+' paint '+paint);
   assert.equal(sha(fs.readFileSync(state)),beforeStateHash,'render modified Ether snapshot');
   cases.push({state:label,camera,paint,sha256:measurements.serial.sha256,
     serialMs:measurements.serial.medianMs,parallelMs:measurements.parallel.medianMs});
  }
 }
 const report={passed:true,scenes:cases.length,equalPixelBuffers:true,
   physicsStateUnchanged:true,renderer:'REgraphics XI native parallel strips',
   note:'Host process time; not device/GPU/display FPS. Faster runtime is not assumed in CI.',
   totalSerialMedianMs:cases.reduce((sum,x)=>sum+x.serialMs,0),
   totalParallelMedianMs:cases.reduce((sum,x)=>sum+x.parallelMs,0),cases};
 if(reportPath)fs.writeFileSync(reportPath,JSON.stringify(report,null,2)+'\n');
 console.log('XI_PARALLEL_REAL_SCENE_AB_PASS '+JSON.stringify(report));
}finally{fs.rmSync(tmp,{force:true,recursive:true});}
