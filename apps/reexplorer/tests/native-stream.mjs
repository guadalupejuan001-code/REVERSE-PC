#!/usr/bin/env node
// Real REVERSE-PC CLI black-box tests. The oracle transports bytes only;
// parsing, tag/script suppression and counters execute solely in XI/Ether.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
const [runtimeArg,buildArg,outArg]=process.argv.slice(2);
if(!runtimeArg||!buildArg||!outArg)throw Error('usage: node apps/reexplorer/tests/native-stream.mjs RUNNER BUILD OUT');
const cli=path.resolve(runtimeArg),app=path.resolve(buildArg,'REexplorer-Q-Stream.rxe'),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:true});
const B=8755000000000000000n,addr=n=>String(B+BigInt(n)),header='#!reverse-pc-machine-v1\n';
let checks=0,turns=0,batches=0,processed=0,parserMillis=0,transportMillis=0;
const check=(actual,want,label)=>{assert.deepEqual(actual,want,label);checks++};
function run(...args){
  return execFileSync(cli,args,{encoding:'utf8',maxBuffer:8*1024*1024});
}
const seed=path.join(out,'blank.rvp'),loadFile=path.join(out,'input.xi'),wire=path.join(out,'wire.rvp'),output=path.join(out,'stream.rvp');
run('init',seed);
let current=seed;
function step(command,bytes=Buffer.alloc(0),extra=''){
  assert.ok(bytes.length<=2049,'test of declared streaming limits');
  const input=header+'store8 '+addr(0)+' '+command+'\n'
    +'store8 '+addr(1)+' '+(bytes.length%256)+'\n'
    +'store8 '+addr(2)+' '+Math.floor(bytes.length/256)+'\n'
    +[...bytes].map((n,i)=>'store8 '+addr(128+i)+' '+n+'\n').join('')+extra+'halt\n';
  fs.writeFileSync(loadFile,input);
  const startA=process.hrtime.bigint();
  run('run',loadFile,current,wire);
  transportMillis+=Number(process.hrtime.bigint()-startA)/1e6;
  const startB=process.hrtime.bigint();
  const log=run('run',app,wire,output);
  parserMillis+=Number(process.hrtime.bigint()-startB)/1e6;
  const events=log.split('\n').filter(s=>s.startsWith('{')).map(s=>JSON.parse(s));
  const visible=Buffer.from(events.filter(e=>e.register==='r14').map(e=>e.value));
  const numbers=Object.fromEntries(events.filter(e=>/^r(0|1|2|3|12|13)$/.test(e.register)).map(e=>[e.register,e.value]));
  if(fs.existsSync(wire))fs.unlinkSync(wire);
  // output becomes the next committed RVPC2 state; the interpreter restarts.
  const target=path.join(out,'latest.rvp');
  fs.renameSync(output,target);
  current=target;turns++;
  return {visible,numbers};
}
function reset(){current=seed;return step(3);}
function feed(input,stepSize=0){
  const bytes=Buffer.isBuffer(input)?input:Buffer.from(input,'utf8');
  const seen=[],metrics=[];
  for(let off=0;off<bytes.length;){
    const width=stepSize||2048;
    const chunk=bytes.subarray(off,off+Math.min(2048,width));
    off+=chunk.length;
    const r=step(1,chunk);
    seen.push(r.visible);metrics.push(r.numbers);batches++;processed+=chunk.length;
  }
  return {text:Buffer.concat(seen).toString('utf8'),numbers:metrics.at(-1)};
}
function stable(name,html,expected,width=0){
  reset();
  const r=feed(html,width);
  check(r.text,expected,name+': independent UTF-8 visible text');
  check(r.numbers.r0,Buffer.byteLength(html,'utf8'),name+': bytes counted');
  check(r.numbers.r1,Buffer.byteLength(expected,'utf8'),name+': visible counted');
  check(r.numbers.r0,r.numbers.r1+r.numbers.r3,name+': every byte accounted for');
  check(r.numbers.r13,0,name+': within budget');
}
stable('HTML tags and scripts',
  '<html><head><script>window.password="SECRET";</script><style>body{display:none}</style></head><body><h1>Alpha</h1> <p>Omega</p></body></html>',
  'Alpha Omega',1);
stable('UTF-8 accents and multi-byte data',
  '<h1>Niño 🧠</h1><p>¡Árbol!</p>', 'Niño 🧠¡Árbol!',2);
stable('multiline and tag attributes',
  '<div class="x">Hola\n</div><p>mun\tdo</p>', 'Hola mundo',7);
stable('uppercase script and style',
  '<SCRIPT>EXFILTRATE</SCRIPT><STYLE>hidden</STYLE><p>SAFE</p>','SAFE',3);
stable('script contents split near close',
  '<script>bad <notclosing> stillbad </script><p>OK</p>','OK',1);
stable('safely displays plain text without markup',
  'Solo lectura; no ejecución de JS.','Solo lectura; no ejecución de JS.',31);
stable('unmatched script remains suppressed',
  'visible<script>alert(1)','visible',2);
stable('at boundary exact 224 bytes',
  'A'.repeat(224),'A'.repeat(224),224);
stable('bounded large response with many tags',
  '<span>t</span>'.repeat(1536),'t'.repeat(1536),2048);
stable('at the exact 2048-byte streaming boundary',
  'B'.repeat(2048),'B'.repeat(2048),2048);
// Reopen the large document for persistent state assertions below.
stable('bounded large response repeated for persistence',
  '<span>t</span>'.repeat(1536),'t'.repeat(1536),2048);
const status=step(2);
check(status.numbers.r0,Buffer.byteLength('<span>t</span>'.repeat(1536)), 'query persisted total after process restart');
check(status.numbers.r1,1536,'query persisted visible after restart');
reset();
const long=step(1,Buffer.from('ABCD'),[
  'store8 '+addr(4097)+' 254',
  'store8 '+addr(4098)+' 255',
  'store8 '+addr(4099)+' 15'
].join('\n')+'\n');
check(long.visible.toString('utf8'),'AB','1 MiB budget: only in-bounds bytes');
check(long.numbers.r0,1048576,'1 MiB budget reached exactly');
check(long.numbers.r13,1,'1 MiB budget permanently rejects future input until reset');
const afterFull=step(1,Buffer.from('MALICIOUS'));
check(afterFull.visible.length,0,'budget fail-closed');
check(afterFull.numbers.r0,1048576,'no overrun after budget');
reset();
const over=step(1,Buffer.alloc(2049,88));
check(over.numbers.r13,1,'oversized chunk refused');
check(over.numbers.r0,0,'oversized chunk did not partially mutate state');
const clean=reset();
check(clean.numbers.r13,0,'explicit reset revives parser');
check(clean.numbers.r0,0,'explicit reset clears old state');
const report={
  product:'REexplorer Q-Stream',checks,turns,batches,processed_bytes:processed,
  native_parser_ms:Math.round(parserMillis),native_mailbox_transport_ms:Math.round(transportMillis),
  scope:'Native XI/RXE streaming text renderer; no real network I/O, TLS, JavaScript, CSS or browser login',
  qbits_required:0,quantum_speedup_claimed:false,bbq_controller_connected:false,
  safety:['no scripts executed','script/style contents suppressed in designed forms',
    '1 MiB bounded work','state persists between CLI runs','UTF-8 bytes preserved',
    'status/reset','oversize fail-closed'],
  deployment_status:'native CLI executable, no end-to-end Robinhood navigation claim'
};
fs.writeFileSync(path.join(out,'native-stream-results.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report,null,2));
