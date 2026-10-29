/* Motion parallax: real orientation input, opt-in and recalibratable; no fake sensor samples. */
const clamp=(x,a,b)=>Math.max(a,Math.min(b,x));
const wrap=x=>Math.atan2(Math.sin(x),Math.cos(x));
export function createMotion(scene,onChange=()=>{},native=window.ReverseGraphics){
  let active=false,mode='',last=null,base=null;
  const send=(x,y)=>{scene.setMotion(x,y);onChange();};
  function sample(raw){
    if(!active||!raw||!['yaw','pitch','roll'].every(k=>Number.isFinite(raw[k])))return;
    last=raw;if(!base)base={...raw};
    const yaw=wrap(raw.yaw-base.yaw),pitch=wrap(raw.pitch-base.pitch);
    send(clamp(yaw*.12,-.052,.052),clamp(pitch*.12,-.052,.052));
  }
  const fromNative=e=>sample(e.detail);
  const fromBrowser=e=>{
    if(e.alpha==null||e.beta==null||e.gamma==null)return;
    sample({yaw:e.alpha*Math.PI/180,pitch:e.beta*Math.PI/180,roll:e.gamma*Math.PI/180});
  };
  window.addEventListener('prisma-motion',fromNative);
  const supported=()=>{
    if(typeof native?.motionAvailable==='function')return !!native.motionAvailable();
    return typeof DeviceOrientationEvent!=='undefined';
  };
  async function enable(want){
    if(!want){if(mode==='native')native.motionEnabled(false);if(mode==='browser')window.removeEventListener('deviceorientation',fromBrowser);active=false;mode='';last=null;base=null;send(0,0);return {enabled:false,reason:'Desactivado'};}
    if(!supported())return {enabled:false,reason:'Este dispositivo o navegador no expone un sensor de orientación'};
    if(typeof native?.motionAvailable==='function'&&native.motionAvailable()){
      base=null;last=null;active=true;mode='native';native.motionEnabled(true);
      return {enabled:true,reason:'Sensor Android activado. Mueve el teléfono y calibra si lo necesitas'};
    }
    try{
      if(typeof DeviceOrientationEvent.requestPermission==='function'){
        const permission=await DeviceOrientationEvent.requestPermission();
        if(permission!=='granted')return {enabled:false,reason:'El permiso del sensor no fue concedido'};
      }
      base=null;last=null;active=true;mode='browser';window.addEventListener('deviceorientation',fromBrowser);
      return {enabled:true,reason:'Sensor del navegador activado; pendiente de lecturas'};
    }catch{return {enabled:false,reason:'No fue posible acceder al sensor de orientación'};}
  }
  function calibrate(){if(!active)return false;if(!last)return false;base={...last};send(0,0);return true;}
  return {enable,calibrate,supported,get active(){return active;},get receiving(){return !!last;}};
}
