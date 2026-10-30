import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {execFileSync,spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const [bbyq,runtime,out]=process.argv.slice(2);
if(!out)throw Error('Usage: test.mjs BBYQ_SOURCE RUNTIME NEW_TEST_DIRECTORY');
const cli=fileURLToPath(new URL('./run.mjs',import.meta.url)),root=path.resolve(out),build=path.join(root,'bundle'),session=path.join(root,'session'),rows=[];
fs.mkdirSync(root,{recursive:true});
function run(operation,extra={}) {const args=[cli,operation,'--bbyq',path.resolve(bbyq),'--build',build];for(const [k,v]of Object.entries(extra))args.push('--'+k,String(v));const result=JSON.parse(execFileSync(process.execPath,args,{encoding:'utf8',timeout:180000,maxBuffer:8*1024*1024}));rows.push({operation,...result});assert.ok(result.ok,result.error?.message);return result;}
run('prepare');run('verify');run('init',{session});
const options={runtime:path.resolve(runtime),session};
let result=run('turn',{...options,id:'hello-1',text:'traduce al ingles: yo tengo tres coches'});assert.match(result.response,/I have three cars/);
const replay=run('turn',{...options,id:'hello-1',text:'traduce al ingles: yo tengo tres coches'});assert.equal(replay.replayed,true);assert.equal(replay.generation,result.generation);
result=run('turn',{...options,id:'book-1',text:'lee pagina 122'});assert.match(result.response,/122/);
const message=path.join(root,'multiline.txt');fs.writeFileSync(message,'resume en 1 frases:\nEl prototipo llega el jueves. No incluye sensores.');
result=run('turn',{...options,id:'summary-1',file:message});assert.equal(result.response,'Resumen extractivo: El prototipo llega el jueves.');
result=run('turn',{...options,id:'code-1',text:'Crea y ejecuta un programa en XI que multiplique 12 por 7.'});assert.equal(result.executed,true);assert.ok(result.response.includes('84'),result.response);
const before=fs.readFileSync(path.join(session,'HEAD.json'),'utf8');
const bad=spawnSync(process.execPath,[cli,'turn','--bbyq',path.resolve(bbyq),'--build',build,'--runtime',path.resolve(runtime),'--session',session,'--id','hello-1','--text','different content'],{encoding:'utf8',timeout:30000});
assert.equal(bad.status,1);assert.equal(JSON.parse(bad.stdout).error.code,'E_REPLAY_MISMATCH');assert.equal(fs.readFileSync(path.join(session,'HEAD.json'),'utf8'),before);
fs.appendFileSync(path.join(build,'native','front.rxe'),'changed');
const declaration=JSON.parse(fs.readFileSync(path.join(build,'release.json')));
declaration.archives.native.files['front.rxe']=crypto.createHash('sha256').update(fs.readFileSync(path.join(build,'native','front.rxe'))).digest('hex');
fs.writeFileSync(path.join(build,'release.json'),JSON.stringify(declaration)); // A rewritten local declaration cannot override the pinned profile.
const tampered=spawnSync(process.execPath,[cli,'verify','--bbyq',path.resolve(bbyq),'--build',build],{encoding:'utf8',timeout:30000});assert.notEqual(tampered.status,0);
const report={ok:true,checks:19,pinned_source:true,translation:true,book_page_122:true,multiline_summary:true,xi_program_executed:true,idempotent_retry:true,reused_id_rejected:true,tampering_rejected:true,android_tested:false};
fs.writeFileSync(path.join(root,'results.json'),JSON.stringify(report,null,2)+'\n');fs.writeFileSync(path.join(root,'transcripts.json'),JSON.stringify(rows,null,2)+'\n');console.log(JSON.stringify(report));
