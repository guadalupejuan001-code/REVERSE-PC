import {emitirPronosticos,verificarPronostico,validarVelas} from './modelo.mjs';
import {huellaContenido} from './integridad.mjs';
import {parseStockChart,BOLSA_LAB} from './x001.mjs';

const UPSTREAM_M001='06ebce4bddf25d615cefd85ed24081f37504a492';
const UPSTREAM_BOLSA='08cafb094a5c0f81253509eff412214dd526b808';
const ASSETS=Object.freeze({
  'BTC-USD':{label:'Bitcoin',short:'BTC',kind:'crypto',currency:'USD',model:'M001'},
  SPY:{label:'S&P 500 ETF',short:'SPY',kind:'stock',currency:'USD',model:'XN01'},
  AAPL:{label:'Apple',short:'AAPL',kind:'stock',currency:'USD',model:'XN01'},
  NVDA:{label:'NVIDIA',short:'NVDA',kind:'stock',currency:'USD',model:'XN01'}
});
const BTC_HORIZONS=new Set([15,30,60,240,1440,10080]);
const $=x=>document.getElementById(x),need=(c,m)=>{if(!c)throw Error(m)};
const money=(n,c='USD')=>Number.isFinite(n)?new Intl.NumberFormat('es-MX',{style:'currency',currency:c,maximumFractionDigits:2}).format(n):'—';
const date=t=>Number.isFinite(Date.parse(t))?new Intl.DateTimeFormat('es-MX',{dateStyle:'short',timeStyle:'medium'}).format(new Date(t)):'—';
const percent=n=>Number.isFinite(n)?(100*n).toFixed(1)+' %':'—';
let serial=0,busy=false,last=null,remote=null;const readings=new Map();
const pending=new Map(),statuses={};

