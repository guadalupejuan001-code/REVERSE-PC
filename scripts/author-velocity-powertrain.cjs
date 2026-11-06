'use strict';
const fs=require('node:fs'),path=require('node:path'),pt=require('./velocity-powertrain.cjs');
const root=path.join(__dirname,'../reverse-os-android/app/src/main/assets/velocity');
function section(source,name,body,anchor){
 const begin='# BEGIN C01 '+name,end='# END C01 '+name;
 const block=begin+'\n'+body+'\n'+end;
 if(source.includes(begin))return source.slice(0,source.indexOf(begin))+block+source.slice(source.indexOf(end)+end.length);
 if(!source.includes(anchor))throw Error('Missing powertrain authoring anchor '+name);
 return source.replace(anchor,(anchor.startsWith('\n')?'\n':'')+block+'\n'+anchor);
}
let drive=fs.readFileSync(path.join(root,'drive.xi'),'utf8');
drive=section(drive,'INITIALIZE',pt.INITIAL,'# BEGIN V23 RIG INITIALIZE');
if(!drive.includes('# BEGIN C01 FORCE')){
 const start=drive.indexOf('load8 r0 128\nmul r0 1100'),end=drive.indexOf('set r1 60',start);
 if(start<0||end<0)throw Error('Original powertrain block missing');
 drive=drive.slice(0,start)+'# BEGIN C01 FORCE\n'+pt.forceXi()+'\n# END C01 FORCE\n'+drive.slice(end);
}else drive=section(drive,'FORCE',pt.forceXi(),'');
for(const [name,source] of [['drive.xi',drive],['environment.xi',fs.readFileSync(path.join(root,'environment.xi'),'utf8')]]){
 const updated=section(source,'TELEMETRY',pt.TELEMETRY,'\nhalt\n');
 fs.writeFileSync(path.join(root,name),updated);
}
console.log('VELOCITY_POWERTRAIN_AUTHOR_PASS gears=6 telemetry=38');
