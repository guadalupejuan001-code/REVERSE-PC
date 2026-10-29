'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),vm=require('node:vm'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'../..');
const js=fs.readFileSync(path.join(root,'reverse-os-android/app/src/main/assets/workbench/bbyq-control.js'),'utf8');
const activity=fs.readFileSync(path.join(root,'reverse-os-android/app/src/main/java/com/reversepc/os/WorkbenchActivity.java'),'utf8');
const interfaceSrc=fs.readFileSync(path.join(root,'reverse-os-android/app/src/main/java/com/reversepc/os/BbyqInterface.java'),'utf8');
const store=fs.readFileSync(path.join(root,'reverse-os-android/app/src/main/java/com/reversepc/os/RxeAppStore.java'),'utf8');
const ctx=vm.createContext({Set,Map,JSON,Number,console});
ctx.mock={requests:[],response:{opened:true},error:null};
vm.runInContext(`
let state={windows:[],space:0,files:[]};
let activeId=null;
const programCatalog={apps:[]},programSessions=new Map();
function getWindow(){return null;}
function nativeRequest(operation,payload){
  mock.requests.push({operation,payload:JSON.parse(payload)});
  if(mock.error)return Promise.reject(mock.error);
  return Promise.resolve(mock.response);
}
function persist(){throw Error('URL open must not mutate desktop state');}
function restoreBbyqScene(){throw Error('No desktop rollback is needed for browser');}
function createWindow(){throw Error('No fake browser window');}
`,ctx);
vm.runInContext(js,ctx);
const evalx=s=>vm.runInContext(s,ctx);
let checks=0;
function yes(v,msg){assert.ok(v,msg);checks++;}
function no(v,msg){assert.ok(!v,msg);checks++;}
function action(op,target,view){const obs=evalx('captureBbyqDesktop("trusted")');const request={op,target,ticket:crypto.randomUUID(),view:view??obs.view};ctx.action=request;ctx.observation=obs;return evalx('executeBbyqControl(action,observation,"trusted")');}
(async()=>{
  yes(evalx('validBbyqAction({op:11,target:11})'),'website action explicitly allowed');
  for(const bad of [{op:11,target:10},{op:11,target:12},{op:12,target:11},{op:1,target:11},{op:10,target:11},{op:11,target:-1}]){
    ctx.candidate=bad;no(evalx('validBbyqAction(candidate)'),JSON.stringify(bad));
  }
  let r=await action(11,11);
  yes(r.success,'browser request must succeed on confirmed native result');
  assert.equal(ctx.mock.requests.length,1);checks++;
  assert.deepEqual(ctx.mock.requests[0],{operation:'openOfficialSite',payload:{service:'robinhood'}});checks++;
  no(evalx('state.windows.length'),'no fake REVERSE browser window');
  ctx.observation=evalx('captureBbyqDesktop("trusted")');
  ctx.action=ctx.action;
  r=await evalx('executeBbyqControl(action,observation,"trusted")');
  no(r.success,'ticket reuse should be rejected');checks++;
  assert.equal(ctx.mock.requests.length,1);checks++;
  const before=evalx('captureBbyqDesktop("trusted")');ctx.observation=before;
  ctx.action={op:11,target:11,ticket:crypto.randomUUID(),view:before.view};
  evalx('state.space=1');
  r=await evalx('executeBbyqControl(action,observation,"trusted")');
  no(r.success,'stale desktop view cannot launch');checks++;
  assert.equal(ctx.mock.requests.length,1);checks++;
  evalx('state.space=0');
  ctx.mock.response={opened:false};
  r=await action(11,11);
  no(r.success,'native opener refusal not falsely reported as success');checks++;
  ctx.mock.error=Error('No hay un navegador compatible.');
  r=await action(11,11);
  no(r.success,'browser launcher failure not silently swallowed');checks++;
  assert.equal(ctx.mock.requests.length,3);checks++;
  assert.match(activity,/Uri\.parse\("https:\/\/robinhood\.com\/"\)/);checks++;
  assert.match(activity,/!"robinhood"\.equals\(request\.optString\("service"\)\)/);checks++;
  assert.match(activity,/settings\.setBlockNetworkLoads\(true\)/);checks++;
  assert.match(activity,/startActivity\(chrome\)/);checks++;
  assert.match(interfaceSrc,/static ResultPacket tryOpenRobinhood\(/);checks++;
  assert.match(interfaceSrc,/op==11&&target==11/);checks++;
  assert.match(store,/BbyqInterface\.tryOpenRobinhood\(/);checks++;
  assert.match(store,/BbyqInterface\.robinhoodFeedback\(/);checks++;
  const report={checks,native_requests:ctx.mock.requests.length,approved_url:'https://robinhood.com/',
    allowed_action:{op:11,target:11},ui:'external Android browser, never privileged REVERSE WebView',
    note:'Host state machine tests use a stub for Android ACTION_VIEW. Real device launch requires Android test.'};
  const out=process.argv[2];
  if(out){fs.mkdirSync(path.dirname(path.resolve(out)),{recursive:true});fs.writeFileSync(out,JSON.stringify(report,null,2)+'\n');}
  console.log(JSON.stringify(report,null,2));
})().catch(err=>{console.error(err);process.exitCode=1;});
