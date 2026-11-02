#!/usr/bin/env node
'use strict';
// Authoring only. The APK executes the emitted XI, never this Node script.
// Shared track vertices come from world.xi; camera, meshes and materials run in XI.
const fs=require('fs'),path=require('path');
let lines=['#!reverse-pc-machine-v1','# REgraphics v4: curved vehicles, smooth XI lighting and bounded 3D raster.',
 '# The generic meshtri3 primitive clips/rasterizes; XI owns world geometry and camera.',
 '# Read-only observation: every scratch byte belongs to the discarded render candidate.'];
const out=s=>lines.push(...s.trim().split('\n'));let serial=0;
const label=p=>p+'_'+serial++;
function load(reg,addr,bytes=4,bias=1000000,tmp='r11'){
 out(`load${bytes*8} ${reg} ${typeof addr==='number'?addr:'$'+addr}`);if(bias)out(`sub ${reg} ${bias}`);
}
function store(reg,addr,bytes=4,bias=1000000,a='r9',b='r10'){
 out(`mov ${a} ${reg}`);if(bias)out(`add ${a} ${bias}`);out(`store${bytes*8} ${addr} ${a}`);
}
// Bhaskara's approximation: unit length is consistent for physics and rendering.
function trig(angle,sin,cos,t0,t1){
 function one(shift,target){let neg=label('sin_negative'),done=label('sin_done');out(`mov ${target} ${angle}\nadd ${target} ${shift}\nmod ${target} 4096\ncmp ${target} 0\njge ${neg}\nadd ${target} 4096\nlabel ${neg}\nmov ${t0} ${target}\nmod ${t0} 2048\nset ${t1} 2048\nsub ${t1} ${t0}\nmul ${t0} ${t1}\nmov ${t1} ${t0}\nmul ${t1} 4\nset ${sin===target?cos:sin} 20971520\nsub ${sin===target?cos:sin} ${t1}\nmul ${t0} 262144\ndiv ${t0} ${sin===target?cos:sin}\ncmp ${target} 2048\njlt ${done}\nmul ${t0} -1\nlabel ${done}\nmov ${target} ${t0}`);}
 // Preserve first result while computing second, whose denominator uses the other register.
 one(0,sin);out(`mov ${t1} ${sin}`);store(t1,8250,2,32768,'r9','r10');
 one(1024,cos);load(sin,8250,2,32768,t0);
}
// The camera's reference point remains the actual vehicle, in centimeters.
load('r12',100,4,2000000);load('r13',104,4,2000000);
load('r0',108,2,0);
out('load16 r1 204\nadd r0 r1\nmod r0 4096');
trig('r0','r14','r15','r1','r2');
out(`load8 r0 200\ncmp r0 1\nje size_high\ncmp r0 2\nje size_medium\nset r0 320\nset r1 180\njmp size_done\nlabel size_medium\nset r0 480\nset r1 270\njmp size_done\nlabel size_high\nset r0 640\nset r1 360\nlabel size_done`);
store('r0',8210,2,0);store('r1',8212,2,0);
out(`meshbegin r0 r1 2 12\nload8 r0 201\ncmp r0 1\nje camera_close\ncmp r0 2\nje camera_hood\nset r0 750\nset r1 250\nset r2 160\nset r3 987\njmp camera_ready\nlabel camera_close\nset r0 650\nset r1 230\nset r2 150\nset r3 989\njmp camera_ready\nlabel camera_hood\nset r0 0\nset r1 115\nset r2 100\nset r3 995\nlabel camera_ready`);
 // Orbit elevation is an ephemeral XI input: a vertical finger drag adjusts
 // height and pitch simultaneously without altering the moving vehicle.
 // Signed tilt uses a wrapped 9-bit integer; zero preserves old views.
 out('load16 r6 206\ncmp r6 256\njlt orbit_elevation_decoded\nsub r6 512\nlabel orbit_elevation_decoded\nadd r1 r6\nadd r2 r6');
 // Chase camera rises with the XI-controlled chassis; no artificial screen shake.
 out('load16 r4 384\nmul r4 3\ndiv r4 5\nadd r1 r4');
 store('r0',8192,2,0);store('r1',8194,2,0);store('r2',8196,2,0);store('r3',8198,2,0);
