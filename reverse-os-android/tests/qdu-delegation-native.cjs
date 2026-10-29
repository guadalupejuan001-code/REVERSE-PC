'use strict';
/* One native XI/Ether task pipeline, not a simulated agent or separate runtime.
   This test initializes a disposable RVPC2 with only w4U schema markers;
   the Android instrumentation separately validates the genuine BBY Q E025 state. */
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process'),crypto=require('node:crypto'),assert=require('node:assert/strict'),{performance}=require('node:perf_hooks');
const [runner,outArg]=process.argv.slice(2);
if(!runner||!outArg)throw Error('usage: node qdu-delegation-native.cjs <reverse_pc> <output-dir>');
const out=path.resolve(outArg),root=path.resolve(__dirname,'../app/src/main/assets/workbench');
fs.mkdirSync(out,{recursive:true});
const H='#!reverse-pc-machine-v1\n',B=8440000000000000000n,M=8300000000000000000n,N=8430000000000000000n;
const nameToFile={gate:'bbyq/qdu-intent.xi',plan:'w4u/qdu-plan.xi',dispatch:'w4u/qdu-dispatch.xi',review:'w4u/qdu-review.xi',report:'bbyq/qdu-result.xi',understand:'qd/understand.xi',compose:'qd/compose.xi'};
const roles=Object.fromEntries(Object.entries(nameToFile).map(([k,f])=>[k,fs.readFileSync(path.join(root,f),'utf8')]));
for(const [key,src] of Object.entries(roles))assert.ok(src.startsWith(H),'XI role invalid '+key);
const file=path.join(out,'current.xi'),seed=path.join(out,'initial.rvp'),sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const init=cp.spawnSync(runner,['init',seed],{encoding:'utf8',timeout:30000});
assert.equal(init.status,0,'failed to initialize XI disposable RVPC2: '+init.stderr);
const seedHash=sha(seed),seedSize=fs.statSync(seed).size;
let calls=0,ms=0,accepted=0,denials=0,correct=0;
function at(base,i){return base+BigInt(i);}
function put(base,offset,value){assert(Number.isInteger(value)&&value>=0&&value<=255);return 'store8 '+at(base,offset)+' '+value+'\n';}
function run(state,src){
 const next=path.join(out,'step-'+(++calls)+'.rvp');
 fs.writeFileSync(file,src);
 const started=performance.now();
 const result=cp.spawnSync(runner,['run',file,state,next],{encoding:'utf8',timeout:15000,maxBuffer:1024*1024});
 ms+=performance.now()-started;
 assert.equal(result.status,0,'Native XI failed call '+calls+': '+result.stderr);
 const values=result.stdout.split('\n').filter(l=>l.startsWith('{')).map(l=>JSON.parse(l)).filter(l=>l.value!==undefined&&l.register).map(l=>Number(l.value));
 assert.ok(values.length<=256);
 return {state:next,values};
}
function role(state,name,stage=''){return run(state,H+stage+roles[name].slice(H.length));}
function tokens(raw){
 if(typeof raw!=='string'||raw.length>180||!raw.trim())throw Error('bad prompt');
 let v=raw.normalize('NFD').replace(/\p{M}+/gu,'').toLowerCase();
 if(/-\s*\d/.test(v))throw Error('negative operand');
 v=v.replace(/[^a-z0-9]+/g,' ').trim();
 const words=[],numbers=[];
 for(const token of v.split(' ')){
  if(/^\d+$/.test(token)){if(token.length>2||numbers.length>=2)throw Error('bad operand count');numbers.push(Number(token));}
  else{if(words.length>=18)throw Error('word limit');
   let h=0;for(const c of token)h=(h*31+c.charCodeAt(0))%65521;words.push(h);}
 }
 return {words,numbers};
}
function stage(prompt,overrides={}){
 const t=tokens(prompt),nonce=overrides.nonce||[9,20,31,42];
 const digest=[...crypto.createHash('sha256').update(prompt).digest().subarray(0,4)];
 let src=put(B,0,overrides.magic===undefined?66:overrides.magic)+put(B,1,1)+put(B,2,t.words.length)+put(B,3,t.numbers.length)
  +put(B,4,t.numbers[0]||0)+put(B,5,t.numbers[1]||0);
 t.words.forEach((h,i)=>{src+=put(B,16+i*2,h&255)+put(B,17+i*2,(h>>>8)&255);});
 for(let i=0;i<4;i++)src+=put(B,60+i,nonce[i]);
 src+=put(B,64,overrides.cap===undefined?1:overrides.cap)+put(B,65,1);
 for(let i=0;i<4;i++)src+=put(B,70+i,digest[i]);
 return src+(overrides.noSchema?'':put(M,0,77)+put(M,1,1));
}
function oracle(op,a,b){return [0,a+b,a-b,a*b,Math.trunc(a/b),a%b][op];}
function implement(prompt,ticketState){
 const t=tokens(prompt);
 let initial=put(N,0,81)+put(N,1,1)+put(N,2,t.words.length)+put(N,3,t.numbers.length)+put(N,4,t.numbers[0])+put(N,5,t.numbers[1]);
 t.words.forEach((h,i)=>{initial+=put(N,16+i*2,h&255)+put(N,17+i*2,h>>>8);});
 const intent=role(ticketState,'understand',initial);
 assert.equal(intent.values.length,4);
 if(intent.values[0]!==0)return {accepted:false};
 const [_,op,a,b]=intent.values;
 let compose=put(N,0,81)+put(N,1,2)+put(N,2,op)+put(N,3,a)+put(N,4,b);
 const produced=role(intent.state,'compose',compose);
 assert.ok(produced.values.length>24&&produced.values.length<128);
 const source=String.fromCharCode(...produced.values);
 assert.ok(source.startsWith(H)&&source.endsWith('halt\n'));
 const answer=run(seed,source);
 assert.equal(answer.values.length,1);
 return {accepted:true,source,actual:answer.values[0],op,a,b,correct:answer.values[0]===oracle(op,a,b)};
}
const examples=[
 ['crea un programa que sume 31 y 44',75],
 ['escribe codigo suma 19 mas 8',27],
 ['create code to add 64 plus 17',81],
 ['crea programa resta 93 menos 34',59],
 ['write code to subtract 80 minus 11',69],
 ['programa diferencia de 74 y 39',35],
 ['crea un programa para multiplicar 15 por 6',90],
 ['write code to multiply 12 times 8',96],
 ['codigo producto de 11 por 9',99],
 ['crea programa divide 84 entre 7',12],
 ['write code to divide 81 entre 9',9],
 ['programa resto de 79 y 8',7],
 ['code remainder 92 and 11',4],
 ['programa modulo 77 y 6',5]
];
const cases=[];
for(const [prompt,answer] of examples){
 const initial=role(seed,'gate',stage(prompt));
 assert.deepEqual(initial.values,[0],'BBY Q rejected an explicit code task '+prompt);
 const planned=role(initial.state,'plan');
 assert.deepEqual(planned.values,[0],'w4U did not plan '+prompt);
 const dispatched=role(planned.state,'dispatch');
 assert.deepEqual(dispatched.values,[0],'w4U did not issue one-use ticket '+prompt);
 const qdu=implement(prompt,dispatched.state);
 assert.equal(qdu.accepted,true,'QdU rejected '+prompt);
 assert.equal(qdu.actual,answer,'QdU generated incorrect result for '+prompt);
 let stamp=put(B,80,qdu.correct?1:0)+put(B,81,qdu.op)+put(B,82,qdu.a)+put(B,83,qdu.b)
   +put(B,84,qdu.actual&255)+put(B,85,(qdu.actual&65535)>>>8);
 const reviewed=role(dispatched.state,'review',stamp);
 assert.deepEqual(reviewed.values,[0],'w4U rejected correctly generated XI source');
 const returned=role(reviewed.state,'report');
 assert.deepEqual(returned.values,[0],'BBY Q did not return verified result');
 assert.equal(sha(seed),seedHash);
 accepted++;correct++;
 cases.push({prompt,oracle:answer,actual:qdu.actual,opcode:qdu.op,program_sha:crypto.createHash('sha256').update(qdu.source).digest('hex')});
}
const basePrompt='crea un programa que sume 31 y 44';
function deny(name,fn){const rejected=fn();assert.equal(rejected,true,'negative control failed: '+name);denials++;}
deny('missing code task',()=>role(seed,'gate',stage('suma 12 y 8')).values[0]!==0);
deny('explicit negation',()=>role(seed,'gate',stage('no crea programa suma 12 y 8')).values[0]!==0);
deny('bad envelope magic',()=>role(seed,'gate',stage(basePrompt,{magic:0})).values[0]!==0);
deny('missing operand',()=>role(seed,'gate',stage('crea programa suma 12')).values[0]!==0);
deny('missing w4U capability',()=>{const p=role(seed,'gate',stage(basePrompt,{cap:0}));return role(p.state,'plan').values[0]!==0});
deny('wrong w4U schema',()=>{const p=role(seed,'gate',stage(basePrompt,{noSchema:true}));return role(p.state,'plan').values[0]!==0});
deny('nonce all zero',()=>{const p=role(seed,'gate',stage(basePrompt,{nonce:[0,0,0,0]}));return role(p.state,'plan').values[0]!==0});
deny('dispatch without a plan',()=>{const p=role(seed,'gate',stage(basePrompt));return role(p.state,'dispatch').values[0]!==0});
const start=role(seed,'gate',stage(basePrompt));
const permit=role(start.state,'plan');
deny('replayed w4U plan',()=>role(permit.state,'plan').values[0]!==0);
deny('changed nonce',()=>role(permit.state,'dispatch',put(B,60,255)).values[0]!==0);
deny('changed task digest',()=>role(permit.state,'dispatch',put(B,70,255)).values[0]!==0);
deny('premature review',()=>role(permit.state,'review',put(B,80,1)).values[0]!==0);
const issued=role(permit.state,'dispatch');
deny('ticket replay',()=>role(issued.state,'dispatch').values[0]!==0);
deny('BBY Q premature completion',()=>role(issued.state,'report').values[0]!==0);
const fake=put(B,80,1)+put(B,81,1)+put(B,82,31)+put(B,83,44)+put(B,84,0)+put(B,85,0);
deny('false reported result',()=>role(issued.state,'review',fake).values[0]!==0);
assert.equal(sha(seed),seedHash);
const evidence={
 cycle:'QDU-T1-20261029',source:'real original XI/Ether native interpreter on isolated RVPC2',
 roles:['BBY Q XI task gate','w4U XI one-use authorization','QdU XI source generation/isolated run','w4U XI arithmetic review','BBY Q XI result handback'],
 acceptance:{completed:accepted,total:examples.length,correct,denied:denials},
 cases,resources:{xi_native_calls:calls,native_run_wall_ms:Math.round(ms),state_bytes:seedSize,state_sha256:seedHash,seed_unchanged:true},
 caveats:['Synthetic w4U schema seeded only for this CLI test; genuine E025 tested separately via Android instrumentation',
 'BBY Q task gate is bounded XI lexical classification, not full E025 open-ended conversational inference',
 'No persistent writes or autonomous files/PR/Work tasks',
 'Host lexical transport and independent oracle only; rules and source emitted by XI']
};
fs.writeFileSync(path.join(out,'qdu-delegation-evidence.json'),JSON.stringify(evidence,null,2)+'\n');
console.log('QDU_T1_XI_OK '+JSON.stringify({tasks:accepted,total:examples.length,negative:denials,runs:calls,state_unchanged:true,origin:'BBY Q XI',coordinator:'w4U XI',programmer:'QdU XI'}));
