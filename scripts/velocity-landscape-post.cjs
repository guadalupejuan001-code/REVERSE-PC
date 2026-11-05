'use strict';
/**
 * Deterministic XI scene finishing pass.
 * Enhances the EXISTING REgraphics scene without introducing a second renderer.
 * All assets remain emitted XI; this program is never shipped as runtime gameplay.
 */
const fs=require('node:fs'),path=require('node:path');
const ROOT=path.resolve(__dirname,'../reverse-os-android/app/src/main/assets/velocity');
// Jet rig precedes shadows and vegetation; audit ID mapping each time the rig changes.
const CAMERA=2048,TREE_START=1552,ROCK_START=1566,GRASS_START=1579,END=1591;
// Each of 32 Cedar actors depicts a 3-tree grove at a fixed 9-face cost.
// Main tree uses the 5-face volumetric canopy. The 4 old trunk faces become
// paired low-poly pine silhouettes, keeping shader IDs and triangle budget.
const treeShape=[
 [14,970,-16],[246,440,33],[100,565,209],[-161,388,205],
 [-258,475,-61],[-101,412,-217],
 [-18,0,0],[18,0,0],[18,390,0],
 [-18,390,0],[-170,680,35],[-50,540,12],
 [170,720,-30],[50,550,-12]
];
const rock=[
 [24,105,-8],[-183,48,-93],[-72,85,-153],[126,64,-142],
 [215,43,55],[57,77,155],[-162,58,132],
 [-183,0,-93],[-72,0,-153],[126,0,-142],
 [215,0,55],[57,0,155],[-162,0,132]
];
const grass=[
 [-42,0,-22],[29,0,17],[-8,103,-17],
 [-13,0,-55],[24,0,63],[5,116,15],
 [-61,0,43],[45,0,-42],[23,77,9],
 [-18,63,-6],[16,63,4],[1,83,-2]
];
function requireOnce(source,needle,label){
 const at=source.indexOf(needle);
 if(at<0||source.indexOf(needle,at+needle.length)>=0)
  throw Error('Landscape XI contract: '+label+' missing or repeated');
 return at;
}
function change(source,from,to,label){
 requireOnce(source,from,label);return source.replace(from,to);
}
function face(a,b,c,mat){
 const rock=mat===3||mat===4||mat===8||mat===10;
 return 'meshfacegradienttex '+(a+CAMERA)+' '+(b+CAMERA)+' '+(c+CAMERA)+
  (rock?' 22 2 7 3':' 12 8 6 2')+' r9 r10 r11 60';
}
function tailLamps(source){
 if(source.includes('label brake_dim_'))return source;
 let count=0;
 source=source.replace(/^meshface (\d+) (\d+) (\d+) 224 r9 r10 r11 60$/gm,
   (_,a,b,c)=>{
    count++;const id=a+'_'+b+'_'+c,dim='brake_dim_'+id,done='brake_done_'+id;
    return ['localget r0 11','cmp r0 0','jne '+dim,
      'load8 r0 129','cmp r0 1','jne '+dim,
      'meshface '+a+' '+b+' '+c+' 224 r9 r10 r11 60',
      'jmp '+done,'label '+dim,
      'meshface '+a+' '+b+' '+c+' 242 r9 r10 r11 60','label '+done].join('\n');
   });
 if(count!==6)throw Error('Expected six authored vehicle tail-light faces, got '+count);
 return source;
}
function finishScene(content,options={}){
 let source=tailLamps(content);
 if(source.includes('label nature_model_ready'))return source; // deterministic rerun
 // Shape the five-sided tree canopy and its crossed real trunk with asymmetry.
 for(let i=0;i<treeShape.length;i++){
  const id=TREE_START+i;
  source=source.replace(new RegExp('^meshvertex '+id+' -?\\d+ -?\\d+ -?\\d+$','m'),
    'meshvertex '+id+' '+treeShape[i].join(' '));
  source=source.replace(new RegExp('^meshtexuv '+id+' -?\\d+ -?\\d+$','m'),
    'meshtexuv '+id+' '+Math.round(treeShape[i][0]/7)+' '+Math.round(treeShape[i][2]/7));
 }
 const newPositions=[...rock,...grass];
 const additions=newPositions.map((v,j)=>{
  const id=ROCK_START+j;
  return 'meshvertex '+id+' '+v.join(' ')+'\nmeshtexuv '+id+
    ' '+Math.round(v[0]/7)+' '+Math.round(v[2]/7);
 }).join('\n');
 source=change(source,'localset 512 256',
   additions+'\nlocalset 512 256','new rock and grass geometry');
 const newMetadata=newPositions.map((_,j)=>{
  const id=ROCK_START+j;
  return 'localset '+(512+id)+' '+id*2048;
 }).join('\n');
 // Landscape vertices are inserted between the author's preallocated
 // vehicle-effect IDs. The actor marker is unique across both render sources.
 source=change(source,'localset 11 0',
   newMetadata+'\nlocalset 11 0',
   'XI vertex metadata extension');
 // Dense roadside grove: 32 cedars, 4 boulders and 4 underbrush clusters.
 const choose=['localget r0 3120','mod r0 10','cmp r0 7','je nature_rock_model','cmp r0 8','je nature_rock_model',
   'cmp r0 9','je nature_grass_model',
   'set r0 '+TREE_START,'mov r9 r0','localset 132 r9',
   'set r0 '+ROCK_START,'mov r9 r0','localset 134 r9','jmp nature_model_ready',
   'label nature_rock_model',
   'set r0 '+ROCK_START,'mov r9 r0','localset 132 r9',
   'set r0 '+GRASS_START,'mov r9 r0','localset 134 r9','jmp nature_model_ready',
   'label nature_grass_model',
   'set r0 '+GRASS_START,'mov r9 r0','localset 132 r9',
   'set r0 '+END,'mov r9 r0','localset 134 r9',
   'label nature_model_ready'].join('\n');
 source=change(source,
   'label forest_choose_model\nset r0 '+TREE_START+'\nmov r9 r0\nlocalset 132 r9\nset r0 '+ROCK_START+'\nmov r9 r0\nlocalset 134 r9',
   'label forest_choose_model\n'+choose,'roadside model dispatch');
 const treeStart=source.indexOf('label emit_tree\n');
 const next=source.indexOf('\nlabel next_actor',treeStart);
 if(treeStart<0||next<0)throw Error('Existing tree face emission not located');
 const original=source.slice(treeStart+'label emit_tree\n'.length,next);
 const originalFaces=original.split('\n');
 if(originalFaces.length!==9)throw Error('Tree triangle count changed');
 const trunk=(a,b,c)=>'meshfacegradienttex '+[a,b,c].map(i=>TREE_START+i+CAMERA).join(' ')+' 9 3 7 2 r9 r10 r11 60';
 const canopyFaces=originalFaces.slice(0,5).map(s=>s.replace(/^meshface (\d+) (\d+) (\d+) \d+/, 'meshfacegradienttex $1 $2 $3 12 8 6 2'));
 const groveFaces=[...canopyFaces,trunk(6,7,8),trunk(6,8,9),trunk(9,8,10),trunk(9,10,11),trunk(8,9,12),trunk(8,12,13)];
 if(groveFaces.length!==11)throw Error('Forest grove must cost nine faces');
 const rockFaces=[],grassFaces=[];
 for(let k=0;k<6;k++){
  const n=(k+1)%6;
  rockFaces.push(face(ROCK_START,ROCK_START+1+k,ROCK_START+1+n,[3,8,4,3,10,8][k]));
  rockFaces.push(face(ROCK_START+1+k,ROCK_START+7+k,ROCK_START+1+n,[4,3,8,4,3,8][k]));
  rockFaces.push(face(ROCK_START+7+k,ROCK_START+7+n,ROCK_START+1+n,[4,3,8,4,3,8][k]));
 }
 for(let k=0;k<4;k++){
  const a=GRASS_START+k*3,b=a+1,c=a+2;
  grassFaces.push(k===3?'meshface '+[a,b,c].map(i=>i+CAMERA).join(' ')+' 243 r9 r10 r11 60':face(a,b,c,14+k));
  grassFaces.push(k===3?'meshface '+[c,b,a].map(i=>i+CAMERA).join(' ')+' 243 r9 r10 r11 60':face(c,b,a,12+k));
 }
 if(28*11+8*rockFaces.length+4*grassFaces.length!==484)
  throw Error('Forest triangle budget is not bounded');
 const full=['label emit_tree','localget r0 3120','mod r0 10','cmp r0 7','je nature_emit_rock','cmp r0 8',
   'je nature_emit_rock','cmp r0 9','je nature_emit_grass',
   ...canopyFaces,'localget r0 112','sub r0 1000000','cmp r0 12000','jgt next_actor',...groveFaces.slice(5),'jmp next_actor','label nature_emit_rock',
   ...rockFaces,'jmp next_actor','label nature_emit_grass',
   ...grassFaces].join('\n');
 source=source.slice(0,treeStart)+full+source.slice(next);
 // Irregular peak heights break the old eight-identical-cones skyline.
 source=change(source,
   'meshtri r1 r3 999990 r4 r5 999990 r2 r3 999990 18',
   'mov r6 r7\nmul r6 17\nmod r6 5\nmul r6 r0\ndiv r6 140\nsub r5 r6\n'+
   'meshtri r1 r3 999990 r4 r5 999990 r2 r3 999990 18',
   'uneven mountain ridge');
 const labels=source.split('\n').filter(s=>s.startsWith('label ')).map(s=>s.slice(6));
 if(new Set(labels).size!==labels.length)throw Error('Landscape produced duplicate XI labels');
 if(source.length>=512*1024)throw Error('Landscape XI exceeds engine source ceiling');
 return source;
}
function run(options={}){
 const changed=[];
 for(const name of ['render.xi','render4k.xi']){
  const filename=path.join(ROOT,name);
  const before=fs.readFileSync(filename,'utf8'),after=finishScene(before,options);
  if(before!==after)fs.writeFileSync(filename,after);
  changed.push({name,bytes:Buffer.byteLength(after),updated:before!==after,
    trees:28,rocks:8,grassClumps:4,faces:484});
 }
 return changed;
}
if(require.main===module)console.log(JSON.stringify(run()));
module.exports={run,finishScene};
