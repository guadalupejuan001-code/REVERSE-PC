'use strict';
// Actuation only: XI returns op/target. This module never reads command text.
const BBYQ_TARGETS=Object.freeze({1:'files',2:'calculator',3:'settings',4:'programs',5:'xi',6:'help',7:'control',8:'bbyq',9:'notes',10:'wallpaper'});
const bbyqControlTickets=new Set();
function bbyqAppCode(w,identity){
  if(w.app==='rxe')return w.rxeIdentity===identity||w.rxePath==='Aplicaciones/BBY-Q.rxe'?8:0;
  return Number(Object.keys(BBYQ_TARGETS).find(key=>BBYQ_TARGETS[key]===w.app)||0);
}
function captureBbyqDesktop(identity){
  const windows=state.windows.filter(w=>w.space===state.space);
  const present=Array(16).fill(0);for(const w of windows){const code=bbyqAppCode(w,identity);if(code)present[code]++;}
  const active=getWindow(activeId),activeCode=active&&active.space===state.space&&!active.min?bbyqAppCode(active,identity):0;
  // Resizing for Android's keyboard does not change which window an action
  // targets. Bind identity, workspace and visibility rather than pixel geometry.
  const view=JSON.stringify({space:state.space,active:activeId,windows:windows.map(w=>({id:w.id,app:w.app,identity:w.rxeIdentity||'',path:w.rxePath||'',min:!!w.min,max:!!w.max})).sort((a,b)=>a.id.localeCompare(b.id))});
  return {active:activeCode,count:windows.length,present,view};
}
function validBbyqAction(action){
  const {op,target}=action;
  return Number.isInteger(op)&&Number.isInteger(target)&&(
    (op===1&&target>=1&&target<=10)||
    (op>=2&&op<=6&&(target>=1&&target<=10||target===15))||
    ((op===7||op===8)&&target===0)||(op===9&&(target===13||target===14)));
}
function restoreBbyqScene(before){
  state.windows=before.windows;state.files=before.files;state.space=before.space;
  for(const el of $$('.window'))el.remove();
  programSessions.clear();for(const [id,data]of before.sessions)programSessions.set(id,data);
  for(const w of state.windows)mountWindow(w);
  switchSpace(before.space);queueSave();
}
async function executeBbyqControl(action,observation,identity){
  if(!action||!validBbyqAction(action)||typeof action.ticket!=='string'||!/^[0-9a-f-]{36}$/.test(action.ticket))return {success:false,reason:'La acción no cumple el contrato del escritorio.'};
  if(bbyqControlTickets.has(action.ticket))return {success:false,reason:'Esta acción ya fue procesada.'};
  bbyqControlTickets.add(action.ticket);if(bbyqControlTickets.size>256)bbyqControlTickets.delete(bbyqControlTickets.values().next().value);
  if(action.view!==observation.view||captureBbyqDesktop(identity).view!==observation.view)return {success:false,reason:'El escritorio cambió mientras BBY Q respondía. Pide la acción otra vez.'};
  const before={windows:JSON.parse(JSON.stringify(state.windows)),files:JSON.parse(JSON.stringify(state.files)),space:state.space,sessions:new Map(programSessions)};
  try{
    const {op,target}=action;
    if(op===1){
      const app=BBYQ_TARGETS[target];
      const existing=state.windows.filter(w=>w.space===state.space&&bbyqAppCode(w,identity)===target);
      if(app==='notes'&&existing.length>1)throw Error('Hay varias notas. Selecciona una ventana concreta.');
      if(app==='notes'&&existing.length===1)focusWindow(existing[0].id);
      else{
        if(state.windows.length>=12&&!existing.length)throw Error('Ya hay 12 ventanas abiertas.');
        if(!createWindow(app))throw Error('La ventana no pudo abrirse.');
      }
    }else if(op>=2&&op<=6){
      const matches=target===15?[getWindow(activeId)].filter(Boolean):state.windows.filter(w=>w.space===state.space&&bbyqAppCode(w,identity)===target);
      if(matches.length!==1)throw Error(matches.length?'Hay varias ventanas con ese nombre.':'Esa ventana ya no está abierta.');
      const w=matches[0];
      if(op===2)focusWindow(w.id);
      if(op===3)minimizeWindow(w);
      if(op===4){if(!w.max)toggleMax(w);focusWindow(w.id);}
      if(op===5){if(w.max)toggleMax(w);focusWindow(w.id);}
      if(op===6)closeWindow(w);
    }else if(op===7)arrangeWindows();
    else if(op===8){for(const w of state.windows.filter(w=>w.space===state.space))minimizeWindow(w);}
    else if(op===9)switchSpace(target===13?0:1);
    const applied=JSON.stringify({windows:state.windows,files:state.files,space:state.space});
    if(await persist()===false){
      if(JSON.stringify({windows:state.windows,files:state.files,space:state.space})===applied)restoreBbyqScene(before);
      return {success:false,reason:'No se pudo guardar la disposición del escritorio.'};
    }
    return {success:true,reason:''};
  }catch(error){
    restoreBbyqScene(before);
    return {success:false,reason:error.message||'No se aplicó la acción.'};
  }
}
