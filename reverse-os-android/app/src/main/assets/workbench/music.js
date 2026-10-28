'use strict';

// Desktop UI owns the library. The native, bridge-free WebView owns YouTube.
function musicEmptyStatus(shield=true){return {loaded:false,phase:'idle',shield,blocked:0,paused:true,hasMedia:false,error:'',notice:'',title:'',url:'',time:0,duration:0,ad:false,held:false,live:false,canSeek:false,canNext:false,canPrevious:false,mediaError:''};}
let musicStatus=musicEmptyStatus();
let musicBoundsFrame=0,musicLastBounds='',musicOwner=null;
function musicSavedURL(value){
  try{
    if(typeof value!=='string'||value.length>2048)return '';
    const u=new URL(value);
    if(u.protocol!=='https:'||u.username||u.password||(u.port&&u.port!=='443')||!['youtube.com','www.youtube.com','m.youtube.com','music.youtube.com','youtu.be'].includes(u.hostname))return '';
    let id=u.pathname==='/watch'?u.searchParams.get('v'):null;const list=u.searchParams.get('list');
    if(u.hostname==='youtu.be')id=u.pathname.slice(1).split('/')[0];
    if(/^\/(shorts|live|embed)\//.test(u.pathname))id=u.pathname.split('/')[2];
    if(/^[\w-]{11}$/.test(id||''))return 'https://m.youtube.com/watch?v='+id+(/^[\w-]{1,160}$/.test(list||'')?'&list='+list:'');
    if(u.pathname==='/playlist'&&/^[\w-]{1,160}$/.test(list||''))return 'https://m.youtube.com/playlist?list='+list;
  }catch{}
  return '';
}
function cleanMusicState(raw){
  const seen=new Set();
  const favorites=(Array.isArray(raw?.favorites)?raw.favorites:[]).slice(0,100).flatMap(item=>{
    const url=musicSavedURL(item?.url);
    if(!url||seen.has(url))return [];seen.add(url);
    return [{url,title:typeof item.title==='string'?item.title.slice(0,240):'YouTube'}];
  });
  return {favorites,lastInput:typeof raw?.lastInput==='string'?raw.lastInput.slice(0,2048):''};
}
function musicNative(action,data={}){
  if(typeof window.ReverseNative?.music!=='function'){
    if(!['bounds','status','close'].includes(action))toast('La reproducción requiere la APK de REVERSE con Music.','help');
    return false;
  }
  const windowId=data.windowId||musicOwner||state.windows.find(w=>w.app==='music')?.id;
  if(!windowId)return false;window.ReverseNative.music(action,JSON.stringify({...data,windowId}));return true;
}
function musicHTML(w){
  const library=state.music||=cleanMusicState();
  const favorites=w.musicTab==='favorites';
  return '<div class="music-app"><div class="music-heading"><div class="music-brand">'+icon('music')+'<strong>REVERSE Music</strong><span>YouTube</span></div><button class="music-shield" data-music-action="shield" aria-pressed="'+musicStatus.shield+'" title="Activar o desactivar el bloqueador">'+icon('lock')+'<span data-music-shield>Bloqueador '+(musicStatus.shield?'activado':'desactivado')+'</span></button></div>'+
    '<form class="music-search" data-music-search><label>'+icon('search')+'<input name="query" aria-label="Buscar música o pegar enlace de YouTube" placeholder="Artista, canción o enlace de YouTube" maxlength="2048" autocomplete="off" value="'+esc(library.lastInput)+'"></label><button class="primary-button" type="submit">Buscar</button></form>'+
    '<nav class="music-tabs" aria-label="Secciones de Music"><button data-music-tab="player" aria-selected="'+!favorites+'">Reproductor</button><button data-music-tab="favorites" aria-selected="'+favorites+'">Favoritos <span data-music-count>'+library.favorites.length+'</span></button><span data-music-blocked>'+musicStatus.blocked+' solicitudes bloqueadas</span></nav>'+
    (favorites?'<div class="music-library">'+(library.favorites.length?library.favorites.map((item,i)=>'<div class="music-favorite"><button data-music-favorite="'+i+'">'+icon('music')+'<span>'+esc(item.title)+'</span>'+icon('play')+'</button><button class="icon-button" data-music-remove="'+i+'" aria-label="Quitar '+esc(item.title)+' de favoritos">'+icon('close')+'</button></div>').join(''):'<div class="music-empty">'+icon('music')+'<strong>Tu música, a mano.</strong><p>Abre una canción o lista y pulsa Guardar favorito.</p></div>')+'</div>':
      '<div class="music-stage" data-music-stage><div class="music-empty">'+icon('music')+'<strong data-music-placeholder>Escucha desde tu escritorio.</strong><p data-music-hint>Busca una canción o abre YouTube para empezar.</p><button class="secondary-button" data-music-action="home">Abrir YouTube</button></div></div>')+
    '<div class="music-error" data-music-error role="status" hidden></div><input class="music-seek" data-music-seek type="range" min="0" max="0" step="1" value="0" aria-label="Posición de la canción" disabled><div class="music-controls"><div class="music-track"><strong data-music-title>Sin reproducción</strong><span data-music-time>0:00 / 0:00</span></div><div class="music-transport"><button class="icon-button" data-music-action="previous" aria-label="Canción anterior">'+icon('previous')+'</button><button class="icon-button music-play" data-music-action="toggle" aria-label="Reproducir o pausar">'+icon('play')+'</button><button class="icon-button" data-music-action="next" aria-label="Canción siguiente">'+icon('next')+'</button></div><button class="secondary-button music-save" data-music-action="favorite" title="Guardar canción o lista actual">'+icon('plus')+'<span>Guardar favorito</span></button></div>'+
    '<footer class="music-footer"><div><button data-music-action="back" title="Atrás">'+icon('arrow-left')+'</button><button data-music-action="reload" title="Recargar">'+icon('restore')+'</button></div><span>Bloqueo experimental · reproducción en línea</span></footer></div>';
}
function musicTime(value){const s=Number.isFinite(Number(value))?Math.max(0,Math.floor(Number(value))):0;return Math.floor(s/60)+':'+String(s%60).padStart(2,'0');}
function updateMusicUI(){
  for(const win of $$('.window[data-app="music"]')){
    const text=(selector,value)=>{const el=$(selector,win);if(el&&el.textContent!==value)el.textContent=value;};
    text('[data-music-title]',musicStatus.title||'Sin reproducción');
    text('[data-music-time]',musicStatus.live?'En directo':musicTime(musicStatus.time)+' / '+musicTime(musicStatus.duration));
    const seek=$('[data-music-seek]',win);if(seek){seek.disabled=!musicStatus.hasMedia||!musicStatus.canSeek||!!musicStatus.ad||!(musicStatus.duration>0);seek.max=String(musicStatus.duration||0);if(seek.dataset.scrubbing!=='true')seek.value=String(musicStatus.time||0);}
    text('[data-music-shield]','Bloqueador '+(musicStatus.shield?'activado':'desactivado'));
    text('[data-music-blocked]',musicStatus.blocked+' solicitudes bloqueadas');
    const shield=$('[data-music-action="shield"]',win);shield?.setAttribute('aria-pressed',String(musicStatus.shield));
    const error=$('[data-music-error]',win);if(error){const message=musicStatus.error||musicStatus.mediaError||musicStatus.notice;error.hidden=!message;error.textContent=message||'';}
    const play=$('[data-music-action="toggle"]',win);if(play){const mode=musicStatus.paused?'play':'pause';if(play.dataset.mode!==mode){play.innerHTML=icon(mode);play.dataset.mode=mode;}play.setAttribute('aria-label',musicStatus.paused?'Reproducir':'Pausar');}
    $$('[data-music-action="toggle"],[data-music-action="previous"],[data-music-action="next"]',win).forEach(el=>el.disabled=!musicStatus.hasMedia||(el.dataset.musicAction==='next'&&!musicStatus.canNext)||(el.dataset.musicAction==='previous'&&!musicStatus.canPrevious));
    const save=$('[data-music-action="favorite"]',win);if(save)save.disabled=!musicSavedURL(musicStatus.url);
    text('[data-music-placeholder]',musicStatus.phase==='error'?'No se pudo cargar YouTube':musicStatus.phase==='loading'?'Cargando YouTube…':'Escucha desde tu escritorio.');
    text('[data-music-hint]',typeof window.ReverseNative?.music==='function'?'Busca una canción o abre YouTube para empezar.':'La reproducción está disponible en la APK de REVERSE Music.');
  }
}
function syncMusicBounds(){
  musicBoundsFrame=0;
  const owner=state.windows.find(w=>w.app==='music');
  if(!owner){if(musicOwner){musicNative('close');musicStatus=musicEmptyStatus(musicStatus.shield);musicOwner=null;musicLastBounds='';}return;}
  if(musicOwner!==owner.id){musicOwner=owner.id;musicNative('status');updateMusicUI();}
  const win=document.getElementById(owner.id),stage=win?.querySelector('[data-music-stage]');
  const modal=!$('#launcher').hidden||!$('#context-menu').hidden||$('#input-dialog').open;
  const r=stage?.getBoundingClientRect();
  const visible=musicStatus.phase!=='error'&&!!r&&activeId===owner.id&&!owner.min&&owner.space===state.space&&!modal&&document.body.dataset.appPaused!=='true'&&!document.hidden&&r.width>=1&&r.height>=1;
  const data=visible?{visible:true,x:r.x,y:r.y,w:r.width,h:r.height,viewport:innerWidth}:{visible:false};
  const key=JSON.stringify(data);if(key!==musicLastBounds){musicLastBounds=key;musicNative('bounds',data);}
}
function scheduleMusicBounds(){if(!musicBoundsFrame)musicBoundsFrame=requestAnimationFrame(syncMusicBounds);}
function musicUpdate(status){
  const owner=state.windows.find(w=>w.app==='music');
  if(!owner||!status||typeof status!=='object'||(status.windowId&&status.windowId!==owner.id))return;
  const clear=status.hasMedia===false||status.loaded===false||['loading','error'].includes(status.phase);
  const next=clear?{...musicEmptyStatus(musicStatus.shield),blocked:musicStatus.blocked}: {...musicStatus};
  for(const key of ['loaded','shield','paused','hasMedia','ad','held','live','canNext','canPrevious','canSeek'])if(typeof status[key]==='boolean')next[key]=status[key];
  for(const key of ['time','duration','blocked'])if(Number.isFinite(status[key])&&status[key]>=0)next[key]=Math.min(status[key],31536000);
  for(const key of ['title','url','error','notice','mediaError'])if(typeof status[key]==='string')next[key]=status[key].slice(0,key==='url'?4096:1000);
  if(['idle','loading','ready','error'].includes(status.phase))next.phase=status.phase;
  else if(status.loaded===true)next.phase='ready';
  musicStatus=next;updateMusicUI();scheduleMusicBounds();
}
window.ReverseMusic={
  update:musicUpdate,
  rendered(){updateMusicUI();scheduleMusicBounds();},
  close(id){
    musicNative('close',{windowId:id});
    if(musicOwner===id||!musicOwner){musicOwner=null;musicLastBounds='';musicStatus=musicEmptyStatus(musicStatus.shield);}
  }
};
document.addEventListener('pointerdown',e=>{if(e.target.matches('[data-music-seek]'))e.target.dataset.scrubbing='true';});
document.addEventListener('input',e=>{
  if(e.target.matches('[data-music-seek]'))e.target.dataset.scrubbing='true';
  if(e.target.matches('[data-music-search] input')){state.music.lastInput=e.target.value.slice(0,2048);queueSave();}
});
document.addEventListener('change',e=>{
  if(!e.target.matches('[data-music-seek]'))return;
  e.target.dataset.scrubbing='false';if(!e.target.disabled)musicNative('seek',{time:Number(e.target.value)});
});
for(const type of ['pointercancel','focusout'])document.addEventListener(type,e=>{
  if(e.target.matches('[data-music-seek]')){e.target.dataset.scrubbing='false';updateMusicUI();}
});
document.addEventListener('submit',e=>{
  if(!e.target.matches('[data-music-search]'))return;e.preventDefault();
  const input=e.target.elements.query.value.trim();if(!input)return;
  state.music.lastInput=input;const w=getWindow(e.target.closest('.window')?.dataset.id);
  if(w.musicTab==='favorites'){w.musicTab='player';renderWindowContent(w);}
  musicNative('open',{input});queueSave();scheduleMusicBounds();
});
document.addEventListener('click',e=>{
  const button=e.target.closest('[data-music-action],[data-music-tab],[data-music-favorite],[data-music-remove]');if(!button)return;
  const w=getWindow(button.closest('.window')?.dataset.id);if(!w||w.app!=='music')return;
  if(button.dataset.musicTab){w.musicTab=button.dataset.musicTab;renderWindowContent(w);updateMusicUI();queueSave();scheduleMusicBounds();return;}
  if(button.hasAttribute('data-music-favorite')){
    const item=state.music.favorites[Number(button.dataset.musicFavorite)];if(!item)return;
    w.musicTab='player';renderWindowContent(w);musicNative('open',{input:item.url});scheduleMusicBounds();return;
  }
  if(button.hasAttribute('data-music-remove')){state.music.favorites.splice(Number(button.dataset.musicRemove),1);renderWindowContent(w);queueSave();return;}
  const action=button.dataset.musicAction;
  if(action==='home')musicNative('open');
  else if(action==='shield'){const enabled=!musicStatus.shield;if(musicNative('shield',{enabled})){musicStatus.shield=enabled;updateMusicUI();}}
  else if(action==='favorite'){
    const url=musicSavedURL(musicStatus.url);if(!url)return;
    if(state.music.favorites.some(item=>item.url===url)){toast('Ya está en favoritos.');return;}
    if(state.music.favorites.length>=100){toast('Puedes guardar hasta 100 favoritos.','help');return;}
    state.music.favorites.push({url,title:String(musicStatus.title||'YouTube').slice(0,240)});queueSave();
    $('[data-music-count]',document.getElementById(w.id)).textContent=state.music.favorites.length;toast('Favorito guardado.');
  }else musicNative(action);
});
window.addEventListener('DOMContentLoaded',()=>{
  const observer=new MutationObserver(scheduleMusicBounds);
  observer.observe(document.body,{subtree:true,childList:true,attributes:true,attributeFilter:['style','class','hidden','open','data-app-paused']});
  new ResizeObserver(scheduleMusicBounds).observe(document.getElementById('desktop'));
  document.addEventListener('visibilitychange',scheduleMusicBounds);
  window.addEventListener('resize',scheduleMusicBounds);
  window.addEventListener('pagehide',()=>musicNative('close'));
  scheduleMusicBounds();
});
