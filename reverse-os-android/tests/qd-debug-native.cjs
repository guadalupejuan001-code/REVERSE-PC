'use strict';
// Qd cycle 02: independent host examiner and byte-transport for the XI debugger.
// No repair policy is in JS: diagnose.xi emits one typed mutation or abstains.
// Every XI execution uses an initialized, disposable RVPC2; no user state is read.
const assert=require('node:assert/strict');
const fs=require('node:fs'),path=require('node:path');
const cp=require('node:child_process'),crypto=require('node:crypto');
const {performance}=require('node:perf_hooks');
const [runtime,outputDir]=process.argv.slice(2);
if(!runtime||!outputDir)throw Error('usage: node qd-debug-native.cjs <reverse_pc> <output-dir>');
const out=path.resolve(outputDir),root=path.resolve(__dirname,'../app/src/main/assets/workbench/qd');
fs.mkdirSync(out,{recursive:true});
const state=path.join(out,'disposable.rvp'),scratch=path.join(out,'discarded.rvp');
const sourceFile=path.join(out,'student.xi');
const HEADER='#!reverse-pc-machine-v1\n';
const D=8420000000000000000n;
const OPS={1:'add',2:'sub',3:'mul',4:'mod',5:'div'};
const OP_IDS={add:1,sub:2,mul:3,mod:4,div:5};
const FIXED=[[6,7],[12,4],[9,3],[15,8],[23,11]];
const oldFaults=['wrongOpA','arithmeticReg1','missingPrint','rhsA'];
const unseenFaults=['wrongOpB','arithmeticReg2','rhsZero','printReg2','swappedOrder','initialReg2'];
const alternateA={1:'sub',2:'add',3:'div',4:'mul'};
const alternateB={1:'mod',2:'mul',3:'sub',4:'add'};
const xi=fs.readFileSync(path.join(root,'diagnose.xi'),'utf8');
assert.ok(xi.startsWith(HEADER));
const sha=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const hashText=s=>crypto.createHash('sha256').update(s).digest('hex');
let nativeCalls=0,nativeWallMs=0,xiCalls=0,studentCases=0;
const t0=performance.now();
const init=cp.spawnSync(runtime,['init',state],{encoding:'utf8',timeout:30000,maxBuffer:1024*1024});
if(init.error||init.status!==0)throw Error('cannot initialize disposable XI state: '+(init.stderr||init.error));
const stateHash=sha(state);
const stateSize=fs.statSync(state).size;
function nativeRun(text){
 fs.writeFileSync(sourceFile,text,'utf8');
 fs.rmSync(scratch,{force:true});
 const begin=performance.now();
 const result=cp.spawnSync(runtime,['run',sourceFile,state,scratch],{
  encoding:'utf8',timeout:15000,maxBuffer:1024*1024,stdio:['ignore','pipe','pipe']
 });
 nativeWallMs+=performance.now()-begin;nativeCalls++;
 fs.rmSync(scratch,{force:true}); // NEVER rename back to the input state.
 const lines=(result.stdout||'').split('\n').filter(x=>x.startsWith('{'));
 const values=[];
 for(const line of lines){
  const data=JSON.parse(line);
  if(data.register&&data.value!==undefined)values.push(Number(data.value));
 }
 return {ok:!result.error&&result.status===0,values,
  failure:result.error?String(result.error):result.status===0?null:(result.stderr||'').slice(0,200)};
}
function parseStudent(source){
 if(typeof source!=='string'||!source.startsWith(HEADER)||!source.endsWith('\n')||
    Buffer.byteLength(source,'utf8')>192||/[^\x09\x0a\x20-\x7e]/.test(source))
  throw Error('unsafe student source');
 const lines=source.slice(HEADER.length).trimEnd().split('\n');
 if(lines.length<3||lines.length>5||lines.at(-1)!=='halt')throw Error('unsafe statement count or halt');
 const set=/^set r([0-3]) \{\{a\}\}$/;
 const operation=/^(add|sub|mul|mod|div) r([0-3]) (\{\{a\}\}|\{\{b\}\}|0)$/;
 const printed=/^print r([0-3])$/;
 const harmless=/^mov r3 r3$/;
 const p={lines,setIdx:-1,opIdx:-1,printIdx:-1,printReg:255};
 for(let i=0;i<lines.length-1;i++){
  let m=set.exec(lines[i]);
  if(m){if(p.setIdx!==-1)throw Error('duplicate initial register');p.setIdx=i;p.setReg=Number(m[1]);continue;}
  m=operation.exec(lines[i]);
  if(m){if(p.opIdx!==-1)throw Error('duplicate operation');
   p.opIdx=i;p.op=OP_IDS[m[1]];p.dest=Number(m[2]);p.rhs={'{{a}}':1,'{{b}}':2,'0':3}[m[3]];continue;}
  m=printed.exec(lines[i]);
  if(m){if(p.printIdx!==-1)throw Error('duplicate print');p.printIdx=i;p.printReg=Number(m[1]);continue;}
  if(harmless.test(lines[i])){if(p.noopIdx!==undefined)throw Error('duplicate no-op');p.noopIdx=i;continue;}
  throw Error('unsafe XI statement');
 }
 if(p.setIdx<0||p.opIdx<0||p.setIdx===p.opIdx||
    (p.printIdx>=0&&p.printIdx<Math.max(p.setIdx,p.opIdx)))throw Error('unsafe statement order');
 return p;
}
function mutation(skill,fault){
 let lines=['set r0 {{a}}',OPS[skill]+' r0 {{b}}','print r0','halt'];
 if(fault==='wrongOpA'||fault==='wrongOpB'){
  const op=fault==='wrongOpA'?alternateA[skill]:alternateB[skill];
  lines[1]=op+' r0 {{b}}';
 }else if(fault==='arithmeticReg1')lines[1]=OPS[skill]+' r1 {{b}}';
 else if(fault==='arithmeticReg2')lines[1]=OPS[skill]+' r2 {{b}}';
 else if(fault==='missingPrint')lines.splice(2,1);
 else if(fault==='rhsA')lines[1]=OPS[skill]+' r0 {{a}}';
 else if(fault==='rhsZero')lines[1]=OPS[skill]+' r0 0';
 else if(fault==='printReg2')lines[2]='print r2';
 else if(fault==='swappedOrder')[lines[0],lines[1]]=[lines[1],lines[0]];
 else if(fault==='initialReg2')lines[0]='set r2 {{a}}';
 else throw Error('unknown synthetic fault');
 if(fault==='wrongOpB')lines.splice(2,0,'mov r3 r3'); // Unseen safe source form, not merely a relabelled baseline.
 const s=HEADER+lines.join('\n')+'\n';parseStudent(s);return s;
}
function diagnose(source,skill){
 const p=parseStudent(source);
 if(!Number.isInteger(skill)||skill<1||skill>4)throw Error('invalid skill');
 const fields=[81,1,skill,p.op,p.dest,p.setReg,p.printIdx<0?0:1,
  p.printReg,p.setIdx<p.opIdx?1:0,p.rhs];
 const stage=fields.map((value,i)=>'store8 '+(D+BigInt(i))+' '+value).join('\n');
 const result=nativeRun(HEADER+stage+'\n'+xi.slice(HEADER.length));
 xiCalls++;assert.ok(result.ok,'XI diagnostic failed '+result.failure);
 assert.equal(result.values.length,3,'XI diagnostic must emit exactly 3 typed fields');
 const [status,kind,arg]=result.values;
 assert.ok(status>=0&&status<=3&&kind>=0&&kind<=7);
 return {status,kind,arg};
}
function applyDecision(source,decision){
 if(decision.status!==1)throw Error('XI did not authorize a single repair');
 const p=parseStudent(source),lines=p.lines.slice();
 if(decision.kind===1){
  if(!OPS[decision.arg]||decision.arg>4)throw Error('untrusted XI operation');
  lines[p.opIdx]=lines[p.opIdx].replace(/^(add|sub|mul|mod|div)/,OPS[decision.arg]);
 }else if(decision.kind===2)
  lines[p.opIdx]=lines[p.opIdx].replace(/^(\w+) r[0-3] /,'$1 r0 ');
 else if(decision.kind===3){
  if(p.printIdx<0)throw Error('cannot replace absent print');
  lines[p.printIdx]='print r0';
 }else if(decision.kind===4){
  if(p.printIdx>=0)throw Error('cannot insert duplicate print');
  lines.splice(lines.length-1,0,'print r0');
 }else if(decision.kind===5)
  [lines[p.setIdx],lines[p.opIdx]]=[lines[p.opIdx],lines[p.setIdx]];
 else if(decision.kind===6)
  lines[p.setIdx]='set r0 {{a}}';
 else if(decision.kind===7)
  lines[p.opIdx]=lines[p.opIdx].replace(/(?:\{\{a\}\}|\{\{b\}\}|0)$/,'{{b}}');
 else throw Error('unknown XI patch kind');
 const changed=HEADER+lines.join('\n')+'\n';
 if(changed===source)throw Error('XI emitted a no-op edit');
 parseStudent(changed);return changed;
}
function oracle(skill,a,b){
 if(skill===1)return a+b;
 if(skill===2)return a-b;
 if(skill===3)return a*b;
 if(skill===4)return a%b;
 throw Error('unsupported skill');
}
function grade(source,skill,pairs){
 const results=[];
 for(const [a,b] of pairs){
  const execution=nativeRun(source.replace(/\{\{a\}\}/g,String(a)).replace(/\{\{b\}\}/g,String(b)));
  studentCases++;
  const correct=execution.ok&&execution.values.length===1&&execution.values[0]===oracle(skill,a,b);
  results.push({a,b,pass:correct,error:correct?null:execution.failure,actual:execution.values});
 }
 return {passed:results.filter(x=>x.pass).length,total:results.length,
  all_passed:results.every(x=>x.pass),results};
}
let seed=process.env.QD_DEBUG_SEED!==undefined?Number(process.env.QD_DEBUG_SEED):crypto.randomBytes(4).readUInt32LE(0);
if(!Number.isSafeInteger(seed)||seed<0||seed>0xffffffff)throw Error('bad QD_DEBUG_SEED');
let rng=seed>>>0;
function random(limit){rng=(Math.imul(rng,1664525)+1013904223)>>>0;return rng%limit;}
const usedPairs=new Set(FIXED.map(x=>x.join(':')));
function freshPairs(count){
 const pairs=[];
 while(pairs.length<count){
  const pair=[random(100),1+random(99)],key=pair.join(':');
  if(usedPairs.has(key))continue;
  usedPairs.add(key);pairs.push(pair);
 }
 return pairs;
}
const baseline=[],holdout=[],baselineSources=new Set(),holdoutSources=new Set();
for(const skill of [1,2,3,4])for(const fault of oldFaults){
 const source=mutation(skill,fault),before=grade(source,skill,FIXED);
 assert.equal(before.all_passed,false,'baseline fault was not reproduced');
 const decision=diagnose(source,skill);
 assert.equal(decision.status,1,'XI cannot diagnose baseline '+skill+'/'+fault);
 const changed=applyDecision(source,decision);
 const clean=diagnose(changed,skill);
 assert.deepEqual(clean,{status:0,kind:0,arg:0});
 const after=grade(changed,skill,FIXED);
 assert.equal(after.all_passed,true,'XI repair failed baseline '+skill+'/'+fault);
 baselineSources.add(source);
 baseline.push({skill,fault,source_sha256:hashText(source),before:before.passed+'/'+before.total,
  decision,after:after.passed+'/'+after.total,edit_bytes:Buffer.byteLength(changed)-Buffer.byteLength(source)});
}
assert.equal(baselineSources.size,16);
for(const skill of [1,2,3,4])for(const fault of unseenFaults){
 const source=mutation(skill,fault),pairs=freshPairs(6);
 assert.ok(!baselineSources.has(source),'heldout source leaked into baseline');
 const before=grade(source,skill,pairs.slice(0,2));
 assert.equal(before.all_passed,false,'heldout fault was not reproduced');
 const decision=diagnose(source,skill);
 assert.equal(decision.status,1,'XI cannot diagnose heldout '+skill+'/'+fault);
 const changed=applyDecision(source,decision);
 const clean=diagnose(changed,skill);
 assert.deepEqual(clean,{status:0,kind:0,arg:0});
 const after=grade(changed,skill,pairs);
 assert.equal(after.all_passed,true,'XI repair failed heldout '+skill+'/'+fault);
 holdoutSources.add(source);
 holdout.push({skill,fault,source_sha256:hashText(source),before:before.passed+'/'+before.total,
  decision,after:after.passed+'/'+after.total,pairs});
}
assert.equal(holdoutSources.size,24);
const good=HEADER+'set r0 {{a}}\nadd r0 {{b}}\nprint r0\nhalt\n';
assert.deepEqual(diagnose(good,1),{status:0,kind:0,arg:0});
const multiple=HEADER+'set r0 {{a}}\ndiv r0 0\nprint r0\nhalt\n';
assert.deepEqual(diagnose(multiple,1),{status:2,kind:0,arg:0});
assert.throws(()=>parseStudent(HEADER+'store8 8300000000000000000 0\nhalt\n'));
assert.throws(()=>parseStudent(HEADER+'set r0 {{a}}\nadd r0 {{b}}\nprint r0\nprint r0\nhalt\n'));
const badStage=nativeRun(HEADER+'store8 '+D+' 0\nstore8 '+(D+1n)+' 1\n'+xi.slice(HEADER.length));
assert.equal(badStage.ok,true);assert.deepEqual(badStage.values,[3,0,0]);
assert.equal(sha(state),stateHash,'disposable RVPC2 was mutated during tests');
const report={
 cycle:'QD-20261029-02',source:'real REVERSE XI/Ether runtime on fresh disposable RVPC2',
 original_qd_api_has_debug:false,
 xi_rule_program:'reverse-os-android/app/src/main/assets/workbench/qd/diagnose.xi',
 trained_new_patterns:0,engineered_symbolic_rules:7,
 baseline:{defective_programs:16,fully_correct_before:0,diagnosed_and_corrected:baseline.length,records:baseline},
 heldout:{distinct_programs:24,diagnosed_and_corrected:holdout.length,new_input_pairs_per_program:6,
  random_seed:seed,records:holdout},
 safety:{clean_unchanged:true,multiple_faults_abstained:true,out_of_contract_rejected:true,
  invalid_staged_bytes_rejected:true,rvpc2_unchanged:true},
 resources:{native_program_runs:nativeCalls,student_input_executions:studentCases,
  diagnostic_xi_calls:xiCalls,native_run_wall_ms:Math.round(nativeWallMs),
  whole_test_wall_ms:Math.round(performance.now()-t0),disposable_rvpc2_bytes:stateSize,
  disposable_rvpc2_sha256:stateHash,native_peak_rss_bytes:null,
  compiled_rxe_programs:0,physical_android_metrics:null},
 limits:['Rules designed in XI; not learned from demonstrations','Single-fault canonical arithmetic programs only',
  'Host tokenizer and edit application are deterministic transport, not diagnostic decision',
  'No persistent user checkpoint or Android UI was changed','Examination is novel sources/inputs, not novel algorithm families']
};
fs.writeFileSync(path.join(out,'qd-debug-evidence.json'),JSON.stringify(report,null,2)+'\n');
console.log('QD_DEBUG_XI_OK',JSON.stringify({baseline:'16/16',unseen:'24/24',
 native_calls:nativeCalls,exam_seed:seed,state_unchanged:true}));
