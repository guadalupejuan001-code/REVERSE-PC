'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),vm=require('node:vm'),crypto=require('node:crypto'),cp=require('node:child_process');
const root=path.resolve(__dirname,'../..'),assets=path.join(root,'reverse-os-android/app/src/main/assets/workbench');
const owner=fs.readFileSync(path.join(assets,'desktop.js'),'utf8'),controls=fs.readFileSync(path.join(assets,'control-center.js'),'utf8');
function extract(text,name){
  const start=text.search(new RegExp('^(?:async )?function '+name+'\\b','m'));assert.ok(start>=0,name);
  const lineEnd=text.indexOf('\n',start),first=text.slice(start,lineEnd);
  if(first.trimEnd().endsWith('}'))return first;
  const end=text.indexOf('\n}',lineEnd);assert.ok(end>=0,'Unclosed '+name);
  return text.slice(start,end+2);
}
const ctx=vm.createContext({console,structuredClone,TextEncoder,Map,Set,Promise});
vm.runInContext(`
let state={windows:[],files:[],space:0},activeId=null,zCounter=0,serial=0,saves=0,persistOK=true,persistEdit=false;
const APP_DESCRIPTIONS={},nativeAvailable=true;
const elements=new Map(),messages=[];
const document={addEventListener(){}};const window={addEventListener(){}};
function $(s){if(s==='#workspace-label')return {};return elements.get(s.slice(1));}
function $$(s){return s==='.window'?[...elements.values()]:[];}
function area(){return {w:1280,h:800};}const innerWidth=1280;
function uid(){return String(++serial);}
function clampWindow(w){w.w=Math.min(w.w,1260);w.h=Math.min(w.h,760);}
function geometry(w,el){if(el){el.min=!!w.min;el.max=!!w.max;}}
function mountWindow(w){const el={id:w.id,dataset:{id:w.id},classList:{toggle(){}},remove(){elements.delete(w.id);}};elements.set(w.id,el);}
function renderDock(){}function refreshControlLists(){}function renderWindowContent(){}function hideLauncher(){}
function queueSave(){saves++;}function toast(message){messages.push(message);}
function createFile(type,name,parent,content){const f={id:'f'+uid(),type,name,parent,content};state.files.push(f);return f;}
async function persist(){if(persistEdit&&state.files.length)state.files[0].content='edición concurrente';return persistOK;}
function refreshAndroid(){}
function esc(x){return String(x);}function icon(){return '';}
`,ctx);
// Use the shipped desktop's actual window implementations, not a second state
// machine. DOM drawing and Android persistence are fixtures in this host test.
vm.runInContext(owner.match(/^const APPS = .*$/m)[0]+'\n'+owner.match(/^Object\.assign\(APPS,.*$/m)[0],ctx);
for(const name of ['getWindow','focusWindow','createWindow','closeWindow','minimizeWindow','toggleMax','switchSpace','arrangeWindows'])vm.runInContext(extract(owner,name),ctx);
vm.runInContext(extract(controls,'selectTopWindow'),ctx);
vm.runInContext(fs.readFileSync(path.join(assets,'bbyq-control.js'),'utf8'),ctx);
vm.runInContext(fs.readFileSync(path.join(assets,'programs.js'),'utf8'),ctx);
const evaluate=s=>vm.runInContext(s,ctx),snapshot=()=>JSON.parse(evaluate('JSON.stringify(state)'));
let checks=0;
function yes(value){assert.ok(value);checks++;}
async function action(op,target,modify){
  const observation=evaluate('captureBbyqDesktop("trusted")');
  if(modify)modify();const request={op,target,ticket:crypto.randomUUID(),view:observation.view};
  ctx.request=request;ctx.observation=observation;
  const result=await evaluate('executeBbyqControl(request,observation,"trusted")');return {result,request,observation};
}
(async()=>{
  const contract=JSON.parse(fs.readFileSync(path.join(root,'bbyq-interface/data/interface.json'),'utf8'));
  for(const t of contract.targets.filter(t=>t.kind===1))yes(evaluate('BBYQ_TARGETS['+t.id+']')===t.app);
  evaluate('createWindow("bbyq").rxeIdentity="trusted"');
  yes((await action(1,1)).result.success);yes(snapshot().windows.filter(w=>w.app==='files').length===1);
  yes((await action(1,1)).result.success);yes(snapshot().windows.length===2);
  yes((await action(3,1)).result.success);yes(snapshot().windows.find(w=>w.app==='files').min);
  yes((await action(2,1)).result.success);yes(!snapshot().windows.find(w=>w.app==='files').min);
  yes((await action(4,1)).result.success);yes((await action(4,1)).result.success);yes(snapshot().windows.find(w=>w.app==='files').max);
  yes((await action(5,1)).result.success);yes(!snapshot().windows.find(w=>w.app==='files').max);
  yes((await action(6,1)).result.success);yes(!snapshot().windows.some(w=>w.app==='files'));
  yes(!(await action(6,1)).result.success);
  const stale=await action(1,1,()=>evaluate('createWindow("calculator")'));yes(!stale.result.success);yes(!snapshot().windows.some(w=>w.app==='files'));
  const once=await action(1,1);yes(once.result.success);ctx.request=once.request;ctx.observation=once.observation;
  yes(!(await evaluate('executeBbyqControl(request,observation,"trusted")')).success);yes(snapshot().windows.filter(w=>w.app==='files').length===1);
  yes(!(await action(255,1)).result.success);
  yes((await action(7,0)).result.success);yes((await action(8,0)).result.success);yes(snapshot().windows.every(w=>w.min));
  evaluate('focusWindow(state.windows.find(w=>w.app==="rxe").id)');
  yes((await action(9,14)).result.success);yes(snapshot().space===1);yes((await action(9,13)).result.success);yes(snapshot().space===0);
  const count=snapshot().windows.length;evaluate('persistOK=false');yes(!(await action(1,9)).result.success);yes(snapshot().windows.length===count);yes(snapshot().files.length===0);
  evaluate('persistOK=true');yes((await action(1,9)).result.success);yes(snapshot().files.length===1);
  evaluate('state.files[0].content="mi nota"');yes((await action(6,9)).result.success);yes(snapshot().files[0].content==='mi nota');
  evaluate('persistOK=false;persistEdit=true');yes(!(await action(1,9)).result.success);yes(snapshot().files[0].content==='edición concurrente');
  evaluate('persistOK=true;persistEdit=false');
  yes((await action(1,1,()=>evaluate('for(const w of state.windows){w.y=5;w.h=250;}'))).result.success);
  // Empty restoration and catalog operations cannot dispatch saved commands.
  yes(!/executeBbyqControl/.test(extract(fs.readFileSync(path.join(assets,'programs.js'),'utf8'),'loadProgram')));

  const [runtime,build]=process.argv.slice(2);let endToEnd=0;
  if(runtime&&build){
    const A=8200000000000000000n,agent=path.join(build,'ui-agent.rvp'),image=path.join(build,'BBY-Q.rxe'),event=path.join(build,'ui-event.xi');
    fs.copyFileSync(path.join(build,'controller.rvp'),agent);
    const run=(...args)=>cp.execFileSync(runtime,args,{encoding:'utf8',maxBuffer:32*1024*1024,stdio:['ignore','pipe','pipe']});
    const meta=JSON.parse(run('inspect-rxe',image)),identity=crypto.createHash('sha256').update(fs.readFileSync(image)).digest('hex');
    let history=[],pending=null,currentLanguage=1;
    ctx.nativeRequest=async(operation,raw)=>{
      const p=JSON.parse(raw);
      if(operation==='askApp'){
        currentLanguage=p.language;
        let code=`#!reverse-pc-machine-v1\nstore8 ${A+16n} 1\nstore8 ${A+17n} ${p.desktop.active}\nstore8 ${A+18n} ${p.desktop.count}\n`;
        p.desktop.present.forEach((n,i)=>code+=`store8 ${A+32n+BigInt(i)} ${n}\n`);
        fs.writeFileSync(event,code);run('run',event,agent,agent);
        const text=run('app-turn',image,agent,agent,p.language===1?'es':'en',p.text).trim();
        const clean=fs.readFileSync(path.join(root,'bbyq-interface/xi/consume.xi'),'utf8').split('\n').slice(1).join('\n');
        fs.writeFileSync(event,`#!reverse-pc-machine-v1\nload8 r0 ${A+64n}\nprint r0\nload8 r1 ${A+65n}\nprint r1\n`+clean);
        const values=run('run',event,agent,agent).split('\n').filter(s=>s.startsWith('{')).map(s=>JSON.parse(s).value);
        history.push({role:'user',text:p.text},{role:'assistant',text});
        pending=values[0]?{op:values[0],target:values[1],view:p.desktop.view,ticket:crypto.randomUUID()}:null;
      }else if(operation==='ackControl'){
        assert.ok(pending&&pending.ticket===p.ticket);
        const feedback=fs.readFileSync(path.join(root,'reverse-os-android/app/src/main/assets/bbyq-interface/feedback.xi'),'utf8').split('\n').slice(1).join('\n');
        fs.writeFileSync(event,`#!reverse-pc-machine-v1\nstore8 7400000000000000003 ${currentLanguage}\nstore8 ${A+67n} ${p.success?2:3}\n`+feedback);
        const values=run('run',event,agent,agent).split('\n').filter(s=>s.startsWith('{')).map(s=>JSON.parse(s)).filter(x=>x.register==='r14').map(x=>x.value);
        history.at(-1).text=Buffer.from(values).toString('utf8');pending=null;endToEnd++;
      }else throw Error('Unexpected fixture operation '+operation);
      return {ok:true,path:'Aplicaciones/BBY-Q.rxe',identity,metadata:meta,desktop_control:true,history:structuredClone(history),language:currentLanguage,...(pending?{control:pending}:{})};
    };
    ctx.initial={ok:true,path:'Aplicaciones/BBY-Q.rxe',identity,metadata:meta,desktop_control:true,history:[],language:1};
    evaluate('state.windows=[];state.files=[];state.space=0;elements.clear();programSessions.clear();let actorWindow=createWindow("bbyq");actorWindow.rxeIdentity=initial.identity;programSessions.set(actorWindow.id,{busy:false,language:1,snapshot:initial,error:"",uncertain:false});');
    for(const text of ['abre archivos','maximiza archivos','restaura archivos','minimiza archivos','muestra archivos','cierra archivos','abre calculadora','ordena las ventanas']){
      ctx.commandText=text;await evaluate('actorWindow=getWindow(actorWindow.id);focusWindow(actorWindow.id);actorWindow.rxeDraft=commandText;transactProgram(actorWindow,"askApp")');
      assert.equal(history.at(-1).text,'Acción completada.');checks++;
    }
    for(const text of ['open files','close files']){
      ctx.commandText=text;await evaluate('focusWindow(actorWindow.id);programSessions.get(actorWindow.id).language=2;actorWindow.rxeDraft=commandText;transactProgram(actorWindow,"askApp")');
      assert.equal(history.at(-1).text,'Action completed.');checks++;
    }
    for(const [text,app]of [['abre ajustes','settings'],['abre aplicaciones','programs'],['abre xi studio','xi'],['abre ayuda','help'],['abre centro de control','control'],['abre fondo','wallpaper'],['abre notas','notes']]){
      ctx.commandText=text;await evaluate('focusWindow(actorWindow.id);programSessions.get(actorWindow.id).language=1;actorWindow.rxeDraft=commandText;transactProgram(actorWindow,"askApp")');
      assert.equal(history.at(-1).text,'Acción completada.');checks++;yes(snapshot().windows.some(w=>w.app===app));
    }
    yes(snapshot().windows.some(w=>w.app==='calculator'));yes(!snapshot().windows.some(w=>w.app==='files'));yes(endToEnd===17);
    fs.writeFileSync(path.join(build,'desktop-results.json'),JSON.stringify({checks,native_backed_actions:endToEnd,history,scope:'Shipped JS window functions and real XI via CLI; DOM drawing/Android storage are fixtures'},null,2)+'\n');
  }
  console.log('BBYQ_DESKTOP_CONTROL_PASS',JSON.stringify({checks,native_backed_actions:endToEnd,restore_does_not_replay:true,stale_and_duplicate_actions_rejected:true}));
})().catch(error=>{console.error(error);process.exitCode=1;});
