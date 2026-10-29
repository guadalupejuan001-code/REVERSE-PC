'use strict';
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const cp=require('node:child_process');

const [runtimeArg,outArg]=process.argv.slice(2);
if(!runtimeArg||!outArg)throw Error('usage: node bbyq-interface/tests/robinhood-native.cjs RUNTIME OUT');
const runtime=path.resolve(runtimeArg),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:true});
const root=path.resolve(__dirname,'../..');
const original=fs.readFileSync(path.join(root,'bbyq-interface/xi/open-robinhood.xi'),'utf8');
const mirror=fs.readFileSync(path.join(root,'reverse-os-android/app/src/main/assets/workbench/xi-open-robinhood.xi'),'utf8');
const feedback=fs.readFileSync(path.join(root,'reverse-os-android/app/src/main/assets/workbench/xi-robinhood-feedback.xi'),'utf8');
assert.equal(original,mirror,'the installed XI must match first-party authored XI source');
assert.equal(feedback,fs.readFileSync(path.join(root,'bbyq-interface/xi/robinhood-feedback.xi'),'utf8'));
function native(...args){return cp.execFileSync(runtime,args,{encoding:'utf8',maxBuffer:4*1024*1024});}
function sourceWithBody(body){assert.ok(body.startsWith('#!reverse-pc-machine-v1\n'));return body.slice(body.indexOf('\n')+1);}
const seed=path.join(out,'seed.rvp');
native('init',seed);
const compiled=path.join(out,'browser-intent.rxe');
native('compile',path.join(root,'bbyq-interface/xi/open-robinhood.xi'),compiled,'BBY Q browser intent');
let checks=2;
function outputs(text) {
  const raw=text.split('\n').filter(s=>s.startsWith('{')).map(s=>JSON.parse(s));
  return raw.filter(o=>o.register==='r14'||o.register==='r9').map(o=>o.value);
}
function probe(message,lang='es'){
  const bytes=Buffer.from(message,'utf8');
  assert.ok(bytes.length<=255);
  const inject='# !'.replace(' ','')+'reverse-pc-machine-v1\n'
    +`store8 7400000000000000003 ${lang==='es'?1:2}\n`
    +`store8 7400000000000000016 1\nstore8 7400000000000000017 ${bytes.length}\n`
    +[...bytes].map((v,i)=>`store8 ${7400000000000000128n+BigInt(i)} ${v}\n`).join('')
    +sourceWithBody(original);
  const script=path.join(out,'probe.xi'),state=path.join(out,'probe.rvp');
  fs.writeFileSync(script,inject);
  const line=native('run',script,seed,state);
  const result=Buffer.from(outputs(line)).toString('utf8');
  const audit=path.join(out,'audit.xi'),resultState=path.join(out,'audit.rvp');
  fs.writeFileSync(audit,'#!reverse-pc-machine-v1\n'
    +'load8 r0 8200000000000000064\nprint r0\n'
    +'load8 r0 8200000000000000065\nprint r0\n'
    +'load8 r0 8200000000000000067\nprint r0\n'
    +'load8 r0 7400000000000000017\nprint r0\nhalt\n');
  const values=native('run',audit,state,resultState).split('\n').filter(s=>s.startsWith('{')).map(s=>JSON.parse(s).value);
  fs.rmSync(state,{force:true});fs.rmSync(resultState,{force:true});
  return {result,op:values[0],target:values[1],status:values[2],inputLength:values[3]};
}
const supported=[
  ['abre Robinhood','es'],['ABRE ROBINHOOD.','es'],['abre roobinhood','es'],
  ['abre robinhood en el navegador','es'],['abre robinhood en navegador','es'],
  ['quiero abrir robinhood','es'],['puedes abrir robinhood','es'],
  ['¿puedes abrir Robinhood?','es'],['abre la página de robinhood','es'],
  ['open Robinhood','en'],['OPEN ROBINHOOD.','en'],['please open robinhood','en'],
  ['open robinhood in the browser','en'],['open robinhood website','en']
];
for(const [message,language] of supported){
  const r=probe(message,language);
  assert.equal(r.op,11,message);assert.equal(r.target,11,message);assert.equal(r.status,1,message);
  assert.equal(r.inputLength,0,'matched message mailbox must be scrubbed');
  assert.equal(r.result,language==='es'?'Voy a abrir Robinhood en el navegador.':'Opening Robinhood in your browser.');
  checks+=5;
}
const forbidden=[
  'no abras robinhood','no abras Robinhood por favor','cierra robinhood',
  'que es robinhood','quiero invertir en robinhood','robinhood',
  'Robinhood no abre','abre roobinhood y compra bitcoin','abre robinhood.com.evil.site',
  'abre robinhood / comprar opciones','te doy mi contraseña de robinhood',
  'open robinhood then sell everything','dont open robinhood','open robinhood support',
  'open robinhoodhttps://fake.com','abre tu broker favorito'
];
for(const message of forbidden){
  const r=probe(message);
  assert.deepEqual([r.op,r.target,r.status],[0,0,0],message);
  assert.equal(r.result,'','negative query must yield no web action');
  checks+=2;
}
function fb(success,language){
  const script=path.join(out,'feedback.xi'),state=path.join(out,'feedback.rvp');
  fs.writeFileSync(script,'#!reverse-pc-machine-v1\n'
    +`store8 7400000000000000003 ${language==='en'?2:1}\n`
    +`store8 8300000000000000080 ${success?1:0}\n`
    +sourceWithBody(feedback));
  const r=Buffer.from(outputs(native('run',script,seed,state))).toString('utf8');
  fs.rmSync(state,{force:true});
  return r;
}
assert.equal(fb(true,'es'),'Robinhood se abrió en el navegador.');
assert.equal(fb(false,'es'),'No se pudo abrir Robinhood en el navegador.');
assert.equal(fb(true,'en'),'Robinhood opened in the browser.');
assert.equal(fb(false,'en'),'Robinhood could not be opened in the browser.');
checks+=4;
const result={checks,supported:supported.length,rejected:forbidden.length,feedback:4,
  selected_action:{op:11,target:11},site:'https://robinhood.com/',
  interpreter:'XI only',scope:'Native Linux XI interpreter; Android activity launch is tested separately.'};
fs.writeFileSync(path.join(out,'robinhood-native.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
