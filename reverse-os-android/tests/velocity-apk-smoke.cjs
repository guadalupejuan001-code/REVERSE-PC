#!/usr/bin/env node
'use strict';
// Actual installed Android APK: launcher, posted Canvas, physical input and lifecycle.
// Uses only adb transport and framework UI hierarchy; it never substitutes game state.
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const assert=require('node:assert/strict');
assert(process.argv.length===4,'velocity-apk-smoke.cjs ADB OUTPUT_DIRECTORY');
const adb=process.argv[2].includes('/')?path.resolve(process.argv[2]):process.argv[2];
const out=path.resolve(process.argv[3]);
const pkg='com.reversepc.velocity',component=pkg+'/com.reversepc.os.VelocityActivity';
const begin=Date.now(),deadline=begin+180000;
fs.mkdirSync(out,{recursive:true});
let checks=0,stage='initial',lastXml='',lastLogs='',initialMarker='',resumedMarker='';
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
function waitFrame(previousCount=0){
  for(let i=0;i<40;i++){
    const text=logs(),lines=markerLines(text);
    checkNoFailure(text);
    if(lines.length>previousCount)return lines.at(-1);
    sleep(250);
  }
  throw Error('No new Canvas FRAME_READY marker after actual unlockCanvasAndPost');
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
  assert(!/XI \/ REgraphics:|No se pudo iniciar el programa propio/.test(text),'renderer/startup error');
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
  for(let attempt=0;attempt<2;attempt++){
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
          sleep(300);continue;
        }
        const app=all.filter(x=>x.package===pkg);
        if(app.length){
          checkNoFailure(app.map(x=>x.text||'').join('\n'));
          return app;
        }
      }
    }
    why=String(p.error||p.stdout||p.stderr).slice(-1200);sleep(250);
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
  adbText(['shell','am','force-stop',pkg]);
  adbText(['logcat','-c']);
  const launch=adbText(['shell','am','start','-W','-n',component]);
  fs.writeFileSync(path.join(out,'launch.txt'),launch);
  check(!/Error:|Exception|does not exist/i.test(launch),'standalone Velocity launcher starts');
  rememberPid();
  initialMarker=waitFrame();check(!!initialMarker,'real Canvas frame posted');
  screenshot('initial-screen');
  stage='ready HUD';
  let ui=waitText(/ACELERA PARA SALIR/);
  check(ui.some(x=>/REgraphics/.test(x.text||'')),'REgraphics live HUD');
  check(!!findText(ui,'ACELERAR'),'accelerator physical control');
  stage='physical acceleration';
  tapNode(findText(ui,'ACELERAR'),1800);
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
  const pauseHud=ui.find(x=>/EN PAUSA/.test(x.text||'')).text;
  sleep(1100);ui=waitText(/EN PAUSA/);
  const laterHud=ui.find(x=>/EN PAUSA/.test(x.text||'')).text;
  const time=s=>(s.match(/\b\d+:\d{2}\b/)||[])[0];
  check(time(pauseHud)&&time(pauseHud)===time(laterHud),'race timer remains fixed while paused');
  stage='continue';tapNode(findText(ui,'Continuar'));
  ui=waitText(/CARRERA/);check(!ui.some(x=>/EN PAUSA/.test(x.text||'')),'continue resumes race');
  stage='camera and paint';tapNode(findText(ui,'Cámara'));
  ui=waitText(/^Cercana$/);check(!!findText(ui,'Cercana'),'physical camera changes to close chase');
  tapNode(findText(ui,'Color'));ui=waitText(/^Color 2$/);
  check(!!findText(ui,'Color 2'),'physical paint selection changes');
  screenshot('changed-camera-paint');
  stage='background resume';
  const before=markerLines(logs()).length;
  adbText(['shell','input','keyevent','KEYCODE_HOME']);sleep(400);
  adbText(['shell','am','start','-W','-a','android.intent.action.MAIN',
    '-c','android.intent.category.LAUNCHER','-f','0x10200000','-n',component]);
  rememberPid();
  resumedMarker=waitFrame(before);check(!!resumedMarker,'new actual Canvas frame after Activity resume');
  report.resumedTicks=Number((/ticks=(\d+)/.exec(resumedMarker)||[])[1]);
  check(Number.isInteger(report.resumedTicks)&&report.resumedTicks>0,
    'Activity resume retains started race state');
  ui=waitText(/REgraphics/);check(ui.length>0,'game remains usable after resume');
  checkNoFailure(logs());check(true,'no fatal Java/native or renderer error');
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
