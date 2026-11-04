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
    @Override public void onCreate(Bundle args){super.onCreate(args);start();}
    private static void require(boolean v,String why){if(!v)throw new AssertionError(why);}
    private String js(String source)throws Exception{
        CountDownLatch done=new CountDownLatch(1);String[] out={"null"};
        runOnMainSync(()->game.testingWebView().evaluateJavascript(source,v->{out[0]=v;done.countDown();}));
        require(done.await(10,TimeUnit.SECONDS),"WebView did not answer");return out[0];
    }
    private void until(String condition,int seconds)throws Exception{
        long deadline=SystemClock.uptimeMillis()+seconds*1000L;
        while(SystemClock.uptimeMillis()<deadline){if("true".equals(js(condition)))return;SystemClock.sleep(100);}
        throw new AssertionError("Timed out: "+condition);
    }
    private void tap(String selector)throws Exception{
        JSONArray p=new JSONArray(js("(()=>{const r=document.querySelector('"+selector+"').getBoundingClientRect();return [r.x+r.width/2,r.y+r.height/2,innerWidth]})()"));
        int[] location=new int[2];float[] scale={1};
        runOnMainSync(()->{WebView w=game.testingWebView();w.getLocationOnScreen(location);scale[0]=w.getWidth()/(float)p.optDouble(2);});
        float x=location[0]+(float)p.getDouble(0)*scale[0],y=location[1]+(float)p.getDouble(1)*scale[0];
        long now=SystemClock.uptimeMillis();MotionEvent down=MotionEvent.obtain(now,now,0,x,y,0),up=MotionEvent.obtain(now,now+70,1,x,y,0);
        try{sendPointerSync(down);sendPointerSync(up);}finally{down.recycle();up.recycle();}
    }
    @Override public void onStart(){
        Bundle result=new Bundle();
        try{
            ActivityMonitor monitor=addMonitor(RxeGraphicsActivity.class.getName(),null,false);
            startActivitySync(new Intent(getTargetContext(),PrismaLauncherActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
            game=(RxeGraphicsActivity)monitor.waitForActivityWithTimeout(20000);require(game!=null,"Standalone entry did not open the game");
            boolean[] ready={false};for(int i=0;i<150;i++){runOnMainSync(()->ready[0]=game.testingWebView()!=null);if(ready[0])break;SystemClock.sleep(100);}require(ready[0],"Game WebView unavailable");
            until("!!document.getElementById('startBtn')&&document.getElementById('game').dataset.speakers==='2'",30);
            require("true".equals(js("document.documentElement.classList.contains('native-xrender')&&!document.querySelector('.gpu-canvas')")),"Native X Render was replaced");
            js("window.__errors=[];addEventListener('error',e=>__errors.push(e.message));window.__musicSources=0;const originalSource=AudioContext.prototype.createBufferSource;AudioContext.prototype.createBufferSource=function(){__musicSources++;return originalSource.call(this)};true");
            tap("#startBtn");until("document.body.classList.contains('is-playing')",50);
            until("+document.getElementById('game').dataset.laserCount>0",10);
            for(int i=0;i<85;i++){
                js("['ArrowUp','ArrowRight','ArrowDown','ArrowLeft'].forEach(code=>document.dispatchEvent(new KeyboardEvent('keydown',{code,bubbles:true})));true");
                SystemClock.sleep(90);
            }
            require("true".equals(js("+document.getElementById('score').textContent>0")),"No real cuts were scored");
            require("1".equals(js("__musicSources")),"Cuts created additional sound sources");
            require("0".equals(js("__errors.length")),"JavaScript error in gameplay");
            JSONObject render=new JSONObject(new JSONArray("["+js("ReverseGraphics.xRenderInfo()")+"]").getString(0));
            require(render.optLong("frames")>30,"Native renderer did not advance");
            File folder=new File(getTargetContext().getExternalFilesDir(null),"prisma-evidence");folder.mkdirs();
            Bitmap image=getUiAutomation().takeScreenshot();try(FileOutputStream out=new FileOutputStream(new File(folder,"PRISMA-2.5-Android.png"))){image.compress(Bitmap.CompressFormat.PNG,100,out);}image.recycle();
            JSONObject report=new JSONObject().put("android_gameplay",true).put("speakers",2).put("cut_audio_sources",0).put("music_sources",1).put("native_render",render).put("ui",new JSONObject(js("(()=>{const c=document.getElementById('game');return {width:c.width,height:c.height,ratio:c.width/c.getBoundingClientRect().width,lasers:+c.dataset.laserCount}})()")));
            tap("#pauseBtn");until("!document.getElementById('pauseOverlay').hidden",5);
            tap("#resumeBtn");until("document.body.classList.contains('is-playing')",5);
            report.put("pause_resume",true);
            Files.write(new File(folder,"android-validation.json").toPath(),report.toString(2).getBytes(StandardCharsets.UTF_8));
            result.putString("stream","PRISMA_ANDROID_OK music=1 cut-sounds=0 speakers=2 native=Ether-Render-X\n");finish(Activity.RESULT_OK,result);
        }catch(Throwable e){result.putString("stream","PRISMA_ANDROID_FAILED "+e+"\n");finish(Activity.RESULT_CANCELED,result);}
    }
}
