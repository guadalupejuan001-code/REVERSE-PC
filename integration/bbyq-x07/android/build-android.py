#!/usr/bin/env python3
"""Package the isolated Android integration using the released JNI libraries."""
import pathlib,subprocess,zipfile,hashlib,json,os,xml.etree.ElementTree as ET,struct
P=pathlib.Path(__file__).resolve().parent;ROOT=P.parent;MAIN=P/'android-src/reverse-os-android/app/src/main';SDK=P/'toolchain/sdk35';OUT=P/'apk-build';DELIVERY=ROOT/'outputs';BASE=ROOT/'inputs/p13-apk/REVERSE-2.8.1-Instalacion.apk'
sha=lambda b:hashlib.sha256(b).hexdigest()
def run(a,**kw):return subprocess.run([str(x) for x in a],check=True,**kw)
for d in ['generated','classes','dex']:(OUT/d).mkdir(parents=True,exist_ok=True)
DELIVERY.mkdir(exist_ok=True)
ET.register_namespace('android','http://schemas.android.com/apk/res/android');tree=ET.parse(MAIN/'AndroidManifest.xml');root=tree.getroot();root.set('package','com.reversepc.os');ns='{http://schemas.android.com/apk/res/android}'
for e in root.iter():
 if e.get(ns+'name','').startswith('.'):e.set(ns+'name','com.reversepc.os'+e.get(ns+'name'))
 if e.get(ns+'label')=='${appLabel}':e.set(ns+'label','REVERSE')
tree.write(OUT/'AndroidManifest.xml',encoding='utf-8',xml_declaration=True)
run([SDK/'aapt2','compile','--dir',MAIN/'res','-o',OUT/'resources.zip'])
run([SDK/'aapt2','link','-I',SDK/'android.jar','--manifest',OUT/'AndroidManifest.xml','-R',OUT/'resources.zip','--auto-add-overlay','--min-sdk-version','29','--target-sdk-version','35','--version-code','290','--version-name','2.9.0-X07','--rename-manifest-package','com.reversepc.complete.workbench','--custom-package','com.reversepc.os','--java',OUT/'generated','-o',OUT/'resources.apk'])
run(['java','-m','jdk.compiler/com.sun.tools.javac.Main','-source','17','-target','17','-encoding','UTF-8','-classpath',SDK/'android.jar','-d',OUT/'classes',*sorted((MAIN/'java').rglob('*.java')),*sorted((OUT/'generated').rglob('*.java'))])
run(['java','-cp',SDK/'d8.jar','com.android.tools.r8.D8','--release','--min-api','29','--lib',SDK/'android.jar','--output',OUT/'dex',*sorted((OUT/'classes').rglob('*.class'))])
mf=json.loads((MAIN/'assets/bbyq-interface/manifest.json').read_text());bi=json.loads((MAIN/'assets/workbench/build-info.json').read_text());bi.update(version='2.9.0-X07',versionCode=290,bbyq=mf['complete'],device_tested=False,training=mf['modern'],native_libraries='Unchanged byte-for-byte from delivered 2.8.1')
(MAIN/'assets/workbench/build-info.json').write_text(json.dumps(bi,ensure_ascii=False,indent=2)+'\n')
with zipfile.ZipFile(OUT/'unsigned.apk','w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
 with zipfile.ZipFile(OUT/'resources.apk') as res:
  for info in res.infolist():z.writestr(info,res.read(info.filename))
 with zipfile.ZipFile(BASE) as old:
  for n in old.namelist():
   if n.startswith('lib/') and n.endswith('.so'):z.writestr(n,old.read(n),compress_type=zipfile.ZIP_STORED)
 for f in sorted((MAIN/'assets').rglob('*')):
  if f.is_file():z.write(f,'assets/'+f.relative_to(MAIN/'assets').as_posix())
 for f in sorted((OUT/'dex').glob('*.dex')):z.write(f,f.name)
run(['python',P/'align-apk.py',OUT/'unsigned.apk',OUT/'aligned.apk'])
final=DELIVERY/'REVERSE-2.9.0-X07.apk';env=os.environ.copy();env['REVERSE_LOCAL_SIGNING_PASS']='android'
run(['java','-jar',SDK/'apksigner.jar','sign','--ks',ROOT/'inputs/p13-signing/REVERSE-Control-signing-key.jks','--ks-key-alias','reverse-desktop','--ks-pass','env:REVERSE_LOCAL_SIGNING_PASS','--key-pass','env:REVERSE_LOCAL_SIGNING_PASS','--out',final,OUT/'aligned.apk'],env=env)
cert=subprocess.check_output(['java','-jar',str(SDK/'apksigner.jar'),'verify','--verbose','--print-certs',str(final)],text=True)
assert 'cd76d2fef0c238b19b7ad679606f3dbecf44affd93fd585cc1a5bcf057d05a7d' in cert
alignment=json.loads(subprocess.check_output(['python',str(P/'align-apk.py'),str(final)],text=True))
with zipfile.ZipFile(final) as z,zipfile.ZipFile(BASE) as old:
 assert z.testzip() is None
 assert sha(z.read('assets/native-apps/BBY-Q.rxe'))==mf['complete']['executable_sha256']
 libs=[n for n in old.namelist() if n.startswith('lib/') and n.endswith('.so')]
 for n in libs:assert old.read(n)==z.read(n)
 assert z.getinfo('resources.arsc').compress_type==zipfile.ZIP_STORED
 # All untouched assets remain identical. Only integration metadata, UI and BBY capsule may change.
 allowed={'assets/native-apps/BBY-Q.rxe','assets/bbyq-interface/manifest.json','assets/workbench/build-info.json','assets/workbench/programs.js','assets/workbench/control-center.js'}
 untouched=0
 for n in old.namelist():
  if n.startswith('assets/') and not n.endswith('/') and n not in allowed:assert z.read(n)==old.read(n),n;untouched+=1
e={'file':final.name,'bytes':final.stat().st_size,'sha256':sha(final.read_bytes()),'version':'2.9.0-X07','version_code':290,'package':'com.reversepc.complete.workbench','certificate_sha256':'cd76d2fef0c238b19b7ad679606f3dbecf44affd93fd585cc1a5bcf057d05a7d','signature_verified':True,'zip_crc':True,'alignment_16kb':True,'resources_arsc_stored':True,'unchanged_native_libraries':libs,'unchanged_baseline_assets':untouched,'bbyq_sha256':mf['complete']['executable_sha256'],'device_tested':False}
e['alignment_entries']=alignment
(DELIVERY/(final.name+'.verification.json')).write_text(json.dumps(e,indent=2)+'\n');print(json.dumps({k:v for k,v in e.items() if k!='alignment_entries'}))
