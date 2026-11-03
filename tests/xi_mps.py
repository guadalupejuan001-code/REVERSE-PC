#!/usr/bin/env python3
"""Compare XI MPS gates to the preserved dense backend and test atomic failure."""
import json
from pathlib import Path
import subprocess
import sys

sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'scripts'))
from xi_session_client import XiSession
cli,binary,out=Path(sys.argv[1]).resolve(),Path(sys.argv[2]).resolve(),Path(sys.argv[3]).resolve()
out.mkdir(parents=True,exist_ok=True);empty=out/'empty.rvp'
if not empty.exists():subprocess.run([cli,'init',empty],check=True,capture_output=True)
maximum=0;checks=0
for width in range(2,9):
    sources=[]
    for preparation in ['qprepare','qmps']:
        body=[f'{preparation} 0 {width}']
        for q in range(width):body += [f'h {q}',f'ry {q} {0.12+.1*q}',f'rx {q} -.31',f'rz {q} .41',f't {q}',f's {q}']
        for q in range(width-1):body += [f'cx {q} {q+1}',f'cz {q+1} {q}']
        for q in range(width):
            for axis in 'XYZ':body += [f'fexpect f0 {axis}:{q}',f'femit p{axis}{q} f0']
        body += ['fexpect f0 X:0 Y:1','femit joint f0']
        with XiSession(binary,empty) as session:
            rows,_=session.execute('#!reverse-pc-machine-v1\n'+'\n'.join(body)+'\nhalt\n')
            sources.append([r['value'] for r in rows if r['type']=='metric'])
    for a,b in zip(*sources):
        error=abs(a-b);maximum=max(maximum,error);assert error<1e-11;checks+=1
with XiSession(binary,empty) as session:
    session.execute('#!reverse-pc-machine-v1\nqmps 0 2\nry 0 .31\ncx 0 1\nstore8 100 7\nhalt\n')
    before,_=session.execute('#!reverse-pc-machine-v1\nfexpect f0 Z:0\nfemit score f0\nload8 r0 100\nprint r0\nhalt\n')
    try:
        session.execute('#!reverse-pc-machine-v1\nstore8 100 99\n'+'cx 0 1\n'*7+'halt\n')
    except RuntimeError:pass
    else:raise AssertionError('bond exhaustion was silently ignored')
    after,_=session.execute('#!reverse-pc-machine-v1\nfexpect f0 Z:0\nfemit score f0\nload8 r0 100\nprint r0\nhalt\n')
    assert before==after;checks+=1
report={'ok':True,'checks':checks,'dense_backend_max_absolute_error':maximum,'transactional_resource_failure':True}
(out/'xi-mps.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
