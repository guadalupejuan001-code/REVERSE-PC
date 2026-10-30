'use strict';
// UI transport and integration checks. This is NOT proof of native XI execution;
// see qd-native.cjs and Android instrumentation for that evidence.
const fs=require('node:fs'),path=require('node:path'),vm=require('node:vm'),assert=require('node:assert/strict');
const folder=path.join(__dirname,'../app/src/main/assets/workbench');
const qd=fs.readFileSync(path.join(folder,'qd-studio.js'),'utf8');
const desktop=fs.readFileSync(path.join(folder,'desktop.js'),'utf8');
const html=fs.readFileSync(path.join(folder,'index.html'),'utf8');
const activity=fs.readFileSync(path.join(__dirname,'../app/src/main/java/com/reversepc/os/WorkbenchActivity.java'),'utf8');
const engine=fs.readFileSync(path.join(__dirname,'../app/src/main/java/com/reversepc/os/QdEngine.java'),'utf8');
const listener={};const jobs=[];let saves=0,renders=0,completed=0;
const w={id:'qdtest',app:'qd',qdSkill:1,qdA:27,qdB:8,qdDrafts:{}};
const ctx=vm.createContext({
 document:{addEventListener(type,handler){listener[type]=handler;}},
 nativeAvailable:true,APP_DESCRIPTIONS:{},w,
 queueMicrotask(fn){jobs.push(fn);},queueSave(){saves++;},
 getWindow(id){return id===w.id?w:undefined;},
 renderWindowContent(owner){assert.equal(owner,w);renders++;},
 icon(name){return '<i>'+name+'</i>';},
 esc(input){return String(input??'').replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');},
 toast(){},refreshPrograms(){},openProgram(){},nativeRequest(operation,raw){
  const p=JSON.parse(raw);completed++;
  if(operation==='compileApp')return Promise.resolve({ok:true,path:'Aplicaciones/Qd-Cody-Suma.rxe'});
  assert.equal(operation,'qd');assert.equal(p.skill,undefined===p.skill?undefined:1);
  if(p.action==='status')return Promise.resolve({ok:true,learned:[false,false,false,false],approved_lessons:0});
  if(p.action==='evaluate')return Promise.resolve({ok:true,passed:4,total:4,cases:[],all_passed:true});
  if(p.action==='teach')return Promise.resolve({ok:true,learned:true,passed:8,total:8,cases:[],status:{learned:[true,false,false,false],approved_lessons:1}});
  if(p.action==='solve')return Promise.resolve({ok:true,learned:true,pass:true,actual:35,expected:35,program:'#!reverse-pc-machine-v1\nset r0 27\nadd r0 8\nprint r0\nhalt\n'});
  throw Error('Unexpected action '+p.action);
 }
});
vm.runInContext(qd,ctx,{filename:'qd-studio.js'});
assert.match(desktop,/qd:\{name:'Qd · Cody'/);assert.match(desktop,/qdStudioHTML\(w\)/);assert.match(desktop,/qdDrafts:Object\.fromEntries/);
assert.match(desktop,/qdSessions.delete/);assert.match(html,/src="qd-studio.js"/);
assert.match(html,/href="qd-studio.css"/);assert.match(activity,/else if\("qd"\.equals\(operation\)\)/);
assert.match(engine,/NativeRuntime\.execute\(NativeRuntime\.initialize\(\),source\)/);
assert.match(qd,/data-qd-action="teach"/);
assert.match(qd,/data-qd-action="solve"/);
const initial=vm.runInContext('qdStudioHTML(w)',ctx);assert.match(initial,/Qd/);assert.match(initial,/Suma/);
async function main(){
 await vm.runInContext('qdLoad(w)',ctx);
 await vm.runInContext("qdAction(w,'evaluate')",ctx);
 let s=vm.runInContext('qdSessions.get(w.id)',ctx);assert.equal(s.result.data.total,4);
 await vm.runInContext("qdAction(w,'teach')",ctx);
 assert.equal(s.learned[0],true);assert.equal(s.approved,1);
 await vm.runInContext("qdAction(w,'solve')",ctx);
 assert.equal(s.result.data.actual,35);assert.match(s.generated,/set r0 27/);
 const output=vm.runInContext('qdStudioHTML(w)',ctx);
 assert.match(output,/Programa generado/);assert.match(output,/APROBADO/);
 const target={value:'#!reverse-pc-machine-v1\nset r0 {{a}}\nsub r0 {{b}}\nprint r0\nhalt\n',
  matches(sel){return sel==='[data-qd-source]';},
  closest(sel){return sel==='.window'?{dataset:{id:w.id}}:undefined;}};
 listener.input({target});
 assert.match(w.qdDrafts['1'],/sub r0/);
 assert.equal(s.generated,null);
 console.log(JSON.stringify({test:'qd_cody_studio_ui',passed:true,saves,renders,requests:completed,real_xi_execution_tested_here:false}));
}
main().catch(e=>{console.error(e);process.exitCode=1});
