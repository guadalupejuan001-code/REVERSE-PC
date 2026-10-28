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
    window.__musicCommands=[];
    window.ReverseNative={
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
  for(const [width,height] of [[640,360],[844,390],[1440,900]]){
    const page=await desktop(width,height);
    await page.locator('#pinned-apps [data-task-app="music"]').click();await frame(page);
    check(await page.locator('.window[data-app="music"]').count()===1,'Music is a PC window');
    check(await page.locator('[data-music-stage]').boundingBox().then(r=>r.width>200&&r.height>=34),'Player has usable bounds');
    check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'No desktop overflow');
    check(await page.evaluate(()=>[...document.querySelectorAll('.taskbar button')].filter(e=>e.getClientRects().length).every(e=>{const r=e.getBoundingClientRect();return r.x>=0&&r.right<=innerWidth;})),'Taskbar still fits');
    check(await page.evaluate(()=>!window.__musicCommands.some(c=>c.action==='open')),'Opening the window never autoplays or loads YouTube');
    await page.screenshot({path:path.join(out,'music-'+width+'.png')});
    await page.locator('[data-music-search] input').fill('café & jazz');await page.locator('[data-music-search] button').click();
    check(await page.evaluate(()=>window.__musicCommands.some(c=>c.action==='open'&&c.data.input==='café & jazz')),'Search reaches native player unchanged');
    await page.evaluate(()=>window.ReverseMusic.update({loaded:true,hasMedia:true,paused:false,time:72,duration:240,title:'Canción <img src=x onerror=alert(1)>',url:'https://www.youtube.com/watch?v=abcdefghijk&si=secret',blocked:3}));
    check(await page.locator('[data-music-time]').innerText()==='1:12 / 4:00','Real status controls time display');
    await page.locator('[data-music-action="shield"]').click();
    check(await page.evaluate(()=>window.__musicCommands.some(c=>c.action==='shield'&&c.data.enabled===false)),'Shield toggle reaches native filtering preference');
    await page.locator('[data-music-action="toggle"]').click();
    check(await page.evaluate(()=>window.__musicCommands.some(c=>c.action==='toggle')),'Playback button reaches native controls');
    await page.locator('[data-music-seek]').evaluate(el=>{el.value='120';el.dispatchEvent(new Event('change',{bubbles:true}));});
    check(await page.evaluate(()=>window.__musicCommands.some(c=>c.action==='seek'&&c.data.time===120)),'Seek reaches native media control');
    await page.locator('[data-music-action="favorite"]').click();
    await page.locator('[data-music-action="favorite"]').click();
    check(await page.evaluate(()=>state.music.favorites.length===1),'Favorites deduplicate');
    check(await page.evaluate(()=>state.music.favorites[0].url==='https://m.youtube.com/watch?v=abcdefghijk'),'Favorites drop tracking');
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
    const profile=await page.evaluate(()=>JSON.parse(JSON.stringify(state)));
    const restored=await desktop(width,height,profile);await frame(restored);
    check(await restored.evaluate(()=>state.music.favorites.length===1),'Favorites survive native profile restoration');
    check(await restored.evaluate(()=>!window.__musicCommands.some(c=>c.action==='open')),'Restoration never starts playback');
    await restored.evaluate(()=>closeWindow(state.windows.find(w=>w.app==='music')));await frame(restored);
    check(await restored.evaluate(()=>window.__musicCommands.some(c=>c.action==='close')),'Closing releases native player');
    await restored.close();await page.close();
  }
  const page=await context.newPage();
  await page.setContent('<div id="movie_player"><video></video></div><div id="player-ads">Ad</div><h1 class="title">Fixture song</h1><button class="ytp-ad-skip-button">Skip ad</button>');
  await page.evaluate(()=>{
    const v=document.querySelector('video');window.__clock={time:10,duration:180,paused:true,plays:0,skips:0};
    Object.defineProperties(v,{currentTime:{get:()=>__clock.time,set:t=>__clock.time=t},duration:{get:()=>__clock.duration},paused:{get:()=>__clock.paused}});
    v.play=async()=>{__clock.paused=false;__clock.plays++;};v.pause=()=>__clock.paused=true;
    document.querySelector('button').onclick=()=>__clock.skips++;
  });
  await page.addScriptTag({path:path.join(assets,'music/youtube.js')});
  await page.evaluate(()=>window.__reverseMusic.setShield(true));
  check(await page.evaluate(()=>__clock.time===10&&!document.querySelector('video').muted),'Enabling shield leaves songs and their sound unchanged');
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
  check(errors.length===0,JSON.stringify(errors));check(requests.length===0,'Fixtures make no external requests');
  await browser.close();
  fs.writeFileSync(path.join(out,'results.json'),JSON.stringify({checks,page_errors:errors,external_requests:requests,scope:'Desktop/profile/transport and DOM media fixtures; no live YouTube streaming or Android device playback verified.'},null,2)+'\n');
  console.log('MUSIC_UI_PASS',checks);
})().catch(async e=>{console.error(e.stack);if(browser)await browser.close();process.exitCode=1;});
