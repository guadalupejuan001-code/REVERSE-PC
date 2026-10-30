'use strict';

// Original centimetre-scale sports coupe. Authoring only: the generated game
// renders/transforms this mesh in XI. Local axes are +x right, +y up, +z forward.
const DETAILS={high:{wheel:16,profile:[-1,-.82,-.45,0,.45,.82,1],roof:5},
  medium:{wheel:8,profile:[-1,0,1],roof:3},
  far:{wheel:4,profile:[-1,0,1],roof:3}};
const MATERIALS=Object.freeze(['paint','glass','tire','rim','lampRed','lampWhite','grille','shadow']);
const WHEELS=Object.freeze([{side:-1,z:-142},{side:1,z:-142},{side:-1,z:138},{side:1,z:138}]);
const BODY=[[-223,85,69,74,72],[-213,89,80,83,80],[-207,91,76,81,77],[-181,95,78,86,79],
  [-142,97,78,90,80],[-103,92,77,84,77],[-72,87,76,80,75],
  [0,85,75,78,73],[70,88,75,80,74],[99,92,72,83,76],
  [138,96,69,85,76],[177,91,64,77,69],[207,81,54,63,57],[223,72,46,53,48]];

function buildCarMesh(detail='high'){
  if(typeof detail==='number')detail=detail===0?'far':detail===1?'medium':'high';
  if(!DETAILS[detail])throw new RangeError('Car detail must be high, medium or far');
  const cfg=DETAILS[detail],vertices=[],faces=[],groups={},cache=new Map(),wheelParts=[];
  const point=p=>p.map(v=>Math.round(v));
  function vertex(p){p=point(p);const key=p.join(',');if(!cache.has(key)){cache.set(key,vertices.length);vertices.push(p);}return cache.get(key);}
  function triangle(a,b,c,material,group,normal){
    a=point(a);b=point(b);c=point(c);
    const u=b.map((v,i)=>v-a[i]),v=c.map((w,i)=>w-a[i]);
    const n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]];
    if(n.every(x=>x===0))return;
    if(normal&&n.reduce((sum,x,i)=>sum+x*normal[i],0)<0)[b,c]=[c,b];
    const indices=[vertex(a),vertex(b),vertex(c)],index=faces.length;
    faces.push({indices,material,group});(groups[group]??=[]).push(index);
  }
  function quad(a,b,c,d,m,g,n){triangle(a,b,c,m,g,n);triangle(a,c,d,m,g,n);}
  function patch(points,m,g,n){for(let i=1;i<points.length-1;i++)triangle(points[0],points[i],points[i+1],m,g,n);}
  function section(z){
    let i=0;while(i<BODY.length-2&&BODY[i+1][0]<z)i++;
    const a=BODY[i],b=BODY[i+1],t=(z-a[0])/(b[0]-a[0]);
    return a.map((x,k)=>k===0?z:x+(b[k]-x)*t);
  }
  function skin(z,f){
    const [,w,crown,haunch,edge]=section(z),x=Math.abs(f);
    let y=x<=.45?crown+2*x/.45:
      x<=.82?crown+2+(haunch-crown-2)*(x-.45)/.37:
      haunch+(edge-haunch)*(x-.82)/.18;
    return [w*f,y,z];
  }
  function arch(z){
    if(detail==='far')return 22;
    let y=22;
    for(const center of [-142,138]){const dz=z-center;if(Math.abs(dz)<=39)y=Math.max(y,34+Math.sqrt(Math.max(0,39*39-dz*dz)));}
    return y;
  }
  const stations=detail==='high'?[-223,-213,-207,-181,-175,-161,-142,-123,-109,-103,-72,0,70,99,105,119,138,157,171,177,207,223]:
    detail==='medium'?[-223,-181,-167,-142,-117,-103,99,113,138,163,177,223]:[-223,-142,-65,65,138,223];
  const rows=stations.map(z=>cfg.profile.map(f=>skin(z,f)));
  for(let i=0;i<rows.length-1;i++){
    const g=stations[i]>=99?'hood':detail==='high'&&stations[i]< -207?'ducktail':'body';
    for(let j=0;j<cfg.profile.length-1;j++)quad(rows[i][j],rows[i+1][j],rows[i+1][j+1],rows[i][j+1],'paint',g,[0,1,0]);
    for(const side of [-1,1]){
      const j=side<0?0:cfg.profile.length-1,a=rows[i][j],b=rows[i+1][j];
      const c=[b[0],Math.min(b[1]-1,arch(stations[i+1])),b[2]],d=[a[0],Math.min(a[1]-1,arch(stations[i])),a[2]];
      quad(a,b,c,d,'paint','body',[side,0,0]);
    }
  }
  // Curved end caps follow the loft, rather than closing a rectangular box.
  for(const index of [0,rows.length-1]){
    const row=rows[index],z=stations[index],sign=index===0?-1:1;
    if(detail==='far'){quad([row[0][0],22,z],row[0],row.at(-1),[row.at(-1)[0],22,z],'paint','body',[0,0,sign]);continue;}
    const outline=[[row[0][0],22,z],...row,[row.at(-1)[0],22,z]];
    const center=[0,32,z];
    for(let j=0;j<outline.length;j++)triangle(center,outline[j],outline[(j+1)%outline.length],'paint','body',[0,0,sign]);
  }
  quad([-71,18,-204],[-71,18,197],[71,18,197],[71,18,-204],'shadow','underbody',[0,-1,0]);

  // A low, compact fastback canopy, with a long hood and strongly raked glass.
  const roof=detail==='high'?[[-150,54,75,73],[-92,58,102,98],[-60,60,113,106],[-15,61,115,108],
      [30,57,113,105],[48,54,108,101],[108,69,75,73]]:
    detail==='medium'?[[-150,54,75,73],[-60,60,113,106],[-10,61,115,108],[48,54,108,101],[108,69,75,73]]:
      [[-145,54,77,74],[-55,60,113,106],[30,57,115,107],[108,69,75,73]];
  const roofFractions=cfg.roof===5?[-1,-.5,0,.5,1]:[-1,0,1];
  const canopy=roof.map(([z,w,c,e])=>roofFractions.map(f=>[w*f,c+(e-c)*f*f,z]));
  for(let i=0;i<canopy.length-1;i++){
    const z=(roof[i][0]+roof[i+1][0])/2,glass=z< -65||z>48,m=glass?'glass':'paint',g=glass?(z<0?'rearGlass':'windscreen'):'roof';
    for(let j=0;j<roofFractions.length-1;j++)quad(canopy[i][j],canopy[i+1][j],canopy[i+1][j+1],canopy[i][j+1],m,g,[0,1,z<0?-0.4:0.4]);
  }
  for(const side of [-1,1]){
    const p=(x,y,z)=>[side*x,y,z];
    if(detail==='far')quad(p(78,79,-126),p(60,107,-15),p(55,101,48),p(74,78,101),'glass','sideGlass',[side,.3,0]);
    else patch([p(78,79,-126),p(61,104,-61),p(55,101,48),p(74,78,101),p(81,77,-64)],'glass','sideGlass',[side,.3,0]);
    if(detail==='far')continue;
    triangle(p(80,77,-141),p(61,104,-61),p(78,79,-126),'paint','pillars',[side,0,-.25]);
    triangle(p(55,101,48),p(69,73,108),p(74,78,101),'paint','pillars',[side,0,.25]);
  }

  function ring(side,x,r,z,count){return Array.from({length:count},(_,k)=>{const t=k*Math.PI*2/count;return [side*x,34+r*Math.sin(t),z+r*Math.cos(t)];});}
  for(const wheel of WHEELS){
    const {side,z}=wheel,n=cfg.wheel,group='wheels',firstFace=faces.length;
    const rings=detail==='high'?[ring(side,76,34,z,n),ring(side,97,34,z,n),ring(side,100,22,z,n)]:
      detail==='medium'?[ring(side,76,34,z,n),ring(side,98,34,z,n),ring(side,100,22,z,n)]:[ring(side,78,34,z,n),ring(side,100,34,z,n)];
    for(let j=0;j<rings.length-1;j++)for(let k=0;k<n;k++){
      const next=(k+1)%n,t=(k+.5)*Math.PI*2/n;
      quad(rings[j][k],rings[j+1][k],rings[j+1][next],rings[j][next],'tire',group,[side*.2,Math.sin(t),Math.cos(t)]);
    }
    const rim=detail==='far'?rings.at(-1):ring(side,100,22,z,n);
    if(detail==='high'){
      const outer=Array.from({length:8},(_,i)=>rim[i*2]),inner=ring(side,100,18,z,8);
      for(let k=0;k<8;k++){
        const next=(k+1)%8;
        quad(outer[k],outer[next],inner[next],inner[k],'rim',group,[side,0,0]);
        triangle([side*99,34,z],[side*99,inner[k][1],inner[k][2]],[side*99,inner[next][1],inner[next][2]],'grille',group,[side,0,0]);
      }
      for(let k=0;k<5;k++){
        const theta=k*Math.PI*2/5+.15;
        const spoke=(r,t)=>[side*100,34+r*Math.sin(t),z+r*Math.cos(t)];
        quad(spoke(4,theta-.23),spoke(20,theta-.08),spoke(20,theta+.08),spoke(4,theta+.23),'rim',group,[side,0,0]);
      }
    }else if(detail==='far')quad(rim[0],rim[1],rim[2],rim[3],'rim',group,[side,0,0]);
    else for(let k=0;k<n;k++)triangle([side*100,34,z],rim[k],rim[(k+1)%n],k%2?'grille':'rim',group,[side,0,0]);
    wheelParts.push({side,axle:z>0?'front':'rear',center:[side*88,34,z],radius:34,faces:Array.from({length:faces.length-firstFace},(_,i)=>firstFace+i)});
  }

  // Light signatures follow the fascia curvature. No logos or copied marque cues.
  for(const side of [-1,1]){
    const p=(x,y,z)=>[side*x,y,z];
    quad(p(30,49,225),p(64,49,225),p(68,54,220),p(32,54,222),'lampWhite','headlights',[0,.3,1]);
    quad(p(20,61,-225),p(76,61,-224),p(78,66,-221),p(20,66,-223),'lampRed','taillights',[0,.2,-1]);
    if(detail!=='far'){
      // Side intake, short mirror stalk and compact aerodynamic mirror housing.
      if(detail==='medium')triangle(p(94,36,-91),p(91,60,-90),p(88,57,-55),'grille','sideVents',[side,0,0]);
      else quad(p(94,36,-91),p(91,60,-90),p(88,57,-55),p(92,39,-63),'grille','sideVents',[side,0,0]);
      if(detail==='high'){
        quad(p(73,83,75),p(93,84,69),p(93,86,66),p(72,85,72),'grille','mirrors',[0,1,0]);
        const a=p(89,85,63),b=p(100,84,62),c=p(100,91,66),d=p(88,92,67),e=p(88,86,79),f=p(98,85,77);
        quad(a,b,c,d,'glass','mirrors',[0,0,-1]);quad(d,c,f,e,'paint','mirrors',[0,1,0]);quad(b,f,e,d,'paint','mirrors',[0,0,1]);
      }
    }
  }
  if(detail!=='far'){
    quad([-51,24,225],[51,24,225],[57,43,225],[-57,43,225],'grille','frontGrille',[0,0,1]);
    quad([-73,15,-225],[73,15,-225],[67,39,-225],[-67,39,-225],'grille','diffuser',[0,-.2,-1]);
    if(detail==='high'){
      for(const x of [-51,-17,17,51])quad([x-1,15,-225],[x+1,15,-225],[x+1,37,-220],[x-1,37,-220],'shadow','diffuser',[0,0,-1]);
      for(const x of [-61,61]){
        const outer=Array.from({length:6},(_,k)=>[x+7*Math.cos(k*Math.PI/3),27+5*Math.sin(k*Math.PI/3),-225]);
        const inner=Array.from({length:6},(_,k)=>[x+5*Math.cos(k*Math.PI/3),27+3*Math.sin(k*Math.PI/3),-225]);
        for(let k=0;k<6;k++){
          const j=(k+1)%6;quad(outer[k],outer[j],inner[j],inner[k],'rim','exhaust',[0,0,-1]);
          triangle([x,27,-224],inner[k],inner[j],'grille','exhaust',[0,0,-1]);
        }
      }
      // The ducktail is a closed raised station of the body loft itself.
      for(const side of [-1,1])quad([side*51,73,108],[side*64,76,112],[side*66,72,158],[side*57,70,157],'grille','hoodVents',[0,1,0]);
    }
  }
  // Corner normals preserve glazing/rubber/metal seams while smoothing each
  // continuous painted shell. No extra transform vertices are required.
  const smoothKey=face=>face.material==='paint'&&['body','hood','ducktail'].includes(face.group)?'paintedShell':face.material+':'+face.group;
  const normalFans=new Map(),allSums=vertices.map(()=>[0,0,0]);
  const unit=v=>{const d=Math.hypot(...v)||1;return v.map(x=>x/d);};
  for(const face of faces){
    const [a,b,c]=face.indices.map(i=>vertices[i]),u=b.map((x,i)=>x-a[i]),v=c.map((x,i)=>x-a[i]);
    const normal=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]];
    face.normal=unit(normal);
    for(const index of face.indices){
      const key=index+'|'+smoothKey(face);
      normal.forEach((n,i)=>{allSums[index][i]+=n;});
      const fan=normalFans.get(key)||[];fan.push({area:normal,unit:face.normal});normalFans.set(key,fan);
    }
  }
  for(const face of faces)face.normals=face.group==='mirrors'?face.indices.map(()=>face.normal.slice()):
    face.indices.map(index=>{
      // Approximately75-degree crease: a broad adjacent panel must not pull
      // the normal of a narrow wheel-arch strip into its back hemisphere.
      const sum=[0,0,0];
      for(const n of normalFans.get(index+'|'+smoothKey(face)))
        if(n.unit.reduce((d,x,k)=>d+x*face.normal[k],0)>=.25)
          n.area.forEach((x,k)=>sum[k]+=x);
      return unit(sum);
    });
  const vertexNormals=allSums.map(unit);
  if(groups.hoodVents)groups.hood.push(...groups.hoodVents);
  groups.glass=faces.flatMap((f,i)=>f.material==='glass'?[i]:[]);
  const min=[0,1,2].map(axis=>Math.min(...vertices.map(p=>p[axis]))),max=[0,1,2].map(axis=>Math.max(...vertices.map(p=>p[axis])));
  return {detail,vertices,vertexNormals,faces,groups,bounds:{min,max,size:max.map((v,i)=>v-min[i])},
    landmarks:{wheelParts,wheelCenters:WHEELS.map(({side,z})=>[side*88,34,z]),wheelRadius:34,wheelbase:280,
      front:[0,49,225],rear:[0,62,-225],roof:[0,115,-15],hood:[0,71,145],driver:[0,82,0],
      axleFrontZ:138,axleRearZ:-142},materials:MATERIALS.slice()};
}
module.exports={buildCarMesh,MATERIALS};
