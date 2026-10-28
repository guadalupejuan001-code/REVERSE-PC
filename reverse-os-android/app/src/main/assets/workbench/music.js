'use strict';

// Desktop UI owns the library. The native, bridge-free WebView owns YouTube.
function musicEmptyStatus(shield=true){return {loaded:false,phase:'idle',source:'youtube',localId:'',shield,blocked:0,paused:true,hasMedia:false,error:'',notice:'',title:'',url:'',time:0,duration:0,ad:false,held:false,live:false,canSeek:false,canNext:false,canPrevious:false,mediaError:''};}
let musicStatus=musicEmptyStatus();
let musicBoundsFrame=0,musicLastBounds='',musicOwner=null,musicLastRepeat=null;
let musicLibrary=[],musicDownloadDraft='';
let musicSearchEditing=false;
function musicDownloadRows(){
  return musicLibrary.map(item=>'<div class="music-download-row" data-music-row="'+item.id+'"><button data-music-local="'+item.id+'" '+(item.status!=='ready'?'disabled':'')+'>'+icon('music')+'<span><strong data-music-local-title>'+esc(item.title)+'</strong><small data-music-local-status></small></span>'+icon('play')+'</button><button class="icon-button" data-music-delete="'+item.id+'" aria-label="Eliminar '+esc(item.title)+'">'+icon('trash')+'</button><progress data-music-progress aria-label="Progreso de la descarga" hidden></progress></div>').join('');
}
function musicDownloadsHTML(){
  return '<section class="music-downloads"><div class="music-download-intro"><div><strong>Tu música, sin conexión</strong><p>Guarda un archivo de audio para escucharlo mientras juegas.</p></div><button class="secondary-button" data-music-action="import">'+icon('upload')+'Importar audio</button></div><form data-music-download class="music-download-form"><label for="music-download-url">Enlace directo al audio</label><div><input id="music-download-url" name="url" type="url" required maxlength="4096" placeholder="https://…/canción.mp3" value="'+esc(musicDownloadDraft)+'" autocomplete="off"><button class="primary-button" type="submit">'+icon('download')+'Descargar</button></div><small>MP3, M4A, OGG, WAV y otros formatos compatibles · hasta 200 MB. Los enlaces de YouTube se reproducen en línea.</small></form><div data-music-download-list>'+musicDownloadRows()+'</div><p class="music-download-empty" data-music-download-empty '+(musicLibrary.length?'hidden':'')+'>Todavía no hay archivos guardados. Descarga un audio o importa uno de tu teléfono.</p></section>';
}
function updateMusicLibraryUI(win){
  const list=$('[data-music-download-list]',win);if(!list)return;
  const structure=JSON.stringify(musicLibrary.map(i=>[i.id,i.title]));
  if(list.dataset.structure!==structure){list.innerHTML=musicDownloadRows();list.dataset.structure=structure;}
  for(const item of musicLibrary){
    const row=$('[data-music-row="'+item.id+'"]',list),button=$('[data-music-local]',row),progress=$('[data-music-progress]',row);
    button.disabled=item.status!=='ready';button.setAttribute('aria-pressed',String(musicStatus.source==='local'&&musicStatus.localId===item.id));
    $('[data-music-local-status]',row).textContent=item.status==='ready'?musicTime(item.duration)+' · '+(item.bytes/1048576).toFixed(1)+' MB · Sin conexión':item.status==='error'?item.error||'No se pudo guardar el audio.':item.total?'Guardando… '+Math.min(100,Math.floor(item.bytes/item.total*100))+' %':'Guardando… '+(item.bytes/1048576).toFixed(1)+' MB';
    progress.hidden=item.status!=='saving';progress.max=item.total||1;
    if(item.total)progress.value=Math.min(item.total,item.bytes);else progress.removeAttribute('value');
  }
  $('[data-music-download-empty]',win).hidden=musicLibrary.length>0;
}
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
  return {favorites,repeatOne:raw?.repeatOne===true,lastInput:typeof raw?.lastInput==='string'?raw.lastInput.slice(0,2048):''};
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
  const favorites=w.musicTab==='favorites',downloads=w.musicTab==='downloads';
  return '<div class="music-app"><div class="music-heading"><div class="music-brand">'+icon('music')+'<strong>REVERSE Music</strong><span data-music-source>YouTube</span></div><div class="music-heading-actions"><button class="secondary-button music-download-button" data-music-action="downloads" aria-label="Descargar música">'+icon('download')+'<span>Descargar música</span></button><button class="music-shield" data-music-action="shield" aria-pressed="'+musicStatus.shield+'" title="Activar o desactivar el bloqueador">'+icon('lock')+'<span data-music-shield>Bloqueador '+(musicStatus.shield?'activado':'desactivado')+'</span></button></div></div>'+
    '<form class="music-search" data-music-search><label>'+icon('search')+'<input name="query" aria-label="Buscar música o pegar enlace de YouTube" placeholder="Artista, canción o enlace de YouTube" maxlength="2048" autocomplete="off" value="'+esc(library.lastInput)+'"></label><button type="button" class="secondary-button music-paste" data-music-paste title="Pegar enlace desde el portapapeles">'+icon('copy')+'<span>Pegar</span></button><button class="primary-button" type="submit">Buscar</button></form>'+
    '<nav class="music-tabs" aria-label="Secciones de Music"><button data-music-tab="player" aria-selected="'+(!favorites&&!downloads)+'">Reproductor</button><button data-music-tab="favorites" aria-selected="'+favorites+'">Favoritos <span data-music-count>'+library.favorites.length+'</span></button><button data-music-tab="downloads" aria-selected="'+downloads+'">Descargas</button><span data-music-blocked>'+musicStatus.blocked+' solicitudes bloqueadas</span></nav>'+
    (downloads?musicDownloadsHTML():favorites?'<div class="music-library">'+(library.favorites.length?library.favorites.map((item,i)=>'<div class="music-favorite"><button data-music-favorite="'+i+'">'+icon('music')+'<span>'+esc(item.title)+'</span>'+icon('play')+'</button><button class="icon-button" data-music-remove="'+i+'" aria-label="Quitar '+esc(item.title)+' de favoritos">'+icon('close')+'</button></div>').join(''):'<div class="music-empty">'+icon('music')+'<strong>Tu música, a mano.</strong><p>Abre una canción o lista y pulsa Guardar favorito.</p></div>')+'</div>':
      '<div class="music-stage" data-music-stage><div class="music-empty">'+icon('music')+'<strong data-music-placeholder>Escucha desde tu escritorio.</strong><p data-music-hint>Busca una canción o abre YouTube para empezar.</p><button class="secondary-button" data-music-action="home">Abrir YouTube</button></div></div>')+
    '<div class="music-error" data-music-error role="status" hidden></div><input class="music-seek" data-music-seek type="range" min="0" max="0" step="1" value="0" aria-label="Posición de la canción" disabled><div class="music-controls"><div class="music-track"><strong data-music-title>Sin reproducción</strong><span data-music-time>0:00 / 0:00</span></div><div class="music-transport"><button class="icon-button" data-music-action="previous" aria-label="Canción anterior">'+icon('previous')+'</button><button class="icon-button music-play" data-music-action="toggle" aria-label="Reproducir o pausar">'+icon('play')+'</button><button class="icon-button" data-music-action="next" aria-label="Canción siguiente">'+icon('next')+'</button><button class="icon-button music-repeat" data-music-action="repeat" aria-label="Repetir canción" aria-pressed="'+library.repeatOne+'" title="Repetir la canción actual">'+icon('repeat')+'<span>1</span></button></div><button class="secondary-button music-save" data-music-action="favorite" title="Guardar canción o lista actual">'+icon('plus')+'<span>Guardar favorito</span></button></div>'+
    '<footer class="music-footer"><div><button data-music-action="back" title="Atrás">'+icon('arrow-left')+'</button><button data-music-action="reload" title="Recargar">'+icon('restore')+'</button><button type="button" data-music-copy title="Copiar enlace de la canción" aria-label="Copiar enlace">'+icon('copy')+'</button></div><span data-music-footer>Filtro experimental · reproducción en línea</span></footer></div>';
}
function musicTime(value){const s=Number.isFinite(Number(value))?Math.max(0,Math.floor(Number(value))):0;return Math.floor(s/60)+':'+String(s%60).padStart(2,'0');}
function updateMusicUI(){
  updateMusicControlPanels();
  for(const win of $$('.window[data-app="music"]')){
    const text=(selector,value)=>{const el=$(selector,win);if(el&&el.textContent!==value)el.textContent=value;};
    text('[data-music-title]',musicStatus.title||'Sin reproducción');
    text('[data-music-source]',musicStatus.source==='local'?'Sin conexión':'YouTube');
    text('[data-music-footer]',musicStatus.source==='local'?'Audio local · puedes abrir tu juego':'Filtro experimental · reproducción en línea');
    updateMusicLibraryUI(win);
    text('[data-music-time]',musicStatus.live?'En directo':musicTime(musicStatus.time)+' / '+musicTime(musicStatus.duration));
    const seek=$('[data-music-seek]',win);if(seek){seek.disabled=!musicStatus.hasMedia||!musicStatus.canSeek||!!musicStatus.ad||!(musicStatus.duration>0);seek.max=String(musicStatus.duration||0);if(seek.dataset.scrubbing!=='true')seek.value=String(musicStatus.time||0);}
    text('[data-music-shield]','Filtro '+(musicStatus.shield?'activo':'inactivo'));
    text('[data-music-blocked]',musicStatus.blocked+' solicitudes bloqueadas');
    const shield=$('[data-music-action="shield"]',win);shield?.setAttribute('aria-pressed',String(musicStatus.shield));
    const error=$('[data-music-error]',win);if(error){const message=musicStatus.error||musicStatus.mediaError||musicStatus.notice;error.hidden=!message;error.textContent=message||'';}
    const play=$('[data-music-action="toggle"]',win);if(play){const mode=musicStatus.paused?'play':'pause';if(play.dataset.mode!==mode){play.innerHTML=icon(mode);play.dataset.mode=mode;}play.setAttribute('aria-label',musicStatus.paused?'Reproducir':'Pausar');}
    $$('[data-music-action="toggle"],[data-music-action="previous"],[data-music-action="next"]',win).forEach(el=>el.disabled=!musicStatus.hasMedia||(el.dataset.musicAction==='next'&&!musicStatus.canNext)||(el.dataset.musicAction==='previous'&&!musicStatus.canPrevious));
    const repeat=$('[data-music-action="repeat"]',win);if(repeat){repeat.setAttribute('aria-pressed',String(state.music?.repeatOne===true));repeat.disabled=musicStatus.live;repeat.title=musicStatus.live?'La repetición no está disponible en un directo':'Repetir la canción actual';}
    const save=$('[data-music-action="favorite"]',win);if(save)save.disabled=!musicSavedURL(musicStatus.url);
    for(const action of ['back','reload']){const button=$('[data-music-action="'+action+'"]',win);if(button)button.disabled=musicStatus.source==='local';}
    text('[data-music-placeholder]',musicStatus.source==='local'?(musicStatus.title||'Tu biblioteca sin conexión'):musicStatus.phase==='error'?'No se pudo cargar YouTube':musicStatus.phase==='loading'?'Cargando YouTube…':'Escucha desde tu escritorio.');
    text('[data-music-hint]',musicStatus.source==='local'?'Tu audio guardado sigue disponible al abrir un juego. Puedes controlarlo desde la notificación de Android.':typeof window.ReverseNative?.music==='function'?'Busca una canción o abre YouTube para empezar.':'La reproducción está disponible en la APK de REVERSE Music.');
  }
}
function musicEnterEditMode(){
  musicSearchEditing=true;
  // Hide Android's separate WebView synchronously before editing a URL.
  musicNative('bounds',{visible:false,editing:true});
  musicLastBounds='';scheduleMusicBounds();
}
function syncMusicBounds(){
  musicBoundsFrame=0;
  const owner=state.windows.find(w=>w.app==='music');
  if(!owner){if(musicOwner){musicNative('close');musicStatus=musicEmptyStatus(musicStatus.shield);musicOwner=null;musicLastBounds='';musicLastRepeat=null;}musicSearchEditing=false;return;}
  if(musicOwner!==owner.id){musicOwner=owner.id;musicLastRepeat=null;musicNative('status');updateMusicUI();}
  const repeat=state.music?.repeatOne===true;if(musicLastRepeat!==repeat){if(musicNative('repeat',{enabled:repeat}))musicLastRepeat=repeat;}
  const win=document.getElementById(owner.id),stage=win?.querySelector('[data-music-stage]');
  const search=win?.querySelector('[data-music-search]'),tabs=win?.querySelector('.music-tabs');
  const seek=win?.querySelector('[data-music-seek]'),rect=stage?.getBoundingClientRect();
  const tabsRect=tabs?.getBoundingClientRect(),searchRect=search?.getBoundingClientRect(),seekRect=seek?.getBoundingClientRect(),windowRect=win?.getBoundingClientRect();
  const modal=!$('#launcher').hidden||!$('#context-menu').hidden||$('#input-dialog').open;
  const editing=musicSearchEditing||document.body.dataset.keyboard==='true'||
    !!(win?.contains(document.activeElement)&&document.activeElement?.matches('input:not([data-music-seek]),textarea,[contenteditable]'));
  // The native YouTube WebView may occupy ONLY the central music-stage region.
  // Its Android host validates these edges before displaying the native surface.
  const inside=!!(rect&&tabsRect&&searchRect&&seekRect&&windowRect&&
    Number.isFinite(rect.x+rect.y+rect.width+rect.height)&&rect.width>=1&&rect.height>=34&&
    rect.top>=Math.max(tabsRect.bottom,searchRect.bottom)-1&&rect.bottom<=seekRect.top+1&&
    rect.left>=windowRect.left-1&&rect.right<=windowRect.right+1&&
    rect.left>=0&&rect.top>=0&&rect.right<=innerWidth+1&&rect.bottom<=innerHeight+1);
  const visible=musicStatus.source!=='local'&&musicStatus.phase!=='error'&&inside&&
    activeId===owner.id&&!owner.min&&owner.space===state.space&&!modal&&!editing&&
    document.body.dataset.appPaused!=='true'&&!document.hidden;
  const data=visible?{visible:true,x:rect.x,y:rect.y,w:rect.width,h:rect.height,viewport:innerWidth,
    safeTop:Math.max(tabsRect.bottom,searchRect.bottom),safeBottom:seekRect.top,
    safeLeft:windowRect.left,safeRight:windowRect.right}:{visible:false,editing:!!editing};
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
  if(['youtube','local'].includes(status.source))next.source=status.source;
  if(typeof status.localId==='string'&&/^[a-f0-9-]{0,36}$/.test(status.localId))next.localId=status.localId;
  if(Array.isArray(status.library))musicLibrary=status.library.slice(0,100).flatMap(item=>{
    if(!item||typeof item.id!=='string'||!/^[a-f0-9-]{36}$/.test(item.id)||!['saving','ready','error'].includes(item.status))return [];
    const n=key=>Number.isFinite(item[key])?Math.max(0,Math.min(item[key],key==='duration'?31536000:209715200)):0;
    return [{id:item.id,title:typeof item.title==='string'?item.title.slice(0,240):'Audio guardado',status:item.status,error:typeof item.error==='string'?item.error.slice(0,1000):'',bytes:n('bytes'),total:n('total'),duration:n('duration')}];
  });
  if(['idle','loading','ready','error'].includes(status.phase))next.phase=status.phase;
  else if(status.loaded===true)next.phase='ready';
  musicStatus=next;updateMusicUI();scheduleMusicBounds();
}
window.ReverseMusic={
  update:musicUpdate,
  rendered(){updateMusicUI();scheduleMusicBounds();},
  close(id){
    musicNative('close',{windowId:id});
    if(musicOwner===id||!musicOwner){musicSearchEditing=false;musicOwner=null;musicLastBounds='';musicLastRepeat=null;musicStatus=musicEmptyStatus(musicStatus.shield);}
  }
};
document.addEventListener('focusin',e=>{
  if(e.target.matches('[data-music-search] input'))musicEnterEditMode();
});
document.addEventListener('click',async e=>{
  const button=e.target.closest('[data-music-paste],[data-music-copy]');if(!button)return;
  const w=getWindow(button.closest('.window')?.dataset.id);if(!w||w.app!=='music')return;
  e.preventDefault();
  if(button.hasAttribute('data-music-copy')){
    const link=musicSavedURL(musicStatus.url);
    if(!link){toast('Abre primero una canción o lista de YouTube.','help');return;}
    let ok=false;
    try{if(typeof window.ReverseNative?.musicCopyLink==='function')ok=window.ReverseNative.musicCopyLink(link)===true;
      else if(navigator.clipboard?.writeText){await navigator.clipboard.writeText(link);ok=true;}}
    catch{}
    toast(ok?'Enlace de música copiado.':'No se pudo copiar automáticamente.','help');return;
  }
  const field=button.closest('[data-music-search]')?.querySelector('input[name="query"]');
  if(!field)return;
  musicEnterEditMode();
  let content='';
  try{if(typeof window.ReverseNative?.musicClipboard==='function')content=String(window.ReverseNative.musicClipboard()||'');
    else if(navigator.clipboard?.readText)content=String(await navigator.clipboard.readText());}
  catch{}
  if(content.trim()){
    field.value=content.trim().slice(0,2048);field.dispatchEvent(new Event('input',{bubbles:true}));
  }else toast('Portapapeles vacío o no autorizado. Mantén pulsado el campo para pegar.','help');
  field.focus();field.setSelectionRange(field.value.length,field.value.length);
});
document.addEventListener('pointerdown',e=>{if(e.target.matches('[data-music-seek]'))e.target.dataset.scrubbing='true';});
document.addEventListener('input',e=>{
  if(e.target.matches('[data-music-seek]'))e.target.dataset.scrubbing='true';
  if(e.target.matches('[data-music-search] input')){state.music.lastInput=e.target.value.slice(0,2048);queueSave();}
  if(e.target.matches('[data-music-download] input'))musicDownloadDraft=e.target.value.slice(0,4096);
});
document.addEventListener('change',e=>{
  if(!e.target.matches('[data-music-seek]'))return;
  e.target.dataset.scrubbing='false';if(!e.target.disabled)musicNative('seek',{time:Number(e.target.value)});
});
for(const type of ['pointercancel','focusout'])document.addEventListener(type,e=>{
  if(e.target.matches('[data-music-seek]')){e.target.dataset.scrubbing='false';updateMusicUI();}
});
document.addEventListener('submit',e=>{
  if(e.target.matches('[data-music-download]')){
    e.preventDefault();const url=e.target.elements.url.value.trim();
    if(url)musicNative('download',{url});return;
  }
  if(!e.target.matches('[data-music-search]'))return;e.preventDefault();
  const input=e.target.elements.query.value.trim();if(!input)return;
  state.music.lastInput=input;musicSearchEditing=false;e.target.elements.query.blur();const w=getWindow(e.target.closest('.window')?.dataset.id);
  if(w.musicTab!=='player'){w.musicTab='player';renderWindowContent(w);}
  musicNative('open',{input});queueSave();scheduleMusicBounds();
});
document.addEventListener('click',e=>{
  const button=e.target.closest('[data-music-action],[data-music-tab],[data-music-favorite],[data-music-remove],[data-music-local],[data-music-delete]');if(!button)return;
  const w=getWindow(button.closest('.window')?.dataset.id);if(!w||w.app!=='music')return;
  if(button.dataset.musicTab){musicSearchEditing=false;w.musicTab=button.dataset.musicTab;renderWindowContent(w);updateMusicUI();queueSave();scheduleMusicBounds();return;}
  if(button.hasAttribute('data-music-local')){musicNative('local',{id:button.dataset.musicLocal});return;}
  if(button.hasAttribute('data-music-delete')){musicNative('removeLocal',{id:button.dataset.musicDelete});return;}
  if(button.hasAttribute('data-music-favorite')){
    const item=state.music.favorites[Number(button.dataset.musicFavorite)];if(!item)return;
    musicSearchEditing=false;w.musicTab='player';renderWindowContent(w);musicNative('open',{input:item.url});scheduleMusicBounds();return;
  }
  if(button.hasAttribute('data-music-remove')){state.music.favorites.splice(Number(button.dataset.musicRemove),1);renderWindowContent(w);queueSave();return;}
  const action=button.dataset.musicAction;
  if(action==='downloads'){musicSearchEditing=false;w.musicTab='downloads';renderWindowContent(w);updateMusicUI();scheduleMusicBounds();$('[data-music-download] input',document.getElementById(w.id))?.focus();queueSave();}
  else if(action==='repeat')toggleMusicRepeat();
  else if(action==='home'){musicSearchEditing=false;musicNative('open');}
  else if(action==='shield'){const enabled=!musicStatus.shield;if(musicNative('shield',{enabled})){musicStatus.shield=enabled;updateMusicUI();}}
  else if(action==='favorite'){
    const url=musicSavedURL(musicStatus.url);if(!url)return;
    if(state.music.favorites.some(item=>item.url===url)){toast('Ya está en favoritos.');return;}
    if(state.music.favorites.length>=100){toast('Puedes guardar hasta 100 favoritos.','help');return;}
    state.music.favorites.push({url,title:String(musicStatus.title||'YouTube').slice(0,240)});queueSave();
    $('[data-music-count]',document.getElementById(w.id)).textContent=state.music.favorites.length;toast('Favorito guardado.');
  }else musicNative(action);
});
function toggleMusicRepeat(){
  state.music||=cleanMusicState();state.music.repeatOne=!state.music.repeatOne;
  if(musicNative('repeat',{enabled:state.music.repeatOne}))musicLastRepeat=state.music.repeatOne;queueSave();updateMusicUI();
}
function musicPanelStatus(){return musicStatus.phase==='loading'?(musicStatus.source==='local'?'Abriendo audio…':'Cargando YouTube…'):musicStatus.phase==='error'?'Requiere atención':musicStatus.hasMedia?(musicStatus.paused?'En pausa':musicStatus.source==='local'?'Reproduciendo · Sin conexión':'Reproduciendo'):'Sin canción seleccionada';}
function musicControlHTML(){
  const repeat=state.music?.repeatOne===true;
  return '<section class="music-control-panel" aria-label="Control de música"><div class="music-panel-heading">'+icon('music')+'<div><strong>REVERSE Music</strong><small data-music-panel-status>'+esc(musicPanelStatus())+'</small></div><button class="secondary-button" data-music-panel-action="open">Abrir Music</button></div><p class="music-panel-title" data-music-panel-title>'+esc(musicStatus.title||'Elige tu música desde el reproductor.')+'</p><div class="music-panel-controls"><button class="secondary-button" data-music-panel-action="toggle" data-music-panel-play '+(!musicStatus.hasMedia?'disabled':'')+'>'+icon(musicStatus.paused?'play':'pause')+'<span>'+(musicStatus.paused?'Reproducir':'Pausar')+'</span></button><button class="secondary-button music-repeat" data-music-panel-action="repeat" aria-pressed="'+repeat+'">'+icon('repeat')+'Repetir una</button><span data-music-panel-repeat-state>'+(repeat?'Repetición activada':'Repetición desactivada')+'</span></div></section>';
}
function updateMusicControlPanels(){
  for(const panel of $$('.music-control-panel')){
    $('[data-music-panel-title]',panel).textContent=musicStatus.title||'Elige tu música desde el reproductor.';
    $('[data-music-panel-status]',panel).textContent=musicPanelStatus();
    const play=$('[data-music-panel-play]',panel);play.disabled=!musicStatus.hasMedia;
    const mode=musicStatus.paused?'play':'pause';if(play.dataset.mode!==mode){play.innerHTML=icon(mode)+'<span>'+(musicStatus.paused?'Reproducir':'Pausar')+'</span>';play.dataset.mode=mode;}
    const repeat=state.music?.repeatOne===true,button=$('[data-music-panel-action="repeat"]',panel);
    button.setAttribute('aria-pressed',String(repeat));button.disabled=musicStatus.live;
    $('[data-music-panel-repeat-state]',panel).textContent=repeat?'Repetición activada':'Repetición desactivada';
  }
}
document.addEventListener('click',e=>{
  const button=e.target.closest('[data-music-panel-action]');if(!button)return;
  const action=button.dataset.musicPanelAction;
  if(action==='open')createWindow('music');
  if(action==='toggle'&&musicStatus.hasMedia)musicNative('toggle');
  if(action==='repeat')toggleMusicRepeat();
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
