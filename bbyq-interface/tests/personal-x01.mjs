// Exercise the actual APK capsule and its migration, never simulated answers.
import fs from'node:fs';import path from'node:path';import crypto from'node:crypto';import assert from'node:assert/strict';import{execFileSync,spawnSync}from'node:child_process';
const[r,b,c,o]=process.argv.slice(2);if(!o)throw Error('usage: personal-x01.mjs RUNTIME E025_BUILD PERSONAL_BUILD NEW_OUTPUT');
const[runtime,base,caps,out]=[r,b,c,o].map(x=>path.resolve(x));if(fs.existsSync(out))throw Error('Use a fresh output');fs.mkdirSync(out,{recursive:true});
const P=9050000000000000000n,A=8200000000000000000n,M=8300000000000000000n,app=path.join(caps,'BBY-Q.rxe'),live=path.join(out,'live.rvp'),hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
let checks=0;const rows=[],eq=(a,b,l)=>{assert.deepEqual(a,b,l);checks++;};
function run(...a){return execFileSync(runtime,a,{encoding:'utf8',timeout:30000,maxBuffer:8*1024*1024});}
function ask(text,image=app){const output=run('app-turn',image,live,live,'es',text).trimEnd();rows.push({text,output});return output;}
function snapshot(file=live){const b=fs.readFileSync(file),n=Number(b.readBigUInt64LE(5)),mem=new Map(),bindings=[];for(const row of b.subarray(29+n).toString().split('\n').slice(2).filter(Boolean)){const[t,a,v]=row.split(' ');if(t==='O'){if(+v)mem.set(BigInt(a),+v);}else bindings.push(row);}return{core:b.subarray(29,29+n).toString('base64'),mem,bindings};}
const legacy=s=>[...s.mem].filter(([a])=>a<P||a>=P+16384n),at=n=>snapshot().mem.get(P+BigInt(n))||0;
const old=snapshot(path.join(caps,'parent.rvp')),trained=snapshot(path.join(caps,'controller.rvp'));
eq(legacy(trained),[...old.mem],'all old E025 memory retained');eq(trained.core,old.core,'old quantum core retained');eq(trained.bindings,old.bindings,'old bindings retained');eq(trained.mem.get(P+2n),59,'59 taught records in APK seed');
fs.copyFileSync(path.join(caps,'controller.rvp'),live);
eq(ask('hola'),'Hola, X. Te leo.','APK greeting uses personal lesson');ask('oye pz siguiente xD');eq(at(8),2,'decorated continuation recognized');eq(at(9),1,'no invented task without context');
ask('@x tarea Android en REVERSE');eq(ask('oye pz siguiente xD').includes('Android en REVERSE'),true,'APK uses explicit task');eq(at(8),2,'continuation intent');
for(const[text,intent,mode]of[['en resumen nada aun? xD',3,0],['no hagas nada solo dime',6,2],['usa mi tecnologia no? XD',8,0],['no me sale el apk',13,0]]){ask(text);eq(at(8),intent,text);eq(at(10),mode,'requested policy '+text);}
ask('no, hazlo');eq(at(8),0,'negation does not activate a positive alias');eq(at(10),0,'request does not survive next unknown message');
// E025 learned facts, arithmetic and desktop actions remain in the same app.
eq(ask('que es calculadora').includes('Calculadora es herramienta'),true,'desktop knowledge');
for(let i=0;i<4;i++){const q='qelora'+String.fromCharCode(97+i);eq(ask('aprende que '+q+' es animal').includes('Aprendí'),true,'learn old factual concept');eq(ask('que es '+q).includes('animal'),true,'recall old factual concept');}
eq(ask('ana tiene dos manzanas'),'Ana tiene dos manzanas.','quantity fact');eq(ask('ella recibe tres mas'),'Ana tiene cinco manzanas.','quantity update');
const setup=path.join(out,'observation.xi');let source='#!reverse-pc-machine-v1\n';for(const[a,v]of[[A+16n,1],[A+17n,2],[A+18n,1]])source+=`store8 ${a} ${v}\n`;
for(let i=0;i<32;i++)for(const[a,v]of[[A+32n+BigInt(i),i===2?1:0],[M+640n+BigInt(i),0],[M+672n+BigInt(i),0],[M+512n+BigInt(i),0]])source+=`store8 ${a} ${v}\n`;
fs.writeFileSync(setup,source+'halt\n');run('run',setup,live,live);ask('maximiza calculadora');let s=snapshot();eq([s.mem.get(A+64n),s.mem.get(A+65n)],[4,2],'W4u still proposes observed calculator maximization');
ask('solo dime');s=snapshot();eq(s.mem.get(A+64n)||0,0,'personal request cannot replay pending desktop action');eq(s.mem.get(A+65n)||0,0,'stale target cleared');
// Upgrading an existing E025 session adds only personal state, retaining facts.
fs.copyFileSync(path.join(base,'controller.rvp'),live);ask('aprende que zelorax es animal',path.join(base,'BBY-Q.rxe'));const before=snapshot(),oldHash=hash(live);
const migrated=path.join(out,'migrated.rvp');run('run',path.join(caps,'upgrade-x01.rxe'),live,migrated);eq(hash(live),oldHash,'old file retained for rollback');eq(legacy(snapshot(migrated)),legacy(before),'used state retains every previous cell');fs.copyFileSync(migrated,live);eq(ask('que es zelorax').includes('animal'),true,'old user knowledge available after upgrade');eq(ask('hola'),'Hola, X. Te leo.','personal lesson available after upgrade');
// A collision prevents publication of any upgraded state.
fs.copyFileSync(path.join(base,'controller.rvp'),live);fs.writeFileSync(setup,`#!reverse-pc-machine-v1\nstore8 ${P+600n} 77\nhalt\n`);run('run',setup,live,live);const stable=hash(live),denied=path.join(out,'denied.rvp');const p=spawnSync(runtime,['run',path.join(caps,'upgrade-x01.rxe'),live,denied],{encoding:'utf8',timeout:30000});eq(p.status!==0,true,'namespace collision rejected');eq(fs.existsSync(denied),false,'conflicting migration publishes nothing');eq(hash(live),stable,'conflict retains prior state');
const report={checks,apk_personalization:'X01',app_sha256:hash(app),lessons:59,preserved_e025_memory:true,existing_learning_and_w4u_verified:true,pending_actions_not_replayed:true,android_device_tested:false};fs.writeFileSync(path.join(out,'results.json'),JSON.stringify(report,null,2)+'\n');fs.writeFileSync(path.join(out,'transcripts.json'),JSON.stringify(rows,null,2)+'\n');console.log(JSON.stringify(report));
