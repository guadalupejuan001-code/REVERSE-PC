// Refuse an APK build which silently omitted or overwrote the personal module.
import fs from'node:fs';import path from'node:path';import crypto from'node:crypto';
const dir=path.resolve(process.argv[2]||'reverse-os-android/app/src/main/assets'),hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const p=JSON.parse(fs.readFileSync(path.join(dir,'bbyq-interface/manifest.json'))).personalization;
if(p?.version!=='X01'||p.schema!==1||p.lessons!==59||p.upgrade_file!=='upgrade-x01.rxe')throw Error('X01 required in this APK');
if(hash(path.join(dir,'native-apps/BBY-Q.rxe'))!==p.executable_sha256||hash(path.join(dir,'bbyq-interface/upgrade-x01.rxe'))!==p.upgrade_sha256)throw Error('APK personal module is missing or was replaced');
console.log(JSON.stringify({personalization:'X01',verified:true,app_sha256:p.executable_sha256}));
