'use strict';
/* Laplace X: user-supplied chronological closes, evaluated by native XI in isolation. */
const LAPLACE_CSV_EXAMPLE='date,close_cents\n2026-10-01,10000\n2026-10-02,10007\n2026-10-03,10017\n2026-10-04,10030\n2026-10-05,10046\n2026-10-06,10065\n2026-10-07,10087\n2026-10-08,10112\n2026-10-09,10140\n2026-10-10,10171';
const laplaceDrafts=new Map(),laplaceBusy=new Set();
function xmForecastHTML(w){
 const csv=laplaceDrafts.get(w.id)||LAPLACE_CSV_EXAMPLE;
 return '<section class="xm-card xm-native-lab"><div class="xm-card-head"><div><strong>Laplace X · Predictor temporal XI</strong><small>8–220 cierres cronológicos en céntimos</small></div><span class="xm-pill neutral">XI / Ether</span></div>'+
 '<p>Introduce datos históricos con fecha. El ejemplo es sintético, no una cotización. La predicción de un paso corre localmente en un estado XI aislado.</p>'+
 '<label for="xm-csv-'+esc(w.id)+'">CSV: date,close_cents</label><textarea id="xm-csv-'+esc(w.id)+'" data-xm-csv rows="8" maxlength="20000" spellcheck="false">'+esc(csv)+'</textarea>'+
 '<div class="xm-native-actions"><button class="primary-button" type="button" data-xm-predict>Ejecutar predictor XI</button><span>Sin precios en vivo, trading ni probabilidades calibradas.</span></div>'+
 '<div class="xm-native-result" data-xm-result role="status" aria-live="polite">Introduce datos y ejecuta el modelo.</div></section>';
}
function laplaceParseCSV(raw){
 if(typeof raw!=='string'||raw.length>20000)throw Error('CSV demasiado grande');
 const lines=raw.replace(/\r\n/g,'\n').trim().split('\n');
 if(lines.shift()!=='date,close_cents'||lines.length<8||lines.length>220)throw Error('Usa la cabecera date,close_cents con 8–220 filas');
 let last='';const rows=[];
 for(let i=0;i<lines.length;i++){
  const m=/^(\d{4}-\d{2}-\d{2}),([1-9]\d{0,9})$/.exec(lines[i]);
  if(!m)throw Error('Fila '+(i+2)+' inválida');
  const day=m[1],amount=Number(m[2]),date=new Date(day+'T00:00:00.000Z');
  if(!Number.isFinite(date.getTime())||date.toISOString().slice(0,10)!==day||day<=last||!Number.isSafeInteger(amount)||amount>2000000000)throw Error('Fila '+(i+2)+': fecha o cantidad fuera de rango');
  rows.push({day,cents:amount});last=day;
 }
 return rows;
}
function laplaceProgram(rows,model){
 if(!model.startsWith('#!reverse-pc-machine-v1'))throw Error('Modelo XI local inválido');
 let code='#!reverse-pc-machine-v1\nstore8 4096 '+rows.length+'\n';
 for(let i=0;i<rows.length;i++)for(let j=0;j<4;j++)code+='store8 '+(10000+4*i+j)+' '+(Math.floor(rows[i].cents/Math.pow(256,j))%256)+'\n';
 code+=model.slice(model.indexOf('\n')+1);
 if(new TextEncoder().encode(code).length>256*1024)throw Error('Programa XI demasiado grande');
 return code;
}
function laplaceResult(reply,count){
 const lines=String(reply.output||'').trim().split('\n').filter(Boolean),regs=lines.map(x=>JSON.parse(x)).filter(x=>x.type==='register');
 const m=Object.fromEntries(regs.map(x=>[x.register,x.value]));
 if(regs.length!==6||Object.keys(m).length!==6)throw Error('Registros XI incompletos');
 for(const k of ['r0','r13','r14','r15','r10','r11'])if(!Number.isSafeInteger(m[k]))throw Error('Registro XI inválido: '+k);
 if(m.r0!==count||m.r13<0||m.r13>2||m.r14<1||m.r14>2000000000||m.r15<0||m.r10<4||m.r10>8||![0,1].includes(m.r11))throw Error('Resultado XI fuera de contrato');
 return m;
}
document.addEventListener('input',event=>{
 if(!event.target.matches('[data-xm-csv]'))return;
 const win=event.target.closest('.window');if(win)laplaceDrafts.set(win.dataset.id,event.target.value);
});
document.addEventListener('click',async event=>{
 const button=event.target.closest('button[data-xm-predict]');if(!button)return;
 const win=button.closest('.window'),w=win?getWindow(win.dataset.id):null;
 if(!w||w.app!=='xmarket'||laplaceBusy.has(w.id))return;
 const input=win.querySelector('[data-xm-csv]'),output=win.querySelector('[data-xm-result]');if(!input||!output)return;
 button.disabled=true;laplaceBusy.add(w.id);output.textContent='Calculando en XI/Ether…';
 try{
  if(!nativeAvailable)throw Error('Se necesita la APK nativa de REVERSE para ejecutar XI');
  const rows=laplaceParseCSV(input.value),r=await fetch('laplace-forecast.xi',{cache:'no-store'});
  if(!r.ok)throw Error('No se pudo leer el modelo local');
  const reply=await nativeRequest('experiment',laplaceProgram(rows,await r.text()));
  if(reply.ok!==true||reply.isolated!==true)throw Error('XI no confirmó aislamiento de estado');
  const m=laplaceResult(reply,rows.length);
  const model=['Persistencia','Primera diferencia','Segunda diferencia'][m.r13];
  output.textContent='Siguiente cierre estimado: '+m.r14.toLocaleString('es')+' céntimos. Modelo: '+model+'. Error histórico medio: '+(m.r15/m.r10).toLocaleString('es',{maximumFractionDigits:2})+' céntimos ('+m.r10+' pasos). Filtro diagnóstico: '+(m.r11?'aprobado':'no aprobado')+'. Esto no es una probabilidad ni una cotización futura.';
 }catch(error){output.textContent='Laplace X: '+(error?.message||'error de ejecución');}
 finally{laplaceBusy.delete(w.id);if(button.isConnected)button.disabled=false;}
});