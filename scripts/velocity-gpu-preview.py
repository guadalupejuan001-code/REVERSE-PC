#!/usr/bin/env python3
"""Render the shipped GLSL and XI XFG4 packet through Mesa EGL (host QA only).
Requires Mesa EGL + numpy + Pillow. It never substitutes host-generated geometry.
Usage: velocity-gpu-preview.py INPUT.xfg4 PALETTE.txt OUTPUT.png [WIDTH HEIGHT]
"""
import ctypes as C
import ctypes.util
import json
import os
import pathlib
import struct
import sys
import numpy as np
from PIL import Image

os.environ.setdefault('EGL_PLATFORM', 'surfaceless')
egl=C.CDLL(C.util.find_library('EGL'))
def ef(name,result,*args):
    f=getattr(egl,name);f.restype=result;f.argtypes=list(args);return f
P=C.c_void_p;I=C.c_int;U=C.c_uint;F=C.c_float;B=C.c_ubyte
getproc=ef('eglGetProcAddress',P,C.c_char_p)
getdisplay=ef('eglGetDisplay',P,P)
display=getdisplay(None)
major,minor=I(),I()
assert ef('eglInitialize',U,P,P,P)(display,C.byref(major),C.byref(minor)), 'EGL initialize'
assert ef('eglBindAPI',U,U)(0x30A0), 'EGL OpenGL ES'
attrs=(I*19)(0x3033,1,0x3040,0x40,0x3024,8,0x3023,8,0x3022,8,0x3021,8,0x3025,24,0x3038,0,0,0,0)
config=P();count=I()
assert ef('eglChooseConfig',U,P,P,P,I,P)(display,attrs,C.byref(config),1,C.byref(count)) and count.value, 'ES3 config'
w=int(sys.argv[4]) if len(sys.argv)>4 else 1280
h=int(sys.argv[5]) if len(sys.argv)>5 else 720
surface=ef('eglCreatePbufferSurface',P,P,P,P)(display,config,(I*5)(0x3057,w,0x3056,h,0x3038))
context=ef('eglCreateContext',P,P,P,P,P)(display,config,None,(I*3)(0x3098,3,0x3038))
assert surface and context and ef('eglMakeCurrent',U,P,P,P,P)(display,surface,surface,context),'ES3 current'
def gl(name,result,*args):
    p=getproc(name.encode());assert p,name;return C.CFUNCTYPE(result,*args)(p)

def program(vert,frag):
    shaders=[]
    for kind,path in [(0x8B31,vert),(0x8B30,frag)]:
        shader=gl('glCreateShader',U,U)(kind);src=C.c_char_p(path.read_bytes())
        gl('glShaderSource',None,U,I,P,P)(shader,1,C.byref(src),None);gl('glCompileShader',None,U)(shader)
        ok=I();gl('glGetShaderiv',None,U,U,P)(shader,0x8B81,C.byref(ok))
        if not ok.value:
            log=C.create_string_buffer(16384);gl('glGetShaderInfoLog',None,U,I,P,P)(shader,len(log),None,log);raise RuntimeError(log.value.decode())
        shaders.append(shader)
    p=gl('glCreateProgram',U)()
    for shader in shaders:gl('glAttachShader',None,U,U)(p,shader)
    gl('glLinkProgram',None,U)(p);ok=I();gl('glGetProgramiv',None,U,U,P)(p,0x8B82,C.byref(ok));assert ok.value,'link'
    for shader in shaders:gl('glDeleteShader',None,U)(shader)
    return p
