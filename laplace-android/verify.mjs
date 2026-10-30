import {readFileSync,writeFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const lock=JSON.parse(readFileSync(root+'/laplace-android/integration-lock.json'));
if(lock.upstream!=='06ebce4bddf25d615cefd85ed24081f37504a492')throw Error('Laplace no corresponde a la integración autorizada');
for(const [p,h] of Object.entries(lock.files)){
 if(!resolve(root,p).startsWith(root+'/'))throw Error('Ruta inválida');
 if(createHash('sha256').update(readFileSync(resolve(root,p))).digest('hex')!==h)throw Error('Laplace ausente o sustituido: '+p);
}
const desktop=readFileSync(root+'/reverse-os-android/app/src/main/assets/workbench/desktop.js','utf8');
const activity=readFileSync(root+'/reverse-os-android/app/src/main/java/com/reversepc/os/WorkbenchActivity.java','utf8');
const manifest=readFileSync(root+'/reverse-os-android/app/src/main/AndroidManifest.xml','utf8');
if(!desktop.includes("if(app==='laplace')")||!desktop.includes("'control','laplace'")||!activity.includes('void openLaplace()')||!manifest.includes('android:name=".LaplaceActivity"'))throw Error('Laplace no está conectado al escritorio Android');
console.log(JSON.stringify({valid:true,files:Object.keys(lock.files).length,upstream:lock.upstream,model:'M001',node_server_required_on_phone:false}));
