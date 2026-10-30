import {host,loadArchivedWorld} from './app.mjs';
const $=id=>document.getElementById(id),fmt=n=>Number(n).toLocaleString('es-MX'),pc=n=>Number.isFinite(n)?(n*100).toFixed(2)+' %':'—';
let saved={captures:[],endpoint:''},report;
const text=(id,value)=>{$(id).textContent=value;};
const node=(tag,value)=>{const e=document.createElement(tag);e.textContent=value;return e;};
async function archive(){const c=await fetch('./mundo-archivado.json').then(r=>r.json());await loadArchivedWorld(c);}
async function retain(){await host('integration_save',saved);}
function renderCaptures(){
 const target=$('i001Capturas');target.replaceChildren();for(const c of saved.captures.slice(-8).reverse()){
  const row=document.createElement('article');row.append(node('strong',c.kind==='quote'?'BTC/USD · '+c.price+' USD':c.title),node('p','Recibido: '+new Date(c.known_at).toLocaleString('es-MX')));
  const a=node('a','Fuente original');a.href=c.source;a.target='_blank';a.rel='noopener';row.append(a);target.append(row);
 }if(!saved.captures.length)target.append(node('p','Todavía no hay capturas locales.'));
}
async function capture(){
 $('i001Capturar').disabled=true;text('i001Estado','Consultando Coinbase y Reserva Federal…');const results=await Promise.allSettled([host('public',{source:'ticker',params:{}}),host('public',{source:'fed',params:{}})]);let added=0;
 for(let i=0;i<results.length;i++){const r=results[i];if(r.status!=='fulfilled')continue;
  if(i===0){const q=JSON.parse(r.value.text);if(typeof q.price!=='string'||!/^\d+(\.\d+)?$/.test(q.price))continue;saved.captures.push({kind:'quote',price:q.price,known_at:r.value.received_at,observed_at:q.time??null,source:'https://api.exchange.coinbase.com/products/BTC-USD/ticker'});added++;}
  else{if(/<!DOCTYPE|<!ENTITY/i.test(r.value.text))continue;const xml=new DOMParser().parseFromString(r.value.text,'application/xml');if(xml.querySelector('parsererror'))continue;for(const item of [...xml.querySelectorAll('item')].slice(0,10)){
    const title=item.querySelector('title')?.textContent??'',link=item.querySelector('link')?.textContent??'';let u;try{u=new URL(link);}catch{continue;}if(u.protocol!=='https:'||!(u.hostname==='federalreserve.gov'||u.hostname.endsWith('.federalreserve.gov')))continue;
    if(saved.captures.some(e=>e.source===link))continue;saved.captures.push({kind:'document',title:title.slice(0,500),known_at:r.value.received_at,published_at:item.querySelector('pubDate')?.textContent??null,source:link});added++;
  }}
 }
 saved.captures=saved.captures.slice(-100);try{await retain();renderCaptures();text('i001Estado',added+' registros guardados · '+results.filter(x=>x.status==='rejected').length+' fuentes sin respuesta.');}catch(e){text('i001Estado','No se pudo confirmar el guardado: '+e.message);}finally{$('i001Capturar').disabled=false;}
}
async function connect(){
 const endpoint=$('i001Endpoint').value.trim();$('i001Conectar').disabled=true;
 try{const u=new URL(endpoint);if(u.protocol!=='https:'||u.username||u.password||u.search||u.hash)throw Error('Usa la URL HTTPS de tu servicio.');
  const r=await host('public',{source:'input_health',params:{endpoint}}),h=JSON.parse(r.text);if(h.schema!=='laplace.input.health.i001')throw Error('La respuesta no corresponde a I001.');
  saved.endpoint=endpoint;await retain();text('i001Servicio',(h.ready?'Servicio preparado':'Servicio sin disponibilidad completa')+' · consultado '+new Date(r.received_at).toLocaleTimeString('es-MX'));const pre=$('i001Salud');pre.textContent=JSON.stringify(h,null,2);
 }catch(e){text('i001Servicio','Sin conexión: '+e.message);}finally{$('i001Conectar').disabled=false;}
}
function training(){
 const h=report?.horizons.find(h=>h.minutes===Number($('x002Horizonte').value));if(!h)return;
 text('x002Casos',h.calibrated.count+' / '+h.calibrated.eligible);text('x002Nativo',pc(h.native.direction_accuracy));text('x002Calibrado',pc(h.calibrated.direction_accuracy));text('x002Base',pc(h.baseline.direction_accuracy));
 text('x002Detalle',(h.calibration_retains_state_information?'Conserva la señal por estado.':'Peso de la señal por estado: cero; usa la frecuencia de calibración.')+' Evaluación retrospectiva del 25 al 30 de octubre de 2026. '+(h.calibrated.count<8?'Muestra insuficiente para una conclusión estable.':'No demuestra una ventaja predictiva consistente.'));
}
$('i001Capturar').onclick=()=>capture().catch(e=>{text('i001Estado',e.message);$('i001Capturar').disabled=false;});$('i001Conectar').onclick=connect;
$('cargarArchivoMundo').onclick=()=>archive().catch(e=>text('integracionEstado',e.message));
$('x002Horizonte').onchange=training;
$('x002Modelo').onclick=async()=>{try{const raw=await fetch('./x002-'+$('x002Horizonte').value+'m.xi').then(r=>r.text());$('x002Codigo').textContent=raw;$('x002Programa').open=true;}catch(e){text('x002Detalle',e.message);}};
(async()=>{
 try{const r=await host('integration_read');const s=JSON.parse(r.text);if(Array.isArray(s.captures)&&s.captures.length<=100)saved={...saved,...s};}catch{}
 $('i001Endpoint').value=saved.endpoint??'';renderCaptures();
 try{report=await fetch('./x002-resumen.json').then(r=>r.json());training();}catch(e){text('x002Detalle',e.message);}
 try{const p=await fetch('./instituciones-resumen.json').then(r=>r.json());text('pulsoEntidades',fmt(p.entities));text('pulsoRelaciones',fmt(p.relations));
  const target=$('pulsoInformes');for(const r of p.reports){const article=document.createElement('article'),name=r.root.includes('2012383')?'BlackRock':'JPMorgan Chase';article.append(node('strong',name+' · '+(r.kind==='holdings'?'posiciones 13F':'filiales EX-21')),node('p',fmt(r.rows)+' filas · referencia '+r.report_date+' · conocidas '+new Date(r.known_at).toLocaleDateString('es-MX')));target.append(article);}
 }catch(e){text('integracionEstado',e.message);}
})();
