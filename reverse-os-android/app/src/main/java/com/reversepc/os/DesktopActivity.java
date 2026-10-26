package com.reversepc.os;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.RadialGradient;
import android.graphics.Shader;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.BatteryManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.text.InputType;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONObject;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Desktop is independent of the JNI engine at startup.
 * Native initialization, programs and RVPC data are loaded on a worker thread.
 * Even if the engine fails on a particular Android device, the user sees the
 * desktop plus a concrete diagnostic instead of an empty/black activity.
 */
public final class DesktopActivity extends Activity {
    private static final String LOG = "ReverseDesktop";
    private static final int BG=0xff070d15, CARD=0xff111e2d, CARD_BRIGHT=0xff1a2b3c;
    private static final int WHITE=0xfff1f6f9, MUTED=0xff9caebf, ACCENT=0xff42e8cc;
    private static final int BLUE=0xff76adff, VIOLET=0xffd5abff, AMBER=0xffffce7d;
    private final ExecutorService engine=Executors.newSingleThreadExecutor();
    private final Handler clockHandler=new Handler(Looper.getMainLooper());
    private SessionStore store;
    private String engineFailure="";
    private TextView statusLabel, clockLabel, statusDetail;
    private final StringBuilder consoleHistory=new StringBuilder(
        "REVERSE TERMINAL   /   XI MACHINE\n"
        + "Sistema de comandos y ejecución real.\n"
        + "Escribe help para comenzar.\n\n");
    private boolean executing=false;
    private final Runnable tick=new Runnable() {
        @Override public void run(){
            if(clockLabel!=null)clockLabel.setText(
                new SimpleDateFormat("HH:mm",Locale.getDefault()).format(new Date()));
            clockHandler.postDelayed(this,60000L);
        }
    };

