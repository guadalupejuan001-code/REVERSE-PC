#!/usr/bin/env node
'use strict';
// Real installed APK, native UI input, completed GPU target readbacks and live XI driving.
const cp=require('node:child_process'),fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const [adb='adb',out='build/velocity-ui']=process.argv.slice(2),pkg='com.reversepc.velocity',component=pkg+'/com.reversepc.os.VelocityActivity';
fs.mkdirSync(out,{recursive:true});const deadline=Date.now()+420000,children=[];
let stage='launch',lastXml='',checks=0;
const report={passed:false,emulator:true,physicalPhoneVerified:false,checks:[],profiles:[],screens:[]};
const sleep=ms=>Atomics.wait(new Int32Array(new SharedArrayBuffer(4)),0,0,ms);
function run(args,binary=false,timeout=30000){
 const r=cp.spawnSync(adb,args,{encoding:binary?null:'utf8',timeout:Math.max(1,Math.min(timeout,deadline-Date.now())),maxBuffer:24*1024*1024});
 assert.ifError(r.error);assert.equal(r.status,0,String(r.stderr));return r.stdout;
}
function logs(){return run(['logcat','-d','-v','brief','ReverseVelocity:I','AndroidRuntime:E','*:S']);}
function check(value,label){assert(value,label);checks++;report.checks.push(label);}
function healthy(){assert(!/GPU_FALLBACK|Race worker failed|FATAL EXCEPTION/.test(logs()),'game/render failure');}
function waitFor(test,label,ms=40000){const end=Math.min(deadline,Date.now()+ms);while(Date.now()<end){healthy();const v=test();if(v)return v;sleep(250);}throw Error('Timed out: '+label);}
function decode(s){return s.replace(/&#(\d+);/g,(_,v)=>String.fromCodePoint(Number(v))).replace(/&quot;/g,'"').replace(/&apos;/g,"'").replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&');}
function ui(){
 run(['shell','uiautomator','dump','/sdcard/velocity-ui.xml'],false,15000);lastXml=run(['shell','cat','/sdcard/velocity-ui.xml']);
 return [...lastXml.matchAll(/<node\b([^>]+)>/g)].map(m=>Object.fromEntries([...m[1].matchAll(/([\w-]+)="([^"]*)"/g)].map(x=>[x[1],decode(x[2])])));
}
function rect(n){const m=/\[(\d+),(\d+)\]\[(\d+),(\d+)\]/.exec(n.bounds);assert(m,n.bounds);return m.slice(1).map(Number);}
function point(n){const [x,y,r,b]=rect(n);return [Math.round((x+r)/2),Math.round((y+b)/2)];}
function tap(n){assert(n,'UI control missing');run(['shell','input','tap',...point(n).map(String)]);sleep(180);}
function buttonNodes(nodes){return nodes.filter(n=>n.class?.endsWith('Button')&&n['visible-to-user']!=='false');}
function byDesc(text){return ui().find(n=>n['content-desc']===text);}
function tapDesc(text){tap(waitFor(()=>byDesc(text),'control '+text,12000));}
function textNode(value){return ui().find(n=>n.text===value);}
function screenshot(name){const bytes=run(['exec-out','screencap','-p'],true);assert(bytes.subarray(1,4).toString()==='PNG');fs.writeFileSync(path.join(out,name+'.png'),bytes);report.screens.push(name+'.png');}
function key(k){run(['shell','input','keyevent',k]);}
function fields(line){return Object.fromEntries([...line.matchAll(/\b(\w+)=(-?\d+(?:\.\d+)?|true|false)\b/g)].map(m=>[m[1],m[2]==='true'?true:m[2]==='false'?false:Number(m[2])]));}
function frames(s=logs()){return s.split('\n').filter(l=>l.includes('FRAME_STATS ')).map(fields);}
function openMenu(){tapDesc('Abrir menú');waitFor(()=>textNode('Tu recorrido'),'main drawer');}
function row(title){
 for(let i=0;i<9;i++){
  const nodes=ui(),n=nodes.find(n=>n.class?.endsWith('Button')&&n.text?.startsWith(title+'\n'));
  if(n){tap(n);return;}
  const scroll=nodes.find(n=>n.scrollable==='true');assert(scroll,'settings scroll missing');const [l,t,r,b]=rect(scroll);
  run(['shell','input','swipe',String(Math.round((l+r)/2)),String(b-20),String(Math.round((l+r)/2)),String(t+20),'300']);sleep(100);
 }throw Error('Missing menu row '+title);
}
function selectProfile(id){
 const names=['Ahorro','Bajos','Medio','Alto','Ultra'],name=names[id];
 for(let i=0;i<8;i++){
  const nodes=ui(),n=nodes.find(n=>n['content-desc']?.startsWith('Gráficos: '+name));
  if(n){const mark=logs().length;tap(n);waitFor(()=>logs().slice(mark).split('\n').find(l=>l.includes('GRAPHICS_FRAME preset='+id+' ')&&l.includes('gpu=true')),'real GPU profile '+name,60000);return;}
  const scroll=nodes.find(n=>n.scrollable==='true');assert(scroll,'graphics scroll missing');const [l,t,r,b]=rect(scroll);
  run(['shell','input','swipe',String(Math.round((l+r)/2)),String(b-24),String(Math.round((l+r)/2)),String(t+22),'300']);sleep(100);
 }throw Error('Missing graphics profile '+name);
}
function continueDriving(){tap(waitFor(()=>textNode('Continuar'),'continue'));sleep(150);}
function hold(n,ms){const [x,y]=point(n);run(['shell','input','swipe',String(x),String(y),String(x),String(y),String(ms)],false,ms+10000);}
try{
 run(['shell','am','force-stop',pkg]);run(['logcat','-c']);run(['shell','am','start','-W','-n',component]);
 waitFor(()=>/GPU_PRESET_PIXELS preset=2 .*width=960 height=540/.test(logs()),'default medium pixels',60000);
 let nodes=ui();for(const label of ['Got it','Entendido','OK']){const n=nodes.find(n=>n.text===label&&n.package==='com.android.systemui');if(n){tap(n);nodes=ui();}}
 check(nodes.some(n=>n.text==='REVERSE\nVELOCITY'),'Reverse Velocity brand is visible');
 check(buttonNodes(nodes).length<=7,'driving view has at most seven essential buttons');
 check(!buttonNodes(nodes).some(n=>/^(Gráficos|Garaje|Mapa|Hora|Foto|Color|Sonido|Reiniciar)/.test(n.text||'')),'secondary tools are hidden while driving');
 check(!/Foto 4K|Salir 4K|HD 720p/.test(lastXml),'old graphics/photo controls are absent');
 screenshot('01-driving-medium');openMenu();
 check(frames().some(x=>x.paused),'opening the menu pauses real XI physics');
 row('Gráficos');
 const profiles=[['Ahorro',480,270],['Bajos',640,360],['Medio',960,540],['Alto',1280,720],['Ultra',1920,1080]];
 for(let id=0;id<profiles.length;id++){
  stage='profile '+profiles[id][0];if(id>0){openMenu();row('Gráficos');}
  selectProfile(id);const [name,w,h]=profiles[id],text=logs();
  check(new RegExp('GPU_PRESET_PIXELS preset='+id+' .*width='+w+' height='+h+' pixels='+(w*h)+' sha256=[a-f0-9]{64}').test(text),'actual '+name+' GPU pixels are hashed');
  check(!/4K|3840|2160/.test(lastXml),'quality page offers no 4K mode');
  if(id===0)screenshot('02-graphics-ahorro');if(id===4)screenshot('03-graphics-ultra');
  continueDriving();key('KEYCODE_R');sleep(300);const mark=logs().length;
  run(['shell','input','keycombination','-t','6500','KEYCODE_W','KEYCODE_SHIFT_LEFT'],false,18000);sleep(400);
  const live=logs().slice(mark);fs.writeFileSync(path.join(out,'profile-'+id+'.log'),live);
  const rows=frames(live).filter(x=>x.preset===id&&!x.paused&&x.speed>0&&x.physicsHz>0);
  check(rows.length>=2&&rows.every(x=>x.width===w&&x.height===h),'sustained '+name+' driving retains its real resolution');
  check(rows.at(-1).ticks>rows[0].ticks,'XI physics advances independently in '+name);
  const count=rows.reduce((a,x)=>a+x.frames,0),nanos=rows.reduce((a,x)=>a+x.elapsedNanos,0);
  const fps=count*1e9/nanos;check(id!==0||fps<30.6,'Ahorro obeys its 30 FPS ceiling');
  const mem=run(['shell','dumpsys','meminfo',pkg]);fs.writeFileSync(path.join(out,'memory-'+id+'.txt'),mem);
  report.profiles.push({id,name,width:w,height:h,frames:count,elapsedNanos:nanos,fps,physicsHz:rows.map(x=>x.physicsHz),pssKiB:Number((/TOTAL PSS:\s*(\d+)/.exec(mem)||[])[1])||null});
 }
 stage='persist selection';run(['shell','am','force-stop',pkg]);run(['logcat','-c']);run(['shell','am','start','-W','-n',component]);
 waitFor(()=>/GPU_PRESET_PIXELS preset=4 .*width=1920 height=1080/.test(logs()),'saved Ultra after relaunch',60000);
 check(true,'graphics preference survives process restart');openMenu();row('Gráficos');
 check(ui().some(n=>n['content-desc']?.startsWith('Gráficos: Ultra, seleccionado')&&n.selected==='true'),'selected preset is restored in the settings');
 selectProfile(2);continueDriving();
 stage='touch controls';key('KEYCODE_R');const before=frames().at(-1)?.ticks||0;
 hold(waitFor(()=>textNode('ACELERAR'),'accelerator'),3500);sleep(1200);
 check(frames().some(x=>x.ticks>before&&x.speed>0&&x.zCm>0),'real accelerator touch moves the car');
 const wheel=ui().find(n=>n['content-desc']?.startsWith('Volante analógico'));check(!!wheel,'analog wheel is accessible');
 const [l,t,r,b]=rect(wheel);run(['shell','input','swipe',String(Math.round((l+r)/2)),String(Math.round((t+b)/2)),String(r-10),String(Math.round((t+b)/2)),'900']);
 check(/ANALOG_STEERING value=255/.test(logs()),'steering recenters after release');
 stage='effects';key('KEYCODE_R');run(['shell','input','keycombination','-t','2500','KEYCODE_W','KEYCODE_N'],false,10000);
 waitFor(()=>/GPU_FX_STATE nitro=true .*emittedNitro=(?:1[6-9]|[2-9]\d)/.test(logs()),'nitro reaches actual GPU geometry');
 key('KEYCODE_J');waitFor(()=>/GPU_FX_STATE .*air=true .*emittedAir=(?:1[6-9]|[2-9]\d)/.test(logs()),'air jets reach actual GPU geometry');
 screenshot('04-effects');
 stage='garage and map';openMenu();row('Garaje');tapDesc('Elegir GRAN TURISMO X-02');
 check(ui().some(n=>n['content-desc']==='Elegir GRAN TURISMO X-02'&&n.selected==='true'),'garage selects the real second car');
 tapDesc('Volver al menú');row('Mapa');check(/MAP_OPEN trails=4 places=6/.test(logs()),'map still contains all trails and destinations');
 row('Mirador del Alba');waitFor(()=>/MAP_WAYPOINT index=/.test(logs()),'actual map waypoint');screenshot('05-map');
 continueDriving();
 stage='camera';const image=ui().find(n=>n['content-desc']?.startsWith('Cámara 3D'));
 check(!!image,'world camera remains accessible');const [il,it,ir,ib]=rect(image);
 run(['shell','input','swipe',String(Math.round((il+ir)*.5)),String(Math.round((it+ib)*.56)),String(Math.round((il+ir)*.67)),String(Math.round((it+ib)*.48)),'700']);
 waitFor(()=>/ORBIT_INPUT yaw=/.test(logs()),'physical orbit gesture');key('KEYCODE_C');
 stage='reverse';key('KEYCODE_R');run(['shell','input','keycombination','-t','4500','KEYCODE_W','KEYCODE_SHIFT_LEFT'],false,12000);key('KEYCODE_G');
 check(/GEAR_REQUEST reverse=true/.test(logs()),'gear request reaches the real gearbox');
 const mark=logs().length;run(['shell','input','keycombination','-t','12000','KEYCODE_W','KEYCODE_SHIFT_LEFT'],false,22000);sleep(1000);
 const reverse=frames(logs().slice(mark)).filter(x=>x.reverse&&x.speed>0);
 check(reverse.length>=2&&Math.max(...reverse.map(x=>x.zCm))-reverse.at(-1).zCm>100,'car physically reverses by over one metre');
 screenshot('06-reverse');
 stage='menu physics freeze';openMenu();sleep(1200);const frozen=frames().filter(x=>x.paused).at(-1);sleep(1300);const frozen2=frames().filter(x=>x.paused).at(-1);
 check(frozen&&frozen2&&frozen.ticks===frozen2.ticks,'menu stops simulation time');
 check(frozen2.cacheHits>0&&frozen2.xiRenders===0,'paused menu reuses the presented scene');screenshot('07-menu');continueDriving();
 stage='lifecycle';key('KEYCODE_HOME');sleep(800);run(['shell','am','start','-W','-n',component]);
 waitFor(()=>byDesc('Abrir menú'),'resumed driving UI');healthy();check(true,'game and graphics survive activity pause/resume');
 report.passed=true;report.checkCount=checks;console.log('VELOCITY_GRAPHICS_UI_PASS '+JSON.stringify({checks,profiles:report.profiles}));
}catch(error){report.error=String(error.stack||error);report.failedStage=stage;try{screenshot('failure-'+stage.replace(/\W+/g,'-'));}catch{};throw error;
}finally{
 for(const c of children)c.kill();report.checkCount=checks;fs.writeFileSync(path.join(out,'result.json'),JSON.stringify(report,null,2)+'\n');
 fs.writeFileSync(path.join(out,'latest-ui.xml'),lastXml);try{fs.writeFileSync(path.join(out,'logcat.txt'),logs());}catch{}
}
