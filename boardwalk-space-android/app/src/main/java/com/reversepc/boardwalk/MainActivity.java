package com.reversepc.boardwalk;

import android.app.Activity;
import android.content.ContentValues;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.provider.MediaStore;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * Virtual georeferenced camera, NOT a human, flying vehicle or orbital rocket.
 * Its vertical height changes while lat/lon stay fixed at the Atlantic City shore.
 */
public final class MainActivity extends Activity implements ObserverRenderer.Listener {
    private static final int WHITE=0xfff0f7ff;
    private static final int MUTED=0xffb6c7db;
    private static final int AQUA=0xff8de9ff;
    private static final int UI_BG=0xc50a1527;
    private static final long POV_DURATION_MS=57000L;

    private final Handler main=new Handler(Looper.getMainLooper());
    private GLSurfaceView surface;
    private ObserverRenderer renderer;
    private FrameLayout root;
    private LinearLayout head,controls;
    private TextView altitudeText,horizonText,metricsText,stageText,subHeading;
    private SeekBar altitudeSeek;
    private Button play,reset,quality,shot,hide;
    private boolean playing=false,closed=false,programmatic=false;
    private long startAtMs;
    private float lastX,lastY;
    private boolean dragging=false;
    private float oldHeading=128f,oldPitch=-3.5f;
    private int qualityMode=0;
    private boolean hidden=false;
    private String lastError=null;

    private final Runnable ascent=new Runnable(){
        @Override public void run(){
            if(!playing||closed)return;
            long elapsed=SystemClock.elapsedRealtime()-startAtMs;
            float fraction=Math.max(0f,Math.min(1f,
                (elapsed-3200f)/(POV_DURATION_MS-3200f)));
            programmatic=true;
            altitudeSeek.setProgress(Math.round(fraction*1000));
            programmatic=false;
            renderer.progress=fraction;
            if(!dragging)renderer.pitch=(float)ObserverMath.pitchDeg(fraction);
            telemetry();
            if(fraction>=1f){
                playing=false;
                play.setText("REPETIR POV");
                return;
            }
            main.postDelayed(this,33);
        }
    };

