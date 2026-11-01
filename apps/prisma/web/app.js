import { RhythmAudio, DEMO_BPM, DEMO_DURATION, analyseRhythm, waveformOf, seeded } from './audio.js';
import { Scene, makeChart, DIRECTIONS, PALETTES } from './engine.js';
import { hitWindowFor, isEndOfSong, nearestSwipeNote, nearestKeyNote, timingLabel } from './rhythm-qa.js';
import { makeMusicStage } from './music-stage.js';
const $ = id => document.getElementById(id);
const all = selector => [...document.querySelectorAll(selector)];
const clamp = (v,a,b) => Math.max(a,Math.min(b,v));
const formatTime = seconds => { const s=Math.max(0,Math.floor(seconds));return `${Math.floor(s/60)}:${String(s%60).padStart(2,'0')}`; };
let saved={};try{saved=JSON.parse(localStorage.getItem('prisma.settings')||'{}')||{};}catch{}
const settings={quality:['auto','high','battery'].includes(saved.quality)?saved.quality:'auto',palette:['coral','violet','ice'].includes(saved.palette)?saved.palette:'coral',precise:!!saved.precise,effects:saved.effects??matchMedia('(prefers-reduced-motion: reduce)').matches,latency:clamp(Number(saved.latency)||0,-200,200),volume:clamp(saved.volume??65,0,100)};
let records=[];try{records=JSON.parse(localStorage.getItem('prisma.records')||'[]');if(!Array.isArray(records))records=[];}catch{}
const audio=new RhythmAudio();audio.volume=settings.volume/100;
const scene=new Scene($('game'),()=>settings);
const random=seeded(3334);
const demoWave=Array.from({length:160},(_,i)=>.18+random()*.55+Math.sin(i*.38)**2*.23);
const demoPeaks=Array.from({length:252},(_,i)=>({t:(i+4)*60/DEMO_BPM/2,strength:i%2===0?1:.36})).filter(p=>p.t<DEMO_DURATION-2.0);
let track={name:'Midnight Motion',demo:true,bpm:DEMO_BPM,duration:DEMO_DURATION,peaks:demoPeaks,wave:demoWave,buffer:null,fallback:false};
let level='flow', chart=[], status='home', frozenTime=0, booting=false, missIndex=0, sceneDirty=true, gameBounds=null, lastScene=0, lastElapsed='';
let score=0,combo=0,maxCombo=0,hits=0,misses=0,lastFrame=performance.now(),lastUI=0,feedbackUntil=0,toastTimer,activePointers=new Map(),runId=0;
const nativeGraphics=typeof window.ReverseGraphics?.event==='function'?window.ReverseGraphics:null;
let nativeSerial=0,nativeFailure=false;
const nativePending=new Map();
function nativeEvent(kind,base,run=runId){
  if(!nativeGraphics)return Promise.resolve(true);
  const serial=++nativeSerial;let resolve;const promise=new Promise(done=>resolve=done);
  const timer=setTimeout(()=>nativeReply({serial,run,ok:false,error:'El motor XI no confirmó el evento.'}),6000);
  nativePending.set(serial,{run,resolve,timer,promise});
  try{nativeGraphics.event(serial,run,kind,base);}catch{nativeReply({serial,run,ok:false,error:'No se pudo enviar el evento al motor XI.'});}
  return promise;
}
function nativeReply(data){
  const entry=nativePending.get(data?.serial);if(!entry||entry.run!==data.run)return;
  nativePending.delete(data.serial);clearTimeout(entry.timer);
  if(data.run===runId){
    if(!data.ok){nativeFailure=true;if(status==='playing')pauseGame();toast(data.error||'El estado XI no se pudo guardar.');}
    else if(![...nativePending.values()].some(item=>item.run===runId)){
      const v=data.state;if(v){score=v.score;combo=v.combo;hits=v.hits;misses=v.misses;maxCombo=v.maxCombo;updateScores();}
    }
  }
  entry.resolve(!!data.ok);
}
window.addEventListener('reverse-score',event=>nativeReply(event.detail));
let landscape=innerWidth>=innerHeight;
const frameSamples=[];
const levelNames={flow:'Flow',pulse:'Pulso',vertigo:'Vértigo'};
function persistSettings(){try{localStorage.setItem('prisma.settings',JSON.stringify(settings));}catch{}}
function toast(text){$('toast').textContent=text;$('toast').classList.add('show');clearTimeout(toastTimer);toastTimer=setTimeout(()=>$('toast').classList.remove('show'),4200);}
function feedback(text,color=PALETTES[settings.palette][0]){$('feedback').textContent=text;$('feedback').style.color=color;$('feedback').classList.add('show');feedbackUntil=performance.now()+500;}
function setLoading(active,text='Encontrando el ritmo…'){$('loadingOverlay').hidden=!active;$('loadingText').textContent=text;$('startBtn').disabled=active;}
function setStatus(next){
  status=next;sceneDirty=true;const session=['playing','paused','ended','finishing'].includes(next);
  $('stage').classList.toggle('is-session',session);document.body.classList.toggle('in-session',session);document.body.classList.toggle('is-playing',next==='playing');
  $('hud').hidden=!session;$('pauseOverlay').hidden=next!=='paused';$('resultOverlay').hidden=next!=='ended';
  if(next!=='playing')$('countdown').hidden=true;
  $('audioStatus').textContent=next==='playing'?'AUDIO REACTIVO':next==='paused'?'EN PAUSA':'LISTO PARA EL BEAT';
  all('[data-level]').forEach(b=>{b.disabled=next==='playing'||next==='paused';b.title=b.disabled?'Cambia la intensidad desde el inicio':'';});
  $('pauseBtn').hidden=next==='ended';
  $('sceneLabel').textContent=session?track.name.toUpperCase():'UN UNIVERSO. TU RITMO.';
}
function updateTrack(){
  $('trackName').textContent=track.name;
  $('trackInfo').textContent=`${track.demo?'PRISMA ORIGINAL':'TU MÚSICA'} · ${track.demo?'':'≈ '}${track.bpm} BPM${track.variableTempo?' · TEMPO VARIABLE (APROX.)':''}`;
  $('duration').textContent=formatTime(Math.round(track.duration));$('elapsed').textContent='0:00';drawWave(0);
}
function updateScores(){
  $('score').textContent=String(score).padStart(6,'0');$('combo').textContent=combo;
  $('accuracy').textContent=`${hits+misses?Math.round(hits/(hits+misses)*100):100}% PRECISIÓN`;
}
function bestForTrack(){return Math.max(0,...records.filter(r=>r.track===track.name&&r.level===level).map(r=>r.score));}
async function startGame(){
  if(booting)return;booting=true;const thisRun=++runId;
  try{
    await enterFullscreen();
    if(matchMedia('(orientation: portrait)').matches){toast('Gira el dispositivo para jugar en horizontal.');return;}
    await audio.init();
    if(!track.buffer){setLoading(true,'Preparando tu primera sesión…');track.buffer=await audio.makeDemo();track.wave=waveformOf(track.buffer);}
    if(thisRun!==runId)return;
    setLoading(false);audio.buffer=track.buffer;
    const peaks=track.demo&&level==='flow'?track.peaks.filter((_,i)=>i%2===0):track.peaks;
    const musicMap=makeMusicStage(track.peaks,{bpm:track.bpm,duration:track.duration,
       energy:track.energy,tempoSegments:track.tempoSegments,fallback:track.fallback});
    chart=makeChart(peaks,level,track.demo?7721:Math.round(track.duration*173),musicMap);
    if(!chart.length)throw new Error('No hay suficientes golpes para una partida. Prueba con una canción más larga.');
    score=combo=maxCombo=hits=misses=missIndex=0;activePointers.clear();scene.clearEffects();
     scene.setMusicStage(musicMap);frozenTime=0;
    $('bestInGame').textContent=`RÉCORD ${bestForTrack().toLocaleString('es')}`;updateScores();
    $('hitHelp').style.opacity='1';$('feedback').classList.remove('show');
    nativeFailure=false;if(nativeGraphics&&!await nativeEvent(0,0,thisRun))throw new Error('No se pudo iniciar la sesión XI.');
    setStatus('playing');audio.play(0,2.8);$('game').focus({preventScroll:true});
  }catch(error){setLoading(false);setStatus('home');toast(error.message||'No se pudo iniciar la pista. Inténtalo otra vez.');}
  finally{booting=false;}
}
function pauseGame(){if(status!=='playing')return;frozenTime=audio.pause();activePointers.clear();for(const id of scene.trails.keys())scene.endTrail(id);setStatus('paused');$('resumeBtn').focus({preventScroll:true});}
async function resumeGame(){if(status!=='paused')return;try{await audio.init();audio.play(frozenTime,0);setStatus('playing');$('game').focus({preventScroll:true});}catch{toast('Toca Continuar para reactivar el audio.');}}
function goHome(){runId++;audio.stop();audio.offset=0;activePointers.clear();scene.clearEffects();scene.clearMusicStage();setLoading(false);setStatus('home');$('elapsed').textContent='0:00';$('feedback').classList.remove('show');drawWave(0);}
async function finishGame(){
  if(status!=='playing')return;audio.stop();frozenTime=track.duration;
  const finishRun=runId;
  if(nativeGraphics){setStatus('finishing');setLoading(true,'Guardando tu sesión…');await Promise.all([...nativePending.values()].filter(item=>item.run===finishRun).map(item=>item.promise));if(finishRun!==runId)return;setLoading(false);if(nativeFailure){setStatus('paused');return;}}
  setStatus('ended');
  const accuracy=chart.length?Math.round(hits/chart.length*100):0,previous=bestForTrack();
  $('resultRank').textContent=accuracy>=97?'S':accuracy>=85?'A':accuracy>=65?'B':accuracy>=40?'C':'D';
  $('resultTitle').textContent=accuracy>=85?'Ese es tu flow.':accuracy>=40?'El ritmo está en ti.':'Tu próximo flow te espera.';
  $('resultScore').textContent=score.toLocaleString('es');$('resultHits').textContent=hits;$('resultAccuracy').textContent=`${accuracy}%`;$('resultCombo').textContent=maxCombo;
  $('recordNotice').textContent=score>previous?'NUEVO RÉCORD PERSONAL':hits?'Cada sesión te lleva un poco más lejos.':'Sigue las flechas o toca los cubos en modo Flow.';
  if(score>0){const r={track:track.name,level,score,accuracy,combo:maxCombo,date:Date.now()};records=records.filter(item=>!(item.track===r.track&&item.level===r.level&&item.score<=score));records.push(r);records.sort((a,b)=>b.score-a.score);records=records.slice(0,30);try{localStorage.setItem('prisma.records',JSON.stringify(records));}catch{}}
  $('elapsed').textContent=formatTime(Math.round(track.duration));drawWave(1);$('replayBtn').focus({preventScroll:true});
}
const hitWindow=()=>hitWindowFor(level);
function cut(note,t,dx,dy,isTap=false,isKey=false){
  if(note.hit||note.missed)return false;
  const delta=note.t+settings.latency/1000-t;if(Math.abs(delta)>hitWindow())return false;
  const dir=DIRECTIONS[note.dir],length=Math.hypot(dx,dy),dot=length?(dx*dir.x+dy*dir.y)/length:0,correct=dot>.43;
  if(settings.precise&&(!correct||isTap))return false;
  note.hit=true;audio.swish(note.color);hits++;combo++;maxCombo=Math.max(combo,maxCombo);
   scene.armCombo(combo,t);
  const perfect=Math.abs(delta)<.145&&(correct||isKey),base=perfect?150:correct?105:isTap?70:80,multiplier=Math.min(4,1+Math.floor(combo/12));
  score+=base*multiplier;if(nativeGraphics)nativeEvent(1,base);
  const p=scene.noteProjection(note,t,settings.latency/1000);scene.burst(note,p,dx||15,dy||-35,perfect?1:.6);
  feedback(combo>0&&combo%12===0?`FLOW ×${multiplier}`:timingLabel(delta,perfect,correct||isKey,isTap),PALETTES[settings.palette][note.color]);
  if(navigator.vibrate&&!settings.effects&&!isKey)navigator.vibrate(8);
  updateScores();return true;
}
function processSwipe(ax,ay,bx,by,isTap=false){
  if(status!=='playing')return;const t=audio.time();if(t<0)return;
  const dx=bx-ax,dy=by-ay;if(!isTap&&Math.hypot(dx,dy)<3)return;
  if(isTap&&(level!=='flow'||settings.precise))return;
  const note=nearestSwipeNote(chart,t,settings.latency/1000,level,ax,ay,bx,by,
    (n,at,latency)=>scene.noteProjection(n,at,latency),
    {precise:settings.precise,isTap});
  if(note)cut(note,t,dx,dy,isTap);
}
const point=e=>{const rect=gameBounds||(gameBounds=$('game').getBoundingClientRect());return{x:e.clientX-rect.left,y:e.clientY-rect.top};};
$('game').addEventListener('pointerdown',e=>{
  if(status!=='playing')return;e.preventDefault();gameBounds=$('game').getBoundingClientRect();$('game').setPointerCapture(e.pointerId);const p=point(e),color=PALETTES[settings.palette][activePointers.size%2];
  activePointers.set(e.pointerId,{...p,startX:p.x,startY:p.y,moved:false,color});scene.addTrail(e.pointerId,p.x,p.y,color);
});
$('game').addEventListener('pointermove',e=>{
  const prev=activePointers.get(e.pointerId);if(!prev||status!=='playing')return;e.preventDefault();
  const events=e.getCoalescedEvents?.()||[e];
  for(const sample of events.length?events:[e]){const p=point(sample);scene.addTrail(e.pointerId,p.x,p.y,prev.color);processSwipe(prev.x,prev.y,p.x,p.y);if(Math.hypot(p.x-prev.startX,p.y-prev.startY)>8)prev.moved=true;prev.x=p.x;prev.y=p.y;}
});
function releasePointer(e){const p=activePointers.get(e.pointerId);if(p){if(!p.moved&&e.type==='pointerup')processSwipe(p.x,p.y,p.x,p.y,true);scene.endTrail(e.pointerId);activePointers.delete(e.pointerId);}}
$('game').addEventListener('pointerup',releasePointer);$('game').addEventListener('pointercancel',releasePointer);$('game').addEventListener('lostpointercapture',releasePointer);
$('game').addEventListener('contextmenu',e=>e.preventDefault());
document.addEventListener('keydown',e=>{
  if(e.repeat||document.querySelector('dialog[open]')||['INPUT','SELECT','TEXTAREA'].includes(document.activeElement?.tagName))return;
  if(e.code==='Space'||e.code==='Escape'){if(status==='playing'){e.preventDefault();pauseGame();}else if(status==='paused'){e.preventDefault();resumeGame();}return;}
  if(e.code==='Enter'&&status==='home'){e.preventDefault();startGame();return;}
  const keyIndex={ArrowUp:0,ArrowRight:1,ArrowDown:2,ArrowLeft:3}[e.code];if(keyIndex===undefined||status!=='playing')return;e.preventDefault();
  const t=audio.time();
  const note=nearestKeyNote(chart,t,settings.latency/1000,level,keyIndex);
  if(note){const n=note,d=DIRECTIONS[keyIndex],p=scene.noteProjection(n,t,settings.latency/1000),id='key-'+performance.now();scene.addTrail(id,p.x-d.x*50,p.y-d.y*50,PALETTES[settings.palette][n.color]);scene.addTrail(id,p.x+d.x*50,p.y+d.y*50,PALETTES[settings.palette][n.color]);scene.endTrail(id);cut(n,t,d.x*100,d.y*100,false,true);}

});
async function loadFile(file){
  if(!file)return;if(file.size===0){toast('Este archivo está vacío. Elige una canción.');return;}
  if(file.size>100*1024*1024){toast('El archivo supera 100 MB. Prueba con una versión más pequeña.');return;}
  if(booting){toast('Espera a que termine de prepararse la pista.');return;}
  goHome();booting=true;setLoading(true,'Leyendo tu canción…');
  try{
    const buffer=await audio.decode(file);if(buffer.duration<3)throw new Error('Elige un audio de al menos 3 segundos para crear una pista.');
    if(buffer.duration>1800)throw new Error('Esta versión admite pistas de hasta 30 minutos.');
    setLoading(true,'Encontrando los golpes de tu música…');await new Promise(r=>setTimeout(r,30));
    const analysis=await analyseRhythm(buffer);
    track={name:file.name.replace(/\.[^/.]+$/,''),demo:false,bpm:analysis.bpm,duration:buffer.duration,peaks:analysis.peaks,energy:analysis.energy,tempoSegments:analysis.tempoSegments,variableTempo:analysis.variableTempo,wave:waveformOf(buffer),buffer,fallback:analysis.fallback};
    updateTrack();toast(analysis.fallback?'Pista lista. Esta canción tiene un pulso suave: creamos una secuencia regular.':'Tu música, tu pista. Lista para entrar en flow.');
  }catch(error){toast(error.message||'No se pudo analizar esta canción. Prueba con otro archivo.');}
  finally{setLoading(false);booting=false;$('audioFile').value='';}
}
$('audioFile').addEventListener('change',e=>loadFile(e.target.files[0]));
all('[data-upload]').forEach(b=>b.addEventListener('click',()=>{if(status==='playing')pauseGame();$('audioFile').click();}));
$('demoBtn').addEventListener('click',()=>{if(booting)return;goHome();track={name:'Midnight Motion',demo:true,bpm:DEMO_BPM,duration:DEMO_DURATION,peaks:demoPeaks,wave:audio.demoBuffer?waveformOf(audio.demoBuffer):demoWave,buffer:audio.demoBuffer||null};updateTrack();toast('Midnight Motion · pista original seleccionada');});
$('startBtn').addEventListener('click',startGame);$('replayBtn').addEventListener('click',startGame);$('restartBtn').addEventListener('click',startGame);
$('pauseBtn').addEventListener('click',pauseGame);$('resumeBtn').addEventListener('click',resumeGame);$('exitBtn').addEventListener('click',goHome);$('homeBtn').addEventListener('click',goHome);
$('navPlay').addEventListener('click',()=>{if(status==='paused')resumeGame();else if(status==='home')$('startBtn').focus({preventScroll:true});else $('game').focus({preventScroll:true});});
document.querySelector('.brand').addEventListener('click',e=>{e.preventDefault();if(!booting)goHome();});
all('[data-level]').forEach(b=>b.addEventListener('click',()=>{level=b.dataset.level;all('[data-level]').forEach(x=>{const selected=x===b;x.classList.toggle('selected',selected);x.setAttribute('aria-pressed',String(selected));});if(status==='ended')goHome();toast({flow:'Flow · un golpe a la vez. También admite toques.',pulse:'Pulso · más notas y cortes más rápidos.',vertigo:'Vértigo · dobles cubos y máxima intensidad.'}[level]);}));
function updateRendererStatus(){
  $('rendererStatus').textContent='Motor gráfico: '+(scene.gpu?.native?'Ether Render X nativo':
    scene.gpu?'Graphics/COSMIC WebGL':'Canvas de reserva');
}
function openDialog(id){
  if(status==='playing')pauseGame();
  if(id==='recordsDialog')renderRecords();
  if(id==='settingsDialog')updateRendererStatus();
  $(id).showModal();
}
all('[data-dialog]').forEach(b=>b.addEventListener('click',()=>openDialog(b.dataset.dialog)));
all('.close-dialog').forEach(b=>b.addEventListener('click',()=>b.closest('dialog').close()));
all('dialog').forEach(dialog=>dialog.addEventListener('click',e=>{if(e.target===dialog){const r=dialog.getBoundingClientRect();if(e.clientX<r.left||e.clientX>r.right||e.clientY<r.top||e.clientY>r.bottom)dialog.close();}}));
function renderRecords(){const list=$('recordList');list.replaceChildren();if(!records.length){const p=document.createElement('p');p.className='dialog-lead';p.textContent='Tu primera marca todavía está por escribirse. Completa una pista y vuelve aquí.';list.append(p);return;}for(const r of records.slice(0,8)){const row=document.createElement('div'),meta=document.createElement('span'),small=document.createElement('small'),value=document.createElement('strong');meta.textContent=r.track;small.textContent=`${levelNames[r.level]||'Flow'} · ${r.accuracy}% precisión · ${r.combo} combo`;meta.append(small);value.textContent=r.score.toLocaleString('es');row.append(meta,value);list.append(row);}}
$('quality').value=settings.quality;$('palette').value=settings.palette;$('precise').checked=settings.precise;$('effects').checked=settings.effects;$('latency').value=settings.latency;$('volume').value=settings.volume;$('latencyValue').textContent=`${settings.latency>0?'+':''}${settings.latency} ms`;
function updatePalette(){sceneDirty=true;const palette=PALETTES[settings.palette];document.documentElement.style.setProperty('--green',palette[0]);document.documentElement.style.setProperty('--coral',palette[1]);all('.palette-legend>span')[0].lastChild.textContent=settings.palette==='ice'?'HIELO':'ESMERALDA';all('.palette-legend>span')[1].lastChild.textContent=settings.palette==='violet'?'VIOLETA':'CORAL';}
$('quality').addEventListener('change',e=>{settings.quality=e.target.value;scene.qualityScale=1;scene.resize();sceneDirty=true;persistSettings();});
$('palette').addEventListener('change',e=>{settings.palette=e.target.value;updatePalette();persistSettings();});
$('precise').addEventListener('change',e=>{settings.precise=e.target.checked;persistSettings();});
$('effects').addEventListener('change',e=>{settings.effects=e.target.checked;persistSettings();});
$('latency').addEventListener('input',e=>{settings.latency=Number(e.target.value);$('latencyValue').textContent=`${settings.latency>0?'+':''}${settings.latency} ms`;persistSettings();});
$('latencyReset').addEventListener('click',()=>{settings.latency=0;$('latency').value='0';$('latencyValue').textContent='0 ms';persistSettings();});
function updateMute(){const muted=audio.muted||settings.volume===0;$('muteBtn').querySelector('use').setAttribute('href',muted?'#i-mute':'#i-sound');$('muteBtn').setAttribute('aria-label',muted?'Activar música':'Silenciar música');}
$('volume').addEventListener('input',e=>{settings.volume=Number(e.target.value);audio.setVolume(settings.volume/100,false);updateMute();persistSettings();});
$('muteBtn').addEventListener('click',()=>{audio.setVolume(settings.volume/100,!audio.muted);updateMute();});
async function enterFullscreen(){
  try{
    if(nativeGraphics?.immersive())return;
    if(!document.fullscreenElement&&document.documentElement.requestFullscreen)await document.documentElement.requestFullscreen({navigationUI:'hide'});
    if(screen.orientation?.lock)await screen.orientation.lock('landscape');
  }catch{/* The landscape gate remains visible on browsers without orientation locking. */}
  gameBounds=null;scene.resize();sceneDirty=true;
}
$('fullscreenBtn').addEventListener('click',()=>{if(document.fullscreenElement)document.exitFullscreen().catch(()=>{});else enterFullscreen();});
$('rotateFullscreen').addEventListener('click',enterFullscreen);
function viewportChanged(){landscape=innerWidth>=innerHeight;gameBounds=null;sceneDirty=true;scene.resize();if(matchMedia('(orientation: portrait)').matches&&status==='playing')pauseGame();}
window.addEventListener('resize',viewportChanged);
document.addEventListener('fullscreenchange',()=>{viewportChanged();$('fullscreenBtn').setAttribute('aria-label',document.fullscreenElement?'Salir de pantalla completa':'Pantalla completa');});
document.addEventListener('visibilitychange',()=>{if(document.hidden&&status==='playing')pauseGame();});
window.addEventListener('prisma-native-pause',pauseGame);
window.addEventListener('blur',()=>{if(status==='playing')pauseGame();});
// Drag a local audio file onto the page. Nothing is uploaded to a server.
let dragDepth=0;
document.addEventListener('dragenter',e=>{if(e.dataTransfer?.types.includes('Files')){e.preventDefault();dragDepth++;$('stage').classList.add('drag-over');}});
document.addEventListener('dragover',e=>{if(e.dataTransfer?.types.includes('Files'))e.preventDefault();});
document.addEventListener('dragleave',()=>{dragDepth=Math.max(0,dragDepth-1);if(!dragDepth)$('stage').classList.remove('drag-over');});
document.addEventListener('drop',e=>{e.preventDefault();dragDepth=0;$('stage').classList.remove('drag-over');const file=e.dataTransfer?.files[0];if(file)loadFile(file);});
function drawWave(progress){
  const canvas=$('waveform'),rect=canvas.getBoundingClientRect(),dpr=Math.min(devicePixelRatio||1,2);if(!rect.width)return;
  if(canvas.width!==Math.round(rect.width*dpr)||canvas.height!==Math.round(rect.height*dpr)){canvas.width=Math.round(rect.width*dpr);canvas.height=Math.round(rect.height*dpr);}
  const c=canvas.getContext('2d');c.setTransform(dpr,0,0,dpr,0,0);c.clearRect(0,0,rect.width,rect.height);
  const count=Math.max(10,Math.floor(rect.width/4)),step=rect.width/count;
  for(let i=0;i<count;i++){const v=track.wave[Math.floor(i/count*track.wave.length)]||.08,h=Math.max(2,v*(rect.height-3));c.fillStyle=i/count<=progress?PALETTES[settings.palette][0]:'#36503e';c.fillRect(i*step,rect.height/2-h/2,Math.max(1,step*.42),h);}
}
let lastFrameAt=performance.now();
function frame(now){
  const interval=now-lastFrame,dt=Math.min(.045,interval/1000);lastFrame=now;
  if(scene.diagnostics&&status==='playing'&&interval<100){frameSamples.push(interval);if(frameSamples.length>240)frameSamples.shift();if(frameSamples.length%30===0){const sorted=[...frameSamples].sort((a,b)=>a-b);$('game').dataset.frameMs=(sorted.reduce((a,b)=>a+b,0)/sorted.length).toFixed(2);$('game').dataset.frameP95=sorted[Math.floor(sorted.length*.95)].toFixed(2);}}
  let t=status==='playing'?audio.time():frozenTime;
  if(status==='playing'){
    const missAfter=hitWindow();let changed=false;
    while(missIndex<chart.length&&chart[missIndex].t+settings.latency/1000<t-missAfter){const n=chart[missIndex++];if(!n.hit&&!n.missed){n.missed=true;misses++;combo=0;scene.cancelCombo();changed=true;if(nativeGraphics)nativeEvent(2,0);}}
    if(changed){updateScores();feedback('SIGUE EL RITMO','#809c89');}
    $('countdown').hidden=t>=0;
    if(t<0){const count=Math.ceil(-t);if($('countdown').dataset.count!==String(count)){$('countdown').dataset.count=count;$('countdown').replaceChildren();$('countdown').append(String(count));const small=document.createElement('small');small.textContent='ENCUENTRA EL RITMO';$('countdown').append(small);}}
    if(t>7)$('hitHelp').style.opacity='0';
    if(isEndOfSong(t,track.duration,level,settings.latency/1000)){finishGame();t=track.duration;}
  }
  if(now>feedbackUntil)$('feedback').classList.remove('show');
  const preview=!['playing','paused','ended','finishing'].includes(status);
  if(landscape&&!document.hidden&&(status==='playing'||sceneDirty||(preview&&now-lastScene>32))){scene.render(preview?now/1000:t,dt,chart,preview,audio.energy(),settings.latency/1000,status==='playing'||preview);sceneDirty=false;lastScene=now;}
  if(status==='playing')scene.adapt(Math.min(.2,(now-lastFrameAt)/1000),now);lastFrameAt=now;
  if(now-lastUI>90){lastUI=now;if(status==='playing'){const elapsed=formatTime(t);if(elapsed!==lastElapsed){$('elapsed').textContent=elapsed;lastElapsed=elapsed;}drawWave(clamp(t/track.duration,0,1));}}
  requestAnimationFrame(frame);
}
new ResizeObserver(()=>{drawWave(status==='playing'?clamp(audio.time()/track.duration,0,1):0);sceneDirty=true;}).observe($('waveform'));
updatePalette();updateTrack();updateMute();setStatus('home');requestAnimationFrame(frame);
