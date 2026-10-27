'use strict';
// Windows stay in Workbench; code and mutable memory belong to the native runtime.
let programCatalog=null,programCatalogError='',programCatalogLoading=false;
const programSessions=new Map();
Object.assign(APP_DESCRIPTIONS,{programs:'Tus ejecutables .rxe en esta mesa.',bbyq:'Conversación y memoria privada de BBY Q.'});

function refreshProgramViews(){
  for(const w of state.windows)if(w.app==='programs')renderWindowContent(w);
  if(!$('#launcher').hidden)renderLauncher($('#global-search').value);
}
async function refreshPrograms(){
  if(!nativeAvailable||programCatalogLoading)return;
  programCatalogLoading=true;programCatalogError='';
  try{programCatalog=await nativeRequest('listApps');}
  catch(error){programCatalogError=error.message;}
  finally{programCatalogLoading=false;refreshProgramViews();}
}
function programCards(){
  if(programCatalogError)return '<p role="alert">'+esc(programCatalogError)+'</p>';
  if(!programCatalog)return '<p class="muted">'+(nativeAvailable?'Leyendo tus ejecutables…':'Abre la aplicación Android para ejecutar programas .rxe.')+'</p>';
  return programCatalog.apps.map(app=>'<article class="program-card"><div>'+icon(app.metadata.ui==='chat'?'help':'desktop')+'<span><strong>'+esc(app.metadata.title)+'</strong><small>'+esc(app.metadata.app_version||'RXE1')+' · '+Math.ceil(app.bytes/1024)+' KB · '+esc(app.path.split('/').pop())+'</small></span></div><div class="program-actions"><button class="primary-button" data-program-path="'+esc(app.path)+'">Abrir</button><button class="secondary-button" data-program-export="'+esc(app.path)+'" aria-label="Exportar '+esc(app.metadata.title)+'">'+icon('download')+'</button></div></article>').join('')+(programCatalog.apps.length?'':'<p>No hay ejecutables. Agrega un .rxe o créalo desde XI Studio.</p>')+(programCatalog.rejected?'<p role="status">Se omitieron '+programCatalog.rejected+' archivos que no son ejecutables válidos.</p>':'');
}
function programsHTML(){
  if(!programCatalog&&!programCatalogLoading&&!programCatalogError)queueMicrotask(refreshPrograms);
  return '<div class="programs-layout"><div class="programs-heading"><div><span class="eyebrow">REVERSE WORKBENCH '+esc(UI_BUILD)+'</span><h2>Aplicaciones .rxe</h2><p>Abre tus programas en esta mesa.</p></div><div class="program-actions"><button class="primary-button" data-program-action="import">'+icon('plus')+'Agregar .rxe</button><button class="secondary-button" data-open="xi">Crear .rxe</button><button class="secondary-button" data-program-action="refresh" aria-label="Actualizar aplicaciones">'+icon('restore')+'</button></div></div><div class="program-list">'+programCards()+'</div></div>';
}
function openProgram(path){return createWindow('rxe',{rxePath:path});}
function applyProgramSnapshot(w,result){
  const data=programSessions.get(w.id);if(!data)return;
  data.snapshot=result;data.busy=false;data.error='';data.uncertain=false;
  w.rxeTitle=result.metadata.title;w.rxeIdentity=result.identity;w.rxeVersion=result.metadata.app_version||'RXE1';
  if(result.language)data.language=result.language;
  const el=$('#'+w.id);if(el)renderWindowContent(w);queueSave();
}
async function loadProgram(w){
  let data=programSessions.get(w.id);if(data?.busy)return;
  if(!data){data={busy:false,language:1,snapshot:null,error:''};programSessions.set(w.id,data);}
  data.busy=true;data.error='';
  try{const result=await nativeRequest('openApp',JSON.stringify({path:w.rxePath}));if(getWindow(w.id))applyProgramSnapshot(w,result);}
  catch(error){data.busy=false;data.error=error.message;data.uncertain=true;if(getWindow(w.id))renderWindowContent(w);}
  finally{if(!getWindow(w.id))programSessions.delete(w.id);}
}
function programHTML(w){
  let data=programSessions.get(w.id);
  if(!data){data={busy:true,language:1,snapshot:null,error:''};programSessions.set(w.id,data);queueMicrotask(()=>{data.busy=false;loadProgram(w);});}
  const saved=data.snapshot;
  if(!saved)return '<div class="programs-layout"><p role="status">'+esc(data.error||'Abriendo el ejecutable y su memoria…')+'</p>'+(data.error?'<button class="secondary-button" data-program-action="reload">Volver a abrir</button>':'')+'</div>';
  const meta=saved.metadata,chat=meta.ui==='chat',disabled=data.busy?' disabled':'';
  const status=data.error|| (data.busy?'Procesando en el núcleo…':chat?'Memoria guardada · '+(data.language===1?'Español':'English'):'Ejecutar inicia el programa. Abrir la ventana conserva la última salida.');
  const heading='<div class="rxe-heading"><span>'+esc(meta.title)+' · '+esc(meta.app_version||'RXE1')+'</span><div class="program-actions"><button class="secondary-button" data-program-action="reload" aria-label="Actualizar memoria"'+disabled+'>'+icon('restore')+'</button><button class="secondary-button" data-program-action="export"'+disabled+'>Exportar .rxe</button>'+(chat?'<button class="secondary-button" data-program-action="memory"'+disabled+'>Memoria .rvp</button>':'')+'</div></div>';
  const message='<p class="rxe-status" role="status">'+esc(status)+'</p>';
  if(meta.ui==='breaker-v1')return '<div class="rxe-layout">'+heading+'<div class="breaker-card"><span class="eyebrow">EL PRIMER JUEGO DE REVERSE</span><h2>REVERSE<br>BREAKER</h2><p>Cinco sectores. Una barra. Rompe los bloques y conserva tu récord.</p><button class="primary-button" data-program-action="play-breaker">Jugar</button><small>Arrastra para mover · Pausa al salir · Lógica XI / Ether</small></div></div>';
  if(!chat)return '<div class="rxe-layout">'+heading+message+'<pre class="rxe-output" aria-label="Salida RXE">'+esc(saved.output||'Pulsa Ejecutar para iniciar.')+'</pre><button class="primary-button" data-program-action="run"'+(data.busy||data.uncertain?' disabled':'')+'>Ejecutar</button></div>';
  const history=saved.history.length?saved.history.map((item,i)=>'<div class="rxe-message '+(item.role==='user'?'from-user':'from-agent')+'"><small>'+esc(item.role==='user'?'TÚ':meta.title)+'</small><p'+(item.role==='assistant'&&i===saved.history.length-1?' aria-label="Respuesta BBY Q"':'')+'>'+esc(item.text)+'</p></div>').join(''):'<p class="muted">Memoria '+esc(meta.app_version)+' lista. Puedes empezar con «hola».</p>';
  queueMicrotask(()=>{const el=$('.rxe-history',$('#'+w.id));if(el)el.scrollTop=el.scrollHeight;});
  return '<div class="rxe-layout">'+heading+message+'<div class="rxe-history" aria-label="Conversación BBY Q">'+history+'</div><form class="rxe-composer" data-program-form><textarea aria-label="Mensaje para BBY Q" data-program-input maxlength="255" rows="2" placeholder="Escribe un mensaje…"'+disabled+'>'+esc(w.rxeDraft||'')+'</textarea><div class="program-actions"><button type="button" class="secondary-button '+(data.language===1?'selected':'')+'" data-program-language="1"'+disabled+'>Español</button><button type="button" class="secondary-button '+(data.language===2?'selected':'')+'" data-program-language="2"'+disabled+'>English</button><button type="submit" class="primary-button"'+(data.busy||data.uncertain?' disabled':'')+'>Enviar</button></div></form></div>';
}
async function transactProgram(w,operation){
  const data=programSessions.get(w.id);if(!data?.snapshot||data.busy||data.uncertain)return;
  const snapshot=data.snapshot,payload={path:w.rxePath,identity:snapshot.identity};
  if(operation==='askApp'){
    payload.text=(w.rxeDraft||'').trim();payload.language=data.language;
    if(!payload.text)return;
    if(new TextEncoder().encode(payload.text).length>255){toast('Escribe un mensaje de hasta 255 bytes.','help');return;}
  }
  data.busy=true;data.error='';renderWindowContent(w);
  try{
    const result=await nativeRequest(operation,JSON.stringify(payload));
    if(operation==='askApp'){
      w.rxeDraft='';
      // Duplicate executables use the same native memory; refresh every open view.
      for(const other of state.windows){const peer=programSessions.get(other.id);if(peer?.snapshot?.identity===result.identity){if(other.id===w.id)other.rxeDraft='';applyProgramSnapshot(other,result);}}
    }else{snapshot.output=result.output;data.busy=false;if(getWindow(w.id))renderWindowContent(w);refreshAndroid(true);}
  }catch(error){
    data.busy=false;data.uncertain=true;data.error='No se confirmó la operación. Actualiza la memoria antes de repetirla. '+error.message;
    if(getWindow(w.id))renderWindowContent(w);
  }finally{queueSave();if(!getWindow(w.id))programSessions.delete(w.id);}
}
window.ReversePrograms={imported(result){refreshPrograms();if(result.ok){toast('Ejecutable agregado.');openProgram(result.path);}}};
document.addEventListener('input',event=>{if(event.target.matches('[data-program-input]')){const w=getWindow(event.target.closest('.window')?.dataset.id);if(w){w.rxeDraft=event.target.value;queueSave();}}});
document.addEventListener('submit',event=>{if(event.target.matches('[data-program-form]')){event.preventDefault();const w=getWindow(event.target.closest('.window')?.dataset.id);if(w)transactProgram(w,'askApp');}});
document.addEventListener('click',async event=>{
  const button=event.target.closest('button');if(!button)return;
  if(button.dataset.programPath){hideLauncher();openProgram(button.dataset.programPath);return;}
  if(button.dataset.programExport){const app=programCatalog?.apps.find(app=>app.path===button.dataset.programExport);if(app)window.ReverseNative.exportRxe(app.path,app.identity,false);return;}
  const w=getWindow(button.closest('.window')?.dataset.id),data=w&&programSessions.get(w.id);
  if(button.dataset.programLanguage&&data&&!data.busy){data.language=Number(button.dataset.programLanguage);renderWindowContent(w);return;}
  const action=button.dataset.programAction;
  if(action==='refresh')refreshPrograms();
  if(action==='import'){if(nativeAvailable)window.ReverseNative.importRxe();else toast('Requiere la aplicación Android.','help');}
  if(action==='reload'&&w)loadProgram(w);
  if(action==='run'&&w)transactProgram(w,'runApp');
  if(action==='play-breaker'&&data?.snapshot)window.ReverseNative.openBreaker(w.rxePath,data.snapshot.identity);
  if((action==='export'||action==='memory')&&data?.snapshot)window.ReverseNative.exportRxe(w.rxePath,data.snapshot.identity,action==='memory');
  if(action==='compile'&&w){
    if(w.xiBusy||!nativeAvailable)return;
    const name=await ask({title:'Crear ejecutable .rxe',value:'Mi-programa.rxe',confirm:'Crear'});if(name===null)return;
    try{const result=await nativeRequest('compileApp',JSON.stringify({source:w.xiSource||XI_PROBE,name}));toast('Ejecutable creado.');refreshPrograms();openProgram(result.path);}
    catch(error){toast(error.message,'help');}
  }
});
window.addEventListener('DOMContentLoaded',refreshPrograms);