    private int dp(float v){
        return Math.round(v*getResources().getDisplayMetrics().density);
    }
    private GradientDrawable background(int fill,int stroke,int radius){
        GradientDrawable d=new GradientDrawable();
        d.setColor(fill);
        d.setCornerRadius(dp(radius));
        if(stroke!=0)d.setStroke(dp(1),stroke);
        return d;
    }
    private TextView text(String value,int sp,int color,boolean bold){
        TextView t=new TextView(this);
        t.setText(value);t.setTextSize(sp);t.setTextColor(color);
        if(bold)t.setTypeface(Typeface.create("sans-serif-medium",Typeface.BOLD));
        t.setIncludeFontPadding(false);
        return t;
    }
    private Button button(String label){
        Button b=new Button(this);
        b.setText(label);
        b.setAllCaps(false);
        b.setMinHeight(0);b.setMinimumHeight(0);
        b.setMinWidth(0);b.setMinimumWidth(0);
        b.setTextColor(WHITE);b.setTextSize(12);
        b.setPadding(dp(2),0,dp(2),0);
        b.setBackground(background(0xff153250,0xff406887,11));
        return b;
    }
    private void immersive(){
        getWindow().getDecorView().setSystemUiVisibility(
             View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN|
             View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION|
             View.SYSTEM_UI_FLAG_FULLSCREEN|
             View.SYSTEM_UI_FLAG_HIDE_NAVIGATION|
             View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY|
             View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
    }

    @Override public void onCreate(Bundle state){
        super.onCreate(state);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        immersive();
        root=new FrameLayout(this);
        root.setBackgroundColor(Color.BLACK);
        surface=new GLSurfaceView(this);
        surface.setEGLContextClientVersion(3);
        surface.setEGLConfigChooser(8,8,8,8,16,0);
        surface.setPreserveEGLContextOnPause(true);
        renderer=new ObserverRenderer(this,this);
        surface.setRenderer(renderer);
        surface.setRenderMode(GLSurfaceView.RENDERMODE_CONTINUOUSLY);
        surface.setContentDescription("boardwalk-virtual-earth-observer");
        root.addView(surface,new FrameLayout.LayoutParams(-1,-1));
        installGestures();

        head=new LinearLayout(this);
        head.setOrientation(LinearLayout.VERTICAL);
        head.setPadding(dp(12),dp(10),dp(12),dp(12));
        head.setBackground(background(UI_BG,0xff39516b,14));
        FrameLayout.LayoutParams topLP=new FrameLayout.LayoutParams(-1,-2,Gravity.TOP);
        topLP.setMargins(dp(10),dp(13),dp(10),0);
        root.addView(head,topLP);
        LinearLayout titleLine=new LinearLayout(this);
        titleLine.setGravity(Gravity.CENTER_VERTICAL);
        head.addView(titleLine,new LinearLayout.LayoutParams(-1,-2));
        TextView title=text("BOARDWALK  →  ESPACIO",17,WHITE,true);
        titleLine.addView(title,new LinearLayout.LayoutParams(0,-2,1f));
        hide=button("OCULTAR");
        hide.setTextSize(10);
        titleLine.addView(hide,new LinearLayout.LayoutParams(dp(88),dp(36)));
        hide.setContentDescription("boardwalk-hide-controls");
        hide.setOnClickListener(v->toggleHud());
        subHeading=text("ATLANTIC CITY, NJ  •  39.3584° N · 74.4214° W",10,MUTED,false);
        LinearLayout.LayoutParams subLP=new LinearLayout.LayoutParams(-1,-2);
        subLP.topMargin=dp(3);
        head.addView(subHeading,subLP);
        altitudeText=text("6 m",32,AQUA,true);
        LinearLayout.LayoutParams altLP=new LinearLayout.LayoutParams(-1,-2);
        altLP.topMargin=dp(9);
        head.addView(altitudeText,altLP);
        stageText=text("BOARDWALK / STEEL PIER",10,AQUA,true);
        head.addView(stageText,new LinearLayout.LayoutParams(-1,-2));
        horizonText=text("HORIZONTE GEOMÉTRICO   8,7 km",11,WHITE,false);
        LinearLayout.LayoutParams horLP=new LinearLayout.LayoutParams(-1,-2);
        horLP.topMargin=dp(7);
        head.addView(horizonText,horLP);
        metricsText=text("GPU iniciando…",10,MUTED,false);
        LinearLayout.LayoutParams metricLP=new LinearLayout.LayoutParams(-1,-2);
        metricLP.topMargin=dp(4);
        head.addView(metricsText,metricLP);
        TextView interpretation=text(
            "CÁMARA VIRTUAL • CAMBIO DE ALTURA, NO VUELO HUMANO",9,MUTED,true);
        LinearLayout.LayoutParams noteLP=new LinearLayout.LayoutParams(-1,-2);
        noteLP.topMargin=dp(8);
        head.addView(interpretation,noteLP);

        controls=new LinearLayout(this);
        controls.setOrientation(LinearLayout.VERTICAL);
        controls.setPadding(dp(12),dp(12),dp(12),dp(12));
        controls.setBackground(background(0xd6091829,0xff3f6181,16));
        FrameLayout.LayoutParams bottom=new FrameLayout.LayoutParams(-1,-2,Gravity.BOTTOM);
        bottom.setMargins(dp(10),0,dp(10),dp(13));
        root.addView(controls,bottom);
        TextView sliderLabel=text("ALTURA DEL OBSERVADOR · 6 m — 400 km",10,AQUA,true);
        controls.addView(sliderLabel);
        altitudeSeek=new SeekBar(this);
        altitudeSeek.setMax(1000);
        altitudeSeek.setProgress(0);
        altitudeSeek.setProgressTintList(android.content.res.ColorStateList.valueOf(AQUA));
        altitudeSeek.setThumbTintList(android.content.res.ColorStateList.valueOf(AQUA));
        altitudeSeek.setContentDescription("boardwalk-altitude-slider");
        controls.addView(altitudeSeek,new LinearLayout.LayoutParams(-1,dp(39)));
        altitudeSeek.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener(){
            @Override public void onProgressChanged(SeekBar s,int p,boolean user){
                renderer.progress=p/1000f;
                if(user&&!programmatic){stopPov();renderer.pitch=(float)ObserverMath.pitchDeg(renderer.progress);}
                telemetry();
            }
            @Override public void onStartTrackingTouch(SeekBar s){}
            @Override public void onStopTrackingTouch(SeekBar s){}
        });
        LinearLayout firstRow=new LinearLayout(this);
        controls.addView(firstRow,new LinearLayout.LayoutParams(-1,dp(47)));
        play=button("INICIAR POV");
        play.setBackground(background(0xff08758a,0xff71f5ff,11));
        play.setContentDescription("boardwalk-start-pov");
        firstRow.addView(play,new LinearLayout.LayoutParams(0,-1,1.4f));
        reset=button("SUELO");
        LinearLayout.LayoutParams rp=new LinearLayout.LayoutParams(0,-1,.7f);
        rp.leftMargin=dp(5);
        firstRow.addView(reset,rp);
        quality=button("AUTO");
        LinearLayout.LayoutParams qp=new LinearLayout.LayoutParams(0,-1,.75f);
        qp.leftMargin=dp(5);
        firstRow.addView(quality,qp);
        shot=button("FOTO");
        LinearLayout.LayoutParams pp=new LinearLayout.LayoutParams(0,-1,.75f);
        pp.leftMargin=dp(5);
        firstRow.addView(shot,pp);
        play.setOnClickListener(v->{
            if(playing)stopPov();
            else startPov();
        });
        reset.setOnClickListener(v->{
            stopPov();
            renderer.heading=128;
            renderer.pitch=-3.5f;
            altitudeSeek.setProgress(0);
            telemetry();
        });
        quality.setOnClickListener(v->{
            qualityMode=(qualityMode+1)%3;
            renderer.quality=qualityMode;
            quality.setText(qualityMode==0?"AUTO":qualityMode==1?"ECO":"ULTRA");
        });
        shot.setOnClickListener(v->{
            renderer.photoRequested=true;
            shot.setEnabled(false);
            shot.setText("…");
        });
        TextView instructions=text("ARRASTRAR: MIRAR  •  GRABAR: USA EL GRABADOR DE PANTALLA DEL TELÉFONO",9,MUTED,false);
        instructions.setGravity(Gravity.CENTER);
        LinearLayout.LayoutParams insp=new LinearLayout.LayoutParams(-1,-2);
        insp.topMargin=dp(8);
        controls.addView(instructions,insp);

        setContentView(root);
        telemetry();
    }