require('./velocity-textures.cjs').emitXiTextures(out);
function focus(){
 load('r9',8210,2,0,'r11');
 out('mov r10 r9\ndiv r10 2\nmov r11 r10\nmul r11 9\ndiv r11 16\nmul r9 85\ndiv r9 100');
}
// Distant screen planes meet the exact camera ground horizon.
load('r0',8210,2,0);load('r1',8212,2,0);
out('mov r2 r1\ndiv r2 2\nmov r3 r0\nmul r3 85\ndiv r3 100');load('r4',8196,2,0);out('mul r3 r4');load('r4',8198,2,0);out('div r3 r4\nsub r2 r3');
store('r2',8238,2,0,'r9','r10');
// True XI rasterized multi-band sky and terrain, with fixed costs: four
// extra triangles per frame, independent of native render resolution.
out('mov r3 r2\ndiv r3 2\nmov r4 r3\ndiv r4 2'+
 '\nmeshtri 0 0 999999 r0 0 999999 r0 r4 999999 210'+
 '\nmeshtri 0 0 999999 r0 r4 999999 0 r4 999999 210'+
 '\nmeshtri 0 r4 999999 r0 r4 999999 r0 r3 999999 8'+
 '\nmeshtri 0 r4 999999 r0 r3 999999 0 r3 999999 8'+
 '\nmeshtri 0 r3 999999 r0 r3 999999 r0 r2 999999 38'+
 '\nmeshtri 0 r3 999999 r0 r2 999999 0 r2 999999 38'+
 '\nmov r4 r1\nsub r4 r2\ndiv r4 2\nadd r4 r2'+
 '\nmeshtri 0 r2 999998 r0 r2 999998 r0 r4 999998 72'+
 '\nmeshtri 0 r2 999998 r0 r4 999998 0 r4 999998 72'+
 '\nmeshtri 0 r4 999998 r0 r4 999998 r0 r1 999998 211'+
 '\nmeshtri 0 r4 999998 r0 r1 999998 0 r1 999998 211');
