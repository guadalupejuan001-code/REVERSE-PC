'use strict';
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const vm=require('node:vm');
const root=path.resolve(__dirname,'../..');
const assets=path.join(root,'reverse-os-android/app/src/main/assets/workbench');
const browser=fs.readFileSync(path.join(assets,'reexplorer.js'),'utf8');
const html=fs.readFileSync(path.join(assets,'index.html'),'utf8');
const desktop=fs.readFileSync(path.join(assets,'desktop.js'),'utf8');
const shortcuts=fs.readFileSync(path.join(assets,'control-center.js'),'utf8');
const art=fs.readFileSync(path.join(assets,'app-icons.js'),'utf8');
let checks=0;
function yes(condition,label){assert.ok(condition,label);checks++;}
function contains(s,t,label){yes(s.includes(t),label);}

contains(html,'src="reexplorer.js"','Browser JS loaded');
contains(html,'href="reexplorer.css"','Browser CSS loaded');
contains(desktop,"reexplorer:{name:'REexplorer'","Real desktop app registered");
contains(desktop,"if(w.app==='reexplorer')body.innerHTML=reexplorerHTML(w)","Desktop render route");
contains(shortcuts,"'reexplorer'","Launcher entry");
contains(art,'reexplorer:{colors:','Artwork not generic icon');
contains(browser,'https://robinhood.com/','Official starting page');
contains(browser,"nativeRequest('openReexplorer',JSON.stringify({url:value}))",
  'Manual launch uses typed native action');
yes(!browser.includes('iframe'), 'Privileged shell must not embed remote sites');
yes(!browser.includes('addJavascriptInterface'),'No browser bridge in launcher');
const calls=[];
const fakeForm={
  closest(){return {querySelector(){return {textContent:''};}};},
  querySelectorAll(){return [{disabled:false},{disabled:false}]}
};
const context=vm.createContext({
  document:{addEventListener(){}},
  icon(){return '[globe]';},
  nativeAvailable:true,
  nativeRequest(op,payload){calls.push({op,payload:JSON.parse(payload)});return Promise.resolve({opened:true});},
  console
});
vm.runInContext(browser,context);
context.form=fakeForm;
const panel=vm.runInContext('reexplorerHTML()',context);
contains(panel,'REexplorer','Own app title');
contains(panel,'Ether Guard','Security framing');
yes(!panel.includes('<iframe'), 'No browser content in privileged shell');
(async()=>{
  await vm.runInContext("openReexplorerFromDesktop(form,'https://robinhood.com/')",context);
  assert.equal(JSON.stringify(calls),JSON.stringify([
    {op:'openReexplorer',payload:{url:'https://robinhood.com/'}}
  ]));checks++;
  context.nativeAvailable=false;
  await vm.runInContext("openReexplorerFromDesktop(form,'https://example.org/')",context);
  yes(calls.length===1,'Web-only preview cannot navigate with Android privileges');
  const report={suite:'REexplorer desktop binding',checks,
    app:'REexplorer',desktop_content:'native launch only',network_source:'isolated Android activity'};
  const output=process.argv[2];
  if(output){fs.mkdirSync(path.dirname(path.resolve(output)),{recursive:true});
    fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');}
  console.log(JSON.stringify(report,null,2));
})().catch(e=>{console.error(e);process.exitCode=1;});
