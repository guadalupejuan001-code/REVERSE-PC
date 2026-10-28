'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {chromium}=require('playwright');
const assets=path.resolve(__dirname,'../app/src/main/assets');
const out=path.resolve(process.argv[2]||'evidence/music');fs.mkdirSync(out,{recursive:true});
let checks=0;const errors=[],requests=[];let browser,context;
function check(value,message){assert.ok(value,message);checks++;}
async function frame(page){await page.evaluate(()=>new Promise(r=>requestAnimationFrame(()=>requestAnimationFrame(r))));}
async function desktop(width,height,profile=null){
  const page=await context.newPage();await page.setViewportSize({width,height});
  page.on('pageerror',e=>errors.push(e.message));page.on('request',r=>{if(/^https?:/.test(r.url()))requests.push(r.url());});
  await page.addInitScript(profile=>{
    try{localStorage.removeItem('reverse.workbench.v1');}catch{}
    window.__musicCommands=[];window.__exports=[];
    window.ReverseNative={
      exportText(name,contents,mime){window.__exports.push({name,contents,mime});},
      loadProfile:()=>JSON.stringify({ok:true,profile:profile?JSON.stringify(profile):null}),
      request(id,operation){setTimeout(()=>window.ReverseAndroid.complete(id,operation==='saveProfile'?{ok:true}:{ok:false,error:'No XI backend in music UI fixture'}),0);},
      music(action,raw){const data=JSON.parse(raw);window.__musicCommands.push({action,data});
        if(action==='status')setTimeout(()=>window.ReverseMusic.update({available:true,shield:true,blocked:0}),0);
      }
    };
  },profile);
  await page.goto('file://'+path.join(assets,'workbench/index.html'));
  await page.waitForFunction(()=>window.ReverseShell?.mode==='desktop');return page;
}
(async()=>{
  browser=await chromium.launch({headless:true,executablePath:process.env.REVERSE_BROWSER,args:['--no-sandbox','--no-zygote','--single-process','--disable-gpu','--disable-software-rasterizer']});
  context=await browser.newContext({locale:'es-ES'});
  for(const [width,height] of [[640,360],[740,360],[844,390],[915,412],[1024,600],[1440,900]]){
    const page=await desktop(width,height);
    await page.locator('#pinned-apps [data-task-app="music"]').click();await frame(page);
    check(await page.locator('.window[data-app="music"]').count()===1,'Music is a PC window');
    const stageFound=await page.locator('[data-music-stage]').count();
    if(!stageFound){const diag=await page.evaluate(()=>({shell:window.ReverseShell?.mode, musicType:typeof musicHTML, qdType:typeof qdStudioHTML, musicUI:document.querySelector('.window[data-app="music"] .window-content')?.innerHTML.slice(0,1200), windows:[...document.querySelectorAll('.window')].map(x=>x.dataset.app)}));throw Error('Music stage absent: '+JSON.stringify({errors,diag}));}
    check(await page.locator('[data-music-stage]').boundingBox().then(r=>r.width>200&&r.height>=34),'Player has usable bounds');
    check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No desktop overflow');
    check(await page.evaluate(()=>[...document.querySelectorAll('.taskbar button')].filter(e=>e.getClientRects().length).every(e=>{const r=e.getBoundingClientRect();return r.x>=0&&r.right<=innerWidth;})),'Taskbar still fits');
    check(await page.evaluate(()=>!window.__musicCommands.some(c=>c.action==='open')),'Opening the window never autoplays or loads YouTube');
    await page.screenshot({path:path.join(out,'music-'+width+'.png')});
    await page.locator('[data-music-search] input').fill('café & jazz');await page.locator('[data-music-search] button').click();
    check(await page.evaluate(()=>window.__musicCommands.some(c=>c.action==='open'&&c.data.input==='café & jazz')),'Search reaches native player unchanged');
    await page.evaluate(()=>window.ReverseMusic.update({loaded:true,phase:'ready',hasMedia:true,canSeek:true,canNext:false,canPrevious:false,paused:false,time:72,duration:240,title:'Canción <img src=x onerror=alert(1)>',url:'https://www.youtube.com/watch?v=abcdefghijk&si=secret',blocked:3}));
    check(await page.locator('[data-music-time]').innerText()==='1:12 / 4:00','Real status controls time display');
    check(await page.locator('[data-music-action="next"]').isDisabled(),'Next is disabled without a playlist control');
    await page.locator('[data-music-seek]').focus();await page.evaluate(()=>window.ReverseMusic.update({time:73}));
    check(await page.locator('[data-music-seek]').inputValue()==='73','Focused seek keeps following playback');
    await page.locator('[data-music-seek]').evaluate(el=>{el.dataset.scrubbing='true';el.value='90';});
    await page.evaluate(()=>window.ReverseMusic.update({time:74}));
    check(await page.locator('[data-music-seek]').inputValue()==='90','Polling does not move a slider being dragged');
    await page.locator('[data-music-seek]').evaluate(el=>el.dispatchEvent(new Event('change',{bubbles:true})));
    await page.evaluate(()=>window.ReverseMusic.update({time:91}));
    check(await page.locator('[data-music-seek]').inputValue()==='91','Progress follows playback again after seeking');
    await page.locator('[data-music-search] input').fill('Bach: concierto');
    await page.locator('[data-music-tab="favorites"]').click();await page.locator('[data-music-tab="player"]').click();
    check(await page.locator('[data-music-search] input').inputValue()==='Bach: concierto','Draft search survives tab switches');

    await page.locator('[data-music-action="downloads"]').click();await frame(page);
    check(await page.locator('[data-music-tab="downloads"]').getAttribute('aria-selected')==='true','Download button opens the offline library');
    check(await page.evaluate(()=>window.__musicCommands.filter(c=>c.action==='bounds').at(-1).data.visible===false),'Remote YouTube view cannot cover the download form');
    const audioURL='https://audio.example/song.mp3?signature=a%2Bb&format=mp3';
    await page.locator('[data-music-download] input').fill(audioURL);await page.locator('[data-music-download] button').click();
    check(await page.evaluate(url=>window.__musicCommands.some(c=>c.action==='download'&&c.data.url===url),audioURL),'Download submits the explicit audio URL unchanged');
    const localId='12345678-1234-1234-1234-123456789abc',savingId='12345678-1234-1234-1234-123456789abd',errorId='12345678-1234-1234-1234-123456789abe';
    await page.evaluate(({localId,savingId,errorId})=>window.ReverseMusic.update({library:[
      {id:localId,title:'Offline <img src=x onerror=alert(1)>',status:'ready',bytes:1048576,total:1048576,duration:120},
      {id:savingId,title:'Descargando.wav',status:'saving',bytes:250,total:1000,duration:0},
      {id:errorId,title:'Audio fallido',status:'error',error:'El servidor no respondió.',bytes:0,total:0,duration:0},
      {id:'<invalid>',title:'Bad ID',status:'ready'}
    ]}),{localId,savingId,errorId});
    check(await page.locator('[data-music-row]').count()===3,'Offline library validates identifiers and renders real transfer states');
    check(await page.locator('[data-music-row] img').count()===0,'Local filenames are rendered as text');
    check(await page.locator('[data-music-local]:enabled').count()===1,'Only fully saved audio can be played');
    check(await page.locator('[data-music-row="'+savingId+'"] [data-music-local-status]').innerText()==='Guardando… 25 %','Download progress reflects received bytes');
    check(await page.locator('[data-music-row="'+errorId+'"] [data-music-local-status]').innerText()==='El servidor no respondió.','Download failure is visible');
    await page.locator('[data-music-local="'+localId+'"]').click();
    check(await page.evaluate(id=>window.__musicCommands.some(c=>c.action==='local'&&c.data.id===id),localId),'Offline playback selects a native library identifier');
    await page.evaluate(localId=>window.ReverseMusic.update({source:'local',localId,loaded:true,phase:'ready',hasMedia:true,paused:false,title:'Offline <img src=x onerror=alert(1)>',url:'',time:5,duration:120,canSeek:true,canNext:false,canPrevious:false}),localId);
    check(await page.locator('[data-music-source]').innerText()==='Sin conexión','Player identifies offline playback');
    check(await page.locator('[data-music-action="favorite"]').isDisabled(),'Local files cannot be saved as YouTube favorites');
    check(await page.locator('[data-music-action="reload"]').isDisabled(),'YouTube reload cannot interrupt local playback');
    await page.locator('[data-music-delete="'+savingId+'"]').focus();
    await page.evaluate(({localId,savingId,errorId})=>window.ReverseMusic.update({library:[
      {id:localId,title:'Offline <img src=x onerror=alert(1)>',status:'ready',bytes:1048576,total:1048576,duration:120},
      {id:savingId,title:'Descargando.wav',status:'saving',bytes:500,total:1000,duration:0},
      {id:errorId,title:'Audio fallido',status:'error',error:'El servidor no respondió.',bytes:0,total:0,duration:0}
    ]}),{localId,savingId,errorId});
    check(await page.evaluate(id=>document.activeElement?.dataset.musicDelete===id,savingId),'Progress updates preserve the focused library control');
    check(await page.locator('[data-music-download] input').inputValue()===audioURL,'Transfer polling preserves the typed download link');
    await page.locator('[data-music-action="import"]').click();
    check(await page.evaluate(()=>window.__musicCommands.some(c=>c.action==='import')),'Import button requests the native audio picker');
    await page.locator('[data-music-delete="'+savingId+'"]').click();
    check(await page.evaluate(id=>window.__musicCommands.some(c=>c.action==='removeLocal'&&c.data.id===id),savingId),'Delete/cancel targets only the selected library identifier');
    check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'Download library fits the desktop width');
    await page.locator('.music-downloads').evaluate(el=>{document.activeElement?.blur();el.scrollTop=0;});
    await page.screenshot({path:path.join(out,'downloads-'+width+'.png')});
    await page.locator('[data-music-tab="player"]').click();await frame(page);
    check(await page.evaluate(()=>window.__musicCommands.filter(c=>c.action==='bounds').at(-1).data.visible===false),'A local track keeps the remote overlay hidden on the player tab');
    await page.evaluate(()=>window.ReverseMusic.update({source:'youtube',localId:'',loaded:true,phase:'ready',hasMedia:true,canSeek:true,canNext:false,canPrevious:false,paused:false,time:72,duration:240,title:'Canción <img src=x onerror=alert(1)>',url:'https://www.youtube.com/watch?v=abcdefghijk&si=secret',blocked:3}));

    await page.locator('[data-music-action="shield"]').click();
    check(await page.evaluate(()=>window.__musicCommands.some(c=>c.action==='shield'&&c.data.enabled===false)),'Shield toggle reaches native filtering preference');
    await page.locator('[data-music-action="shield"]').click();
    check(await page.evaluate(()=>window.__musicCommands.filter(c=>c.action==='shield').slice(-2).map(c=>c.data.enabled).join(',')==='false,true'),'Rapid shield toggles preserve each user action');
    await page.locator('[data-music-action="toggle"]').click();
    check(await page.evaluate(()=>window.__musicCommands.some(c=>c.action==='toggle')),'Playback button reaches native controls');
    await page.locator('[data-music-seek]').evaluate(el=>{el.value='120';el.dispatchEvent(new Event('change',{bubbles:true}));});
    check(await page.evaluate(()=>window.__musicCommands.some(c=>c.action==='seek'&&c.data.time===120)),'Seek reaches native media control');
    await page.locator('[data-music-action="favorite"]').click();
    await page.locator('[data-music-action="favorite"]').click();
    check(await page.evaluate(()=>state.music.favorites.length===1),'Favorites deduplicate');
    check(await page.evaluate(()=>state.music.favorites[0].url==='https://m.youtube.com/watch?v=abcdefghijk'),'Favorites drop tracking');
    await page.locator('[data-music-action="repeat"]').click();
    check(await page.evaluate(()=>state.music.repeatOne===true),'Repeat one is a persistent preference');
    check(await page.locator('[data-music-action="repeat"]').getAttribute('aria-pressed')==='true','Repeat button shows its active state');
    await page.evaluate(()=>createWindow('control',{tab:'apps'}));await frame(page);
    check(await page.locator('.music-control-panel').count()===1,'Control center includes live music controls');
    check(await page.locator('[data-music-panel-title]').innerText()==='Canción <img src=x onerror=alert(1)>','Control panel displays remote titles as text');
    await page.locator('[data-music-panel-action="toggle"]').click();
    check(await page.evaluate(()=>window.__musicCommands.filter(c=>c.action==='toggle').at(-1).data.windowId===state.windows.find(w=>w.app==='music').id),'Control panel targets the music window');
    await page.locator('[data-music-panel-action="repeat"]').click();
    check(await page.evaluate(()=>state.music.repeatOne===false),'Control panel changes the same repeat setting');
    await page.locator('[data-music-panel-action="repeat"]').click();
    await page.evaluate(()=>{const w=state.windows.find(w=>w.app==='music');toggleMax(w);});
    check(await page.locator('[data-control-window] small').allInnerTexts().then(rows=>rows.some(s=>s==='REVERSE Music · Maximizada')),'Window inventory updates without rebuilding controls');
    await page.evaluate(()=>{const w=state.windows.find(w=>w.app==='music');toggleMax(w);});
    for(const tab of ['system','appearance','backup']){await page.locator('[data-ui-tab="'+tab+'"]').click();check(await page.locator('.control-main').innerText().then(t=>t.length>30),'Control panel tab renders: '+tab);}
    await page.locator('.control-main [data-action="export-backup"]').click();
    check(await page.evaluate(()=>{const backup=JSON.parse(window.__exports.at(-1).contents);return backup.music.repeatOne===true&&backup.music.favorites.length===1;}),'Control panel backup includes repeat and favorites');
    await page.locator('[data-ui-tab="apps"]').click();
    await page.locator('[data-music-panel-action="open"]').click();await frame(page);
    check(await page.evaluate(()=>getWindow(activeId).app==='music'),'Control panel opens the existing music player');
    await page.locator('[data-music-tab="favorites"]').click();await frame(page);
    check(await page.locator('.music-favorite img').count()===0,'Remote titles are rendered as text');
    check(await page.evaluate(()=>window.__musicCommands.filter(c=>c.action==='bounds').at(-1).data.visible===false),'Native view hides on library tab');
    await page.locator('[data-music-favorite="0"]').click();await frame(page);
    check(await page.evaluate(()=>window.__musicCommands.filter(c=>c.action==='open').at(-1).data.input==='https://m.youtube.com/watch?v=abcdefghijk'),'Favorite opens canonical video');
    await page.evaluate(()=>createWindow('music'));check(await page.locator('.window[data-app="music"]').count()===1,'Player is a singleton');
    await page.evaluate(()=>createWindow('files'));await frame(page);
    check(await page.evaluate(()=>window.__musicCommands.filter(c=>c.action==='bounds').at(-1).data.visible===false),'Player cannot cover another application');
    await page.evaluate(()=>focusWindow(state.windows.find(w=>w.app==='music').id));await frame(page);
    check(await page.evaluate(()=>window.__musicCommands.filter(c=>c.action==='bounds').at(-1).data.visible===true),'Native view follows focused window');
    await page.locator('#launcher-toggle').click();await frame(page);
    check(await page.evaluate(()=>window.__musicCommands.filter(c=>c.action==='bounds').at(-1).data.visible===false),'Native view does not cover desktop menus');
    await page.evaluate(()=>hideLauncher());await frame(page);
    await page.evaluate(()=>{const w=state.windows.find(w=>w.app==='music');toggleMax(w);});await frame(page);
    const bounds=await page.evaluate(()=>window.__musicCommands.filter(c=>c.action==='bounds').at(-1).data);
    check(bounds.visible&&bounds.x>=0&&bounds.y>=0&&bounds.x+bounds.w<=width&&bounds.y+bounds.h<=height,'Maximized bounds fit native host');
    await page.evaluate(()=>minimizeWindow(state.windows.find(w=>w.app==='music')));await frame(page);
    check(await page.evaluate(()=>window.__musicCommands.filter(c=>c.action==='bounds').at(-1).data.visible===false),'Minimizing hides the surface');
    check(await page.evaluate(()=>!window.__musicCommands.some(c=>c.action==='close')),'Minimizing keeps the player session');
    await page.evaluate(()=>window.ReverseMusic.update({phase:'loading',loaded:true,hasMedia:false}));
    check(await page.locator('[data-music-title]').innerText()==='Sin reproducción'&&await page.locator('[data-music-action="favorite"]').isDisabled(),'Navigation clears the previous track and favorite target');
    const profile=await page.evaluate(()=>JSON.parse(JSON.stringify(state)));
    profile.windows.push({...profile.windows.find(w=>w.app==='music'),id:'duplicate-music',space:1});
    const restored=await desktop(width,height,profile);await frame(restored);
    check(await restored.evaluate(()=>state.music.favorites.length===1),'Favorites survive native profile restoration');
    check(await restored.evaluate(()=>state.music.repeatOne===true),'Repeat preference survives restoration without autoplay');
    check(await restored.evaluate(()=>state.windows.filter(w=>w.app==='music').length===1),'Imported profiles cannot restore two native players');
    check(await restored.evaluate(()=>!window.__musicCommands.some(c=>c.action==='open')),'Restoration never starts playback');
    await restored.evaluate(()=>closeWindow(state.windows.find(w=>w.app==='music')));await frame(restored);
    check(await restored.evaluate(()=>window.__musicCommands.some(c=>c.action==='close')),'Closing releases native player');
    await restored.evaluate(()=>{createWindow('music');const old=state.windows.find(w=>w.app==='music');closeWindow(old);createWindow('music');window.ReverseMusic.update({windowId:old.id,loaded:true,hasMedia:true,title:'Stale track'});});await frame(restored);
    check(await restored.locator('[data-music-title]').innerText()!=='Stale track','A closed window cannot update a new player');
    check(await restored.evaluate(()=>window.__musicCommands.filter(c=>c.action==='close').length===2),'Immediate reopen closes each old native instance exactly once');
    await restored.close();await page.close();
  }
  const page=await context.newPage();
  await page.setContent('<div id="movie_player"><video></video><button class="ytp-ad-skip-button">Skip ad</button></div><div id="player-ads">Ad</div><h1 class="title">Fixture song</h1>');
  await page.evaluate(()=>{
    const v=document.querySelector('video');window.__clock={time:10,duration:180,paused:true,plays:0,skips:0};
    Object.defineProperties(v,{currentTime:{get:()=>__clock.time,set:t=>__clock.time=t},duration:{get:()=>__clock.duration},paused:{get:()=>__clock.paused}});
    v.play=async()=>{__clock.paused=false;__clock.plays++;};v.pause=()=>__clock.paused=true;
    document.querySelector('button').onclick=()=>{__clock.skips++;__clock.time=180;};
  });
  await page.addScriptTag({path:path.join(assets,'music/youtube.js')});
  await page.evaluate(()=>window.__reverseMusic.setShield(true));
  check(await page.evaluate(()=>__clock.time===10&&!document.querySelector('video').muted),'Enabling shield leaves songs and their sound unchanged');
  await page.evaluate(()=>{const ad=document.createElement('div');ad.id='unrelated';ad.className='ad-showing';document.body.prepend(ad);});await page.waitForTimeout(700);
  check(await page.evaluate(()=>__clock.time===10&&!document.querySelector('video').muted),'An unrelated ad cannot skip or mute the song');
  await page.evaluate(()=>document.getElementById('unrelated').remove());
  check(await page.locator('#player-ads').isVisible()===false,'Cosmetic ad slots are hidden');
  await page.evaluate(()=>document.getElementById('movie_player').classList.add('ad-showing'));
  await page.waitForFunction(()=>__clock.time===180&&__clock.skips>0);
  check(await page.evaluate(()=>document.querySelector('video').muted),'Explicit ads are muted and skipped');
  await page.evaluate(()=>{document.getElementById('movie_player').classList.remove('ad-showing');__clock.time=0;});
  await page.waitForFunction(()=>!document.querySelector('video').muted);
  check(await page.evaluate(()=>__clock.time===0),'The song after an ad is not skipped');
  await page.evaluate(()=>window.__reverseMusic.command('play'));check(await page.evaluate(()=>!__clock.paused),'Play calls actual media element');
  await page.evaluate(()=>window.__reverseMusic.command('pause'));check(await page.evaluate(()=>__clock.paused),'Pause calls actual media element');
  await page.evaluate(()=>window.__reverseMusic.command('seek',60));check(await page.evaluate(()=>__clock.time===60),'Seek controls the media element');
  await page.evaluate(()=>{document.getElementById('movie_player').classList.add('ad-showing');window.__reverseMusic.setShield(false);__clock.time=7;});
  await page.waitForTimeout(700);
  check(await page.evaluate(()=>__clock.time===7&&!document.querySelector('video').muted&&!document.getElementById('reverse-music-filter')),'Disabling removes ad actions/styles and restores audio');
  check(await page.locator('#player-ads').isVisible(),'Disabling restores cosmetic slots');
  await page.evaluate(()=>{document.getElementById('movie_player').classList.remove('ad-showing');window.__reverseMusic.setRepeatOne(true);});
  check(await page.evaluate(()=>document.querySelector('video').loop),'Repeat one enables the media loop');
  await page.evaluate(()=>document.getElementById('movie_player').classList.add('ad-showing'));await page.waitForFunction(()=>!document.querySelector('video').loop);
  check(await page.evaluate(()=>!document.querySelector('video').loop),'Repeat never loops a marked advertisement');
  await page.evaluate(()=>document.getElementById('movie_player').classList.remove('ad-showing'));await page.waitForFunction(()=>document.querySelector('video').loop);
  check(await page.evaluate(()=>document.querySelector('video').loop),'Repeat resumes for the song after an ad');
  await page.evaluate(()=>window.__reverseMusic.setRepeatOne(false));
  check(await page.evaluate(()=>!document.querySelector('video').loop),'Turning repeat off restores normal playback');
  await page.evaluate(()=>{const v=document.querySelector('video');Object.defineProperty(v,'readyState',{value:4});__clock.time=0;window.__reverseMusic.command('play');v.pause();v.dispatchEvent(new Event('pause'));});
  check(await page.evaluate(()=>window.__reverseMusic.snapshot().held),'A system pause at the start of a track also blocks automatic resume');
  await page.evaluate(()=>window.__reverseMusic.command('hostPause'));
  check(await page.evaluate(()=>window.__reverseMusic.command('play')===false&&__clock.paused),'A suspended host cannot start playback');
  await page.evaluate(()=>{window.__reverseMusic.command('hostResume');__clock.paused=false;document.querySelector('video').dispatchEvent(new Event('play'));});
  check(await page.evaluate(()=>__clock.paused&&window.__reverseMusic.snapshot().held),'Returning to the app keeps automatic playback paused');
  await page.evaluate(()=>window.__reverseMusic.command('play'));check(await page.evaluate(()=>!__clock.paused&&!window.__reverseMusic.snapshot().held),'Explicit Play releases the interruption');
  await page.evaluate(async()=>{const v=document.querySelector('video');v.play=()=>new Promise((resolve,reject)=>window.rejectPlay=reject);window.__reverseMusic.command('play');window.__reverseMusic.command('pause');window.rejectPlay(Error('Interrupted by user'));await Promise.resolve();});
  check(await page.evaluate(()=>window.__reverseMusic.snapshot().mediaError===''),'A canceled Play promise cannot overwrite a newer Pause');
  check(errors.length===0,JSON.stringify(errors));check(requests.length===0,'Fixtures make no external requests');
  await browser.close();
  fs.writeFileSync(path.join(out,'results.json'),JSON.stringify({checks,page_errors:errors,external_requests:requests,scope:'Desktop/profile/transport and DOM media fixtures; no live YouTube streaming or Android device playback verified.'},null,2)+'\n');
  console.log('MUSIC_UI_PASS',checks);
})().catch(async e=>{console.error(e.stack);if(browser)await browser.close();process.exitCode=1;});
