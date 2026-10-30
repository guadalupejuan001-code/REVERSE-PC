import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
const [legacy,previousApk,modern,velocity]=process.argv.slice(2).map(p=>path.resolve(p));
if(!velocity)throw Error('Usage: import-sources.mjs LEGACY_ROOT PREVIOUS_APK MODERN_ROOT VELOCITY_ROOT');
const root=path.resolve(import.meta.dirname,'../..');
const android='reverse-os-android',main=android+'/app/src/main';
const cp=(from,to)=>{fs.mkdirSync(path.dirname(to),{recursive:true});fs.cpSync(from,to,{recursive:true});};
cp(path.join(legacy,android),path.join(root,android));
for(const name of ['apps','security'])if(fs.existsSync(path.join(legacy,name)))cp(path.join(legacy,name),path.join(root,name));
// Restore the exact generated assets of the already delivered X07 APK.
execFileSync('unzip',['-qo',previousApk,'assets/*','-d',path.join(root,main)]);
for(const name of ['LaplaceActivity.java','LaplaceGlobalCompiler.java','LaplaceXiCompiler.java'])cp(path.join(modern,main,'java/com/reversepc/os',name),path.join(root,main,'java/com/reversepc/os',name));
cp(path.join(modern,main,'assets/laplace'),path.join(root,main,'assets/laplace'));
for(const name of ['VelocityActivity.java','VelocityXiEngine.java','VelocityXSurface.java','VelocityLoopLifecycle.java','RegraphicsFrame.java'])cp(path.join(velocity,main,'java/com/reversepc/os',name),path.join(root,main,'java/com/reversepc/os',name));
cp(path.join(velocity,main,'assets/velocity'),path.join(root,main,'assets/velocity'));
// A separate binding keeps the released BBY/PRISMA JNI ABI unchanged.
let transport=fs.readFileSync(path.join(velocity,main,'java/com/reversepc/os/NativeRuntime.java'),'utf8').replaceAll('NativeRuntime','RenderRuntime').replace('loadLibrary("reverse_os")','loadLibrary("regraphics")');
fs.writeFileSync(path.join(root,main,'java/com/reversepc/os/RenderRuntime.java'),transport);
for(const name of ['VelocityXiEngine.java','VelocityActivity.java']){
 const p=path.join(root,main,'java/com/reversepc/os',name);fs.writeFileSync(p,fs.readFileSync(p,'utf8').replaceAll('NativeRuntime.','RenderRuntime.'));
}
// Superset packet transport: retain atomic-history encoding and binary XFS1.
const packet=path.join(root,main,'java/com/reversepc/os/ResultPacket.java');
const prior=fs.readFileSync(packet,'utf8'),next=fs.readFileSync(path.join(velocity,main,'java/com/reversepc/os/ResultPacket.java'),'utf8');
const start=prior.indexOf('    public static byte[] encode('),end=prior.indexOf('    public static ResultPacket parse(',start);
fs.writeFileSync(packet,next.includes('public static byte[] encode(')?next:next.replace('    public static ResultPacket parse(',prior.slice(start,end)+'    public static ResultPacket parse('));
console.log('Imported released desktop, X07 Android transport, current Laplace and REgraphics/Velocity source.');
