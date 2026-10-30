/* Chrome real with an explicitly synthetic Android IO bridge; never a market
 * accuracy test. Production adapter and APK receive separate compile/device checks. */
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
 const end=Math.floor(Date.now()/300000)*300,start=end-14*86400;let v=80000;
 const bars=Array.from({length:4032},(_,i)=>{const o=v;v*=Math.exp(.0005*Math.sin(i/7)-.00001);return [start+i*300,Math.min(o,v)*.9998,Math.max(o,v)*1.0002,o,v,10+i%20]});
 await context.exposeFunction('auditIO',async(operation,raw)=>{
  const p=JSON.parse(raw);calls.push({operation,p});
  if(operation==='read')return {ok:true,text:saved};
  if(operation==='save'){saved=raw;return {ok:true};}
  if(operation!=='public')return {ok:false,error:'Operación desconocida'};
  if(fail&&p.source==='candles')return {ok:false,error:'Fallo de fuente inducido'};
  await new Promise(ok=>setTimeout(ok,30));let value;
  if(p.source==='candles')value=bars.filter(b=>b[0]>=p.params.start&&b[0]<=p.params.end);
  else if(p.source==='ticker')value={price:String(v),time:new Date().toISOString()};
  else if(p.source==='book')value={bids:Array.from({length:12},(_,i)=>[String(v-1-i),'1',1]),asks:Array.from({length:12},(_,i)=>[String(v+1+i),'2',1])};
  else if(p.source==='trades')value=[{side:'buy',size:'.1'}];
  else if(p.source==='noaa')value=[{time_tag:new Date(Date.now()-3600000).toISOString().slice(0,19),Kp:1}];
  else if(p.source==='registro')value={schema:'laplace-resumen-m001',actualizado_en:new Date().toISOString(),pronosticos:2,evaluados:1,por_horizonte:[],ultimos:[{horizonte_minutos:15,objetivo_en:new Date().toISOString(),precio_predicho:80000,resultado:{acierto_precio:false,error_absoluto_usd:100}},{horizonte_minutos:60,objetivo_en:new Date().toISOString(),precio_predicho:79000,estado:'pendiente',resultado:null}]};
  else value={price:'2500',time:new Date().toISOString()};
  return {ok:true,text:JSON.stringify(value),received_at:new Date().toISOString()};
 });
 await context.addInitScript(()=>{window.LaplaceNative={request(id,op,payload){window.auditIO(op,payload).then(r=>window.LaplaceHost.complete(id,r));},export(payload){window.exported=payload;},close(){window.didClose=true;}};});
 const page=await context.newPage();page.on('pageerror',e=>errors.push(e.message));
 const root='http://127.0.0.1:'+server.address().port;
 try{
  await page.goto(root);await page.waitForTimeout(250);assert.equal(await page.locator('#precio').innerText(),'—');checks++;
  assert.equal(calls.filter(c=>c.operation==='public').length,0);checks++;
  await page.getByRole('button',{name:'Calcular y consultar',exact:true}).click();
  await page.waitForFunction(()=>document.querySelector('[data-node="candles"]').dataset.estado==='consultando'||document.querySelector('[data-node="candles"]').dataset.estado==='recibida');
  await page.getByRole('button',{name:'Consulta 3D',exact:true}).click();
  assert.equal(await page.locator('.nodo').count(),7);checks++;
  await page.waitForFunction(()=>!document.getElementById('actualizar').disabled,{},{timeout:30000});
  assert.ok(saved,'snapshot not persisted');assert.equal(await page.locator('#aviso').isVisible(),false);checks++;
  const snapshot=JSON.parse(saved);assert.equal(snapshot.predictions.length,6);checks++;
  assert.equal(snapshot.bars.length,4032);checks++;
  await page.selectOption('#horizonte','60');await page.getByRole('button',{name:'Resumen',exact:true}).click();
  const selected=snapshot.predictions.find(p=>p.horizonte_minutos===60);
  assert.equal(await page.locator('#candidato').innerText(),new Intl.NumberFormat('es-MX',{style:'currency',currency:'USD',maximumFractionDigits:2}).format(selected.precio_predicho));checks++;
  assert.equal(await page.locator('[data-horizonte]').getAttribute('data-horizonte'),'60');checks++;
  assert.equal(Number(await page.locator('[data-precio-origen]').getAttribute('data-precio-origen')),selected.precio_inicial);checks++;
  await page.selectOption('#horizonte','10080');assert.match(await page.locator('#soporte').innerText(),/Soporte escaso/);checks++;
  await page.locator('#exportar').click();assert.deepEqual(JSON.parse(await page.evaluate(()=>window.exported)),snapshot);checks++;
  await page.reload();await page.waitForFunction(()=>document.querySelector('#precio').textContent!=='—');assert.equal(await page.locator('#aviso').isVisible(),false);checks++;
  await page.getByRole('button',{name:'Elegir datos',exact:true}).click();
  await page.locator('[data-source="eth"]').uncheck();assert.equal(await page.locator('#factores article').count(),2);checks++;
  await page.getByRole('button',{name:'Registro horario',exact:true}).click();await page.locator('#leerRegistro').click();
  await page.waitForFunction(()=>!document.querySelector('#leerRegistro').disabled);assert.equal(await page.locator('#filas tr').count(),1);checks++;
  await page.selectOption('#filtro','fallos');assert.match(await page.locator('#filas').innerText(),/Fallo de precio/);checks++;
  await page.selectOption('#horizonte','60');await page.selectOption('#filtro','pendientes');assert.match(await page.locator('#filas').innerText(),/Pendiente/);checks++;
  await page.getByRole('button',{name:'Resumen',exact:true}).click();
  for(const [w,h] of [[1366,950],[390,844],[360,800],[844,390]]){
   await page.setViewportSize({width:w,height:h});
   for(const name of ['Resumen','Elegir datos','Consulta 3D','Registro horario']){
    await page.getByRole('button',{name,exact:true}).click();
    const size=await page.evaluate(()=>[document.documentElement.clientWidth,document.documentElement.scrollWidth]);assert.ok(size[1]<=size[0]+1,name+': '+size);checks++;
   }
   await page.getByRole('button',{name:'Resumen',exact:true}).click();await page.screenshot({path:join(out,`panel-${w}.png`),fullPage:true});
  }
  await page.getByRole('button',{name:'Consulta 3D',exact:true}).click();await page.screenshot({path:join(out,'consulta-3d.png'),fullPage:true});
  const old=saved;fail=true;await page.locator('#actualizar').click();await page.waitForFunction(()=>!document.getElementById('actualizar').disabled);
  assert.equal(saved,old);assert.match(await page.locator('#aviso').innerText(),/inducido/);checks++;
  await page.locator('#volver').click();assert.equal(await page.evaluate(()=>window.didClose),true);checks++;
  assert.deepEqual(errors,[]);checks++;
  writeFileSync(join(out,'resultado.json'),JSON.stringify({checks,errors,android_bridge:'simulado, no prueba de dispositivo',model:'M001 original adaptado a WebCrypto',source_data:'sintéticos',browser:browser.version()},null,2));
  console.log(JSON.stringify({checks,errors}));
 }finally{await context.close();await browser.close();await new Promise(ok=>server.close(ok));}
})().catch(e=>{console.error(e);process.exitCode=1;});
