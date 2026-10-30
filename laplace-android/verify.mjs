import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const lock=JSON.parse(readFileSync(root+'/laplace-android/integration-lock.json'));
if(lock.schema!==2)throw Error('Contrato Laplace obsoleto');
if(lock.upstream_m001!=='06ebce4bddf25d615cefd85ed24081f37504a492')throw Error('M001 no corresponde a la integración autorizada');
if(lock.upstream_bolsa!=='08cafb094a5c0f81253509eff412214dd526b808')throw Error('X001/B001 no corresponde a la integración autorizada');
for(const [p,h] of Object.entries(lock.files)){
 if(!resolve(root,p).startsWith(root+'/'))throw Error('Ruta inválida');
 if(createHash('sha256').update(readFileSync(resolve(root,p))).digest('hex')!==h)throw Error('Laplace ausente o sustituido: '+p);
}
const desktop=readFileSync(root+'/reverse-os-android/app/src/main/assets/workbench/desktop.js','utf8');
const activity=readFileSync(root+'/reverse-os-android/app/src/main/java/com/reversepc/os/WorkbenchActivity.java','utf8');
const manifest=readFileSync(root+'/reverse-os-android/app/src/main/AndroidManifest.xml','utf8');
const host=readFileSync(root+'/reverse-os-android/app/src/main/java/com/reversepc/os/LaplaceActivity.java','utf8');
const app=readFileSync(root+'/reverse-os-android/app/src/main/assets/laplace/app.mjs','utf8');
if(!desktop.includes("if(app==='laplace')")||!desktop.includes("'control','laplace'")||!activity.includes('void openLaplace()')||!manifest.includes('android:name=".LaplaceActivity"'))throw Error('Laplace no está conectado al escritorio Android');
if(!host.includes('case "stock"')||!host.includes('status==429')||!host.includes('Retry-After'))throw Error('Puente bursátil o control 429 ausente');
if(!app.includes("SPY:{")||!app.includes("AAPL:{")||!app.includes("NVDA:{")||!app.includes("liveX001"))throw Error('Interfaz bursátil X001 ausente');
if(lock.automatic_trading!==false||lock.native_XI_modified!==false)throw Error('El contrato no debe activar órdenes ni modificar XI');
console.log(JSON.stringify({valid:true,files:Object.keys(lock.files).length,upstreams:{m001:lock.upstream_m001,bolsa:lock.upstream_bolsa},models:lock.models,markets:['BTC-USD',...lock.stock_symbols],node_server_required_on_phone:false,http_429_backoff:true}));