    private int dp(float value){
        return Math.round(value*getResources().getDisplayMetrics().density);
    }
    private GradientDrawable round(int color,int border,int radius){
        GradientDrawable d=new GradientDrawable();
        d.setColor(color);
        d.setCornerRadius(dp(radius));
        if(border!=0)d.setStroke(dp(1),border);
        return d;
    }
    private TextView label(String value,int size,int color,boolean strong){
        TextView t=new TextView(this);
        t.setText(value);
        t.setTextColor(color);
        t.setTextSize(size);
        t.setTypeface(Typeface.create(strong?"sans-serif-medium":"sans-serif",Typeface.NORMAL));
        t.setIncludeFontPadding(true);
        return t;
    }
    private LinearLayout vertical(){
        LinearLayout v=new LinearLayout(this);
        v.setOrientation(LinearLayout.VERTICAL);
        return v;
    }
    private LinearLayout horizontal(){
        LinearLayout v=new LinearLayout(this);
        v.setOrientation(LinearLayout.HORIZONTAL);
        v.setGravity(Gravity.CENTER_VERTICAL);
        return v;
    }
    private void space(LinearLayout v,int size){
        View a=new View(this);
        v.addView(a,new LinearLayout.LayoutParams(1,dp(size)));
    }
    private TextView touch(String text,int size,boolean primary,Runnable action){
        TextView t=label(text,size,primary?BG:WHITE,true);
        t.setGravity(Gravity.CENTER);
        t.setBackground(round(primary?ACCENT:CARD_BRIGHT,primary?0:0xff304658,13));
        t.setPadding(dp(15),dp(12),dp(15),dp(12));
        t.setClickable(true);
        t.setFocusable(true);
        t.setOnClickListener(v->action.run());
        return t;
    }
    private void margin(LinearLayout parent,View view,int top){
        LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2);
        p.topMargin=dp(top);
        parent.addView(view,p);
    }
    private void rowWeight(LinearLayout parent,View view,float weight){
        LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(0,-1,weight);
        p.setMargins(dp(4),0,dp(4),0);
        parent.addView(view,p);
    }
    private void info(String message){
        Toast.makeText(this,message,Toast.LENGTH_LONG).show();
    }

    @Override public void onCreate(Bundle previous) {
        super.onCreate(previous);
        getWindow().setStatusBarColor(BG);
        getWindow().setNavigationBarColor(BG);
        getWindow().getDecorView().setSystemUiVisibility(
            View.SYSTEM_UI_FLAG_FULLSCREEN|View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        buildDesktop();
        clockHandler.post(tick);
        engine.execute(()->{
            try {
                SessionStore s=new SessionStore(getApplicationContext());
                String stats=NativeRuntime.inspect(s.loadState());
                store=s;
                Log.i(LOG,"DESKTOP_CORE_READY "+stats);
                runOnUiThread(()->{
                    if(isFinishing()||isDestroyed())return;
                    statusLabel.setText("● CORE ONLINE");
                    statusLabel.setTextColor(ACCENT);
                    statusDetail.setText("XI MACHINE  •  ETHER ACTIVE");
                });
            }catch(Throwable fault){
                engineFailure=fault.getClass().getSimpleName()+": "+fault.getMessage();
                Log.e(LOG,"ENGINE_BOOT_FAILED",fault);
                runOnUiThread(()->{
                    if(isFinishing()||isDestroyed())return;
                    statusLabel.setText("● CORE ERROR");
                    statusLabel.setTextColor(0xffff9898);
                    statusDetail.setText("Toca CORE ERROR para ver el diagnóstico.");
                });
            }
        });
    }

    private void buildDesktop(){
        FrameLayout root=new FrameLayout(this);
        root.setBackgroundColor(BG);
        root.addView(new DesktopBackdrop(),new FrameLayout.LayoutParams(-1,-1));

        LinearLayout layout=vertical();
        layout.setPadding(dp(14),dp(22),dp(14),dp(13));
        root.addView(layout,new FrameLayout.LayoutParams(-1,-1));
        // Android 15+ draws host navigation over app windows by default.
        // Reserve the genuine gesture/button inset so the desktop dock
        // stays touchable and legible on smaller phones (e.g. Galaxy A16).
        root.setOnApplyWindowInsetsListener((view,insets)->{
            int nav=android.os.Build.VERSION.SDK_INT>=30
                ? insets.getInsets(android.view.WindowInsets.Type.navigationBars()).bottom
                : insets.getSystemWindowInsetBottom();
            layout.setPadding(dp(14),dp(22),dp(14),Math.max(dp(13),nav+dp(7)));
            return insets;
        });

        // Desktop system bar
        LinearLayout toolbar=horizontal();
        TextView mark=label("R",22,BG,true);
        mark.setGravity(Gravity.CENTER);
        mark.setBackground(round(ACCENT,0,11));
        toolbar.addView(mark,new LinearLayout.LayoutParams(dp(43),dp(43)));
        LinearLayout titles=vertical();
        titles.setPadding(dp(11),0,0,0);
        titles.addView(label("REVERSE OS",17,WHITE,true));
        TextView sub=label("PERSONAL COMPUTER / XI",9,MUTED,false);
        sub.setLetterSpacing(0.12f);
        titles.addView(sub);
        toolbar.addView(titles,new LinearLayout.LayoutParams(0,-2,1f));
        clockLabel=label("",15,WHITE,true);
        toolbar.addView(clockLabel);
        TextView power=label(" PWR ",11,ACCENT,true);
        power.setPadding(dp(11),dp(10),dp(5),dp(10));
        power.setOnClickListener(v->openPower());
        toolbar.addView(power);
        layout.addView(toolbar,new LinearLayout.LayoutParams(-1,dp(46)));

        LinearLayout stateBar=horizontal();
        stateBar.setPadding(dp(12),dp(9),dp(12),dp(9));
        stateBar.setBackground(round(0xcc0f202c,0xff2d4957,14));
        statusLabel=label("● CORE INIT",11,AMBER,true);
        statusLabel.setClickable(true);
        statusLabel.setOnClickListener(v->{
            if(!engineFailure.isEmpty())new AlertDialog.Builder(this)
                .setTitle("Diagnóstico de REVERSE-PC")
                .setMessage(engineFailure)
                .setPositiveButton("CERRAR",null).show();
            else openMonitor();
        });
        stateBar.addView(statusLabel,new LinearLayout.LayoutParams(0,-2,1f));
        statusDetail=label("INICIALIZANDO ENTORNO",9,MUTED,false);
        stateBar.addView(statusDetail);
        margin(layout,stateBar,13);

        ScrollView scroll=new ScrollView(this);
        scroll.setFillViewport(false);
        scroll.setVerticalScrollBarEnabled(false);
        LinearLayout main=vertical();
        main.setPadding(dp(0),dp(10),dp(0),dp(12));

        TextView micro=label("YOUR COMPUTER",11,ACCENT,true);
        micro.setLetterSpacing(0.24f);
        main.addView(micro);
        TextView hero=label("MR REVERSE",34,WHITE,true);
        hero.setLetterSpacing(0.025f);
        margin(main,hero,6);
        TextView caption=label("Un espacio. Un núcleo. Tus propias reglas.",13,0xffbfd2da,false);
        margin(main,caption,4);

        LinearLayout metrics=horizontal();
        metrics.setGravity(Gravity.CENTER_VERTICAL);
        TextView badge=label("XI MACHINE  V1",10,ACCENT,true);
        badge.setPadding(dp(10),dp(8),dp(10),dp(8));
        badge.setBackground(round(0xff102b32,0xff23595d,8));
        metrics.addView(badge);
        TextView badge2=label("  RVPC2  •  ETHER",10,MUTED,true);
        metrics.addView(badge2);
        margin(main,metrics,10);

        space(main,12);
        TextView libraryTitle=label("APPLICATIONS",11,0xffb5c8d2,true);
        libraryTitle.setLetterSpacing(0.22f);
        main.addView(libraryTitle);
        TextView subtitle=label("Abre herramientas, archivos y programas",12,MUTED,false);
        margin(main,subtitle,4);
        space(main,10);

        // Compact 3 x 2 desktop launcher: show the complete application
        // library above the dock even at 320dp emulator resolution.
        LinearLayout r1=horizontal();
        addTile(r1,"⌘","XI STUDIO","Programas XI",ACCENT,()->openStudio(0,null));
        addTile(r1,">_","TERMINAL","Consola real",BLUE,this::openTerminal);
        addTile(r1,"▤","FILES","Archivos .xi",AMBER,this::openFiles);
        main.addView(r1,new LinearLayout.LayoutParams(-1,dp(96)));
        space(main,9);
        LinearLayout r2=horizontal();
        addTile(r2,"◈","ETHER CORE","Estado real",VIOLET,this::openMonitor);
        addTile(r2,"◎","CHROMIUM","WebView host",BLUE,this::openBrowser);
        addTile(r2,"⚙","SETTINGS","Configurar",ACCENT,this::openSettings);
        main.addView(r2,new LinearLayout.LayoutParams(-1,dp(96)));

        TextView note=label("REVERSE-PC nativo  ·  Chromium utiliza Android WebView",10,MUTED,false);
        note.setGravity(Gravity.CENTER_HORIZONTAL);
        margin(main,note,18);

        scroll.addView(main);
        layout.addView(scroll,new LinearLayout.LayoutParams(-1,0,1f));
        layout.addView(buildDock(),new LinearLayout.LayoutParams(-1,dp(76)));

        setContentView(root);
        Log.i(LOG,"DESKTOP_SHOWN REVERSE OS MR REVERSE");
    }

    private void addTile(LinearLayout row,String glyph,String name,String subtitle,int color,Runnable open){
        LinearLayout cell=vertical();
        cell.setGravity(Gravity.CENTER_VERTICAL);
        cell.setPadding(dp(9),dp(7),dp(6),dp(7));
        cell.setBackground(round(0xe9142333,0xff2a3c4b,20));
        cell.setClickable(true);
        cell.setFocusable(true);
        cell.setOnClickListener(v->open.run());

        TextView symbol=label(glyph,19,color,true);
        symbol.setGravity(Gravity.CENTER);
        symbol.setBackground(round(0xff233549,0,13));
        cell.addView(symbol,new LinearLayout.LayoutParams(dp(35),dp(35)));
        TextView title=label(name,11,WHITE,true);
        title.setSingleLine(true);
        title.setEllipsize(android.text.TextUtils.TruncateAt.END);
        margin(cell,title,5);
        TextView caption=label(subtitle,9,MUTED,false);
        caption.setSingleLine(true);
        caption.setEllipsize(android.text.TextUtils.TruncateAt.END);
        margin(cell,caption,1);
        LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(0,-1,1f);
        p.setMargins(dp(4),0,dp(4),0);
        row.addView(cell,p);
    }
    private LinearLayout buildDock(){
        LinearLayout dock=horizontal();
        dock.setGravity(Gravity.CENTER);
        dock.setPadding(dp(8),dp(6),dp(8),dp(6));
        dock.setBackground(round(0xee122334,0xff345060,23));
        addDock(dock,"⌂","HOME",ACCENT,()->{});
        addDock(dock,"⌘","XI",WHITE,()->openStudio(0,null));
        addDock(dock,">_","TERM",WHITE,this::openTerminal);
        addDock(dock,"▤","FILES",WHITE,this::openFiles);
        addDock(dock,"◎","WEB",WHITE,this::openBrowser);
        addDock(dock,"◈","CORE",WHITE,this::openMonitor);
        return dock;
    }
    private void addDock(LinearLayout dock,String glyph,String name,int color,Runnable open){
        LinearLayout item=vertical();
        item.setGravity(Gravity.CENTER);
        TextView icon=label(glyph,21,color,true);
        icon.setGravity(Gravity.CENTER);
        item.addView(icon);
        TextView sub=label(name,9,color==ACCENT?ACCENT:MUTED,true);
        sub.setGravity(Gravity.CENTER);
        item.addView(sub);
        item.setClickable(true);
        item.setFocusable(true);
        item.setOnClickListener(v->open.run());
        dock.addView(item,new LinearLayout.LayoutParams(0,-1,1f));
    }

    private static final class WindowUi {
        final Dialog dialog;
        final LinearLayout content;
        WindowUi(Dialog dialog,LinearLayout content) {
            this.dialog=dialog;this.content=content;
        }
    }
    private WindowUi window(String title,String subtitle){
        Dialog dialog=new Dialog(this);
        LinearLayout shell=vertical();
        shell.setBackground(round(0xff0d1a27,0xff466075,23));
        shell.setPadding(dp(1),dp(1),dp(1),dp(1));

        LinearLayout top=horizontal();
        top.setPadding(dp(13),dp(12),dp(12),dp(12));
        TextView dot=label("● ● ●",11,ACCENT,true);
        top.addView(dot);
        LinearLayout name=vertical();name.setPadding(dp(11),0,0,0);
        name.addView(label(title,16,WHITE,true));
        name.addView(label(subtitle,10,MUTED,false));
        top.addView(name,new LinearLayout.LayoutParams(0,-2,1f));
        TextView close=label("×",29,WHITE,false);
        close.setGravity(Gravity.CENTER);
        close.setContentDescription("CERRAR "+title);
        close.setBackground(round(0xff203346,0,12));
        top.addView(close,new LinearLayout.LayoutParams(dp(44),dp(40)));
        close.setOnClickListener(v->dialog.dismiss());
        shell.addView(top);
        View hairline=new View(this);hairline.setBackgroundColor(0xff263a4b);
        shell.addView(hairline,new LinearLayout.LayoutParams(-1,dp(1)));

        LinearLayout body=vertical();body.setPadding(dp(14),dp(14),dp(14),dp(14));
        shell.addView(body,new LinearLayout.LayoutParams(-1,0,1f));
        dialog.setContentView(shell);
        dialog.show();
        Window actual=dialog.getWindow();
        if(actual!=null){
            actual.setBackgroundDrawableResource(android.R.color.transparent);
            actual.addFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND);
            WindowManager.LayoutParams p=actual.getAttributes();
            p.width=(int)(getResources().getDisplayMetrics().widthPixels*0.94f);
            p.height=(int)(getResources().getDisplayMetrics().heightPixels*0.80f);
            p.dimAmount=0.50f;p.gravity=Gravity.CENTER;
            actual.setAttributes(p);
            actual.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        }
        return new WindowUi(dialog,body);
    }
    private void appError(LinearLayout parent,String message){
        TextView t=label(message,13,0xffffa5a5,false);
        t.setPadding(dp(12),dp(15),dp(12),dp(15));
        parent.addView(t);
    }
    private void openStudio(int tab,String file){
        Intent editor=new Intent(this,MainActivity.class);
        editor.putExtra("tab",tab);
        if(file!=null)editor.putExtra("program",file);
        startActivity(editor);
        overridePendingTransition(android.R.anim.fade_in,android.R.anim.fade_out);
    }

    // Terminal executes programs through the exact JNI bridge used by the original GUI.
    private void openTerminal(){
        WindowUi w=window("TERMINAL","XI SHELL  •  ejecución nativa");
        ScrollView scroll=new ScrollView(this);
        TextView output=label(consoleHistory.toString(),12,0xffc2ecdf,false);
        output.setTypeface(Typeface.MONOSPACE);
        output.setPadding(dp(12),dp(13),dp(12),dp(13));
        output.setBackground(round(0xff06131d,0xff213649,14));
        scroll.addView(output);
        w.content.addView(scroll,new LinearLayout.LayoutParams(-1,0,1f));
        space(w.content,11);

        LinearLayout inputLine=horizontal();
        EditText command=new EditText(this);
        command.setSingleLine(true);command.setTextColor(WHITE);command.setTextSize(14);
        command.setHintTextColor(MUTED);command.setHint("help / ls / run 01_euclides.xi");
        command.setInputType(InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        command.setBackground(round(CARD_BRIGHT,0xff304657,10));
        command.setPadding(dp(10),dp(10),dp(10),dp(10));
        inputLine.addView(command,new LinearLayout.LayoutParams(0,dp(52),1f));
        TextView send=touch("RUN",12,true,()->{
            String entry=command.getText().toString().trim();
            command.setText("");
            terminal(entry,w,output,scroll);
        });
        LinearLayout.LayoutParams sendParams=new LinearLayout.LayoutParams(dp(67),dp(52));
        sendParams.leftMargin=dp(8);
        inputLine.addView(send,sendParams);
        w.content.addView(inputLine);
        TextView help=label("help · ls · run nombre.xi · core · edit nombre.xi · clear",10,MUTED,false);
        margin(w.content,help,12);
        scroll.post(()->scroll.fullScroll(View.FOCUS_DOWN));
    }
    private void putConsole(String data,TextView output,ScrollView scroll){
        consoleHistory.append(data);
        if(consoleHistory.length()>45000)consoleHistory.delete(0,9000);
        output.setText(consoleHistory.toString());
        scroll.post(()->scroll.fullScroll(View.FOCUS_DOWN));
    }
    private String pretty(String raw){
        if(raw.trim().isEmpty())return "(Programa completado sin salida)\n";
        StringBuilder formatted=new StringBuilder();
        for(String line:raw.split("\n")){
            if(line.trim().isEmpty())continue;
            try{
                JSONObject json=new JSONObject(line);
                if("register".equals(json.optString("type"))){
                    formatted.append(json.optString("register")).append(" = ")
                             .append(json.optString("value")).append("\n");
                }else formatted.append(line).append("\n");
            }catch(Exception e){formatted.append(line).append('\n');}
        }
        return formatted.toString();
    }
    private void terminal(String input,WindowUi w,TextView output,ScrollView scroll){
        if(input.isEmpty())return;
        if(input.equalsIgnoreCase("clear")){
            consoleHistory.setLength(0);output.setText("");return;
        }
        putConsole("reverse@xi ~> "+input+"\n",output,scroll);
        String[] words=input.split("\\s+",2);
        String cmd=words[0].toLowerCase(Locale.ROOT);
        String arg=words.length==2?words[1].trim():"";
        if(cmd.equals("help")){
            putConsole("help : comandos\nls : listar programas\n"
                +"run programa.xi : ejecutar en Ether\ncore : estado nativo\n"
                +"edit programa.xi : abrir estudio XI\nclear : limpiar consola\n\n",output,scroll);
        }else if(cmd.equals("edit")){
            if(arg.isEmpty()){putConsole("Falta nombre de archivo.\n",output,scroll);return;}
            w.dialog.dismiss();openStudio(0,SessionStore.normalized(arg));
        }else if(cmd.equals("ls")||cmd.equals("core")||cmd.equals("run")){
            if(executing){putConsole("Ya hay una ejecución en curso.\n",output,scroll);return;}
            executing=true;
            engine.execute(()->{
                String result;
                try{
                    if(store==null)throw new IllegalStateException("Núcleo no disponible: "+engineFailure);
                    if(cmd.equals("ls")){
                        List<String> files=store.listPrograms();
                        StringBuilder b=new StringBuilder();
                        for(String f:files)b.append("  ").append(f).append('\n');
                        result=b.toString();
                    }else if(cmd.equals("core")){
                        result=NativeRuntime.inspect(store.loadState())+"\n";
                    }else{
                        String name=SessionStore.normalized(arg);
                        String program=store.readProgram(name);
                        long start=SystemClock.elapsedRealtimeNanos();
                        ResultPacket payload=ResultPacket.parse(
                            NativeRuntime.execute(store.loadState(),program));
                        store.writeState(payload.state);
                        long ns=SystemClock.elapsedRealtimeNanos()-start;
                        result=pretty(payload.output)
                             +String.format(Locale.US,"[PASS] %.2f ms / RVPC2 guardado\n",ns/1e6);
                        Log.i("ReverseOS","DESKTOP_RUN_OK "+name+" output="+payload.output.length());
                    }
                }catch(Throwable error){
                    result="[ERROR] "+error.getClass().getSimpleName()+": "
                        +error.getMessage()+"\nSin cambios aplicados al estado si XI falló.\n";
                    Log.e(LOG,"Terminal command failed",error);
                }
                final String text=result;
                runOnUiThread(()->{
                    executing=false;
                    putConsole(text+"\n",output,scroll);
                });
            });
        }else putConsole("Comando no reconocido. Escribe help.\n\n",output,scroll);
    }

    private void openFiles(){
        WindowUi w=window("FILES","Aplicaciones XI instaladas");
        TextView count=label("Leyendo biblioteca privada...",12,MUTED,false);
        w.content.addView(count);
        ScrollView scroll=new ScrollView(this);
        LinearLayout list=vertical();
        scroll.addView(list);
        w.content.addView(scroll,new LinearLayout.LayoutParams(-1,0,1f));
        engine.execute(()->{
            try{
                if(store==null)throw new IOException("Núcleo no disponible: "+engineFailure);
                List<String> paths=store.listPrograms();
                runOnUiThread(()->{
                    if(!w.dialog.isShowing())return;
                    count.setText(paths.size()+" programas .xi • memoria privada");
                    list.removeAllViews();
                    for(String path:paths){
                        LinearLayout file=horizontal();
                        file.setPadding(dp(12),dp(13),dp(12),dp(13));
                        file.setBackground(round(CARD,0xff263f50,13));
                        TextView icon=label("▤",25,AMBER,true);
                        file.addView(icon);
                        LinearLayout name=vertical();name.setPadding(dp(11),0,0,0);
                        name.addView(label(path,13,WHITE,true));
                        name.addView(label(store.programBytes(path)+" bytes • script XI",10,MUTED,false));
                        file.addView(name,new LinearLayout.LayoutParams(0,-2,1f));
                        TextView open=touch("ABRIR",11,false,()->{
                            w.dialog.dismiss();openStudio(0,path);
                        });
                        file.addView(open);
                        margin(list,file,9);
                    }
                });
            }catch(Throwable err){
                runOnUiThread(()->{
                    count.setText("Error de archivos");
                    appError(list,String.valueOf(err.getMessage()));
                });
            }
        });
        TextView create=touch("+ CREAR NUEVO PROGRAMA",12,true,()->{
            w.dialog.dismiss();openStudio(2,null);
        });
        margin(w.content,create,13);
    }

    private void openMonitor(){
        WindowUi w=window("ETHER CORE","Autoridad compartida XI / Inverse Memory");
        TextView state=label("Leyendo núcleo nativo...",12,MUTED,false);
        state.setTypeface(Typeface.MONOSPACE);
        state.setPadding(dp(13),dp(15),dp(13),dp(15));
        state.setBackground(round(0xff07131e,0xff223f51,15));
        ScrollView scroll=new ScrollView(this);
        scroll.addView(state);
        w.content.addView(scroll,new LinearLayout.LayoutParams(-1,0,1f));
        TextView refresh=touch("↻ ACTUALIZAR ESTADO",12,true,()->loadStats(state));
        margin(w.content,refresh,12);
        loadStats(state);
    }
    private void loadStats(TextView target){
        engine.execute(()->{
            try {
                if(store==null)throw new IllegalStateException("Núcleo no disponible: "+engineFailure);
                JSONObject j=new JSONObject(NativeRuntime.inspect(store.loadState()));
                String info="CORE ONLINE\n"
                    +"────────────────────────\n\n"
                    +"Estado: "+j.optString("state_format")+"\n"
                    +"Qubits activos: "+j.optInt("active_qubits")+"\n"
                    +"Componentes: "+j.optInt("components")+"\n"
                    +"Mayor componente: "+j.optInt("largest_component")+"\n"
                    +"Reglas Ether: "+j.optInt("ether_rules")+"\n"
                    +"Memoria tableau: "+j.optInt("tableau_bytes")+" bytes\n"
                    +"Revisión de núcleo: "+j.optInt("core_revision")+"\n"
                    +"Revisión de memoria: "+j.optInt("memory_revision")+"\n"
                    +"Excepciones: "+j.optInt("memory_overrides")+"\n"
                    +"Enlaces cuánticos: "+j.optInt("quantum_bindings")+"\n\n"
                    +"Este es el núcleo real de REVERSE-PC.\n"
                    +"No son estadísticas simuladas de la interfaz.";
                runOnUiThread(()->target.setText(info));
            }catch(Throwable err){
                runOnUiThread(()->{
                    target.setTextColor(0xffff9c9c);
                    target.setText("Núcleo no disponible.\n\n"+err);
                });
            }
        });
    }

    private void openBrowser(){
        WindowUi w=window("CHROMIUM","Android WebView • motor del sistema anfitrión");
        LinearLayout address=horizontal();
        TextView back=touch("‹",20,false,()->{});
        TextView forward=touch("›",20,false,()->{});
        TextView refresh=touch("↻",17,false,()->{});
        EditText field=new EditText(this);
        field.setTextColor(WHITE);field.setTextSize(12);field.setHintTextColor(MUTED);
        field.setSingleLine(true);field.setHint("https://www.chromium.org");
        field.setInputType(InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_VARIATION_URI);
        field.setBackground(round(CARD_BRIGHT,0xff34506a,12));
        field.setPadding(dp(11),dp(9),dp(11),dp(9));

        try{
            WebView web=new WebView(this);
            web.setBackgroundColor(Color.WHITE);
            WebSettings settings=web.getSettings();
            settings.setJavaScriptEnabled(true);
            settings.setDomStorageEnabled(true);
            settings.setAllowFileAccess(false);
            settings.setAllowContentAccess(false);
            settings.setJavaScriptCanOpenWindowsAutomatically(false);
            settings.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
            settings.setBuiltInZoomControls(true);
            settings.setDisplayZoomControls(false);
            settings.setSafeBrowsingEnabled(true);
            web.setWebViewClient(new WebViewClient(){
                @Override public boolean shouldOverrideUrlLoading(WebView w,WebResourceRequest request){
                    String scheme=request.getUrl().getScheme();
                    return !"http".equalsIgnoreCase(scheme)&&!"https".equalsIgnoreCase(scheme);
                }
                @Override public void onPageFinished(WebView w,String url){
                    // Address bar remains editable; no hidden navigation or state changes.
                }
            });
            // Window content is a real Android WebView: Chromium-based but NOT an
            // independently emulated Chromium binary executing on XI.
            back.setOnClickListener(v->{if(web.canGoBack())web.goBack();});
            forward.setOnClickListener(v->{if(web.canGoForward())web.goForward();});
            refresh.setOnClickListener(v->web.reload());
            address.addView(back,new LinearLayout.LayoutParams(dp(36),dp(44)));
            address.addView(forward,new LinearLayout.LayoutParams(dp(36),dp(44)));
            address.addView(refresh,new LinearLayout.LayoutParams(dp(39),dp(44)));
            LinearLayout.LayoutParams editParams=new LinearLayout.LayoutParams(0,dp(44),1f);
            editParams.leftMargin=dp(7);
            address.addView(field,editParams);
            TextView go=touch("GO",12,true,()->navigate(web,field.getText().toString(),field));
            LinearLayout.LayoutParams goParams=new LinearLayout.LayoutParams(dp(51),dp(44));
            goParams.leftMargin=dp(6);
            address.addView(go,goParams);
            w.content.addView(address);
            TextView note=label("Sitios web por Android WebView. No se ejecuta Chromium como huésped XI.",
                                10,MUTED,false);
            margin(w.content,note,8);
            LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,0,1f);
            p.topMargin=dp(11);
            w.content.addView(web,p);

            TextView chrome=touch("ABRIR EN CHROME INSTALADO",11,false,()->openChrome());
            margin(w.content,chrome,9);
            w.dialog.setOnDismissListener(x->{
                web.stopLoading();
                web.destroy();
            });
            field.setText("https://www.chromium.org");
            web.loadUrl("https://www.chromium.org");
        }catch(Throwable error){
            Log.e(LOG,"Browser could not start",error);
            appError(w.content,"No se pudo iniciar el motor WebView de Android.\n"+error.getMessage());
            TextView chrome=touch("ABRIR CHROME INSTALADO",12,true,this::openChrome);
            margin(w.content,chrome,12);
        }
    }
    private void navigate(WebView web,String userInput,EditText field){
        String trimmed=userInput.trim();
        if(trimmed.isEmpty())return;
        String url;
        if(trimmed.startsWith("https://")||trimmed.startsWith("http://"))url=trimmed;
        else if(trimmed.contains(" ")||!trimmed.contains(".")){
            try {
                url="https://www.google.com/search?q="+
                    java.net.URLEncoder.encode(trimmed,"UTF-8");
            }catch(java.io.UnsupportedEncodingException e){url="https://www.google.com";}
        }else url="https://"+trimmed;
        if(!url.startsWith("https://")&&!url.startsWith("http://")){
            info("Solo se admiten HTTP y HTTPS.");return;
        }
        field.setText(url);
        web.loadUrl(url);
    }
    private void openChrome(){
        try{
            Intent intent=new Intent(Intent.ACTION_VIEW,Uri.parse("https://www.chromium.org"));
            intent.setPackage("com.android.chrome");
            startActivity(intent);
        }catch(ActivityNotFoundException e){
            info("Chrome no está instalado. Puedes utilizar el navegador WebView.");
        }catch(Exception e){info("No se pudo abrir Chrome: "+e.getMessage());}
    }
    private void openSettings(){
        WindowUi w=window("SETTINGS","REVERSE OS 0.2 • configuración");
        LinearLayout panel=vertical();
        panel.setPadding(dp(16),dp(16),dp(16),dp(16));
        panel.setBackground(round(CARD,0xff29485a,16));
        panel.addView(label("REVERSE OS  /  PERSONAL COMPUTER",16,WHITE,true));
        margin(panel,label("Bienvenido, Mr Reverse.",13,ACCENT,false),9);
        margin(panel,label("Arquitectura XI y Ether con estado RVPC2.\n"
                +"Android proporciona interfaz, procesos, teclado y controladores.\n\n"
                +"La computadora huésped XI aún no arranca como un sistema operativo independiente.",
                12,MUTED,false),11);
        w.content.addView(panel);
        TextView restart=touch("REINICIAR LA PANTALLA DE BIENVENIDA",12,false,()->{
            w.dialog.dismiss();
            Intent i=new Intent(this,BootActivity.class);
            i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(i);finish();
        });
        margin(w.content,restart,20);
        TextView reset=touch("RESTABLECER NÚCLEO ETHER",12,false,()->{
            new AlertDialog.Builder(this)
                .setTitle("Reiniciar el estado de la computadora")
                .setMessage("Se perderá el estado actual RVPC2. Tus programas XI seguirán guardados.")
                .setNegativeButton("CANCELAR",null)
                .setPositiveButton("RESTABLECER",(d,x)->{
                    engine.execute(()->{
                        try{
                            if(store==null)throw new IOException("Núcleo no disponible");
                            store.reset();
                            runOnUiThread(()->info("Estado RVPC2 restablecido"));
                        }catch(Throwable ex){
                            runOnUiThread(()->info("Error: "+ex.getMessage()));
                        }
                    });
                }).show();
        });
        margin(w.content,reset,11);
        TextView close=touch("CERRAR",12,true,w.dialog::dismiss);
        margin(w.content,close,16);
    }
    private void openPower(){
        new AlertDialog.Builder(this).setTitle("REVERSE OS")
            .setItems(new String[]{"Reiniciar escritorio","Configuración","Cerrar REVERSE OS"},(d,which)->{
                if(which==0){
                    Intent i=new Intent(this,BootActivity.class);
                    i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_NEW_TASK);
                    startActivity(i);finish();
                }else if(which==1)openSettings();
                else finish();
            }).show();
    }
    @Override public void onBackPressed(){
        new AlertDialog.Builder(this).setTitle("REVERSE OS")
            .setMessage("¿Cerrar el escritorio?")
            .setNegativeButton("CANCELAR",null)
            .setPositiveButton("CERRAR",(d,which)->finish()).show();
    }
    @Override protected void onDestroy(){
        clockHandler.removeCallbacks(tick);
        engine.shutdown();
        super.onDestroy();
    }

    private final class DesktopBackdrop extends View {
        private final Paint paint=new Paint(Paint.ANTI_ALIAS_FLAG);
        DesktopBackdrop(){super(DesktopActivity.this);}
        @Override protected void onDraw(Canvas canvas){
            float w=getWidth(),h=getHeight();
            paint.setShader(new LinearGradient(0,0,w,h,
                new int[]{0xff060b11,0xff132536,0xff09111b},null,Shader.TileMode.CLAMP));
            canvas.drawRect(0,0,w,h,paint);
            paint.setShader(new RadialGradient(w*0.82f,h*0.35f,w*0.95f,
                new int[]{0x4334a5bd,0x122e84a0,0x0007080c},null,Shader.TileMode.CLAMP));
            canvas.drawRect(0,0,w,h,paint);
            paint.setShader(null);
            paint.setStyle(Paint.Style.STROKE);
            paint.setStrokeWidth(dp(0.6f));
            paint.setColor(0x1022cfb9);
            for(int x=0;x<w;x+=dp(32))canvas.drawLine(x,0,x,h,paint);
            for(int y=0;y<h;y+=dp(32))canvas.drawLine(0,y,w,y,paint);
            paint.setColor(0x205fead2);
            paint.setStrokeWidth(dp(1.5f));
            canvas.drawCircle(w*0.86f,h*0.39f,dp(145),paint);
            canvas.drawCircle(w*0.86f,h*0.39f,dp(179),paint);
            paint.setStyle(Paint.Style.FILL);
            paint.setTypeface(Typeface.create("sans-serif-black",Typeface.BOLD));
            paint.setTextSize(dp(290));
            paint.setColor(0x0cffffff);
            canvas.drawText("R",w*0.39f,h*0.66f,paint);
        }
    }
}