// Distant hills rotate as a panoramic skyline with the actual yaw.
out('load8 r6 108\nload8 r7 109\nmul r7 256\nadd r6 r7\nload16 r7 204\nadd r6 r7\nmul r6 5\ndiv r6 16\nmod r6 160\nstore8 8236 r6\nset r7 0\nlabel hills');
load('r0',8210,2,0);out('mov r1 r0\nmul r1 r7\ndiv r1 5\nmov r2 r0\ndiv r2 160\nload8 r6 8236\nmul r6 r2\nsub r1 r6\nmov r2 r0\ndiv r2 3\nadd r2 r1\nmov r4 r1\nadd r4 r2\ndiv r4 2');load('r3',8238,2,0);out('mov r5 r0\ndiv r5 20\nmul r5 -1\nadd r5 r3\nmeshtri r1 r3 999990 r4 r5 999990 r2 r3 999990 189\nadd r7 1\ncmp r7 8\njlt hills');
// Transform a ground point to camera: x/y/z in registers; r9..11 temporary.
function cameraPoint(x,y,z){out(`sub ${x} r12\nsub ${z} r13\nmov r9 ${x}\nmul r9 r15\nmov r10 ${z}\nmul r10 r14\nsub r9 r10\ndiv r9 16384\nmov r10 ${x}\nmul r10 r14\nmov r11 ${z}\nmul r11 r15\nadd r10 r11\ndiv r10 16384\nmov ${x} r9`);load('r11',8192,2,0,'r9');out('add r10 r11');load('r11',8194,2,0,'r9');out(`sub ${y} r11`);pitch(x,y,z);}
function pitch(x,y,z){
 // Before pitch: x is side, y is height, r10 is forward.
 load('r11',8196,2,0,'r9');out(`mul r11 ${y}`);load('r9',8198,2,0,z);out(`mov ${z} r10\nmul ${z} r9\nsub ${z} r11\ndiv ${z} 1000\nmul ${y} r9`);load('r11',8196,2,0,'r9');out(`mul r11 r10\nadd ${y} r11\ndiv ${y} 1000`);
}
// Pretransform track center and right normal once, then reuse them for road bands.
out('store8 8200 0\nlabel transform_track\nload8 r8 8200\nmov r7 r8\nmul r7 8\nadd r7 4096');load('r0','r7',4,65536);out('add r7 4');load('r2','r7',4,65536);out('set r1 0');cameraPoint('r0','r1','r2');
out('load8 r8 8200\nmul r8 2\nadd r8 1600\nmeshvertex r8 r0 r1 r2');
out('load8 r7 8200\nmul r7 2\nadd r7 5000');load('r0','r7',2,0);trig('r0','r1','r2','r3','r4');
out('mov r0 r2\nmul r0 r15\nmov r3 r1\nmul r3 r14\nadd r0 r3\ndiv r0 16384\nmov r10 r2\nmul r10 r14\nmul r1 r15\nsub r10 r1\ndiv r10 16384\nset r1 0\nset r2 0');pitch('r0','r1','r2');
out('load8 r8 8200\nmul r8 2\nadd r8 1601\nmeshvertex r8 r0 r1 r2');
out('load8 r8 8200\nadd r8 1\nstore8 8200 r8\ncmp r8 81\njlt transform_track\nstore8 8200 0\nlabel road_segment');
// Frustum culling reads ephemeral projected centers, without state writes.
out('load8 r9 8200\nmul r9 2\nadd r9 1600\nmeshread r0 r1 r2 r9\nadd r9 2\nmeshread r3 r4 r5 r9\ncmp r2 -2000\njge road_front\ncmp r5 -2000\njlt next_segment\nlabel road_front\ncmp r2 45000\njle road_near\ncmp r5 45000\njgt next_segment\nlabel road_near\nmov r6 r0\nmov r7 r3\ncmp r0 0\njge road_a_abs\nmul r0 -1\nlabel road_a_abs\nmov r4 r2\nmul r4 2\nadd r4 5000\ncmp r0 r4\njle road_visible\ncmp r3 0\njge road_b_abs\nmul r3 -1\nlabel road_b_abs\nmov r4 r5\nmul r4 2\nadd r4 5000\ncmp r3 r4\njle road_visible\nmul r6 r7\ncmp r6 0\njge next_segment\nlabel road_visible\nstore8 8201 0\nlabel road_band');
// Bands are actual geometry, using the same 6m/10m boundaries as physics.
const bands=[[-1000,-670,0,0,78],[-670,-600,0,0,208],[-600,600,0,0,108],[600,670,0,0,208],[670,1000,0,0,78],[-590,-580,1,1,206],[580,590,1,1,206],[-205,-195,2,2,206],[195,205,2,2,206],[-1000,-1000,0,100,204],[1000,1000,0,100,204]];
for(let b=0;b<bands.length;b++){out(`load8 r0 8201\ncmp r0 ${b}\njne band_${b}_skip`);const[a,c,yl,yr,m]=bands[b];out(`set r0 ${a}\nset r1 ${c}\nset r2 ${yl}\nset r3 ${yr}\nstore8 8220 ${m}\njmp band_ready\nlabel band_${b}_skip`);}
out('jmp next_segment\nlabel band_ready');
store('r0',8214,2,32768);store('r1',8216,2,32768);store('r2',8218,2,0);store('r3',8222,2,0);
out('load8 r0 8201\ncmp r0 7\njlt stripe_ready\ncmp r0 8\njgt stripe_ready\nload8 r0 8200\nmod r0 2\ncmp r0 0\nje next_band\nlabel stripe_ready\nload8 r0 8201\ncmp r0 1\nje curb_color\ncmp r0 3\njne curb_ready\nlabel curb_color\nload8 r0 8200\nmod r0 2\ncmp r0 0\njne curb_ready\nstore8 8220 206\nlabel curb_ready');
function roadVertex(tuple,endpoint,side){const[x,y,z]=tuple;
 out(`load8 r9 8200\nadd r9 ${endpoint}\nmul r9 2\nadd r9 1600\nmeshread ${x} ${y} ${z} r9\nadd r9 1\nmeshread r9 r10 r11 r9`);
 load('r12',side?8216:8214,2,32768);
 out(`mul r9 r12\ndiv r9 16384\nadd ${x} r9\nmul r10 r12\ndiv r10 16384\nadd ${y} r10\nmul r11 r12\ndiv r11 16384\nadd ${z} r11`);
 load('r9',side?8222:8218,2,0,'r11');load('r10',8198,2,0,'r11');out(`mul r10 r9\ndiv r10 1000\nadd ${y} r10`);
 load('r10',8196,2,0,'r11');out(`mul r10 r9\ndiv r10 1000\nsub ${z} r10`);
}
for(const tri of [[[0,0],[1,0],[1,1]],[[0,0],[1,1],[0,1]]]){
 tri.forEach(([e,s],i)=>roadVertex(['r'+(i*3),'r'+(i*3+1),'r'+(i*3+2)],e,s));
 const plain=label('road_plain'),done=label('road_done');
 out('load8 r9 8220\ncmp r9 108\njne '+plain);
 for(let i=0;i<3;++i)out('meshvertex '+(1770+i)+' r'+(3*i)+' r'+(3*i+1)+' r'+(3*i+2));
 for(let i=0;i<3;++i){
  const [endpoint,side]=tri[i],id=1770+i;
  out('load8 r0 8200\nadd r0 '+endpoint+'\nmul r0 32');
  load('r1',side?8216:8214,2,32768);
  out('div r1 12\nmeshtexuv '+id+' r1 r0\nmeshshade '+id+' 128');
 }
 focus();
 // Road wear shader. A 7-segment material cadence preserves the same XI
 // texture phase on both triangles of one physical segment.
 const darker=label('asphalt_darker'),toneDone=label('asphalt_tone_done');
 out('load8 r12 8200\nmod r12 7\ncmp r12 3\njle '+darker+
   '\nset r12 42\njmp '+toneDone+
   '\nlabel '+darker+'\nset r12 40\nlabel '+toneDone);
 out('meshfacegradienttex 1770 1771 1772 r12 12 5 3 r9 r10 r11 60\njmp '+done+'\nlabel '+plain);
 focus();
 out('load8 r7 8220\nmeshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 r7 r9 r10 r11 60');
 out('label '+done);
}
// Note material register collides with third y: use memory-free material dispatch.
// Replace the above meshtri3 line with literal-material dispatch preserving all vertices.
let replaced=[];for(const s of lines){if(s==='load8 r7 8220')continue;if(s==='meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 r7 r9 r10 r11 60'){
 // use r9 asmaterial probe, thenreload focusaftereach dispatch. r9 focalrestored by focus.
 const tags=[78,208,108,206,204];let done=label('triangle_emitted');replaced.push('load8 r9 8220');for(const m of tags){let skip=label('material_skip');replaced.push('cmp r9 '+m,'jne '+skip); // retain resolution focal, which was replaced above by materialprobe
 replaced.push('mov r9 r10','mul r9 170','div r9 100',`meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 ${m} r9 r10 r11 60`,'jmp '+done,'label '+skip);}replaced.push('label '+done);
 }else replaced.push(s);}lines=replaced;
