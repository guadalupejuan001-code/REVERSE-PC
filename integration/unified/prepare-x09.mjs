import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import zlib from 'node:zlib';
const root=path.resolve(import.meta.dirname,'../..'),assets=path.join(root,'reverse-os-android/app/src/main/assets'),dir=path.join(assets,'bbyq-x09');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex'),read=n=>JSON.parse(fs.readFileSync(path.join(dir,n)));
const m=read('build.json'),dict=read('dictionary/build.json'),campaign=read('campaign/campaign-build.json');
if(m.version!=='X09-All-Training-1'||m.model_sha256!=='71ba9704e279c08160a8af882a8628b77e938a30befa450e95a522315a39f995')throw Error('Unexpected canonical X09 training fixture');
if(hash(zlib.gunzipSync(fs.readFileSync(path.join(dir,'model.rvp.gz'))))!==m.model_sha256)throw Error('X09 model differs');
for(const [name,item]of Object.entries(m.extensions))if(hash(fs.readFileSync(path.join(dir,item.directory,item.manifest_file)))!==item.manifest_sha256)throw Error('Extension changed: '+name);
const p={version:m.version,'source.commit':'70852c46baead5f5885d0f08c8cc12f98bd6a62c','model.sha256':m.model_sha256,'sha.model.rvp.gz':hash(fs.readFileSync(path.join(dir,'model.rvp.gz'))),'sha.front.rxe':m.front_sha256,'sha.code.rxe':m.code_sha256,'phase.count':m.migration.length,'dictionary.entries':dict.entries,'dictionary.max.page':dict.max_page_bytes,'dictionary.data.bytes':dict.corpus.data.bytes};
for(const[n,h]of Object.entries(m.roles_sha256))p['sha.'+n]=h;
for(const [i,item]of m.migration.entries()){p['phase.'+i]=item.file;p['sha.'+item.file]=item.sha256;}
for(const[n,item]of Object.entries(dict.files))p['sha.dictionary/'+n]=item.sha256;
for(const item of [dict.corpus.index,dict.corpus.data])p['sha.dictionary/'+item.file]=item.sha256;
for(const[n,h]of Object.entries(campaign.roles))p['sha.campaign/'+n]=h;
for(const[n,h]of Object.entries(campaign.source_sha256))p['sha.campaign/'+n]=h;
fs.writeFileSync(path.join(dir,'x09.properties'),Object.entries(p).map(([k,v])=>k+'='+v).join('\n')+'\n');
fs.writeFileSync(path.join(root,'integration/unified/bbyq-lock.json'),JSON.stringify({source:'guadalupejuan001-code/BBY-Q',commit:p['source.commit'],version:m.version,model_sha256:m.model_sha256,dictionary_entries:dict.entries,properties_sha256:hash(fs.readFileSync(path.join(dir,'x09.properties'))),host:'Original JNI, original XI roles, Android byte transport'},null,2)+'\n');
console.log(JSON.stringify({version:m.version,model_bytes:m.model_bytes,dictionary_entries:dict.entries,migration_phases:m.migration.length}));
