#!/usr/bin/env node
'use strict';
const fs=require('node:fs'),os=require('node:os'),path=require('node:path'),cp=require('node:child_process');
const assert=require('node:assert/strict'),{performance}=require('node:perf_hooks');
const {decode,fromXI}=require('./frame-stream.cjs');
const exe=path.resolve(process.argv[2]),out=path.resolve(process.argv[3]);
const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'xi-direct-xfs1-'));
fs.mkdirSync(out,{recursive:true});
function run(args,binary=false){
 const t=performance.now();
 const p=cp.spawnSync(exe,args,{encoding:binary?null:'utf8',timeout:90000,maxBuffer:24*1024*1024});
 return {status:p.status,stdout:p.stdout,stderr:String(p.stderr),ms:performance.now()-t};
}
function checked(args,binary=false){
 const p=run(args,binary);assert.equal(p.status,0,p.stderr.slice(-2000));return p;
}
const cases=[],source='experiments/xi-render/span-frame.xi',direct='experiments/xi-render/span-direct.xi';
try{
 for(const [w,h] of [[96,48],[1280,720],[1920,1080]]){
  const initial=path.join(tmp,'start-'+w+'.rvp'),ready=path.join(tmp,'ready-'+w+'.rvp'),
   config=path.join(tmp,'size-'+w+'.xi');
  fs.writeFileSync(config,'#!reverse-pc-machine-v1\n'+
   [w&255,w>>8,h&255,h>>8].map((v,i)=>'store8 '+(200+i)+' '+v+'\n').join('')+'halt\n');
  checked(['init',initial]);checked(['run',config,initial,ready]);
  const old=checked(['run',source,ready,path.join(tmp,'json-'+w+'.rvp')]);
  const baseline=fromXI(old.stdout,w,h,1);
  const directRun=checked(['run',direct,ready,path.join(tmp,'binary-'+w+'.rvp')],true);
  const binary=directRun.stdout;
  assert(binary.equals(baseline),'direct binary differs from XI JSON protocol at '+w);
  assert(decode(binary).pixels.equals(decode(baseline).pixels),'pixels changed');
  const measures=[];
  for(let k=0;k<3;k++){
   const t=checked(['run',direct,ready,path.join(tmp,'trial-'+w+'-'+k+'.rvp')],true);
   assert(t.stdout.equals(binary));measures.push(Number(t.ms.toFixed(3)));
  }
  const row={width:w,height:h,bytes:binary.length,commands:decode(binary).commands,
   directFirstMs:Number(directRun.ms.toFixed(3)),directRepeatMs:measures,
   jsonRunMs:Number(old.ms.toFixed(3)),sha256:decode(binary).sha256};
  cases.push(row);
  fs.writeFileSync(path.join(out,'xi-direct-'+w+'x'+h+'.xfs1'),binary);
  console.log('XI_DIRECT_BINARY_EXACT_OK',w,h,'bytes',binary.length,'firstMs',row.directFirstMs);
 }
 // Invalid span must fail without a published partial frame.
 const invalid=path.join(tmp,'invalid.xi'),initial=path.join(tmp,'invalid.rvp');
 fs.writeFileSync(invalid,'#!reverse-pc-machine-v1\nframebegin 64 32 1\nframespan 0 0 64 2 100\nframeend\nhalt\n');
 checked(['init',initial]);
 const bad=run(['run',invalid,initial,path.join(tmp,'bad.rvp')],true);
 assert.notEqual(bad.status,0);
 assert.equal(bad.stdout.length,0,'invalid stream leaked bytes');
 assert(!fs.existsSync(path.join(tmp,'bad.rvp')),'failed transaction saved state');
 // Material is the generic XFS1 u8 ID. The triangle decoder's private
 // two-color palette must not restrict the VM's transport vocabulary.
 const materialCases=[];
 for(const material of [0,255,-1,256]){
  const script=path.join(tmp,'material-'+material+'.xi');
  const destination=path.join(tmp,'material-'+material+'.rvp');
  fs.writeFileSync(script,'#!reverse-pc-machine-v1\nframebegin 64 32 1\n'+
   'framespan 0 0 63 '+material+' 100\nframeend\nhalt\n');
  const observed=run(['run',script,initial,destination],true);
  if(material>=0&&material<=255){
   assert.equal(observed.status,0,observed.stderr);
   assert.equal(observed.stdout.length,38,'one-span XFS1 frame length');
   assert.equal(observed.stdout.toString('ascii',0,4),'XFS1');
   assert.equal(observed.stdout[16],2);assert.equal(observed.stdout[17],material);
   assert.equal(observed.stdout.readUInt16LE(20),0);
   assert.equal(observed.stdout.readUInt16LE(22),63);
   assert.equal(observed.stdout[30],3);assert(fs.existsSync(destination));
  }else{
   assert.notEqual(observed.status,0,'out-of-range material accepted');
   assert.equal(observed.stdout.length,0,'invalid material leaked a partial frame');
   assert(!fs.existsSync(destination),'invalid material published state');
  }
  materialCases.push({material,accepted:material>=0&&material<=255});
 }
 fs.writeFileSync(path.join(out,'xi-direct-results.json'),JSON.stringify({passed:true,cases,invalidRejected:true,materialCases},null,2)+'\n');
 console.log('XI_DIRECT_BINARY_ALL_OK cases='+cases.length);
}catch(e){console.error(e.stack);process.exitCode=1;}
finally{fs.rmSync(tmp,{recursive:true,force:true});}
