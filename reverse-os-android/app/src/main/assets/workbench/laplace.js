'use strict';
const laplaceSessions=new Map();
function cleanLaplaceState(raw){
  const safe=entry=>entry&&entry.schema==='laplace-universo-btc-u001-v1'&&typeof entry.at==='string'&&entry.instrument_15m&&typeof entry.instrument_15m.projected_price_usd==='number'&&Number.isFinite(entry.instrument_15m.projected_price_usd)&&JSON.stringify(entry).length<=150000;
  return {version:1,history:(Array.isArray(raw?.history)?raw.history:[]).filter(safe).slice(-20),
    observations:(Array.isArray(raw?.observations)&&raw.observations.length<=4096&&JSON.stringify(raw.observations).length<=800000)?raw.observations:[]};
}
function laplaceData(){return state.laplace||(state.laplace=cleanLaplaceState());}
function laplaceSession(w){if(!laplaceSessions.has(w.id))laplaceSessions.set(w.id,{busy:false,error:'',tab:'instrument'});return laplaceSessions.get(w.id);}
function laplaceTime(value){const date=new Date(value);return Number.isFinite(date.getTime())?date.toLocaleString('es',{hour12:false}):'Sin fecha';}
function laplaceMoney(value){return Number.isFinite(value)?value.toLocaleString('es',{style:'currency',currency:'USD',maximumFractionDigits:2}):'Sin observación';}
function laplaceMetric(label,value,detail){return '<div class="lp-metric"><small>'+esc(label)+'</small><strong>'+esc(value)+'</strong><span>'+esc(detail||'')+'</span></div>';}
function laplaceInstrument(report){
  if(!report)return '<div class="lp-empty"><h3>Tu próxima observación</h3><p>Pulsa «Observar y proyectar». Laplace leerá BTC/USD y las fuentes públicas disponibles, con sus fechas originales.</p></div>';
  const r=report.instrument_15m,b=r.backtest||{},range=r.scenario_interval_usd;
  const model=r.model_selected==='analogia_historica_15m'?'Analogía histórica':'Referencia: precio observado';
  return '<div class="lp-metrics">'+laplaceMetric('BTC/USD observado',laplaceMoney(r.observed_price_usd),laplaceTime(r.observed_at))+
    laplaceMetric('Proyección a 15 minutos',laplaceMoney(r.projected_price_usd),'Objetivo: '+laplaceTime(r.target_at))+
    laplaceMetric('Modelo seleccionado',model,r.price_candles+' velas completas · '+r.analog_count+' análogos')+'</div>'+
    '<section class="lp-card"><h3>Trayectoria y cálculo</h3><p>'+(r.model_selected==='persistencia'?'La analogía no superó el criterio de validación reciente. El centro conserva el precio observado.':'La analogía superó el criterio en la ventana reciente; su resultado sigue siendo una proyección condicionada.')+'</p>'+
    '<dl class="lp-facts"><dt>Variación central</dt><dd>'+esc(String(r.projected_change_pct))+' %</dd><dt>Escenarios históricos 10–90</dt><dd>'+esc(range?range.map(laplaceMoney).join(' — '):'Datos insuficientes')+'</dd><dt>Error medio del modelo / referencia</dt><dd>'+esc(String(b.model_mae_return_pct??'—'))+' % / '+esc(String(b.reference_mae_return_pct??'—'))+' %</dd><dt>Decisiones históricas evaluadas</dt><dd>'+esc(String(b.scored??0))+'</dd></dl>'+
    '<p class="lp-note">El rango describe los análogos observados; no es una garantía. Las variables nuevas se registran sin modificar el precio previsto hasta validar su aporte.</p></section>'+
    '<details class="lp-card"><summary>Cálculo, fuentes y huellas de esta captura</summary><pre>'+esc(JSON.stringify(report,null,2))+'</pre></details>';
}
function laplaceStates(report){
  const graph=report?.universal_state,rows=graph?.variables||[];
  const sources=[...(report?.measured_market||[]).map(s=>({name:s.name,status:s.status,reason:s.reason})),...(report?[{name:'NOAA · Kp planetario',status:report.measured_space_weather?.status,reason:report.measured_space_weather?.reason}]:[])];
  return '<section class="lp-card"><h3>Estados y relaciones U001</h3><p>Registro por dominios, variables, unidades y fuentes. Los hechos conocidos después del corte quedan excluidos.</p>'+
    '<div class="lp-metrics">'+laplaceMetric('Estados conocidos',String(graph?.known_states??0),'Corte: '+(graph?laplaceTime(graph.cutoff):'sin captura'))+laplaceMetric('Dominios observados',String(graph?.domains?.length??0),(graph?.domains||[]).join(', '))+laplaceMetric('Relaciones registradas',String(graph?.relations?.length??0),'Hipótesis, no causas demostradas')+'</div>'+
    '<div class="lp-table"><table><thead><tr><th>Dominio / variable</th><th>Último valor</th><th>Repeticiones</th></tr></thead><tbody>'+rows.map(r=>'<tr><td>'+esc(r.domain)+'<small>'+esc(r.variable)+'</small></td><td>'+esc(String(r.last_value))+' '+esc(r.unit)+'</td><td>'+esc(String(r.count))+'</td></tr>').join('')+'</tbody></table></div>'+
    '<div class="lp-source-list">'+sources.map(s=>'<p><strong>'+esc(s.name)+'</strong><span>'+esc(s.status==='observed'?'Observado':s.reason||'Sin observación')+'</span></p>').join('')+'</div></section>'+
    '<section class="lp-card"><h3>Tus observaciones</h3><p>'+laplaceData().observations.length+' registros importados. Admite un archivo JSON de observaciones U001 con dominio, variable, valor, unidad, fuente y fechas.</p><label class="secondary-button lp-file">Importar observaciones<input type="file" accept="application/json,.json" data-lp-import></label></section>';
}
function laplaceHistory(){const list=laplaceData().history;
 return '<section class="lp-card"><h3>Capturas y contraste</h3><p>Se conservan hasta 20 capturas. El contraste se registra cuando otra observación cae entre el objetivo y los tres minutos siguientes.</p>'+
 '<div class="lp-source-list">'+list.slice().reverse().map(entry=>{const r=entry.instrument_15m;return '<article><strong>'+esc(laplaceTime(r.target_at))+' · '+esc(laplaceMoney(r.projected_price_usd))+'</strong><p>'+esc(entry.comparison?'Observado después del objetivo: '+laplaceMoney(entry.comparison.observed_price_usd)+' · Error absoluto: '+entry.comparison.absolute_error_pct.toFixed(4)+' %':'Pendiente de observación dentro de la ventana de contraste')+'</p></article>';}).join('')+(list.length?'':'<p>Todavía no hay capturas.</p>')+'</div><button class="secondary-button" data-lp-action="export">Exportar historial</button></section>';
}
function laplaceHTML(w){const s=laplaceSession(w),report=laplaceData().history.at(-1);
 return '<div class="lp-shell"><header class="lp-header"><div><span class="eyebrow">LAPLACE · U001 / I015</span><h2>Observa. Relaciona. Proyecta.</h2><p>Tu instrumento de estados y trayectorias · BTC/USD a 15 minutos.</p></div><button class="primary-button" data-lp-action="observe"'+(s.busy?' disabled':'')+'>'+esc(s.busy?'Observando fuentes…':'Observar y proyectar')+'</button></header>'+
 '<nav class="lp-tabs" aria-label="Áreas de Laplace">'+[['instrument','Instrumento 15 min'],['states','Estados y relaciones'],['history','Historial']].map(([id,label])=>'<button class="secondary-button '+(s.tab===id?'selected':'')+'" data-lp-tab="'+id+'" aria-current="'+(s.tab===id?'page':'false')+'">'+label+'</button>').join('')+'</nav>'+
 (s.error?'<p class="lp-error" role="alert">'+esc(s.error)+'</p>':'')+
 (s.busy?'<p role="status">Leyendo fuentes públicas. La memoria de BBY Q permanece independiente.</p>':'')+
 (s.tab==='states'?laplaceStates(report):s.tab==='history'?laplaceHistory():laplaceInstrument(report))+
 '<footer class="lp-footer">Corte temporal explícito · Fuentes verificables · Actualización manual · Las fuentes ausentes se indican sin inventar valores.</footer></div>';
}
function laplaceRefresh(){for(const w of state.windows.filter(x=>x.app==='laplace'))if(getWindow(w.id))renderWindowContent(w);}
async function laplaceObserve(w){const s=laplaceSession(w);if(s.busy)return;s.busy=true;s.error='';laplaceRefresh();
 try{
  if(!nativeAvailable)throw Error('La observación de fuentes requiere la APK de REVERSE.');
  if(!window.ReverseLaplaceCore)throw Error('El instrumento está preparando sus módulos. Intenta de nuevo en un momento.');
  const report=await window.ReverseLaplaceCore.observe(laplaceData().observations,laplaceData().history);
  const r=report.instrument_15m,when=Date.parse(r.observed_at),history=laplaceData().history;
  for(const old of history){const target=Date.parse(old.instrument_15m.target_at);if(!old.comparison&&when>=target&&when-target<=180000)old.comparison={observed_at:r.observed_at,observed_price_usd:r.observed_price_usd,absolute_error_pct:Math.abs(r.observed_price_usd-old.instrument_15m.projected_price_usd)/r.observed_price_usd*100};}
  history.push(report);if(history.length>20)history.splice(0,history.length-20);
  queueSave();
 }catch(error){s.error='No se obtuvo una captura nueva. '+String(error.message||error);}finally{s.busy=false;laplaceRefresh();}
}
document.addEventListener('click',event=>{const b=event.target.closest('[data-lp-action],[data-lp-tab]');if(!b)return;const w=getWindow(b.closest('.window')?.dataset.id);if(!w||w.app!=='laplace')return;
 if(b.dataset.lpTab){laplaceSession(w).tab=b.dataset.lpTab;renderWindowContent(w);return;}
 if(b.dataset.lpAction==='observe')void laplaceObserve(w);
 if(b.dataset.lpAction==='export'){
  if(!window.ReverseNative?.exportText){toast('La exportación requiere REVERSE Android.','help');return;}
  window.ReverseNative.exportText('Laplace-U001-Historial.json',JSON.stringify(laplaceData(),null,2),'application/json');
 }
});
document.addEventListener('change',async event=>{const input=event.target;if(!input.matches('[data-lp-import]'))return;const w=getWindow(input.closest('.window')?.dataset.id);if(!w||w.app!=='laplace')return;
 try{const file=input.files?.[0];if(!file)return;if(file.size>800000)throw Error('El archivo supera 800 KB.');if(!window.ReverseLaplaceCore)throw Error('El instrumento todavía no está listo.');const records=JSON.parse(await file.text());window.ReverseLaplaceCore.validate(records);laplaceData().observations=records;laplaceSession(w).error='';queueSave();}
 catch(error){laplaceSession(w).error=String(error.message||error);}finally{laplaceRefresh();}
});
