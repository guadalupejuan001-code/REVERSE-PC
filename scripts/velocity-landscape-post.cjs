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
const treeShape=[
 [31,846,-25],[223,245,22],[99,287,168],[-122,228,201],
 [-239,275,-13],[-97,210,-192],
 [-23,0,-12],[14,0,0],[15,290,-8],[-16,276,-18],
 [0,0,-23],[0,0,20],[11,278,12],[-9,275,-21]
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
 [41,0,39],[-43,0,-36],[10,88,-35]
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
 return 'meshface '+(a+CAMERA)+' '+(b+CAMERA)+' '+(c+CAMERA)+
  ' '+mat+' r9 r10 r11 60';
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
function finishScene(content){
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
  return 'localset '+(512+id)+' '+id*512;
 }).join('\n');
 const lastTree='localset '+(512+ROCK_START-1)+' '+((ROCK_START-1)*512+256);
 source=change(source,lastTree+'\nlocalset 11 0',
   lastTree+'\n'+newMetadata+'\nlocalset 11 0',
   'XI vertex metadata extension');
 // Select actual 3D templates per roadside object: 20 trees, 10 rocks, 10 grass clumps.
 const choose=['localget r0 11','mod r0 4','cmp r0 2','je nature_rock_model',
   'cmp r0 3','je nature_grass_model',
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
   'label tree_actor\nset r0 '+TREE_START+'\nmov r9 r0\nlocalset 132 r9\nset r0 '+ROCK_START+'\nmov r9 r0\nlocalset 134 r9',
   'label tree_actor\n'+choose,'roadside model dispatch');
 const treeStart=source.indexOf('label emit_tree\n');
 const next=source.indexOf('\nlabel next_actor',treeStart);
 if(treeStart<0||next<0)throw Error('Existing tree face emission not located');
 const original=source.slice(treeStart+'label emit_tree\n'.length,next);
 if(original.split('\n').length!==9)throw Error('Tree triangle count changed');
 const rockFaces=[],grassFaces=[];
 for(let k=0;k<6;k++){
  const n=(k+1)%6;
  rockFaces.push(face(ROCK_START,ROCK_START+1+k,ROCK_START+1+n,[3,8,4,3,10,8][k]));
  rockFaces.push(face(ROCK_START+1+k,ROCK_START+7+k,ROCK_START+1+n,[4,3,8,4,3,8][k]));
 }
 for(let k=0;k<4;k++){
  const a=GRASS_START+k*3,b=a+1,c=a+2;
  grassFaces.push(face(a,b,c,14+k));
  grassFaces.push(face(c,b,a,12+k));
 }
 if(20*9+10*rockFaces.length+10*grassFaces.length!==380)
  throw Error('Terrain budget would exceed original renderer face count');
 const full=['label emit_tree','localget r0 11','mod r0 4','cmp r0 2',
   'je nature_emit_rock','cmp r0 3','je nature_emit_grass',
   original,'jmp next_actor','label nature_emit_rock',
   ...rockFaces,'jmp next_actor','label nature_emit_grass',
   ...grassFaces].join('\n');
 source=source.slice(0,treeStart)+full+source.slice(next);
 // Give grassy verges a 22cm natural berm; no collision boundary is modified.
 source=change(source,
   'set r0 -1000\nset r1 -670\nset r2 0\nset r3 0',
   'set r0 -1000\nset r1 -670\nset r2 22\nset r3 0','left raised verge');
 source=change(source,
   'set r0 670\nset r1 1000\nset r2 0\nset r3 0',
   'set r0 670\nset r1 1000\nset r2 0\nset r3 22','right raised verge');
 // Irregular peak heights break the old eight-identical-cones skyline.
 source=change(source,
   'meshtri r1 r3 999990 r4 r5 999990 r2 r3 999990 3',
   'mov r6 r7\nmul r6 17\nmod r6 5\nmul r6 r0\ndiv r6 140\nsub r5 r6\n'+
   'meshtri r1 r3 999990 r4 r5 999990 r2 r3 999990 3',
   'uneven mountain ridge');
 const labels=source.split('\n').filter(s=>s.startsWith('label ')).map(s=>s.slice(6));
 if(new Set(labels).size!==labels.length)throw Error('Landscape produced duplicate XI labels');
 if(source.length>=512*1024)throw Error('Landscape XI exceeds engine source ceiling');
 return source;
}
function run(){
 const changed=[];
 for(const name of ['render.xi','render4k.xi']){
  const filename=path.join(ROOT,name);
  const before=fs.readFileSync(filename,'utf8'),after=finishScene(before);
  if(before!==after)fs.writeFileSync(filename,after);
  changed.push({name,bytes:Buffer.byteLength(after),updated:before!==after,
    trees:20,rocks:10,grassClumps:10,faces:380});
 }
 return changed;
}
if(require.main===module)console.log(JSON.stringify(run()));
module.exports={run,finishScene};
