"""Align stored APK entries; independent verification uses local ZIP offsets."""
import zipfile,struct,pathlib,sys,copy,json
def verify(p):
 checked=[]
 with zipfile.ZipFile(p) as z,open(p,'rb') as raw:
  for i in z.infolist():
   if i.compress_type!=zipfile.ZIP_STORED:continue
   raw.seek(i.header_offset);h=raw.read(30);n,e=struct.unpack_from('<HH',h,26);off=i.header_offset+30+n+e
   alignment=16384 if i.filename.startswith('lib/') and i.filename.endswith('.so') else 4
   if off%alignment:raise ValueError('Misaligned '+i.filename)
   checked.append({'file':i.filename,'offset':off,'alignment':alignment})
 return checked
def align(src,dst):
 with zipfile.ZipFile(src) as a,zipfile.ZipFile(dst,'w') as b:
  for old in a.infolist():
   i=copy.copy(old)
   if i.compress_type==zipfile.ZIP_STORED:
    alignment=16384 if i.filename.startswith('lib/') and i.filename.endswith('.so') else 4
    offset=b.fp.tell()+30+len(i.filename.encode('utf-8'))+len(i.extra)
    if offset%alignment:
     padding=(-offset-6)%alignment
     i.extra+=struct.pack('<HHH',0xd935,2+padding,alignment)+bytes(padding)
   b.writestr(i,a.read(old.filename))
 verify(dst)
if __name__=='__main__':
 if len(sys.argv)==3:align(*sys.argv[1:])
 else:print(json.dumps(verify(sys.argv[1]),indent=2))
