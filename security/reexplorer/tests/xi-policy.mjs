#!/usr/bin/env node
// Native XI state-policy test, no web parsing. This DOES NOT implement or
// claim Android IPC isolation, egress control, network monitoring or PQ TLS.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';

const [runtimeArg,outputArg]=process.argv.slice(2);
if(!runtimeArg||!outputArg)throw Error('usage: node security/reexplorer/tests/xi-policy.mjs RUNTIME OUTPUT_DIR');
const runtime=path.resolve(runtimeArg),out=path.resolve(outputArg);
fs.mkdirSync(out,{recursive:true});
const source=fs.readFileSync('security/reexplorer/xi/citadel-typed-policy.xi','utf8');
const header='#!reverse-pc-machine-v1\n';
assert.ok(source.startsWith(header));
const body=source.slice(header.length);
const seed=path.join(out,'seed.rvp'),state=path.join(out,'candidate.rvp'),probe=path.join(out,'probe.xi');
function cli(...args){return execFileSync(runtime,args,{encoding:'utf8',maxBuffer:1024*1024});}
cli('init',seed);
const B=9200000000000000000n;
const store=(offset,n)=>'store8 '+(B+BigInt(offset))+' '+n+'\n';
let checks=0,allowed=0,asked=0,blocked=0,terminated=0;
function expected(flags,mode,ready){
  if(ready!==1)return [2,90];
  if(mode>2)return [2,91];
  for(const [mask,reason] of [[1,1],[2,2],[4,3],[128,4]])
    if(flags&mask)return [2,reason];
  if(flags&64)return [4,64];
  if(flags&8)return [mode===1?2:1,8];
  if(flags&32)return [mode===1?2:1,32];
  if(flags&16)return [1,16];
  return [0,0];
}
function check(flags,mode,ready){
  const input=header+store(0,flags)+store(1,mode)+store(2,ready)+body;
  fs.writeFileSync(probe,input);
  const text=cli('run',probe,seed,state);
  const values=text.split('\n').filter(x=>x.startsWith('{')).map(x=>JSON.parse(x))
    .filter(x=>x.type==='register'&&(x.register==='r0'||x.register==='r1')).map(x=>x.value);
  const want=expected(flags,mode,ready);
  assert.deepEqual(values,want,'flags='+flags+' mode='+mode+' ready='+ready);
  // An absolute prohibition cannot become ALLOW through extra signals.
  if(ready!==1||(flags&135))assert.notEqual(values[0],0,'hard deny unexpectedly allowed');
  checks++;
  if(values[0]===0)allowed++;else if(values[0]===1)asked++;else if(values[0]===2)blocked++;else if(values[0]===4)terminated++;
  fs.rmSync(state,{force:true});
}
// All 256 combinations, all declared modes, with verified boundaries.
for(let mode=0;mode<3;mode++)for(let bits=0;bits<256;bits++)check(bits,mode,1);
// A security boundary not yet proved NEVER permits browsing.
for(let mode=0;mode<3;mode++)for(let bits of [0,1,2,4,8,16,32,64,128,255])check(bits,mode,0);
// Undefined policy mode is not permissive.
for(const bits of [0,1,8,16,128])for(const mode of [3,255])check(bits,mode,1);
const report={
  version:'Citadel-XI-Policy-Proof-of-Design',
  checks,allowed,asked,blocked,terminated,
  interface:{event_address:String(B),mode_address:String(B+1n),boundary_ready_address:String(B+2n),
    action_address:String(B+16n),reason_address:String(B+17n)},
  mode_codes:{general:0,finance:1,ephemeral:2},
  signals:{tls_invalid:1,private_ip:2,native_bridge:4,web_permission:8,
    origin_change:16,download:32,renderer_stall:64,monitor_unavailable:128},
  facts:[
    'No native decision is ALLOW with an unverified UID/network boundary',
    'Network and TLS veto flags are non-overridable in the XI prototype',
    'Finance mode rejects sensitive permission and download signals',
    'This XI program currently receives synthetic events only'
  ],
  deployed_in_browser:false,
  android_uid_separation_verified:false,
  all_egress_filtered:false,
  quantum_tls_verified:false,
  scope:'Offline native XI policy evaluator; not a real browsing threat prevention measurement'
};
fs.writeFileSync(path.join(out,'citadel-xi-results.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report,null,2));