    private void startPov(){
        if(renderer.progress>=.998f)altitudeSeek.setProgress(0);
        startAtMs=SystemClock.elapsedRealtime()-(long)(
            renderer.progress*(POV_DURATION_MS-3200f)+3200f);
        if(renderer.progress<.001f)startAtMs=SystemClock.elapsedRealtime();
        renderer.heading=128f;
        dragging=false;
        playing=true;
        play.setText("PAUSAR");
        main.removeCallbacks(ascent);
        main.post(ascent);
    }

    private void stopPov(){
        playing=false;
        main.removeCallbacks(ascent);
        if(play!=null)play.setText(renderer.progress>=.999f?"REPETIR POV":"CONTINUAR POV");
    }

    private void telemetry(){
        if(renderer==null || altitudeText==null)return;
        double alt=ObserverMath.altitudeKm(renderer.progress);
        altitudeText.setText(alt<.1?
                String.format(Locale.US,"%.0f m",alt*1000.):
                alt<10?String.format(Locale.US,"%.2f km",alt):
                String.format(Locale.US,"%.1f km",alt));
        double horizon=ObserverMath.horizonKm(alt);
        horizonText.setText(String.format(Locale.US,
            "HORIZONTE %.1f km   ·   g %.2f m/s²",
            horizon,ObserverMath.gravityMs2(alt)));
        stageText.setText(alt<.025?"BOARDWALK / STEEL PIER":
                          alt<2?"COSTA DE ATLANTIC CITY":
                          alt<25?"NUEVA JERSEY / ASCENSO VIRTUAL":
                          alt<100?"ESTRATÓSFERA / TRANSICIÓN":
                          "ESPACIO CERCANO / TIERRA CURVADA");
    }

