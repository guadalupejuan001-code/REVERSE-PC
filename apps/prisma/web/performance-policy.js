// PRISMA Cycle 06: deterministic frame-budget policy, independent of hardware.
// UI quality and game logic are deliberately independent.
export const QUALITY_LEVELS=Object.freeze(['battery','balanced','high']);
export function nextVisualQuality({quality='balanced',slowFrames=0,fastFrames=0,
  cooldownUntil=0,now=0,frameMs=16.67}={}){
 const current=QUALITY_LEVELS.includes(quality)?quality:'balanced';
 if(now<cooldownUntil)return {quality:current,slowFrames,fastFrames,cooldownUntil};
 const slow=frameMs>24?slowFrames+1:0;
 const fast=frameMs<15.5?fastFrames+1:0;
 let target=current;
 if(slow>=20)target=current==='high'?'balanced':'battery';
 else if(fast>=120)target=current==='battery'?'balanced':'high';
 if(target===current)return {quality:current,slowFrames:slow,fastFrames:fast,cooldownUntil};
 return {quality:target,slowFrames:0,fastFrames:0,cooldownUntil:now+8000};
}
export function visualBudget(quality='balanced',reduced=false){
 if(reduced)return {particles:24,rig:'battery',material:0,lightCones:false};
 if(quality==='battery')return {particles:48,rig:'battery',material:0,lightCones:false};
 if(quality==='high')return {particles:240,rig:'high',material:1,lightCones:true};
 return {particles:120,rig:'auto',material:1,lightCones:true};
}
