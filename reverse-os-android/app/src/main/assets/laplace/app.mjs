import {emitirPronosticos,verificarPronostico,validarVelas} from './modelo.mjs';
import {huellaContenido} from './integridad.mjs';
const UPSTREAM='06ebce4bddf25d615cefd85ed24081f37504a492';
const $=x=>document.getElementById(x),need=(c,m)=>{if(!c)throw Error(m)};
const money=(n,c='USD')=>Number.isFinite(n)?new Intl.NumberFormat('es-MX',{style:'currency',currency:c,maximumFractionDigits:2}).format(n):'Sin cálculo';
const date=t=>Number.isFinite(Date.parse(t))?new Intl.DateTimeFormat('es-MX',{dateStyle:'short',timeStyle:'medium'}).format(new Date(t)):'Sin fecha';
const labels={ticker:'Precio BTC',candles:'Velas',book:'Libro',trades:'Operaciones',eth:'ETH/USD',euro:'BTC/EUR',noaa:'NOAA'};
const names={espera:'Esperando',consultando:'Consultando',recibida:'Recibida',error:'Sin datos',omitida:'No seleccionada'};
let serial=0,busy=false,last=null,remote=null;
const pending=new Map(),statuses={};
window.LaplaceHost={complete(id,result){const p=pending.get(id);if(!p)return;pending.delete(id);clearTimeout(p.timer);result.ok?p.ok(result):p.fail(Error(result.error||'La consulta falló'));}};
function host(operation,payload={}){
 return new Promise((ok,fail)=>{
  if(!window.LaplaceNative?.request){fail(Error('Abre Laplace desde REVERSE; esta vista necesita el adaptador Android.'));return;}
  const id='l'+(++serial),timer=setTimeout(()=>{pending.delete(id);fail(Error('La consulta agotó su tiempo. La última lectura se conserva.'));},65000);
  pending.set(id,{ok,fail,timer});
  try{window.LaplaceNative.request(id,operation,typeof payload==='string'?payload:JSON.stringify(payload));}
  catch(e){clearTimeout(timer);pending.delete(id);fail(e);}
 });
}
function status(source,state,detail=''){
 statuses[source]={state,detail};const el=document.querySelector('[data-node="'+source+'"]');
 if(el){el.dataset.estado=state;el.querySelector('small').textContent=names[state]||state;}
 $('flujoEstado').textContent=busy?'Consulta en curso · '+Object.values(statuses).filter(x=>x.state==='recibida').length+' fuentes recibidas.':'Sin consultas activas. Los estados pertenecen a la última lectura.';
}
async function pub(source,params={}){
 status(source,'consultando');
 try{const r=await host('public',{source,params});const value=JSON.parse(r.text);status(source,'recibida');return {value,received_at:r.received_at};}
 catch(e){status(source,'error',e.message);throw e;}
}
function alert(text=''){ $('aviso').textContent=text;$('aviso').hidden=!text; }
const sleep=n=>new Promise(ok=>setTimeout(ok,n));
async function candles(){
 const end=Math.floor(Date.now()/300000)*300,start=end-14*86400,parts=[];let index=0;
 async function worker(){while(index<14){const day=index++,r=await pub('candles',{step:300,start:start+day*86400,end:start+(day+1)*86400});
  need(Array.isArray(r.value)&&r.value.length<=500,'Velas incompatibles');parts[day]=r.value.filter(x=>Array.isArray(x)&&x[0]>=start&&x[0]<end);await sleep(300);}}
 const results=await Promise.allSettled([worker(),worker()]);const failed=results.find(x=>x.status==='rejected');if(failed)throw failed.reason;return parts.flat();
}
function selected(){return [...document.querySelectorAll('[data-source]:checked')].map(x=>x.dataset.source);}
async function verifySnapshot(s){
 const {sha256,...body}=s??{};
 need(body.schema==='laplace-reverse-m001-v1'&&body.upstream===UPSTREAM,'Lectura local incompatible');
 need(sha256===await huellaContenido(body),'Lectura local alterada; se conserva sin utilizarla');
 need(Array.isArray(body.predictions)&&body.predictions.length===6&&new Set(body.predictions.map(p=>p.horizonte_minutos)).size===6,'Pronósticos incompletos');
 need(Array.isArray(body.bars)&&body.bars.length<=10000,'Historial fuera de presupuesto');
 need(Date.parse(body.at)>=Date.parse(body.quote.known_at),'Fecha de captura incoherente');
 for(const p of body.predictions){await verificarPronostico(p);need(p.precio_inicial===Number(body.quote.value)&&p.cotizacion_en===body.quote.observed_at,'Precio incoherente');}
 return s;
}
async function update(){
 if(busy)return;busy=true;$('actualizar').disabled=true;$('actualizar').textContent='Consultando…';alert();
 for(const key of Object.keys(labels))status(key,selected().includes(key)||['ticker','candles'].includes(key)?'espera':'omitida');
 let extrasTask=Promise.resolve([]);
 try{
  extrasTask=Promise.all(selected().map(async source=>{try{return {source,status:'observed',...(await pub(source))};}catch(e){return {source,status:'unavailable',error:'No se recibió una lectura válida'};}}));
  const raw=await candles(),response=await pub('ticker'),q=response.value;
  need(q&&Number.isFinite(Number(q.price))&&Number(q.price)>0,'La fuente no entregó un precio válido');
  const quote={asset:'BTC-USD',value:String(q.price),observed_at:new Date(Date.parse(q.time)).toISOString(),known_at:new Date(Date.parse(response.received_at)).toISOString()};
  const bars=validarVelas(raw,{corte:quote.observed_at});need(bars.length>=60,'Historial insuficiente');
  const predictions=await emitirPronosticos(bars,quote,{emitidoEn:new Date().toISOString(),horizontes:[15,30,60,240,1440,10080],revision:'REVERSE-Android-M001-'+UPSTREAM});
  const extras=await extrasTask,body={schema:'laplace-reverse-m001-v1',upstream:UPSTREAM,at:new Date().toISOString(),quote,bars,predictions,extras};
  const fresh={...body,sha256:await huellaContenido(body)};
  await verifySnapshot(fresh);await host('save',JSON.stringify(fresh));last=fresh;render();
  $('guardado').textContent='Última consulta guardada y sellada localmente. No modifica el diario remoto.';
 }catch(e){alert(e.message+' No se reemplaza la última lectura válida.');}
 finally{await extrasTask;busy=false;$('actualizar').disabled=false;$('actualizar').textContent='Calcular y consultar';for(const key in statuses)if(statuses[key].state==='consultando')status(key,'error');statusText();}
}
function prediction(){return last?.predictions.find(p=>p.horizonte_minutos===Number($('horizonte').value));}
function statusText(){
 if(!last){$('estado').textContent='Sin lectura';return;}
 const age=Date.now()-Date.parse(last.quote.observed_at);$('estado').textContent=age< -5000?'Revisar reloj':age>180000?'Captura histórica':'Lectura reciente';
 const p=prediction();if(p)$('objetivo').textContent='Objetivo: '+date(p.objetivo_en)+(Date.now()>=Date.parse(p.objetivo_en)?' · Vencido; consulta de nuevo.':'');
}
function render(){
 const p=prediction();$('duracion').textContent=$('horizonte').selectedOptions[0].textContent;
 if(!last||!p)return;
 $('precio').textContent=money(Number(last.quote.value));$('fecha').textContent='Observado: '+date(last.quote.observed_at);
 $('candidato').textContent=money(p.precio_predicho);
 const change=p.precio_predicho===null?null:p.precio_predicho-p.precio_inicial;
 $('cambio').textContent=change===null?'No hay antecedentes suficientes para calcular.':(change<0?'Bajada estimada: ':change>0?'Subida estimada: ':'Sin cambio estimado: ')+money(Math.abs(change))+' · '+(100*change/p.precio_inicial).toFixed(3)+' %';
 $('soporte').textContent=p.analogos+' antecedentes seleccionados · '+last.bars.length+' velas cerradas. '+(p.analogos<8?'Soporte escaso; especialmente incierto.':'Estimación experimental, no probabilidad de acierto.');
 $('exportar').disabled=false;statusText();chart();renderFactors();renderRemote();
}
const NS='http://www.w3.org/2000/svg';
function chart(){
 const p=prediction(),graph=$('grafico');graph.replaceChildren();if(!p)return;
 const width=Math.max(300,graph.getBoundingClientRect().width||800);
 const inst={observed_at:p.cotizacion_en,target_at:p.objetivo_en,observed_price_usd:p.precio_inicial,projected_price_usd:p.precio_predicho};
 const serie=last.bars.slice(-Number($('historia').value)).map(b=>({fecha:new Date((b[0]+300)*1000).toISOString(),precio:b[4]}));
 const g=window.LaplaceGrafica.calcular(serie,inst,{ancho:width});graph.setAttribute('viewBox','0 0 '+width+' 285');
 const draw=(tag,attrs,text)=>{const e=document.createElementNS(NS,tag);for(const [k,v] of Object.entries(attrs))e.setAttribute(k,v);if(text)e.textContent=text;graph.append(e);};
 if(!g){draw('text',{x:width/2,y:130,'text-anchor':'middle',fill:'#b2c5d3'},'Sin candidato para este horizonte');return;}
 for(const r of g.rejilla){draw('line',{x1:g.izquierda,x2:g.derecha,y1:r.y,y2:r.y,stroke:'#314153'});draw('text',{x:g.izquierda-8,y:r.y+4,'text-anchor':'end',fill:'#a3b3c0','font-size':'11'},Math.round(r.valor).toLocaleString('es-MX'));}
 draw('path',{d:g.puntos.map((v,i)=>(i?'L':'M')+v.x+' '+v.y).join(' '),fill:'none',stroke:'#dcecf3','stroke-width':2});
 draw('path',{d:'M '+g.ancla.x+' '+g.ancla.y+' L '+g.fin.x+' '+g.fin.y,fill:'none',stroke:'#e6bc7f','stroke-width':2,'stroke-dasharray':'6 5','data-precio-origen':p.precio_inicial,'data-horizonte':p.horizonte_minutos});
 draw('circle',{cx:g.ancla.x,cy:g.ancla.y,r:4,fill:'#dcecf3'});draw('circle',{cx:g.fin.x,cy:g.fin.y,r:4,fill:'#e6bc7f'});
 $('detalleGrafico').textContent='De '+date(g.inicio?new Date(g.inicio).toISOString():p.cotizacion_en)+' a '+date(p.objetivo_en)+'. Tiempo proporcional; línea discontinua = estimación.';
}
function renderFactors(){
 const root=$('factores');root.replaceChildren();
 for(const key of selected()){
  const e=last?.extras.find(x=>x.source===key),card=document.createElement('article'),title=document.createElement('h3'),text=document.createElement('p');title.textContent=labels[key];card.append(title);
  let detail='No consultada en esta lectura. Pulsa «Calcular y consultar».';
  if(e?.status==='unavailable')detail='No se pudo recibir esta fuente.';
  if(e?.status==='observed')try{
   const v=e.value;
   if(key==='book'){
    const side=s=>v[s].slice(0,10).reduce((t,r)=>t+Number(r[0])*Number(r[1]),0);
    need(Array.isArray(v.bids)&&Array.isArray(v.asks)&&v.bids.length&&v.asks.length,'Libro inválido');
    detail='Primeros 10 niveles · Compra '+money(side('bids'))+' · Venta '+money(side('asks'))+'. Las órdenes pueden cancelarse.';
   }else if(key==='trades')detail=Array.isArray(v)?v.length+' operaciones en la muestra. El lado reportado es el creador de mercado, no el agresor.':'Formato no compatible';
   else if(key==='noaa'){
    need(Array.isArray(v),'Formato NOAA no compatible');
    const rows=v.filter(r=>typeof r?.Kp==='number'&&Date.parse(r.time_tag+'Z')<=Date.parse(e.received_at));const x=rows.at(-1);
    detail=x?'Kp '+x.Kp+' · '+date(x.time_tag+'Z')+'. Observación separada; no altera el precio calculado.':'Sin lectura compatible';
   }else detail=money(Number(v.price),key==='euro'?'EUR':'USD')+' · '+date(v.time)+'. Cotización de contexto, no causa demostrada.';
  }catch(err){detail='Datos recibidos con formato no utilizable.';}
  text.textContent=detail;card.append(text);root.append(card);
 }
}
async function readRemote(){
 $('leerRegistro').disabled=true;try{
  const r=await pub('registro'),s=r.value;need(s?.schema==='laplace-resumen-m001'&&Array.isArray(s.ultimos)&&s.ultimos.length<=100&&Array.isArray(s.por_horizonte),'Resumen remoto incompatible');
  remote=s;$('registroEstado').textContent='Diario remoto actualizado: '+date(s.actualizado_en)+' · '+s.pronosticos+' pronósticos / '+s.evaluados+' evaluados. Cierre de minuto; no precio del segundo exacto.';renderRemote();
 }catch(e){$('registroEstado').textContent='No se pudo actualizar el registro remoto. No se inventan resultados.';}
 finally{$('leerRegistro').disabled=false;}
}
function renderRemote(){
 const root=$('filas');root.replaceChildren();if(!remote)return;
 const rows=remote.ultimos.filter(x=>x.horizonte_minutos===Number($('horizonte').value)).filter(x=>{
  const f=$('filtro').value;return f==='todos'||f==='pendientes'&&!x.resultado||f==='aciertos'&&x.resultado?.acierto_precio===true||f==='fallos'&&x.resultado?.acierto_precio===false;});
 for(const x of rows){const tr=document.createElement('tr');for(const v of [date(x.objetivo_en),x.horizonte_minutos+' min',money(x.precio_predicho),x.resultado?(x.resultado.acierto_precio?'Acierto de precio':'Fallo de precio')+' · error '+money(x.resultado.error_absoluto_usd):x.estado==='sin_patrones'?'Sin candidato':'Pendiente']){const td=document.createElement('td');td.textContent=v;tr.append(td);}root.append(tr);}
 if(!rows.length){const tr=document.createElement('tr'),td=document.createElement('td');td.colSpan=4;td.textContent='No hay registros para este horizonte y filtro.';tr.append(td);root.append(tr);}
}
function buildNodes(){
 const keys=Object.keys(labels),root=$('nodos');
 keys.forEach((key,i)=>{const a=i*2*Math.PI/keys.length,el=document.createElement('div');el.className='nodo';el.dataset.node=key;el.dataset.estado='espera';
  const radius=innerWidth<500?108:175;el.style.setProperty('--x',Math.cos(a)*radius+'px');el.style.setProperty('--y',Math.sin(a)*112+'px');el.style.setProperty('--z',Math.sin(a)*55+'px');
  el.textContent=labels[key];const info=document.createElement('small');info.textContent='Esperando';el.append(info);root.append(el);
 });
}
buildNodes();
function effects(){$('escena').classList.toggle('con-efectos',$('animacion').checked&&!document.hidden&&!matchMedia('(prefers-reduced-motion: reduce)').matches);}
$('animacion').addEventListener('change',effects);document.addEventListener('visibilitychange',()=>{effects();statusText();});effects();
$('giro').oninput=()=>{$('nodos').style.setProperty('--giro',$('giro').value+'deg');};
for(const btn of document.querySelectorAll('[data-tab]'))btn.onclick=()=>{for(const b of document.querySelectorAll('[data-tab]'))b.removeAttribute('aria-current');btn.setAttribute('aria-current','page');for(const s of document.querySelectorAll('.vista'))s.hidden=s.id!==btn.dataset.tab;if(btn.dataset.tab==='resumen')chart();};
$('actualizar').onclick=update;$('horizonte').onchange=render;$('historia').onchange=chart;$('leerRegistro').onclick=readRemote;$('filtro').onchange=renderRemote;
$('exportar').onclick=()=>{if(last)window.LaplaceNative?.export(JSON.stringify(last));};$('volver').onclick=()=>window.LaplaceNative?.close();
for(const c of document.querySelectorAll('[data-source]'))c.onchange=()=>{renderFactors();try{localStorage.setItem('laplace-fuentes-v1',JSON.stringify(selected()));}catch{}};
try{const prefs=JSON.parse(localStorage.getItem('laplace-fuentes-v1'));if(Array.isArray(prefs))for(const c of document.querySelectorAll('[data-source]'))c.checked=prefs.includes(c.dataset.source);}catch{}
setInterval(statusText,1000);window.addEventListener('resize',()=>{chart();$('nodos').replaceChildren();buildNodes();for(const [k,v] of Object.entries(statuses))status(k,v.state,v.detail);});
try{const r=await host('read');if(r.text){last=await verifySnapshot(JSON.parse(r.text));render();}}catch(e){alert(e.message);}
