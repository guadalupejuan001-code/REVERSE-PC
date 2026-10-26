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
    private static final int BG=0xff131922, CARD=0xff222b36, CARD_BRIGHT=0xff303c47;
    private static final int WHITE=0xfff5f3ef, MUTED=0xffbdc3c8, ACCENT=0xffaec3d2;
    private static final int BLUE=0xffb4c6d4, VIOLET=0xffcbb9cb, AMBER=0xffdec4a6;
    private final ExecutorService engine=Executors.newSingleThreadExecutor();
    private final Handler clockHandler=new Handler(Looper.getMainLooper());
    private SessionStore store;
    private OrbitalWallpaper wallpaper;
    private TextView fpsLabel, minimizedLabel;
    private Dialog minimizedWindow;
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
        t.setBackground(round(primary?ACCENT:CARD_BRIGHT,primary?0:0xff45535f,9));
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
                    statusLabel.setText("● Listo");
                    statusLabel.setTextColor(ACCENT);
                    statusDetail.setText("XI y Ether disponibles");
                });
            }catch(Throwable fault){
                engineFailure=fault.getClass().getSimpleName()+": "+fault.getMessage();
                Log.e(LOG,"ENGINE_BOOT_FAILED",fault);
                runOnUiThread(()->{
                    if(isFinishing()||isDestroyed())return;
                    statusLabel.setText("● Error del núcleo");
                    statusLabel.setTextColor(0xffff9898);
                    statusDetail.setText("Toca CORE ERROR para ver el diagnóstico.");
                });
            }
        });
    }

    // REVERSE OS: Windows/macOS-inspired desktop. The orbital shader is a
    // wallpaper only: menus, windows, data and apps retain conventional roles.
    private void buildDesktop(){
        FrameLayout root=new FrameLayout(this);
        root.setBackgroundColor(BG);
        root.addView(new DesktopBackdrop(),new FrameLayout.LayoutParams(-1,-1));

        try {
            wallpaper=new OrbitalWallpaper(this,new OrbitalWallpaper.Events(){
                @Override public void onFps(int frames,float scale){
                    if(fpsLabel!=null)fpsLabel.setText(frames+" fps");
                }
                @Override public void onFailure(String error){
                    Log.e(LOG,"GPU fallback: "+error);
                    if(wallpaper!=null)wallpaper.setVisibility(View.GONE);
                    if(fpsLabel!=null)fpsLabel.setText("Fondo simple");
                }
            });
            root.addView(wallpaper,new FrameLayout.LayoutParams(-1,-1));
        } catch(Throwable error) {
            Log.e(LOG,"OpenGL wallpaper unavailable; retaining CPU fallback",error);
            wallpaper=null;
        }

        LinearLayout system=vertical();
        system.setPadding(dp(12),dp(3),dp(12),dp(0));
        root.addView(system,new FrameLayout.LayoutParams(-1,-1));
        root.setOnApplyWindowInsetsListener((view,insets)->{
            int nav=android.os.Build.VERSION.SDK_INT>=30
                ? insets.getInsets(android.view.WindowInsets.Type.navigationBars()).bottom
                : insets.getSystemWindowInsetBottom();
            system.setPadding(dp(12),dp(3),dp(12),nav+dp(5));
            return insets;
        });

        // Tiny unobtrusive top status bar. The OS looks like a desktop rather
        // than a mobile app with tab bars and cards.
        LinearLayout top=horizontal();
        TextView mark=label("REVERSE",16,WHITE,true);
        mark.setLetterSpacing(.07f);

        top.addView(mark,new LinearLayout.LayoutParams(0,-2,1f));

        statusLabel=label("● Iniciando",10,AMBER,true);
        statusLabel.setOnClickListener(v->{
            if(!engineFailure.isEmpty())
                new AlertDialog.Builder(this).setTitle("REVERSE-PC")
                    .setMessage(engineFailure).setPositiveButton("CERRAR",null).show();
            else openMonitor();
        });
        top.addView(statusLabel);
        statusDetail=label("  XI / Ether",10,MUTED,false);
        top.addView(statusDetail);
        LinearLayout.LayoutParams topP=new LinearLayout.LayoutParams(-1,dp(32));
        system.addView(top,topP);

        FrameLayout workspace=new FrameLayout(this);
        system.addView(workspace,new LinearLayout.LayoutParams(-1,0,1f));

        // The primary cosmic orb remains visible. Icons stay aligned to
        // traditional desktop columns on the left, not a "quantum menu".
        LinearLayout shortcutGrid=vertical();
        shortcutGrid.setPadding(dp(3),dp(12),dp(3),dp(2));
        LinearLayout row1=horizontal();
        addDesktopShortcut(row1,"⌘","XI Studio",this::showStudio);
        addDesktopShortcut(row1,">_","Terminal",this::openTerminal);
        shortcutGrid.addView(row1);
        LinearLayout row2=horizontal();
        addDesktopShortcut(row2,"▤","ARCHIVOS",this::openFiles);
        addDesktopShortcut(row2,"◎","Navegador",this::openBrowser);
        shortcutGrid.addView(row2);
        LinearLayout row3=horizontal();
        addDesktopShortcut(row3,"◈","Ether Core",this::openMonitor);
        addDesktopShortcut(row3,"⚙","Ajustes",this::openSettings);
        shortcutGrid.addView(row3);
        FrameLayout.LayoutParams gridP=new FrameLayout.LayoutParams(dp(235),-2,
                                                                  Gravity.TOP|Gravity.LEFT);
        workspace.addView(shortcutGrid,gridP);

        LinearLayout identity=vertical();
        identity.setGravity(Gravity.CENTER);
        TextView title=label("REVERSE",29,WHITE,true);
        title.setGravity(Gravity.CENTER);
        title.setLetterSpacing(.10f);

        identity.addView(title);
        TextView caption=label("Tu espacio de trabajo",12,MUTED,false);
        caption.setGravity(Gravity.CENTER);
        margin(identity,caption,7);
        FrameLayout.LayoutParams idP=new FrameLayout.LayoutParams(dp(320),dp(92),
                                                              Gravity.CENTER);
        idP.leftMargin=dp(115);
        workspace.addView(identity,idP);

        system.addView(buildTaskbar(),new LinearLayout.LayoutParams(-1,dp(56)));
        setContentView(root);
        Log.i(LOG,"DESKTOP_SHOWN REVERSE OS MR REVERSE landscape");
    }

    private void showStudio(){openStudio(0,null);}

    private void addDesktopShortcut(LinearLayout row,String glyph,String text,
                                    Runnable callback) {
        LinearLayout icon=vertical();
        icon.setGravity(Gravity.CENTER);
        icon.setPadding(dp(4),dp(6),dp(4),dp(6));
        icon.setBackground(round(0xff1e2935,0,10));
        icon.setClickable(true);
        icon.setFocusable(true);
        icon.setOnClickListener(v->callback.run());
        TextView sign=label(glyph,22,ACCENT,true);
        sign.setGravity(Gravity.CENTER);

        icon.addView(sign);
        TextView name=label(text,11,WHITE,true);
        name.setGravity(Gravity.CENTER);
        name.setSingleLine(true);
        name.setEllipsize(android.text.TextUtils.TruncateAt.END);
        margin(icon,name,3);
        LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(dp(111),dp(72));
        p.setMargins(dp(1),dp(2),dp(1),dp(2));
        row.addView(icon,p);
    }

    private LinearLayout buildTaskbar(){
        LinearLayout taskbar=horizontal();
        taskbar.setGravity(Gravity.CENTER_VERTICAL);
        taskbar.setPadding(dp(8),dp(4),dp(8),dp(4));
        taskbar.setBackground(round(0xff1c2631,0xff364651,8));
        addTaskButton(taskbar,"▦","INICIO",this::openStartMenu);
        addTaskButton(taskbar,"⌕","BUSCAR",this::openSearch);
        addTaskButton(taskbar,"▤","ARCHIVOS",this::openFiles);
        addTaskButton(taskbar,">_","TERM",this::openTerminal);

        LinearLayout center=horizontal();
        center.setGravity(Gravity.CENTER);
        TextView orb=label("R",21,WHITE,true);
        orb.setGravity(Gravity.CENTER);

        orb.setBackground(round(0xff344656,0xff728394,22));
        orb.setContentDescription("ABRIR REVERSE HOME");
        orb.setOnClickListener(v->openHome());
        center.addView(orb,new LinearLayout.LayoutParams(dp(48),dp(46)));
        taskbar.addView(center,new LinearLayout.LayoutParams(0,-1,1f));

        minimizedLabel=label("▣ Ventana",11,ACCENT,true);
        minimizedLabel.setPadding(dp(10),dp(6),dp(10),dp(6));
        minimizedLabel.setVisibility(minimizedWindow==null?View.GONE:View.VISIBLE);
        minimizedLabel.setOnClickListener(v->{
            if(minimizedWindow!=null){
                minimizedWindow.show();
                minimizedWindow=null;
                minimizedLabel.setVisibility(View.GONE);
            }
        });
        taskbar.addView(minimizedLabel);
        fpsLabel=label("Gráficos",10,MUTED,false);
        taskbar.addView(fpsLabel);
        TextView systemIcons=label("    ◉   ◖))  ",12,0xffb8b7e9,false);
        taskbar.addView(systemIcons);
        clockLabel=label("",13,WHITE,true);
        taskbar.addView(clockLabel);
        return taskbar;
    }

    private void addTaskButton(LinearLayout taskbar,String symbol,String title,
                               Runnable callback) {
        LinearLayout item=vertical();
        item.setGravity(Gravity.CENTER);
        TextView glyph=label(symbol,20,ACCENT,true);
        glyph.setGravity(Gravity.CENTER);
        item.addView(glyph);
        TextView sub=label(title,9,WHITE,false);
        sub.setGravity(Gravity.CENTER);
        item.addView(sub);
        item.setOnClickListener(v->callback.run());
        item.setContentDescription(title);
        taskbar.addView(item,new LinearLayout.LayoutParams(dp(65),-1));
    }

    private void openHome(){
        WindowUi w=window("HOME","REVERSE / PERSONAL COMPUTER");
        LinearLayout header=vertical();
        header.setGravity(Gravity.CENTER);
        TextView headline=label("Bienvenido a REVERSE",22,WHITE,true);
        headline.setLetterSpacing(.01f);
        headline.setGravity(Gravity.CENTER);

        header.addView(headline);
        TextView welcome=label("Tus archivos, programas y herramientas.",12,MUTED,false);
        welcome.setGravity(Gravity.CENTER);
        margin(header,welcome,7);
        w.content.addView(header,new LinearLayout.LayoutParams(-1,0,1f));
        LinearLayout buttons=horizontal();
        buttons.addView(touch("Terminal",12,false,()->{
            w.dialog.dismiss();openTerminal();
        }),new LinearLayout.LayoutParams(0,dp(43),1f));
        TextView studio=touch("XI Studio",12,true,()->{
            w.dialog.dismiss();openStudio(0,null);
        });
        LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(0,dp(43),1f);
        p.leftMargin=dp(9);
        buttons.addView(studio,p);
        w.content.addView(buttons);
    }

    private void openStartMenu(){
        WindowUi w=window("Inicio","Aplicaciones REVERSE OS");
        LinearLayout grid=vertical();
        String[][] shortcuts={{"XI Studio","⌘"},{"Terminal",">_"},{"Archivos","▤"},
                              {"Navegador","◎"},{"Ether Core","◈"},{"Ajustes","⚙"}};
        Runnable[] actions={()->openStudio(0,null),this::openTerminal,this::openFiles,
                            this::openBrowser,this::openMonitor,this::openSettings};
        for(int index=0;index<shortcuts.length;index++){
            final int n=index;
            TextView t=touch(shortcuts[index][1]+"   "+shortcuts[index][0],12,false,()->{
                w.dialog.dismiss();actions[n].run();
            });
            margin(grid,t,7);
        }
        ScrollView scroll=new ScrollView(this);
        scroll.addView(grid);
        w.content.addView(scroll,new LinearLayout.LayoutParams(-1,0,1f));
    }

    private void openSearch(){
        WindowUi w=window("Buscar","Buscar aplicaciones");
        EditText field=new EditText(this);
        field.setTextColor(WHITE);field.setHintTextColor(MUTED);
        field.setSingleLine(true);
        field.setHint("XI, Files, Terminal, Chromium, Core, Settings...");
        field.setBackground(round(CARD_BRIGHT,0xff536b79,9));
        field.setPadding(dp(12),dp(11),dp(12),dp(11));
        w.content.addView(field);
        TextView result=label("Escribe un nombre y pulsa BUSCAR.",12,MUTED,false);
        margin(w.content,result,14);
        TextView go=touch("BUSCAR",12,true,()->{
            final String q=field.getText().toString().trim().toLowerCase(Locale.ROOT);
            Runnable action=null;
            if(q.contains("xi")||q.contains("studio")||q.contains("program")) action=()->openStudio(0,null);
            else if(q.contains("term")||q.contains("console")) action=this::openTerminal;
            else if(q.contains("file")||q.contains("archivo")) action=this::openFiles;
            else if(q.contains("chrome")||q.contains("web")||q.contains("naveg")) action=this::openBrowser;
            else if(q.contains("ether")||q.contains("core")||q.contains("quant")) action=this::openMonitor;
            else if(q.contains("setting")||q.contains("config")) action=this::openSettings;
            if(action==null){result.setText("No hay ninguna aplicación coincidente.");return;}
            w.dialog.dismiss();action.run();
        });
        margin(w.content,go,10);
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
        dock.setBackground(round(0xee122334,0xff53616d,23));
        addDock(dock,"⌂","HOME",ACCENT,()->{});
        addDock(dock,"⌘","XI",WHITE,()->openStudio(0,null));
        addDock(dock,">_","TERM",WHITE,this::openTerminal);
        addDock(dock,"▤","ARCHIVOS",WHITE,this::openFiles);
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
        WindowUi(Dialog dialog,LinearLayout content){
            this.dialog=dialog;this.content=content;
        }
    }

    // Floating window. The top bar can drag, minimize, maximize and close
    // without leaving REVERSE OS; navigation is a real sidebar.
    private WindowUi window(String title,String subtitle){
        if(minimizedWindow!=null){
            minimizedWindow.dismiss();
            minimizedWindow=null;
            if(minimizedLabel!=null)minimizedLabel.setVisibility(View.GONE);
        }
        Dialog dialog=new Dialog(this);
        LinearLayout shell=vertical();
        shell.setBackground(round(0xff232c36,0xff45545f,12));
        shell.setPadding(dp(1),dp(1),dp(1),dp(1));

        LinearLayout top=horizontal();
        top.setBackground(round(0xff26313b,0,11));
        top.setPadding(dp(11),dp(7),dp(11),dp(7));
        TextView dot=label("●",12,0xffcfb8ab,true);
        top.addView(dot);
        LinearLayout name=vertical();name.setPadding(dp(12),0,0,0);
        name.addView(label(title,15,WHITE,true));
        name.addView(label(subtitle,10,MUTED,false));
        top.addView(name,new LinearLayout.LayoutParams(0,-2,1f));

        TextView minimize=label("—",19,MUTED,false);
        minimize.setGravity(Gravity.CENTER);
        minimize.setContentDescription("MINIMIZAR "+title);
        top.addView(minimize,new LinearLayout.LayoutParams(dp(38),dp(32)));
        minimize.setOnClickListener(v->{
            minimizedWindow=dialog;
            if(minimizedLabel!=null){
                minimizedLabel.setText("▣ "+title);
                minimizedLabel.setVisibility(View.VISIBLE);
            }
            dialog.hide();
        });
        TextView maximize=label("□",22,WHITE,false);
        maximize.setGravity(Gravity.CENTER);
        maximize.setContentDescription("MAXIMIZAR "+title);
        top.addView(maximize,new LinearLayout.LayoutParams(dp(38),dp(32)));
        maximize.setOnClickListener(v->{
            Window actual=dialog.getWindow();
            if(actual==null)return;
            WindowManager.LayoutParams p=actual.getAttributes();
            int width=getResources().getDisplayMetrics().widthPixels;
            int height=getResources().getDisplayMetrics().heightPixels;
            boolean enlarged=p.width>(int)(width*.88f);
            p.width=(int)(width*(enlarged?.78f:.96f));
            p.height=(int)(height*(enlarged?.78f:.91f));
            p.gravity=Gravity.CENTER;
            actual.setAttributes(p);
        });
        TextView close=label("×",25,WHITE,false);
        close.setGravity(Gravity.CENTER);
        close.setContentDescription("CERRAR "+title);
        close.setBackground(round(0xff384451,0,7));
        top.addView(close,new LinearLayout.LayoutParams(dp(38),dp(34)));
        close.setOnClickListener(v->dialog.dismiss());
        shell.addView(top,new LinearLayout.LayoutParams(-1,dp(51)));

        View line=new View(this);line.setBackgroundColor(0xff48535d);
        shell.addView(line,new LinearLayout.LayoutParams(-1,dp(1)));

        LinearLayout interior=horizontal();
        interior.setGravity(Gravity.TOP);
        LinearLayout sidebar=vertical();
        sidebar.setPadding(dp(8),dp(12),dp(8),dp(8));
        sidebar.setBackgroundColor(0xff1d2731);
        String[] names={"⌂  Inicio","▤  Archivos","⚙  Ajustes",">_  Terminal","ⓘ  Acerca de"};
        Runnable[] go={this::openHome,this::openFiles,this::openSettings,
                       this::openTerminal,this::openAbout};
        for(int index=0;index<names.length;index++){
            final int pos=index;
            TextView entry=label(names[index],11,pos==0?ACCENT:WHITE,false);
            entry.setPadding(dp(10),dp(12),dp(6),dp(12));
            if((title.equalsIgnoreCase("HOME")&&pos==0)||
               (title.equalsIgnoreCase("Archivos")&&pos==1)||
               (title.equalsIgnoreCase("Ajustes")&&pos==2)||
               (title.equalsIgnoreCase("Terminal")&&pos==3)){
                entry.setTextColor(ACCENT);
                entry.setBackground(round(0xff344451,0,7));
            }
            margin(sidebar,entry,pos==0?0:3);
            entry.setOnClickListener(v->{dialog.dismiss();go[pos].run();});
        }
        interior.addView(sidebar,new LinearLayout.LayoutParams(dp(143),-1));
        View verticalRule=new View(this);verticalRule.setBackgroundColor(0xff46515d);
        interior.addView(verticalRule,new LinearLayout.LayoutParams(dp(1),-1));
        LinearLayout body=vertical();
        body.setPadding(dp(13),dp(10),dp(13),dp(10));
        interior.addView(body,new LinearLayout.LayoutParams(0,-1,1f));
        shell.addView(interior,new LinearLayout.LayoutParams(-1,0,1f));

        dialog.setContentView(shell);
        dialog.show();
        Window actual=dialog.getWindow();
        if(actual!=null){
            actual.setBackgroundDrawableResource(android.R.color.transparent);
            actual.addFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND);
            WindowManager.LayoutParams p=actual.getAttributes();
            p.width=(int)(getResources().getDisplayMetrics().widthPixels*.78f);
            p.height=(int)(getResources().getDisplayMetrics().heightPixels*.78f);
            p.dimAmount=.25f;
            p.gravity=Gravity.CENTER;
            actual.setAttributes(p);
            actual.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);

            final float[] touchStart={0f,0f};
            final int[] origin={0,0};
            top.setOnTouchListener((view,event)->{
                switch(event.getActionMasked()){
                    case android.view.MotionEvent.ACTION_DOWN:
                        touchStart[0]=event.getRawX();
                        touchStart[1]=event.getRawY();
                        actual.getDecorView().getLocationOnScreen(origin);
                        return true;
                    case android.view.MotionEvent.ACTION_MOVE:
                        WindowManager.LayoutParams moving=actual.getAttributes();
                        int maxX=getResources().getDisplayMetrics().widthPixels-dp(180);
                        int maxY=getResources().getDisplayMetrics().heightPixels-dp(60);
                        moving.gravity=Gravity.TOP|Gravity.LEFT;
                        moving.x=Math.max(-dp(30),Math.min(maxX,origin[0]+
                                      Math.round(event.getRawX()-touchStart[0])));
                        moving.y=Math.max(0,Math.min(maxY,origin[1]+
                                      Math.round(event.getRawY()-touchStart[1])));
                        actual.setAttributes(moving);
                        return true;
                    case android.view.MotionEvent.ACTION_UP:return true;
                    default:return false;
                }
            });
        }
        return new WindowUi(dialog,body);
    }

    private void openAbout(){
        WindowUi w=window("ABOUT","Acerca de REVERSE OS");
        TextView text=label("REVERSE OS 0.4\n\n"+
            "Escritorio horizontal con ventanas funcionales, GPU GLES 3 "+
            "de REVERSE Space Glitch y la computadora XI/Ether.\n\n"+
            "El fondo orbital representa cálculos gráficos en tiempo real; "+
            "no es prueba de aceleración cuántica.\n\n"+
            "Android sigue siendo el sistema operativo anfitrión; "+
            "XI ejecuta programas y conserva estados RVPC2. "+
            "Chromium utiliza Android WebView.",13,WHITE,false);
        margin(w.content,text,9);
        TextView button=touch("ABRIR ETHER CORE",12,true,()->{
            w.dialog.dismiss();openMonitor();
        });
        margin(w.content,button,17);
    }

    private void appError(LinearLayout parent,String message){
        TextView t=label(message,13,0xffffa5a5,false);
        t.setPadding(dp(12),dp(15),dp(12),dp(15));
        parent.addView(t);
    }
    // A real program editor inside a floating window; JNI remains the one
    // authority for execution. A failed program never replaces RVPC2.
    private void openStudio(int tab,String file){
        final String chosen;
        if(tab==2)chosen="nuevo_"+(System.currentTimeMillis()%100000)+".xi";
        else chosen=file==null?"01_euclides.xi":SessionStore.normalized(file);
        WindowUi w=window("XI Studio","Editor de programas de REVERSE-PC");
        TextView filename=label(chosen+"   •  XI SCRIPT",11,ACCENT,true);
        margin(w.content,filename,1);

        EditText editor=new EditText(this);
        editor.setTypeface(Typeface.MONOSPACE);
        editor.setTextColor(WHITE);editor.setHintTextColor(MUTED);
        editor.setTextSize(12);
        editor.setGravity(Gravity.TOP|Gravity.START);
        editor.setSingleLine(false);
        editor.setInputType(InputType.TYPE_CLASS_TEXT|
            InputType.TYPE_TEXT_FLAG_MULTI_LINE|
            InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        editor.setBackground(round(0xff070c19,0xff45406a,10));
        editor.setPadding(dp(12),dp(8),dp(12),dp(8));
        editor.setText(tab==2?"#!reverse-pc-machine-v1\nset r0 1\nprint r0\nhalt\n":
            "#!reverse-pc-machine-v1\n# Cargando...\n");
        LinearLayout.LayoutParams editP=new LinearLayout.LayoutParams(-1,0,1f);
        editP.topMargin=dp(8);
        w.content.addView(editor,editP);

        TextView output=label("Estado: preparando editor...",11,MUTED,false);
        output.setTypeface(Typeface.MONOSPACE);
        output.setMaxLines(3);
        margin(w.content,output,7);
        LinearLayout buttons=horizontal();
        TextView save=touch("GUARDAR",11,false,()->{
            final String data=editor.getText().toString();
            engine.execute(()->{
                try{
                    if(store==null)throw new IllegalStateException("Núcleo no disponible");
                    store.saveProgram(chosen,data);
                    runOnUiThread(()->output.setText("Guardado: "+chosen));
                }catch(Throwable e){
                    runOnUiThread(()->output.setText("Error: "+e.getMessage()));
                }
            });
        });
        buttons.addView(save,new LinearLayout.LayoutParams(0,dp(42),1f));
        TextView run=touch("▶ EJECUTAR",12,true,()->{
            if(executing){info("XI está ejecutando otro programa");return;}
            executing=true;
            final String data=editor.getText().toString();
            output.setText("EJECUTANDO "+chosen+"...");
            engine.execute(()->{
                try{
                    if(store==null)throw new IllegalStateException(
                        "Núcleo XI no disponible: "+engineFailure);
                    store.saveProgram(chosen,data);
                    long t0=SystemClock.elapsedRealtimeNanos();
                    ResultPacket packet=ResultPacket.parse(NativeRuntime.execute(
                        store.loadState(),data));
                    store.writeState(packet.state);
                    long elapsed=SystemClock.elapsedRealtimeNanos()-t0;
                    final String result=pretty(packet.output)+
                        String.format(Locale.US,"RVPC2 guardado  •  %.2f ms",
                                      elapsed/1000000.0);
                    Log.i("ReverseOS","RUN_OK "+chosen+" output="+packet.output.length());
                    runOnUiThread(()->{
                        executing=false;
                        output.setText(result);
                        consoleHistory.append("$ run "+chosen+"\n"+result+"\n");
                    });
                }catch(Throwable error){
                    Log.e(LOG,"XI studio run failed",error);
                    runOnUiThread(()->{
                        executing=false;
                        output.setText("ERROR: "+error.getMessage()+
                            "\nEstado RVPC2 anterior conservado");
                    });
                }
            });
        });
        LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(0,dp(42),1f);
        p.leftMargin=dp(8);
        buttons.addView(run,p);
        TextView open=touch("ABRIR",11,false,()->{
            if(store==null){info("Leyendo programas...");return;}
            List<String> programs=store.listPrograms();
            if(programs.isEmpty()){info("No hay programas");return;}
            new AlertDialog.Builder(this)
                .setTitle("Abrir programa XI")
                .setItems(programs.toArray(new String[0]),(d,pos)->{
                    w.dialog.dismiss();openStudio(0,programs.get(pos));
                }).show();
        });
        LinearLayout.LayoutParams opener=new LinearLayout.LayoutParams(dp(73),dp(42));
        opener.leftMargin=dp(8);
        buttons.addView(open,opener);
        margin(w.content,buttons,6);

        engine.execute(()->{
            if(tab==2)return;
            try{
                if(store==null)throw new IllegalStateException("Núcleo no disponible");
                String code=store.readProgram(chosen);
                runOnUiThread(()->{
                    if(!w.dialog.isShowing())return;
                    editor.setText(code);
                    output.setText("Listo: "+chosen+" · editando programa XI");
                });
            }catch(Throwable error){
                runOnUiThread(()->output.setText("Error: "+error.getMessage()));
            }
        });
    }

    // Terminal executes programs through the exact JNI bridge used by the original GUI.
    private void openTerminal(){
        WindowUi w=window("Terminal","XI SHELL  •  ejecución nativa");
        ScrollView scroll=new ScrollView(this);
        TextView output=label(consoleHistory.toString(),12,0xffdddacb,false);
        output.setTypeface(Typeface.MONOSPACE);
        output.setPadding(dp(12),dp(13),dp(12),dp(13));
        output.setBackground(round(0xff171f29,0xff425160,14));
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
        WindowUi w=window("Archivos","Aplicaciones XI instaladas");
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
        WindowUi w=window("Ether Core","Autoridad compartida XI / Inverse Memory");
        TextView state=label("Leyendo núcleo nativo...",12,MUTED,false);
        state.setTypeface(Typeface.MONOSPACE);
        state.setPadding(dp(13),dp(15),dp(13),dp(15));
        state.setBackground(round(0xff1a2430,0xff475664,15));
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
        WindowUi w=window("Navegador","Android WebView • motor del sistema anfitrión");
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
        WindowUi w=window("Ajustes","REVERSE OS 0.2 • configuración");
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
        TextView quality=label("FONDO ORBITAL — GPU GLES 3",12,ACCENT,true);
        margin(w.content,quality,12);
        LinearLayout qualityControls=horizontal();
        qualityControls.addView(touch("ECO",11,false,()->{
            if(wallpaper!=null)wallpaper.quality(1);
            info("Calidad ECO seleccionada");
        }),new LinearLayout.LayoutParams(0,dp(38),1f));
        TextView automatic=touch("AUTO",11,true,()->{
            if(wallpaper!=null)wallpaper.quality(0);
            info("Calidad adaptativa seleccionada");
        });
        LinearLayout.LayoutParams center=new LinearLayout.LayoutParams(0,dp(38),1f);
        center.leftMargin=dp(7);qualityControls.addView(automatic,center);
        TextView maximum=touch("ALTA",11,false,()->{
            if(wallpaper!=null)wallpaper.quality(2);
            info("Calidad alta; medir FPS en la barra");
        });
        LinearLayout.LayoutParams right=new LinearLayout.LayoutParams(0,dp(38),1f);
        right.leftMargin=dp(7);qualityControls.addView(maximum,right);
        margin(w.content,qualityControls,7);
        LinearLayout motionControls=horizontal();
        motionControls.addView(touch("⏸ PAUSA",11,false,()->{
            if(wallpaper!=null)wallpaper.motionEnabled(false);
            info("Fondo orbital en pausa");
        }),new LinearLayout.LayoutParams(0,dp(38),1f));
        TextView play=touch("▶ MOVIMIENTO",11,true,()->{
            if(wallpaper!=null)wallpaper.motionEnabled(true);
            info("Fondo orbital animado");
        });
        LinearLayout.LayoutParams motionP=new LinearLayout.LayoutParams(0,dp(38),1f);
        motionP.leftMargin=dp(7);motionControls.addView(play,motionP);
        margin(w.content,motionControls,7);
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
    @Override protected void onResume(){
        super.onResume();
        if(wallpaper!=null)wallpaper.onResume();
    }
    @Override protected void onPause(){
        if(wallpaper!=null)wallpaper.onPause();
        super.onPause();
    }
    @Override protected void onDestroy(){
        clockHandler.removeCallbacks(tick);
        if(minimizedWindow!=null){minimizedWindow.dismiss();minimizedWindow=null;}
        engine.shutdown();
        super.onDestroy();
    }

    // Consistent flat-color fallback when the GPU shader is unavailable.
    private final class DesktopBackdrop extends View {
        private final Paint paint=new Paint(Paint.ANTI_ALIAS_FLAG);
        DesktopBackdrop(){super(DesktopActivity.this);}
        @Override protected void onDraw(Canvas canvas){
            float w=getWidth(),h=getHeight();
            canvas.drawColor(0xff131922);
            float cx=w*.60f,cy=h*.50f,scale=Math.min(w,h);
            paint.setStyle(Paint.Style.FILL);
            paint.setColor(0xff1c303d);
            canvas.drawCircle(cx,cy,scale*.25f,paint);
            paint.setStyle(Paint.Style.STROKE);
            paint.setStrokeWidth(dp(1));
            paint.setColor(0xff394d5c);
            canvas.drawOval(cx-scale*.44f,cy-scale*.16f,
                            cx+scale*.44f,cy+scale*.16f,paint);
            paint.setColor(0xff354954);
            canvas.drawCircle(cx,cy,scale*.30f,paint);
            paint.setStyle(Paint.Style.FILL);
            paint.setColor(0xffacbfcd);
            canvas.drawCircle(cx+scale*.42f,cy,dp(3),paint);
        }
    }
}
