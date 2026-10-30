import test from 'node:test';
import assert from 'node:assert/strict';
import {parseStockChart,stateAt,liveX001,BOLSA_LAB} from '../../reverse-os-android/app/src/main/assets/laplace/x001.mjs';
const start=Math.floor(Date.parse('2026-10-01T13:30:00Z')/300000)*300;
function bars(n=500){let p=500;return Array.from({length:n},(_,i)=>{const o=p;p*=Math.exp((i%18<10?.0008:-.0007));return [start+i*300,Math.min(o,p)*.9999,Math.max(o,p)*1.0001,o,p,1000+(i%7)*100]})}
function chart(rows){return {chart:{result:[{meta:{currency:'USD',exchangeName:'NMS',exchangeTimezoneName:'America/New_York'},timestamp:rows.map(x=>x[0]),indicators:{quote:[{low:rows.map(x=>x[1]),high:rows.map(x=>x[2]),open:rows.map(x=>x[3]),close:rows.map(x=>x[4]),volume:rows.map(x=>x[5])}]}}]}}}
test('B001 parses only closed five-minute bars',()=>{
 const b=bars(),received=new Date((b.at(-1)[0]+600)*1000).toISOString(),r=parseStockChart(chart(b),'SPY',received);
 assert.equal(r.symbol,'SPY');assert.equal(r.bars.length,b.length);assert.equal(r.exchange,'NMS');
});
test('X001 state remains four bits and ignores future bars',()=>{
 const b=bars(100),a=stateAt(b,70),copy=b.map(x=>[...x]);copy[90][4]*=2;copy[90][2]=Math.max(copy[90][2],copy[90][4]);
 assert.ok(Number.isInteger(a)&&a>=0&&a<16);assert.equal(stateAt(copy,70),a);
});
test('live X001 produces direction, confidence, support and chronological walk-forward',()=>{
 const b=bars(500),cutoff=new Date((b.at(-1)[0]+300)*1000).toISOString(),x=liveX001(b,{cutoff});
 assert.equal(x.schema,'laplace-x001-live-v1');assert.ok(['subida','bajada'].includes(x.direction));
 assert.ok(x.probability_up>=0&&x.probability_up<=1);assert.ok(x.confidence>=.5&&x.confidence<=1);
 assert.equal(x.bits.length,4);assert.ok(x.walk_forward.count>0);assert.ok(x.walk_forward.accuracy>=0&&x.walk_forward.accuracy<=1);
});
test('B001 packaged evidence remains explicit and does not claim universal accuracy',()=>{
 assert.deepEqual(Object.keys(BOLSA_LAB),['SPY','AAPL','NVDA']);
 for(const row of Object.values(BOLSA_LAB)){assert.ok(row.accuracy>=0&&row.accuracy<=1);assert.ok(row.baseline>=0&&row.baseline<=1);}
});