    private void installGestures(){
        surface.setOnTouchListener((v,event)->{
            if(closed)return false;
            switch(event.getActionMasked()){
                case MotionEvent.ACTION_DOWN:
                    lastX=event.getX();lastY=event.getY();dragging=false;
                    return true;
                case MotionEvent.ACTION_MOVE:
                    if(event.getPointerCount()==1){
                        float dx=event.getX()-lastX,dy=event.getY()-lastY;
                        if(Math.abs(dx)+Math.abs(dy)>1.5f){
                            if(!dragging && playing)stopPov();
                            dragging=true;
                            renderer.heading=(renderer.heading+dx*.11f+360f)%360f;
                            renderer.pitch=Math.max(-84f,Math.min(70f,renderer.pitch-dy*.085f));
                        }
                        lastX=event.getX();lastY=event.getY();
                    }
                    return true;
                case MotionEvent.ACTION_UP:
                case MotionEvent.ACTION_CANCEL:
                    dragging=false;return true;
                default:return true;
            }
        });
    }

    private void toggleHud(){
        hidden=!hidden;
        controls.setVisibility(hidden?View.GONE:View.VISIBLE);
        subHeading.setVisibility(hidden?View.GONE:View.VISIBLE);
        altitudeText.setVisibility(hidden?View.GONE:View.VISIBLE);
        stageText.setVisibility(hidden?View.GONE:View.VISIBLE);
        horizonText.setVisibility(hidden?View.GONE:View.VISIBLE);
        metricsText.setVisibility(hidden?View.GONE:View.VISIBLE);
        hide.setText(hidden?"MOSTRAR":"OCULTAR");
    }

    @Override public void onFrameRate(int fps,float scale){
        if(closed)return;
        metricsText.setText(String.format(Locale.US,
            "GPU %d FPS  ·  INTERNA %.0f%%  ·  FOTO TIERRA NASA",fps,scale*100));
    }

    @Override public void onPhoto(Bitmap photo){
        if(closed){photo.recycle();return;}
        new Thread(()->{
            Uri saved=null;
            try {
                String name="BOARDWALK_TO_SPACE_"+new SimpleDateFormat(
                        "yyyyMMdd_HHmmss",Locale.US).format(new Date())+".png";
                ContentValues values=new ContentValues();
                values.put(MediaStore.MediaColumns.DISPLAY_NAME,name);
                values.put(MediaStore.MediaColumns.MIME_TYPE,"image/png");
                values.put(MediaStore.MediaColumns.RELATIVE_PATH,Environment.DIRECTORY_PICTURES+"/BoardwalkSpace");
                values.put(MediaStore.MediaColumns.IS_PENDING,1);
                saved=getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,values);
                if(saved==null)throw new IllegalStateException("No se pudo crear PNG");
                try(OutputStream stream=getContentResolver().openOutputStream(saved)){
                    if(stream==null || !photo.compress(Bitmap.CompressFormat.PNG,100,stream))
                        throw new IllegalStateException("Error guardando PNG");
                }
                ContentValues done=new ContentValues();
                done.put(MediaStore.MediaColumns.IS_PENDING,0);
                getContentResolver().update(saved,done,null,null);
                runOnUiThread(()->{
                    if(!closed)Toast.makeText(this,"Foto: Imágenes/BoardwalkSpace",Toast.LENGTH_LONG).show();
                });
            }catch(Exception e){
                if(saved!=null)getContentResolver().delete(saved,null,null);
                String error=e.toString();
                runOnUiThread(()->{
                    if(!closed)Toast.makeText(this,"Error PNG: "+error,Toast.LENGTH_LONG).show();
                });
            }finally{
                photo.recycle();
                runOnUiThread(()->{
                    if(!closed){shot.setEnabled(true);shot.setText("FOTO");}
                });
            }
        },"Boardwalk-Photo").start();
    }

    @Override public void onError(String error){
        lastError=error;
        if(!closed)Toast.makeText(this,"GPU: "+error,Toast.LENGTH_LONG).show();
    }

    @Override protected void onPause(){
        if(surface!=null)surface.onPause();
        if(playing)stopPov();
        super.onPause();
    }

    @Override protected void onResume(){
        super.onResume();
        immersive();
        if(surface!=null)surface.onResume();
    }

    @Override protected void onDestroy(){
        closed=true;
        main.removeCallbacks(ascent);
        super.onDestroy();
    }
}