root=pathlib.Path(__file__).resolve().parents[1]/'reverse-os-android/app/src/main/assets/velocity'
scene=program(root/'gpu-scene.vert',root/'gpu-scene.frag');post=program(root/'gpu-post.vert',root/'gpu-post.frag')
packet=pathlib.Path(sys.argv[1]).read_bytes();magic,width,height,revision,faces=struct.unpack_from('<4sHHII',packet)
assert (magic,width,height,revision)==(b'XFG4',3840,2160,4) and len(packet)==2064+60*faces
buckets=[[],[],[],[]];lamp=None
for i in range(faces):
    values=struct.unpack_from('<9i6h3H6B',packet,2064+60*i)
    positions=values[:9];uv=values[9:15];shade=values[15:18];base,count,tile,strength,reserved0,reserved1=values[18:]
    assert not reserved0 and not reserved1
    category=0 if min(positions[2::3])>900000 else 2 if 24<=base<32 else (3 if strength else 6) if base==32 and count==8 else (4 if strength else 7) if base==244 else 5 if base==56 else 1
    if base==57 and count==1:
        pp=np.array(positions,dtype=np.float32).reshape(3,3);lamp=[]
        for x,y,z in pp[:2]:lamp.extend([(x-width*.5)*z/(width*.85)*.01,(height*.5-y)*z/(width*.85)*.01,z*.01])
        continue
    if base==58 and count==2:category=11
    if base in (221,223) and count==1:category=9
    if base==14 and count==3 and strength==1:category=8
    bucket=0 if category==0 else 1 if category in (1,8) else 2 if category in (2,3,9) else 3
    for v in range(3):buckets[bucket].append([*positions[v*3:v*3+3],*uv[v*2:v*2+2],shade[v]/65280,base,count,tile,strength,category])
alpha_faces=[buckets[2][i:i+3] for i in range(0,len(buckets[2]),3)];alpha_faces.sort(key=lambda face:-sum(v[2] for v in face));buckets[2]=[v for face in alpha_faces for v in face]
vertices=np.array([v for bucket in buckets for v in bucket],dtype=np.float32)
vao=U();gl('glGenVertexArrays',None,I,P)(1,C.byref(vao));gl('glBindVertexArray',None,U)(vao)
vbo=U();gl('glGenBuffers',None,I,P)(1,C.byref(vbo));gl('glBindBuffer',None,U,U)(0x8892,vbo)
gl('glBufferData',None,U,C.c_ssize_t,P,U)(0x8892,vertices.nbytes,vertices.ctypes.data,0x88E4)
for index,(size,offset) in enumerate([(3,0),(2,3),(1,5),(4,6),(1,10)]):
    gl('glEnableVertexAttribArray',None,U)(index);gl('glVertexAttribPointer',None,U,I,U,B,I,P)(index,size,0x1406,0,44,P(offset*4))

def texture(unit,internal,tw,th,form,pixels,nearest=False):
    gl('glActiveTexture',None,U)(0x84C0+unit);n=U();gl('glGenTextures',None,I,P)(1,C.byref(n));gl('glBindTexture',None,U,U)(0x0DE1,n)
    for name,value in [(0x2801,0x2600 if nearest else 0x2601),(0x2800,0x2600 if nearest else 0x2601),(0x2802,0x812F),(0x2803,0x812F)]:gl('glTexParameteri',None,U,U,I)(0x0DE1,name,value)
    data=C.create_string_buffer(pixels) if pixels else None
    gl('glTexImage2D',None,U,I,I,I,I,I,U,U,P)(0x0DE1,0,internal,tw,th,0,form,0x1401,data)
    return n
palette=bytes(sum([list(bytes.fromhex(line.strip()))+[255] for line in pathlib.Path(sys.argv[2]).read_text().splitlines() if line.strip()],[]))
texture(0,0x8058,256,1,0x1908,palette)
atlas=bytes(packet[16+tile*256+y*16+x] for y in range(16) for tile in range(8) for x in range(16))
texture(1,0x8229,128,16,0x1903,atlas,True)
color=texture(2,0x8058,w,h,0x1908,None)
fbo=U();depth=U();gl('glGenFramebuffers',None,I,P)(1,C.byref(fbo));gl('glBindFramebuffer',None,U,U)(0x8D40,fbo)
gl('glFramebufferTexture2D',None,U,U,U,U,I)(0x8D40,0x8CE0,0x0DE1,color,0)
gl('glGenRenderbuffers',None,I,P)(1,C.byref(depth));gl('glBindRenderbuffer',None,U,U)(0x8D41,depth);gl('glRenderbufferStorage',None,U,U,I,I)(0x8D41,0x81A6,w,h)
gl('glFramebufferRenderbuffer',None,U,U,U,U)(0x8D40,0x8D00,0x8D41,depth)
assert gl('glCheckFramebufferStatus',U,U)(0x8D40)==0x8CD5,'framebuffer'
gl('glUseProgram',None,U)(scene)
def loc(name,p=scene):
    n=gl('glGetUniformLocation',I,U,C.c_char_p)(p,name.encode());assert n>=0,name;return n
