'use strict';
const {points,heights,point,headings,terrainHeight}=require('./open-forest-map.cjs');
module.exports=function({out,load,focus,cameraPoint,label,trig}){
 const objects=[];
 function object(segment,kind='ground'){const o={segment,kind,vertices:[],faces:[],tags:[],cache:new Map()};objects.push(o);return o;}
 function vertex(o,p,tag=0){const key=p.join(',')+';'+tag;if(!o.cache.has(key)){o.cache.set(key,o.vertices.length);o.vertices.push(p.map(Math.round));o.tags.push(tag);}return o.cache.get(key);}
 function tri(o,a,b,c,material=9,tags=[0,0,0]){o.faces.push({ids:[a,b,c].map((p,i)=>vertex(o,p,tags[i])),material});}
 function quad(o,a,b,c,d,m=9){tri(o,a,b,c,m);tri(o,a,c,d,m);}
 function strip(i,left,right,y0,y1,kind='ground',material=9){const o=object(i,kind),p=[point(i,left,y0),point(i+1,left,y1),point(i+1,right,y1),point(i,right,y0)];if(kind==='dirt')for(const v of p)v[1]=terrainHeight(v[2])+1;quad(o,...p,material);return o;}
 const apron=object(0,'dirt');quad(apron,[-650,1,-1200],[650,1,-1200],[650,1,1000],[-650,1,1000],9);
 // River beneath the bridge: a real cut-out in the land, not blue road paint.
 for(let i=65;i<=65;i++)strip(i,-6000,6000,terrainHeight(points[i][1])+12,terrainHeight(points[i+1][1])+12,'water',32);
 // Irregular lake ribbon and sloped muddy banks, all in the same world coordinates.
 for(let i=49;i<=62;i++){
  const edge=900+Math.round(120*Math.sin(i*.83));
  strip(i,edge,5800+Math.round(400*Math.sin(i*.37)),terrainHeight(points[i][1])+12,terrainHeight(points[i+1][1])+12,'water',32);
  const o=object(i,'shore');quad(o,point(i,450),point(i+1,450),point(i+1,edge,terrainHeight(points[i+1][1])+1),point(i,edge,terrainHeight(points[i][1])+1),9);
 }
 for(const i of [50,54,60]){
  const o=object(i,'flora'),c=point(i,750,Math.round(heights[i]/3));
  for(let k=0;k<3;k++)tri(o,[c[0]-10+k*12,c[1],c[2]+k*9],[c[0]+k*12,c[1]+110-k*10,c[2]+k*9],[c[0]+7+k*12,c[1],c[2]+k*9],14);
 }
 // Small bridge rails use boxes, while the physical bridge remains one lane.
 function box(o,c,size,material=9){const [x,y,z]=c,[a,b,d]=size.map(v=>v/2),v=[[-a,-b,-d],[a,-b,-d],[a,b,-d],[-a,b,-d],[-a,-b,d],[a,-b,d],[a,b,d],[-a,b,d]].map(p=>p.map((n,k)=>n+c[k]));for(const face of [[0,1,2,3],[4,7,6,5],[0,4,5,1],[3,2,6,7],[0,3,7,4],[1,5,6,2]])quad(o,...face.map(i=>v[i]),material);}
 require('./forest-bridge.cjs')({object,quad});
 // Three turnouts are actual dirt patches beside the traversable road.
 for(const [start,side] of [[12,-1],[43,1],[76,-1]])for(let i=start;i<start+2;i++)strip(i,side<0?-2200:200,side<0?-200:2200,heights[i]+2,heights[i+1]+2,'dirt',9);
 // Volumetric, occasional animals. The world tick drives their small animation.
 for(const i of [15,43,74]){
  const o=object(i,'deer'),c=point(i,i===43?-850:850),at=(x,y,z)=>[c[0]+x,c[1]+y,c[2]+z];
  box(o,at(0,86,0),[42,52,130],10);box(o,at(0,114,68),[26,45,34],11);
  for(const side of [-1,1])for(const z of [-43,43]){
   const x=side*17;tri(o,at(x-5,68,z),at(x+5,68,z),at(x+4,0,z+6),9,[0,0,z*side>0?2:-2]);
   tri(o,at(x-5,68,z),at(x+4,0,z+6),at(x-4,0,z+6),9,[0,z*side>0?2:-2,z*side>0?2:-2]);
  }
  tri(o,at(-9,132,64),at(-22,155,59),at(-2,139,69),11);tri(o,at(9,132,64),at(22,155,59),at(2,139,69),11);
  quad(o,at(-38,1,-85),at(38,1,-85),at(38,1,85),at(-38,1,85),24);
 }
 for(const i of [6,21,39,67]){
  const o=object(i,'bird'),c=point(i,-1100,heights[i]+700);
  tri(o,[c[0],c[1],c[2]-17],[c[0]-65,c[1]+7,c[2]+2],[c[0],c[1],c[2]+23],226,[0,1,0]);
  tri(o,[c[0],c[1],c[2]-17],[c[0],c[1],c[2]+23],[c[0]+65,c[1]+7,c[2]+2],226,[0,0,1]);
 }
 for(const i of [51,56,60]){const o=object(i,'fish'),c=point(i,1200,terrainHeight(point(i,1200)[2])+6);tri(o,[c[0]-8,c[1],c[2]-24],[c[0]+11,c[1],c[2]],[c[0]-8,c[1],c[2]+24],22);tri(o,[c[0]-8,c[1],c[2]+18],[c[0]-18,c[1],c[2]+34],[c[0]+6,c[1],c[2]+29],22);}
 for(const i of [11,42,75]){const o=object(i,'butterfly'),c=point(i,600,heights[i]+65);tri(o,[c[0],c[1],c[2]-4],[c[0]-13,c[1]+9,c[2]],[c[0],c[1],c[2]+9],243,[0,1,0]);tri(o,[c[0],c[1],c[2]-4],[c[0],c[1],c[2]+9],[c[0]+13,c[1]+9,c[2]],243,[0,0,1]);}
 const wetStats=require('./wetlands-objects.cjs')({object,tri,quad,box,strip});
 require('./forest-lights.cjs')({object,tri,quad,box});
 for(const p of require('./forest-trails.cjs').pois){
  const i=points.reduce((best,c,k)=>Math.abs(c[1]-p.z)<Math.abs(points[best][1]-p.z)?k:best,0);
  const y=terrainHeight(p.z,p.x),o=object(Math.min(79,i),'sign');
  box(o,[p.x+240,y+70,p.z],[12,140,12],9);
  box(o,[p.x+240,y+145,p.z],[90,35,10],11);
 }
 const models=[],modelMap=new Map();for(const o of objects){o.origin=o.vertices[0].slice();o.vertices=o.vertices.map(v=>v.map((n,k)=>n-o.origin[k]));const key=JSON.stringify([o.vertices,o.tags]);if(!modelMap.has(key)){modelMap.set(key,models.length);models.push(o);}o.model=modelMap.get(key);}
 function branchDispatch(first,last,prefix){if(last-first===1){out('jmp '+prefix+first);return;}const middle=(first+last)>>1,left=label('dispatch_left');out('cmp r0 '+middle+'\njlt '+left);branchDispatch(middle,last,prefix);out('label '+left);branchDispatch(first,middle,prefix);}
 const drawGroups=new Map();objects.forEach((o,index)=>{const key=o.kind+JSON.stringify(o.faces);if(!drawGroups.has(key))drawGroups.set(key,{o,indices:[],id:drawGroups.size});const g=drawGroups.get(key);g.indices.push(index);o.drawId=g.id;});
 out('load16 r0 108');trig('r0','r3','r4','r5','r6');out('localset 3330 r3\nlocalset 3331 r4');out(require('./car-ground-frame.cjs').readXi());
 out('localset 3300 0\njmp open_object_dispatch\nlabel open_object_transform\nlocalset 3302 0\nlabel open_object_vertex');
 out('localget r8 3302\nmov r9 r8\nadd r9 1900\nmeshread r0 r1 r2 r9\nlocalget r3 3316\nadd r0 r3\nlocalget r3 3317\nadd r1 r3\nlocalget r3 3318\nadd r2 r3\nlocalget r3 3310\nadd r0 r3\nmov r9 r8\nadd r9 3400\nlocalget r9 r9\ncmp r9 0\nje open_object_motion_done\nload32 r3 115\nmod r3 40\ncmp r3 20\njle open_flap_fold\nset r4 40\nsub r4 r3\nmov r3 r4\nlabel open_flap_fold\nsub r3 10\ncmp r9 1\njne open_leg_motion\nmul r3 3\nadd r1 r3\njmp open_object_motion_done\nlabel open_leg_motion\nmul r3 r9\nadd r2 r3\nlabel open_object_motion_done');
 out('localget r3 3312\ncmp r3 0\nje open_water_vertex_ready\nmov r3 r0\ndiv r3 50\nload32 r4 115\ndiv r4 8\nadd r3 r4\nmov r4 r2\ndiv r4 35\nlocalget r9 3302\nadd r9 1900\nmeshtexuv r9 r3 r4\nadd r3 r4\nmod r3 64\ncmp r3 32\njle open_wave_fold\nset r4 64\nsub r4 r3\nmov r3 r4\nlabel open_wave_fold\nmul r3 3\nadd r3 110\nlocalset 3311 r3\nlabel open_water_vertex_ready');
 out(require('./wetlands-car-transform.cjs')());
 cameraPoint('r0','r1','r2');
 out('localget r8 3302\nmov r9 r8\nadd r9 2000\nmeshvertex r9 r0 r1 r2\nmov r3 r8\nadd r3 1900\nmeshtexcopy r9 r3\nlocalget r4 3311\nmeshshade r9 r4\nadd r8 1\nlocalset 3302 r8\nlocalget r9 3301\ncmp r8 r9\njlt open_object_vertex\njmp open_object_draw\nlabel open_object_dispatch');
 out('localget r0 3300\ncmp r0 '+objects.length+'\njge open_objects_done');branchDispatch(0,objects.length,'open_case_');
 for(let index=0;index<objects.length;index++){
  const o=objects[index],skip=label('open_object_skip'),active=label('open_object_active');
  out(`label open_case_${index}\nlocalset 3319 ${o.drawId}`);
  if(o.gpuOnly)out('load8 r0 141\ncmp r0 1\njne open_object_next');
  if(o.nightOnly)out('load8 r0 526\ncmp r0 0\nje open_object_next');
  if(o.kind!=='car'){const c=point(o.segment);out(`load32 r0 100\nsub r0 ${2000000000+c[0]}\nmul r0 r0\nload32 r1 104\nsub r1 ${2000000000+c[2]}\nmul r1 r1\nadd r0 r1\ncmp r0 2500000000\njgt open_object_next`);}
  if(o.kind!=='car')out(`localget r0 3200\ncmp r0 ${o.segment+1}\njgt open_object_next\nlocalget r0 3201\ncmp r0 ${o.segment}\njle open_object_next`);
  if(['deer','bird','fish','butterfly','squirrel'].includes(o.kind))out('load8 r0 139\ncmp r0 1\nje open_object_next');
  if(o.kind==='water')out('load8 r0 140\ncmp r0 1\nje open_object_next');
  if(['deer','bird','butterfly','squirrel'].includes(o.kind))out('load8 r0 526\ncmp r0 2\nje open_object_next');
  if(['deer','fish','butterfly','squirrel'].includes(o.kind)){
   const c=point(o.segment);out(`load32 r0 100\nsub r0 ${2000000000+c[0]}\nmul r0 r0\nload32 r1 104\nsub r1 ${2000000000+c[2]}\nmul r1 r1\nadd r0 r1\ncmp r0 ${o.kind==='deer'?100000000:36000000}\njgt open_object_next`);
  }
  out('localset 3310 0\nlocalset 3311 150\nlocalset 3312 '+(o.kind==='water'?1:0)+'\nlocalset 3314 '+(o.kind==='car'?1:0)+'\nlocalset 3315 '+(o.kind==='squirrel'?(o.tail?2:1):0));
  if(['deer','fish','bird','butterfly','squirrel'].includes(o.kind))out('load32 r0 115\nmod r0 200\ncmp r0 100\njle '+active+'\nset r1 200\nsub r1 r0\nmov r0 r1\nlabel '+active+'\nsub r0 50\ndiv r0 2\nlocalset 3310 r0');
  if(o.kind==='water')out('load32 r0 115\ndiv r0 7\nmod r0 60\nadd r0 145\nlocalset 3311 r0');
  out(`localset 3316 ${o.origin[0]}\nlocalset 3317 ${o.origin[1]}\nlocalset 3318 ${o.origin[2]}\nlocalset 3301 ${o.vertices.length}\njmp open_model_${o.model}\nlabel ${skip}`);
 }
 out('jmp open_objects_done');
 models.forEach((o,index)=>{out('label open_model_'+index);o.vertices.forEach((p,i)=>out(`meshvertex ${1900+i} ${p.join(' ')}\nlocalset ${3400+i} ${o.tags[i]}\nmeshtexuv ${1900+i} ${Math.round(p[0]/25)} ${Math.round(p[2]/25)}`));out('jmp open_object_transform');});
 out('label open_object_draw');focus();
 // Share identical topology/material programs across water and animal instances.
 // XI still transforms each object's own vertices and evaluates its visibility.
 out('localget r0 3319');branchDispatch(0,drawGroups.size,'open_faces_');
 for(const {o,id} of drawGroups.values()){
  const skip=label('open_draw_skip');out('label open_faces_'+id);
  for(const f of o.faces){const v=f.ids.map(i=>2000+i).join(' ');if(o.kind==='car'&&f.material===58){out(`meshfacegradienttex ${v} 58 2 0 1 r9 r10 r11 60`);}else if(o.kind==='car'&&f.material===64){out('load8 r0 202\nmul r0 24\nadd r0 64');out(`meshfacegradient ${v} r0 24 r9 r10 r11 60`);}else out(o.kind==='water'?`meshfacegradienttex ${v} 32 8 0 1 r9 r10 r11 60`:o.kind==='car'&&f.material===228?`meshfacegradient ${v} 228 12 r9 r10 r11 60`:['dirt','shore','bridge'].includes(o.kind)&&f.material===9?`meshfacegradienttex ${v} 9 3 7 2 r9 r10 r11 60`:`meshface ${v} ${f.material} r9 r10 r11 60`);}
  out(`jmp open_object_next\nlabel ${skip}`);
 }
 out('label open_object_next\nlocalget r0 3300\nadd r0 1\nlocalset 3300 r0\njmp open_object_dispatch\nlabel open_objects_done');
 const triangles=objects.reduce((n,o)=>n+o.faces.length,0);
 if(triangles>1800||objects.some(o=>o.vertices.length>80))throw Error('Open-world prop budget exceeded '+JSON.stringify({triangles,oversize:objects.filter(o=>o.vertices.length>80).map(o=>({kind:o.kind,n:o.vertices.length})),counts:objects.reduce((a,o)=>(a[o.kind]=(a[o.kind]||0)+o.faces.length,a),{})}));
 console.log('OPEN_FOREST_PROPS',JSON.stringify({objects:objects.length,maxTriangles:triangles,fauna:['deer','bird','fish','butterfly','squirrel'],wetStats}));
 const maxActiveTriangles=Math.max(...Array.from({length:8},(_,sector)=>objects.filter(o=>o.kind==='car'||(o.segment>=Math.max(0,sector*10-10)&&o.segment<Math.min(80,sector*10+20))).reduce((n,o)=>n+o.faces.length,0)));
 return {objects:objects.length,triangles,maxActiveTriangles};
};
