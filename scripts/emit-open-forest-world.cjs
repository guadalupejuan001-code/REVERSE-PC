'use strict';
const {points,heights,point,headings}=require('./open-forest-map.cjs');
module.exports=function({out,load,focus,cameraPoint,label,trig}){
 const objects=[];
 function object(segment,kind='ground'){const o={segment,kind,vertices:[],faces:[],tags:[],cache:new Map()};objects.push(o);return o;}
 function vertex(o,p,tag=0){const key=p.join(',')+';'+tag;if(!o.cache.has(key)){o.cache.set(key,o.vertices.length);o.vertices.push(p.map(Math.round));o.tags.push(tag);}return o.cache.get(key);}
 function tri(o,a,b,c,material=9,tags=[0,0,0]){o.faces.push({ids:[a,b,c].map((p,i)=>vertex(o,p,tags[i])),material});}
 function quad(o,a,b,c,d,m=9){tri(o,a,b,c,m);tri(o,a,c,d,m);}
 function strip(i,left,right,y0,y1,kind='ground',material=9){const o=object(i,kind);quad(o,point(i,left,y0),point(i+1,left,y1),point(i+1,right,y1),point(i,right,y0),material);return o;}
 const apron=object(0,'dirt');quad(apron,[-650,1,-1200],[650,1,-1200],[650,1,1000],[-650,1,1000],9);
 // River beneath the bridge: a real cut-out in the land, not blue road paint.
 for(let i=28;i<=28;i++)strip(i,-6000,6000,heights[i]-165,heights[i+1]-165,'water',32);
 // Irregular lake ribbon and sloped muddy banks, all in the same world coordinates.
 for(let i=49;i<=62;i++){
  const edge=900+Math.round(120*Math.sin(i*.83));
  strip(i,edge,5800+Math.round(400*Math.sin(i*.37)),0,0,'water',32);
  const o=object(i,'shore');quad(o,point(i,450),point(i+1,450),point(i+1,edge,0),point(i,edge,0),9);
 }
 for(const i of [50,54,60]){
  const o=object(i,'flora'),c=point(i,750,Math.round(heights[i]/3));
  for(let k=0;k<3;k++)tri(o,[c[0]-10+k*12,c[1],c[2]+k*9],[c[0]+k*12,c[1]+110-k*10,c[2]+k*9],[c[0]+7+k*12,c[1],c[2]+k*9],14);
 }
 // Small bridge rails use boxes, while the physical bridge remains one lane.
 function box(o,c,size,material=9){const [x,y,z]=c,[a,b,d]=size.map(v=>v/2),v=[[-a,-b,-d],[a,-b,-d],[a,b,-d],[-a,b,-d],[-a,-b,d],[a,-b,d],[a,b,d],[-a,b,d]].map(p=>p.map((n,k)=>n+c[k]));for(const face of [[0,1,2,3],[4,7,6,5],[0,4,5,1],[3,2,6,7],[0,3,7,4],[1,5,6,2]])quad(o,...face.map(i=>v[i]),material);}
 for(const i of [28]){const o=object(i,'bridge');for(const side of [-1,1]){const a=point(i,side*225,heights[i]+45),b=point(i+1,side*225,heights[i+1]+45);box(o,a.map((v,k)=>(v+b[k])/2),[18,90,1900],9);}}
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
 for(const i of [51,56,60]){const o=object(i,'fish'),c=point(i,1200,3);tri(o,[c[0]-8,c[1],c[2]-24],[c[0]+11,c[1],c[2]],[c[0]-8,c[1],c[2]+24],22);tri(o,[c[0]-8,c[1],c[2]+18],[c[0]-18,c[1],c[2]+34],[c[0]+6,c[1],c[2]+29],22);}
 for(const i of [11,42,75]){const o=object(i,'butterfly'),c=point(i,600,heights[i]+65);tri(o,[c[0],c[1],c[2]-4],[c[0]-13,c[1]+9,c[2]],[c[0],c[1],c[2]+9],243,[0,1,0]);tri(o,[c[0],c[1],c[2]-4],[c[0],c[1],c[2]+9],[c[0]+13,c[1]+9,c[2]],243,[0,0,1]);}
 out('localset 3300 0\njmp open_object_dispatch\nlabel open_object_transform\nlocalset 3302 0\nlabel open_object_vertex');
 out('localget r8 3302\nmov r9 r8\nadd r9 1900\nmeshread r0 r1 r2 r9\nlocalget r3 3310\nadd r0 r3\nmov r9 r8\nadd r9 3400\nlocalget r9 r9\ncmp r9 0\nje open_object_motion_done\nload32 r3 115\nmod r3 40\ncmp r3 20\njle open_flap_fold\nset r4 40\nsub r4 r3\nmov r3 r4\nlabel open_flap_fold\nsub r3 10\ncmp r9 1\njne open_leg_motion\nmul r3 3\nadd r1 r3\njmp open_object_motion_done\nlabel open_leg_motion\nmul r3 r9\nadd r2 r3\nlabel open_object_motion_done');
 out('localget r3 3312\ncmp r3 0\nje open_water_vertex_ready\nmov r3 r0\ndiv r3 50\nload32 r4 115\ndiv r4 8\nadd r3 r4\nmov r4 r2\ndiv r4 35\nlocalget r9 3302\nadd r9 1900\nmeshtexuv r9 r3 r4\nadd r3 r4\nmod r3 64\ncmp r3 32\njle open_wave_fold\nset r4 64\nsub r4 r3\nmov r3 r4\nlabel open_wave_fold\nmul r3 3\nadd r3 110\nlocalset 3311 r3\nlabel open_water_vertex_ready');
 cameraPoint('r0','r1','r2');
 out('localget r8 3302\nmov r9 r8\nadd r9 2000\nmeshvertex r9 r0 r1 r2\nmov r3 r8\nadd r3 1900\nmeshtexcopy r9 r3\nlocalget r4 3311\nmeshshade r9 r4\nadd r8 1\nlocalset 3302 r8\nlocalget r9 3301\ncmp r8 r9\njlt open_object_vertex\njmp open_object_draw\nlabel open_object_dispatch');
 for(let index=0;index<objects.length;index++){
  const o=objects[index],skip=label('open_object_skip'),active=label('open_object_active');
  out(`localget r0 3300\ncmp r0 ${index}\njne ${skip}\nlocalget r0 3200\ncmp r0 ${o.segment+1}\njgt open_object_next\nlocalget r0 3201\ncmp r0 ${o.segment}\njle open_object_next`);
  if(['deer','bird','fish','butterfly'].includes(o.kind))out('load8 r0 139\ncmp r0 1\nje open_object_next');
  if(o.kind==='water')out('load8 r0 140\ncmp r0 1\nje open_object_next');
  if(['deer','bird','butterfly'].includes(o.kind))out('load8 r0 526\ncmp r0 2\nje open_object_next');
  if(['deer','fish','butterfly'].includes(o.kind)){
   const c=point(o.segment);out(`load32 r0 100\nsub r0 ${2000000+c[0]}\nmul r0 r0\nload32 r1 104\nsub r1 ${2000000+c[2]}\nmul r1 r1\nadd r0 r1\ncmp r0 ${o.kind==='deer'?100000000:36000000}\njgt open_object_next`);
  }
  out('localset 3310 0\nlocalset 3311 150\nlocalset 3312 '+(o.kind==='water'?1:0));
  if(['deer','fish','bird','butterfly'].includes(o.kind))out('load32 r0 115\nmod r0 200\ncmp r0 100\njle '+active+'\nset r1 200\nsub r1 r0\nmov r0 r1\nlabel '+active+'\nsub r0 50\ndiv r0 2\nlocalset 3310 r0');
  if(o.kind==='water')out('load32 r0 115\ndiv r0 7\nmod r0 60\nadd r0 145\nlocalset 3311 r0');
  o.vertices.forEach((p,i)=>{out(`meshvertex ${1900+i} ${p.join(' ')}\nlocalset ${3400+i} ${o.tags[i]}\nmeshtexuv ${1900+i} ${Math.round(p[0]/25)} ${Math.round(p[2]/25)}`);});
  out(`localset 3301 ${o.vertices.length}\njmp open_object_transform\nlabel ${skip}`);
 }
 out('jmp open_objects_done\nlabel open_object_draw');focus();
 for(let index=0;index<objects.length;index++){
  const o=objects[index],skip=label('open_draw_skip');out(`localget r0 3300\ncmp r0 ${index}\njne ${skip}`);
  for(const f of o.faces){const v=f.ids.map(i=>2000+i).join(' ');out(o.kind==='water'?`meshfacegradienttex ${v} 32 8 0 1 r9 r10 r11 60`:['dirt','shore','bridge'].includes(o.kind)?`meshfacegradienttex ${v} 9 3 7 2 r9 r10 r11 60`:`meshface ${v} ${f.material} r9 r10 r11 60`);}
  out(`jmp open_object_next\nlabel ${skip}`);
 }
 out('label open_object_next\nlocalget r0 3300\nadd r0 1\nlocalset 3300 r0\njmp open_object_dispatch\nlabel open_objects_done');
 // A bounded road-space headlight pool. The vehicle yaw, not camera orbit,
 // steers the beam. There are no extra lights, shadow maps or GPU passes.
 out('load8 r0 526\ncmp r0 0\nje open_headlights_done\nload16 r0 108');
 trig('r0','r3','r4','r5','r6');
 out('localset 3323 r3\nlocalset 3324 r4');
 const beam=[[-65,190,225],[65,190,225],[360,1700,0],[-360,1700,0]];
 beam.forEach(([side,forward,shade],i)=>{
  out(`localget r0 3324\nmul r0 ${side}\nlocalget r2 3323\nmul r2 ${forward}\nadd r0 r2\ndiv r0 16384\nload32 r1 100\nsub r1 2000000\nadd r0 r1\nlocalget r2 3324\nmul r2 ${forward}\nlocalget r1 3323\nmul r1 ${side}\nsub r2 r1\ndiv r2 16384\nload32 r1 104\nsub r1 2000000\nadd r2 r1\nload16 r1 520\nadd r1 4`);
  cameraPoint('r0','r1','r2');
  out(`meshvertex ${2000+i} r0 r1 r2\nmeshshade ${2000+i} ${shade}`);
 });
 focus();
 out('meshfacegradient 2000 2001 2002 40 16 r9 r10 r11 60\nmeshfacegradient 2000 2002 2003 40 16 r9 r10 r11 60\nlabel open_headlights_done');
 const triangles=objects.reduce((n,o)=>n+o.faces.length,0);
 if(triangles>600||objects.some(o=>o.vertices.length>80))throw Error('Open-world prop budget exceeded');
 console.log('OPEN_FOREST_PROPS',JSON.stringify({objects:objects.length,maxTriangles:triangles,fauna:['deer','bird','fish','butterfly']}));
 return {objects:objects.length,triangles};
};
