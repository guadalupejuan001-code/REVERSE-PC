'use strict';
// Contract audit only: this DOES NOT prove the future BBY Q -> w4U -> QdU
// task delegation is already implemented. It locks visible identity and
// technical backward compatibility while recording the missing delegation.
const fs=require('node:fs');
const path=require('node:path');
const assert=require('node:assert/strict');
const base=path.resolve(__dirname,'../../');
const read=p=>fs.readFileSync(path.join(base,p),'utf8');
const contract=read('docs/BBYQ_W4U_QDU_CONTRACT.md');
const ui=read('reverse-os-android/app/src/main/assets/workbench/qd-studio.js');
const desktop=read('reverse-os-android/app/src/main/assets/workbench/desktop.js');
const engine=read('reverse-os-android/app/src/main/java/com/reversepc/os/QdEngine.java');
const orders=read('reverse-os-android/app/src/main/java/com/reversepc/os/QdOrders.java');
const appStore=read('reverse-os-android/app/src/main/java/com/reversepc/os/RxeAppStore.java');
const w4u=read('docs/W4U_BBYQ.md');
const checks=[
 ['canonical three-role labels',()=>{for(const role of ['BBY Q','w4U','QdU'])assert.ok(contract.includes(role));}],
 ['role boundaries',()=>{
    assert.match(contract,/inteligencia principal|Inteligencia principal/i);
    assert.match(contract,/orquestador/i);
    assert.match(contract,/especialidad programadora/i);
    assert.match(contract,/no.*un.*(segundo|otra).*IA|no.*otra IA|sin un nuevo modelo/i);
 }],
 ['visible ReverseCoding identity',()=>{
    assert.match(ui,/ReverseCoding <span>· QdU<\/span>/);
    assert.match(ui,/BBY Q \/ w4U \/ QdU/);
    assert.doesNotMatch(ui,/ReverseCoding <span>· Qd<\/span>/);
 }],
 ['preserve existing UI identifiers',()=>{
    assert.match(desktop,/qd:\{name:'ReverseCoding'/);
    assert.match(ui,/nativeRequest\('qd'/);
    assert.match(desktop,/qdDrafts:Object\.fromEntries/);
 }],
 ['preserve XI/Ether sandbox and agent state authority',()=>{
    assert.match(orders,/NativeRuntime\.initialize\(\)/);
    assert.match(engine,/new RxeAppStore\(context,bbyq\)/);
    assert.match(engine,/8400000000000000000L/);
    assert.match(engine,/8410000000000000000L/);
    assert.match(w4u,/RVPC2|memoria privada/);
    assert.match(appStore,/writer\.lock/);
 }],
 ['direct Qd UI route correctly recorded as unfinished',()=>{
    assert.match(contract,/qd-studio\.js.*nativeRequest\('qd'\).*WorkbenchPrograms\.qd.*QdEngine\.handle/);
    assert.match(contract,/FALTA LA CONEXIÓN/);
    assert.match(contract,/no.*flujo demostrado/);
 }],
 ['separate workspace and irreversible effects',()=>{
    assert.match(contract,/w4U.*(acciones|autoriza|permiso)/i);
    assert.match(contract,/sin persistencia|temporal/i);
 }],
];
for(const [name,test] of checks){try{test();}catch(e){throw new Error('Contract check failed: '+name+'; '+e.message)}}
console.log('TRIAD_CONTRACT_OK '+JSON.stringify({
 roles:['BBY Q','w4U','QdU'],assertions:checks.length,
 qdu_legacy_identifier:'qd',w4u_runtime_unchanged:true,
 xi_backend_unchanged:true,delegation_over_w4u_implemented:false,
 verification_scope:'static+UI name; not a runtime delegation test'
}));
