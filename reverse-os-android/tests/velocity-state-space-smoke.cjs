#!/usr/bin/env node
'use strict';
// Operates the actual installed game: save, kill, restart, restore and drive.
const cp=require('node:child_process'),fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const [adb='adb',out='build/velocity-state-space']=process.argv.slice(2),pkg='com.reversepc.velocity';
fs.mkdirSync(out,{recursive:true});const report={passed:false,emulator:true,checks:[],processRestart:false};
const sleep=ms=>Atomics.wait(new Int32Array(new SharedArrayBuffer(4)),0,0,ms);
function run(args,binary=false,timeout=30000){const r=cp.spawnSync(adb,args,{encoding:binary?null:'utf8',timeout,maxBuffer:80*1024*1024});assert.ifError(r.error);assert.equal(r.status,0,String(r.stderr));return r.stdout;}
function logs(){return run(['logcat','-d','-v','brief','ReverseVelocity:I','AndroidRuntime:E','*:S']);}
function wait(test,label,ms=60000){const end=Date.now()+ms;while(Date.now()<end){assert(!/FATAL EXCEPTION|GPU_FALLBACK|Race worker failed/.test(logs()),'real game failed');const value=test();if(value)return value;sleep(250);}throw Error('Timed out: '+label);}
function check(ok,label){assert(ok,label);report.checks.push(label);}
function decode(s){return s.replace(/&#(\d+);/g,(_,n)=>String.fromCodePoint(Number(n))).replace(/&quot;/g,'"').replace(/&apos;/g,"'").replace(/&amp;/g,'&');}
function ui(){
 for(let i=0;i<7;i++){
  const status=run(['shell','uiautomator','dump','--compressed','/sdcard/velocity-state-ui.xml']);if(/ERROR|Exception|could not/.test(status)){sleep(250);continue;}
  const text=run(['shell','cat','/sdcard/velocity-state-ui.xml']);
  const nodes=[...text.matchAll(/<node\b([^>]+)>/g)].map(m=>Object.fromEntries([...m[1].matchAll(/([\w-]+)="([^"]*)"/g)].map(a=>[a[1],decode(a[2])])));
  if(nodes.some(n=>n.package===pkg))return nodes.filter(n=>n.package===pkg);sleep(250);
 }throw Error('No current game hierarchy');
}
function rect(node){return /\[(\d+),(\d+)\]\[(\d+),(\d+)\]/.exec(node.bounds).slice(1).map(Number);}
function tap(node){assert(node,'missing UI control');const [l,t,r,b]=rect(node);run(['shell','input','tap',String(Math.round((l+r)/2)),String(Math.round((t+b)/2))]);sleep(180);}
function key(name){run(['shell','input','keyevent',name]);}
function row(title){for(let i=0;i<10;i++){
 const nodes=ui(),button=nodes.find(n=>n.class?.endsWith('Button')&&n.text?.startsWith(title+'\n'));
 if(button&&rect(button)[3]-rect(button)[1]>24){tap(button);return;}
 const scroll=nodes.find(n=>n.scrollable==='true');assert(scroll,'menu scroll missing');const [l,t,r,b]=rect(scroll);
 run(['shell','input','swipe',String(Math.round((l+r)/2)),String(b-20),String(Math.round((l+r)/2)),String(t+20),'250']);
 }throw Error('Missing row: '+title);}
function open(){key('KEYCODE_ESCAPE');wait(()=>ui().some(n=>n.text==='Tu recorrido'),'main menu');}
function preset(id){
 row('Gráficos');const name=['Ahorro','Bajos','Medio','Alto','Ultra'][id];
 for(let i=0;i<8;i++){
  const nodes=ui(),button=nodes.find(n=>n['content-desc']?.startsWith('Gráficos: '+name));
  if(button&&rect(button)[3]-rect(button)[1]>30){tap(button);break;}
  const scroll=nodes.find(n=>n.scrollable==='true'),[l,t,r,b]=rect(scroll);
  run(['shell','input','swipe',String((l+r)/2),String(id<=2?t+22:b-22),String((l+r)/2),String(id<=2?b-22:t+22),'250']);
 }
 wait(()=>ui().some(n=>n['content-desc']?.startsWith('Gráficos: '+name)&&n.selected==='true'),'selected preset');
 tap(ui().find(n=>n['content-desc']==='Volver al menú'));
}
function start(){run(['shell','am','force-stop',pkg]);run(['shell','am','start','-W','-n',pkg+'/com.reversepc.os.VelocityActivity']);wait(()=>/GPU_FRAME_READY source=XI_XFG4/.test(logs()),'GPU frame');}
function fields(line){return Object.fromEntries([...line.matchAll(/\b(\w+)=(-?\d+(?:\.\d+)?|true|false)\b/g)].map(m=>[m[1],m[2]==='true'?true:m[2]==='false'?false:Number(m[2])]));}
function shots(name){fs.writeFileSync(path.join(out,name+'.png'),run(['exec-out','screencap','-p'],true));}
try{
 run(['logcat','-c']);start();key('KEYCODE_R');
 run(['shell','input','keycombination','-t','6500','KEYCODE_W','KEYCODE_SHIFT_LEFT'],false,18000);open();preset(3);
 check(/QSSD_SPACE_READY .*"resources":20/.test(logs()),'actual game authority contains all 20 resources');
 row('Guardar recorrido');
 wait(()=>ui().some(n=>n.text?.includes('Recorrido guardado')),'completed atomic save');
 const savedLines=logs().split('\n').filter(l=>l.includes('QSSD_CHECKPOINT '));assert(savedLines.length);const saved=fields(savedLines.at(-1));
 check(saved.ticks>150&&saved.bytes>2_000_000,'save contains the driven native world and complete resources');report.saved=saved;
 const archive=run(['exec-out','run-as',pkg,'cat','files/velocity-complete-state.qss'],true);
 check(archive.subarray(0,4).toString()==='QSB3'&&archive.length===saved.bytes,'published save uses the complete QSB3 archive');
 fs.writeFileSync(path.join(out,'saved-state.qss'),archive);report.sha256=crypto.createHash('sha256').update(archive).digest('hex');shots('saved');
 run(['shell','am','force-stop',pkg]);run(['logcat','-c']);start();report.processRestart=true;open();preset(2);
 row('Recuperar recorrido');wait(()=>ui().some(n=>n.text?.includes('Recorrido recuperado')),'complete cold restore');
 const restored=fields(logs().split('\n').filter(l=>l.includes('QSSD_RESTORED ')).at(-1)||'');
 check(restored.ticks===saved.ticks,'native simulation time is identical after process death and restore');
 check(/QSSD_RESTORED .*"resources":20.*"components":2/.test(logs()),'cold restore contains resource and component graph');
 row('Gráficos');check(ui().some(n=>n['content-desc']?.startsWith('Gráficos: Alto')&&n.selected==='true'),'graphics policy restores from the complete state');
 tap(ui().find(n=>n['content-desc']==='Volver al menú'));shots('restored');tap(ui().find(n=>n.text==='Continuar'));
 const mark=logs().length;run(['shell','input','keycombination','-t','3500','KEYCODE_W','KEYCODE_SHIFT_LEFT'],false,14000);
 wait(()=>logs().slice(mark).split('\n').filter(l=>l.includes('FRAME_STATS ')).map(fields).some(x=>!x.paused&&x.ticks>saved.ticks&&x.speed>0&&x.preset===3),'continued real driving');
 check(true,'restored world continues through the original XI physics and GPU');
 open();preset(2);tap(ui().find(n=>n.text==='Continuar'));report.passed=true;
 console.log('VELOCITY_STATE_SPACE_ANDROID_PASS '+JSON.stringify(report));
}catch(error){report.error=String(error.stack||error);try{shots('failure');}catch{}throw error;}
finally{fs.writeFileSync(path.join(out,'logcat.txt'),logs());fs.writeFileSync(path.join(out,'result.json'),JSON.stringify(report,null,2)+'\n');}
