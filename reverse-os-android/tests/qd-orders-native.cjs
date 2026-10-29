'use strict';
// Real XI/Ether evaluator for Qd's bounded natural-command interpreter.
// Java's host is independently replicated only for generic token/byte transport.
// Vocabulary, operation selection and source-byte emission belong to XI scripts.
const assert=require('node:assert/strict');
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process'),crypto=require('node:crypto');
const [runtime,work]=process.argv.slice(2);
if(!runtime||!work)throw Error('usage: node qd-orders-native.cjs <reverse_pc> <scratch-directory>');
fs.mkdirSync(work,{recursive:true});
const root=path.join(__dirname,'../app/src/main/assets/workbench/qd'),N=8430000000000000000n;
const HEADER='#!reverse-pc-machine-v1\n';
const files={state:path.resolve(work,'seed.rvp'),next:path.resolve(work,'discarded.rvp'),source:path.resolve(work,'temporary.xi')};
const scripts={understand:fs.readFileSync(path.join(root,'understand.xi'),'utf8'),compose:fs.readFileSync(path.join(root,'compose.xi'),'utf8')};
const sha=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const init=cp.spawnSync(runtime,['init',files.state],{encoding:'utf8',timeout:30000});
assert.equal(init.status,0,'XI init failed: '+init.stderr);
const initialHash=sha(files.state);
let nativeRuns=0,interpretations=0,codeEmissions=0,executions=0;
function run(source){
 fs.writeFileSync(files.source,source);
 fs.rmSync(files.next,{force:true});
 const result=cp.spawnSync(runtime,['run',files.source,files.state,files.next],{encoding:'utf8',timeout:15000,maxBuffer:1024*1024});
 fs.rmSync(files.next,{force:true});
 nativeRuns++;
 assert.equal(result.status,0,'Native XI error: '+result.stderr);
 return result.stdout.split('\n').filter(l=>l.startsWith('{')).map(l=>JSON.parse(l))
  .filter(x=>x.register&&x.value!==undefined).map(x=>Number(x.value));
}
function store(offset,value){assert(value>=0&&value<=255);return 'store8 '+(N+BigInt(offset))+' '+value+'\n';}
function tokenize(raw){
 assert(typeof raw==='string'&&raw.length>0&&raw.length<=180);
 let value=raw.normalize('NFD').replace(/\p{M}+/gu,'').toLowerCase();
 if(/-\s*\d/.test(value))throw Error('negative input');
 value=value.replace(/[^a-z0-9]+/g,' ').trim();
 const words=[],values=[];
 for(const token of value.split(' ').filter(Boolean)){
  if(/^\d+$/.test(token)){if(token.length>2||values.length>=3)throw Error('numbers out of bounds');values.push(Number(token));}
  else{if(words.length>=18)throw Error('too many words');
   let hash=0;for(const ch of token)hash=(hash*31+ch.charCodeAt(0))%65521;words.push(hash);}
 }
 return {words,values};
}
function understand(raw){
 const data=tokenize(raw);
 let stage=store(0,81)+store(1,1)+store(2,data.words.length)+store(3,data.values.length)+
   store(4,data.values[0]??0)+store(5,data.values[1]??0);
 data.words.forEach((h,i)=>{stage+=store(16+2*i,h&255)+store(17+2*i,h>>>8);});
 const values=run(HEADER+stage+scripts.understand.slice(HEADER.length));
 interpretations++;assert.equal(values.length,4);return values;
}
function compose(op,a,b){
 let stage=store(0,81)+store(1,2)+store(2,op)+store(3,a)+store(4,b);
 const codes=run(HEADER+stage+scripts.compose.slice(HEADER.length));
 codeEmissions++;
 assert(codes.length>0&&codes.length<128);
 assert(codes.every(c=>c===10||c>=32&&c<=126));
 return String.fromCharCode(...codes);
}
const examples=[
 ['crea un programa que sume 31 y 44','add',31,44,75],
 ['sumar 19 mas 8','add',19,8,27],
 ['por favor agrega 28 y 43','add',28,43,71],
 ['programa suma 1 y 99','add',1,99,100],
 ['añade 88 y 11','add',88,11,99],
 ['create code to add 64 plus 17','add',64,17,81],
 ['sum 20 and 17','add',20,17,37],
 ['calcula la diferencia de 72 menos 15','sub',72,15,57],
 ['resta 93 menos 34','sub',93,34,59],
 ['crea codigo que reste 61 y 9','sub',61,9,52],
 ['subtract 80 minus 11','sub',80,11,69],
 ['difference 74 and 39','sub',74,39,35],
 ['multiplica 9 por 7','mul',9,7,63],
 ['quiero un programa para multiplicar 15 por 6','mul',15,6,90],
 ['calcula producto de 11 por 9','mul',11,9,99],
 ['multiply 12 times 8','mul',12,8,96],
 ['produce code product 8 times 9','mul',8,9,72],
 ['divide 84 entre 7','div',84,7,12],
 ['dividir 96 entre 12','div',96,12,8],
 ['divide 81 entre 9','div',81,9,9],
 ['quotient 90 divided 15','div',90,15,6],
 ['resto de 79 y 8','mod',79,8,7],
 ['modulo 77 y 6','mod',77,6,5],
 ['remainder 92 and 11','mod',92,11,4],
 ['calcula el residuo de 45 y 7','mod',45,7,3],
 ['calcula una resta de 4 menos 93','sub',4,93,-89]
];
const operators={add:1,sub:2,mul:3,div:4,mod:5};
const log=[];
for(const [prompt,op,a,b,want] of examples){
 const decision=understand(prompt);
 assert.deepEqual(decision,[0,operators[op],a,b],'Intent XI wrong for: '+prompt);
 const program=compose(decision[1],decision[2],decision[3]);
 const expected=HEADER+'set r0 '+a+'\n'+op+' r0 '+b+'\nprint r0\nhalt\n';
 assert.equal(program,expected,'XI generated different code: '+prompt);
 const output=run(program);executions++;
 assert.deepEqual(output,[want],'XI result incorrect: '+prompt);
 log.push({prompt,operation:op,a,b,expected:want,actual:output[0],program_sha256:crypto.createHash('sha256').update(program).digest('hex')});
}
const invalid=[
 ['haz una calculadora',1],
 ['programa para elevar 2 al cuadrado',1],
 ['suma 2 y multiplica 3',3],
 ['no sumes 2 y 3',4],
 ['divide 90 entre 0',5],
 ['modulo 5 y 0',5],
 ['borra mis archivos 2 3',1],
 ['imprime acceso sistema 1 2',1],
 ['multiplica 12 por 7 y divide',3],
 ['suma 3',2],
 ['hello world',1]
];
for(const [prompt,status] of invalid){const d=understand(prompt);assert.equal(d[0],status,'Unexpected acceptance for '+prompt);}
for(const rejected of ['resta -3 y 4','suma 3 y 4 y 5','create code to add 99 and 100'])assert.throws(()=>understand(rejected));
assert.equal(sha(files.state),initialHash,'XI changed reusable disposable checkpoint');
const report={
 suite:'reversecoding_natural_orders',source:'Native REVERSE XI/Ether; host handles lexical normalization only',
 new_algorithms_learned:0,semantic_rules_engineered_in_xi:5,accepted:examples.length,
 rejected_by_xi:invalid.length,rejected_before_xi:3,
 programs_generated_and_executed:executions,
 calls:{nativeRuns,interpretations,codeEmissions,executions},
 checkpoint:{bytes:fs.statSync(files.state).size,sha256:initialHash,unchanged:true},
 examples:log,
 limits:'Binary arithmetic with two explicit 0..99 integers only; unknown or conflicting commands abstain.'
};
fs.writeFileSync(path.join(work,'reversecoding-evidence.json'),JSON.stringify(report,null,2)+'\n');
console.log('REVERSECODING_XI_OK '+JSON.stringify({accepted:examples.length,rejected:invalid.length+3,nativeRuns,checkpointPreserved:true}));
