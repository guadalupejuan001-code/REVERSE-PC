package com.reversepc.os;

import android.app.Activity;
import android.app.Instrumentation;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.os.Bundle;
import android.webkit.WebView;
import org.json.JSONArray;
import org.json.JSONObject;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import java.io.File;
import java.io.FileOutputStream;
import java.nio.file.Files;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Arrays;
import android.os.SystemClock;
import android.view.MotionEvent;
import android.graphics.RectF;

/** Framework-only instrumentation: actual APK, WebView, JNI and saved RVPC2. */
public final class WorkbenchTestRunner extends Instrumentation {
    private Bundle arguments;
    private volatile WorkbenchActivity activity;
    private volatile Activity resumed;
    @Override public void callActivityOnResume(Activity current){super.callActivityOnResume(current);resumed=current;if(current instanceof WorkbenchActivity)activity=(WorkbenchActivity)current;}
    @Override public void onCreate(Bundle args){arguments=args;start();}
    private static void require(boolean ok,String message){if(!ok)throw new AssertionError(message);}
    private String js(String script)throws Exception{
        CountDownLatch done=new CountDownLatch(1);AtomicReference<String> result=new AtomicReference<>();
        runOnMainSync(()->activity.testingWebView().evaluateJavascript(script,value->{result.set(value);done.countDown();}));
        require(done.await(30,TimeUnit.SECONDS),"WebView callback timed out: "+script.substring(0,Math.min(script.length(),160)));
        Object value=new JSONArray("["+result.get()+"]").get(0);return value==JSONObject.NULL?"null":String.valueOf(value);
    }
    private String waitJs(String expression)throws Exception{
        for(int i=0;i<120;i++){String result=js(expression);if(!result.equals("null")&&!result.equals("undefined")&&!result.equals("false"))return result;Thread.sleep(250);}
        throw new AssertionError("Timed out: "+expression);
    }
    private JSONObject op(String op,String payload,String target)throws Exception{
        js("window."+target+"=null;nativeRequest("+JSONObject.quote(op)+","+JSONObject.quote(payload)+").then(r=>window."+target+"=r).catch(e=>window."+target+"={ok:false,error:String(e)});true");
        return new JSONObject(waitJs("window."+target+"?JSON.stringify(window."+target+"):null"));
    }
    private File dataFile(String path){return new File(getTargetContext().getFilesDir(),path);}
    private static String digest(byte[] data)throws Exception{
        StringBuilder out=new StringBuilder();for(byte b:MessageDigest.getInstance("SHA-256").digest(data))out.append(String.format(java.util.Locale.ROOT,"%02x",b&255));return out.toString();
    }
    private String hash(String path)throws Exception{return digest(Files.readAllBytes(dataFile(path).toPath()));}
    private void tapDom(String selector)throws Exception{
        String quoted=JSONObject.quote(selector);
        js("document.querySelector("+quoted+").scrollIntoView({block:'nearest',inline:'nearest'});true");
        String geometry="(()=>{const r=document.querySelector("+quoted+").getBoundingClientRect();return JSON.stringify({x:r.x+r.width/2,y:r.y+r.height/2,width:innerWidth});})()";String previous="",stable="";int same=0;for(int i=0;i<30;i++){stable=js(geometry);same=stable.equals(previous)?same+1:0;if(same>=3)break;previous=stable;Thread.sleep(100);}JSONObject point=new JSONObject(stable);
        int[] origin=new int[2];int[] width={0};runOnMainSync(()->{activity.testingWebView().getLocationOnScreen(origin);width[0]=activity.testingWebView().getWidth();});
        float scale=(float)(width[0]/point.getDouble("width")),x=origin[0]+(float)point.getDouble("x")*scale,y=origin[1]+(float)point.getDouble("y")*scale;
        long time=SystemClock.uptimeMillis();MotionEvent down=MotionEvent.obtain(time,time,MotionEvent.ACTION_DOWN,x,y,0),up=MotionEvent.obtain(time,time+80,MotionEvent.ACTION_UP,x,y,0);
        try{sendPointerSync(down);sendPointerSync(up);}catch(Exception error){throw new AssertionError("Tap failed: "+selector+" x="+x+" y="+y+" geometry="+stable,error);}finally{down.recycle();up.recycle();}waitForIdleSync();
    }
    private void sendMessage(String question,String answer)throws Exception{
        int before=Integer.parseInt(js("programSessions.get(state.windows.find(w=>w.rxePath==='Aplicaciones/BBY-Q.rxe').id).snapshot.history.length"));
        js("(()=>{const field=document.querySelector('[data-program-input]');field.value="+JSONObject.quote(question)+";field.dispatchEvent(new Event('input',{bubbles:true}));})()");
        tapDom(".rxe-composer button[type=submit]");
        waitJs("(()=>{const w=state.windows.find(w=>w.rxePath==='Aplicaciones/BBY-Q.rxe'),d=programSessions.get(w.id);return d.snapshot.history.length==="+(before+2)+"&&!d.busy;})()");
        require(js("document.querySelector('[aria-label=\"Respuesta BBY Q\"]').textContent").equals(answer),"Unexpected real BBY Q answer: "+question);
    }
    private void seedUpgrade()throws Exception{
        byte[] image;try(java.io.InputStream input=getTargetContext().getAssets().open("native-apps/BBY-Q.rxe")){image=WorkbenchProgramsRead(input);}
        final byte[] executable=image;
        RuntimeExecutor.INSTANCE.submit(()->{try{
            WorkspaceFiles files=new WorkspaceFiles(getTargetContext().getFilesDir());files.write("Aplicaciones/BBY-Q.rxe",executable,false);
            RxeAppStore app=new RxeAppStore(getTargetContext(),executable);
            app.ask(executable,"hola",1);app.ask(executable,"ana tiene dos manzanas",1);app.ask(executable,"ella recibe tres mas",1);
            return true;
        }catch(Exception error){throw new RuntimeException(error);}}).get(60,TimeUnit.SECONDS);
        String identity=digest(image);JSONObject proof=new JSONObject().put("identity",identity).put("record_sha256",hash("rxe-apps/"+identity+"/session.rxas")).put("desktop_sha256",hash("session.rvp"));
        Files.write(dataFile("upgrade-before.json").toPath(),proof.toString().getBytes(StandardCharsets.UTF_8));
    }
    // This fixture also runs on the previous 2.0 APK, which has no WorkbenchPrograms.
    private static byte[] WorkbenchProgramsRead(java.io.InputStream input)throws Exception{
        java.io.ByteArrayOutputStream output=new java.io.ByteArrayOutputStream();byte[] part=new byte[8192];int n;while((n=input.read(part))!=-1)output.write(part,0,n);return output.toByteArray();
    }
    private void retainedProof(boolean write)throws Exception{
        String identity=js("programSessions.get(state.windows.find(w=>w.rxePath==='Aplicaciones/BBY-Q.rxe').id).snapshot.identity");
        String record="rxe-apps/"+identity+"/session.rxas";
        if(write){JSONObject proof=new JSONObject().put("record_sha256",hash(record)).put("desktop_sha256",hash("session.rvp"));Files.write(dataFile("retained-app.json").toPath(),proof.toString().getBytes(StandardCharsets.UTF_8));}
        else{JSONObject proof=new JSONObject(new String(Files.readAllBytes(dataFile("retained-app.json").toPath()),StandardCharsets.UTF_8));require(hash(record).equals(proof.getString("record_sha256")),"Opening after restart executed or changed BBY Q");require(hash("session.rvp").equals(proof.getString("desktop_sha256")),"Restart executed an RXE again");}
    }
    private void programNavigation(boolean upgrade)throws Exception{
        ActivityMonitor oldDesktop=addMonitor(DesktopActivity.class.getName(),null,true);
        byte[] desktopBefore=Files.readAllBytes(dataFile("session.rvp").toPath());
        tapDom("#launcher-toggle");tapDom("#launcher [data-open=programs]");
        waitJs("document.querySelector('.window[aria-label=\"Aplicaciones .rxe\"] [data-program-path=\"Aplicaciones/BBY-Q.rxe\"]')");
        tapDom(".program-list [data-program-path=\"Aplicaciones/BBY-Q.rxe\"]");waitJs("document.querySelector('[data-program-input]:not(:disabled)')");
        require(resumed instanceof WorkbenchActivity&&oldDesktop.getHits()==0,"Applications left Workbench for the old desktop");
        require(Arrays.equals(desktopBefore,Files.readAllBytes(dataFile("session.rvp").toPath())),"Opening BBY Q changed the shared machine");
        if(upgrade){
            JSONObject proof=new JSONObject(new String(Files.readAllBytes(dataFile("upgrade-before.json").toPath()),StandardCharsets.UTF_8));
            require(hash("rxe-apps/"+proof.getString("identity")+"/session.rxas").equals(proof.getString("record_sha256")),"Upgrade replaced the retained agent");
            require(js("document.querySelector('[aria-label=\"Respuesta BBY Q\"]').textContent").equals("Ana tiene cinco manzanas."),"Old conversation not restored in the new window");
        }else{sendMessage("hola","Hola. Soy BBY Q.");sendMessage("ana tiene dos manzanas","Ana tiene dos manzanas.");sendMessage("ella recibe tres mas","Ana tiene cinco manzanas.");}
        sendMessage("cuantas manzanas tiene ana?","Ana tiene cinco manzanas.");
        tapDom("[data-program-language=\"2\"]");sendMessage("how many apples does she have?","Ana has five apples.");
        require(Arrays.equals(desktopBefore,Files.readAllBytes(dataFile("session.rvp").toPath())),"BBY Q wrote the shared desktop checkpoint");
        visualCheck(upgrade?"upgraded-bbyq":"bbyq-in-workbench");
        // All catalog entry points, including a restored 2.0 shortcut, stay here.
        js("createWindow('control',{tab:'apps'});true");tapDom(".control-app-grid [data-open=programs]");
        js("createWindow('control',{tab:'system'});true");waitJs("document.querySelector('.wall-editor-actions [data-open=programs]')");tapDom(".wall-editor-actions [data-open=programs]");
        js("createWindow('nativeDesktop');window.ReverseNative.openNativeDesktop();true");waitForIdleSync();
        require(resumed instanceof WorkbenchActivity&&oldDesktop.getHits()==0,"A catalog entry point launched DesktopActivity");
        tapDom(".program-list [data-program-path=\"Aplicaciones/Hola-REVERSE.rxe\"]");
        waitJs("document.querySelector('.window[aria-label=\"Hola REVERSE\"] [data-program-action=run]')");
        tapDom(".window[aria-label=\"Hola REVERSE\"] [data-program-action=run]");waitJs("document.querySelector('.rxe-output').textContent.includes('42')");
        // Compile through XI Studio: output must not be executed until Run.
        js("createWindow('xi');true");
        String source="#!reverse-pc-machine-v1\nset r0 7\nmul r0 9\nstore8 314 r0\nprint r0\nhalt\n";
        js("(()=>{const field=document.querySelector('[data-xi-source]');field.value="+JSONObject.quote(source)+";field.dispatchEvent(new Event('input',{bubbles:true}));})()");
        String beforeCompile=hash("session.rvp");tapDom("[data-program-action=compile]");waitJs("document.querySelector('#input-dialog').open");
        js("document.querySelector('#dialog-input').value='Prueba-workbench.rxe';true");tapDom("#dialog-confirm");
        waitJs("document.querySelector('.window[aria-label=\"Prueba-workbench\"] [data-program-action=run]')");
        require(hash("session.rvp").equals(beforeCompile),"Compilation executed the source");
        tapDom(".window[aria-label=\"Prueba-workbench\"] [data-program-action=run]");waitJs("document.querySelector('.window[aria-label=\"Prueba-workbench\"] .rxe-output').textContent.includes('63')");
        require(!hash("session.rvp").equals(beforeCompile),"RXE did not update the real machine");
        RuntimeExecutor.INSTANCE.submit(()->{try{
            WorkbenchPrograms programs=new WorkbenchPrograms(getTargetContext());WorkspaceFiles files=new WorkspaceFiles(getTargetContext().getFilesDir());
            JSONObject opened=programs.open("Aplicaciones/BBY-Q.rxe"),request=new JSONObject().put("path",opened.getString("path")).put("identity",opened.getString("identity"));
            byte[] image=files.read(opened.getString("path"));require(Arrays.equals(programs.exportImage(request,false),image),"Executable export changed bytes");
            require(Arrays.equals(programs.exportImage(request,true),new RxeAppStore(getTargetContext(),image).load(image).state),"Memory export is not the real RVPC2");
            JSONObject copy=programs.importImage(image);require(programs.open(copy.getString("path")).getJSONArray("history").toString().equals(opened.getJSONArray("history").toString()),"Imported duplicate lost the same retained memory");
            try{programs.importImage(source.getBytes(StandardCharsets.UTF_8));throw new AssertionError("Renamed source accepted as RXE");}catch(RuntimeException|java.io.IOException rejected){}
            return true;
        }catch(Exception error){throw new RuntimeException(error);}}).get(60,TimeUnit.SECONDS);
        // Keep the agent visible for cold restart, with no inference on restoration.
        js("for(const w of [...state.windows])if(w.app!=='programs'&&w.rxePath!=='Aplicaciones/BBY-Q.rxe')closeWindow(w);createWindow('bbyq');true");
        require(resumed instanceof WorkbenchActivity&&oldDesktop.getHits()==0,"Program operation left Workbench");removeMonitor(oldDesktop);
        js("window.navigationSaved=null;persist().then(ok=>window.navigationSaved=ok);true");require(waitJs("window.navigationSaved").equals("true"),"App window was not persisted");retainedProof(true);
    }
    private void visualCheck(String mode)throws Exception{
        CountDownLatch painted=new CountDownLatch(1);
        runOnMainSync(()->activity.testingWebView().postVisualStateCallback(1,new WebView.VisualStateCallback(){@Override public void onComplete(long id){painted.countDown();}}));
        require(painted.await(30,TimeUnit.SECONDS),"WebView did not commit a visual frame");
        File folder=new File(getTargetContext().getExternalFilesDir(null),"visual-evidence");folder.mkdirs();
        String geometry=js("JSON.stringify({width:innerWidth,height:innerHeight,body:document.body.getBoundingClientRect().toJSON(),desktop:document.querySelector('#desktop').getBoundingClientRect().toJSON(),taskbar:document.querySelector('.taskbar').getBoundingClientRect().toJSON(),wall:getComputedStyle(document.querySelector('#wall-image')).backgroundImage})");
        try(FileOutputStream output=new FileOutputStream(new File(folder,mode+"-geometry.json"))){output.write(geometry.getBytes(java.nio.charset.StandardCharsets.UTF_8));}
        boolean visible=false;
        for(int attempt=0;attempt<24;attempt++){
            Bitmap screen=getUiAutomation().takeScreenshot();require(screen!=null,"No display screenshot");
            int bright=0,samples=0;
            for(int y=10;y<screen.getHeight()-10;y+=4)for(int x=10;x<screen.getWidth()*9/10;x+=4){int color=screen.getPixel(x,y);if(((color>>16)&255)>85||((color>>8)&255)>85||(color&255)>85)bright++;samples++;}
            try(FileOutputStream output=new FileOutputStream(new File(folder,mode+"-screen.png"))){screen.compress(Bitmap.CompressFormat.PNG,100,output);}
            screen.recycle();visible=bright>samples/250;if(visible)break;Thread.sleep(500);
        }
        runOnMainSync(()->{WebView view=activity.testingWebView();Bitmap bitmap=Bitmap.createBitmap(Math.max(1,view.getWidth()),Math.max(1,view.getHeight()),Bitmap.Config.ARGB_8888);view.draw(new Canvas(bitmap));try(FileOutputStream output=new FileOutputStream(new File(folder,mode+"-view.png"))){bitmap.compress(Bitmap.CompressFormat.PNG,100,output);}catch(Exception error){throw new RuntimeException(error);}finally{bitmap.recycle();}});
        require(visible,"Display stayed blank after committed WebView frame; "+geometry);
    }
    private void tapNative(ViewTarget target,float x,float y)throws Exception{
        int[] origin=new int[2];runOnMainSync(()->target.view.getLocationOnScreen(origin));long now=SystemClock.uptimeMillis();
        MotionEvent down=MotionEvent.obtain(now,now,MotionEvent.ACTION_DOWN,x+origin[0],y+origin[1],0),up=MotionEvent.obtain(now,now+50,MotionEvent.ACTION_UP,x+origin[0],y+origin[1],0);
        try{sendPointerSync(down);sendPointerSync(up);}finally{down.recycle();up.recycle();}
    }
    private static final class ViewTarget {final android.view.View view;ViewTarget(android.view.View view){this.view=view;}}
    private int[] gameSnapshot(BreakerActivity game)throws Exception{
        for(int i=0;i<120;i++){AtomicReference<int[]> result=new AtomicReference<>();runOnMainSync(()->result.set(game.testingSnapshot()));if(result.get()!=null)return result.get();Thread.sleep(100);}throw new AssertionError("Game did not load its XI frame");
    }
    private void screenshot(String name)throws Exception{
        File folder=new File(getTargetContext().getExternalFilesDir(null),"visual-evidence");folder.mkdirs();Bitmap bitmap=getUiAutomation().takeScreenshot();require(bitmap!=null,"No native game screenshot");try(FileOutputStream output=new FileOutputStream(new File(folder,name+".png"))){bitmap.compress(Bitmap.CompressFormat.PNG,100,output);}finally{bitmap.recycle();}
    }
    private void breaker(boolean restore)throws Exception{
        BreakerActivity game;
        if(restore)game=(BreakerActivity)startActivitySync(new Intent(getTargetContext(),BreakerActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
        else{
            activity=(WorkbenchActivity)startActivitySync(new Intent(getTargetContext(),WorkbenchActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
            waitJs("programCatalog&&programCatalog.apps.some(a=>a.metadata.ui==='breaker-v1')");
            js("openProgram('Aplicaciones/REVERSE-BREAKER.rxe');true");waitJs("document.querySelector('[data-program-action=play-breaker]')");
            ActivityMonitor monitor=addMonitor(BreakerActivity.class.getName(),null,false);tapDom("[data-program-action=play-breaker]");game=(BreakerActivity)waitForMonitorWithTimeout(monitor,10000);removeMonitor(monitor);require(game!=null,"RXE play did not open the native game");
        }
        int[] initial=gameSnapshot(game);Thread.sleep(400);String coreBefore=hash("session.rvp");
        if(restore){
            JSONObject proof=new JSONObject(new String(Files.readAllBytes(dataFile("breaker-proof.json").toPath()),StandardCharsets.UTF_8));JSONArray before=proof.getJSONArray("frame");
            for(int i:new int[]{0,1,5,6,7,8,9,10,12,13,14,15,16,17})require(initial[i]==before.getInt(i),"Cold game restore differs at "+i);
            require(coreBefore.equals(proof.getString("core")),"Game altered desktop quantum checkpoint");
            Thread.sleep(300);require(gameSnapshot(game)[17]==initial[17],"Restored game ran without player resuming");
        }else{
            require(initial[6]==3&&initial[9]==50,"First RXE game state differs");
            RectF[] play={null};for(int i=0;i<50;i++){runOnMainSync(()->play[0]=game.testingPlayRect());if(play[0].width()>0)break;Thread.sleep(50);}require(play[0].width()>0,"Game did not draw the play control");tapNative(new ViewTarget(game.testingView()),play[0].centerX(),play[0].centerY());
            for(int i=0;i<100&&gameSnapshot(game)[17]<8;i++)Thread.sleep(30);
            int[] playing=gameSnapshot(game);require(playing[7]==1&&playing[17]>=8&&playing[1]!=initial[1],"Touch did not launch XI gameplay");
            RectF[] board={null};runOnMainSync(()->board[0]=game.testingBoard());float x=board[0].left+board[0].width()*.75f,y=board[0].bottom-25;
            tapNative(new ViewTarget(game.testingView()),x,y);Thread.sleep(100);require(gameSnapshot(game)[4]>=740,"Touch did not move XI paddle");
            screenshot("breaker-running");
            RectF[] pause={null};runOnMainSync(()->pause[0]=game.testingPauseRect());tapNative(new ViewTarget(game.testingView()),pause[0].centerX(),pause[0].centerY());Thread.sleep(250);
            int[] stopped=gameSnapshot(game);Thread.sleep(250);require(gameSnapshot(game)[17]==stopped[17],"Pause kept advancing XI ticks");
            RuntimeExecutor.INSTANCE.submit(()->{}).get(10,TimeUnit.SECONDS);
            require(dataFile("reverse-breaker-v1.rvp").length()>29,"No durable game checkpoint");
            require(hash("session.rvp").equals(coreBefore),"Game mutated desktop state");
            JSONObject proof=new JSONObject().put("frame",new JSONArray(stopped)).put("core",coreBefore).put("checkpoint_bytes",dataFile("reverse-breaker-v1.rvp").length());
            Files.write(dataFile("breaker-proof.json").toPath(),proof.toString().getBytes(StandardCharsets.UTF_8));
        }
        screenshot(restore?"breaker-restored":"breaker-paused");runOnMainSync(game::finish);waitForIdleSync();
        if(!restore)require(resumed instanceof WorkbenchActivity,"Returning from game opened the legacy desktop");
    }
    @Override public void onStart(){
        Bundle result=new Bundle();
        try{
            String requested=arguments==null?"full":arguments.getString("mode","full");
            if(requested.equals("breaker")||requested.equals("breakerRestore")){
                breaker(requested.equals("breakerRestore"));result.putString("stream","WORKBENCH_TESTS_OK mode="+requested+" native=XI/Ether game=RXE touch=real checkpoint=RVPC2\n");result.putBoolean("passed",true);finish(Activity.RESULT_OK,result);return;
            }
            boolean boot=requested.equals("boot"),seed=requested.equals("upgradeSeed"),upgrade=requested.equals("upgrade");
            if(boot){ActivityMonitor monitor=addMonitor(WorkbenchActivity.class.getName(),null,false);startActivitySync(new Intent(getTargetContext(),BootActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));activity=(WorkbenchActivity)waitForMonitorWithTimeout(monitor,15000);removeMonitor(monitor);require(activity!=null,"Boot did not reach desktop");}
            else activity=(WorkbenchActivity)startActivitySync(new Intent(getTargetContext(),WorkbenchActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
            waitJs("document.querySelector('[data-task-app]')&&typeof nativeRequest==='function'");
            JSONObject snapshot=op("inspect","","testSnapshot");
            require(snapshot.getBoolean("ok"),snapshot.toString());
            require(snapshot.getJSONObject("android").getLong("ram_total_bytes")>0,"No native RAM reading");
            require(snapshot.getJSONObject("core").getString("state_format").equals("RVPC2"),"Wrong checkpoint format");
            require(snapshot.getJSONObject("build").getString("source_commit").matches("[a-f0-9]{40}"),"Missing build provenance");
            boolean restore=boot||upgrade||requested.equals("restore");
            if(restore){
                require(snapshot.getJSONObject("core").getLong("active_qubits")>=128,"Native state did not survive process restart");
                require(js("state.prefs.dim").equals("23"),"Preferences did not survive restart");
                require(js("state.files.some(f=>f.name==='Prueba-nativa.txt'&&!f.trashRoot)").equals("true"),"File did not survive restart");
            }else{
                JSONObject arithmetic=op("calculate","2+3*4","testArithmetic");
                require(arithmetic.getBoolean("ok")&&arithmetic.getString("value").equals("14"),"XI arithmetic failed");
                require(arithmetic.getString("source").contains("NativeRuntime"),"Arithmetic source missing");
                JSONObject decimal=op("calculate","0.1+0.2","testDecimal");require(decimal.getString("value").equals("0.3"),"Fixed-point decimal failed");
                JSONObject invalid=op("calculate","1/0","testInvalid");require(!invalid.getBoolean("ok"),"Division by zero accepted");
                JSONObject probe=op("execute",js("XI_PROBE"),"testProbe");
                require(probe.getBoolean("ok"),probe.toString());
                require(probe.getJSONObject("core").getLong("active_qubits")==128,"GHZ probe did not create 128 active qubits");
                require(probe.getString("output").contains("42"),"Probe arithmetic result missing");
                js("createWindow('calculator');true");
                js("document.querySelector('.window[aria-label=Calculadora] [data-calc=\"7\"]').click();document.querySelector('.window[aria-label=Calculadora] [data-calc=\"×\"]').click();document.querySelector('.window[aria-label=Calculadora] [data-calc=\"6\"]').click();document.querySelector('.window[aria-label=Calculadora] [data-calc=\"=\"]').click();true");
                waitJs("document.querySelector('.calc-history').textContent.includes('XI')");
                require(js("document.querySelector('.calc-display').value").equals("42"),"UI did not display native result");
                js("window.testFile=createFile('text','Prueba-nativa.txt','personal','Texto persistente real');deleteFile(testFile);true");
                require(js("state.files.find(f=>f.id===testFile.id).trashRoot===testFile.id").equals("true"),"Trash did not change index");
                js("restoreFile(testFile);setPref('dim',23,false);window.testSaved=null;persist().then(ok=>window.testSaved=ok);true");
                require(waitJs("window.testSaved").equals("true"),"Native profile was not acknowledged");
                require(js("state.files.find(f=>f.id===testFile.id).trashRoot===undefined").equals("true"),"Trash restore failed");
                js("createWindow('control',{tab:'system'});true");
                waitJs("document.querySelector('.diagnostic-table')&&document.querySelector('.diagnostic-table').textContent.includes('Conectado')");
                require(js("getComputedStyle(document.querySelector('.taskbar')).position").equals("fixed"),"Taskbar is not fixed");
                require(js("getComputedStyle(document.querySelector('#wall-image')).backgroundImage.includes('pliegue-default')").equals("true"),"Approved wallpaper is not loaded");
                // The trusted WebView must reject a remote subframe before it can use the bridge.
                require(js("document.querySelectorAll('iframe').length").equals("0"),"Unexpected third-party frame");
            }
            if(seed)seedUpgrade();
            else if(restore&&!upgrade){waitJs("document.querySelector('[data-program-input]:not(:disabled)')");require(js("document.querySelector('[aria-label=\"Respuesta BBY Q\"]').textContent").equals("Ana has five apples."),"Restored app response differs");retainedProof(false);}
            else programNavigation(upgrade);
            String mode=boot?"boot":requested;visualCheck(mode);
            String text="WORKBENCH_TESTS_OK mode="+mode+" native=XI/Ether checkpoint=RVPC2 visual=drawn\n";
            result.putString("stream",text);result.putBoolean("passed",true);finish(Activity.RESULT_OK,result);
        }catch(Throwable failure){result.putString("stream","WORKBENCH_TESTS_FAILED "+failure+"\n");result.putString("error",failure.toString());finish(Activity.RESULT_CANCELED,result);}
    }
}
