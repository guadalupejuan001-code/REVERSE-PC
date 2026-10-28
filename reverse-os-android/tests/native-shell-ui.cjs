const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {chromium}=require('playwright');
const root=path.resolve(__dirname,'../..'),[runtime,buildArg,probeArg,outArg]=process.argv.slice(2),build=path.resolve(buildArg),probe=path.resolve(probeArg),out=path.resolve(outArg);
const nativeHost=require('./native-host-fixture.cjs');fs.mkdirSync(out,{recursive:true});
const executablePath=process.env.REVERSE_BROWSER;if(executablePath)fs.chmodSync(executablePath,0o755);
let checks=0;const layouts=[],errors=[];
function check(value,message){assert.ok(value,message);checks++;}
async function open(width,height,label){
  const host=nativeHost({root,build,runtime,probe,directory:path.join(out,label)});
  const browser=await chromium.launch({headless:true,executablePath,args:['--no-sandbox','--no-zygote','--single-process','--disable-gpu','--disable-software-rasterizer']});
  const page=await browser.newPage({viewport:{width,height},locale:'es-ES',timezoneId:'America/New_York'});page.setDefaultTimeout(20000);
  page.on('pageerror',error=>errors.push({label,error:error.message}));
  await page.exposeFunction('__reverseNative',async(operation,payload)=>{try{return await host.request(operation,payload);}catch(error){return {ok:false,error:error.message};}});
  await page.addInitScript(profile=>{window.ReverseNative={loadProfile:()=>JSON.stringify({ok:true,profile}),request(id,operation,payload){window.__reverseNative(operation,payload).then(result=>window.ReverseAndroid.complete(id,result));},exportText(){},exportBase64(){}};},null);
  await page.goto('file://'+path.join(root,'reverse-os-android/app/src/main/assets/workbench/index.html'));
  await page.waitForFunction(()=>window.ReverseShell&&typeof androidSnapshot!=='undefined'&&!!androidSnapshot);
  await page.waitForTimeout(100);
  return {browser,page,host};
}
(async()=>{
 for(const [width,height] of [[360,780],[390,844],[412,915],[768,900],[1024,768],[1440,900]]){
  const {browser,page}=await open(width,height,'layout-'+width);
  check(await page.locator('.home-app').count()===4,'Four coherent primary tools');
  check(await page.locator('.topbar').isVisible(),'Visible system header');
  check(await page.locator('.core-capacity strong').first().innerText()==='4096','Verified capacity');
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No horizontal viewport overflow');
  check(!/Hazlo tuyo|Infinitas formas|Un espacio por construir/.test(await page.locator('body').innerText()),'No template copy');
  for(const item of await page.locator('.home-app').all()){const box=await item.boundingBox();check(box.width>=44&&box.height>=44,'Touch target');}
  check(await page.locator('#mobile-navigation').isVisible()===(width<=760),'Responsive navigation');
  await page.screenshot({path:path.join(out,'home-'+width+'.png')});layouts.push({width,height,horizontal_overflow:false});
  await browser.close();
 }
 const {browser,page,host}=await open(390,844,'interactive-mobile');
 const legacyProfile=JSON.parse(fs.readFileSync(path.join(__dirname,'fixtures/workbench-2.3-profile.json'),'utf8'));
 const cleanProfiles=await page.evaluate(profile=>{
   const plain=validateState(structuredClone(profile));
   const renamed=structuredClone(profile);renamed.files.find(f=>f.id==='welcome').name='Mi documento.txt';
   const moved=structuredClone(profile);moved.files.find(f=>f.id==='ideas').parent='personal';
   const trashed=structuredClone(profile);trashed.files.find(f=>f.id==='quick').trashRoot='quick';
   return {stock:plain.files.length,renamed:validateState(renamed).files.some(f=>f.id==='welcome'),moved:validateState(moved).files.some(f=>f.id==='ideas'),trashed:validateState(trashed).files.some(f=>f.id==='quick')};
 },legacyProfile);
 check(cleanProfiles.stock===3,'Only untouched template documents retire');check(cleanProfiles.renamed&&cleanProfiles.moved&&cleanProfiles.trashed,'Renamed/moved/trashed documents are retained');
 const retained=await page.evaluate(()=>{
   const base=seedState();base.files.push({id:'quick',parent:'personal',type:'text',name:'Mi nota.txt',content:'Mi nota personal',date:Date.now()});
   const imported=validateState(base);
   base.windows=[{id:'w-malicious',app:'xi',space:0,hamiltonian:{coupling:'" autofocus onfocus=alert(1) x="',field:1,steps:1},quantumResult:{kind:'ising',output:'',parameters:{coupling:'bad'},core:{active_qubits:2,components:'<img src=x>'}}}];
   const safe=validateState(base);
   return {note:imported.files.find(f=>f.id==='quick')?.content,coupling:safe.windows[0].hamiltonian.coupling,components:safe.windows[0].quantumResult.core.components};
 });
 check(retained.note==='Mi nota personal','User notes survive cleanup');check(retained.coupling===1&&retained.components===0,'Imported experiment fields are sanitized');
 await page.locator('.home-app[data-open="programs"]').click();await page.waitForSelector('.program-card');
 const box=await page.locator('.window.focused').boundingBox(),nav=await page.locator('#mobile-navigation').boundingBox();
 check(box.x===0&&box.width===390&&Math.round(box.y+box.height)<=Math.round(nav.y),'Phone uses full application surface');
 check(await page.locator('.window.focused [data-window-action="max"]').isVisible()===false,'No desktop maximization controls on phone');
 await page.locator('.window.focused .mobile-back').click();check(await page.locator('body').getAttribute('data-shell-surface')==='home','Back to home');
 await page.locator('#mobile-navigation [data-open="bbyq"]').click();await page.waitForSelector('[data-program-input]');
 await page.locator('[data-program-input]').fill('ejecuta programa 1');await page.locator('[data-program-form] [type="submit"]').click();
 await page.waitForFunction(()=>state.windows.some(w=>w.rxePath==='Aplicaciones/Prueba.rxe')&&[...programSessions.values()].some(p=>p.snapshot?.history?.at(-1)?.text==='Acción completada.'));
 check(host.stats().runs===1,'W4u really executed the internal RXE once');
 check(host.stats().history.at(-1).text==='Acción completada.','Native result acknowledged');
 await page.locator('#mobile-navigation [data-open="bbyq"]').click();await page.waitForSelector('[data-program-input]');
 await page.screenshot({path:path.join(out,'bbyq-mobile.png')});
 await page.evaluate(()=>{document.body.dataset.keyboard='true';});await page.setViewportSize({width:390,height:500});
 check(!(await page.locator('#mobile-navigation').isVisible()),'Keyboard hides navigation');
 const composer=await page.locator('.rxe-composer').boundingBox();check(composer.y+composer.height<=501,'Composer remains inside the viewport');
 await page.evaluate(()=>{document.body.dataset.keyboard='false';});await page.setViewportSize({width:390,height:844});
 await page.waitForTimeout(350);await page.reload();await page.waitForTimeout(350);check(host.stats().runs===1,'Restoring does not replay commands');
 await page.evaluate(()=>window.ReverseShell.back());await page.locator('.home-app[data-open="xi"]').click();await page.locator('[data-quantum-tab="hamiltonian"]').click();
 const before=host.sessionHash();await page.locator('[data-quantum-run="ising"]').click();await page.waitForSelector('.energy-reading strong');
 check(await page.locator('.quantum-result-meta').innerText().then(s=>s.includes('2 qubits activos')),'Hamiltonian used real two-qubit state');
 check(host.sessionHash()===before,'Hamiltonian experiment preserves work state');
 await page.screenshot({path:path.join(out,'hamiltonian-mobile.png')});
 await page.locator('[data-quantum-tab="quantum"]').click();await page.locator('[data-quantum-run="register"]').click();
 await page.waitForFunction(()=>getWindow(activeId)?.quantumResult?.core?.active_qubits===4096);
 check(host.sessionHash()===before,'4096-qubit experiment preserves work state');
 check(await page.locator('.quantum-result-meta').innerText().then(s=>s.includes('4096 qubits activos')),'Actual 4096-qubit result shown');
 await page.screenshot({path:path.join(out,'register-mobile.png')});
 await page.locator('#mobile-navigation [data-shell-action="recent"]').click();check(await page.locator('#recent-panel').isVisible(),'Recent applications are accessible');
 await browser.close();
 const desktop=await open(1440,900,'interactive-desktop');
 await desktop.page.locator('.home-app[data-open="files"]').click();const old=await desktop.page.locator('.window.focused').boundingBox();check(old.width<1200&&old.width>500,'Desktop keeps movable windows');
 await desktop.page.mouse.move(old.x+140,old.y+20);await desktop.page.mouse.down();await desktop.page.mouse.move(old.x+210,old.y+65,{steps:5});await desktop.page.mouse.up();const moved=await desktop.page.locator('.window.focused').boundingBox();check(moved.x>old.x+40,'Desktop window can be dragged');
 await desktop.page.setViewportSize({width:390,height:844});await desktop.page.waitForTimeout(100);const narrow=await desktop.page.locator('.window.focused').boundingBox();check(narrow.width===390,'Desktop session adapts to phone');
 await desktop.page.setViewportSize({width:1440,height:900});await desktop.page.waitForTimeout(100);const restored=await desktop.page.locator('.window.focused').boundingBox();check(restored.width===moved.width,'Desktop window size is preserved across phone layout');
 await desktop.page.screenshot({path:path.join(out,'desktop-windows.png')});await desktop.browser.close();
 check(errors.length===0,JSON.stringify(errors));
 const report={checks,layouts,actual_internal_program_runs:host.stats().runs,actual_isolated_experiments:host.stats().experiments,page_errors:errors,scope:'Chromium viewport/interaction checks, transport fixtures and real XI/RXE backend. No Android device/emulator was used.'};
 fs.writeFileSync(path.join(out,'results.json'),JSON.stringify(report,null,2)+'\n');console.log('NATIVE_SHELL_UI_PASS',checks);
})().catch(e=>{console.error(e.stack);console.error('PAGE_ERRORS',JSON.stringify(errors));process.exitCode=1;});
