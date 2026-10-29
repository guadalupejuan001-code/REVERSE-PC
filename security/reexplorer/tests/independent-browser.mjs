#!/usr/bin/env node
// REexplorer is a standalone native REVERSE browser, not a BBY Q tool.
import fs from 'node:fs';
import assert from 'node:assert/strict';
const read=p=>fs.readFileSync(p,'utf8');
const store=read('reverse-os-android/app/src/main/java/com/reversepc/os/RxeAppStore.java');
const agent=read('reverse-os-android/app/src/main/java/com/reversepc/os/BbyqInterface.java');
const ui=read('reverse-os-android/app/src/main/assets/workbench/bbyq-control.js');
const host=read('reverse-os-android/app/src/main/java/com/reversepc/os/WorkbenchActivity.java');
const browser=read('reverse-os-android/app/src/main/java/com/reversepc/os/ReexplorerActivity.java');
const kernel=read('reverse-os-android/app/src/main/java/com/reversepc/os/ReexplorerQuantumCore.java');
let checks=0;
const yes=(v,label)=>{assert.ok(v,label);checks++;};
yes(!store.includes('BbyqInterface.tryOpenRobinhood('),'No BBY Q Robinhood command path');
yes(!agent.includes('tryOpenRobinhood('),'Agent cannot route a site');
yes(!ui.includes('op===11'),'No BBY Q browser action');
yes(!ui.includes("'openOfficialSite'"),'UI never dispatches agent website action');
yes(!host.includes('"openOfficialSite".equals(operation)'),'No bridge action for BBY Q website');
yes(host.includes('"openReexplorer".equals(operation)'),'Manual REVERSE browser launch retained');
yes(browser.includes('new ReexplorerQuantumCore('),'Browser initializes own XI kernel');
yes(kernel.includes('NativeRuntime.initialize()'),'Browser creates independent RVPC2 state');
yes(!kernel.includes('BbyqInterface')&&!kernel.includes('RxeAppStore'),'Kernel isolated from BBY Q');
yes(kernel.includes('"reexplorer/navigation-core.xi"'),'Native Q-Core source shipped');
yes(browser.includes('shouldOverrideUrlLoading'),'Real browser handles navigation');
yes(browser.includes('allowNavigationByXi'),'Every explicit navigation runs through XI');
yes(browser.includes('page.loadUrl(destination)'),'Browser actually loads web documents');
yes(browser.includes('WebView.setDataDirectorySuffix("reexplorer")'),'Separate WebView data');
yes(!browser.includes('addJavascriptInterface('),'No browser bridge to REVERSE');
yes(browser.includes('handler.cancel()'),'TLS exception never overridden');
const result={suite:'REexplorer independent browser',checks,agent_browser_dispatch:false,
  rvpc2:'fresh isolated XI state',web_rendering:'Android System WebView (maintained)',
  note:'Does not prove live Robinhood compatibility or physical quantum computation'};
const output=process.argv[2];
if(output){fs.mkdirSync((await import('node:path')).dirname(output),{recursive:true});fs.writeFileSync(output,JSON.stringify(result,null,2)+'\n');}
console.log(JSON.stringify(result,null,2));