window.LaplaceHost={complete(id,result){
  const p=pending.get(id);if(!p)return;pending.delete(id);clearTimeout(p.timer);
  result.ok?p.ok(result):p.fail(Error(result.error||'La consulta falló'));
}};
function host(operation,payload={}){
  return new Promise((ok,fail)=>{
    if(!window.LaplaceNative?.request){fail(Error('Abre Laplace desde REVERSE; esta vista necesita el adaptador Android.'));return;}
    const id='l'+(++serial),timer=setTimeout(()=>{pending.delete(id);fail(Error('La consulta agotó su tiempo. La última lectura se conserva.'));},75000);
    pending.set(id,{ok,fail,timer});
    try{window.LaplaceNative.request(id,operation,typeof payload==='string'?payload:JSON.stringify(payload));}
    catch(e){clearTimeout(timer);pending.delete(id);fail(e);}
  });
}
function asset(){return ASSETS[$('activo').value]??ASSETS['BTC-USD'];}
function assetId(){return $('activo').value;}
function isBTC(){return asset().kind==='crypto';}
function remember(s){if(s?.market?.asset){last=s;readings.set(s.market.asset,s);}return s;}
function current(){return readings.get(assetId())??(last?.market?.asset===assetId()?last:null);}
function alert(text=''){
  if(/429|too many|demasiadas solicitudes/i.test(text))text='La fuente limitó temporalmente las consultas. Laplace redujo el ritmo; vuelve a intentarlo más tarde si persiste.';
  $('aviso').textContent=text;$('aviso').hidden=!text;
}
function sourceLabels(){
  return isBTC()?{ticker:'Precio BTC',candles:'Velas',book:'Libro',trades:'Operaciones',eth:'ETH/USD',euro:'BTC/EUR',noaa:'NOAA'}:
    {stock:'Serie '+asset().short,r5:'5 min',r15:'15 min',impulse:'Impulso',volume:'Volumen'};
}
const stateNames={espera:'Esperando',consultando:'Consultando',recibida:'Lista',error:'Sin datos',omitida:'No usada'};
function status(source,state,detail=''){
  statuses[source]={state,detail};const el=document.querySelector('[data-node="'+source+'"]');
  if(el){el.dataset.estado=state;const small=el.querySelector('small');if(small)small.textContent=stateNames[state]||state;}
  $('flujoEstado').textContent=busy?'Consulta en curso · '+Object.values(statuses).filter(x=>x.state==='recibida').length+' señales listas.':'Sin consultas activas. Se muestra la última lectura del mercado seleccionado.';
}
async function pub(source,params={}){
  status(source,'consultando');
  try{const r=await host('public',{source,params});const value=JSON.parse(r.text);status(source,'recibida');return {value,received_at:r.received_at};}
  catch(e){status(source,'error',e.message);throw e;}
}
const sleep=n=>new Promise(ok=>setTimeout(ok,n));
async function bitcoinCandles(){
  const end=Math.floor(Date.now()/300000)*300,start=end-14*86400,parts=[];
  for(let day=0;day<14;day++){
    const r=await pub('candles',{step:300,start:start+day*86400,end:start+(day+1)*86400});
    need(Array.isArray(r.value)&&r.value.length<=500,'Velas incompatibles');
    parts.push(...r.value.filter(x=>Array.isArray(x)&&x[0]>=start&&x[0]<end));
    if(day<13)await sleep(420);
  }
  return parts;
}
function selected(){return [...document.querySelectorAll('[data-source]:checked')].map(x=>x.dataset.source);}
async function verifySnapshot(s){
  if(s?.schema==='laplace-reverse-m001-v1'){
    const {sha256,...body}=s;need(body.upstream===UPSTREAM_M001,'Lectura antigua incompatible');
    need(sha256===await huellaContenido(body),'Lectura local alterada');
    for(const p of body.predictions??[])await verificarPronostico(p);
    return {...s,market:{asset:'BTC-USD',kind:'crypto',model:'M001'}};
  }
  const {sha256,...body}=s??{};
  need(body.schema==='laplace-reverse-v2','Lectura local incompatible');
  need(sha256===await huellaContenido(body),'Lectura local alterada; se conserva sin utilizarla');
  need(ASSETS[body.market?.asset],'Mercado desconocido');
  need(Array.isArray(body.bars)&&body.bars.length<=10000,'Historial fuera de presupuesto');
  need(Date.parse(body.at)>=Date.parse(body.quote?.known_at),'Fecha de captura incoherente');
  if(body.market.kind==='crypto'){
    need(body.upstream===UPSTREAM_M001&&Array.isArray(body.predictions)&&body.predictions.length===6,'Pronósticos BTC incompletos');
    for(const p of body.predictions){await verificarPronostico(p);need(p.precio_inicial===Number(body.quote.value),'Precio BTC incoherente');}
  }else{
    need(body.upstream===UPSTREAM_BOLSA&&body.stock_result?.schema==='laplace-xn01-native-xi-v1','Resultado XN01 nativo ausente');
    need(body.market.asset===body.stock_meta?.symbol,'Símbolo bursátil incoherente');
  }
  return s;
}
async function updateBTC(){
  const extrasTask=Promise.all(selected().map(async source=>{try{return {source,status:'observed',...(await pub(source))};}catch{return {source,status:'unavailable'};}}));
  const raw=await bitcoinCandles(),response=await pub('ticker'),q=response.value;
  need(q&&Number.isFinite(Number(q.price))&&Number(q.price)>0,'La fuente no entregó un precio válido');
  const quote={asset:'BTC-USD',value:String(q.price),observed_at:new Date(Date.parse(q.time)).toISOString(),known_at:new Date(Date.parse(response.received_at)).toISOString()};
  const bars=validarVelas(raw,{corte:quote.observed_at});need(bars.length>=60,'Historial insuficiente');
  const predictions=await emitirPronosticos(bars,quote,{emitidoEn:new Date().toISOString(),horizontes:[15,30,60,240,1440,10080],revision:'REVERSE-Android-M001-'+UPSTREAM_M001});
  const extras=await extrasTask;
  return {schema:'laplace-reverse-v2',upstream:UPSTREAM_M001,at:new Date().toISOString(),
    market:{asset:'BTC-USD',kind:'crypto',model:'M001'},quote,bars,predictions,extras};
}
async function updateStock(){
  const id=assetId(),r=await pub('stock',{symbol:id,range:'1mo'}),parsed=parseStockChart(r.value,id,r.received_at);
  const lastBar=parsed.bars.at(-1),observedAt=new Date((lastBar[0]+300)*1000).toISOString();
  const quote={asset:id,value:String(lastBar[4]),observed_at:observedAt,known_at:new Date(Date.parse(r.received_at)).toISOString()};
  status('r5','consultando');status('r15','consultando');status('impulse','consultando');status('volume','consultando');
  const native=await host('native_x001',{asset:id,bars:parsed.bars.slice(-240)});
  const result=native.result;need(result?.schema==='laplace-xn01-native-xi-v1'&&result.asset===id,'XN01 nativo no devolvió un resultado compatible');
  for(const key of ['r5','r15','impulse','volume'])status(key,'recibida');
  return {schema:'laplace-reverse-v2',upstream:UPSTREAM_BOLSA,at:new Date().toISOString(),
    market:{asset:id,kind:'stock',model:'XN01-XI'},quote,bars:parsed.bars,stock_result:result,
    stock_meta:{symbol:id,currency:parsed.currency,exchange:parsed.exchange,timezone:parsed.timezone},extras:[]};
}
async function update(){
  if(busy)return;busy=true;$('actualizar').disabled=true;$('actualizar').textContent='Consultando…';alert();
  resetNodes();
  try{
    const body=isBTC()?await updateBTC():await updateStock();
    const fresh={...body,sha256:await huellaContenido(body)};
    remember(await verifySnapshot(fresh));$('activo').value=last.market.asset;await host('save',JSON.stringify(fresh));render();
    $('guardado').textContent='Consulta guardada y sellada localmente.';
  }catch(e){alert(e.message+' No se reemplazó la última lectura válida.');}
  finally{busy=false;$('actualizar').disabled=false;$('actualizar').textContent='Consultar ahora';for(const k in statuses)if(statuses[k].state==='consultando')status(k,'error');statusText();}
}
function prediction(s=current()){return s?.predictions?.find(p=>p.horizonte_minutos===Number($('horizonte').value));}
function statusText(){
  const s=current();if(!s){$('estado').textContent='Sin lectura';return;}
  const age=Date.now()-Date.parse(s.quote.observed_at);$('estado').textContent=age< -5000?'Revisar reloj':age>180000?'Histórica':'Reciente';
}
function clearSummary(){
  $('precio').textContent='—';$('candidato').textContent='—';$('fecha').textContent='Pulsa «Consultar ahora».';
  $('cambio').textContent='Sin cálculo';$('objetivo').textContent='—';$('soporteCorto').textContent='—';$('validacionCorta').textContent='—';
  $('soporte').textContent='Se necesitan datos cerrados y una lectura reciente.';$('estadoBits').hidden=true;$('estadoBits').replaceChildren();
  $('exportar').disabled=true;drawChart();
}
function render(){
  adaptMode();const s=current();if(!s){clearSummary();renderFactors();renderRegister();statusText();return;}
  $('exportar').disabled=false;$('precio').textContent=money(Number(s.quote.value),asset().currency);$('fecha').textContent='Observado: '+date(s.quote.observed_at);
  if(isBTC())renderBTC(s);else renderStock(s);
  drawChart();renderFactors();renderRegister();statusText();
}
function renderBTC(s){
  const p=prediction(s);if(!p)return;
  $('resultadoEtiqueta').textContent='PRECIO CALCULADO · '+$('horizonte').selectedOptions[0].textContent.toUpperCase();
  $('candidato').textContent=money(p.precio_predicho);$('modeloChip').textContent='M001';
  const change=p.precio_predicho===null?null:p.precio_predicho-p.precio_inicial;
  $('candidato').className=change>0?'positivo':change<0?'negativo':'neutral';
  $('cambio').textContent=change===null?'Sin antecedentes suficientes.':(change<0?'Bajada: ':change>0?'Subida: ':'Sin cambio: ')+money(Math.abs(change))+' · '+(100*change/p.precio_inicial).toFixed(3)+' %';
  $('objetivo').textContent=date(p.objetivo_en);$('soporteCorto').textContent=p.analogos+' análogos';$('validacionCorta').textContent='M001 experimental';
  $('soporte').textContent=p.analogos+' antecedentes seleccionados · '+s.bars.length+' velas cerradas. '+(p.analogos<8?'Soporte escaso.':'Candidato publicado sin sustituirlo por persistencia.');
  $('interpretacion').textContent='M001 calcula un precio candidato usando antecedentes similares. La línea discontinua es el punto estimado, no el recorrido que seguirá el precio.';
  $('estadoBits').hidden=true;
}
function renderStock(s){
  const x=s.stock_result,up=x.direction==='subida';
  $('resultadoEtiqueta').textContent='DIRECCIÓN XI/ETHER · PRÓXIMOS 5 MIN';$('modeloChip').textContent='XN01';
  $('candidato').textContent=up?'SUBIDA':'BAJADA';$('candidato').className=up?'positivo':'negativo';
  $('cambio').textContent='Confianza interna '+percent(x.confidence)+' · P(subida) '+percent(x.probability_up);
  $('objetivo').textContent=date(new Date(Date.parse(s.quote.observed_at)+300000).toISOString());
  $('soporteCorto').textContent=x.support+' estados iguales';$('validacionCorta').textContent='XN01 · pendiente de reserva fresca';
  $('soporte').textContent='Estado XI '+x.mask+' · '+x.training_rows+' filas nativas · soporte '+x.support+' · prior '+percent(x.prior)+'.';
  $('interpretacion').textContent='XN01 calcula la dirección dentro de XI/Ether usando InverseMemory. JavaScript solo representa la salida y no decide SUBIDA/BAJADA.';
  const root=$('estadoBits');root.hidden=false;root.replaceChildren();
  const defs=[['5 min',1,'close actual ≥ anterior'],['15 min',2,'close actual ≥ hace 15 min'],['Impulso',4,'movimiento 5m > media absoluta 30m'],['Volumen',8,'volumen > media 30m']];
  for(const [name,bit,detail] of defs){const el=document.createElement('div');el.className='bit';el.dataset.on=Boolean(x.mask&bit);const dot=document.createElement('i'),txt=document.createElement('span'),sm=document.createElement('small');txt.textContent=name;sm.textContent=(x.mask&bit?'Activo · ':'Inactivo · ')+detail;txt.append(sm);el.append(dot,txt);root.append(el);}
}
function drawChart(){
  const s=current(),graph=$('grafico');graph.replaceChildren();if(!s)return;
  if(!isBTC()){drawObservedStock(s,graph);return;}
  const p=prediction(s);if(!p)return;
  const width=Math.max(300,graph.getBoundingClientRect().width||800);
  const inst={observed_at:s.quote.observed_at,target_at:p.objetivo_en,observed_price_usd:Number(s.quote.value),projected_price_usd:p.precio_predicho};
  const serie=s.bars.slice(-Number($('historia').value)).map(b=>({fecha:new Date((b[0]+300)*1000).toISOString(),precio:b[4]}));
  const g=window.LaplaceGrafica.calcular(serie,inst,{ancho:width});graph.setAttribute('viewBox','0 0 '+width+' 285');
  const draw=(tag,attrs,text)=>{const e=document.createElementNS('http://www.w3.org/2000/svg',tag);for(const [k,v] of Object.entries(attrs))e.setAttribute(k,String(v));if(text!==undefined)e.textContent=text;graph.append(e);return e;};
  if(!g){draw('text',{x:width/2,y:130,'text-anchor':'middle',fill:'#b2c5d3'},'Sin datos suficientes para graficar');return;}
  for(const r of g.rejilla){draw('line',{x1:g.izquierda,x2:g.derecha,y1:r.y,y2:r.y,stroke:'#314153'});draw('text',{x:g.izquierda-8,y:r.y+4,'text-anchor':'end',fill:'#a3b3c0','font-size':'11'},Math.round(r.valor).toLocaleString('es-MX'));}
  draw('path',{d:g.puntos.map((v,i)=>(i?'L':'M')+v.x+' '+v.y).join(' '),fill:'none',stroke:'#dcecf3','stroke-width':2});
  draw('circle',{cx:g.ancla.x,cy:g.ancla.y,r:4,fill:'#dcecf3'});
  draw('path',{d:'M '+g.ancla.x+' '+g.ancla.y+' L '+g.fin.x+' '+g.fin.y,fill:'none',stroke:'#e6bc7f','stroke-width':2,'stroke-dasharray':'6 5','data-horizonte':p.horizonte_minutos});
  draw('circle',{cx:g.fin.x,cy:g.fin.y,r:4,fill:'#e6bc7f'});
  $('detalleGrafico').textContent='Observado hasta '+date(s.quote.observed_at)+' · estimación a '+date(p.objetivo_en)+'.';
}
function drawObservedStock(s,graph){
  const width=Math.max(300,graph.getBoundingClientRect().width||800),height=285,left=width<550?64:78,right=width-18,top=28,bottom=height-42;
  const rows=s.bars.slice(-Number($('historia').value)).map(b=>({t:(b[0]+300)*1000,p:b[4]})).filter(x=>Number.isFinite(x.p)&&x.p>0);
  const draw=(tag,attrs,text)=>{const e=document.createElementNS('http://www.w3.org/2000/svg',tag);for(const [k,v] of Object.entries(attrs))e.setAttribute(k,String(v));if(text!==undefined)e.textContent=text;graph.append(e);return e;};
  graph.setAttribute('viewBox','0 0 '+width+' '+height);
  if(rows.length<2){draw('text',{x:width/2,y:130,'text-anchor':'middle',fill:'#b2c5d3'},'Sin datos suficientes para graficar');return;}
  const t0=rows[0].t,t1=rows.at(-1).t,lo=Math.min(...rows.map(x=>x.p)),hi=Math.max(...rows.map(x=>x.p)),margin=Math.max((hi-lo)*.15,rows.at(-1).p*.0003),min=lo-margin,max=hi+margin;
  const x=t=>left+(t-t0)/Math.max(1,t1-t0)*(right-left),y=p=>bottom-(p-min)/Math.max(1e-9,max-min)*(bottom-top);
  for(let i=0;i<4;i++){const value=max-(max-min)*i/3,yy=y(value);draw('line',{x1:left,x2:right,y1:yy,y2:yy,stroke:'#314153'});draw('text',{x:left-8,y:yy+4,'text-anchor':'end',fill:'#a3b3c0','font-size':'11'},value.toFixed(2));}
  draw('path',{d:rows.map((v,i)=>(i?'L':'M')+x(v.t).toFixed(2)+' '+y(v.p).toFixed(2)).join(' '),fill:'none',stroke:'#dcecf3','stroke-width':2,'data-series':'observed-stock'});
  draw('circle',{cx:x(rows.at(-1).t),cy:y(rows.at(-1).p),r:4,fill:'#8bdcb9'});
  $('detalleGrafico').textContent='Observado hasta '+date(s.quote.observed_at)+' · XN01 predice dirección, no un precio futuro.';
}
function renderFactors(){
  const root=$('factores');root.replaceChildren();const s=current();
  if(!s){$('datosEstado').textContent='Sin lectura';return;}
  $('datosEstado').textContent=s.market.asset+' · '+date(s.at);
  if(!isBTC()){
    const cards=[
      ['Fuente bursátil',(s.stock_meta.exchange||'Mercado')+' · '+s.stock_meta.timezone+' · '+s.bars.length+' velas cerradas.'],
      ['Estado XI/Ether','Máscara '+s.stock_result.mask+' · '+s.stock_result.support+' antecedentes del mismo estado.'],
      ['Ensayo B001',labText(s.market.asset)]
    ];
    for(const [t,d] of cards)root.append(card(t,d));return;
  }
  for(const key of selected()){
    const e=s.extras?.find(x=>x.source===key);let detail='No consultada.';
    if(e?.status==='unavailable')detail='No se recibió una lectura válida.';
    if(e?.status==='observed')try{
      const v=e.value;
      if(key==='book'){const side=n=>v[n].slice(0,10).reduce((sum,r)=>sum+Number(r[0])*Number(r[1]),0);detail='Top 10 · compra '+money(side('bids'))+' · venta '+money(side('asks'))+'.';}
      else if(key==='trades')detail=Array.isArray(v)?v.length+' operaciones recibidas.':'Formato no compatible';
      else if(key==='noaa'){const rows=v.filter(r=>typeof r?.Kp==='number');const x=rows.at(-1);detail=x?'Kp '+x.Kp+' · observación separada del cálculo.':'Sin Kp compatible';}
      else detail=money(Number(v.price),key==='euro'?'EUR':'USD')+' · contexto, no causa demostrada.';
    }catch{detail='Datos recibidos con formato no utilizable.';}
    root.append(card(sourceLabels()[key]||key,detail));
  }
}
function card(title,detail){const el=document.createElement('article'),h=document.createElement('h3'),p=document.createElement('p');h.textContent=title;p.textContent=detail;el.append(h,p);return el;}
function labText(id){const x=BOLSA_LAB[id];return x?'Último ensayo reservado: Laplace '+percent(x.accuracy)+' vs referencia '+percent(x.baseline)+'. Brier '+x.brier.toFixed(4)+' vs '+x.baseline_brier.toFixed(4)+'.':'Sin ensayo empaquetado.';}
async function readRemote(){
  if(!isBTC()){renderRegister();return;}
  $('leerRegistro').disabled=true;
  try{const r=await pub('registro'),s=r.value;need(s?.schema==='laplace-resumen-m001'&&Array.isArray(s.ultimos)&&Array.isArray(s.por_horizonte),'Resumen remoto incompatible');remote=s;renderRegister();}
  catch{$('registroEstado').textContent='No se pudo actualizar el registro remoto.';}
  finally{$('leerRegistro').disabled=false;}
}
function renderRegister(){
  const root=$('filas');root.replaceChildren();
  if(!isBTC()){
    $('registroTitulo').textContent='Ensayo B001 · '+asset().short;$('registroDescripcion').textContent='Resultado histórico reservado del laboratorio, no una predicción en vivo.';$('leerRegistro').hidden=true;$('registroControles').hidden=true;
    $('registroEstado').textContent=labText(assetId());
    const x=BOLSA_LAB[assetId()];if(x){const tr=document.createElement('tr');for(const v of ['2026-10-30','5 min',percent(x.accuracy),'Referencia '+percent(x.baseline)]){const td=document.createElement('td');td.textContent=v;tr.append(td);}root.append(tr);}return;
  }
  $('registroTitulo').textContent='Registro M001 · Bitcoin';$('registroDescripcion').textContent='Pronósticos horarios prospectivos guardados por separado.';$('leerRegistro').hidden=false;$('registroControles').hidden=false;
  $('registroEstado').textContent=remote?'Actualizado '+date(remote.actualizado_en)+' · '+remote.pronosticos+' pronósticos / '+remote.evaluados+' evaluados.':'Sin descargar.';
  if(!remote)return;
  const rows=remote.ultimos.filter(x=>x.horizonte_minutos===Number($('horizonte').value)).filter(x=>{const f=$('filtro').value;return f==='todos'||f==='pendientes'&&!x.resultado||f==='aciertos'&&x.resultado?.acierto_precio===true||f==='fallos'&&x.resultado?.acierto_precio===false;});
  for(const x of rows){const tr=document.createElement('tr');for(const v of [date(x.objetivo_en),x.horizonte_minutos+' min',money(x.precio_predicho),x.resultado?(x.resultado.acierto_precio?'Acierto':'Fallo')+' · error '+money(x.resultado.error_absoluto_usd):x.estado==='sin_patrones'?'Sin candidato':'Pendiente']){const td=document.createElement('td');td.textContent=v;tr.append(td);}root.append(tr);}
}
function adaptMode(){
  const a=asset(),btc=a.kind==='crypto';$('modoCabecera').textContent='Mercado · '+a.short+' '+a.model;$('mercadoChip').textContent=a.short;$('modeloChip').textContent=a.model;
  $('precioEtiqueta').textContent='PRECIO OBSERVADO · '+a.short;$('graficoTitulo').textContent=btc?'Historia observada y estimación':'Historia observada · '+a.short;$('graficoSubtitulo').textContent=btc?'Precio y punto calculado con eje temporal real.':'XN01 no dibuja un precio futuro que no calculó.';
  for(const el of document.querySelectorAll('[data-btc-only]'))el.hidden=!btc;for(const el of document.querySelectorAll('[data-stock-only]'))el.hidden=btc;
  for(const opt of $('horizonte').options)opt.disabled=btc?!BTC_HORIZONS.has(Number(opt.value)):opt.value!=='5';
  if(btc&&!BTC_HORIZONS.has(Number($('horizonte').value)))$('horizonte').value='15';if(!btc)$('horizonte').value='5';
  buildNodes();renderRegister();
}
function buildNodes(){
  const root=$('nodos');root.replaceChildren();for(const k of Object.keys(statuses))delete statuses[k];
  const labels=sourceLabels(),keys=Object.keys(labels),radius=innerWidth<500?105:170;
  keys.forEach((key,i)=>{const a=i*2*Math.PI/keys.length,el=document.createElement('div');el.className='nodo';el.dataset.node=key;el.dataset.estado='espera';el.style.setProperty('--x',Math.cos(a)*radius+'px');el.style.setProperty('--y',Math.sin(a)*(innerWidth<500?92:112)+'px');el.style.setProperty('--z',Math.sin(a)*50+'px');el.textContent=labels[key];const sm=document.createElement('small');sm.textContent='Esperando';el.append(sm);root.append(el);statuses[key]={state:'espera',detail:''};});
  $('nucleoModo').textContent=asset().model+' · '+asset().short;
}
function resetNodes(){buildNodes();for(const key of Object.keys(statuses)){const required=isBTC()?selected().includes(key)||['ticker','candles'].includes(key):true;status(key,required?'espera':'omitida');}}
function effects(){$('escena').classList.toggle('con-efectos',$('animacion').checked&&!document.hidden&&!matchMedia('(prefers-reduced-motion: reduce)').matches);}
function navigate(id){for(const b of document.querySelectorAll('[data-tab]'))b.toggleAttribute('aria-current',b.dataset.tab===id);for(const s of document.querySelectorAll('.vista'))s.hidden=s.id!==id;if(id==='resumen')drawChart();else if(id==='datos')renderFactors();else if(id==='registro')renderRegister();else if(id==='flujo')buildNodes();}
for(const btn of document.querySelectorAll('[data-tab]'))btn.onclick=()=>navigate(btn.dataset.tab);
$('animacion').onchange=effects;document.addEventListener('visibilitychange',()=>{effects();statusText();});effects();
$('giro').oninput=()=>{$('nodos').style.setProperty('--giro',$('giro').value+'deg');};
$('actualizar').onclick=update;$('horizonte').onchange=render;$('historia').onchange=drawChart;$('leerRegistro').onclick=readRemote;$('filtro').onchange=renderRegister;
$('exportar').onclick=()=>{const s=current();if(s)window.LaplaceNative?.export(JSON.stringify(s));};$('volver').onclick=()=>window.LaplaceNative?.close();
$('activo').onchange=()=>{adaptMode();render();try{localStorage.setItem('laplace-activo-v2',assetId());}catch{}};
for(const c of document.querySelectorAll('[data-source]'))c.onchange=()=>{renderFactors();try{localStorage.setItem('laplace-fuentes-v1',JSON.stringify(selected()));}catch{}};
try{const a=localStorage.getItem('laplace-activo-v2');if(ASSETS[a])$('activo').value=a;const prefs=JSON.parse(localStorage.getItem('laplace-fuentes-v1'));if(Array.isArray(prefs))for(const c of document.querySelectorAll('[data-source]'))c.checked=prefs.includes(c.dataset.source);}catch{}
adaptMode();setInterval(statusText,1000);window.addEventListener('resize',()=>{drawChart();buildNodes();});
try{const r=await host('read');if(r.text){remember(await verifySnapshot(JSON.parse(r.text)));render();}}catch(e){alert(e.message);}
