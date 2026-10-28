'use strict';
// Presentation/navigation only. All programs keep using the native bridge.
const shellCompact=()=>window.matchMedia('(max-width:760px)').matches;
const shellName=app=>({programs:'Programas',files:'Archivos',bbyq:'BBY Q',xi:'XI',control:'Sistema'}[app]||APPS[app]?.name||'Programa');
function shellCoreCard(){
  const cap=window.REVERSE_CAPABILITIES,core=androidSnapshot?.core;
  const ready=!!core;
  return '<button class="core-overview" data-open="control" data-shell-system="true"><div class="core-overview-top"><span class="core-wordmark">ETHER</span><span class="connection-state '+(ready?'is-connected':'')+'"><i></i>'+(ready?'Núcleo local':nativeAvailable?'Conectando':'Perfil del motor')+'</span></div><div class="core-capacity"><strong>'+(cap?Number(cap.max_active_qubits).toLocaleString('es'):'—')+'</strong><span>qubits<small>límite del núcleo</small></span>'+icon('arrow-right')+'</div><div class="core-live"><span>'+(ready?Number(core.active_qubits).toLocaleString('es')+' activos':'XI / Ether')+'</span><span>'+(ready?core.components+' componentes':'H · CX · T · T†')+'</span><span>RVPC2</span></div></button>';
}
function shellHome(){
  const date=new Intl.DateTimeFormat('es',{weekday:'long',day:'numeric',month:'long'}).format(new Date());
  const names=[['programs','desktop','Programas','Tus ejecutables'],['files','files','Archivos','Documentos y proyectos'],['bbyq','bby','BBY Q','Conversación · W4u'],['xi','terminal','XI','Código y operadores']];
  const recent=state.windows.slice().sort((a,b)=>b.z-a.z).slice(0,3);
  $('#shell-home').innerHTML='<div class="home-heading"><div><span class="home-date">'+esc(date)+'</span><h1>Principal</h1></div><button class="icon-button" data-open="control" aria-label="Abrir Sistema">'+icon('settings')+'</button></div>'+shellCoreCard()+'<div class="home-section-heading"><h2>Herramientas</h2><span>EN ESTE DISPOSITIVO</span></div><div class="home-apps">'+names.map(([app,ico,label,detail])=>'<button class="home-app" data-open="'+app+'"><span class="home-app-icon">'+icon(ico)+'</span><span><strong>'+label+'</strong><small>'+detail+'</small></span>'+icon('chevron')+'</button>').join('')+'</div><div class="home-section-heading"><h2>Sesión</h2><button class="text-button" data-shell-action="recent">'+(state.windows.length?'Ver abiertas':'Sin ventanas')+'</button></div><div class="home-recents">'+(recent.length?recent.map(w=>'<button class="home-recent" data-shell-focus="'+w.id+'">'+icon(APPS[w.app].icon)+'<span>'+esc(windowTitle(w))+'</span><small>'+(w.min?'En segundo plano':'Abierta')+'</small>'+icon('arrow-right')+'</button>').join(''):'<div class="session-empty"><span class="session-line"></span><p>Elige una herramienta para empezar.</p></div>')+'</div><div class="home-footnote"><span class="core-wordmark">REVERSE</span><span>LOCAL · XI / ETHER</span></div>';
}
function shellNavigation(){
  const current=getWindow(activeId),app=current&&!current.min?taskApp(current):'';
  $('#mobile-navigation').innerHTML=[['home','home','Inicio'],['programs','desktop','Programas'],['bbyq','bby','BBY Q'],['recent','grid','Abiertas']].map(([key,ico,label])=>'<button '+(['home','recent'].includes(key)?'data-shell-action="'+key+'"':'data-open="'+key+'"')+' class="'+((key==='home'&&!app||key===app)?'selected':'')+'" aria-label="'+label+'"'+((key==='home'&&!app||key===app)?' aria-current="page"':'')+'>'+icon(ico)+'<span>'+label+'</span></button>').join('');
  document.body.dataset.shellSurface=app?'app':'home';
  $('#shell-home').setAttribute('aria-hidden',String(shellCompact()&&!!app));
}
function shellRefresh(){if(!$('#shell-home'))return;shellHome();shellNavigation();}
function shellShowHome(){
  for(const w of state.windows.filter(w=>w.space===state.space)){w.min=true;geometry(w,$('#'+w.id));}
  activeId=null;$$('.window').forEach(el=>el.classList.remove('focused'));hideLauncher();$('#recent-panel').hidden=true;renderDock();shellRefresh();queueSave();
}
function shellRecents(){
  const panel=$('#recent-panel'),windows=state.windows.slice().sort((a,b)=>b.z-a.z);
  panel.innerHTML='<div class="recent-heading"><h2>Abiertas</h2><button class="icon-button" data-shell-action="close-recents" aria-label="Cerrar aplicaciones abiertas">'+icon('close')+'</button></div><div class="recent-list">'+(windows.length?windows.map(w=>'<div class="recent-app"><button data-shell-focus="'+w.id+'"><span class="recent-app-icon">'+icon(APPS[w.app].icon)+'</span><strong>'+esc(windowTitle(w))+'</strong><small>'+(w.space?'Enfoque':'Principal')+' · '+(w.min?'En segundo plano':'Abierta')+'</small></button><button class="icon-button" data-shell-close="'+w.id+'" aria-label="Cerrar '+esc(windowTitle(w))+'">'+icon('close')+'</button></div>').join(''):'<p class="muted">No hay aplicaciones abiertas.</p>')+'</div>';
  panel.hidden=false;hideLauncher();
}
window.ReverseShell={refresh:shellRefresh,back(){
  if($('#input-dialog').open){$('#input-dialog').close();return true;}
  if(!$('#launcher').hidden){hideLauncher();return true;}
  if(!$('#recent-panel').hidden){$('#recent-panel').hidden=true;return true;}
  const w=getWindow(activeId);
  if(w&&!w.min){shellShowHome();return true;}return false;
}};
document.addEventListener('click',e=>{
  const b=e.target.closest('button');if(!b)return;
  if(b.dataset.shellAction==='home')shellShowHome();
  if(b.dataset.shellAction==='recent')shellRecents();
  if(b.dataset.shellAction==='close-recents')$('#recent-panel').hidden=true;
  if(b.dataset.shellFocus){const w=getWindow(b.dataset.shellFocus);if(w){if(w.space!==state.space)switchSpace(w.space);focusWindow(w.id);$('#recent-panel').hidden=true;shellRefresh();}}
  if(b.dataset.shellClose){const w=getWindow(b.dataset.shellClose);if(w)closeWindow(w);shellRecents();}
  if(b.dataset.open||b.dataset.programPath){$('#recent-panel').hidden=true;queueMicrotask(shellRefresh);}
  if(b.dataset.shellSystem){const w=getWindow(activeId);if(w?.app==='control'){w.tab='system';renderWindowContent(w);}}
});
window.addEventListener('resize',shellRefresh);
document.addEventListener('keydown',e=>{if(e.key==='Escape'&&!$('#recent-panel').hidden){$('#recent-panel').hidden=true;e.preventDefault();}});
const detailedSystemHTML=systemHTML;
systemHTML=function(){
  return '<div class="system-summary"><div class="system-intro"><span class="home-date">REVERSE '+UI_BUILD+'</span><h2>Núcleo y dispositivo</h2></div>'+shellCoreCard()+'<div class="system-operators"><div><strong>Operadores</strong><span>H · S · X · Y · Z · CX · CZ · T · T†</span></div><button class="text-button" data-shell-quantum="quantum">Abrir en XI '+icon('arrow-right')+'</button></div><div class="system-operators"><div><strong>Hamiltonianos</strong><span>Ising de dos qubits · evolución en pasos π/8</span></div><button class="text-button" data-shell-quantum="hamiltonian">Preparar '+icon('arrow-right')+'</button></div><p class="system-capacity-note">'+(window.REVERSE_CAPABILITIES?'Perfil del motor comprobado con 4.096 qubits independientes y puertas T. La capacidad de un circuito depende de su estructura y memoria.':'Leyendo el perfil del motor.')+'</p><details class="system-details"><summary>Detalles del dispositivo y del estado</summary>'+detailedSystemHTML()+'</details></div>';
};
document.addEventListener('click',e=>{const b=e.target.closest('[data-shell-quantum]');if(b){const w=createWindow('xi');if(w){w.xiTab=b.dataset.shellQuantum;renderWindowContent(w);shellRefresh();}}});
shellRefresh();
