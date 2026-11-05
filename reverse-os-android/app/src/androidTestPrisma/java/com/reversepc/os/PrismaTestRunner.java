package com.reversepc.os;

import android.app.Activity;
import android.app.Instrumentation;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.SystemClock;
import android.view.MotionEvent;
import android.webkit.WebView;
import java.io.File;
import java.io.FileOutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import org.json.JSONArray;
import org.json.JSONObject;

/** Actual Android WebView, touch, music source and XI/native renderer smoke test. */
public final class PrismaTestRunner extends Instrumentation {
    private RxeGraphicsActivity game;
    private ActivityMonitor gameMonitor;
    private String phase="full";
    @Override public void onCreate(Bundle args){super.onCreate(args);phase=args==null?"full":args.getString("phase","full");start();}
    private static void require(boolean v,String why){if(!v)throw new AssertionError(why);}
    private String js(String source)throws Exception{
        CountDownLatch done=new CountDownLatch(1);String[] out={"null"};
        runOnMainSync(()->{
            Activity current=gameMonitor==null?null:gameMonitor.getLastActivity();
            if(current instanceof RxeGraphicsActivity&&!current.isDestroyed())game=(RxeGraphicsActivity)current;
            WebView view=game==null||game.isDestroyed()?null:game.testingWebView();
            if(view==null){done.countDown();return;}
            try{view.evaluateJavascript(source,v->{out[0]=v;done.countDown();});}
            catch(IllegalStateException closed){done.countDown();}
        });
        // Android may replace the WebView during the initial landscape relaunch;
        // callbacks belonging to its destroyed document are never delivered.
        // Readiness polls retry the current activity instead of killing setup.
        if(!done.await(10,TimeUnit.SECONDS))return "null";return out[0];
    }
    private void until(String condition,int seconds)throws Exception{
        long deadline=SystemClock.uptimeMillis()+seconds*1000L;
        while(SystemClock.uptimeMillis()<deadline){if("true".equals(js(condition)))return;SystemClock.sleep(100);}
        throw new AssertionError("Timed out: "+condition+"; diagnostic="+js("(()=>{const d=document.getElementById('game')?.dataset;return {playing:document.body.classList.contains('is-playing'),holds:d?.holdCompletions,phrases:d?.phrasesCompleted,constellations:d?.constellations,score:document.getElementById('score')?.textContent,inputs:window.__fixtureEvents,errors:window.__errors}})()"));
    }
    private void tap(String selector)throws Exception{
        long deadline=SystemClock.uptimeMillis()+15000;
        while(SystemClock.uptimeMillis()<deadline){
            boolean[] focused={false};
            runOnMainSync(()->{
                Activity current=gameMonitor==null?null:gameMonitor.getLastActivity();
                if(current instanceof RxeGraphicsActivity&&!current.isDestroyed())game=(RxeGraphicsActivity)current;
                WebView w=game==null||game.isDestroyed()?null:game.testingWebView();
                focused[0]=w!=null&&w.isAttachedToWindow()&&w.isShown()&&game.hasWindowFocus()&&w.getWidth()>w.getHeight();
            });
            if(!focused[0]){SystemClock.sleep(100);continue;}
            String bounds=js(selector.equals("!nextCube")?"(()=>{const n=__testScene.visibleNotes[0],p=__testScene.noteProjection(n,0),r=document.getElementById('game').getBoundingClientRect();return [r.x+p.x,r.y+p.y,innerWidth,innerHeight]})()":"(()=>{const r=document.querySelector('"+selector+"').getBoundingClientRect();return [r.x+r.width/2,r.y+r.height/2,innerWidth,innerHeight]})()");
            if(!bounds.startsWith("[")){SystemClock.sleep(100);continue;}
            JSONArray p=new JSONArray(bounds);int[] location=new int[2];float[] scale={0};
            runOnMainSync(()->{
                WebView w=game==null||game.isDestroyed()?null:game.testingWebView();
                if(w!=null&&w.isAttachedToWindow()&&game.hasWindowFocus()&&p.optDouble(3)>0&&Math.abs(w.getWidth()/(double)w.getHeight()-p.optDouble(2)/p.optDouble(3))<.05){w.getLocationOnScreen(location);scale[0]=w.getWidth()/(float)p.optDouble(2);}
            });
            if(scale[0]<=0||p.optDouble(0)<0||p.optDouble(1)<0||p.optDouble(0)>p.optDouble(2)||p.optDouble(1)>p.optDouble(3)){SystemClock.sleep(100);continue;}
            float x=location[0]+(float)p.getDouble(0)*scale[0],y=location[1]+(float)p.getDouble(1)*scale[0];
            long now=SystemClock.uptimeMillis();MotionEvent down=MotionEvent.obtain(now,now,0,x,y,0),up=null;
            try{sendPointerSync(down);SystemClock.sleep(50);up=MotionEvent.obtain(now,SystemClock.uptimeMillis(),1,x,y,0);sendPointerSync(up);return;}
            catch(IllegalArgumentException transition){if(!String.valueOf(transition.getMessage()).contains("Targeted input event injection"))throw transition;SystemClock.sleep(180);}
            finally{down.recycle();if(up!=null)up.recycle();}
        }
        throw new AssertionError("Game window was not stable for touch: "+selector);
    }
    @Override public void onStart(){
        Bundle result=new Bundle();
        try{
            ActivityMonitor monitor=addMonitor(RxeGraphicsActivity.class.getName(),null,false);gameMonitor=monitor;
            startActivitySync(new Intent(getTargetContext(),PrismaLauncherActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
            game=(RxeGraphicsActivity)monitor.waitForActivityWithTimeout(20000);require(game!=null,"Standalone entry did not open the game");
            until("!!document.getElementById('startBtn')&&document.getElementById('game').dataset.speakers==='2'",30);
            if(phase.equals("seed")){
                until("(()=>{localStorage.setItem('prisma.upgrade-proof','2.9-to-3.0');localStorage.setItem('prisma.records',JSON.stringify([{track:'Récord conservado',level:'flow',rules:'flow-2.9',score:137,accuracy:83,combo:4,date:1}]));return localStorage.getItem('prisma.upgrade-proof')==='2.9-to-3.0'})()",15);
                // WebView commits DOM storage asynchronously. Do not kill its
                // process immediately after writing the upgrade fixture.
                runOnMainSync(()->game.moveTaskToBack(true));SystemClock.sleep(6500);
                result.putString("stream","PRISMA_UPGRADE_SEEDED\n");finish(Activity.RESULT_OK,result);return;
            }
            until("localStorage.getItem('prisma.upgrade-proof')==='2.9-to-3.0'&&JSON.parse(localStorage.getItem('prisma.records')||'[]').some(r=>r.score===137)",10);
            require("true".equals(js("document.documentElement.classList.contains('native-xrender')&&!document.querySelector('.gpu-canvas')")),"Native X Render was replaced");
            js("window.__errors=[];addEventListener('error',e=>__errors.push(e.message));window.__musicSources=0;const originalSource=AudioContext.prototype.createBufferSource;AudioContext.prototype.createBufferSource=function(){__musicSources++;const ctx=this,node=originalSource.call(this),start=node.start;node.start=function(when=0,offset=0){window.__audio={ctx,when,offset};return start.apply(this,arguments)};return node;};import(location.origin+'/audio.js').then(m=>window.__clock=m.outputClock).catch(e=>window.__clockError=String(e));true");
            until("typeof __clock==='function'",10);
            tap("#startBtn");until("document.body.classList.contains('is-playing')",50);
            until("+document.getElementById('game').dataset.laserCount>0",10);
            js("window.__playTest=setInterval(()=>['ArrowUp','ArrowRight','ArrowDown','ArrowLeft'].forEach(code=>document.dispatchEvent(new KeyboardEvent('keydown',{code,bubbles:true}))),55);true");
            until("+document.getElementById('score').textContent>0",25);
            js("clearInterval(__playTest);true");
            require("true".equals(js("+document.getElementById('score').textContent>0")),"No real cuts were scored");
            require("1".equals(js("__musicSources")),"Cuts created additional sound sources");
            require("0".equals(js("__errors.length")),"JavaScript error in gameplay");
            JSONObject render=new JSONObject(new JSONArray("["+js("ReverseGraphics.xRenderInfo()")+"]").getString(0));
            require(render.optLong("frames")>30,"Native renderer did not advance");
            require(render.optString("renderer").equals("ether-render-x-gpu")&&render.optInt("world_vertices")>1000,"Geometry is still calculated on CPU or no 3D world was submitted");
            require(render.optInt("depth_bits")>=24&&render.optInt("world_uploads")==5,"GPU depth buffer/model cache missing");
            require("true".equals(js("document.getElementById('game').dataset.mesh3d==='true'&&Math.abs(+document.getElementById('game').dataset.lookAhead-3.4)<.001")),"3D mode or the new 3.4-second default is not active");
            File folder=new File(getTargetContext().getExternalFilesDir(null),"prisma-evidence");folder.mkdirs();
            Bitmap image=getUiAutomation().takeScreenshot();try(FileOutputStream out=new FileOutputStream(new File(folder,"PRISMA-3.0-Android.png"))){image.compress(Bitmap.CompressFormat.PNG,100,out);}image.recycle();
            JSONObject report=new JSONObject().put("android_gameplay",true).put("speakers",2).put("cut_audio_sources",0).put("music_sources",1).put("native_render",render).put("ui",new JSONObject(js("(()=>{const c=document.getElementById('game');return {width:c.width,height:c.height,ratio:c.width/c.getBoundingClientRect().width,lasers:+c.dataset.laserCount}})()")));
            JSONArray visited=new JSONArray();
            for(String id:new String[]{"neon","aurora","abyss","volcano","galaxy"}){
                js("document.getElementById('world').value='"+id+"';document.getElementById('world').dispatchEvent(new Event('change'));true");
                until("document.getElementById('game').dataset.world==='"+id+"'",5);
                int worldIndex=java.util.Arrays.asList("galaxy","neon","aurora","abyss","volcano").indexOf(id);
                until("JSON.parse(ReverseGraphics.xRenderInfo()).world==="+worldIndex,8);visited.put(id);
            }
            report.put("worlds_rendered",visited);
            js("document.getElementById('world').value='journey';document.getElementById('world').dispatchEvent(new Event('change'));true");
            require("true".equals(js("document.body.classList.contains('is-playing')")),"Session ended before pause test");
            tap("#pauseBtn");until("!document.getElementById('pauseOverlay').hidden",5);
            js("(()=>{const p=new Array(16+128*12).fill(0);p.splice(0,16,3,0,.5,0,.5,.49,.6,1.2,.4,1,.7,1,.3,.5,65280,128);for(let i=0;i<128;i++){const j=16+i*12;p[j]=(i%16-7.5)*.15;p[j+1]=(Math.floor(i/16)-3.5)*.15;p[j+2]=i*.025;p[j+3]=.10;p[j+4]=.5;p[j+5]=1;p[j+6]=.7;p[j+7]=1;p[j+9]=i%4;p[j+11]=1;}window.__gpuStress=setInterval(()=>ReverseGraphics.frame(p),40);ReverseGraphics.frame(p);return true})()");
            until("JSON.parse(ReverseGraphics.xRenderInfo()).note_instances===128",8);
            js("clearInterval(__gpuStress);true");
            report.put("gpu_note_capacity_128",true);
            tap("#resumeBtn");until("document.body.classList.contains('is-playing')",5);
            report.put("pause_resume",true);
            tap("#pauseBtn");tap("#exitBtn");js(RhythmFixture.uploadScript());
            until("document.getElementById('trackName').textContent==='PRISMA-ritmo-prueba'&&document.getElementById('loadingOverlay').hidden",30);
            js(RhythmFixture.prepareScript());until("window.__fixtureReady===true",15);
            js("document.getElementById('precise').checked=true;document.getElementById('precise').dispatchEvent(new Event('change'));true");
            tap("#startBtn");until("document.body.classList.contains('is-playing')",30);
            until("Math.abs(+document.getElementById('game').dataset.firstNoteTime-1.025)<.03",6);
            until("__audio.offset+__clock(__audio.ctx,performance.now(),true).time-__audio.when>1.4",15);
            require("true".equals(js("__testScene.visibleNotes.some(n=>Math.abs(n.t-1.025)<.03)&&document.getElementById('game').dataset.misses==='0'&&document.getElementById('game').dataset.holdCount==='0'&&document.getElementById('game').dataset.chainCount==='0'&&+document.getElementById('game').dataset.noteCount<=32")),"Flow grace or simple cuts are missing");
            tap("!nextCube");until("+document.getElementById('game').dataset.hits===1",8);
            report.put("flow_late_native_touch",true).put("flow_no_holds",true).put("ordered_first_note",true);
            until("__audio.offset+__clock(__audio.ctx,performance.now(),true).time-__audio.when>5.55",10);
            require("true".equals(js("+document.getElementById('game').dataset.deferredNotes>0&&+document.getElementById('game').dataset.firstNoteTime>5&&__testScene.visibleNotes.some(n=>Math.abs(n.t-5.525)<.03)&&__testScene.visibleNotes.every(n=>Math.abs(__testScene.flowPositions.get(n)-(n.t-__testSceneTime))<.00001)")),"Missed notes block the stream or frame time slows musical arrivals");
            report.put("flow_live_stream_unblocked",true).put("flow_audio_clock",new JSONObject(js("(()=>({frameTime:__testSceneTime,deferred:+document.getElementById('game').dataset.deferredNotes,notes:__testScene.visibleNotes.map(n=>({onset:n.t,remaining:__testScene.flowPositions.get(n)}))}))()")));
            until("document.getElementById('game').dataset.flowCoda==='true'",30);
            require("true".equals(js("document.getElementById('game').dataset.misses==='0'&&!document.getElementById('flowFinishBtn').hidden")),"Flow failed or hid its pending notes at song end");
            tap("#pauseBtn");tap("#resumeBtn");require("3".equals(js("__musicSources")),"Resuming the end-of-song recovery created another music source");
            tap("#flowFinishBtn");until("!document.getElementById('resultOverlay').hidden",10);
            report.put("flow_end_recovery",true).put("flow_explicit_finish",true).put("flow_coda_resume_silent",true);
            tap("#homeBtn");tap("[data-level=\"pulse\"]");tap("#startBtn");until("document.body.classList.contains('is-playing')",30);
            require("true".equals(js("document.getElementById('game').dataset.holdCount==='0'&&+document.getElementById('game').dataset.chainCount>=2")),"Single-cut Pulse chart did not retain its musical phrases");
            js(RhythmFixture.playScript());
            until("+document.getElementById('game').dataset.hits>=__fixturePulseNotes.length&&+document.getElementById('game').dataset.phrasesCompleted>=2&&+document.getElementById('game').dataset.constellations>=1",35);
            js("clearInterval(__playTest);true");
            require("4".equals(js("__musicSources")),"Cuts or recovery created non-musical audio sources");
            require("0".equals(js("__errors.length")),"Gameplay raised a JavaScript error");
            report.put("mechanics_fixture",new JSONObject(js("(()=>{const d=document.getElementById('game').dataset;return {holds:+d.holdCompletions,phrases:+d.phrasesCompleted,constellations:+d.constellations,hits:+d.hits,maxFireworks:__festivalMaxShells,maxSparks:__festivalMaxSparks,rewardFireworks:__festivalMaxRewards,sync:d.syncMode,musicSources:__musicSources,inputs:__fixtureEvents}})()")));
            require("true".equals(js("__festivalMaxShells>0&&__festivalMaxSparks>0&&__festivalMaxRewards>0")),"Native Android never displayed a firework");
            js("document.getElementById('effects').checked=true;document.getElementById('effects').dispatchEvent(new Event('change'));true");
            until("document.getElementById('game').dataset.fireworks==='0'",5);
            report.put("soft_effects_disable_fireworks",true);
            require("true".equals(js("JSON.parse(localStorage.getItem('prisma.records')||'[]').some(r=>r.score===137&&r.rules==='flow-2.9')")),"Saving forgiving Flow erased the old record");
            report.put("upgrade_2_9_records_preserved",true);
            Files.write(new File(folder,"android-validation.json").toPath(),report.toString(2).getBytes(StandardCharsets.UTF_8));
            result.putString("stream","PRISMA_ANDROID_OK music=1 cut-sounds=0 speakers=2 native=Ether-Render-X\n");finish(Activity.RESULT_OK,result);
        }catch(Throwable e){result.putString("stream","PRISMA_ANDROID_FAILED "+e+"\n");finish(Activity.RESULT_CANCELED,result);}
    }
}
