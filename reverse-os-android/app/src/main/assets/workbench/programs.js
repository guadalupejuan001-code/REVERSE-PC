'use strict';
// Windows stay in Workbench; code and mutable memory belong to the native runtime.
let programCatalog=null,programCatalogError='',programCatalogLoading=false;
const programSessions=new Map();
Object.assign(APP_DESCRIPTIONS,{programs:'Tus programas del dispositivo.',bbyq:'Conversación y memoria privada de BBY Q.'});

function refreshProgramViews(){
  for(const w of state.windows)if(w.app==='programs')renderWindowContent(w);
  if(!$('#launcher').hidden)renderLauncher($('#global-search').value);
  renderShortcuts();
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
  return programCatalog.apps.map(app=>'<article class="program-card"><div>'+appIcon(programIconName(app))+'<span><strong>'+esc(app.metadata.title)+'</strong><small>'+esc(app.metadata.app_version||'RXE1')+(bbyqPrograms().find(p=>p.path===app.path)?' · Programa '+(bbyqPrograms().find(p=>p.path===app.path).target-15):'')+' · '+Math.ceil(app.bytes/1024)+' KB · '+esc(app.path.split('/').pop())+'</small></span></div><div class="program-actions"><button class="primary-button" data-program-path="'+esc(app.path)+'">Abrir</button><button class="secondary-button" data-program-export="'+esc(app.path)+'" aria-label="Exportar '+esc(app.metadata.title)+'">'+icon('download')+'</button></div></article>').join('')+(programCatalog.apps.length?'':'<p>No hay ejecutables. Agrega un .rxe o créalo desde XI Studio.</p>')+(programCatalog.rejected?'<p role="status">Se omitieron '+programCatalog.rejected+' archivos que no son ejecutables válidos.</p>':'');
}
function programsHTML(){
  if(!programCatalog&&!programCatalogLoading&&!programCatalogError)queueMicrotask(refreshPrograms);
  return '<div class="programs-layout"><div class="programs-heading"><div><span class="eyebrow">REVERSE WORKBENCH '+esc(UI_BUILD)+'</span><h2>Programas</h2><p>Abre tus programas en esta mesa.</p></div><div class="program-actions"><button class="primary-button" data-program-action="import">'+icon('plus')+'Agregar .rxe</button><button class="secondary-button" data-open="xi">Crear .rxe</button><button class="secondary-button" data-program-action="refresh" aria-label="Actualizar aplicaciones">'+icon('restore')+'</button></div></div><div class="program-list">'+programCards()+'</div></div>';
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
  const status=data.error|| (data.busy?'Procesando en el núcleo…':chat?'Memoria guardada · '+(data.language===1?'Español':'English')+(saved.desktop_control?' · W4u conectado':''):'Ejecutar inicia el programa. Abrir la ventana conserva la última salida.');
  const heading='<div class="rxe-heading"><span>'+(chat?'BBY Q · XI/Ether':esc(meta.title)+' · '+esc(meta.app_version||'RXE1'))+'</span><div class="program-actions"><button class="secondary-button" data-program-action="reload" aria-label="Actualizar memoria"'+disabled+'>'+icon('restore')+'</button><button class="secondary-button" data-program-action="export"'+disabled+'>Exportar .rxe</button>'+(chat?'<button class="secondary-button" data-program-action="memory"'+disabled+'>Memoria</button>':'')+'</div></div>';
  const plan=saved.agents;
  const progress=plan&&plan.steps?'<p class="rxe-status">W4u · Plan: '+plan.steps+' paso'+(plan.steps===1?'':'s')+' · '+(plan.status===3?'Comprobado':plan.status===4?'Detenido':plan.completed+'/'+plan.steps+' completados')+'</p>':'';
  const message='<p class="rxe-status" role="status">'+esc(status)+'</p>'+progress;
  if(meta.ui==='graphics')return '<div class="rxe-layout">'+heading+'<p class="rxe-status" role="status">'+esc(data.error||'Juego · Pantalla completa · Música propia')+'</p><h2>'+esc(meta.title)+'</h2><p>Una experiencia horizontal a pantalla completa. Carga tu música y desliza sobre los cubos.</p><button class="primary-button" data-program-action="graphics"'+disabled+'>Jugar a pantalla completa</button></div>';
  if(!chat)return '<div class="rxe-layout">'+heading+message+'<pre class="rxe-output" aria-label="Salida RXE">'+esc(saved.output||'Pulsa Ejecutar para iniciar.')+'</pre><button class="primary-button" data-program-action="run"'+(data.busy||data.uncertain?' disabled':'')+'>Ejecutar</button></div>';
  const module=['chat','work','cody'].includes(w.bbyqModule)?w.bbyqModule:'chat';
  const moduleTabs='<nav class="bbyq-modules" aria-label="Módulos de BBY Q">'+[['chat','Chat'],['work','Work · W4u'],['cody','Cody · XI']].map(([id,label])=>'<button type="button" data-bbyq-module="'+id+'" aria-current="'+(module===id?'page':'false')+'" class="'+(module===id?'selected':'')+'">'+label+'</button>').join('')+'</nav>';
  if(module==='cody')return '<div class="rxe-layout bbyq-shell">'+heading+moduleTabs+'<section class="bbyq-module-content" aria-label="Cody, programación de BBY Q">'+qdStudioHTML(w)+'</section></div>';
  if(module==='work'){
    const details=plan&&Number.isInteger(plan.steps)&&plan.steps>0?'Último plan: '+(plan.completed||0)+' de '+plan.steps+' pasos. '+(plan.status===3?'Comprobado':plan.status===4?'Detenido':'Pendiente de confirmación')+'.':'Sin plan verificado en la sesión.';
    return '<div class="rxe-layout bbyq-shell">'+heading+moduleTabs+'<section class="bbyq-work"><h2>Work · W4u</h2><p>Capacidad de coordinación del mismo BBY Q. Las órdenes se escriben en Chat; no se ejecuta trabajo oculto.</p><div class="bbyq-work-status"><strong>Control del escritorio</strong><span>'+(saved.desktop_control?'Acciones admitidas y verificadas por REVERSE':'No disponible para este ejecutable')+'</span></div><div class="bbyq-work-status"><strong>Plan</strong><span>'+esc(details)+'</span></div><p>La memoria solo se confirma tras observar el resultado. No hay tareas externas ni acceso irrestricto al teléfono.</p><button class="primary-button" data-bbyq-module="chat">Dar instrucción en Chat</button></section></div>';
  }
  const history=saved.history.length?saved.history.map((item,i)=>'<div class="rxe-message '+(item.role==='user'?'from-user':'from-agent')+'"><small>'+esc(item.role==='user'?'TÚ':meta.title)+'</small><p'+(item.role==='assistant'&&i===saved.history.length-1?' aria-label="Respuesta BBY Q"':'')+'>'+esc(item.text)+'</p></div>').join(''):'<p class="muted">Memoria '+esc(meta.app_version)+' lista. Lista para conversar. W4u solo dispone de las acciones autorizadas y verificables de este escritorio.</p>';
  queueMicrotask(()=>{const el=$('.rxe-history',$('#'+w.id));if(el)el.scrollTop=el.scrollHeight;});
  return '<div class="rxe-layout bbyq-shell">'+heading+moduleTabs+message+'<div class="rxe-history" aria-label="Conversación BBY Q">'+history+'</div><form class="rxe-composer" data-program-form><textarea aria-label="Mensaje para BBY Q" data-program-input maxlength="255" rows="2" placeholder="Escribe un mensaje…">'+esc(w.rxeDraft||'')+'</textarea><div class="program-actions"><button type="button" class="secondary-button '+(data.language===1?'selected':'')+'" data-program-language="1"'+disabled+'>Español</button><button type="button" class="secondary-button '+(data.language===2?'selected':'')+'" data-program-language="2"'+disabled+'>English</button><button type="submit" class="primary-button"'+(data.busy||data.uncertain?' disabled':'')+'>Enviar</button></div></form></div>';
}
function renderProgramContent(w,body){
  const next=document.createElement('div');next.innerHTML=programHTML(w);
  const previous=body.querySelector('.rxe-layout'),layout=next.firstElementChild;
  const composer=previous?.querySelector('[data-program-form]'),replacement=layout?.querySelector('[data-program-form]');
  if(!composer||!replacement){body.replaceChildren(...next.childNodes);return;}
  // Leave the live textarea connected: replacing it would reset Android's
  // input connection, composing text and selection on every native reply.
  for(const child of [...previous.children])if(child!==composer)child.remove();
  for(const child of [...layout.children])if(child!==replacement)previous.insertBefore(child,composer);
  const field=composer.querySelector('[data-program-input]'),nextField=replacement.querySelector('[data-program-input]');
  if(field.value!==nextField.value)field.value=nextField.value;
  composer.setAttribute('aria-busy',String(!!programSessions.get(w.id)?.busy));
  for(const button of composer.querySelectorAll('button')){
    const selector=button.dataset.programLanguage?'[data-program-language="'+button.dataset.programLanguage+'"]':'[type="submit"]';
    const updated=replacement.querySelector(selector);button.disabled=updated.disabled;button.className=updated.className;
  }
}
async function transactProgram(w,operation){
  const data=programSessions.get(w.id);if(!data?.snapshot||data.busy||data.uncertain)return;
  const snapshot=data.snapshot,payload={path:w.rxePath,identity:snapshot.identity},submittedDraft=w.rxeDraft||'';
  if(operation==='askApp'){
    payload.text=(w.rxeDraft||'').trim();payload.language=data.language;
    if(!payload.text)return;
    if(new TextEncoder().encode(payload.text).length>255){toast('Escribe un mensaje de hasta 255 bytes.','help');return;}
    w.rxeDraft='';
  }
  data.busy=true;data.error='';renderWindowContent(w);
  try{
    if(operation==='askApp'&&snapshot.desktop_control){await refreshPrograms();payload.desktop=captureBbyqDesktop(snapshot.identity);}
    let result=await nativeRequest(operation,JSON.stringify(payload));
    if(operation==='launchGraphics'){data.busy=false;if(getWindow(w.id))renderWindowContent(w);return;}
    if(operation==='askApp'){
      let observation=payload.desktop,steps=0;
      while(result.control){
        if(!snapshot.desktop_control||!observation)throw Error('La aplicación no tiene un escritorio asociado.');
        if(++steps>2)throw Error('El plan supera el límite de pasos.');
        const outcome=await executeBbyqControl(result.control,observation,snapshot.identity);
        const nextObservation=captureBbyqDesktop(snapshot.identity);
        result=await nativeRequest('ackControl',JSON.stringify({path:w.rxePath,identity:snapshot.identity,ticket:result.control.ticket,success:outcome.success,desktop:nextObservation}));
        observation=nextObservation;
        if(!outcome.success)toast(outcome.reason,'help');
        if(!result.control&&(!getWindow(w.id)||w.min||w.space!==state.space))toast('BBY Q · '+result.history.at(-1).text);
      }
      // Duplicate executables use the same native memory; refresh every open view.
      for(const other of state.windows){const peer=programSessions.get(other.id);if(peer?.snapshot?.identity===result.identity)applyProgramSnapshot(other,result);}
    }else{snapshot.output=result.output;data.busy=false;if(getWindow(w.id))renderWindowContent(w);refreshAndroid(true);}
  }catch(error){
    if(operation==='askApp'&&!w.rxeDraft)w.rxeDraft=submittedDraft;
    data.busy=false;data.uncertain=true;data.error='No se confirmó la operación. Actualiza la memoria antes de repetirla. '+error.message;
    if(getWindow(w.id))renderWindowContent(w);
  }finally{queueSave();if(!getWindow(w.id))programSessions.delete(w.id);}
}
window.ReversePrograms={imported(result){refreshPrograms();if(result.ok){toast('Ejecutable agregado.');openProgram(result.path);}}};
document.addEventListener('input',event=>{if(event.target.matches('[data-program-input]')){const w=getWindow(event.target.closest('.window')?.dataset.id);if(w){w.rxeDraft=event.target.value;queueSave();}}});
document.addEventListener('submit',event=>{
  if(!event.target.matches('[data-program-form]'))return;
  event.preventDefault();const w=getWindow(event.target.closest('.window')?.dataset.id);if(!w)return;
  const command=(w.rxeDraft||'').trim().toLowerCase();
  if(['/cody','/work','/chat'].includes(command)){w.rxeDraft='';w.bbyqModule=command.slice(1);renderWindowContent(w);queueSave();return;}
  transactProgram(w,'askApp');
});
document.addEventListener('click',event=>{
  const button=event.target.closest('[data-bbyq-module]');if(!button)return;
  const w=getWindow(button.closest('.window')?.dataset.id);
  if(!w||w.rxePath!=='Aplicaciones/BBY-Q.rxe')return;
  const module=button.dataset.bbyqModule;if(!['chat','work','cody'].includes(module))return;
  w.bbyqModule=module;renderWindowContent(w);queueSave();
});
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
  if(action==='graphics'&&w)transactProgram(w,'launchGraphics');
  if(action==='run'&&w)transactProgram(w,'runApp');
  if((action==='export'||action==='memory')&&data?.snapshot)window.ReverseNative.exportRxe(w.rxePath,data.snapshot.identity,action==='memory');
  if(action==='compile'&&w){
    if(w.xiBusy||!nativeAvailable)return;
    const name=await ask({title:'Crear ejecutable .rxe',value:'Mi-programa.rxe',confirm:'Crear'});if(name===null)return;
    try{const result=await nativeRequest('compileApp',JSON.stringify({source:w.xiSource||XI_PROBE,name}));toast('Ejecutable creado.');refreshPrograms();openProgram(result.path);}
    catch(error){toast(error.message,'help');}
  }
});
window.addEventListener('DOMContentLoaded',refreshPrograms);