for name,val in [('uTime',3.4),('uDay',.12 if 'night' in sys.argv[2] else .48 if 'dusk' in sys.argv[2] else 1),('uYaw',float(os.getenv('VELOCITY_VIEW_YAW','0'))),('uWet',.6),('uWaterDepth',float(os.getenv('VELOCITY_WATER_DEPTH','0'))),('uAspect',w/h)]:gl('glUniform1f',None,I,F)(loc(name),val)
lamp=lamp or [0,0,0,0,0,1]
for name,values in [('uLampOrigin',lamp[:3]),('uLampDirection',[lamp[3+i]-lamp[i] for i in range(3)])]:gl('glUniform3f',None,I,F,F,F)(loc(name),*values)
gl('glUniform1f',None,I,F)(loc('uLampPower'),1 if 'night' in sys.argv[2] else .6 if 'dusk' in sys.argv[2] else 0)
gl('glUniform2f',None,I,F,F)(loc('uProjection'),width,height)
for name,val in [('uPalette',0),('uAtlas',1)]:gl('glUniform1i',None,I,I)(loc(name),val)
gl('glViewport',None,I,I,I,I)(0,0,w,h);gl('glClearColor',None,F,F,F,F)(.08,.12,.14,1);gl('glClear',None,U)(0x4000|0x0100)
gl('glDisable',None,U)(0x0B44);gl('glDisable',None,U)(0x0B71);gl('glDepthMask',None,B)(0);start=0
for index,bucket in enumerate(buckets):
    if index==1:gl('glEnable',None,U)(0x0B71);gl('glDepthFunc',None,U)(0x0203);gl('glDepthMask',None,B)(1)
    if index==2:gl('glDepthMask',None,B)(0);gl('glEnable',None,U)(0x0BE2);gl('glBlendFunc',None,U,U)(0x0302,0x0303)
    if index==3:gl('glBlendFunc',None,U,U)(0x0302,1)
    gl('glDrawArrays',None,U,I,I)(4,start,len(bucket));start+=len(bucket)
gl('glBindFramebuffer',None,U,U)(0x8D40,0);gl('glBindVertexArray',None,U)(0);gl('glDisable',None,U)(0x0B71);gl('glDisable',None,U)(0x0BE2)
gl('glUseProgram',None,U)(post);gl('glActiveTexture',None,U)(0x84C0);gl('glBindTexture',None,U,U)(0x0DE1,color)
gl('glUniform1i',None,I,I)(loc('uImage',post),0);gl('glUniform1i',None,I,I)(loc('uPhoto',post),0);gl('glUniform2f',None,I,F,F)(loc('uTexel',post),1/w,1/h)
gl('glDrawArrays',None,U,I,I)(4,0,3)
pixels=(B*(w*h*4))();gl('glReadPixels',None,I,I,I,I,U,U,P)(0,0,w,h,0x1908,0x1401,pixels)
error=gl('glGetError',U)();assert error==0,hex(error)
image=Image.frombytes('RGBA',(w,h),bytes(pixels)).transpose(Image.Transpose.FLIP_TOP_BOTTOM)
output=pathlib.Path(sys.argv[3]);output.parent.mkdir(parents=True,exist_ok=True);image.save(output)
renderer=gl('glGetString',C.c_char_p,U)(0x1F01).decode()
print(json.dumps({'passed':True,'hostOnly':True,'renderer':renderer,'faces':faces,'width':w,'height':h,'output':str(output)}))
