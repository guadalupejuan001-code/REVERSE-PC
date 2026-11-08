#!/usr/bin/env python3
"""Original 3.7 JNI versus shared qSSD, identical XI driving/view trace."""
import argparse
import concurrent.futures
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import statistics
import subprocess

parser=argparse.ArgumentParser()
parser.add_argument('--baseline',required=True,type=Path)
parser.add_argument('--asset-baseline',type=Path,
    help='Pinned delivered C03 assets; both JNI implementations execute these same inputs')
parser.add_argument('--output',required=True,type=Path)
parser.add_argument('--jni-include',type=Path)
parser.add_argument('--rounds',type=int,default=3)
args=parser.parse_args()
root=Path(__file__).resolve().parents[1]
baseline=args.baseline.resolve();out=args.output.resolve();out.mkdir(parents=True,exist_ok=True)
assert subprocess.check_output(['git','-C',str(baseline),'rev-parse','HEAD'],text=True).strip()=='665742aa9310314242271ea51f9294d07a97b4c4'
assets=root/'reverse-os-android/app/src/main/assets/velocity'
asset_baseline=(args.asset_baseline.resolve() if args.asset_baseline else baseline)
asset_commit=subprocess.check_output(['git','-C',str(asset_baseline),'rev-parse','HEAD'],text=True).strip()
if args.asset_baseline:
    assert asset_commit=='cb7903bd596f1f0c382d3ba880e47086dfc37014','asset baseline must be delivered C03'
reference_assets=asset_baseline/'reverse-os-android/app/src/main/assets/velocity'
assert sorted(p.name for p in assets.iterdir() if p.is_file())==sorted(p.name for p in reference_assets.iterdir() if p.is_file()),'asset inventory differs'
inventory={}
for file in sorted(assets.iterdir()):
    if not file.is_file(): continue
    if args.asset_baseline or file.name not in {'drive.xi','environment.xi'}:
        assert file.read_bytes()==(reference_assets/file.name).read_bytes(),file.name
    inventory[file.name]=hashlib.sha256(file.read_bytes()).hexdigest()
java=['java','-m','jdk.compiler/com.sun.tools.javac.Main']
java_settings=subprocess.run(['java','-XshowSettings:properties','-version'],text=True,capture_output=True,check=True).stderr
java_home=Path(re.search(r'java.home\s*=\s*(.+)',java_settings).group(1).strip())
jni=args.jni_include or java_home/'include'
assert (jni/'jni.h').is_file(),'JDK JNI headers required; pass --jni-include'
mundo=root/'deps/mundo-x'
def run(command,log=None):
    p=subprocess.run(list(map(str,command)),cwd=root,text=True,capture_output=True,timeout=180,check=False)
    if log: Path(log).write_text(p.stdout+p.stderr)
    if p.returncode: raise RuntimeError(' '.join(map(str,command))+'\n'+p.stdout+p.stderr)
    return p.stdout
common=out/'common-java';common.mkdir(exist_ok=True)
base_names=['NativeRuntime.java','RegraphicsGeometry.java','XiGeometryDeltaDecoder.java','XiObservationPacket.java']
java_dir=Path('reverse-os-android/app/src/main/java')
sources=[root/java_dir/'com/reversepc/os'/name for name in base_names+['XiSharedGeometryPacket.java','VelocityOrbitMath.java','VelocitySessionState.java']]
sources += [root/java_dir/'x/gpu/virtual/CompactTriangleStream.java',root/'reverse-os-android/tests/VelocityQssdNativeTrace.java',root/'reverse-os-android/tests/VelocityStateSpaceTest.java']
run(java+['-d',common]+sources)
before_java=out/'before-java';before_java.mkdir(exist_ok=True)
run(java+['-d',before_java]+[baseline/java_dir/'com/reversepc/os'/name for name in base_names]+[baseline/java_dir/'x/gpu/virtual/CompactTriangleStream.java'])
for name,source in [('before',baseline),('after',root)]:
    folder=out/name;folder.mkdir(exist_ok=True)
    run(['python3',source/'scripts/prepare-ether-compat.py',mundo,folder/'ether'])
def compile_library(name,source):
    folder=out/name
    command=['g++','-std=c++17','-O2','-pthread','-fPIC','-shared','-DREVERSE_PC_HAVE_BOUNDED_PRODUCT_IMPORT=1',
      '-DVELOCITY_QSSD_JNI_SOURCE="'+str(source/'reverse-os-android/app/src/main/cpp/reverse_os_jni.cpp')+'"',
      '-I'+str(folder/'ether'),'-I'+str(mundo/'native/include'),'-I'+str(source/'src'),'-I'+str(jni),'-I'+str(jni/'linux'),
      root/'reverse-os-android/tests/velocity-qssd-jni.cpp','-o',folder/'libreverse_os.so']
    run(command,folder/'compile.log')
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
    list(pool.map(lambda item:compile_library(*item),[('before',baseline),('after',root)]))
run(['g++','-std=c++17','-O2','-pthread','-DREVERSE_PC_HAVE_BOUNDED_PRODUCT_IMPORT=1',
     '-I'+str(out/'before/ether'),'-I'+str(mundo/'native/include'),'-I'+str(baseline/'src'),
     root/'reverse-os-android/tests/velocity-cpu-gpu-link.cpp','-o',out/'original-trace'],out/'trace-compile.log')
fixtures=out/'original-frames';run([out/'original-trace',assets,fixtures],out/'original-trace.log')
run(['java','-Djava.library.path='+str(out/'after'),'-cp',common,'com.reversepc.os.VelocityStateSpaceTest',assets,out/'complete-state'],out/'complete-state.log')
trials=[]
for round_id in range(args.rounds):
    for name in (['before','after'] if round_id%2==0 else ['after','before']):
        folder=out/f'{name}-{round_id}';folder.mkdir(exist_ok=True)
        classpath=str(common) if name=='after' else str(before_java)+os.pathsep+str(common)
        text=run(['java','-Djava.library.path='+str(out/name),'-cp',classpath,
            'com.reversepc.os.VelocityQssdNativeTrace',assets,fixtures,folder,'shared' if name=='after' else 'delta'],folder/'run.log')
        report=json.loads(text.strip().splitlines()[-1]);report['trial']=round_id;trials.append(report)
keys=['nativeExecuteP50Ms','decodeP50Ms','packP50Ms','pipelineP50Ms','changedPublicationP50Ms','unchangedPublicationP50Ms']
summary={name:{key:statistics.median(row[key] for row in trials if row['mode']==mode) for key in keys}
    for name,mode in [('before','original-3.7'),('after','qssd')]}
report={'passed':True,'original_source':'665742aa9310314242271ea51f9294d07a97b4c4',
    'hostOnly':True,'physicalPhoneMeasured':False,'unchanged_assets':inventory,
    'unchanged_assets_relative_to':asset_commit,'both_implementations_use_same_current_assets':True,
    'trials':trials,'median_of_trial_p50_ms':summary,
    'scope':'same XI driving and view trace; all geometry, shader state, native RVPC2 and packed GPU bytes exact; host CPU/JNI stages, not drawing FPS'}
(out/'qssd-equivalence.json').write_text(json.dumps(report,indent=2)+'\n')
print('QSSD_VELOCITY_EQUIVALENCE_PASS '+json.dumps(summary))
