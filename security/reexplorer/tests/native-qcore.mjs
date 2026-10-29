#!/usr/bin/env node
// Native REVERSE execution of the same XI program bundled in REexplorer.
// This examines policy decisions, NOT full browser rendering or network egress.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';

const [runnerArg,outArg]=process.argv.slice(2);
if(!runnerArg||!outArg)throw Error('usage: node test-qcore.mjs RUNTIME OUT');
const runtime=path.resolve(runnerArg),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:true});
const original=fs.readFileSync('security/reexplorer/xi/reexplorer-qcore.xi','utf8');
const bundled=fs.readFileSync('reverse-os-android/app/src/main/assets/reexplorer/navigation-core.xi','utf8');
assert.equal(original,bundled,'Shipped XI must exactly match the reviewed first-party source');
const header='#!reverse-pc-machine-v1\n';
assert.ok(original.startsWith(header));
const core=original.slice(header.length),B=9100000000000000000n;
function call(...args){return execFileSync(runtime,args,{encoding:'utf8',maxBuffer:1024*1024});}
const seed=path.join(out,'seed.rvp'),state=path.join(out,'live.rvp'),sourceFile=path.join(out,'turn.xi');
call('init',seed);fs.copyFileSync(seed,state);
let checks=2,turns=0,counts={allow:0,block:0,quarantine:0};
function query(event,flags=0,mode=0){
  const input=header+
    'store8 '+B+' '+event+'\n'+
    'store8 '+(B+1n)+' '+flags+'\n'+
    'store8 '+(B+2n)+' '+mode+'\n'+core;
  fs.writeFileSync(sourceFile,input);
  const next=path.join(out,'next.rvp');
  if(fs.existsSync(next))fs.rmSync(next);
  const result=call('run',sourceFile,state,next);
  const data=result.split('\n').filter(s=>s.startsWith('{')).map(s=>JSON.parse(s))
    .filter(x=>x.type==='register'&&['r0','r1','r2'].includes(x.register));
  assert.equal(data.length,3,'complete XI decision');
  const values=data.map(x=>x.value);
  fs.renameSync(next,state);turns++;
  if(values[0]===0)counts.allow++;else if(values[0]===2)counts.block++;else if(values[0]===3)counts.quarantine++;
  return values;
}
function test(event,flags,mode,expected,label){
  const got=query(event,flags,mode);
  assert.deepEqual(got,expected,label);checks++;
}
function reset(){fs.copyFileSync(seed,state);}
for(let mode=0;mode<2;mode++){
 reset();test(0,0,mode,[0,0,0],'valid HTTPS '+mode);
 test(6,0,mode,[0,7,0],'normal origin change');
 for(let event of [3,4,7]){
  const reason={3:31,4:41,7:71}[event];
  test(event,0,mode,[2,reason,0],'browser capability denied '+event);
 }
 reset();test(0,1,mode,[2,11,1],'first unsafe URL');
 test(0,2,mode,[2,11,2],'second unsafe URL');
 test(0,4,mode,[3,12,3],'third unsafe URL triggers quarantine');
 test(0,0,mode,[3,90,3],'quarantine cannot be bypassed by HTTPS');
 for(const event of [1,2,5]){
  reset();const reason={1:21,2:22,5:51}[event];
  test(event,0,mode,[3,reason,0],'hard browser security event '+event);
  test(0,0,mode,[3,90,0],'hard quarantine sticky');
 }
 reset();test(8,0,mode,[2,98,0],'undefined event rejected');
}
const random=()=>{let x=17393;return ()=>{x=(x*1664525+1013904223)>>>0;return x;};};
const next=random();
for(let i=0;i<192;i++){
 reset();
 const event=next()%8, flags=next()%8,mode=next()%2;
 const got=query(event,flags,mode);
 assert.ok([0,2,3].includes(got[0]),'defined decision '+i);
 if(event===0||event===6){
  assert.ok(flags===0 ?got[0]===0:got[0]!==0,'URL safety invariant '+i);
 }else if([1,2,5].includes(event)){
  assert.equal(got[0],3,'immediate quarantine '+i);
 }else{
  assert.equal(got[0],2,'permission or download blocked '+i);
 }
 checks++;
}
const report={suite:'REexplorer standalone native XI quantum state core',
  checks,turns,counts,
  no_bbyq_dependency:true,standalone_rvpc2:true,
  script_bytes:Buffer.byteLength(original,'utf8'),address_base:String(B),
  note:'XI/Ether logical states; not physical quantum hardware, PQ TLS or complete network interception'};
fs.writeFileSync(path.join(out,'results.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report,null,2));