out('label next_band\nload8 r0 8201\nadd r0 1\nstore8 8201 r0\ncmp r0 11\njlt road_band\nlabel next_segment\nload8 r0 8200\nadd r0 1\nstore8 8200 r0\ncmp r0 80\njlt road_segment');
// Reserve compact world materials and continuous car lighting ramps.
const {worldMaterial,buildPalette}=require('./velocity-materials.cjs');
lines=lines.map(line=>{
 const words=line.split(' ');
 if(words[0]==='meshbegin')words[4]='0';
 const at=words[0]==='meshtri'||words[0]==='meshtri3'?10:-1;
 if(at>=0&&/^\d+$/.test(words[at]))words[at]=String(worldMaterial(Number(words[at])));
 return words.join(' ');
});
load('r12',100,4,2000000);
const modelStats=require('./emit-velocity-car-scene.cjs')({out,load,store,trig,pitch,focus,label});
const destination=path.join(__dirname,'../reverse-os-android/app/src/main/assets/velocity/render.xi');
// Render temporaries are local VM registers, never durable Ether state.
// The original world/vehicle addresses continue using InverseMemory.
lines=lines.map(s=>{
 let m=/^load(?:8|16|32) (r\d+) (\d+)$/.exec(s);
 if(m&&Number(m[2])>=8192&&Number(m[2])<9000)return `localget ${m[1]} ${Number(m[2])-8192}`;
 m=/^store(?:8|16|32) (\d+) (.+)$/.exec(s);
 if(m&&Number(m[1])>=8192&&Number(m[1])<9000)return `localset ${Number(m[1])-8192} ${m[2]}`;
 return s;
});
fs.writeFileSync(destination,lines.join('\n')+'\n');
// The GPU 4K program is the SAME XI scene, lighting, physics inputs and
// authored meshes. Only the output mode and native projection size change.
// REgraphics/GL receives a bounded triangle transport, not enlarged pixels.
const capture=lines.slice();
const sizeDone=capture.indexOf('label size_done');
if(sizeDone<0)throw Error('Expected a XI size_done label');
capture.splice(sizeDone+1,0,'set r0 3840','set r1 2160');
const gpuBegin=capture.indexOf('meshbegin r0 r1 2 0');
if(gpuBegin<0)throw Error('Expected a bounded XI meshbegin');
capture[gpuBegin]='meshbegin r0 r1 4 0';
fs.writeFileSync(path.join(path.dirname(destination),'render4k.xi'),capture.join('\n')+'\n');
console.log(JSON.stringify({file:path.basename(destination),bytes:fs.statSync(destination).size,...modelStats}));
// Palette and XI lighting are authored together; Android only presents.
fs.writeFileSync(path.join(path.dirname(destination),'palette.txt'),buildPalette().join('\n')+'\n');
// Deterministic landscape geometry still executes entirely as XI/REgraphics.
console.log('XI_LANDSCAPE_GEOMETRY_PASS',JSON.stringify(require('./velocity-landscape-post.cjs').run()));
 // Exactly the same native XI scene (cars, materials, mountains, road). Revision 5
 // rasterizes all 3840x2160 pixels through REgraphics software strips, never GLES.
 const gpuLegacy=fs.readFileSync(path.join(path.dirname(destination),'render4k.xi'),'utf8');
 const legacyStart='meshbegin r0 r1 4 0';
 if(gpuLegacy.split(legacyStart).length!==2)throw Error('Expected a single XI 4K meshbegin');
 const nativeSource=gpuLegacy.replace(legacyStart,'meshbegin r0 r1 5 0');
 const nativePath=path.join(path.dirname(destination),'render-native4k.xi');
 fs.writeFileSync(nativePath,nativeSource);
 console.log('XI_NATIVE_4K_SOURCE_READY',JSON.stringify({name:path.basename(nativePath),bytes:nativeSource.length,revision:5}));
