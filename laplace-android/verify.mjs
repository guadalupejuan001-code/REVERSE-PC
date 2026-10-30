import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const lock=JSON.parse(readFileSync(root+'/laplace-android/integration-lock.json'));
if(lock.schema!==3)throw Error('Contrato Laplace obsoleto');
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
const compiler=readFileSync(root+'/reverse-os-android/app/src/main/java/com/reversepc/os/LaplaceXiCompiler.java','utf8');
const xi=readFileSync(root+'/reverse-os-android/app/src/main/assets/laplace/x001-native.xi','utf8');
const app=readFileSync(root+'/reverse-os-android/app/src/main/assets/laplace/app.mjs','utf8');
if(!desktop.includes("if(app==='laplace')")||!desktop.includes("'control','laplace'")||!activity.includes('void openLaplace()')||!manifest.includes('android:name=".LaplaceActivity"'))throw Error('Laplace no está conectado al escritorio Android');
if(!host.includes('case "stock"')||!host.includes('status==429')||!host.includes('Retry-After'))throw Error('Puente bursátil o control 429 ausente');
if(!host.includes('"native_x001"')||!host.includes('LaplaceXiCompiler.compile')||!host.includes('NativeRuntime.execute'))throw Error('XN01 no está conectado al runtime nativo Android');
if(!compiler.includes('laplace-xn01-native-xi-v1')||!compiler.includes('STATE_VALID_BASE')||!compiler.includes('LABEL_VALID_BASE'))throw Error('Compilador XN01 incompatible');
if(!xi.startsWith('#!reverse-pc-machine-v1\n')||!xi.includes('# LAPLACE XN01')||!xi.includes('mem_stats')||!xi.includes('qstats'))throw Error('Plantilla XN01/XI incompatible');
if(!app.includes("SPY:{")||!app.includes("AAPL:{")||!app.includes("NVDA:{")||!app.includes("host('native_x001'"))throw Error('Interfaz bursátil nativa XN01 ausente');
if(lock.stock_model!=='XN01-native-XI'||lock.native_XI_used_for_stock_prediction!==true)throw Error('Contrato bursátil no exige XN01 nativo');
if(lock.automatic_trading!==false||lock.native_XI_modified!==false)throw Error('El contrato no debe activar órdenes ni modificar XI');
console.log(JSON.stringify({valid:true,files:Object.keys(lock.files).length,upstreams:{m001:lock.upstream_m001,bolsa:lock.upstream_bolsa},models:lock.models,stock_model:lock.stock_model,markets:['BTC-USD',...lock.stock_symbols],native_stock:true,node_server_required_on_phone:false,http_429_backoff:true}));
