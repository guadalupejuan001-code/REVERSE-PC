package com.reversepc.os;

import android.app.Activity;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;
import java.util.HashSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;

/** Physical controls and compact race HUD; all game rules remain in XI. */
public final class VelocityActivity extends Activity {
    private VelocityXSurface surface;
    private TextView speed,lap,position,timer,status,warning,renderInfo;
    private Button pauseButton;
    private RaceMap map;
    private boolean gas,brake,left,right,drift;
    private boolean keyGas,keyBrake,keyLeft,keyRight,keyDrift;
    private final List<Set<Integer>> touchPointers=new ArrayList<>();
    private int dp(float value){return Math.round(getResources().getDisplayMetrics().density*value);}
    private GradientDrawable background(int color){
        GradientDrawable drawable=new GradientDrawable();
        drawable.setColor(color);drawable.setCornerRadius(dp(14));
        drawable.setStroke(dp(1),0x557ab9e3);return drawable;
    }
    private TextView text(String value,int size){
        TextView t=new TextView(this);t.setText(value);t.setTextColor(Color.WHITE);t.setTextSize(size);
        t.setShadowLayer(dp(2),0,dp(1),0xcc000000);
        t.setTypeface(Typeface.create("sans-serif-medium",Typeface.NORMAL));return t;
    }
    private static void changedText(TextView view,String value){
        if(!value.contentEquals(view.getText()))view.setText(value);
    }
    private void add(FrameLayout root,View view,int w,int h,int gravity,int l,int t,int r,int b){
        FrameLayout.LayoutParams p=new FrameLayout.LayoutParams(w<0?w:dp(w),h<0?h:dp(h),gravity);
        p.setMargins(dp(l),dp(t),dp(r),dp(b));root.addView(view,p);
    }
    private Button button(String label){
        Button b=new Button(this);b.setText(label);b.setTextColor(0xfff3f8fe);b.setTextSize(12);
        b.setAllCaps(false);b.setBackground(background(0xa318283a));b.setMinWidth(0);b.setMinimumWidth(0);
        b.setMinHeight(0);b.setMinimumHeight(0);b.setPadding(dp(5),0,dp(5),0);
        b.setContentDescription(label);return b;
    }
    private void hold(Button button,int which){
        Set<Integer> pointers=new HashSet<>();
        touchPointers.add(pointers);
        button.setOnTouchListener((view,event)->{
            int action=event.getActionMasked(),at=event.getActionIndex();
            if(action==MotionEvent.ACTION_DOWN){
                pointers.clear();pointers.add(event.getPointerId(at));
            }else if(action==MotionEvent.ACTION_POINTER_DOWN)
                pointers.add(event.getPointerId(at));
            else if(action==MotionEvent.ACTION_UP||action==MotionEvent.ACTION_POINTER_UP)
                pointers.remove(event.getPointerId(at));
            else if(action==MotionEvent.ACTION_CANCEL)pointers.clear();
            boolean down=!pointers.isEmpty();
            if(which==0)left=down;if(which==1)right=down;if(which==2)brake=down;
            if(which==3)gas=down;if(which==4)drift=down;
            view.setAlpha(down?.58f:1f);controls();
            if(action==MotionEvent.ACTION_UP)view.performClick();
            return true;
        });
    }
    private void controls(){
        if(surface==null)return;
        boolean l=left||keyLeft,r=right||keyRight;
        surface.controls(gas||keyGas?1:0,brake||keyBrake?1:0,l==r?1:l?0:2,drift||keyDrift);
    }
    private void releaseControls(){
        for(Set<Integer> pointers:touchPointers)pointers.clear();
        gas=brake=left=right=drift=false;
        keyGas=keyBrake=keyLeft=keyRight=keyDrift=false;controls();
    }
    private void togglePause(){
        if(surface==null)return;releaseControls();
        boolean paused=surface.togglePause();pauseButton.setText(paused?"Continuar":"Pausa");
    }
    private void raceHud(VelocityXiEngine.Snapshot s,boolean paused,String error,int w,int h,int fps){
        if(s==null)return;
        changedText(speed,s.speedKmh()+" km/h");
        changedText(lap,"VUELTA "+s.displayedLap()+" / 3");
        changedText(position,"POSICIÓN "+s.position+" / 4");
        long hundredths=s.ticks*2;
        changedText(timer,String.format(Locale.ROOT,"%02d:%02d.%02d",hundredths/6000,(hundredths/100)%60,hundredths%100));
        String center=error;
        if(center.isEmpty())center=paused?"EN PAUSA":s.finished?"META · "+s.position+".º":
            s.countdown==150?"ACELERA PARA SALIR":s.countdown>0?""+((s.countdown+49)/50):"";
        changedText(status,center);
        int statusSp=s.countdown>0&&s.countdown<150&&!paused?64:18;
        if(Math.abs(status.getTextSize()-statusSp*getResources().getDisplayMetrics().scaledDensity)>.5f)
            status.setTextSize(statusSp);
        changedText(warning,s.wallContact?"CONTACTO":s.offRoad?"FUERA DE PISTA":"");
        if(renderInfo!=null){String backend=w>640?"REgraphics GLES3":"REgraphics XI";
            changedText(renderInfo,backend+"  "+w+" × "+h+"  |  "+fps+" FPS");}
        map.setCar(s.xCm/100f,s.zCm/100f);
    }
    @Override public void onCreate(Bundle saved){
        super.onCreate(saved);getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        WorkbenchActivity.immersive(this);
        final VelocityXiEngine game;
        try{game=new VelocityXiEngine(this);}
        catch(Exception failure){
            TextView error=text("No se pudo preparar la carrera: "+failure.getMessage(),17);
            error.setPadding(dp(24),dp(24),dp(24),dp(24));error.setBackgroundColor(0xff10191d);
            setContentView(error);return;
        }
        FrameLayout root=new FrameLayout(this);root.setMotionEventSplittingEnabled(true);
        root.setBackgroundColor(0xff101a24);
        surface=new VelocityXSurface(this,game,(s,paused,fps,w,h,error)->runOnUiThread(()->raceHud(s,paused,error,w,h,fps)));
        root.addView(surface,new FrameLayout.LayoutParams(-1,-1));
        View topWash=new View(this);
        topWash.setBackground(new GradientDrawable(
            GradientDrawable.Orientation.TOP_BOTTOM,
            new int[]{0xe20a1522,0x9e13263a,0x0013263a}));
        add(root,topWash,-1,114,Gravity.TOP,0,0,0,0);
        View bottomWash=new View(this);
        bottomWash.setBackground(new GradientDrawable(
            GradientDrawable.Orientation.BOTTOM_TOP,
            new int[]{0xa808101c,0x0008101c}));
        add(root,bottomWash,-1,130,Gravity.BOTTOM,0,0,0,0);
        lap=text("VUELTA 1 / 3",18);add(root,lap,-2,-2,Gravity.TOP|Gravity.LEFT,18,14,0,0);
        position=text("POSICIÓN 4 / 4",18);add(root,position,-2,-2,Gravity.TOP|Gravity.RIGHT,0,14,18,0);
        timer=text("00:00.00",18);add(root,timer,-2,-2,Gravity.TOP|Gravity.CENTER_HORIZONTAL,0,14,0,0);
        speed=text("0 km/h",34);add(root,speed,-2,-2,Gravity.BOTTOM|Gravity.RIGHT,0,0,18,108);
        warning=text("",12);add(root,warning,-2,-2,Gravity.BOTTOM|Gravity.RIGHT,0,0,20,146);
        renderInfo=text("REgraphics XI",10);renderInfo.setTextColor(0xffb4d5e7);
        add(root,renderInfo,-2,-2,Gravity.BOTTOM|Gravity.LEFT,18,0,0,202);
        status=text("ACELERA PARA SALIR",18);status.setGravity(Gravity.CENTER);
        add(root,status,-2,-2,Gravity.CENTER,0,0,0,0);
        map=new RaceMap(game.track());add(root,map,86,86,Gravity.BOTTOM|Gravity.LEFT,18,0,0,106);
        LinearLayout menu=new LinearLayout(this);menu.setOrientation(LinearLayout.HORIZONTAL);
        Button camera=button("Cámara");camera.setOnClickListener(v->{int m=surface.cycleCamera();camera.setText(m==0?"Cámara":m==1?"Cercana":"Capó");});
        Button colors=button("Color");colors.setOnClickListener(v->colors.setText("Color "+(surface.cyclePaint()+1)));
        Button sharpness=button("Nitidez");sharpness.setOnClickListener(v->{
            boolean high=surface.toggleSharpness();sharpness.setText(high?"Alta":"Auto");
            sharpness.setContentDescription(high?"Nitidez alta":"Nitidez automática");
        });
        Button gpu4k=button("4K");
        gpu4k.setContentDescription("Activar renderizado 4K");
        gpu4k.setOnClickListener(v->{
            boolean on=surface.toggle4K();
            gpu4k.setText(on?"4K activo":"4K");
            gpu4k.setBackground(background(on?0xcc145f85:0xa318283a));
            gpu4k.setContentDescription(on?"Desactivar renderizado 4K":"Activar renderizado 4K");
        });
        pauseButton=button("Pausa");pauseButton.setOnClickListener(v->togglePause());
        Button restart=button("Reiniciar");restart.setOnClickListener(v->{releaseControls();surface.reset();pauseButton.setText("Pausa");});
        Button exit=button("Salir");exit.setOnClickListener(v->finish());
        for(Button b:new Button[]{camera,colors,sharpness,gpu4k,pauseButton,restart,exit}){
            LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(dp(66),dp(32));p.setMargins(dp(1),0,dp(1),0);menu.addView(b,p);
        }
        add(root,menu,-2,32,Gravity.TOP|Gravity.CENTER_HORIZONTAL,0,48,0,0);
        Button bLeft=button("◀");hold(bLeft,0);Button bRight=button("▶");hold(bRight,1);
        Button bBrake=button("FRENO");hold(bBrake,2);Button bGas=button("ACELERAR");hold(bGas,3);
        Button bDrift=button("DERRAPE");hold(bDrift,4);
        add(root,bLeft,70,70,Gravity.BOTTOM|Gravity.LEFT,18,0,0,18);
        add(root,bRight,70,70,Gravity.BOTTOM|Gravity.LEFT,100,0,0,18);
        add(root,bGas,108,72,Gravity.BOTTOM|Gravity.RIGHT,0,0,18,18);
        add(root,bBrake,82,58,Gravity.BOTTOM|Gravity.RIGHT,0,0,138,18);
        add(root,bDrift,82,38,Gravity.BOTTOM|Gravity.RIGHT,0,0,232,18);
        setContentView(root);
    }
    /** Circuit projection for a HUD map only; it never feeds game rules. */
    private final class RaceMap extends View {
        private final float[] points;private final Paint pen=new Paint(Paint.ANTI_ALIAS_FLAG);
        private float minX,maxX,minZ,maxZ,carX,carZ;
        RaceMap(float[] points){super(VelocityActivity.this);this.points=points;
            minX=minZ=Float.MAX_VALUE;maxX=maxZ=-Float.MAX_VALUE;
            for(int i=0;i<points.length;i+=2){minX=Math.min(minX,points[i]);maxX=Math.max(maxX,points[i]);minZ=Math.min(minZ,points[i+1]);maxZ=Math.max(maxZ,points[i+1]);}
            setContentDescription("Mapa del circuito");
        }
        void setCar(float x,float z){if(x==carX&&z==carZ)return;carX=x;carZ=z;invalidate();}
        @Override protected void onDraw(Canvas canvas){
            super.onDraw(canvas);float pad=dp(7),scale=Math.min((getWidth()-2*pad)/Math.max(1,maxX-minX),(getHeight()-2*pad)/Math.max(1,maxZ-minZ));
            float ox=(getWidth()-(maxX-minX)*scale)/2,oz=(getHeight()-(maxZ-minZ)*scale)/2;
            Path path=new Path();for(int i=0;i<points.length;i+=2){float x=ox+(points[i]-minX)*scale,y=oz+(maxZ-points[i+1])*scale;if(i==0)path.moveTo(x,y);else path.lineTo(x,y);}
            pen.setStyle(Paint.Style.STROKE);pen.setStrokeWidth(dp(5));pen.setColor(0x990b1119);canvas.drawPath(path,pen);
            pen.setStrokeWidth(dp(2));pen.setColor(0xbbffffff);canvas.drawPath(path,pen);
            pen.setStyle(Paint.Style.FILL);pen.setColor(0xff7fe6ff);canvas.drawCircle(ox+(carX-minX)*scale,oz+(maxZ-carZ)*scale,dp(3),pen);
        }
    }
    @Override public boolean onKeyDown(int key,KeyEvent event){
        if(key==KeyEvent.KEYCODE_P){if(event.getRepeatCount()==0)togglePause();return true;}
        if(key==KeyEvent.KEYCODE_R){if(surface!=null){releaseControls();surface.reset();}if(pauseButton!=null)pauseButton.setText("Pausa");return true;}
        if(key==KeyEvent.KEYCODE_W||key==KeyEvent.KEYCODE_DPAD_UP)keyGas=true;
        else if(key==KeyEvent.KEYCODE_S||key==KeyEvent.KEYCODE_DPAD_DOWN)keyBrake=true;
        else if(key==KeyEvent.KEYCODE_A||key==KeyEvent.KEYCODE_DPAD_LEFT)keyLeft=true;
        else if(key==KeyEvent.KEYCODE_D||key==KeyEvent.KEYCODE_DPAD_RIGHT)keyRight=true;
        else if(key==KeyEvent.KEYCODE_SPACE)keyDrift=true;else return super.onKeyDown(key,event);
        controls();return true;
    }
    @Override public boolean onKeyUp(int key,KeyEvent event){
        if(key==KeyEvent.KEYCODE_W||key==KeyEvent.KEYCODE_DPAD_UP)keyGas=false;
        else if(key==KeyEvent.KEYCODE_S||key==KeyEvent.KEYCODE_DPAD_DOWN)keyBrake=false;
        else if(key==KeyEvent.KEYCODE_A||key==KeyEvent.KEYCODE_DPAD_LEFT)keyLeft=false;
        else if(key==KeyEvent.KEYCODE_D||key==KeyEvent.KEYCODE_DPAD_RIGHT)keyRight=false;
        else if(key==KeyEvent.KEYCODE_SPACE)keyDrift=false;else return super.onKeyUp(key,event);
        controls();return true;
    }
    @Override protected void onResume(){super.onResume();WorkbenchActivity.immersive(this);if(surface!=null)surface.resumeLoop();}
    @Override protected void onPause(){if(surface!=null){releaseControls();surface.pauseLoop();}super.onPause();}
    @Override public void onWindowFocusChanged(boolean focus){super.onWindowFocusChanged(focus);if(!focus)releaseControls();}
    @Override protected void onDestroy(){if(surface!=null)surface.closeLoop();super.onDestroy();}
}
