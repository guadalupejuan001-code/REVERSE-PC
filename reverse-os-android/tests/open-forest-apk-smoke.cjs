#!/usr/bin/env node
'use strict';
// Actual installed Android APK: launcher, posted Canvas, physical input and lifecycle.
// Uses only adb transport and framework UI hierarchy; it never substitutes game state.
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const crypto=require('node:crypto');
const assert=require('node:assert/strict');
assert(process.argv.length===4,'velocity-apk-smoke.cjs ADB OUTPUT_DIRECTORY');
const adb=process.argv[2].includes('/')?path.resolve(process.argv[2]):process.argv[2];
const out=path.resolve(process.argv[3]);
const pkg='com.reversepc.velocity',component=pkg+'/com.reversepc.os.VelocityActivity';
const begin=Date.now(),deadline=begin+240000;
fs.mkdirSync(out,{recursive:true});
let checks=0,stage='initial',lastXml='',lastLogs='',initialMarker='',resumedMarker='';
let video=null;
const appPids=new Set();
const report={passed:false,package:pkg,androidDeviceExecution:true,physicalPhoneVerified:false,
  renderer:'XI / REgraphics',checks:[],warnings:[]};
const sleep=ms=>Atomics.wait(new Int32Array(new SharedArrayBuffer(4)),0,0,ms);
function run(args,{binary=false,timeout=30000,allowFailure=false}={}){
  const left=deadline-Date.now();
  if(left<=0)throw Error('APK smoke exceeded 180 seconds at '+stage);
  const p=cp.spawnSync(adb,args,{encoding:binary?null:'utf8',timeout:Math.min(timeout,left),
    maxBuffer:20*1024*1024});
  if(!allowFailure&&(p.error||p.status!==0))throw Error('adb '+args.join(' ')+' failed: '+
    String(p.error||'')+' '+String(p.stderr).slice(-2000));
  return p;
}
function adbText(args,options){return String(run(args,options).stdout||'');}
function check(ok,name){assert(ok,name);checks++;report.checks.push(name);}
function logs(){lastLogs=adbText(['logcat','-d','-v','brief']);return lastLogs;}
function rememberPid(){
  const text=adbText(['shell','pidof',pkg],{timeout:5000,allowFailure:true});
  for(const pid of text.trim().split(/\s+/))if(/^\d+$/.test(pid))appPids.add(Number(pid));
}
function screenshot(name){
  const data=run(['exec-out','screencap','-p'],{binary:true}).stdout;
  check(Buffer.isBuffer(data)&&data.length>24&&data.subarray(1,4).toString()==='PNG',
    'valid screenshot '+name);
  fs.writeFileSync(path.join(out,name+'.png'),data);
  return data;
}
function markerLines(text){return text.split(/\r?\n/).filter(s=>/ReverseVelocity.*FRAME_READY \d+x\d+/.test(s));}
function fields(line){
  const result={};
  for(const m of line.matchAll(/\b(\w+)=(-?\d+(?:\.\d+)?|true|false)\b/g))
    result[m[1]]=m[2]==='true'?true:m[2]==='false'?false:Number(m[2]);
  return result;
}
function startVideo(){
  const remote='/sdcard/velocity-race3d.mp4';
  adbText(['shell','rm','-f',remote]);
  const fd=fs.openSync(path.join(out,'screenrecord.txt'),'w');
  const child=cp.spawn(adb,['shell','screenrecord','--time-limit','10','--bit-rate','2000000',remote],
    {stdio:['ignore',fd,fd]});
  fs.closeSync(fd);
  assert(child.pid,'Android screenrecord did not start');
  video={remote,started:Date.now(),child,error:null};
  child.on('error',error=>{video.error=String(error);});
}
function mp4Duration(bytes){
  function boxes(start,end){
    const found=[];
    while(start+8<=end){
      let length=bytes.readUInt32BE(start),header=8;
      if(length===1){assert(start+16<=end,'truncated MP4 extended size');length=Number(bytes.readBigUInt64BE(start+8));header=16;}
      if(length===0)length=end-start;
      assert(length>=header&&start+length<=end,'invalid MP4 box');
      found.push({type:bytes.toString('ascii',start+4,start+8),start:start+header,end:start+length});
      start+=length;
    }
    return found;
  }
  const top=boxes(0,bytes.length);
  assert(top.some(x=>x.type==='ftyp')&&top.some(x=>x.type==='mdat'),'recording lacks video container/media');
  const moov=top.find(x=>x.type==='moov');assert(moov,'screenrecord has not finalized movie metadata');
  const clock=boxes(moov.start,moov.end).find(x=>x.type==='mvhd');assert(clock,'movie clock missing');
  const version=bytes[clock.start],scaleAt=clock.start+(version===1?20:12);
  const scale=bytes.readUInt32BE(scaleAt),duration=version===1?
    Number(bytes.readBigUInt64BE(scaleAt+4)):bytes.readUInt32BE(scaleAt+4);
  assert(scale>0,'movie clock scale invalid');return duration/scale;
}
function finishVideo(){
  assert(video,'recording was not started');
  sleep(Math.max(0,video.started+11000-Date.now()));
  const target=path.join(out,'velocity-race3d-driving.mp4');
  let error;
  for(let i=0;i<3;i++){
    adbText(['pull',video.remote,target],{timeout:15000});
    try{
      const bytes=fs.readFileSync(target),seconds=mp4Duration(bytes);
      check(bytes.length>10000&&seconds>=8&&seconds<=12,'actual Android driving video finalized');
      report.video={file:path.basename(target),requestedSeconds:10,seconds,bytes:bytes.length,
        sha256:crypto.createHash('sha256').update(bytes).digest('hex'),source:'adb screenrecord of real APK'};
      return;
    }catch(failure){error=failure;sleep(500);}
  }
  throw error;
}
function waitFrame(previousCount=0){
  for(let i=0;i<40;i++){
    const text=logs(),lines=markerLines(text);
    checkNoFailure(text);
    if(lines.length>previousCount)return lines.at(-1);
    sleep(250);
  }
  throw Error('No new Canvas FRAME_READY marker after actual unlockCanvasAndPost');
}
function waitNative4KFrame(){
  for(let i=0;i<100;i++){
    const text=logs();checkNoFailure(text);
    const line=text.split(/\r?\n/).find(x=>
      /ReverseVelocity.*NATIVE_4K_FRAME_READY source=XI_XFG4_GLSL/.test(x));
    if(line){
      const match=/width=(\d+) height=(\d+) pixels=(\d+)/.exec(line);
      assert(match,'XI 4K telemetry dimensions absent: '+line);
      return {width:Number(match[1]),height:Number(match[2]),pixels:Number(match[3]),
        source:'XI XFG4 / REgraphics GLSL',log:line.trim()};
    }
    if(/Native XI 4K unavailable on this device/.test(text))
      throw Error('Native XI renderer could not produce 4K pixels');
    sleep(250);
  }
  throw Error('No verified XI 4K frame was presented on Android');
}
function waitAdvancingFrame(minimumTicks){
  for(let i=0;i<28;i++){
    const text=logs();checkNoFailure(text);
    const records=text.split(/\r?\n/).filter(s=>/ReverseVelocity.*FRAME_STATS\b/.test(s)).map(fields);
    const record=records.find(s=>s.paused===false&&Number.isFinite(s.ticks)&&s.ticks>minimumTicks);
    if(record)return record;
    sleep(250);
  }
  throw Error('Actual posted-frame stats did not show advancing XI race ticks after continue');
}
function frameRecords(text){
  return text.split(/\r?\n/).filter(s=>/ReverseVelocity.*FRAME_STATS\b/.test(s)).map(fields);
}
function waitProfileFrame(previousCount,predicate,label){
  for(let i=0;i<28;i++){
    const text=logs();checkNoFailure(text);
    const record=frameRecords(text).slice(previousCount).find(predicate);
    if(record)return record;
    sleep(250);
  }
  throw Error('No new actual posted frame for '+label);
}
function checkNoFailure(text){
  // Android services may log unrelated failures; attribute a crash to this app.
  const appProcess=/Process:\s*com\.reversepc\.velocity\b/.test(text);
  const appFatal=text.split(/\r?\n/).some(line=>{
    if(!/FATAL EXCEPTION|Fatal signal|UnsatisfiedLinkError/.test(line))return false;
    const pid=/^[VDIWEF]\/[^()]+\(\s*(\d+)\)/.exec(line);
    return appProcess||line.includes(pkg)||(pid&&appPids.has(Number(pid[1])));
  });
  assert(!appFatal,'fatal Android/native game error');
  assert(!/XI \/ REgraphics:|No se pudo (?:iniciar el programa propio|preparar (?:la carrera|el bosque)|continuar (?:la carrera|la exploración))|ReverseVelocity.*Race worker failed/.test(text),
    'renderer/startup error');
}
function unescapeXml(s){
  return s.replace(/&quot;/g,'"').replace(/&apos;/g,"'").replace(/&lt;/g,'<')
    .replace(/&gt;/g,'>').replace(/&amp;/g,'&')
    .replace(/&#(x[0-9a-f]+|\d+);/gi,(_,v)=>String.fromCodePoint(v[0].toLowerCase()==='x'?
      parseInt(v.slice(1),16):Number(v)));
}
function nodes(xml){
  return [...xml.matchAll(/<node\b[^>]*>/g)].map(m=>{
    const item={};for(const a of m[0].matchAll(/([\w:-]+)="([^"]*)"/g))item[a[1]]=unescapeXml(a[2]);
    return item;
  });
}
function fullscreenHintControl(items){
  const system=items.filter(x=>x.package==='com.android.systemui'||x.package==='android');
  const text=system.map(x=>(x.text||'')+' '+(x['content-desc']||'')).join('\n');
  if(!/Viewing full screen|Full screen mode|pantalla completa/i.test(text))return null;
  if(!system.some(x=>/immersive_cling_title$/.test(x['resource-id']||'')))return null;
  // This is Android's immersive-mode education, not a permission prompt.
  return system.find(x=>/^(Got it|Entendido)[.!]?$/i.test((x.text||'').trim())&&
    (x.clickable==='true'||x.class==='android.widget.Button'))||null;
}
function hierarchy(){
  let why='';
  // UiAutomator can temporarily return a null root immediately after
  // immersive orientation changes or dismissing SystemUI education. Retry
  // only a bounded number of actual hierarchy failures; keep crash checks.
  for(let attempt=0;attempt<6;attempt++){
    const p=run(['shell','uiautomator','dump','--compressed','/sdcard/velocity-smoke.xml'],
      {timeout:12000,allowFailure:true});
    if(!p.error&&p.status===0&&!/ERROR|Exception|could not/i.test(String(p.stdout)+String(p.stderr))){
      const xml=adbText(['exec-out','cat','/sdcard/velocity-smoke.xml'],{timeout:5000});
      if(xml.includes('<hierarchy')){
        // Preserve system overlays too, including failures before app nodes exist.
        lastXml=xml;fs.writeFileSync(path.join(out,'latest-ui.xml'),xml);
        const all=nodes(xml),hint=fullscreenHintControl(all);
        if(hint&&!report.fullscreenHintDismissed){
          fs.writeFileSync(path.join(out,'fullscreen-education-ui.xml'),xml);
          tapNode(hint);report.fullscreenHintDismissed=true;
          check(true,'dismissed known SystemUI fullscreen education');
          sleep(350);
          // The initial P key is consumed while SystemUI owns focus. Pause
          // again only after dismissing this observed education overlay.

          attempt--;continue; // Overlay is not a failed app hierarchy.
        }
        const app=all.filter(x=>x.package===pkg);
        if(app.length){
          if(stage==='initial'&&!app.some(n=>/EN PAUSA/.test(n.text||''))){adbText(['shell','input','keyevent','KEYCODE_P']);sleep(350);continue;}
          checkNoFailure(app.map(x=>x.text||'').join('\n'));
          return app;
        }
      }
    }
    why=String(p.error||p.stdout||p.stderr).slice(-1200);
    if(/null root node/i.test(why))checkNoFailure(logs());
    sleep(350);
  }
  throw Error('Actual Android UI hierarchy unavailable: '+why);
}
function findText(items,text){return items.find(x=>x.text===text);}
function revealToolbar(label,forward){
  // A landscape phone is narrower than the eleven real controls. Navigate
  // the Android HorizontalScrollView instead of assuming everything fits.
  let ui=hierarchy();
  if(findText(ui,label))return ui;
  for(let attempt=0;attempt<2;attempt++){
    const scroller=ui.find(n=>n.class==='android.widget.HorizontalScrollView'&&n.bounds);
    assert(scroller,'physical game options are not in a horizontal scroll view');
    const b=/^\[(\d+),(\d+)\]\[(\d+),(\d+)\]$/.exec(scroller.bounds);
    assert(b,'invalid toolbar screen bounds');
    const xLeft=Number(b[1])+30,xRight=Number(b[3])-30;
    const y=Math.round((Number(b[2])+Number(b[4]))/2);
    adbText(['shell','input','swipe',
       String(forward?xRight:xLeft),String(y),
       String(forward?xLeft:xRight),String(y),'380']);
    ui=hierarchy();
    if(findText(ui,label))return ui;
  }
  throw Error('Toolbar did not reveal physical control '+label);
}
function tapNode(item,holdMs=0){
  assert(item,'visible physical control is missing');
  const b=/^\[(\d+),(\d+)\]\[(\d+),(\d+)\]$/.exec(item.bounds||'');
  assert(b,'invalid physical control bounds');
  const x=Math.round((Number(b[1])+Number(b[3]))/2),y=Math.round((Number(b[2])+Number(b[4]))/2);
  assert(Number(b[3])>Number(b[1])&&Number(b[4])>Number(b[2]),'empty physical control bounds');
  if(holdMs)adbText(['shell','input','swipe',''+x,''+y,''+x,''+y,''+holdMs]);
  else adbText(['shell','input','tap',''+x,''+y]);
}
function waitText(pattern){
  for(let i=0;i<6;i++){
    const items=hierarchy();
    if(items.some(x=>pattern.test(x.text||'')))return items;
    sleep(300);
  }
  throw Error('Live HUD did not show '+pattern);
}
try{
  check(adbText(['get-state']).trim()==='device','connected Android device');
  check(adbText(['shell','pm','path',pkg]).includes('package:'),'world package installed');
  report.apiLevel=adbText(['shell','getprop','ro.build.version.sdk']).trim();
  report.emulator=adbText(['shell','getprop','ro.kernel.qemu']).trim()==='1';
  adbText(['shell','am','force-stop',pkg]);adbText(['logcat','-c']);
  const launch=adbText(['shell','am','start','-W','-a','android.intent.action.MAIN','-c','android.intent.category.LAUNCHER','-f','0x10200000','-n',component]);
  check(!/Error:|Exception/i.test(launch),'Open Forest Road launches');rememberPid();
  initialMarker=waitFrame();check(!!initialMarker,'actual XI world frame posted');
  let hdReady=false;for(let attempt=0;attempt<80;attempt++){const text=logs();checkNoFailure(text);if(/GPU_FALLBACK/.test(text))throw Error('GPU failed during HD startup');if(/GPU_FRAME_READY source=XI_XFG4/.test(text)&&/GPU_HD_PIXELS .*pixels=921600/.test(text)){hdReady=true;break;}sleep(250);}
  check(hdReady,'real HD GPU frame is posted before interaction');
  adbText(['shell','input','keyevent','KEYCODE_P']);
  let ui=waitText(/EN PAUSA/);
  check(!!findText(ui,'OPEN FOREST ROAD')&&ui.some(n=>/^SECTOR \d+ \/ 8$/.test(n.text||'')),'exploration HUD replaces laps and race positions');
  check(!ui.some(n=>/^VUELTA |^POSICIÓN /.test(n.text||'')),'no closed-race HUD remains');
  check(!!findText(ui,'ACELERAR')&&!!findText(ui,'FRENO')&&!!findText(ui,'NITRO')&&!!findText(ui,'SALTO'),'real driving controls remain usable');
  screenshot('open-world-entry');
  const frozenReuse=frameRecords(logs()).some(s=>s.paused&&s.frames===0&&s.cacheHits>0&&s.xiRenders===0);
  check(frozenReuse,'paused world reuses posted pixels without executing XI or drawing again');
  check(/GPU_SHADERS_READY owner=REgraphics geometry=XI_XFG4/.test(logs()),'own REgraphics shaders compiled on Android GPU');
  check(/GPU_FRAME_READY source=XI_XFG4 shaders=REgraphics/.test(logs()),'actual XI geometry rendered through GPU');
  tapNode(findText(ui,'Reversa R'));ui=waitText(/^Avance D$/);tapNode(findText(ui,'Avance D'));ui=waitText(/^Reversa R$/);
  check(true,'stationary reverse and forward selector work');
  stage='day and night while paused';
  ui=revealToolbar('Hora: auto',false);
  for(const [from,to,phase] of [['Hora: auto','Día',0],['Día','Atardecer',2048],['Atardecer','Noche',3072],['Noche','Hora: auto',null]]){
    tapNode(findText(ui,from));ui=waitText(new RegExp('^'+to+'$'));
    check(!!findText(ui,to),'world time control '+to);
    const text=logs();checkNoFailure(text);
    if(phase!==null)check(new RegExp('WORLD_TIME mode=\\d+ phase='+phase+' ticks=').test(text),'XI applies actual world phase '+phase);
    if(to==='Noche')screenshot('night-world');
  }
  stage='garage';ui=revealToolbar('Garaje',true);tapNode(findText(ui,'Garaje'));
  ui=waitText(/GRAN TURISMO X-02/);tapNode(findText(ui,'GRAN TURISMO X-02 · más largo y estrecho'));ui=waitText(/^Coche 2$/);
  check(true,'garage changes the actual world vehicle');
  stage='ambient audio';ui=revealToolbar('Sonido: off',true);tapNode(findText(ui,'Sonido: off'));ui=waitText(/^Sonido: on$/);
  check(true,'optional ambient synthesis can be enabled');tapNode(findText(ui,'Sonido: on'));ui=waitText(/^Sonido: off$/);
  check(true,'ambient audio can be disabled');
  stage='world atlas';ui=revealToolbar('Mapa',false);tapNode(findText(ui,'Mapa'));ui=waitText(/^Mapa · Open Forest Road$/);
  check(!!findText(ui,'Mirador del Alba'),'actual atlas exposes the trail destinations');
  tapNode(findText(ui,'Mirador del Alba'));check(/MAP_WAYPOINT index=1 name=Mirador del Alba/.test(logs()),'map waypoint selection uses the shared authored destination');screenshot('world-atlas');
  ui=hierarchy();tapNode(ui.find(n=>/^VOLVER$/i.test(n.text||'')));ui=waitText(/OPEN FOREST ROAD/);
  stage='manual steering and pedal';const manualBefore=frameRecords(logs()).length;
  adbText(['shell','input','keyevent','KEYCODE_P']);
  adbText(['shell','input','keycombination','-t','2200','KEYCODE_W','KEYCODE_D']);
  const manual=waitProfileFrame(manualBefore,s=>!s.paused&&s.speed>0&&Math.abs(s.xCm)>100&&s.yaw4096>50,'actual manual acceleration and turn');
  report.manualTurn=manual;check(manual.width===1280&&manual.height===720,'manual driving posts true HD pixels');check(Math.abs(manual.xCm)>100&&manual.yaw4096>50,'real pedals and steering turn the XI car');
  adbText(['shell','input','keyevent','KEYCODE_P']);ui=waitText(/EN PAUSA/);
  adbText(['shell','input','keyevent','KEYCODE_R']);sleep(400);adbText(['shell','input','keyevent','KEYCODE_P']);ui=waitText(/EN PAUSA/);
  check(/GPU_HD_PIXELS source=XI_XFG4_GLSL width=1280 height=720 pixels=921600 sha256=[a-f0-9]{64}/.test(logs()),'all HD pixels read back and hashed on Android');
  stage='open road pilot';ui=revealToolbar('Manual',false);tapNode(findText(ui,'Manual'));ui=waitText(/^Asistida$/);tapNode(findText(ui,'Asistida'));ui=waitText(/^Piloto$/);
  check(true,'XI pilot available for the finite road');startVideo();
  const recordsBefore=frameRecords(logs()),statsBefore=recordsBefore.length;
  const pausedTicks=recordsBefore.at(-1).ticks;
  adbText(['shell','input','keyevent','KEYCODE_P']);sleep(3500);
  // The first posted frame after resume can precede the physics worker's
  // one-second measurement. Wait for its actual measured rate as well as
  // progress beyond this pause, rather than asserting on that partial window.
  const moving=waitProfileFrame(statsBefore,s=>s.paused===false&&s.ticks>pausedTicks&&s.frames>0&&s.physicsHz>0,'finite road traversal');
  check(moving.physicsHz>0&&moving.ticks>pausedTicks,'XI physics actually advances in the open world');
  check(moving.width===1280&&moving.height===720,'continuous driving retains the HD profile');
  report.movingFrame=moving;
  // A paused scene deliberately reuses its Surface pixels. Android's encoder
  // then receives no fresh buffers and can finalize a shorter MP4 timeline.
  // Record the full requested interval while the physical car is moving.
  finishVideo();
  adbText(['shell','input','keyevent','KEYCODE_P']);ui=waitText(/EN PAUSA/);
  check(ui.some(n=>/^[1-9]\d* km\/h$/.test(n.text||'')),'pilot accelerates the physical car without a race countdown');
  report.observedSpeedKmh=Number(ui.find(n=>/^[1-9]\d* km\/h$/.test(n.text||'')).text.split(' ')[0]);
  screenshot('driving-open-road');
  stage='GPU nitro and pneumatic jump';
  // Boost requires a physical accelerator. Test sustained Manual input rather
  // than hoping the speed-limited pilot samples a one-tick boost between frames.
  ui=revealToolbar('Piloto',false);tapNode(findText(ui,'Piloto'));ui=waitText(/^Manual$/);
  adbText(['shell','input','keyevent','KEYCODE_P']);
  adbText(['shell','input','keycombination','-t','2200','KEYCODE_W','KEYCODE_N']);
  adbText(['shell','input','keycombination','-t','1500','KEYCODE_W','KEYCODE_N','KEYCODE_J']);
  screenshot('gpu-air-and-nitro');
  adbText(['shell','input','keyevent','KEYCODE_P']);ui=waitText(/EN PAUSA/);
  check(/GPU_FX_STATE nitro=true.*emittedNitro=[1-9]/.test(logs()),'rear nitro emits actual XI triangles on GPU');
  check(/GPU_FX_STATE .*air=true.*emittedAir=[1-9]/.test(logs()),'wheel air jets emit actual XI triangles on GPU');
  stage='braking and physical reverse';
  // Use the real restart control to isolate this check from the preceding
  // 230 km/h nitro/jump trajectory and its off-road landing. No state injection.
  // Then establish actual acceleration and freeze it before inspecting gears.
  adbText(['shell','input','keyevent','KEYCODE_R']);
  adbText(['shell','input','keycombination','-t','1500','KEYCODE_W','KEYCODE_SHIFT_LEFT']);
  adbText(['shell','input','keyevent','KEYCODE_P']);ui=waitText(/EN PAUSA/);
  check(ui.some(n=>/^[1-9]\d* km\/h$/.test(n.text||'')),'reverse test starts with a genuinely moving paused car');
  // Request reverse from a paused, genuinely moving XI car. The input adapter
  // must brake it before selecting R; the accelerator then drives it backwards.
  tapNode(findText(ui,'Reversa R'));ui=waitText(/^Frenando · R$/);
  check(/GEAR_REQUEST reverse=true pending=true speed=[1-9]\d*/.test(logs()),'XI receives a moving gear request that requires braking');
  check(true,'moving reverse request visibly waits for braking');
  const beforeShift=frameRecords(logs()).length;
  adbText(['shell','input','keyevent','KEYCODE_P']);
  const stopped=waitProfileFrame(beforeShift,s=>s.reverse===true&&s.speed===0&&s.physicsHz>0,'brake then engage reverse');
  check(/GEAR_APPLIED reverse=true ticks=/.test(logs()),'actual reverse applies after XI braking');
  const beforeReverse=frameRecords(logs()).length;
  // Hold a real touch long enough to observe physical reverse on a slow AVD.
  // Still require >1 metre of posted XI displacement; elapsed time is no proof.
  tapNode(findText(ui,'ACELERAR'),4000);
  const backwards=waitProfileFrame(beforeReverse,s=>s.reverse===true&&s.speed>0&&s.zCm<stopped.zCm-100,'backward displacement');
  check(backwards.zCm<stopped.zCm-100,'reverse pedal moves the physical car backwards by more than one metre');
  report.reverseMotion={before:stopped,after:backwards,physicalBackwardCm:stopped.zCm-backwards.zCm};
  adbText(['shell','input','keyevent','KEYCODE_P']);ui=waitText(/EN PAUSA/);
  check(ui.some(n=>/^R · [1-9]\d* km\/h$/.test(n.text||'')),'reverse direction is explicit on the HUD');
  screenshot('actual-reverse');
  const timeOf=items=>(items.find(n=>/^\d{2}:\d{2} · /.test(n.text||''))||{}).text;
  const frozen=timeOf(ui);sleep(700);ui=waitText(/EN PAUSA/);check(frozen&&frozen===timeOf(ui),'paused world clock and distance remain stable');
  stage='analog steering';
  ui=hierarchy();const wheel=ui.find(n=>/^Volante analógico/.test(n['content-desc']||''));
  check(!!wheel,'analog steering wheel is reachable');
  const wb=/^\[(\d+),(\d+)\]\[(\d+),(\d+)\]$/.exec(wheel.bounds);
  const wx=(+wb[1]+ +wb[3])/2,wy=(+wb[2]+ +wb[4])/2;
  adbText(['shell','input','swipe',String(Math.round(wx)),String(Math.round(wy)),String(Math.round(wx+(+wb[3]-wb[1])*.3)),String(Math.round(wy)),'450']);
  const analog=logs();check(/ANALOG_STEERING value=1[1-9]\d/.test(analog)&&/ANALOG_STEERING value=255/.test(analog),'touch steering emits proportional input and recenters on release');
  stage='touch camera';
  // Android exposes this custom SurfaceView as android.view.View. Its
  // observed accessibility description identifies the actual camera target.
  const target=ui.find(n=>/^Cámara 3D\./.test(n['content-desc']||'')&&n.clickable==='true');
  check(!!target,'world camera accessible');
  const b=/^\[(\d+),(\d+)\]\[(\d+),(\d+)\]$/.exec(target.bounds);const w=+b[3]-b[1],h=+b[4]-b[2];
  adbText(['shell','input','swipe',String(Math.round(+b[1]+w*.38)),String(Math.round(+b[2]+h*.43)),String(Math.round(+b[1]+w*.64)),String(Math.round(+b[2]+h*.39)),'350']);
  let orbitRendered=false;
  for(let attempt=0;attempt<15;attempt++){
    const text=logs();checkNoFailure(text);
    orbitRendered=/ORBIT_INPUT yaw=[1-9]\d* pitch=/.test(text)&&/ORBIT_FRAME yaw=[1-9]\d* pitch=/.test(text);
    if(orbitRendered)break;
    sleep(250);
  }
  check(orbitRendered,'touch orbit posts a new XI world view');screenshot('forest-orbit');
  stage='native photo';ui=revealToolbar('Foto 4K',false);tapNode(findText(ui,'Foto 4K'));ui=waitText(/^Salir 4K$/);report.native4K=waitNative4KFrame();
  check(/GPU_NATIVE_4K_PIXELS source=XI_XFG4_GLSL width=3840 height=2160 pixels=8294400 sha256=[a-f0-9]{64}/.test(logs()),'all 8.3 million GPU photo pixels read back and hashed');
  check(report.native4K.width===3840&&report.native4K.height===2160,'world photo uses original 3840x2160 XI pixels');screenshot('open-world-photo-4k');
  tapNode(findText(ui,'Salir 4K'));ui=waitText(/^Foto 4K$/);check(true,'returns from photo to the adaptive world profile');
  stage='background resume';adbText(['shell','input','keyevent','KEYCODE_HOME']);sleep(300);const count=markerLines(logs()).length;
  adbText(['shell','am','start','-W','-n',component]);rememberPid();resumedMarker=waitFrame(count);check(!!resumedMarker,'world survives Activity pause and resume');
  ui=waitText(/OPEN FOREST ROAD/);check(ui.length>0,'exploration HUD survives resume');
  const finalLogs=logs();checkNoFailure(finalLogs);check(!/GPU_FALLBACK/.test(finalLogs),'GPU remains active through driving, orbit, photo and resume');check(true,'no fatal Java, native or XI failure');
  report.frameStats=frameRecords(finalLogs);report.passed=true;report.initialFrame=initialMarker;report.resumedFrame=resumedMarker;
}catch(error){
  report.error=String(error.stack||error);report.failedStage=stage;
  process.exitCode=1;
}finally{
  // Diagnostic capture must not turn a failed action into a pass.
  try{fs.writeFileSync(path.join(out,'logcat.txt'),adbText(['logcat','-d','-v','threadtime'],
    {timeout:5000,allowFailure:true}));}catch(error){
      fs.writeFileSync(path.join(out,'logcat.txt'),lastLogs);
      report.warnings.push('logcat: '+String(error));
    }
  if(!report.passed){
    try{screenshot('failure-screen');}catch(error){report.warnings.push('screenshot: '+String(error));}
    if(lastXml)fs.writeFileSync(path.join(out,'failure-ui.xml'),lastXml);
  }
  report.elapsedMs=Date.now()-begin;report.checkCount=checks;report.appPids=[...appPids];
  fs.writeFileSync(path.join(out,'result.json'),JSON.stringify(report,null,2)+'\n');
  console.log(JSON.stringify({result:report.passed?'VELOCITY_ANDROID_APK_PASS':'VELOCITY_ANDROID_APK_FAIL',
    checks,observedSpeedKmh:report.observedSpeedKmh,failedStage:report.failedStage,error:report.error,
    elapsedMs:report.elapsedMs}));
}
