'use strict';
// Qd / Cody is the coding laboratory inside REVERSE-PC. Intelligence, pattern
// storage and recall remain XI/Ether inside BBY Q's private RVPC2.
// This JavaScript is only the PC interface and typed host transport.
const QD_SKILLS=Object.freeze([
 {id:1,name:'Suma',verb:'sumar',operator:'add',description:'Construir un programa que sume dos cantidades.'},
 {id:2,name:'Resta',verb:'restar',operator:'sub',description:'Construir un programa que reste la segunda cantidad de la primera.'},
 {id:3,name:'Producto',verb:'multiplicar',operator:'mul',description:'Construir un programa que multiplique dos cantidades.'},
 {id:4,name:'Resto',verb:'calcular el resto',operator:'mod',description:'Construir un programa que calcule el resto de una división entera.'}
]);
const qdSessions=new Map();
function qdSkill(id){return QD_SKILLS.find(s=>s.id===Number(id))||QD_SKILLS[0];}
function qdExample(skill){return '#!reverse-pc-machine-v1\n# XI: reemplaza la operación y verifica las pruebas\nset r0 {{a}}\n'+skill.operator+' r0 {{b}}\nprint r0\nhalt\n';}
function qdDraft(w){w.qdDrafts ||= {};const key=String(qdSkill(w.qdSkill).id);if(typeof w.qdDrafts[key]!=='string')w.qdDrafts[key]=qdExample(qdSkill(key));return w.qdDrafts[key];}
function qdSession(w){
 let s=qdSessions.get(w.id);
 if(!s){s={busy:false,loading:false,loaded:false,learned:[false,false,false,false],approved:0,result:null,generated:null,error:''};qdSessions.set(w.id,s);}
 if(nativeAvailable&&!s.loaded&&!s.loading&&!s.error)queueMicrotask(()=>qdLoad(w));
 return s;
}
function qdRender(w){if(getWindow(w.id))renderWindowContent(w);}
async function qdLoad(w){
 const s=qdSessions.get(w.id);if(!s||s.loading||s.busy||s.loaded||!nativeAvailable)return;
 s.loading=true;s.error='';
 try{const status=await nativeRequest('qd',JSON.stringify({action:'status'}));if(!getWindow(w.id))return;
  s.learned=Array.isArray(status.learned)?status.learned.map(Boolean).slice(0,4):[false,false,false,false];
  s.approved=Number(status.approved_lessons)||0;s.loaded=true;
 }catch(e){s.error='No fue posible leer la memoria de Qd: '+e.message;}
 finally{s.loading=false;qdRender(w);}
}
function qdBadge(s,kind){return '<span class="qd-state '+kind+'">'+esc(s)+'</span>';}
function qdReport(s){
 if(!s.result)return '<div class="qd-empty"><span class="qd-empty-glyph">'+icon('terminal')+'</span><strong>Laboratorio preparado</strong><p>Prueba un programa para obtener resultados auténticos del ejecutor XI. Qd sólo conservará patrones que superen la evaluación.</p></div>';
 const {action,data}=s.result;
 if(action==='solve'){
  if(!data.learned)return '<div class="qd-empty"><strong>Patrón sin aprender</strong><p>Enseña primero un programa que supere todas las pruebas. No se ha generado código.</p></div>';
  return '<div class="qd-report-head">'+qdBadge(data.pass?'APROBADO':'FALLO',data.pass?'pass':'fail')+'<small>Qd recuperó un patrón de su memoria XI.</small></div>'+
   '<div class="qd-metric-row"><div><small>Resultado XI</small><strong>'+esc(data.actual)+'</strong></div><div><small>Esperado</small><strong>'+esc(data.expected)+'</strong></div></div>'+
   '<p class="qd-report-caption">Programa generado y ejecutado desde una sesión aislada:</p><pre class="qd-generated">'+esc(data.program||'')+'</pre>';
 }
 const passed=Number(data.passed)||0,total=Number(data.total)||0,learned=data.learned===true;
 const header=action==='teach'?(learned?'Patrón conservado en BBY Q':'Enseñanza rechazada: corrige los errores'):'Pruebas de práctica';
 const rows=Array.isArray(data.cases)?data.cases:[];
 return '<div class="qd-report-head">'+qdBadge(passed+'/'+total+' pruebas',passed===total&&total>0?'pass':'fail')+'<span>'+esc(header)+'</span></div>'+
  '<div class="qd-case-table"><div class="qd-case-heading"><span>Entrada</span><span>Salida XI</span><span>Esperado</span><span>Estado</span></div>'+
  rows.map(x=>'<div class="qd-case"><span>'+esc(x.a)+' y '+esc(x.b)+(x.set==='evaluación'?'<small> · reservada</small>':'')+'</span><strong>'+esc(x.actual??'—')+'</strong><span>'+esc(x.expected)+'</span><span class="'+(x.pass?'qd-good':'qd-bad')+'">'+(x.pass?'Correcto':'Error')+'</span></div>'+
     (x.error?'<div class="qd-case-error">'+esc(x.error)+'</div>':'')).join('')+'</div>'+
  (action==='teach'?'<p class="qd-report-caption">'+(learned?'XI escribió la lección en el RVPC2 privado del mismo BBY Q.':'No se guardó ningún patrón: la evaluación falló.')+'</p>':'<p class="qd-report-caption">Esta ejecución no modifica la memoria de BBY Q ni el estado del escritorio.</p>');
}
function qdStudioHTML(w){
 w.qdSkill=qdSkill(w.qdSkill).id;
 if(!Number.isInteger(w.qdA)||w.qdA<0||w.qdA>99)w.qdA=27;
 if(!Number.isInteger(w.qdB)||w.qdB<1||w.qdB>99)w.qdB=8;
 const skill=qdSkill(w.qdSkill),draft=qdDraft(w),s=qdSession(w),disabled=s.busy?' disabled':'';
 const available=nativeAvailable?'<span class="qd-live"><i></i>XI / Ether local</span>':qdBadge('REQUIERE APK NATIVA','fail');
 const badges=QD_SKILLS.map(item=>'<button type="button" class="qd-skill '+(skill.id===item.id?'selected':'')+'" data-qd-skill="'+item.id+'" aria-current="'+(skill.id===item.id?'page':'false')+'"><span class="qd-skill-number">0'+item.id+'</span><span><strong>'+item.name+'</strong><small>'+((s.loaded&&s.learned[item.id-1])?'Aprendido':'Sin verificar')+'</small></span><span class="qd-skill-dot '+(s.loaded&&s.learned[item.id-1]?'learned':'')+'"></span></button>').join('');
 const disableNative=(!nativeAvailable||s.busy)?' disabled':'';
 return '<div class="qd-root">'+
  '<header class="qd-top"><div><span class="qd-overline">BBY Q / CODY</span><h2>Cody <span>· XI</span></h2><p>Módulo de BBY Q. Evalúa y conserva patrones XI verificados.</p></div><div class="qd-top-actions">'+available+'<button type="button" class="secondary-button" data-qd-action="refresh"'+disableNative+'>'+icon('restore')+' Estado</button></div></header>'+
  '<div class="qd-workspace"><aside class="qd-sidebar"><span class="qd-section-caption">CURRÍCULO / NIVEL 01</span>'+badges+
  '<div class="qd-memory"><span>Memoria compartida con BBY Q</span><strong>'+(s.loaded?s.learned.filter(Boolean).length+'/4':'—')+'</strong><small>patrones aprendidos · '+(s.loaded?s.approved:'—')+' enseñanzas verificadas</small></div></aside>'+
  '<section class="qd-editor"><div class="qd-panel-heading"><div><span class="qd-section-caption">EDITOR XI</span><strong>'+esc(skill.name)+'.xi</strong></div><span class="qd-file-ext">.xi</span></div>'+
  '<div class="qd-task"><strong>Objetivo</strong><p>'+esc(skill.description)+'</p><small>Los símbolos {{a}} y {{b}} son valores de entrada que Qd debe generalizar.</small></div>'+
  '<label class="qd-editor-label" for="qd-src-'+esc(w.id)+'">Código fuente</label>'+
  '<textarea class="qd-source" maxlength="192" data-qd-source id="qd-src-'+esc(w.id)+'" spellcheck="false" autocomplete="off" autocorrect="off" autocapitalize="off" aria-label="Código XI de Qd"'+disabled+'>'+esc(draft)+'</textarea>'+
  '<div class="qd-editor-foot"><span>XI Machine v1 · registros y aritmética · aislado</span><button class="secondary-button" data-qd-action="reset">Restablecer ejemplo</button></div>'+
  '<div class="qd-editor-actions"><button class="secondary-button" data-qd-action="evaluate"'+disableNative+'>Probar código</button><button class="primary-button" data-qd-action="teach"'+disableNative+'>Enseñar a Qd</button></div></section>'+
  '<aside class="qd-results"><div class="qd-panel-heading"><div><span class="qd-section-caption">EVIDENCIA</span><strong>Resultados reales</strong></div>'+(s.busy?qdBadge('EJECUTANDO','busy'):s.loading?qdBadge('LEYENDO','busy'):qdBadge('LOCAL','neutral'))+'</div>'+
  (s.error?'<div role="alert" class="qd-error">'+esc(s.error)+'</div>':'')+
  '<div class="qd-results-scroll">'+qdReport(s)+'</div>'+
  '<section class="qd-run"><strong>Qd aplica lo aprendido</strong><p>Introduce números distintos. Qd recupera su patrón aprendido y produce una variante ejecutable XI.</p><div class="qd-fields">'+
  '<label>Valor a<input data-qd-number="a" type="number" min="0" max="99" value="'+w.qdA+'"></label>'+
  '<label>Valor b<input data-qd-number="b" type="number" min="1" max="99" value="'+w.qdB+'"></label></div>'+
  '<div class="qd-run-actions"><button class="primary-button" data-qd-action="solve"'+disableNative+'>Qd resuelve</button><button class="secondary-button" data-qd-action="export"'+(s.generated&&!s.busy?'':' disabled')+'>Crear .RXE</button></div></section></aside></div>'+
  '<footer class="qd-footer"><span>BBY Q · memoria RVPC2 privada · ejecución aislada de ejemplos</span><span>Qd v0.1 / entrenamiento de patrones, no modelo general</span></footer></div>';
}
Object.assign(APP_DESCRIPTIONS,{qd:'Enseñar y evaluar programación XI en el mismo BBY Q.'});
async function qdAction(w,action){
 const s=qdSessions.get(w.id);if(!s||s.busy)return;
 if(action==='reset'){w.qdDrafts[String(w.qdSkill)]=qdExample(qdSkill(w.qdSkill));s.generated=null;s.result=null;s.error='';qdRender(w);queueSave();return;}
 if(action==='refresh'){s.loaded=false;s.result=null;s.error='';s.generated=null;qdLoad(w);qdRender(w);return;}
 if(!nativeAvailable){s.error='Instala y abre REVERSE-PC para usar el motor XI nativo.';qdRender(w);return;}
 if(action==='export'){
  if(!s.generated)return;
  s.busy=true;s.error='';qdRender(w);
  try{const name='Qd-Cody-'+qdSkill(w.qdSkill).name+'.rxe';
   const out=await nativeRequest('compileApp',JSON.stringify({source:s.generated,name}));
   toast('Qd creó un ejecutable .rxe verificado.');if(typeof refreshPrograms==='function')refreshPrograms();
   if(getWindow(w.id)&&typeof openProgram==='function')openProgram(out.path);
  }catch(e){s.error=e.message;}finally{s.busy=false;qdRender(w);}return;
 }
 const skill=qdSkill(w.qdSkill);
 const payload={action,skill:skill.id};
 if(action==='evaluate'||action==='teach')payload.source=qdDraft(w);
 if(action==='solve'){payload.a=w.qdA;payload.b=w.qdB;}
 s.busy=true;s.error='';s.result=null;s.generated=null;qdRender(w);
 try{const result=await nativeRequest('qd',JSON.stringify(payload));if(!getWindow(w.id))return;
  s.result={action,data:result};
  if(result.status){s.learned=result.status.learned;s.approved=result.status.approved_lessons;s.loaded=true;}
  if(action==='solve'&&result.learned&&result.pass)s.generated=result.program;
 }catch(e){s.error='El núcleo rechazó la operación: '+e.message;}
 finally{s.busy=false;qdRender(w);queueSave();}
}
document.addEventListener('input',event=>{
 const target=event.target,w=getWindow(target.closest('.window')?.dataset.id);
 if(!w||!(w.app==='qd'||(w.app==='rxe'&&w.rxePath==='Aplicaciones/BBY-Q.rxe'&&w.bbyqModule==='cody')))return;
 if(target.matches('[data-qd-source]')){
  w.qdDrafts ||= {};w.qdDrafts[String(w.qdSkill)]=target.value;const s=qdSessions.get(w.id);if(s)s.generated=null;queueSave();
 }
 if(target.matches('[data-qd-number]')){
  const value=Number(target.value);
  if(Number.isInteger(value)){if(target.dataset.qdNumber==='a')w.qdA=value;else w.qdB=value;const session=qdSessions.get(w.id);if(session)session.generated=null;const exportButton=$('[data-qd-action="export"]',$('#'+w.id));if(exportButton)exportButton.disabled=true;queueSave();}
 }
});
document.addEventListener('click',event=>{
 const btn=event.target.closest('button');if(!btn)return;
 const w=getWindow(btn.closest('.window')?.dataset.id);if(!w||!(w.app==='qd'||(w.app==='rxe'&&w.rxePath==='Aplicaciones/BBY-Q.rxe'&&w.bbyqModule==='cody')))return;
 if(btn.dataset.qdSkill){
  const selected=qdSkill(btn.dataset.qdSkill).id;
  if(selected!==w.qdSkill){w.qdSkill=selected;const s=qdSessions.get(w.id);if(s){s.result=null;s.generated=null;s.error='';}qdRender(w);queueSave();}
  return;
 }
 if(btn.dataset.qdAction)qdAction(w,btn.dataset.qdAction);
});
