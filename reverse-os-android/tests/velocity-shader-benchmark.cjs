#!/usr/bin/env node
'use strict';
// Paired host-CLI benchmark of two XI sources on the same real game snapshot.
// No legacy renderer is bundled. Supply the exact pre-optimization source.
const fs=require('node:fs'),os=require('node:os'),path=require('node:path');
const cp=require('node:child_process'),assert=require('node:assert/strict');
const crypto=require('node:crypto'),{performance}=require('node:perf_hooks');
assert(process.argv.length>=5,'velocity-shader-benchmark.cjs CLI BEFORE_XI OUTPUT_JSON [AFTER_XI]');
const cli=path.resolve(process.argv[2]),before=path.resolve(process.argv[3]);
const output=path.resolve(process.argv[4]);
const assets=path.resolve('reverse-os-android/app/src/main/assets/velocity');
const after=path.resolve(process.argv[5]||path.join(assets,'render.xi'));
const sourceBytes={before:fs.readFileSync(before),after:fs.readFileSync(after)};
const header='#!reverse-pc-machine-v1\n';
const temp=fs.mkdtempSync(path.join(os.tmpdir(),'velocity-shader-benchmark-'));
const hash=data=>crypto.createHash('sha256').update(data).digest('hex');
const median=values=>[...values].sort((a,b)=>a-b)[values.length>>1];
const rounded=n=>+n.toFixed(3);
let sequence=0;
function run(args){
 const begin=performance.now();
 const child=cp.spawnSync(cli,args,{encoding:null,timeout:30000,maxBuffer:12*1024*1024});
 const elapsed=performance.now()-begin;
 assert.equal(child.status,0,String(child.stderr));assert(!child.error,String(child.error));
 return {bytes:child.stdout,ms:elapsed};
}
function program(source,prefix){
 assert(source.startsWith(header),'XI source header');
 return header+prefix+source.slice(header.length);
}
try{
 const initial=path.join(temp,'initial.rvp'),world=path.join(temp,'world.rvp');
 const ready=path.join(temp,'ready.rvp'),reset=path.join(temp,'reset.xi');
 run(['init',initial]);run(['run',path.join(assets,'world.xi'),initial,world]);
 fs.writeFileSync(reset,program(fs.readFileSync(path.join(assets,'drive.xi'),'utf8'),
  'store8 128 0\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 1\n'));
 run(['run',reset,world,ready]);
 const snapshotHash=hash(fs.readFileSync(ready)),cases=[];
 for(const stride of [4,1]){
  const programs={};
  for(const name of ['before','after']){
   programs[name]=path.join(temp,name+'-'+stride+'.xi');
   fs.writeFileSync(programs[name],program(sourceBytes[name].toString('utf8'),
    'store8 200 '+stride+'\nstore8 201 0\nstore8 202 0\n'));
  }
  const observe=name=>run(['run',programs[name],ready,path.join(temp,'frame-'+sequence+++'.rvp')]);
  const warmBefore=observe('before'),warmAfter=observe('after');
  assert(warmBefore.bytes.equals(warmAfter.bytes),'warmup images differ');
  assert.equal(warmBefore.bytes.toString('ascii',0,4),'XFS1');
  const samples={before:[],after:[]},pairs=[];
  for(let i=0;i<5;i++){
   const order=i%2?['after','before']:['before','after'];
   const result={};for(const name of order){result[name]=observe(name);samples[name].push(result[name].ms);}
   assert(result.before.bytes.equals(result.after.bytes),'paired XFS1 observations differ');
   assert(result.before.bytes.equals(warmBefore.bytes),'same-state observations changed');
   pairs.push({order,beforeMs:rounded(result.before.ms),afterMs:rounded(result.after.ms)});
  }
  const beforeMedian=median(samples.before),afterMedian=median(samples.after);
  cases.push({stride,camera:0,paint:0,width:1280,height:720,samplesPerSource:5,
   observationBytes:warmAfter.bytes.length,xfs1Sha256:hash(warmAfter.bytes),
   byteExactAllPairs:true,beforeMedianMs:rounded(beforeMedian),afterMedianMs:rounded(afterMedian),
   hostMedianSpeedup:rounded(beforeMedian/afterMedian),pairs});
 }
 assert.equal(hash(fs.readFileSync(ready)),snapshotHash,'benchmark mutated source snapshot');
 const report={passed:true,scope:'paired separate-process host CLI execution on the identical XI game state',
  timingIncludes:'process startup, source parse, XI execution, observation and snapshot write',
  optimization:'inline XI span emission instead of shared 46-way layer dispatch',
  beforeSourceSha256:hash(sourceBytes.before),afterSourceSha256:hash(sourceBytes.after),
  interpreterSha256:hash(fs.readFileSync(cli)),snapshotSha256:snapshotHash,
  warmupPerSourcePerStride:1,inputStateUnchanged:true,androidDeviceMeasured:false,cases};
 fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');
 console.log(JSON.stringify(report));
}finally{fs.rmSync(temp,{recursive:true,force:true});}
