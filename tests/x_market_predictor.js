#!/usr/bin/env node
'use strict';
// LAPLACE X: transparent data-transport and independent chronology auditor.
// Every prediction is computed by XI forecast-one.xi in the real REVERSE-PC runtime.
// Node never computes a candidate forecast, chooses a model, or updates XI state.
const fs=require('node:fs');
const path=require('node:path');
const os=require('node:os');
const crypto=require('node:crypto');
const cp=require('node:child_process');
const assert=require('node:assert/strict');

const ROOT=path.resolve(__dirname,'..');
const SOURCE=path.join(ROOT,'experiments/x-market-laplace/forecast-one.xi');
function sha(data){return crypto.createHash('sha256').update(data).digest('hex');}
function requireValid(ok,reason){if(!ok)throw Error(reason);}
function priceRow(day,cents){return {day,close_cents:cents};}
function dayString(i){const day=new Date(Date.UTC(2026,0,1+i));return day.toISOString().slice(0,10);}
function parseCSV(text){
  requireValid(typeof text==='string'&&text.length<20000,'CSV exceeds limit');
  const lines=text.replace(/\r\n/g,'\n').trim().split('\n');
  requireValid(lines.shift()==='date,close_cents','expected exactly: date,close_cents');
  requireValid(lines.length>=8&&lines.length<=220,'8..220 sequential observations required');
  let last='';
  return lines.map((line,i)=>{
    const m=/^(\d{4}-\d{2}-\d{2}),([1-9]\d{0,9})$/.exec(line);
    requireValid(Boolean(m),'invalid CSV row '+(i+2));
    const day=m[1],amount=Number(m[2]);
    requireValid(new Date(day+'T00:00:00.000Z').toISOString().slice(0,10)===day,'invalid date '+day);
    requireValid(day>last,'dates must be strictly ascending, without duplicates');
    requireValid(Number.isSafeInteger(amount)&&amount>=1&&amount<=2000000000,'close_cents must be positive and <=2 billion cents');
    last=day;return priceRow(day,amount);
  });
}
function toCSV(rows){return 'date,close_cents\n'+rows.map(x=>x.day+','+x.close_cents).join('\n')+'\n';}
function makeFixture(kind,size=66){
  let total=10000,seed=20261027;
  const rows=[];
  for(let t=0;t<size;t++){
    if(t>0){
      if(kind==='quadratic')total+=7+3*(t-1);
      else if(kind==='shock')total+=7+3*(t-1)+(t===33?250:0);
      else if(kind==='noise'){
        seed=(Math.imul(1664525,seed)+1013904223)>>>0;
        total+=(seed%241)-120;
      }else throw Error('unknown fixture');
    }
    requireValid(total>0&&total<=2000000000,'fixture outside input budget');
    rows.push(priceRow(dayString(t),total));
  }
  return rows;
}
function checkCode(code,step){
  if(code.error)throw code.error;
  if(code.status!==0)throw Error(step+': '+(code.stderr||'').slice(0,600)+' '+(code.stdout||'').slice(0,600));
  return code.stdout;
}
function command(exe,args,step){
  return checkCode(cp.spawnSync(exe,args,{encoding:'utf8',timeout:60000,maxBuffer:2*1024*1024}),step);
}
function stageProgram(t,cents){
  const bytes=[cents%256,Math.floor(cents/256)%256,Math.floor(cents/65536)%256,Math.floor(cents/16777216)%256],at=10000+4*t;
  // This input adapter stages only the new observation and the exact observation count.
  // No future prices, model coefficients, benchmark labels or hidden seeds are transferred.
  return '#!reverse-pc-machine-v1\n'+
    'load8 r0 4096\ncmp r0 '+t+'\nje correct_time\n'+
    'set r15 1\ndiv r15 0\nlabel correct_time\n'+
    bytes.map((value,i)=>'store8 '+(at+i)+' '+value+'\n').join('')+
    'add r0 1\nstore8 4096 r0\nprint r0\nhalt\n';
}
function registers(jsonl){
  const results=jsonl.trim().split('\n').filter(Boolean).map(x=>JSON.parse(x));
  const entries=results.filter(x=>x.type==='register');
  const map=Object.fromEntries(entries.map(x=>[x.register,x.value]));
  requireValid(entries.length===6&&Object.keys(map).length===6,'unexpected XI result count');
  for(const key of ['r0','r13','r14','r15','r10','r11']){
    requireValid(Number.isSafeInteger(map[key]),'missing XI register '+key);
  }
  requireValid([0,1,2].includes(map.r13),'invalid expert id');
  requireValid(map.r14>=1&&map.r14<=2000000000,'XI prediction out of range');
  requireValid(map.r11===0||map.r11===1,'invalid gate status');
  requireValid(map.r10>=4&&map.r10<=8,'unexpected training length');
  requireValid(map.r15>=0,'negative historical error');
  return {observed_count:map.r0,expert:map.r13,forecast_cents:map.r14,rolling_loss_cents:map.r15,rolling_samples:map.r10,diagnostic_gate:map.r11===1};
}
function average(sum,n){return n?Math.round(1000*sum/n)/1000:null;}
function runSeries(exe,rows,{rxetest=true}={}){
  requireValid(fs.existsSync(exe),'original runtime binary missing');
  requireValid(fs.existsSync(SOURCE),'original XI model missing');
  requireValid(rows.length>=8&&rows.length<=220,'input count out of range');
  const work=fs.mkdtempSync(path.join(os.tmpdir(),'laplace-x-'));
  const current=path.join(work,'current.rvp'),out=path.join(work,'next.rvp'),stage=path.join(work,'observe.xi');
  try{
    command(exe,['init',current],'XI init');
    let pending=null;
    let modelAE=0,baseAE=0,scored=0,accepted=0,acceptedAE=0,wrongDirection=0,nonflat=0;
    let nonzeroError=0,firstForecast=null;
    const forecasts=[],matured=[],selection={persistence:0,velocity:0,acceleration:0};
    const sourceSHA=sha(fs.readFileSync(SOURCE));
    for(let t=0;t<rows.length;t++){
      const item=rows[t];
      // Audit forecast made BEFORE observation at t is placed in InverseMemory.
      if(pending){
        requireValid(pending.target_index===t,'prediction not aligned with next observation');
        const err=Math.abs(pending.forecast_cents-item.close_cents);
        const baseline=Math.abs(pending.naive_cents-item.close_cents);
        const diff=(pending.forecast_cents-pending.naive_cents)*(item.close_cents-pending.naive_cents);
        if(pending.forecast_cents!==pending.naive_cents){nonflat++;if(diff<=0)wrongDirection++;}
        modelAE+=err;baseAE+=baseline;scored++;if(err)nonzeroError++;
        if(pending.diagnostic_gate){accepted++;acceptedAE+=err;}
        matured.push({index:t,date:item.day,issued_after:pending.issued_at,expert:pending.expert,forecast_cents:pending.forecast_cents,naive_cents:pending.naive_cents,actual_cents:item.close_cents,abs_error_cents:err,baseline_abs_error_cents:baseline,diagnostic_gate:pending.diagnostic_gate,prediction_sha256:pending.seal});
        pending=null;
      }
      fs.writeFileSync(stage,stageProgram(t,item.close_cents),{encoding:'utf8',mode:0o600});
      const staged=command(exe,['run',stage,current,out],'XI stage '+t);
      requireValid(staged.includes('"register":"r0","value":'+(t+1)),'wrong observation count');
      fs.renameSync(out,current);
      if(t<6)continue;
      const before=fs.readFileSync(current);
      const raw=command(exe,['run',SOURCE,current,out],'XI forecast '+t);
      const after=fs.readFileSync(out);
      requireValid(before.equals(after),'read-only forecast mutated RVPC2 state');
      const pred=registers(raw);
      requireValid(pred.observed_count===t+1,'lookahead / stale XI time boundary');
      if(t===6)firstForecast={index:t,prediction:pred};
      const label=['persistence','velocity','acceleration'][pred.expert];
      selection[label]++;
      const issued={...pred,target_index:t+1,issued_at:item.day,naive_cents:item.close_cents,source_sha256:sourceSHA,snapshot_sha256:sha(before)};
      issued.seal=sha(JSON.stringify(issued)); // Auditable checksum, NOT a trusted timestamp signature.
      forecasts.push(issued);
      if(t+1<rows.length)pending=issued;
      if(rxetest&&t===6){
        const binary=path.join(work,'model.rxe'),rxeState=path.join(work,'rxe.rvp');
        const compiled=command(exe,['compile',SOURCE,binary,'Laplace X Causal Forecaster'],'XI→RXE compile');
        requireValid(compiled.includes('"format":"RXE"'),'not a real RXE image');
        const rex=command(exe,['run',binary,current,rxeState],'run RXE model');
        requireValid(rex===raw,'XI and RXE outputs differ');
        requireValid(before.equals(fs.readFileSync(rxeState)),'RXE mutated read-only state');
      }
    }
    const metrics={observations:rows.length,scored,forecast_count:forecasts.length,model_mae_cents:average(modelAE,scored),persistence_mae_cents:average(baseAE,scored),improvement_vs_persistence_cents:average(baseAE-modelAE,scored),gate_coverage:average(accepted,scored),gate_mae_cents:average(acceptedAE,accepted),nonflat_directional_accuracy:nonflat?average(nonflat-wrongDirection,nonflat):null,nonzero_errors:nonzeroError,selected:selection};
    return {model:'Laplace X v0.2 · native XI',status:'research_only',feed:'staged historical or synthetic CSV',source_sha256:sourceSHA,dates:{first:rows[0].day,last:rows.at(-1).day},metrics,forecasts,matured,firstForecast};
  }finally{fs.rmSync(work,{recursive:true,force:true});}
}
function ci(exe){
  // Independent fixtures. Forecaster XI never sees the generator's formula or seed.
  const exact=runSeries(exe,parseCSV(toCSV(makeFixture('quadratic'))));
  const shock=runSeries(exe,parseCSV(toCSV(makeFixture('shock'))));
  const high=runSeries(exe,parseCSV(toCSV(makeFixture('quadratic').map(x=>priceRow(x.day,x.close_cents+80000)))));
  assert.equal(high.metrics.model_mae_cents,0,'four-byte high-price calculation regressed');
  const noise=runSeries(exe,parseCSV(toCSV(makeFixture('noise'))));
  assert.equal(exact.metrics.nonzero_errors,0,'quadratic is not exact after minimum history');
  assert.equal(exact.metrics.model_mae_cents,0);
  assert.ok(exact.metrics.persistence_mae_cents>0);
  assert.ok(shock.metrics.nonzero_errors>0,'unknown shock was supposedly known in advance');
  assert.ok(noise.metrics.nonzero_errors>0);
  // A common historical prefix must imply byte-identical predictions despite any future suffix.
  const prefix=makeFixture('quadratic'),changed=prefix.map((x,i)=>priceRow(x.day,i>=26?Math.min(65000,x.close_cents+315):x.close_cents));
  const left=runSeries(exe,prefix,{rxetest:false}),right=runSeries(exe,changed,{rxetest:false});
  for(let t=0;t<=24;t++){
    if(t<6)continue;
    assert.deepEqual(left.forecasts[t-6],right.forecasts[t-6],'changed future altered earlier forecast at '+t);
  }
  assert.throws(()=>parseCSV('date,close_cents\n2026-01-01,100\n2026-01-01,101\n'.repeat(6)));
  assert.throws(()=>parseCSV(toCSV(prefix).replace('2026-01-04,','2026-01-40,')));
  assert.throws(()=>parseCSV(toCSV(prefix).replace('2026-01-06,','2026-01-06,-')));
  console.log(JSON.stringify({suite:'laplace_x_causal_xi',xi_native:true,rxe_equal:true,chronology_enforced:true,read_only:true,unknown_shock_detected:true,quadratic_exact:true,models_compared:true,results:{
    quadratic:exact.metrics,high_price:high.metrics,shock:shock.metrics,unobserved_innovations:noise.metrics
  }}));
}
function main(){
  const [exePath,arg,reportPath]=process.argv.slice(2);
  requireValid(Boolean(exePath),'usage: node tests/x_market_predictor.js /path/to/reverse_pc [--ci | history.csv] [report.json]');
  const exe=path.resolve(exePath);
  if(arg==='--ci'){ci(exe);return;}
  requireValid(typeof arg==='string','CSV filename required for non-demo execution');
  const rows=parseCSV(fs.readFileSync(path.resolve(arg),'utf8'));
  const result=runSeries(exe,rows);
  if(reportPath)fs.writeFileSync(path.resolve(reportPath),JSON.stringify(result,null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({model:result.model,status:result.status,source_sha256:result.source_sha256,dates:result.dates,metrics:result.metrics,report_file:reportPath||null}));
}
main();
