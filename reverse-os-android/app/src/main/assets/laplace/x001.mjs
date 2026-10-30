import {validarVelas} from './modelo.mjs';
const avg=a=>a.reduce((s,x)=>s+x,0)/a.length;
const need=(c,m)=>{if(!c)throw Error(m)};
export const BOLSA_LAB=Object.freeze({
  SPY:{accuracy:0.5148936170212766,baseline:0.4595744680851064,brier:0.25544831160465975,baseline_brier:0.25158087258091055},
  AAPL:{accuracy:0.4658119658119658,baseline:0.4978723404255319,brier:0.26087168404022,baseline_brier:0.2509044158985818},
  NVDA:{accuracy:0.5191489361702127,baseline:0.5319148936170213,brier:0.2576195733099689,baseline_brier:0.24943622183474493}
});
export function parseStockChart(raw,symbol,receivedAt){
  const r=raw?.chart?.result?.[0],q=r?.indicators?.quote?.[0],ts=r?.timestamp;
  need(r&&q&&Array.isArray(ts),'La fuente bursátil no devolvió una serie compatible');
  const cutoff=Date.parse(receivedAt)/1000,bars=[];
  for(let i=0;i<ts.length;i++){
    const row=[ts[i],q.low?.[i],q.high?.[i],q.open?.[i],q.close?.[i],q.volume?.[i]];
    if(!row.every(Number.isFinite)||row[0]%300!==0||(row[0]+300)>cutoff)continue;
    const [t,l,h,o,c,v]=row;if(l<=0||h<l||o<l||o>h||c<l||c>h||v<0)continue;
    bars.push(row);
  }
  bars.sort((a,b)=>a[0]-b[0]);
  need(bars.length>=80,'Historial bursátil insuficiente');
  return {symbol,currency:r.meta?.currency??'USD',exchange:r.meta?.exchangeName??'—',
    timezone:r.meta?.exchangeTimezoneName??'—',bars};
}
export function stateAt(bars,i){
  if(i<6)return null;
  for(let j=i-5;j<=i;j++)if(j>0&&bars[j][0]!==bars[j-1][0]+300)return null;
  const r5=Math.log(bars[i][4]/bars[i-1][4]),r15=Math.log(bars[i][4]/bars[i-3][4]);
  const recent=[];for(let j=i-5;j<=i;j++)recent.push(Math.log(bars[j][4]/bars[j-1][4]));
  const rms=Math.sqrt(avg(recent.map(x=>x*x))),vol=avg(bars.slice(i-5,i+1).map(x=>x[5]));
  return (r5>=0?1:0)|(r15>=0?2:0)|(Math.abs(r5)>rms?4:0)|(bars[i][5]>vol?8:0);
}
function rows(bars,start,end){
  const out=[];
  for(let i=Math.max(6,start);i<Math.min(end,bars.length-1);i++){
    const mask=stateAt(bars,i);if(mask===null||bars[i+1][0]!==bars[i][0]+300)continue;
    out.push({i,mask,y:Number(bars[i+1][4]>bars[i][4])});
  }
  return out;
}
function probability(train,mask,strength=8){
  need(train.length>=16,'Muy pocos estados cerrados para X001');
  const positives=train.reduce((s,r)=>s+r.y,0),prior=(positives+1)/(train.length+2);
  const same=train.filter(r=>r.mask===mask),up=same.reduce((s,r)=>s+r.y,0);
  return {p:(up+strength*prior)/(same.length+strength),support:same.length,prior};
}
export function liveX001(raw,{cutoff,lookback=224,validation=64}={}){
  const bars=validarVelas(raw,{corte:cutoff,maximo:10000}),current=bars.length-1,mask=stateAt(bars,current);
  need(mask!==null,'El estado actual cruza una pausa de mercado o no tiene historia suficiente');
  const train=rows(bars,Math.max(0,current-lookback),current),now=probability(train,mask);
  const scored=[];
  const start=Math.max(7,current-validation);
  for(let i=start;i<current;i++){
    const m=stateAt(bars,i);if(m===null||bars[i+1][0]!==bars[i][0]+300)continue;
    const previous=rows(bars,Math.max(0,i-lookback),i);if(previous.length<16)continue;
    const p=probability(previous,m).p,y=Number(bars[i+1][4]>bars[i][4]);
    scored.push({p,y,ok:(p>=.5)===Boolean(y)});
  }
  const p=now.p,confidence=Math.max(p,1-p),accuracy=scored.length?avg(scored.map(x=>Number(x.ok))):null;
  const bits=[
    {name:'5 min',on:Boolean(mask&1),detail:(mask&1)?'retorno no negativo':'retorno negativo'},
    {name:'15 min',on:Boolean(mask&2),detail:(mask&2)?'retorno no negativo':'retorno negativo'},
    {name:'Impulso',on:Boolean(mask&4),detail:(mask&4)?'movimiento > RMS 30 min':'movimiento <= RMS 30 min'},
    {name:'Volumen',on:Boolean(mask&8),detail:(mask&8)?'sobre media 30 min':'en/bajo media 30 min'}
  ];
  return {schema:'laplace-x001-live-v1',mask,probability_up:p,direction:p>=.5?'subida':'bajada',
    confidence,support:now.support,prior:now.prior,walk_forward:{count:scored.length,accuracy},bits};
}
