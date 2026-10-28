/* Runs only in the unprivileged YouTube WebView. Never exposes a native bridge. */
(() => {
  'use strict';
  if (window.__reverseMusic?.version === 2) return;
  let shield=false,timer=null,observer=null,altered=null,lastAction=-Infinity;
  let held=false,hostSuspended=false,mediaError='',commandId=0;
  let repeatOne=false,repeatTimer=null,repeatObserver=null,repeatVideo=null;
  const video=()=>document.querySelector('#movie_player video')||document.querySelector('#player-container-id video')
    ||document.querySelector('ytmusic-player video')||[...document.querySelectorAll('video')].find(v=>v.getClientRects().length)||document.querySelector('video');
  // An unrelated ad elsewhere in the page must never seek the current song.
  const adShowing=v=>!!v?.closest('.ad-showing,.ad-interrupting');
  const visible=e=>!!e&&e.getClientRects().length>0&&getComputedStyle(e).visibility!=='hidden'&&!e.disabled&&e.getAttribute('aria-disabled')!=='true';
  function transport(action,v=video()) {
    const root=v?.closest('#movie_player,.html5-video-player,#player-container-id')||document;
    return root.querySelector(action==='next'?'.ytp-next-button':'.ytp-prev-button')
      ||document.querySelector(action==='next'?'ytmusic-player-bar .next-button':'ytmusic-player-bar .previous-button');
  }
  const selectors='ytd-ad-slot-renderer,ytm-ad-slot-renderer,ytd-display-ad-renderer,ytd-promoted-sparkles-web-renderer,ytm-promoted-sparkles-web-renderer,ytmusic-mealbar-promo-renderer,.ytp-ad-overlay-container,#player-ads';
  function restore(){if(altered){altered.video.muted=altered.muted;altered=null;}}
  function pauseAll(){for(const v of document.querySelectorAll('video,audio'))v.pause();}
  function filter(){
    if(!shield)return;
    const v=video();
    if(!adShowing(v)){restore();lastAction=-Infinity;return;}
    if(altered?.video!==v){restore();altered={video:v,muted:v.muted};lastAction=-Infinity;}
    v.muted=true;
    const time=performance.now();if(time-lastAction<900)return;
    lastAction=time;
    const root=v.closest('.ad-showing,.ad-interrupting');
    const skip=root.querySelector('.ytp-ad-skip-button,.ytp-ad-skip-button-modern,.ytp-skip-ad-button');
    if(visible(skip)){skip.click();return;}
    if(Number.isFinite(v.duration)&&v.duration>0&&v.duration<600&&v.currentTime<v.duration-.1){try{v.currentTime=v.duration;}catch{}}
  }
  function setShield(enabled){
    enabled=!!enabled;
    if(shield===enabled&&timer!==null){filter();return;}
    shield=enabled;clearInterval(timer);timer=null;observer?.disconnect();observer=null;
    document.getElementById('reverse-music-filter')?.remove();
    if(!shield){restore();return;}
    const style=document.createElement('style');style.id='reverse-music-filter';style.textContent=selectors+'{display:none!important}';
    (document.head||document.documentElement).append(style);
    observer=new MutationObserver(filter);
    observer.observe(document.documentElement,{subtree:true,childList:true,attributes:true,attributeFilter:['class']});
    timer=setInterval(filter,600);filter();
  }
  function syncRepeat(){
    const v=video();
    if(repeatVideo&&repeatVideo!==v)repeatVideo.loop=false;
    repeatVideo=v;
    if(v)v.loop=repeatOne&&!adShowing(v)&&Number.isFinite(v.duration)&&v.duration>0;
  }
  function setRepeatOne(enabled){
    repeatOne=!!enabled;clearInterval(repeatTimer);repeatTimer=null;
    repeatObserver?.disconnect();repeatObserver=null;syncRepeat();
    if(repeatOne){
      repeatObserver=new MutationObserver(syncRepeat);
      repeatObserver.observe(document.documentElement,{subtree:true,childList:true,attributes:true,attributeFilter:['class','src']});
      repeatTimer=setInterval(syncRepeat,400);
    }
    return true;
  }
  for(const type of ['loadedmetadata','durationchange','emptied'])document.addEventListener(type,syncRepeat,true);
  document.addEventListener('ended',e=>{
    const v=video();
    if(e.target!==v||!repeatOne||held||hostSuspended||adShowing(v)||!Number.isFinite(v.duration)||v.duration<=0)return;
    e.stopImmediatePropagation();
    try{v.currentTime=0;command('play');}catch{}
  },true);
  function command(action,value){
    const attempt=++commandId;
    if(action==='hostPause'){hostSuspended=true;held=true;pauseAll();return true;}
    if(action==='hostResume'){hostSuspended=false;held=true;pauseAll();return true;}
    if(action==='hold'||action==='pause'){held=true;pauseAll();return true;}
    if(hostSuspended)return false;
    const v=video();
    if(action==='play'||(action==='toggle'&&v?.paused)){
      if(!v)return false;held=false;mediaError='';
      try{const playing=v.play();playing?.catch(()=>{if(attempt===commandId&&!held&&!hostSuspended)mediaError='No se pudo reproducir. Toca el video o vuelve a pulsar Reproducir.';});return true;}
      catch{mediaError='No se pudo reproducir. Toca el video para continuar.';return false;}
    }
    if(action==='toggle'){held=true;pauseAll();return !!v;}
    if(action==='seek'){
      if(!v||adShowing(v)||!Number.isFinite(v.duration)||v.duration<=0||!Number.isFinite(value))return false;
      try{v.currentTime=Math.max(0,Math.min(v.duration,value));return true;}catch{return false;}
    }
    if(action==='next'||action==='previous'){
      const button=transport(action,v);if(!visible(button))return false;
      held=false;mediaError='';button.click();return true;
    }
    return false;
  }
  // Interruptions stay paused until a real interaction or an explicit native Play.
  document.addEventListener('play',e=>{if((held||hostSuspended)&&e.target.matches?.('video,audio'))e.target.pause();},true);
  document.addEventListener('pause',e=>{
    const v=video();
    // WebView pauses this element when Android takes audio focus away.
    if(e.target===v&&!adShowing(v)&&!v.ended&&!v.seeking&&v.currentTime>0&&v.readyState>=2)held=true;
  },true);
  const interact=e=>{if(e.isTrusted&&!hostSuspended){commandId++;held=false;mediaError='';}};
  document.addEventListener('pointerdown',interact,true);document.addEventListener('keydown',interact,true);
  function snapshot(){
    syncRepeat();const v=video(),ad=adShowing(v);
    const title=document.querySelector('ytmusic-player-bar .title,ytm-slim-video-metadata-section-renderer h1,h1.ytd-watch-metadata,h1.title')?.textContent?.trim()
      ||document.title.replace(/ - YouTube(?: Music)?$/,'');
    return {url:location.href.slice(0,4096),title:(title||'YouTube').slice(0,240),hasMedia:!!v,paused:v?v.paused:true,ad,held,repeatOne,
      time:v&&Number.isFinite(v.currentTime)?v.currentTime:0,duration:v&&Number.isFinite(v.duration)?v.duration:0,
      live:!!v&&v.duration===Infinity,canSeek:!!v&&!ad&&Number.isFinite(v.duration)&&v.duration>0,
      canNext:visible(transport('next',v)),canPrevious:visible(transport('previous',v)),mediaError};
  }
  window.__reverseMusic={version:2,setShield,setRepeatOne,command,snapshot};
})();
