import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {execFileSync} from 'node:child_process';import {rebind} from './rebind-library.mjs';
const [base,game]=process.argv.slice(2).map(p=>path.resolve(p));if(!game)throw Error('Usage: prepare-native.mjs RELEASED_X07_APK RELEASED_VELOCITY_03_APK');
const root=path.resolve(import.meta.dirname,'../..'),dest=path.join(root,'reverse-os-android/app/src/main/jniLibs'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
if(sha(fs.readFileSync(base))!=='3c7bb96c2af45a8bc52511ece0ecc47069dcc6b2ca6c7719fae1a6a7e86b707e')throw Error('Unexpected released desktop APK');
const result={desktop_apk_sha256:sha(fs.readFileSync(base)),velocity_apk_sha256:sha(fs.readFileSync(game)),velocity_source:'236513fc0870e5e07a5ff0eb2f1d2609e29328ce',jni:{}};
for(const abi of ['arm64-v8a','x86_64']){
 const target=path.join(dest,abi);fs.mkdirSync(target,{recursive:true});
 const primary=execFileSync('unzip',['-p',base,'lib/'+abi+'/libreverse_os.so'],{maxBuffer:16*1024*1024});fs.writeFileSync(path.join(target,'libreverse_os.so'),primary);
 const render=execFileSync('unzip',['-p',game,'lib/'+abi+'/libreverse_os.so'],{maxBuffer:16*1024*1024}),tmp=path.join(target,'render-input.so');fs.writeFileSync(tmp,render);
 const proof=rebind(tmp,path.join(target,'libregraphics.so'));fs.unlinkSync(tmp);result.jni[abi]={primary_sha256:sha(primary),regraphics_original_sha256:sha(render),...proof};
}
fs.writeFileSync(path.join(root,'integration/unified/native-lock.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({abis:Object.keys(result.jni),primary_unchanged:true,render_code_unchanged:true}));
