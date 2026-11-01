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
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;

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
        try{sendPointerSync(down);sendPointerSync(up);}finally{down.recycle();up.recycle();}Thread.sleep(100);
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
        js("createWindow('nativeDesktop');window.ReverseNative.openNativeDesktop();true");Thread.sleep(100);
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

        // X MARKET is a built-in Workbench window, not an RXE masquerading as a market feed.
        String beforeMarket=hash("session.rvp");
        tapDom("#launcher-toggle");
        tapDom("#launcher [data-open=xmarket]");
        waitJs("document.querySelector('.window[aria-label=\"X MARKET\"] .xm-shell')");
        require(js("getWindow(activeId).app").equals("xmarket"),"Start opened the wrong X MARKET application");
        require(js("document.querySelector('.xm-no-data').textContent.includes('Sin datos de mercado')").equals("true"),"X MARKET fabricated a quote");
        tapDom(".window[aria-label=\"X MARKET\"] [data-xm-tab=laplace]");
        require(js("document.querySelector('.xm-lab-results').textContent.includes('12 620')").equals("true"),"Missing closed-world XI demonstration");
        tapDom(".window[aria-label=\"X MARKET\"] [data-xm-shock=on]");
        require(js("document.querySelector('.xm-lab-results').textContent.includes('+250')").equals("true"),"The unknown-event illustration did not update");
        require(js("document.querySelector('.xm-lab-graph').textContent.includes('SINTÉTICO')").equals("true"),"Missing synthetic-data label");
        visualCheck("x-market-in-workbench");
        require(hash("session.rvp").equals(beforeMarket),"Viewing X MARKET mutated XI/Ether state");
        tapDom("#pinned-apps [data-task-app=xmarket]");
        require(js("getWindow(state.windows.find(x=>x.app==='xmarket').id).min").equals("true"),"X MARKET pin did not minimize its window");
        tapDom("#pinned-apps [data-task-app=xmarket]");
        require(js("getWindow(activeId).app").equals("xmarket"),"X MARKET pinned shortcut failed to restore");
        require(resumed instanceof WorkbenchActivity&&oldDesktop.getHits()==0,"X MARKET escaped REVERSE Workbench");

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
        if(mode.equals("full")||mode.equals("native-full")){
            tapDom("#show-desktop");
            File iconsFolder=new File(getTargetContext().getExternalFilesDir(null),"ui-evidence");iconsFolder.mkdirs();
            Bitmap icons=getUiAutomation().takeScreenshot();
            if(icons!=null)try(FileOutputStream output=new FileOutputStream(new File(iconsFolder,"desktop-icons.png"))){icons.compress(Bitmap.CompressFormat.PNG,100,output);}finally{icons.recycle();}
            tapDom("#show-desktop");
        }
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
    private void keyboardWorkflow()throws Exception{
        String frame=js("JSON.stringify({w:getWindow(activeId).w,h:getWindow(activeId).h,x:getWindow(activeId).x,y:getWindow(activeId).y})");
        tapDom("[data-program-input]");
        runOnMainSync(()->((InputMethodManager)activity.getSystemService(android.content.Context.INPUT_METHOD_SERVICE)).showSoftInput(activity.testingWebView(),InputMethodManager.SHOW_IMPLICIT));
        waitJs("document.body.dataset.imeVisible==='true'");
        EditorInfo info=new EditorInfo();AtomicReference<InputConnection> input=new AtomicReference<>();
        runOnMainSync(()->input.set(activity.testingWebView().onCreateInputConnection(info)));
        require(input.get()!=null,"No live Android input connection");
        require((info.imeOptions&EditorInfo.IME_FLAG_NO_FULLSCREEN)!=0,"Fullscreen IME is not disabled");
        CountDownLatch edited=new CountDownLatch(1);
        Runnable edit=()->{try{input.get().commitText("Prueba á ñ",1);}finally{edited.countDown();}};
        android.os.Handler handler=input.get().getHandler();if(handler!=null)handler.post(edit);else runOnMainSync(edit);
        require(edited.await(10,TimeUnit.SECONDS),"Input connection edit timed out");
        waitJs("document.querySelector('[data-program-input]').value.includes('Prueba á ñ')");
        require(js("getWindow(activeId).rxeDraft.includes('Prueba á ñ')").equals("true"),"Native input did not reach the stored draft");
        waitJs("(()=>{const r=document.querySelector('[data-program-input]').getBoundingClientRect();return r.top>=0&&r.bottom<=innerHeight;})()");
        require(js("!window.visualViewport||Math.abs(visualViewport.height-innerHeight)<2").equals("true"),"IME space was subtracted twice");
        tapDom(".window.focused [data-keyboard-dismiss]");
        waitJs("document.body.dataset.imeVisible==='false'");
        require(js("document.querySelector('[data-program-input]').value.includes('Prueba á ñ')").equals("true"),"Dismiss lost the draft");
        require(js("JSON.stringify({w:getWindow(activeId).w,h:getWindow(activeId).h,x:getWindow(activeId).x,y:getWindow(activeId).y})").equals(frame),"Keyboard changed the saved frame");
    }
    private void desktopShellWorkflow(String requested,JSONObject snapshot)throws Exception{
        boolean restore=requested.equals("restore")||requested.equals("boot")||requested.equals("legacy")||requested.equals("upgrade");
        boolean upgrade=requested.equals("upgrade");
        require(js("REVERSE_CAPABILITIES.max_active_qubits").equals("4096"),"Missing verified core profile");
        require(js("document.documentElement.scrollWidth<=innerWidth").equals("true"),"Viewport overflow");
        if(restore){
            require(snapshot.getJSONObject("core").getLong("active_qubits")>=128,"Quantum state not retained");
            require(js("state.prefs.dim").equals("23"),"Preferences not retained");
            require(js("state.files.some(f=>f.name==='Prueba-nativa.txt'&&!f.trashRoot)").equals("true"),"File not retained");
        }else{
            JSONObject arithmetic=op("calculate","2+3*4","shellArithmetic");
            require(arithmetic.getString("value").equals("14"),"Native arithmetic failed");
            JSONObject probe=op("execute",js("XI_PROBE"),"shellProbe");
            require(probe.getJSONObject("core").getLong("active_qubits")==128,"Quantum probe failed");
            js("createFile('text','Prueba-nativa.txt','personal','Texto persistente real');setPref('dim',23,false);true");
        }
        js("createWindow('bbyq');true");waitJs("document.querySelector('[data-program-input]:not(:disabled)')");
        if(requested.equals("full"))keyboardWorkflow();
        if(restore&&!upgrade){retainedProof(false);fullDisplay();visualCheck("native-"+requested);return;}
        if(upgrade)sendMessage("cuántas manzanas tiene ana","Ana tiene cinco manzanas.");
        else{sendMessage("hola","Hola. Soy BBY Q.");sendMessage("ana tiene dos manzanas","Ana tiene dos manzanas.");sendMessage("ella recibe tres mas","Ana tiene cinco manzanas.");}
        JSONObject compiled=op("compileApp",new JSONObject().put("name","AAA-native-test.rxe").put("source","#!reverse-pc-machine-v1\nset r0 11\nmul r0 7\nprint r0\nhalt\n").toString(),"shellCompiled");
        require(compiled.getBoolean("ok"),"Internal fixture compilation failed");
        js("createWindow('bbyq');true");sendMessage("ejecuta programa 1","Acción completada.");
        require(js("document.querySelector('.window.focused .rxe-output').textContent.includes('77')").equals("true"),"W4u did not execute the native program");
        String beforeExperiment=hash("session.rvp");
        JSONObject experiment=op("experiment",js("quantumProgram('ising',{coupling:1,field:1,steps:1})"),"shellExperiment");
        require(experiment.getBoolean("ok")&&experiment.getBoolean("isolated"),"Ising did not execute natively");
        require(experiment.getJSONObject("core").getLong("active_qubits")==2,"Ising qubits mismatch");
        require(hash("session.rvp").equals(beforeExperiment),"Experiment replaced the work state");
        require(js("innerWidth>innerHeight").equals("true"),"APK must use the horizontal PC desktop");
        require(js("document.querySelector('#shell-home,#mobile-navigation')===null").equals("true"),"Mobile home is still present");
        js("createWindow('files');createWindow('programs');true");
        require(js("state.windows.filter(w=>w.space===state.space&&!w.min).length>=2").equals("true"),"Focusing a PC window minimized its peers");
        require(js("document.querySelector('.window.focused').getBoundingClientRect().width<document.querySelector('#desktop').clientWidth").equals("true"),"PC window was forced full width");
        require(js("getComputedStyle(document.querySelector('.window.focused [data-window-action=max]')).display!=='none'").equals("true"),"PC controls are missing");
        tapDom("#show-desktop");
        require(js("state.windows.every(w=>w.space!==state.space||w.min)").equals("true"),"Show desktop did not minimize the windows");
        tapDom("#show-desktop");
        require(js("state.windows.filter(w=>w.space===state.space&&!w.min).length>=2").equals("true"),"Show desktop did not restore the windows");
        js("createWindow('xi');getWindow(activeId).xiTab='hamiltonian';renderWindowContent(getWindow(activeId));true");
        require(js("document.querySelector('.hamiltonian-equation').textContent.includes('Z₀Z₁')").equals("true"),"Hamiltonian surface missing");
        js("createWindow('bbyq');true");
        js("window.shellSaved=null;persist().then(ok=>window.shellSaved=ok);true");
        require(waitJs("window.shellSaved").equals("true"),"Profile not committed");
        retainedProof(true);fullDisplay();visualCheck("native-"+requested);
    }
    private String graphicsJs(RxeGraphicsActivity game,String script)throws Exception{
        CountDownLatch ready=new CountDownLatch(1);AtomicReference<String> value=new AtomicReference<>();
        runOnMainSync(()->game.testingWebView().evaluateJavascript(script,result->{value.set(result);ready.countDown();}));
        require(ready.await(10,TimeUnit.SECONDS),"Graphics JavaScript timeout");return value.get();
    }
    private void graphicsTap(RxeGraphicsActivity game,String selector)throws Exception{
        String encoded=graphicsJs(game,"(()=>{const r=document.querySelector("+JSONObject.quote(selector)+").getBoundingClientRect();return JSON.stringify({x:r.x+r.width/2,y:r.y+r.height/2,width:innerWidth});})()");
        JSONObject point=new JSONObject(new JSONArray("["+encoded+"]").getString(0));
        int[] origin=new int[2],width={0};runOnMainSync(()->{game.testingWebView().getLocationOnScreen(origin);width[0]=game.testingWebView().getWidth();});
        float scale=(float)(width[0]/point.getDouble("width")),x=origin[0]+(float)point.getDouble("x")*scale,y=origin[1]+(float)point.getDouble("y")*scale;
        long t=SystemClock.uptimeMillis();MotionEvent down=MotionEvent.obtain(t,t,MotionEvent.ACTION_DOWN,x,y,0),up=MotionEvent.obtain(t,t+70,MotionEvent.ACTION_UP,x,y,0);
        try{sendPointerSync(down);sendPointerSync(up);}finally{down.recycle();up.recycle();}
    }
    private void graphicsWorkflow(JSONObject before)throws Exception{
        // Isolated workspace: fresh seeding, exact official upgrade, user file,
        // removal and repeated starts. Never edits the real desktop fixtures.
        WorkspaceFiles migration=new WorkspaceFiles(new File(getTargetContext().getCacheDir(),"prisma-upgrade-"+System.nanoTime()));
        android.content.SharedPreferences flags=getTargetContext().getSharedPreferences("prisma-upgrade-check",0);flags.edit().clear().commit();
        WorkbenchPrograms.seedGraphics(getTargetContext(),migration,flags);byte[] current=migration.read("Aplicaciones/PRISMA.rxe");
        require(new JSONObject(new String(NativeRuntime.inspectRxe(current),StandardCharsets.UTF_8)).getString("app_version").equals("2.1.0"),"Fresh install did not seed PRISMA 2.1");
        byte[] prior;try(java.io.InputStream input=getContext().getAssets().open("prisma-1.1.rxe")){prior=WorkbenchPrograms.read(input);}
        require(digest(prior).equals(WorkbenchPrograms.PRISMA_11_SHA),"Wrong official PRISMA upgrade fixture");
        require(WorkbenchPrograms.trustedOldPrisma("8eab78b37f7d18365f26746e4ed30bf6433c36109f23c0ee92d6c42804b534f0"),"Official PRISMA 1.2 was not allowlisted");
        require(WorkbenchPrograms.trustedOldPrisma("c6bd13581a7a565cd9ea54b34dbefc3f92ca473d4bd5701478853a0205653fd9"),"Last official PRISMA 1.2 was not allowlisted");
        require(WorkbenchPrograms.trustedOldPrisma("3d4659559cf02e2f4509971afc84db56b84bc9a07faaf545d0064d44504399ce"),"Cycle 03 pre-release was not allowlisted");
        require(WorkbenchPrograms.trustedOldPrisma("446bebd4c97cbd4807aea0624da0bd45e076541f5e491540f9bffd4b4797370e"),"Cycle 03 final release was not allowlisted");
        require(!WorkbenchPrograms.trustedOldPrisma(digest(current)),"New official release wrongly matches an old executable");
        migration.write("Aplicaciones/PRISMA.rxe",prior,true);flags.edit().remove("prisma-ui-origin-sha").putBoolean("prisma-2.1-seeded",false).commit();
        WorkbenchPrograms.seedGraphics(getTargetContext(),migration,flags);
        require(Arrays.equals(current,migration.read("Aplicaciones/PRISMA.rxe")),"Official PRISMA 1.1 was not upgraded");
        require(digest(prior).equals(flags.getString("prisma-ui-origin-sha","")),"Official upgrade lost its WebView records origin");
        byte[] custom=NativeRuntime.compileRxe("#!reverse-pc-machine-v1\nset r0 42\nprint r0\nhalt\n".getBytes(StandardCharsets.UTF_8),"User app".getBytes(StandardCharsets.UTF_8));
        migration.write("Aplicaciones/PRISMA.rxe",custom,true);flags.edit().putBoolean("prisma-2.1-seeded",false).commit();
        WorkbenchPrograms.seedGraphics(getTargetContext(),migration,flags);
        require(Arrays.equals(custom,migration.read("Aplicaciones/PRISMA.rxe")),"Upgrade overwrote a custom executable");
        require(!WorkbenchPrograms.trustedOldPrisma(digest(custom)),"Customized image was misclassified as official");
        migration.trash("Aplicaciones/PRISMA.rxe");flags.edit().putBoolean("prisma-2.1-seeded",false).commit();
        WorkbenchPrograms.seedGraphics(getTargetContext(),migration,flags);WorkbenchPrograms.seedGraphics(getTargetContext(),migration,flags);
        require(migration.list("Aplicaciones").isEmpty(),"Upgrade restored a removed game");
        JSONObject catalog=op("listApps","","graphicsCatalog");JSONObject program=null;
        for(int i=0;i<catalog.getJSONArray("apps").length();i++){JSONObject app=catalog.getJSONArray("apps").getJSONObject(i);if("org.reverse.prisma".equals(app.getJSONObject("metadata").optString("app_id")))program=app;}
        require(program!=null,"PRISMA binary missing from native catalog");
        require(program.getJSONObject("metadata").getInt("version")==3,"Wrong graphics executable format");
        final JSONObject selected=program;
        ActivityMonitor monitor=addMonitor(RxeGraphicsActivity.class.getName(),null,false);
        op("launchGraphics",new JSONObject().put("path",selected.getString("path")).put("identity",selected.getString("identity")).toString(),"graphicsLaunch");
        RxeGraphicsActivity game=(RxeGraphicsActivity)waitForMonitorWithTimeout(monitor,15000);removeMonitor(monitor);require(game!=null,"RXE did not open its native graphics adapter");
        long until=SystemClock.uptimeMillis()+20000;boolean loaded=false;
        while(SystemClock.uptimeMillis()<until){AtomicReference<WebView> view=new AtomicReference<>();runOnMainSync(()->view.set(game.testingWebView()));if(view.get()!=null&&"true".equals(graphicsJs(game,"!!document.getElementById('startBtn')&&!!document.getElementById('game').dataset.renderer"))){loaded=true;break;}SystemClock.sleep(50);}
        require(loaded,"Local graphics assets did not load");
        require("true".equals(graphicsJs(game,"innerWidth>innerHeight")),"Game is not landscape");
        require(graphicsJs(game,"document.getElementById('game').dataset.renderer").contains("ether-render-x-cpu"),"Ether Render X was not selected");
        String uiOrigin=getTargetContext().getSharedPreferences("workbench-programs",0).getString("prisma-ui-origin-sha","");
        require(uiOrigin.matches("[0-9a-f]{64}"),"Official WebView origin was not saved");
        String expectedHost=uiOrigin.substring(0,32)+"."+uiOrigin.substring(32)+".rxe.reverse.local";
        require(JSONObject.quote(expectedHost).equals(graphicsJs(game,"location.host")),"Official PRISMA WebView did not retain its records origin");
        long firstFrame=SystemClock.uptimeMillis()+15000;boolean nativeFrame=false;
        while(SystemClock.uptimeMillis()<firstFrame){if("true".equals(graphicsJs(game,"(()=>{const r=JSON.parse(ReverseGraphics.xRenderInfo());return r.frames>0&&r.cubes>=7&&r.cubes<=23&&r.surface_pixels>0&&r.candidate_queries<r.width*r.height&&Number(document.getElementById('game').dataset.rigNativeCount)>0;})()"))){nativeFrame=true;break;}SystemClock.sleep(60);}
        require(nativeFrame,"Ether Render X must present playable preview cubes and native moving-head parts; stats="+graphicsJs(game,"ReverseGraphics.xRenderInfo()"));
        require("true".equals(graphicsJs(game,"document.documentElement.classList.contains('native-xrender')&&!document.querySelector('.gpu-canvas')")),"Legacy GPU cube renderer remained active");
        graphicsJs(game,"window.graphicReplies=[];window.addEventListener('reverse-score',e=>graphicReplies.push(e.detail));ReverseGraphics.event(1,1,0,0);true");
        for(int serial=1;serial<=3;serial++){
            if(serial==2)graphicsJs(game,"ReverseGraphics.event(2,1,1,150);true");
            if(serial==3)graphicsJs(game,"ReverseGraphics.event(3,1,2,0);true");
            long end=SystemClock.uptimeMillis()+15000;
            while(SystemClock.uptimeMillis()<end&&!"true".equals(graphicsJs(game,"graphicReplies.length>="+serial)))SystemClock.sleep(30);
            require("true".equals(graphicsJs(game,"graphicReplies.length==="+serial+"&&graphicReplies.at(-1).ok")),"Native XI event was not committed");
        }
        require("true".equals(graphicsJs(game,"graphicReplies[1].state.score===150&&graphicReplies[1].state.combo===1&&graphicReplies[2].state.combo===0&&graphicReplies[2].state.misses===1")),"Wrong persisted XI score");
        graphicsJs(game,"window.blockedNetwork=false;fetch('https://example.com/').catch(()=>blockedNetwork=true);true");
        require("true".equals(graphicsJs(game,"blockedNetwork")),"Graphics adapter allowed an external connection");
        File folder=new File(getTargetContext().getExternalFilesDir(null),"ui-evidence");folder.mkdirs();Bitmap screen=getUiAutomation().takeScreenshot();if(screen!=null)try(FileOutputStream output=new FileOutputStream(new File(folder,"prisma-xrender-screen.png"))){screen.compress(Bitmap.CompressFormat.PNG,100,output);screen.recycle();}
        graphicsTap(game,"#startBtn");long playDeadline=SystemClock.uptimeMillis()+20000;
        while(SystemClock.uptimeMillis()<playDeadline&&!"true".equals(graphicsJs(game,"document.body.classList.contains('is-playing')")))SystemClock.sleep(60);
        require("true".equals(graphicsJs(game,"document.body.classList.contains('is-playing')")),"Native game did not start after touch");
        SystemClock.sleep(3600);require("true".equals(graphicsJs(game,"JSON.parse(ReverseGraphics.xRenderInfo()).frames>10")),"X Render stopped during playback");
        graphicsTap(game,"#pauseBtn");SystemClock.sleep(200);
        require("true".equals(graphicsJs(game,"!document.getElementById('pauseOverlay').hidden")),"Native game did not pause");
        graphicsTap(game,"#resumeBtn");SystemClock.sleep(200);
        require("true".equals(graphicsJs(game,"document.body.classList.contains('is-playing')")),"Native game did not resume");
        Files.write(new File(folder,"prisma-xrender-info.json").toPath(),new JSONArray("["+graphicsJs(game,"ReverseGraphics.xRenderInfo()")+"]").getString(0).getBytes(StandardCharsets.UTF_8));
        runOnMainSync(game::finish);SystemClock.sleep(250);
        JSONObject after=op("inspect","","graphicsCoreAfter");
        for(String key:new String[]{"memory_revision","memory_overrides","core_revision"})require(before.getJSONObject("core").getLong(key)==after.getJSONObject("core").getLong(key),"Game altered desktop authority: "+key);
    }
    @Override public void onStart(){
        Bundle result=new Bundle();
        try{
            String requested=arguments==null?"full":arguments.getString("mode","full");
            if(requested.equals("migration")){
                int checks=E025MigrationChecks.run(getTargetContext(),getContext());
                result.putString("stream","WORKBENCH_TESTS_OK mode=migration checks="+checks+" native=XI/Ether\n");
                result.putBoolean("passed",true);finish(Activity.RESULT_OK,result);return;
            }
            boolean boot=requested.equals("boot"),seed=requested.equals("upgradeSeed"),upgrade=requested.equals("upgrade"),legacy=requested.equals("legacy");
            ActivityMonitor desktopMonitor=addMonitor(WorkbenchActivity.class.getName(),null,false);
            Class<?> entry=boot?BootActivity.class:legacy?DesktopActivity.class:WorkbenchActivity.class;
            runOnMainSync(()->getTargetContext().startActivity(new Intent(getTargetContext(),entry).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)));
            activity=(WorkbenchActivity)waitForMonitorWithTimeout(desktopMonitor,15000);removeMonitor(desktopMonitor);
            require(activity!=null,"Entry did not reach Workbench: "+requested);
            waitJs("document.querySelector('[data-task-app]')&&typeof nativeRequest==='function'");
            JSONObject snapshot=op("inspect","","testSnapshot");
            require(snapshot.getBoolean("ok"),snapshot.toString());
            require(snapshot.getJSONObject("android").getLong("ram_total_bytes")>0,"No native RAM reading");
            require(snapshot.getJSONObject("core").getString("state_format").equals("RVPC2"),"Wrong checkpoint format");
            require(snapshot.getJSONObject("build").getString("source_commit").matches("[a-f0-9]{40}"),"Missing build provenance");
            if(requested.equals("graphics")){
                graphicsWorkflow(snapshot);result.putString("stream","WORKBENCH_TESTS_OK mode=graphics native=XI renderer=Ether-Render-X-CPU presenter=GLES3 touch=verified isolation=verified\n");result.putBoolean("passed",true);finish(Activity.RESULT_OK,result);return;
            }
            if(!seed&&js("typeof window.ReverseShell==='object'").equals("true")){
                desktopShellWorkflow(requested,snapshot);
                result.putString("stream","WORKBENCH_TESTS_OK mode="+requested+" native=XI/Ether desktop-shell=verified\n");result.putBoolean("passed",true);finish(Activity.RESULT_OK,result);return;
            }
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
            android.util.Log.e("ReverseWorkbenchTest","WORKBENCH_TESTS_FAILED",failure);
            if(activity!=null)try{File folder=new File(getTargetContext().getExternalFilesDir(null),"visual-evidence");folder.mkdirs();Bitmap screen=getUiAutomation().takeScreenshot();try(FileOutputStream output=new FileOutputStream(new File(folder,"failure-screen.png"))){screen.compress(Bitmap.CompressFormat.PNG,100,output);}finally{screen.recycle();}Files.write(new File(folder,"failure-dom.txt").toPath(),js("document.documentElement.outerHTML").getBytes(StandardCharsets.UTF_8));}catch(Throwable ignored){}
            result.putString("stream","WORKBENCH_TESTS_FAILED "+failure+"\n");result.putString("error",failure.toString());finish(Activity.RESULT_CANCELED,result);
        }
    }
}
