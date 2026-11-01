#!/usr/bin/env node
'use strict';
// Same real Ether state, XI scene, device-host and executable flags. Compare
// whole XFB5 frames, never only triangle counts or displayed FPS.
const assert=require('node:assert/strict'),fs=require('node:fs'),os=require('node:os'),
  path=require('node:path'),cp=require('node:child_process'),crypto=require('node:crypto');
const baseline=path.resolve(process.argv[2]||'build/velocity/reverse_pc_baseline');
const candidate=path.resolve(process.argv[3]||'build/velocity/reverse_pc');
const reportPath=process.argv[4];
const root=path.resolve('reverse-os-android/app/src/main/assets/velocity');
const temp=fs.mkdtempSync(path.join(os.tmpdir(),'xi-spatial-ab-'));
const header='#!reverse-pc-machine-v1\n';
const hash=x=>crypto.createHash('sha256').update(x).digest('hex');
function run(cli,...args){
 const p=cp.spawnSync(cli,args,{encoding:null,timeout:45000,maxBuffer:16*1024*1024});
 assert.ifError(p.error);assert.equal(p.status,0,String(p.stderr));return p.stdout;
}
const median=a=>a.slice().sort((x,y)=>x-y)[Math.floor(a.length/2)];
try{
 const init=path.join(temp,'init.rvp'),world=path.join(temp,'world.rvp'),ready=path.join(temp,'ready.rvp');
 run(baseline,'init',init);run(baseline,'run',path.join(root,'world.xi'),init,world);
 const drive=fs.readFileSync(path.join(root,'drive.xi'),'utf8');
 const script=path.join(temp,'reset.xi');
 fs.writeFileSync(script,header+'store8 128 0\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 1\n'+drive.slice(header.length));
 run(baseline,'run',script,world,ready);
 const original=hash(fs.readFileSync(ready));
 const scene=fs.readFileSync(path.join(root,'render-native4k.xi'),'utf8');
 assert(scene.startsWith(header)&&scene.includes('meshbegin r0 r1 5 0'));
 const cases=[];
 for(let camera=0;camera<3;camera++){
  const program=path.join(temp,'4k-'+camera+'.xi');
  fs.writeFileSync(program,header+'store8 200 1\nstore8 201 '+camera+'\nstore8 202 0\n'+scene.slice(header.length));
  const results=[];
  for(const [label,cli] of [['reference',baseline],['candidate',candidate]]){
   let output;const durations=[];
   for(let n=0;n<5;n++){
    const begin=process.hrtime.bigint();
    output=run(cli,'run',program,ready,path.join(temp,label+'-'+camera+'.rvp'));
    if(n>0)durations.push(Number(process.hrtime.bigint()-begin)/1e6);
   }
   assert.equal(output.length,8294416,'must produce exact 4K XFB5 bytes');
   assert.equal(output.toString('ascii',0,4),'XFB5');
   results.push({label,sha256:hash(output),medianMs:median(durations),timesMs:durations});
  }
  assert.equal(results[0].sha256,results[1].sha256,
    'XI spatial kernel diverged from original 4K scene at camera '+camera);
  cases.push({camera,width:3840,height:2160,bytes:8294416,sha256:results[0].sha256,
    referenceMedianMs:results[0].medianMs,spatialMedianMs:results[1].medianMs,
    referenceTimesMs:results[0].timesMs,spatialTimesMs:results[1].timesMs});
 }
 assert.equal(hash(fs.readFileSync(ready)),original,'raster mutated authoritative Ether state');
 const report={passed:true,renderer:'XI MachineMeshRaster + Ether spatial candidates',
  opengl:false,identicalFrames:cases.length,unchangedEther:true,
  note:'paired host execution timings; NOT Android FPS and NOT an Android benchmark',cases};
 if(reportPath)fs.writeFileSync(reportPath,JSON.stringify(report,null,2)+'\n');
 console.log('XI_SPATIAL_REAL_SCENE_AB_PASS '+JSON.stringify(report));
}finally{fs.rmSync(temp,{recursive:true,force:true});}
