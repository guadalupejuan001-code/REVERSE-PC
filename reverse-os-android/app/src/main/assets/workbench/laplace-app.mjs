import {observeUniverseBTC} from './laplace-core/universo/mercado.mjs';
import {observation,universeSnapshot} from './laplace-core/universo/estados.mjs';

const urls=[
 'https://api.exchange.coinbase.com/products/BTC-USD/ticker',
 'https://api.exchange.coinbase.com/products/BTC-USD/stats',
 'https://api.exchange.coinbase.com/products/BTC-USD/candles?granularity=300',
 'https://api.exchange.coinbase.com/products/BTC-USD/book?level=2',
 'https://api.exchange.coinbase.com/products/BTC-USD/trades',
 'https://api.exchange.coinbase.com/products/ETH-USD/ticker',
 'https://api.exchange.coinbase.com/products/BTC-EUR/ticker',
 'https://services.swpc.noaa.gov/products/noaa-planetary-k-index.json'
];
if(typeof AbortSignal.timeout!=='function')AbortSignal.timeout=ms=>{const c=new AbortController();setTimeout(()=>c.abort(),ms);return c.signal;};
async function sourceRead(url){
 const source=urls.indexOf(url);if(source<0)throw Error('La fuente no está autorizada para Laplace.');
 const result=await nativeRequest('laplaceRead',JSON.stringify({source}));
 if(!result.ok||result.url!==url||result.status!==200)throw Error(result.error||'La fuente no confirmó una lectura válida.');
 return new Response(result.body,{status:200,headers:{'Content-Type':'application/json','Content-Length':String(new TextEncoder().encode(result.body).length)}});
}
window.ReverseLaplaceCore={
 observe:async(observations,history=[])=>{
  const report=await observeUniverseBTC({fetchImpl:sourceRead,now:()=>new Date().toISOString(),additionalObservations:observations});
  if(!history.length)return report;
  const records=new Map();
  const links=new Map(),renamed=new Map();let revisions=0;
  const signature=item=>JSON.stringify({...item,known_at:null});
  const put=raw=>{
   const item=observation(raw),old=records.get(item.id);
   if(!old){records.set(item.id,item);return item.id;}
   if(signature(old)===signature(item)){
    if(item.known_at<old.known_at)records.set(item.id,item);
    return item.id;
   }
   const id=item.id.slice(0,100)+'-v'+globalThis.ReverseNative.laplaceHash(signature(item)).slice(0,12);
   const revision=records.get(id);
   if(!revision){records.set(id,observation({...item,id}));revisions++;}
   else if(item.known_at<revision.known_at)records.set(id,observation({...item,id}));
   return id;
  };
  for(const old of history){
   for(const item of old.universal_state?.states||[])put(item);
   for(const link of old.universal_state?.relations||[])links.set(link.id,link);
  }
  for(const item of report.universal_state.states)renamed.set(item.id,put(item));
  for(const raw of report.universal_state.relations){
   const link={...raw,from:renamed.get(raw.from)||raw.from,to:renamed.get(raw.to)||raw.to};
   if(links.has(link.id)&&JSON.stringify(links.get(link.id))!==JSON.stringify(link))link.id=link.id.slice(0,100)+'-v'+globalThis.ReverseNative.laplaceHash(JSON.stringify(link)).slice(0,12);
   links.set(link.id,link);
  }
  return {...report,universal_state:universeSnapshot([...records.values()],{cutoff:report.at,hypotheses:[...links.values()]}),android_ledger:{retained_captures:history.length,revision_records:revisions}};
 },
 validate:records=>{if(!Array.isArray(records)||records.length>4096)throw Error('Se admiten hasta 4096 observaciones.');records.forEach(observation);return universeSnapshot(records,{cutoff:new Date().toISOString()});}
};
if(typeof laplaceRefresh==='function'&&typeof state!=='undefined')laplaceRefresh();
