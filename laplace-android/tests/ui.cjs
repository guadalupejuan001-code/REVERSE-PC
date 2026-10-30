/* Real Chrome + synthetic Android IO. UI/navigation test only. */
const {createServer}=require('node:http'),{readFileSync,writeFileSync,mkdirSync}=require('node:fs');
const {resolve,join}=require('node:path'),assert=require('node:assert/strict');
const {chromium}=require(process.env.LAPLACE_PLAYWRIGHT||'playwright');
const base=resolve(__dirname,'../../reverse-os-android/app/src/main/assets/laplace');
const out=resolve(process.argv[2]||'/tmp/laplace-ui-proof');mkdirSync(out,{recursive:true});
const server=createServer((req,res)=>{try{const path=req.url==='/'?'/index.html':req.url;if(!/^\/[a-z0-9-]+\.(html|mjs|js|css)$/.test(path))throw Error();res.setHeader('Content-Type',path.endsWith('.css')?'text/css':path.endsWith('.html')?'text/html':'text/javascript');res.end(readFileSync(base+path));}catch{res.writeHead(404);res.end();}});
(async()=>{
 await new Promise(ok=>server.listen(0,'127.0.0.1',ok));
 const browser=await chromium.launch({headless:true,executablePath:process.env.LAPLACE_CHROME||'/usr/bin/chromium',args:['--no-sandbox']});
 const context=await browser.newContext({viewport:{width:1366,height:950},locale:'es-MX'});
 let saved=null,fail=false,checks=0;const errors=[],calls=[];
 const fixedTime=Math.floor(Date.now()/300000)*300000+120000,end=Math.floor(fixedTime/300000)*300,start=end-14*86400;
 let v=80000;const bars=Array.from({length:4032},(_,i)=>{const o=v;v*=Math.exp(.0005*Math.sin(i/7)-.00001);return [start+i*300,Math.min(o,v)*.9998,Math.max(o,v)*1.0002,o,v,10+i%20]});
 const stockBars=bars.slice(-1200).map((b,i)=>{const p=500*Math.exp(.0006*Math.sin(i/9)+i*.00002),o=p/Math.exp(.0006*Math.sin(i/9)+i*.00002);return [b[0],Math.min(o,p)*.9998,Math.max(o,p)*1.0002,o,p,1000+i%50]});
 const stockChart={chart:{result:[{meta:{currency:'USD',exchangeName:'NMS',exchangeTimezoneName:'America/New_York'},timestamp:stockBars.map(b=>b[0]),indicators:{quote:[{low:stockBars.map(b=>b[1]),high:stockBars.map(b=>b[2]),open:stockBars.map(b=>b[3]),close:stockBars.map(b=>b[4]),volume:stockBars.map(b=>b[5])}]}}],error:null}};
 await context.exposeFunction('auditIO',async(operation,raw)=>{
  const p=JSON.parse(raw);calls.push({operation,p});if(operation==='read')return {ok:true,text:saved};if(operation==='save'){saved=raw;return {ok:true};}
  if(operation==='native_x001')return {ok:true,result:{schema:'laplace-xn01-native-xi-v1',asset:p.asset,backend:'XI/Ether · NativeRuntime',mask:11,probability_up_bps:5430,probability_up:.543,direction:'subida',support:17,prior_bps:5010,prior:.501,training_rows:176,confidence_bps:5430,confidence:.543,elapsed_ns:123456,core:{active_qubits:0,memory_overrides:42},isolated:true}};
  if(operation!=='public')return {ok:false,error:'Operación desconocida'};if(fail&&p.source==='candles')return {ok:false,error:'Fallo de fuente inducido'};
  await new Promise(ok=>setTimeout(ok,15));let value;
  if(p.source==='candles')value=bars.filter(b=>b[0]>=p.params.start&&b[0]<=p.params.end);
  else if(p.source==='ticker')value={price:String(v),time:new Date(fixedTime).toISOString()};
  else if(p.source==='stock')value=stockChart;
  else if(p.source==='book')value={bids:Array.from({length:12},(_,i)=>[String(v-1-i),'1',1]),asks:Array.from({length:12},(_,i)=>[String(v+1+i),'2',1])};
  else if(p.source==='trades')value=[{side:'buy',size:'.1'}];
  else if(p.source==='noaa')value=[{time_tag:new Date(fixedTime-3600000).toISOString().slice(0,19),Kp:1}];
  else if(p.source==='registro')value={schema:'laplace-resumen-m001',actualizado_en:new Date(fixedTime).toISOString(),pronosticos:2,evaluados:1,por_horizonte:[],ultimos:[{horizonte_minutos:15,objetivo_en:new Date(fixedTime).toISOString(),precio_predicho:80000,resultado:{acierto_precio:false,error_absoluto_usd:100}},{horizonte_minutos:60,objetivo_en:new Date(fixedTime).toISOString(),precio_predicho:79000,estado:'pendiente',resultado:null}]};
  else value={price:'2500',time:new Date(fixedTime).toISOString()};
  return {ok:true,text:JSON.stringify(value),received_at:new Date(fixedTime).toISOString()};
 });
 await context.addInitScript(()=>{window.LaplaceNative={request(id,op,payload){window.auditIO(op,payload).then(r=>window.LaplaceHost.complete(id,r));},export(payload){window.exported=payload;},close(){window.didClose=true;}};});
 const page=await context.newPage();await page.clock.setFixedTime(new Date(fixedTime));page.on('pageerror',e=>errors.push(e.message));const root='http://127.0.0.1:'+server.address().port;
 try{
  await page.goto(root);await page.waitForTimeout(150);assert.equal(await page.locator('#precio').innerText(),'—');checks++;
  assert.equal(calls.filter(c=>c.operation==='public').length,0);checks++;
  assert.equal(await page.inputValue('#activo'),'BTC-USD');checks++;
  await page.getByRole('button',{name:'Consultar ahora',exact:true}).click();await page.waitForFunction(()=>!document.getElementById('actualizar').disabled,{},{timeout:30000});
  assert.ok(saved);const btc=JSON.parse(saved);assert.equal(btc.schema,'laplace-reverse-v2');checks++;assert.equal(btc.market.asset,'BTC-USD');checks++;assert.equal(btc.predictions.length,6);checks++;assert.equal(btc.native_direction.schema,'laplace-xn01-native-xi-v1');checks++;
  await page.getByRole('button',{name:'Flujo',exact:true}).click();assert.equal(await page.locator('.nodo').count(),7);checks++;
  await page.getByRole('button',{name:'Resumen',exact:true}).click();assert.match(await page.locator('#resultadoEtiqueta').innerText(),/PRECIO CALCULADO/);checks++;
  await page.selectOption('#horizonte','60');assert.match(await page.locator('#objetivo').innerText(),/\d/);checks++;
  await page.locator('#exportar').click();assert.equal(JSON.parse(await page.evaluate(()=>window.exported)).market.asset,'BTC-USD');checks++;
  await page.selectOption('#activo','SPY');assert.equal(await page.inputValue('#horizonte'),'5');checks++;
  assert.equal(await page.locator('#candidato').innerText(),'—');checks++;
  await page.getByRole('button',{name:'Consultar ahora',exact:true}).click();await page.waitForFunction(()=>!document.getElementById('actualizar').disabled,{},{timeout:30000});
  const spy=JSON.parse(saved);assert.equal(spy.market.asset,'SPY');checks++;assert.equal(spy.stock_result.schema,'laplace-xn01-native-xi-v1');checks++;assert.equal(spy.stock_result.backend,'XI/Ether · NativeRuntime');checks++;
  assert.match(await page.locator('#candidato').innerText(),/SUBIDA|BAJADA/);checks++;assert.match(await page.locator('#interpretacion').innerText(),/XI\/Ether/);checks++;assert.equal(await page.locator('#estadoBits .bit').count(),4);checks++;
  assert.equal(await page.locator('[data-horizonte]').count(),0);checks++;
  await page.getByRole('button',{name:'Datos',exact:true}).click();const factorState=await page.evaluate(()=>({hidden:document.querySelector('#datos').hidden,asset:document.querySelector('#activo').value,status:document.querySelector('#datosEstado').textContent,children:document.querySelector('#factores').childElementCount,text:document.querySelector('#factores').textContent,candidate:document.querySelector('#candidato').textContent}));console.log('FACTOR_STATE='+JSON.stringify(factorState));assert.equal(factorState.hidden,false);assert.match(factorState.text,/Ensayo B001/);checks++;
  await page.getByRole('button',{name:'Registro',exact:true}).click();assert.equal(await page.locator('#registro').getAttribute('hidden'),null);assert.match(await page.locator('#registroEstado').textContent(),/Último ensayo reservado/);checks++;
  await page.getByRole('button',{name:'Flujo',exact:true}).click();assert.equal(await page.locator('.nodo').count(),5);checks++;
  await page.selectOption('#activo','BTC-USD');await page.getByRole('button',{name:'Registro',exact:true}).click();await page.locator('#leerRegistro').click();await page.waitForFunction(()=>!document.querySelector('#leerRegistro').disabled);assert.match(await page.locator('#registroEstado').innerText(),/pronósticos/);checks++;
  for(const [w,h] of [[1366,950],[390,844],[360,800],[844,390]]){
    await page.setViewportSize({width:w,height:h});
    for(const name of ['Resumen','Datos','Flujo','Registro']){await page.getByRole('button',{name,exact:true}).click();const size=await page.evaluate(()=>[document.documentElement.clientWidth,document.documentElement.scrollWidth]);if(size[1]>size[0]+1){const overflow=await page.evaluate(()=>[...document.querySelectorAll('body *')].map(el=>({tag:el.tagName,id:el.id,right:el.getBoundingClientRect().right,width:el.getBoundingClientRect().width})).filter(x=>x.right>document.documentElement.clientWidth+1));writeFileSync(join(out,'desbordamiento.json'),JSON.stringify({view:name,viewport:[w,h],size,overflow},null,2));await page.screenshot({path:join(out,'desbordamiento.png'),fullPage:true});}assert.ok(size[1]<=size[0]+1,name+': '+size);checks++;}
    await page.getByRole('button',{name:'Resumen',exact:true}).click();await page.screenshot({path:join(out,`panel-${w}.png`),fullPage:true});
  }
  fail=true;await page.selectOption('#activo','BTC-USD');await page.locator('#actualizar').click();await page.waitForFunction(()=>!document.getElementById('actualizar').disabled);assert.match(await page.locator('#aviso').innerText(),/inducido/);checks++;
  await page.locator('#volver').click();assert.equal(await page.evaluate(()=>window.didClose),true);checks++;assert.deepEqual(errors,[]);checks++;
  writeFileSync(join(out,'resultado.json'),JSON.stringify({checks,errors,browser:browser.version(),markets:['BTC-USD','SPY'],bridge:'synthetic'},null,2));console.log(JSON.stringify({checks,errors}));
 }finally{await context.close();await browser.close();await new Promise(ok=>server.close(ok));}
})().catch(e=>{console.error(e);process.exitCode=1;});
