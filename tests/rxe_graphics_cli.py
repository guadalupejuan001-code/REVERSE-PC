#!/usr/bin/env python3
"""Independent session model, parser mutation rejection and RXE1/RXE2 coexistence."""
import hashlib,json,random,struct,subprocess,sys,tempfile
from pathlib import Path
exe=Path(sys.argv[1]).resolve();image=Path(sys.argv[2]).resolve()
def run(*args,ok=True):
    p=subprocess.run([str(exe),*map(str,args)],capture_output=True,text=True)
    assert (p.returncode==0)==ok,(args,p.stdout,p.stderr)
    return p
raw=image.read_bytes();before_hash=hashlib.sha256(raw).hexdigest()
info=json.loads(run('inspect-rxe',image).stdout)
assert info['version']==3 and info['ui']=='graphics' and info['abi']=='XI-graphics-v1'
assert info['instructions']>100 and info['assets']>=6 and raw[:8]==b'RXE3\r\n\x1a\n'
assert b'#!reverse-pc-machine-v1' not in raw
with tempfile.TemporaryDirectory() as temp:
    root=Path(temp);state=root/'session.rvp'
    expected=dict(score=0,combo=0,hits=0,misses=0,maxCombo=0)
    assert json.loads(run('graphics-event',image,'-',state,0,0).stdout)==expected
    rng=random.Random(1784)
    events=[(1,150)]*38+[(2,0)]+[(rng.choice([1,1,1,2]),rng.choice([70,80,105,150])) for _ in range(73)]
    for kind,base in events:
        if kind==2:base=0;expected['combo']=0;expected['misses']+=1
        else:
            expected['combo']+=1;expected['hits']+=1;expected['maxCombo']=max(expected['maxCombo'],expected['combo'])
            expected['score']+=base*min(4,1+expected['combo']//12)
        actual=json.loads(run('graphics-event',image,state,state,kind,base).stdout)
        assert actual==expected,(actual,expected)
    assert json.loads(run('graphics-event',image,state,state,3,0).stdout)==expected
    saved=state.read_bytes()
    for kind,quality in [('4','0'),('1','151'),('2','1'),('-1','0'),('4294967296','0'),('1junk','0')]:
        run('graphics-event',image,state,state,kind,quality,ok=False);assert state.read_bytes()==saved
    run('graphics-event',image,root/'missing.rvp',state,1,150,ok=False);assert state.read_bytes()==saved
    run('graphics-event',image,state,image,1,150,ok=False);assert hashlib.sha256(image.read_bytes()).hexdigest()==before_hash
    def reseal(data):
        h=14695981039346656037
        for i,b in enumerate(data):
            if not 40<=i<48:h=((h^b)*1099511628211)&((1<<64)-1)
        data[40:48]=h.to_bytes(8,'little');return data
    variants=[]
    for offset,width,value in [(8,2,4),(10,2,4),(12,4,72),(16,4,len(raw)+1),(48,4,65),(52,4,41),(56,4,2),(60,4,3),(64,8,1)]:
        data=bytearray(raw);data[offset:offset+width]=value.to_bytes(width,'little');variants.append(reseal(data))
    ni,nt,nv,nc,ns=struct.unpack_from('<5I',raw,20);first=80+ni+nt+nv+40+nc+ns
    path_len=struct.unpack_from('<H',raw,first)[0]
    data=bytearray(raw);data[first+8:first+8+path_len]=b'../'+b'x'*(path_len-3);variants.append(reseal(data))
    data=bytearray(raw);data[first+2]=1;variants.append(reseal(data))
    variants.extend([raw[:n] for n in [0,7,8,79,len(raw)-1]])
    for i,data in enumerate(variants):
        bad=root/f'bad-{i}.rxe';bad.write_bytes(data)
        run('inspect-rxe',bad,ok=False);run('graphics-event',bad,state,state,1,150,ok=False);assert state.read_bytes()==saved
    # A valid capsule whose XI produces an invalid UI state must roll back too.
    src=root/'bad-output.xi';src.write_text('#!reverse-pc-machine-v1\nstore8 10 88\nset r0 1\nprint r0\nhalt\n')
    code=root/'bad-code.rxe';seed=root/'seed.rvp';bad=root/'bad-program.rxe'
    run('compile',src,code);run('init',seed)
    run('pack-graphics',code,seed,image.parent.parent.parent/'apps/prisma/web',bad,'org.reverse.bad','Bad state','1.0','a'*40)
    run('graphics-event',bad,state,state,1,150,ok=False);assert state.read_bytes()==saved
    assert json.loads(run('graphics-event',image,state,state,0,0).stdout)==dict(score=0,combo=0,hits=0,misses=0,maxCombo=0)
assert hashlib.sha256(image.read_bytes()).hexdigest()==before_hash
print(json.dumps(dict(rxe_graphics=True,independent_events=len(events),restarted_process_per_event=True,rejected_mutations=len(variants),invalid_events_rejected=True,failed_output_preserved=True,old_profiles='tested separately')))
