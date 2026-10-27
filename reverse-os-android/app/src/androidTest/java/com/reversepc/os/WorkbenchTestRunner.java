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
        Thread.sleep(150); // A scroll or resize must reach the compositor before touch.
        JSONObject point=new JSONObject(js("(()=>{const r=document.querySelector("+quoted+").getBoundingClientRect();return JSON.stringify({x:r.x+r.width/2,y:r.y+r.height/2,width:innerWidth});})()"));
        require(js("(()=>{const e=document.querySelector("+quoted+"),r=e.getBoundingClientRect(),hit=document.elementFromPoint(r.x+r.width/2,r.y+r.height/2);return !!hit&&(e===hit||e.contains(hit));})()").equals("true"),"Touch target is covered or outside the viewport: "+selector);
        int[] origin=new int[2];int[] width={0};runOnMainSync(()->{activity.testingWebView().getLocationOnScreen(origin);width[0]=activity.testingWebView().getWidth();});
        float scale=(float)(width[0]/point.getDouble("width")),x=origin[0]+(float)point.getDouble("x")*scale,y=origin[1]+(float)point.getDouble("y")*scale;
        long time=SystemClock.uptimeMillis();MotionEvent down=MotionEvent.obtain(time,time,MotionEvent.ACTION_DOWN,x,y,0),up=MotionEvent.obtain(time,time+80,MotionEvent.ACTION_UP,x,y,0);
        try{sendPointerSync(down);sendPointerSync(up);}finally{down.recycle();up.recycle();}waitForIdleSync();
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
    private void fullDisplay()throws Exception{
        int[] bounds=new int[4];boolean[] bars={true};
        int displayWidth=0,displayHeight=0;
        for(int attempt=0;attempt<30;attempt++){
            runOnMainSync(()->{
                WebView view=activity.testingWebView();int[] point=new int[2];view.getLocationOnScreen(point);
                bounds[0]=point[0];bounds[1]=point[1];bounds[2]=view.getWidth();bounds[3]=view.getHeight();
                android.view.WindowInsets insets=view.getRootWindowInsets();bars[0]=insets==null||insets.isVisible(android.view.WindowInsets.Type.statusBars())||insets.isVisible(android.view.WindowInsets.Type.navigationBars());
            });
            Bitmap screen=getUiAutomation().takeScreenshot();displayWidth=screen.getWidth();displayHeight=screen.getHeight();screen.recycle();
            if(!bars[0]&&bounds[0]==0&&bounds[1]==0&&bounds[2]==displayWidth&&bounds[3]==displayHeight)return;
            Thread.sleep(100);
        }
        throw new AssertionError("Display has reserved borders: "+Arrays.toString(bounds)+" display="+displayWidth+"x"+displayHeight+" bars="+bars[0]);
    }
    private void appearanceWorkflow()throws Exception{
        fullDisplay();
        require(js("!document.querySelector('#pinned-apps [data-task-app=wallpaper]')&&!document.querySelector('#running-apps [data-task-app=wallpaper]')").equals("true"),"Wallpaper editor is in the taskbar");
        js("createWindow('settings');true");tapDom(".window[aria-label=Ajustes] [data-open=wallpaper]");
        require(js("!!document.querySelector('.window[aria-label=\"Editor de fondo\"]')&&!document.querySelector('.taskbar [data-task-app=wallpaper]')").equals("true"),"Wallpaper editor is not contained in Settings");
        tapDom(".window[aria-label=\"Editor de fondo\"] [data-pref-toggle=motion]");
        require(js("state.prefs.motion").equals("false"),"Motion toggle did not pause");
        String stopped=js("getComputedStyle(document.querySelector('#wall-image')).transform");Thread.sleep(500);
        require(js("getComputedStyle(document.querySelector('#wall-image')).transform").equals(stopped),"Paused wallpaper still moves");
        tapDom(".window[aria-label=\"Editor de fondo\"] [data-pref-toggle=motion]");
        waitJs("document.querySelector('#wall-image').getAnimations().some(a=>a.playState==='running')");
        js("for(const w of [...state.windows])if(w.app==='settings'||w.app==='wallpaper')closeWindow(w);true");
        tapDom("#show-desktop");Thread.sleep(500);
        String before=js("getComputedStyle(document.querySelector('#wall-image')).transform");
        Bitmap first=getUiAutomation().takeScreenshot();Thread.sleep(1800);Bitmap second=getUiAutomation().takeScreenshot();
        require(!js("getComputedStyle(document.querySelector('#wall-image')).transform").equals(before),"Animated wallpaper transform did not advance");
        int changed=0;
        for(int y=16;y<first.getHeight()-130;y+=4)for(int x=16;x<first.getWidth()-16;x+=4){
            int a=first.getPixel(x,y),b=second.getPixel(x,y);
            if(Math.abs(((a>>16)&255)-((b>>16)&255))+Math.abs(((a>>8)&255)-((b>>8)&255))+Math.abs((a&255)-(b&255))>8)changed++;
        }
        File folder=new File(getTargetContext().getExternalFilesDir(null),"visual-evidence");folder.mkdirs();
        try(FileOutputStream output=new FileOutputStream(new File(folder,"wall-motion-before.png"))){first.compress(Bitmap.CompressFormat.PNG,100,output);}
        try(FileOutputStream output=new FileOutputStream(new File(folder,"wall-motion-after.png"))){second.compress(Bitmap.CompressFormat.PNG,100,output);}
        first.recycle();second.recycle();require(changed>30,"Wallpaper pixels did not move: "+changed);
        tapDom("#show-desktop");fullDisplay();
        js("window.appearanceSaved=null;persist().then(ok=>window.appearanceSaved=ok);true");require(waitJs("window.appearanceSaved").equals("true"),"Appearance was not saved");
    }
    private void programNavigation(boolean upgrade)throws Exception{
        ActivityMonitor oldDesktop=addMonitor(DesktopActivity.class.getName(),null,true);
        byte[] desktopBefore=Files.readAllBytes(dataFile("session.rvp").toPath());
        tapDom("#launcher-toggle");fullDisplay();tapDom("#launcher [data-open=programs]");
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
        require(js("document.querySelector('.task-tray').getBoundingClientRect().right<=innerWidth+1").equals("true"),"Taskbar controls overflow the display");
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
        String beforeSearch=hash("session.rvp");tapDom("#launcher-toggle");
        js("(()=>{const field=document.querySelector('#global-search');field.value='Prueba-workbench';field.dispatchEvent(new Event('input',{bubbles:true}));})()");
        tapDom("#launcher [data-program-path=\"Aplicaciones/Prueba-workbench.rxe\"]");
        require(hash("session.rvp").equals(beforeSearch),"Searching reopened and executed the program");
        tapDom("#pinned-apps [data-task-app=bbyq]");
        require(js("getWindow(activeId).rxePath").equals("Aplicaciones/BBY-Q.rxe"),"BBY Q taskbar shortcut opened the wrong window");
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
    @Override public void onStart(){
        Bundle result=new Bundle();
        try{
            String requested=arguments==null?"full":arguments.getString("mode","full");
            boolean boot=requested.equals("boot"),seed=requested.equals("upgradeSeed"),upgrade=requested.equals("upgrade"),legacy=requested.equals("legacy");
            if(boot){ActivityMonitor monitor=addMonitor(WorkbenchActivity.class.getName(),null,false);startActivitySync(new Intent(getTargetContext(),BootActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));activity=(WorkbenchActivity)waitForMonitorWithTimeout(monitor,15000);removeMonitor(monitor);require(activity!=null,"Boot did not reach desktop");}
            else if(legacy){ActivityMonitor monitor=addMonitor(WorkbenchActivity.class.getName(),null,false);runOnMainSync(()->getTargetContext().startActivity(new Intent(getTargetContext(),DesktopActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)));activity=(WorkbenchActivity)waitForMonitorWithTimeout(monitor,15000);removeMonitor(monitor);require(activity!=null,"Restored 2.0 activity did not redirect to Workbench");}
            else activity=(WorkbenchActivity)startActivitySync(new Intent(getTargetContext(),WorkbenchActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
            waitJs("document.querySelector('[data-task-app]')&&typeof nativeRequest==='function'");
            JSONObject snapshot=op("inspect","","testSnapshot");
            require(snapshot.getBoolean("ok"),snapshot.toString());
            require(snapshot.getJSONObject("android").getLong("ram_total_bytes")>0,"No native RAM reading");
            require(snapshot.getJSONObject("core").getString("state_format").equals("RVPC2"),"Wrong checkpoint format");
            require(snapshot.getJSONObject("build").getString("source_commit").matches("[a-f0-9]{40}"),"Missing build provenance");
            boolean restore=boot||legacy||upgrade||requested.equals("restore");
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
            else{programNavigation(upgrade);appearanceWorkflow();}
            if(!seed)fullDisplay();
            String mode=boot?"boot":requested;visualCheck(mode);
            String text="WORKBENCH_TESTS_OK mode="+mode+" native=XI/Ether checkpoint=RVPC2 visual=drawn\n";
            result.putString("stream",text);result.putBoolean("passed",true);finish(Activity.RESULT_OK,result);
        }catch(Throwable failure){
            try{File folder=new File(getTargetContext().getExternalFilesDir(null),"visual-evidence");folder.mkdirs();Bitmap screen=getUiAutomation().takeScreenshot();try(FileOutputStream output=new FileOutputStream(new File(folder,"failure-screen.png"))){screen.compress(Bitmap.CompressFormat.PNG,100,output);}finally{screen.recycle();}Files.write(new File(folder,"failure-dom.txt").toPath(),js("document.documentElement.outerHTML").getBytes(StandardCharsets.UTF_8));}catch(Throwable ignored){}
            result.putString("stream","WORKBENCH_TESTS_FAILED "+failure+"\n");result.putString("error",failure.toString());finish(Activity.RESULT_CANCELED,result);
        }
    }
}
