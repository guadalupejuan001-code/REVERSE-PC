#!/usr/bin/env python3
"""Exercise every material quality at one fixed resolution; sizes cannot fake quality."""
import json,os,pathlib,subprocess,sys
root=pathlib.Path(__file__).resolve().parents[1]
fixtures=root/(sys.argv[1] if len(sys.argv)>1 else 'build/open-forest')
out=root/(sys.argv[2] if len(sys.argv)>2 else 'build/graphics-presets');out.mkdir(parents=True,exist_ok=True)
assets=root/'reverse-os-android/app/src/main/assets/velocity'
results=[]
for quality,name in enumerate(['Ahorro','Bajos','Medio','Alto','Ultra']):
    env=dict(os.environ,VELOCITY_QUALITY=str(quality),VELOCITY_COMPACT_VERTEX='1',VELOCITY_SHADER_VARIANTS='1',VELOCITY_VERIFY_STRIPES='1',VELOCITY_BENCH_SAMPLES='3')
    r=subprocess.run([sys.executable,str(root/'scripts/velocity-gpu-preview.py'),str(fixtures/'gpu-0-0.xfg4'),str(assets/'palette.txt'),str(out/(name+'.png')),'640','360'],env=env,text=True,capture_output=True,check=True)
    record=json.loads(r.stdout.strip().splitlines()[-1]);record['quality']=quality;record['name']=name;results.append(record)
assert len({r['rgbaSha256'] for r in results})==5,'all five shader policies must make a real visual difference at identical dimensions'
(out/'shader-profiles.json').write_text(json.dumps({'passed':True,'hostOnly':True,'fixedWidth':640,'fixedHeight':360,'profiles':results},indent=2)+'\n')
print('VELOCITY_SHADER_PROFILES_PASS distinctImages=5 sameResolution=640x360')
