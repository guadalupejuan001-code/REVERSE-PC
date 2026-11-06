#!/usr/bin/env python3
"""Compare original and coordinated XI traces, including every shader input."""
import hashlib,json,pathlib,sys
root=pathlib.Path(sys.argv[1]);before=root/'before';after=root/'after'
assert (before/'final.rvpc2').read_bytes()==(after/'final.rvpc2').read_bytes(),'compact checkpoint changed'
frames=[]
for i in range(72):
    name=f'link-{i}'
    a=(before/(name+'.xfg4')).read_bytes();b=(after/(name+'.xfg4')).read_bytes()
    assert a==b,f'original XI geometry changed at {i}'
    assert (before/(name+'.state')).read_bytes()==(after/(name+'.state')).read_bytes(),f'shader state changed at {i}'
    frames.append({'index':i,'bytes':len(a),'sha256':hashlib.sha256(a).hexdigest()})
a=json.loads((before/'cpu-gpu-host.json').read_text());b=json.loads((after/'cpu-gpu-host.json').read_text())
assert b['wireBytes']<a['wireBytes'],'retained transport did not save bytes'
report={'passed':True,'hostOnly':True,'physicalPhoneMeasured':False,'frames':frames,'before':a,'after':b,
        'prepareRatio':a['prepareP50Ms']/b['prepareP50Ms'],'wireReduction':1-b['wireBytes']/a['wireBytes'],
        'scope':'identical XI trace, full geometry and shader-state bytes; GPU shaders/assets unchanged; CPU stages only'}
(root/'cpu-gpu-equivalence.json').write_text(json.dumps(report,indent=2)+'\n')
print('CPU_GPU_EQUIVALENCE_PASS '+json.dumps({k:v for k,v in report.items() if k not in ['frames','scope']}))
