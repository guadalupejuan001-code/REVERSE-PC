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
      /ReverseVelocity.*NATIVE_4K_FRAME_READY source=XI_XFB5/.test(x));
    if(line){
      const match=/width=(\d+) height=(\d+) pixels=(\d+)/.exec(line);
      assert(match,'XI 4K telemetry dimensions absent: '+line);
      return {width:Number(match[1]),height:Number(match[2]),pixels:Number(match[3]),
        source:'XI / REgraphics XFB5',log:line.trim()};
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
  assert(!/XI \/ REgraphics:|No se pudo (?:iniciar el programa propio|preparar la carrera|continuar la carrera)|ReverseVelocity.*Race worker failed/.test(text),
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
          sleep(350);attempt--;continue; // Overlay is not a failed app hierarchy.
        }
        const app=all.filter(x=>x.package===pkg);
        if(app.length){
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
  check(adbText(['shell','pm','path',pkg]).includes('package:'),'standalone game package installed');
  report.apiLevel=adbText(['shell','getprop','ro.build.version.sdk']).trim();
  report.abi=adbText(['shell','getprop','ro.product.cpu.abi']).trim();
  report.emulator=adbText(['shell','getprop','ro.kernel.qemu']).trim()==='1';
  adbText(['shell','am','force-stop',pkg]);
  adbText(['logcat','-c']);
  const launch=adbText(['shell','am','start','-W','-a','android.intent.action.MAIN',
    '-c','android.intent.category.LAUNCHER','-f','0x10200000','-n',component]);
  fs.writeFileSync(path.join(out,'launch.txt'),launch);
  check(!/Error:|Exception|does not exist/i.test(launch),'standalone Velocity launcher starts');
  rememberPid();
  initialMarker=waitFrame();check(!!initialMarker,'real Canvas frame posted');
  screenshot('initial-screen');
  stage='ready HUD';
  let ui=waitText(/ACELERA PARA SALIR/);
  check(ui.some(x=>/^VUELTA \d+ \/ 3$/.test(x.text||''))&&
    ui.some(x=>/^POSICIÓN \d+ \/ 4$/.test(x.text||'')),'minimal race lap and position HUD');
  check(!!findText(ui,'ACELERAR'),'accelerator physical control');
   check(!!findText(ui,'NITRO')&&!!findText(ui,'SALTO'),
     'physical boost and pneumatic jump buttons exist in the installed APK');
  check(!!findText(ui,'FRENO')&&!!findText(ui,'◀')&&!!findText(ui,'▶'),
    'real driving pedal/steering accessibility controls');
  check(!!findText(ui,'Marcha D'),'visible real-world transmission selector');
  check(!!findText(ui,'Garaje')&&!!findText(ui,'HUD libre'),
    'compact unobstructed HUD and actual selectable garage are present');
  tapNode(findText(ui,'Marcha D'));
  ui=waitText(/^Marcha R$/);
  check(!!findText(ui,'Marcha R'),'stationary gear selector engages reverse in the APK');
  tapNode(findText(ui,'Marcha R'));
  ui=waitText(/^Marcha D$/);
  check(!!findText(ui,'Marcha D'),'gear selector returns to forward before racing');
  stage='physical acceleration';
  // A three-second countdown is authoritative XI state; keep physical throttle
  // held beyond it so the subsequent speed assertion measures actual driving.
  tapNode(findText(ui,'ACELERAR'),4500);
  // Accessibility dumps can take several seconds. Freeze the real speed with
  // the game's physical pause key before observing it, rather than letting
  // legitimate coasting/off-road drag erase the short acceleration pulse.
  adbText(['shell','input','keyevent','KEYCODE_P']);
  ui=waitText(/^[1-9]\d* km\/h$/);
  const speedText=ui.find(x=>/^[1-9]\d* km\/h$/.test(x.text||'')).text;
  report.observedSpeedKmh=parseInt(speedText,10);
  check(report.observedSpeedKmh>0,'physical accelerator advances XI speed');
  stage='pause';
  ui=waitText(/EN PAUSA/);check(true,'pause freezes game scheduler and shows HUD');
  const timer=items=>(items.find(x=>/^\d{2}:\d{2}\.\d{2}$/.test(x.text||''))||{}).text;
  const pauseTime=timer(ui);
  sleep(1100);ui=waitText(/EN PAUSA/);
  check(pauseTime&&pauseTime===timer(ui),'race timer remains fixed while paused');
  const ticksFromTimer=value=>{
    const match=/^(\d{2}):(\d{2})\.(\d{2})$/.exec(value||'');
    assert(match,'race HUD timer format is invalid');
    return (Number(match[1])*6000+Number(match[2])*100+Number(match[3]))/2;
  };
  stage='continue';tapNode(findText(ui,'Continuar'));
  // A running hundredths timer deliberately prevents accessibility-idle dumps.
  // Observe actual posted-frame/tick telemetry while moving, then physically
  // pause before reading a stable hierarchy again.
  const advanced=waitAdvancingFrame(ticksFromTimer(pauseTime));
  check(advanced.ticks>ticksFromTimer(pauseTime),'continue advances authoritative XI race ticks');
  report.continuedFrame=advanced;
  adbText(['shell','input','keyevent','KEYCODE_P']);
  ui=waitText(/EN PAUSA/);
  check(ticksFromTimer(timer(ui))>ticksFromTimer(pauseTime),'live race timer advanced before second physical pause');
  stage='garage and clear view';
  tapNode(findText(ui,'Garaje'));
  ui=waitText(/GRAN TURISMO X-02/);
  check(!!findText(ui,'GRAN TURISMO X-02 · más largo y estrecho'),
    'garage exposes a second physical car silhouette');
  tapNode(findText(ui,'GRAN TURISMO X-02 · más largo y estrecho'));
  ui=waitText(/^Coche 2$/);
  check(!!findText(ui,'Coche 2'),'selecting a car visibly changes the garage choice');
  screenshot('garage-gt-car');
  tapNode(findText(ui,'HUD libre'));
  ui=waitText(/^HUD tablero$/);
  check(!!findText(ui,'HUD tablero'),'dashboard can be enabled explicitly');
  tapNode(findText(ui,'HUD tablero'));
  ui=waitText(/^HUD libre$/);
  check(!!findText(ui,'HUD libre'),'large animated dashboard can be hidden again');
  stage='physical touchscreen orbit';
  const sceneNode=ui.find(x=>x.class==='android.view.SurfaceView')||
    ui.filter(x=>x.class==='android.widget.FrameLayout'&&x.bounds)
      .sort((a,b)=>{
        const area=v=>{const p=/^\[(\d+),(\d+)\]\[(\d+),(\d+)\]$/.exec(v.bounds||'');
          return p?(Number(p[3])-Number(p[1]))*(Number(p[4])-Number(p[2])):0;};
        return area(b)-area(a);
      })[0];
  check(!!sceneNode,'gesture target visible in native Android hierarchy');
  const screen=/^\[(\d+),(\d+)\]\[(\d+),(\d+)\]$/.exec(sceneNode.bounds||'');
  check(!!screen,'landscape scene has valid physical bounds');
  const sx=Number(screen[1]),sy=Number(screen[2]),
    sw=Number(screen[3])-sx,sh=Number(screen[4])-sy;
  check(sw>500&&sh>200,'gesture area is large enough to avoid driving controls');
  const y=sy+Math.round(sh*.43),startX=sx+Math.round(sw*.38),
    endX=sx+Math.round(sw*.67);
  adbText(['shell','input','swipe',String(startX),String(y),
    String(endX),String(y-28),'400']);
  let orbitReported=false,orbitRendered=false;
  for(let k=0;k<15;k++){
    const lines=logs();
    orbitReported=/ORBIT_INPUT yaw=[1-9]\d* pitch=/.test(lines);
    orbitRendered=/ORBIT_FRAME yaw=[1-9]\d* pitch=/.test(lines);
    if(orbitReported&&orbitRendered)break;
    sleep(250);
  }
  check(orbitReported&&orbitRendered,
    'real screen drag rotates XI camera and posts an independently rendered view');
  screenshot('touch-orbit-camera');
  ui=waitText(/EN PAUSA/);
  stage='camera and paint';tapNode(findText(ui,'Cámara'));
  ui=waitText(/^Cercana$/);check(!!findText(ui,'Cercana'),'physical camera changes to close chase');
  tapNode(findText(ui,'Color'));ui=waitText(/^Color 2$/);
  check(!!findText(ui,'Color 2'),'physical paint selection changes');
  screenshot('changed-camera-paint');
  // Cycle the actual UI paint to pearl white before the GPU screenshot.
  for(const pair of [['Color 2','Color 3'],['Color 3','Color 4'],
                     ['Color 4','Color 5'],['Color 5','Color 1']]){
    tapNode(findText(ui,pair[0]));
    ui=waitText(new RegExp('^'+pair[1]+'$'));
    check(!!findText(ui,pair[1]),'selected paint '+pair[1]);
  }
  report.verified4KPaint='pearl-white';
  stage='high detail profile';
  const detailPauseTime=timer(ui),beforeHigh=frameRecords(logs()).length;
  tapNode(findText(ui,'Nitidez'));
  report.highDetailFrame=waitProfileFrame(beforeHigh,s=>s.width===640&&s.height===360&&
    s.fixedDetail===true&&s.paused===true&&s.frames>0,'fixed high detail 640x360');
  check(true,'Nitidez produces a new actual fixed 640x360 frame');
  ui=waitText(/^Alta$/);check(!!findText(ui,'Alta'),'high detail physical control shows Alta');
  check(timer(ui)===detailPauseTime,'high detail leaves paused race timer unchanged');
  screenshot('high-detail-car');
  stage='automatic detail profile';
  const beforeAuto=frameRecords(logs()).length;
  tapNode(findText(ui,'Alta'));
  report.autoDetailFrame=waitProfileFrame(beforeAuto,s=>s.fixedDetail===false&&s.paused===true&&s.frames>0&&
    ((s.width===480&&s.height===270)||(s.width===320&&s.height===180)),'automatic detail profile');
  check(true,'Auto restores an actual automatic-resolution frame');
  ui=waitText(/^Auto$/);check(!!findText(ui,'Auto'),'automatic detail physical control shows Auto');
  check(timer(ui)===detailPauseTime,'automatic detail leaves paused race timer unchanged');
  stage='REgraphics XI renderer ownership';
  tapNode(findText(ui,'Motor XI'));
  ui=waitText(/Resolución habitual: hasta 640/);
  check(ui.some(x=>/XFB5 escala el trabajo por resolución/.test(x.text||'')),
    'renderer diagnostic exposes real XI pixel-work limit');
  check(ui.some(x=>/No hay OpenGL/.test(x.text||'')),
    'game explicitly discloses no external graphics renderer');
  screenshot('regraphics-xi-native-panel');
  // AlertDialog button casing/layout varies across Android skins. Use the
  // Android back action to close the verified diagnostic on every device.
  adbText(['shell','input','keyevent','KEYCODE_BACK']);
  ui=waitText(/EN PAUSA/);
  check(true,'native REgraphics-only diagnostics close without modifying physical race');
  stage='true XI 4K native pixel mode';
  const beforeNativeFrameStats=frameRecords(logs()).length;
  tapNode(findText(ui,'Foto 4K'));
  ui=waitText(/^Salir 4K$/);
  check(!!findText(ui,'Salir 4K'),'4K is explicitly photo-only and freezes XI physics');
  report.native4K=waitNative4KFrame();
  check(report.native4K.width===3840&&report.native4K.height===2160&&
    report.native4K.pixels===8294400,'actual XI raster computed 8.294.400 pixels');
  screenshot('xi-native-4k-real-frame');
  report.frozen4KCache=waitProfileFrame(beforeNativeFrameStats,
    s=>s.paused===true&&s.width===3840&&s.height===2160&&
      s.cacheHits>=3&&s.xiRenders<=2,
    '4K cached XI frame reuse while paused');
  check(report.frozen4KCache.cacheHits>=3&&report.frozen4KCache.xiRenders<=2,
    'native 4K must reuse frozen XI pixels instead of rendering continuously');
  tapNode(findText(ui,'Salir 4K'));
  ui=waitText(/^Foto 4K$/);
  check(!!findText(ui,'Foto 4K'),'4K photo exited and fluid XI driving profile restored');
    stage='physical steering and driving video';
  const startState=fields(initialMarker);
  check(Number.isFinite(startState.xCm)&&Number.isFinite(startState.zCm)&&Number.isFinite(startState.yaw4096),
    'initial posted frame exposes observed XI position and heading');
  startVideo();
  adbText(['shell','input','keyevent','KEYCODE_P']);
  tapNode(findText(ui,'ACELERAR'),4500);
  tapNode(findText(ui,'ACELERAR'),3000);
  tapNode(findText(ui,'◀'),800);
  // Freeze immediately after the real steering gesture, before accessibility
  // diagnostics can consume time or the car can coast into a different state.
  adbText(['shell','input','keyevent','KEYCODE_P']);
  finishVideo();
  ui=waitText(/EN PAUSA/);check(true,'physical steering phase paused for observation');
  screenshot('steered-race');
  stage='background resume';
  adbText(['shell','input','keyevent','KEYCODE_HOME']);sleep(400);
  const before=markerLines(logs()).length;
  adbText(['shell','am','start','-W','-a','android.intent.action.MAIN',
    '-c','android.intent.category.LAUNCHER','-f','0x10200000','-n',component]);
  rememberPid();
  resumedMarker=waitFrame(before);check(!!resumedMarker,'new actual Canvas frame after Activity resume');
  report.resumedTicks=Number((/ticks=(\d+)/.exec(resumedMarker)||[])[1]);
  check(Number.isInteger(report.resumedTicks)&&report.resumedTicks>0,
    'Activity resume retains started race state');
  const endState=fields(resumedMarker);
  check(Number.isInteger(endState.yaw4096)&&endState.yaw4096!==startState.yaw4096,
    'physical steering changes authoritative XI heading');
  check(Number.isFinite(endState.xCm)&&Number.isFinite(endState.zCm)&&
    (endState.xCm!==startState.xCm||endState.zCm!==startState.zCm),
    'physical accelerator moves authoritative XI world position');
  report.drivingState={before:startState,after:endState,physicalSteering:true};
  ui=waitText(/^VUELTA \d+ \/ 3$/);check(ui.length>0,'game remains usable after resume');
  const finalLogs=logs();checkNoFailure(finalLogs);check(true,'no fatal Java/native or renderer error');
  report.frameStats=finalLogs.split(/\r?\n/).filter(s=>/ReverseVelocity.*FRAME_STATS\b/.test(s)).map(fields);
  const active=report.frameStats.filter(s=>s.paused===false&&s.frames>0&&s.elapsedNanos>0&&Number.isFinite(s.fps)&&s.fps>0);
  check(active.length>0,'actual posted-frame FPS measurements recorded');
  check(active.some(s=>s.xiRenders>0),'live race continues rendering updated XI snapshots');
  report.framePipeline=finalLogs.split(/\r?\n/)
    .filter(s=>/ReverseVelocity.*FRAME_PIPELINE\b/.test(s))
    .map(line=>({mode:/mode=(XI_4K|XI_STANDARD)/.exec(line)?.[1],...fields(line)}));
  check(report.framePipeline.length>0,'real frame stage timings are emitted');
  check(report.framePipeline.some(s=>s.mode==='XI_STANDARD'&&s.samples>0),
    'ordinary XI render stage timings are measured');
  check(report.framePipeline.some(s=>s.mode==='XI_4K'&&s.samples>0&&s.payloadBytes===8294416),
    'native 4K stage timings identify exact 8294416-byte frame');
  check(report.framePipeline.every(s=>Number.isFinite(s.xiP50Ms)&&
      Number.isFinite(s.xiP95Ms)&&Number.isFinite(s.totalP95Ms)&&
      Number.isFinite(s.presentP50Ms)&&s.totalP95Ms>=0),
    'pipeline p50/p95 measurements are finite and nonnegative');
  report.activeFps={samples:active.length,min:Math.min(...active.map(s=>s.fps)),max:Math.max(...active.map(s=>s.fps)),
    source:'FRAME_STATS posted Canvas frames / elapsed nanoseconds; emulator workload with recording'};
  screenshot('final-screen');
  report.passed=true;report.initialFrame=initialMarker;report.resumedFrame=resumedMarker;
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
