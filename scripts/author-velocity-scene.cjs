#!/usr/bin/env node
'use strict';
// Authoring only. The APK executes the emitted XI, never this Node script.
// Shared track vertices come from world.xi; camera, meshes and materials run in XI.
const fs=require('fs'),path=require('path');
let lines=['#!reverse-pc-machine-v1','# REgraphics v3: world-space 3D meshes, perspective, near-plane and Z-buffer.',
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
load('r0',108,2,0);trig('r0','r14','r15','r1','r2');
out(`load8 r0 200\ncmp r0 1\nje size_high\ncmp r0 2\nje size_medium\nset r0 320\nset r1 180\njmp size_done\nlabel size_medium\nset r0 480\nset r1 270\njmp size_done\nlabel size_high\nset r0 640\nset r1 360\nlabel size_done`);
store('r0',8210,2,0);store('r1',8212,2,0);
out(`meshbegin r0 r1 2 12\nload8 r0 201\ncmp r0 1\nje camera_close\ncmp r0 2\nje camera_hood\nset r0 900\nset r1 360\nset r2 200\nset r3 980\njmp camera_ready\nlabel camera_close\nset r0 650\nset r1 260\nset r2 210\nset r3 978\njmp camera_ready\nlabel camera_hood\nset r0 0\nset r1 125\nset r2 70\nset r3 998\nlabel camera_ready`);
store('r0',8192,2,0);store('r1',8194,2,0);store('r2',8196,2,0);store('r3',8198,2,0);
function focus(){
 load('r9',8210,2,0,'r11');
 out('mov r10 r9\ndiv r10 2\nmov r11 r10\nmul r11 9\ndiv r11 16\nmul r9 85\ndiv r9 100');
}
// Distant screen planes meet the exact camera ground horizon.
load('r0',8210,2,0);load('r1',8212,2,0);
out('mov r2 r1\ndiv r2 2\nmov r3 r0\nmul r3 85\ndiv r3 100');load('r4',8196,2,0);out('mul r3 r4');load('r4',8198,2,0);out('div r3 r4\nsub r2 r3');
store('r2',8238,2,0,'r9','r10');
out('mov r3 r2\ndiv r3 2\nmeshtri 0 0 999999 r0 0 999999 r0 r3 999999 8\nmeshtri 0 0 999999 r0 r3 999999 0 r3 999999 8\nmeshtri 0 r3 999999 r0 r3 999999 r0 r2 999999 38\nmeshtri 0 r3 999999 r0 r2 999999 0 r2 999999 38\nmeshtri 0 r2 999998 r0 r2 999998 r0 r1 999998 72\nmeshtri 0 r2 999998 r0 r1 999998 0 r1 999998 72');
// Distant hills rotate as a panoramic skyline with the actual yaw.
out('load8 r6 108\nload8 r7 109\nmul r7 256\nadd r6 r7\nmul r6 5\ndiv r6 16\nmod r6 160\nstore8 8236 r6\nset r7 0\nlabel hills');
load('r0',8210,2,0);out('mov r1 r0\nmul r1 r7\ndiv r1 5\nmov r2 r0\ndiv r2 160\nload8 r6 8236\nmul r6 r2\nsub r1 r6\nmov r2 r0\ndiv r2 3\nadd r2 r1\nmov r4 r1\nadd r4 r2\ndiv r4 2');load('r3',8238,2,0);out('mov r5 r0\ndiv r5 20\nmul r5 -1\nadd r5 r3\nmeshtri r1 r3 999990 r4 r5 999990 r2 r3 999990 189\nadd r7 1\ncmp r7 8\njlt hills');
// Transform a ground point to camera: x/y/z in registers; r9..11 temporary.
function cameraPoint(x,y,z){out(`sub ${x} r12\nsub ${z} r13\nmov r9 ${x}\nmul r9 r15\nmov r10 ${z}\nmul r10 r14\nsub r9 r10\ndiv r9 16384\nmov r10 ${x}\nmul r10 r14\nmov r11 ${z}\nmul r11 r15\nadd r10 r11\ndiv r10 16384\nmov ${x} r9`);load('r11',8192,2,0,'r9');out('add r10 r11');load('r11',8194,2,0,'r9');out(`sub ${y} r11`);pitch(x,y,z);}
function pitch(x,y,z){
 // Before pitch: x is side, y is height, r10 is forward.
 load('r11',8196,2,0,'r9');out(`mul r11 ${y}`);load('r9',8198,2,0,z);out(`mov ${z} r10\nmul ${z} r9\nsub ${z} r11\ndiv ${z} 1000\nmul ${y} r9`);load('r11',8196,2,0,'r9');out(`mul r11 r10\nadd ${y} r11\ndiv ${y} 1000`);
}
// Pretransform track center and right normal once, then reuse them for road bands.
out('store8 8200 0\nlabel transform_track\nload8 r8 8200\nmov r7 r8\nmul r7 8\nadd r7 4096');load('r0','r7',4,65536);out('add r7 4');load('r2','r7',4,65536);out('set r1 0');cameraPoint('r0','r1','r2');
out('load8 r8 8200\nmul r8 2\nadd r8 1000\nmeshvertex r8 r0 r1 r2');
out('load8 r7 8200\nmul r7 2\nadd r7 5000');load('r0','r7',2,0);trig('r0','r1','r2','r3','r4');
out('mov r0 r2\nmul r0 r15\nmov r3 r1\nmul r3 r14\nadd r0 r3\ndiv r0 16384\nmov r10 r2\nmul r10 r14\nmul r1 r15\nsub r10 r1\ndiv r10 16384\nset r1 0\nset r2 0');pitch('r0','r1','r2');
out('load8 r8 8200\nmul r8 2\nadd r8 1001\nmeshvertex r8 r0 r1 r2');
out('load8 r8 8200\nadd r8 1\nstore8 8200 r8\ncmp r8 81\njlt transform_track\nstore8 8200 0\nlabel road_segment');
// Frustum culling reads ephemeral projected centers, without state writes.
out('load8 r9 8200\nmul r9 2\nadd r9 1000\nmeshread r0 r1 r2 r9\nadd r9 2\nmeshread r3 r4 r5 r9\ncmp r2 -2000\njge road_front\ncmp r5 -2000\njlt next_segment\nlabel road_front\ncmp r2 45000\njle road_near\ncmp r5 45000\njgt next_segment\nlabel road_near\nmov r6 r0\nmov r7 r3\ncmp r0 0\njge road_a_abs\nmul r0 -1\nlabel road_a_abs\nmov r4 r2\nmul r4 2\nadd r4 5000\ncmp r0 r4\njle road_visible\ncmp r3 0\njge road_b_abs\nmul r3 -1\nlabel road_b_abs\nmov r4 r5\nmul r4 2\nadd r4 5000\ncmp r3 r4\njle road_visible\nmul r6 r7\ncmp r6 0\njge next_segment\nlabel road_visible\nstore8 8201 0\nlabel road_band');
// Bands are actual geometry, using the same 6m/10m boundaries as physics.
const bands=[[-1000,-670,0,0,78],[-670,-600,0,0,208],[-600,600,0,0,108],[600,670,0,0,208],[670,1000,0,0,78],[-590,-580,1,1,206],[580,590,1,1,206],[-205,-195,2,2,206],[195,205,2,2,206],[-1000,-1000,0,100,204],[1000,1000,0,100,204]];
for(let b=0;b<bands.length;b++){out(`load8 r0 8201\ncmp r0 ${b}\njne band_${b}_skip`);const[a,c,yl,yr,m]=bands[b];out(`set r0 ${a}\nset r1 ${c}\nset r2 ${yl}\nset r3 ${yr}\nstore8 8220 ${m}\njmp band_ready\nlabel band_${b}_skip`);}
out('jmp next_segment\nlabel band_ready');
store('r0',8214,2,32768);store('r1',8216,2,32768);store('r2',8218,2,0);store('r3',8222,2,0);
out('load8 r0 8201\ncmp r0 7\njlt stripe_ready\ncmp r0 8\njgt stripe_ready\nload8 r0 8200\nmod r0 2\ncmp r0 0\nje next_band\nlabel stripe_ready\nload8 r0 8201\ncmp r0 1\nje curb_color\ncmp r0 3\njne curb_ready\nlabel curb_color\nload8 r0 8200\nmod r0 2\ncmp r0 0\njne curb_ready\nstore8 8220 206\nlabel curb_ready');
function roadVertex(tuple,endpoint,side){const[x,y,z]=tuple;
 out(`load8 r9 8200\nadd r9 ${endpoint}\nmul r9 2\nadd r9 1000\nmeshread ${x} ${y} ${z} r9\nadd r9 1\nmeshread r9 r10 r11 r9`);
 load('r12',side?8216:8214,2,32768);
 out(`mul r9 r12\ndiv r9 16384\nadd ${x} r9\nmul r10 r12\ndiv r10 16384\nadd ${y} r10\nmul r11 r12\ndiv r11 16384\nadd ${z} r11`);
 load('r9',side?8222:8218,2,0,'r11');load('r10',8198,2,0,'r11');out(`mul r10 r9\ndiv r10 1000\nadd ${y} r10`);
 load('r10',8196,2,0,'r11');out(`mul r10 r9\ndiv r10 1000\nsub ${z} r10`);
}
for(const tri of [[[0,0],[1,0],[1,1]],[[0,0],[1,1],[0,1]]]){tri.forEach(([e,s],i)=>roadVertex(['r'+(i*3),'r'+(i*3+1),'r'+(i*3+2)],e,s));focus();out('load8 r7 8220\nmeshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 r7 r9 r10 r11 60'); // repair below: material must not reuse r7!
}
// Note material register collides with third y: use memory-free material dispatch.
// Replace the above meshtri3 line with literal-material dispatch preserving all vertices.
let replaced=[];for(const s of lines){if(s==='load8 r7 8220')continue;if(s==='meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 r7 r9 r10 r11 60'){
 // use r9 asmaterial probe, thenreload focusaftereach dispatch. r9 focalrestored by focus.
 const tags=[78,208,108,206,204];let done=label('triangle_emitted');replaced.push('load8 r9 8220');for(const m of tags){let skip=label('material_skip');replaced.push('cmp r9 '+m,'jne '+skip); // retain resolution focal, which was replaced above by materialprobe
 replaced.push('mov r9 r10','mul r9 170','div r9 100',`meshtri3 r0 r1 r2 r3 r4 r5 r6 r7 r8 ${m} r9 r10 r11 60`,'jmp '+done,'label '+skip);}replaced.push('label '+done);
 }else replaced.push(s);}lines=replaced;
out('label next_band\nload8 r0 8201\nadd r0 1\nstore8 8201 r0\ncmp r0 11\njlt road_band\nlabel next_segment\nload8 r0 8200\nadd r0 1\nstore8 8200 r0\ncmp r0 80\njlt road_segment');
// Actor rendering is emitted below by the authoring helper.
load('r12',100,4,2000000);
// Compact authored local mesh: meters become centimeters; no imported engine/assets.
const vertices=[],faces=[];const index=new Map();
function vertex(p){const key=p.join(',');if(!index.has(key)){index.set(key,vertices.length);vertices.push(p);}return index.get(key);}
function tri(a,b,c,m){faces.push([vertex(a),vertex(b),vertex(c),m]);}
function quad(a,b,c,d,m){tri(a,b,c,m);tri(a,c,d,m);}
function box(x0,x1,y0,y1,z0,z1,m){
 const a=[x0,y0,z0],b=[x1,y0,z0],c=[x1,y0,z1],d=[x0,y0,z1],e=[x0,y1,z0],f=[x1,y1,z0],g=[x1,y1,z1],h=[x0,y1,z1];
 quad(a,b,f,e,m);quad(b,c,g,f,m+1);quad(c,d,h,g,m);quad(d,a,e,h,m+2);quad(e,f,g,h,m+3);
}
quad([-125,3,-245],[125,3,-245],[115,3,240],[-115,3,240],210);
// Lower shell, with a wide rear and tapered nose.
box(-94,94,24,62,-212,207,128);
const rearL=[-98,73,-195],rearR=[98,73,-195],frontL=[-88,81,190],frontR=[88,81,190];
quad([-94,62,-212],[94,62,-212],rearR,rearL,129);
quad([94,62,-212],[94,62,207],frontR,rearR,128);
quad([-94,62,207],[-94,62,-212],rearL,frontL,130);
quad([94,62,207],[-94,62,207],frontL,frontR,132);
quad(rearL,rearR,[87,91,-75],[-87,91,-75],132);
quad([-87,91,-75],[87,91,-75],[82,91,45],[-82,91,45],132);
quad([-82,91,45],[82,91,45],frontR,frontL,133);
// Glass canopy: sharply raked front/rear, separate roof and lit body pillars.
const rl=[-61,136,-75],rr=[61,136,-75],fl=[-57,128,46],fr=[57,128,46];
quad([-85,91,-115],[85,91,-115],rr,rl,160);
quad([82,91,86],[-82,91,86],fl,fr,164);
quad([-85,91,-115],rl,fl,[-82,91,86],158);
quad(rr,[85,91,-115],[82,91,86],fr,162);
quad(rl,rr,fr,fl,133);
// Raised rear wing, supports, rear diffuser, segmented tail lamps and exhaust.
box(-75,-65,75,110,-200,-190,245);box(65,75,75,110,-200,-190,245);
box(-112,112,108,117,-225,-195,128);
quad([-80,27,-214],[80,27,-214],[72,57,-214],[-72,57,-214],209);
quad([-82,65,-214],[-25,65,-214],[-25,78,-214],[-82,78,-214],213);
quad([25,65,-214],[82,65,-214],[82,78,-214],[25,78,-214],213);
quad([-19,38,-215],[19,38,-215],[19,54,-215],[-19,54,-215],211);
quad([-72,31,-216],[-49,31,-216],[-49,43,-216],[-72,43,-216],211);
quad([49,31,-216],[72,31,-216],[72,43,-216],[49,43,-216],211);
quad([-76,71,208],[-39,71,208],[-39,81,198],[-76,81,198],212);
quad([39,71,208],[76,71,208],[76,81,198],[39,81,198],212);
// Four eight-sided tires with metal wheel centers.
for(const side of [-1,1])for(const zc of [-144,142]){
 const inner=side*82,outer=side*105;
 for(let k=0;k<8;k++){
  const a=k*Math.PI/4,b=(k+1)*Math.PI/4;
  const y0=Math.round(36+33*Math.sin(a)),z0=Math.round(zc+33*Math.cos(a));
  const y1=Math.round(36+33*Math.sin(b)),z1=Math.round(zc+33*Math.cos(b));
  quad([inner,y0,z0],[outer,y0,z0],[outer,y1,z1],[inner,y1,z1],209);
  tri([outer,36,zc],[outer,y0,z0],[outer,y1,z1],245);
  tri([outer+side,36,zc],[outer+side,Math.round(36+17*Math.sin(a)),Math.round(zc+17*Math.cos(a))],
    [outer+side,Math.round(36+17*Math.sin(b)),Math.round(zc+17*Math.cos(b))],211);
 }
}
const carFaceCount=faces.length,carVertexCount=vertices.length,treeFaceStart=faces.length;
box(-20,20,0,280,-20,20,202);
for(const [y,r,tip,m]of [[200,215,650,196],[410,155,820,198]])for(let k=0;k<8;k++){
 const a=k*Math.PI/4,b=(k+1)*Math.PI/4;
 tri([Math.round(r*Math.cos(a)),y,Math.round(r*Math.sin(a))],[0,tip,0],
     [Math.round(r*Math.cos(b)),y,Math.round(r*Math.sin(b))],m+(k%3));
}
const treeFaceEnd=faces.length;
if(vertices.length>256)throw Error('Mesh vertex byte budget');
out('# XI-authored local meshes live only in the generic ephemeral vertex buffer.');
for(let i=0;i<vertices.length;i++)out(`meshvertex ${i} ${vertices[i].join(' ')}`);
out('store8 8203 0\nlabel actor\nstore8 8334 0\nload8 r0 8203\ncmp r0 4\njge tree_actor\nset r0 0');store('r0',8324,2,0);out(`set r0 ${carVertexCount}`);store('r0',8326,2,0);
out('load8 r0 8203\ncmp r0 0\njne rival_actor\nload8 r1 201\ncmp r1 2\njne player_mesh_ready\nstore8 8334 1\nlabel player_mesh_ready');
load('r0',100,4,2000000);load('r2',104,4,2000000);load('r8',108,2,0);
out('load8 r9 202\nmul r9 6\nstore8 8318 r9\njmp actor_ready\nlabel rival_actor\nload8 r7 8203\nsub r7 1\nmul r7 32\nadd r7 6004');load('r0','r7',4,65536);out('add r7 4');load('r2','r7',4,65536);out('add r7 4');load('r8','r7',2,0);
out('load8 r9 8203\nmul r9 6\nstore8 8318 r9\njmp actor_ready\nlabel tree_actor');
out(`set r0 ${carVertexCount}`);store('r0',8324,2,0);out(`set r0 ${vertices.length}`);store('r0',8326,2,0);
out('load8 r8 8203\nsub r8 4\ndiv r8 2\nmul r8 4\nmov r7 r8\nmul r7 2\nadd r7 5000');load('r6','r7',2,0);trig('r6','r3','r4','r1','r2');
out('load8 r0 8203\nmod r0 2\nmul r0 2\nsub r0 1\nmul r0 1650\nmul r4 r0\ndiv r4 16384\nmul r3 r0\ndiv r3 16384\nmul r8 8\nadd r8 4096');load('r0','r8',4,65536,'r11');out('add r0 r4\nadd r8 4');load('r2','r8',4,65536,'r11');out('sub r2 r3\nset r8 0\nlabel actor_ready');
trig('r8','r3','r4','r5','r6');
out('mov r1 r3\nmul r1 r15\nmov r5 r4\nmul r5 r14\nsub r1 r5\ndiv r1 16384\nmov r5 r3\nmul r5 r14\nmul r4 r15\nadd r5 r4\ndiv r5 16384');store('r1',8308,2,32768);store('r5',8310,2,32768);
out('sub r0 r12\nsub r2 r13\nmov r1 r0\nmul r1 r15\nmov r3 r2\nmul r3 r14\nsub r1 r3\ndiv r1 16384\nmul r0 r14\nmul r2 r15\nadd r0 r2\ndiv r0 16384');store('r1',8300);store('r0',8304);
out('cmp r0 -1200\njlt next_actor\ncmp r0 35000\njgt next_actor\nmov r2 r0\nmul r2 2\nadd r2 3500');load('r1',8300,4,1000000,'r11');out('cmp r1 0\njge actor_side_absolute\nmul r1 -1\nlabel actor_side_absolute\ncmp r1 r2\njgt next_actor\nload8 r1 8203\ncmp r1 0\nje actor_lod_ready\ncmp r1 4\njge actor_lod_ready\ncmp r0 6500\njle actor_lod_ready\nstore8 8334 2\nlabel actor_lod_ready\nlabel actor_vertex');
load('r8',8324,2,0);out('meshread r0 r1 r2 r8');
// Transform every unique authored vertex once per actor, in XI.
load('r9',8310,2,32768,'r11');out('mul r9 r0');load('r10',8308,2,32768,'r11');out('mul r10 r2\nadd r9 r10\ndiv r9 16384');store('r9',8320,4,1000000,'r10','r11');
load('r9',8310,2,32768,'r11');out('mul r9 r2');load('r10',8308,2,32768,'r11');out('mul r10 r0\nsub r9 r10\ndiv r9 16384');load('r10',8304,4,1000000,'r11');out('add r10 r9');load('r0',8320,4,1000000,'r11');load('r11',8300,4,1000000,'r9');out('add r0 r11');
load('r11',8192,2,0,'r9');out('add r10 r11');load('r11',8194,2,0,'r9');out('sub r1 r11');pitch('r0','r1','r2');
load('r8',8324,2,0);out('add r8 256\nmeshvertex r8 r0 r1 r2\nsub r8 255');store('r8',8324,2,0);load('r0',8326,2,0);out('cmp r8 r0\njlt actor_vertex');
focus();out('load8 r12 8203\ncmp r12 4\njge emit_tree\nload8 r12 8334\ncmp r12 1\nje emit_hood');
for(let i=0;i<carFaceCount;i++){
 if(i===18)out('label emit_hood');
 if(i===26)out('load8 r12 8334\ncmp r12 1\nje next_actor');
 if(i===82)out('load8 r12 8334\ncmp r12 2\nje next_actor');
 const [a,b,c,m]=faces[i];let mat=m;
 if(m>=128&&m<=133){out(`load8 r12 8318\nadd r12 ${m}`);mat='r12';}
 out(`meshface ${a+256} ${b+256} ${c+256} ${mat} r9 r10 r11 60`);
}
out('jmp next_actor\nlabel emit_tree');
for(let i=treeFaceStart;i<treeFaceEnd;i++){const[a,b,c,m]=faces[i];out(`meshface ${a+256} ${b+256} ${c+256} ${m} r9 r10 r11 60`);}
out('label next_actor');load('r12',100,4,2000000);out('load8 r0 8203\nadd r0 1\nstore8 8203 r0\ncmp r0 44\njlt actor\nmeshend\nhalt');
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
console.log(JSON.stringify({file:path.basename(destination),bytes:fs.statSync(destination).size,vertices:vertices.length,trianglesPerCar:carFaceCount,trianglesPerTree:treeFaceEnd-treeFaceStart}));
// Palette is authored here alongside geometry; the Android host only unpacks RGB.
function ramp(a,b,n){const rgb=s=>[0,2,4].map(i=>parseInt(s.slice(i,i+2),16)),x=rgb(a),y=rgb(b);return Array.from({length:n},(_,j)=>x.map((v,k)=>Math.round(v+(y[k]-v)*j/(n-1)).toString(16).padStart(2,'0')).join(''));}
let palette=[...ramp('318ac5','e2edf1',64),...ramp('52634b','8b9167',32),...ramp('343c43','657076',32)];
for(const p of [['5a0a17','ff5a66'],['092443','4fa9ed'],['545e66','eef2f3'],['092d24','5bad8b'],['654714','f7cc59']])palette.push(...ramp(...p,6));
palette.push(...ramp('122333','b4d4de',12),...ramp('276c87','73bdc5',16),...ramp('8da5af','5b747c',8),...ramp('263b29','608753',8));
const colors={202:'64503b',203:'8c9495',204:'9ba3a4',205:'b1b7b5',206:'e3e5db',207:'e8c448',208:'d84843',209:'13171d',210:'354137',211:'bec9ce',212:'eaf9ff',213:'ff303b',214:'3dd7ff',215:'f4f7f6',216:'e0edf2',217:'fff6dc',218:'f7f5e7',219:'64767f',220:'b4c3c4',221:'8b8f87',222:'b6b7a7',223:'5f7176',224:'889ca1',225:'102d3a',226:'49ddf0',227:'f4e955',228:'e7f8ff'};
while(palette.length<256)palette.push('38434c');for(const [at,color]of Object.entries(colors))palette[Number(at)]=color;
for(let n=229;n<=236;n++)palette[n]=ramp('414a50','79878c',8)[n-229];for(let n=237;n<=244;n++)palette[n]=ramp('6395b4','c1d8df',8)[n-237];
palette[245]='262b32';palette[246]='12171f';palette[247]='303740';palette[248]='49515a';palette[249]='f7fcff';palette[250]='56cff2';palette[251]='ea1729';palette[252]='7d1221';palette[253]='423a2d';palette[254]='a2af9b';palette[255]='ffffff';
fs.writeFileSync(path.join(path.dirname(destination),'palette.txt'),palette.join('\n')+'\n');
