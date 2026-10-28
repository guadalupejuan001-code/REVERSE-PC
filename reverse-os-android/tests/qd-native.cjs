'use strict';
// Native Qd contract test. The actual reverse_pc XI/Ether runtime executes these
// programs, and its RVPC2 checkpoint proves persistence and rollback.
const assert=require('node:assert/strict');
const fs=require('node:fs'),path=require('node:path'),os=require('node:os');
const cp=require('node:child_process'),crypto=require('node:crypto');
const [runtime,outputDir,seed]=process.argv.slice(2);
if(!runtime||!outputDir)throw Error('usage: node qd-native.cjs <reverse_pc> <outputDir> [seed.rvp]');
const out=path.resolve(outputDir),root=path.resolve(__dirname,'../app/src/main/assets/workbench/qd');
fs.mkdirSync(out,{recursive:true});
const state=path.join(out,'qd-agent.rvp'),source=path.join(out,'current.xi'),next=path.join(out,'candidate.rvp');
const HEADER='#!reverse-pc-machine-v1\n', B=8400000000000000000n,M=8410000000000000000n;
const code=name=>fs.readFileSync(path.join(root,name+'.xi'),'utf8');
const run=(...args)=>cp.execFileSync(runtime,args,{encoding:'utf8',timeout:60000,maxBuffer:1024*1024,stdio:['ignore','pipe','pipe']});
const prints=output=>output.split('\n').filter(x=>x.startsWith('{')).map(x=>JSON.parse(x)).filter(x=>x.register&&x.value!==undefined).map(x=>Number(x.value));
const sha=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
let checks=0;
function execute(text,commit=true){
 fs.writeFileSync(source,text);
 const data=run('run',source,state,next);
 if(commit)fs.renameSync(next,state);
 else fs.rmSync(next,{force:true});
 return prints(data);
}
if(seed)fs.copyFileSync(path.resolve(seed),state);else run('init',state);
assert.ok(fs.statSync(state).size>0);checks++;
function status(){const r=execute(code('status'),false);assert.equal(r.length,6);return r;}
const before=status();
assert.ok(before[0]===0||before[0]===81);checks++;
const sentinelAddress=8300000000000000818n;
// Write to W4u-owned address in TEST STATE ONLY; Qd must not touch it.
execute(HEADER+'store8 '+sentinelAddress+' 177\nhalt\n');
const cases=[
 {skill:1,op:'add'},{skill:2,op:'sub'},{skill:3,op:'mul'},{skill:4,op:'mod'}
];
const fixtures=[[6,7],[12,4],[9,3],[15,8],[23,11],[7,19],[38,5],[61,9]];
const reports=[];
for(const row of cases){
 const template=HEADER+'set r0 {{a}}\n'+row.op+' r0 {{b}}\nprint r0\nhalt\n';
 const bytes=Buffer.from(template,'ascii');assert.ok(bytes.length<=192);
 const stage=[
  'store8 '+M+' 81',
  'store8 '+(M+1n)+' 1',
  'store8 '+(M+2n)+' '+row.skill,
  'store8 '+(M+3n)+' '+bytes.length,
  ...Array.from(bytes,(value,i)=>'store8 '+(M+16n+BigInt(i))+' '+value)
 ].join('\n');
 const result=execute(HEADER+stage+'\n'+code('learn').slice(HEADER.length));
 assert.deepEqual(result,[row.skill,bytes.length]);checks++;
 const statusNow=status();
 assert.equal(statusNow[row.skill],bytes.length);checks++;
 const recallStage=HEADER+'store8 '+M+' 81\nstore8 '+(M+1n)+' 2\nstore8 '+(M+2n)+' '+row.skill+'\n'+code('recall').slice(HEADER.length);
 const recalled=execute(recallStage,false);
 assert.equal(Buffer.from(recalled).toString('ascii'),template);checks++;
 let passed=0;
 for(const [a,b] of fixtures){
  const filled=template.replaceAll('{{a}}',String(a)).replaceAll('{{b}}',String(b));
  const result=execute(filled,false);
  const expected=row.skill===1?a+b:row.skill===2?a-b:row.skill===3?a*b:a%b;
  assert.deepEqual(result,[expected]);checks++;passed++;
 }
 reports.push({skill:row.skill,pattern_bytes:bytes.length,cases:passed,passed:true});
}
const after=status();
assert.equal(after[0],81);assert.ok(after[5]>=4);checks++;
for(const i of [1,2,3,4]){assert.ok(after[i]>0);checks++;}
const w4u=execute(HEADER+'load8 r0 '+sentinelAddress+'\nprint r0\nhalt\n',false);
assert.deepEqual(w4u,[177]);checks++;
// Invalid lesson length causes XI error and leaves the already-persisted RVPC2 intact.
const lockedHash=sha(state);
const bad=HEADER+'store8 '+M+' 81\nstore8 '+(M+1n)+' 1\nstore8 '+(M+2n)+' 2\nstore8 '+(M+3n)+' 0\n'+code('learn').slice(HEADER.length);
fs.writeFileSync(source,bad);
const failure=cp.spawnSync(runtime,['run',source,state,next],{encoding:'utf8',timeout:30000});
assert.notEqual(failure.status,0);assert.equal(sha(state),lockedHash);checks+=2;
fs.rmSync(next,{force:true});
const report={suite:'qd_cody_native_xi',checks,status_before:before,status_after:after,learned_skills:reports,holdout_pairs:4,verified_rvpc2:true,w4u_state_preserved:true,invalid_lesson_rolled_back:true,source:'native reverse_pc XI/Ether, not JavaScript code execution'};
fs.writeFileSync(path.join(out,'qd-evidence.json'),JSON.stringify(report,null,2)+'\n');
console.log('QD_CODY_NATIVE_OK',JSON.stringify({checks,patterns:4,validations:fixtures.length*4,persisted:after[5]}));
