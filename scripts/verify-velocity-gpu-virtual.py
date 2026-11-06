#!/usr/bin/env python3
"""Legacy/compact rendering A/B of actual XI fixtures, never generated game pixels."""
import json, os, pathlib, subprocess, sys
from PIL import Image

root=pathlib.Path(__file__).resolve().parents[1]
fixtures=root/(sys.argv[1] if len(sys.argv)>1 else 'build/open-forest')
out=root/(sys.argv[2] if len(sys.argv)>2 else 'build/compact-gpu')
out.mkdir(parents=True,exist_ok=True)
assets=root/'reverse-os-android/app/src/main/assets/velocity'
report={'passed':False,'hostOnly':True,'physicalPhoneFpsMeasured':False,'pairs':[]}
cases=[(p,320,180,'palette.txt') for p in sorted(fixtures.glob('gpu-*.xfg4'))]
assert len(cases)>=12,'the full actual XI view/effect fixture matrix is required'
cases += [(fixtures/'gpu-0-0.xfg4',1280,720,'palette.txt'),
          (fixtures/'gpu-ford.xfg4',1280,720,'palette-night.txt'),
          (fixtures/'gpu-nitro.xfg4',1280,720,'palette-dusk.txt'),
          (fixtures/'gpu-700-450.xfg4',3840,2160,'palette.txt')]
try:
    for index,(fixture,w,h,palette) in enumerate(cases):
        images=[];results=[]
        for compact in [False,True]:
            png=out/f'{index:02d}-{int(compact)}.png'
            env=dict(os.environ,VELOCITY_COMPACT_VERTEX=str(int(compact)),VELOCITY_SHADER_VARIANTS=str(int(compact)),VELOCITY_VERIFY_STRIPES='1',VELOCITY_BENCH_SAMPLES='3')
            result=subprocess.run([sys.executable,str(root/'scripts/velocity-gpu-preview.py'),str(fixture),str(assets/palette),str(png),str(w),str(h)],env=env,check=True,text=True,capture_output=True)
            results.append(json.loads(result.stdout.strip().splitlines()[-1]));images.append(Image.open(png).tobytes())
        assert images[0]==images[1],f'GPU pixels differ for {fixture.name} at {w}x{h}'
        report['pairs'].append({'fixture':fixture.name,'width':w,'height':h,'palette':palette,'pixelExact':True,'before':results[0],'after':results[1]})
        print(f'GPU_VIRTUAL_PIXEL_PAIR_PASS {fixture.name} {w}x{h}',flush=True)
    report['passed']=True
finally:
    (out/'gpu-virtual-pixel-equivalence.json').write_text(json.dumps(report,indent=2)+'\n')
print('GPU_VIRTUAL_PIXEL_MATRIX_PASS pairs='+str(len(report['pairs'])))
