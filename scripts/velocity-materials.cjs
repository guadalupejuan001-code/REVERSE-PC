'use strict';
// Fixed 8-bit material transport, with dedicated smooth lighting ramps.
const WORLD_MAP=new Map([[8,0],[38,1],[72,2],[189,3],[78,4],[208,5],[108,6],[206,7],[204,8],[202,9],[203,10],[205,11],[194,12],[195,13],[196,14],[197,15],[198,16],[199,17],[200,18],[201,19]]);
function worldMaterial(old){if(!WORLD_MAP.has(old))throw Error('Unknown world material '+old);return WORLD_MAP.get(old);}
const RAMPS=Object.freeze({paint:{base:64,count:24},glass:{base:184,count:24},tire:{base:208,count:4},rim:{base:212,count:12},aero:{base:228,count:12}});
const FLAT=Object.freeze({lampRed:224,lampWhite:225,grille:226,shadow:227,shadowSoft:28,shadowMid:29,shadowContact:30,seam:240,metal:241});
function mix(a,b,t){return a.map((n,i)=>Math.round(n+(b[i]-n)*t));}
const rgb=h=>[0,2,4].map(i=>parseInt(h.slice(i,i+2),16));
const hex=c=>c.map(n=>Math.max(0,Math.min(255,n)).toString(16).padStart(2,'0')).join('');
function buildPalette(){
 const p=Array(256).fill('485259');
 const world=['4c98c5','b7d3e2','667356','8d9f9d','858c82','ce4843','4b535a','e4e6df','a5adae','65503b','736046','806c50','203d2c','294b32','34583a','3c6240','446b45','4d744a','567d50','608457'];
 world.forEach((v,i)=>p[i]=v);
 // Asfalto con 8 matices, recorrido espacial constante en la pista XI.
 ['242b31','2a3238','30373e','343c43','394149','3e474f','465058','4e5961'].forEach((v,i)=>p[40+i]=v);
 for(let i=0;i<8;i++){p[24+i]=hex(mix(rgb('4b535a'),rgb('151e25'),i/7));p[32+i]=hex(mix(rgb('667356'),rgb('19271e'),i/7));}
 const paints=['e8edf3','b50920','135c9c','164c3b','d6a32b'];
 paints.forEach((paint,k)=>{const c=rgb(paint);for(let n=0;n<24;n++){
  const t=n/23;let v;
  if(k===0){
   if(t<.76)v=mix(rgb('63717d'),c,Math.pow(t/.76,.76));
   else v=mix(c,[252,253,255],Math.pow((t-.76)/.24,1.6)*.73);
  }else if(t<.76)v=mix(c.map(x=>Math.round(x*.15)),c,Math.pow(t/.76,.82));
  else v=mix(c,[226,239,247],Math.pow((t-.76)/.24,1.9)*.88);
  p[64+k*24+n]=hex(v);
 }});
 for(let n=0;n<24;n++){let v;if(n<=8)v=mix(rgb('070c12'),rgb('182936'),n/8);else if(n<=12)v=mix(rgb('253744'),rgb('82959c'),(n-9)/3);else v=mix(rgb('526877'),rgb('203545'),(n-13)/10);p[184+n]=hex(v);}
 ['10151a','1a2026','262d33','38414a'].forEach((v,i)=>p[208+i]=v);
 for(let n=0;n<12;n++)p[212+n]=hex(mix(rgb('273039'),rgb('f0f6f7'),Math.pow(n/11,.85)));
 p[224]='ff2437';p[225]='f0f9ff';p[226]='111a22';p[227]='151e25';
 for(let n=0;n<12;n++){
  const t=n/11;
  p[228+n]=hex(t<.72?mix(rgb('0b1016'),rgb('303b47'),Math.pow(t/.72,.85)):
    mix(rgb('303b47'),rgb('677787'),Math.pow((t-.72)/.28,1.9)));
 }
 p[3]='89958b'; // distant mountain slate
 p[4]='4d7041'; // real grassy verge, not gray concrete
 p[240]='343d47';p[241]='596977';
 p[242]='69202b'; // tail light at idle; braking lights use hot-red 224
 return p;
}
module.exports={worldMaterial,RAMPS,FLAT,buildPalette};
