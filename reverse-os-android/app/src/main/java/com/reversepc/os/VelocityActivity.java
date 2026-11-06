package com.reversepc.os;

import android.app.Activity;
import android.content.SharedPreferences;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.StateListDrawable;
import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.style.ForegroundColorSpan;
import android.text.style.RelativeSizeSpan;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

/** A clear driving surface and a paused, accessible native settings drawer. */
public final class VelocityActivity extends Activity {
    private static final int INK=0xff111619,CARD=0xff1c2327,WHITE=0xfff1f3ec,MUTED=0xff94a19f,ACCENT=0xffc4ef82;
    private static final String[] CARS={"AERO X-01","GRAN TURISMO X-02","TRACK X-03"};
    private static final String[] CAR_NOTES={"La carrocería original","Más largo y estrecho","Más ancho y bajo"};
    private static final String[] TIMES={"Automática","Día","Atardecer","Noche"};
    private static final String[] CAMERAS={"Seguimiento","Cercana","Capó"};
    private VelocityXSurface surface;
    private VelocityGpuSurface gpu;
    private FrameLayout root,drawer;
    private LinearLayout drawerBody;
    private TextView speed,timer,status,warning,renderInfo,sector,countdown;
    private Button gearButton;
    private VelocitySteeringFrame steering;
    private VelocityActionButton nitroButton,jumpButton;
    private VelocityForestAtlas atlas;
    private VelocityForestAtlas.MapView map,menuMap;
    private final VelocityAmbientAudio ambient=new VelocityAmbientAudio();
    private SharedPreferences preferences;
    private boolean foreground,immersiveReady,menuVisible,resumeAfterMenu,showMetrics=true;
    private int page;
    private boolean gas,brake,left,right,drift,nitro,jump;
    private boolean keyGas,keyBrake,keyLeft,keyRight,keyDrift,keyNitro,keyJump;
    private int touchSteer=255;
    private final List<Set<Integer>> touchPointers=new ArrayList<>();
    private final List<Button> heldButtons=new ArrayList<>();
    private int dp(float n){return Math.round(getResources().getDisplayMetrics().density*n);}
    private TextView text(String value,float size,int color){
        TextView t=new TextView(this);t.setText(value);t.setTextSize(size);t.setTextColor(color);
        t.setTypeface(Typeface.create("sans-serif-medium",Typeface.NORMAL));t.setIncludeFontPadding(false);return t;
    }
    private GradientDrawable shape(int color,int edge,int radius){
        GradientDrawable d=new GradientDrawable();d.setColor(color);d.setCornerRadius(dp(radius));
        if(edge!=0)d.setStroke(dp(1),edge);return d;
    }
    private Button button(String label){
        Button b=new Button(this);b.setText(label);b.setTextColor(WHITE);b.setTextSize(12);b.setAllCaps(false);
        b.setTypeface(Typeface.create("sans-serif-medium",Typeface.NORMAL));
        b.setMinWidth(0);b.setMinimumWidth(0);b.setMinHeight(0);b.setMinimumHeight(0);
        b.setPadding(dp(14),0,dp(14),0);
        StateListDrawable bg=new StateListDrawable();
        bg.addState(new int[]{android.R.attr.state_pressed},shape(0xff344139,0xff87a563,14));
        bg.addState(new int[]{android.R.attr.state_selected},shape(0xff273326,ACCENT,14));
        bg.addState(new int[]{},shape(CARD,0xff35403f,14));b.setBackground(bg);return b;
    }
    private static void changed(TextView v,String value){if(!value.contentEquals(v.getText()))v.setText(value);}
    private void add(FrameLayout parent,View v,int w,int h,int gravity,int l,int t,int r,int b){
        FrameLayout.LayoutParams p=new FrameLayout.LayoutParams(w<0?w:dp(w),h<0?h:dp(h),gravity);
        p.setMargins(dp(l),dp(t),dp(r),dp(b));parent.addView(v,p);
    }
    private void hold(Button b,int which){
        Set<Integer> pointers=new HashSet<>();touchPointers.add(pointers);heldButtons.add(b);
        b.setOnTouchListener((view,e)->{
            int action=e.getActionMasked(),at=e.getActionIndex();
            if(action==MotionEvent.ACTION_DOWN){pointers.clear();pointers.add(e.getPointerId(at));}
            else if(action==MotionEvent.ACTION_POINTER_DOWN)pointers.add(e.getPointerId(at));
            else if(action==MotionEvent.ACTION_UP||action==MotionEvent.ACTION_POINTER_UP)pointers.remove(e.getPointerId(at));
            else if(action==MotionEvent.ACTION_CANCEL)pointers.clear();
            boolean down=!pointers.isEmpty();
            if(which==0)left=down;if(which==1)right=down;if(which==2)brake=down;
            if(which==3)gas=down;if(which==4)drift=down;if(which==5)nitro=down;if(which==6)jump=down;
            b.setPressed(down);b.setSelected(down);controls();if(action==MotionEvent.ACTION_UP)view.performClick();return true;
        });
    }
    private void controls(){
        if(surface==null)return;boolean l=left||keyLeft,r=right||keyRight;
        surface.steering(l||r?255:touchSteer);
        surface.controls(gas||keyGas?1:0,brake||keyBrake?1:0,l==r?1:l?0:2,drift||keyDrift,nitro||keyNitro,jump||keyJump);
    }
    private void releaseControls(){
        for(Set<Integer> p:touchPointers)p.clear();for(Button b:heldButtons){b.setPressed(false);b.setSelected(false);}
        gas=brake=left=right=drift=nitro=jump=false;keyGas=keyBrake=keyLeft=keyRight=keyDrift=keyNitro=keyJump=false;
        touchSteer=255;if(steering!=null)steering.resetSteering();controls();
    }
    private void changeGear(){if(surface!=null)surface.setReverseGear(!surface.isReverseRequested());}
    private void togglePause(){
        if(surface==null)return;if(menuVisible){closeMenu(true);return;}
        if(!surface.isPaused())openMenu(0);else surface.togglePause();
    }
    private void raceHud(VelocityXiEngine.Snapshot s,boolean paused,int fps,int w,int h,String error){
        if(s==null||isFinishing()||isDestroyed())return;
        if(!immersiveReady&&((gpu!=null&&gpu.hasPresentedFrame())||(gpu==null&&w>0))){immersiveReady=true;WorkbenchActivity.immersive(this);}
        ambient.update(s);changed(speed,s.speedKmh()+" km/h");
        changed(gearButton,surface.isGearPending()?"…":surface.isReverseGear()?"R":"D");
        gearButton.setContentDescription(surface.isGearPending()?"Frenando para cambiar de marcha":surface.isReverseGear()?"Cambiar a avance":"Cambiar a reversa");
        nitroButton.setStatus(s.nitroPercent()/100f,s.nitroActive);
        jumpButton.setStatus(s.jumpHeightCm>0?1f:1f-s.jumpCooldown/90f,s.jumpHeightCm>0);
        changed(sector,"SECTOR "+String.format(Locale.ROOT,"%02d / 08",s.sector+1));
        int clock=VelocityWorldLight.minutes(s.dayPhase);
        changed(timer,String.format(Locale.ROOT,"%02d:%02d  ·  %.2f km",clock/60,clock%60,s.trackS/100000.0));
        String center=error.isEmpty()?(paused&&!menuVisible?"EN PAUSA":""):error;
        changed(status,center);status.setVisibility(center.isEmpty()?View.GONE:View.VISIBLE);
        boolean counting=!paused&&s.countdown>0&&s.countdown<150;
        countdown.setVisibility(counting?View.VISIBLE:View.GONE);if(counting)changed(countdown,""+((s.countdown+49)/50));
        String road=surface.isGearPending()?"Frenando para cambiar de marcha":s.jumpHeightCm>0?"En el aire · "+s.jumpHeightCm+" cm":
            s.landingPulse?"Aterrizaje":s.wallContact?"Contacto":s.waterDepthCm>0?"Agua · "+s.waterDepthCm+" cm":
            s.offRoad?(s.surface==3?"Barro · poco agarre":"Fuera del asfalto"):s.driftComboPct>100?"Derrape · "+s.driftScore+" pts":
            s.roadEnd?"El camino termina. La exploración sigue.":"";
        changed(warning,road);warning.setVisibility(road.isEmpty()?View.GONE:View.VISIBLE);
        VelocityGraphics g=surface.graphics();
        changed(renderInfo,g.name+(showMetrics?(paused?" · PAUSA":" · "+fps+" FPS")+" · "+w+"×"+h:""));
        atlas.update(s);
    }
    @Override public void onCreate(Bundle state){
        super.onCreate(state);preferences=getSharedPreferences("velocity-driving",MODE_PRIVATE);
        showMetrics=preferences.getBoolean("metrics",true);getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        FrameLayout loading=new FrameLayout(this);loading.setBackgroundColor(INK);
        TextView mark=text("RV",54,ACCENT);mark.setGravity(Gravity.CENTER);mark.setTypeface(Typeface.create("sans-serif-condensed",Typeface.BOLD));add(loading,mark,160,84,Gravity.CENTER,0,0,0,48);
        TextView title=text("REVERSE  VELOCITY",16,WHITE);title.setLetterSpacing(.16f);title.setGravity(Gravity.CENTER);add(loading,title,-1,28,Gravity.CENTER,0,64,0,0);
        TextView subtitle=text("Preparando el recorrido",12,MUTED);subtitle.setGravity(Gravity.CENTER);add(loading,subtitle,-1,24,Gravity.CENTER,0,119,0,0);
        ProgressBar progress=new ProgressBar(this,null,android.R.attr.progressBarStyleHorizontal);progress.setIndeterminate(true);progress.setIndeterminateTintList(ColorStateList.valueOf(ACCENT));add(loading,progress,100,3,Gravity.CENTER,0,172,0,0);
        setContentView(loading);
        new Thread(()->{try{
            VelocityXiEngine game=new VelocityXiEngine(this);runOnUiThread(()->{if(!isFinishing()&&!isDestroyed())buildScene(game);else game.close();});
        }catch(Exception failure){runOnUiThread(()->subtitle.setText("No se pudo abrir el recorrido: "+failure.getMessage()));}},"Velocity-World-Loader").start();
    }
    private void buildScene(VelocityXiEngine game){
        root=new FrameLayout(this);root.setMotionEventSplittingEnabled(true);root.setBackgroundColor(INK);
        surface=new VelocityXSurface(this,game,(s,p,f,w,h,e)->runOnUiThread(()->raceHud(s,p,f,w,h,e)));
        surface.setGraphics(VelocityGraphics.fromId(preferences.getInt("graphics",2)));
        root.addView(surface,new FrameLayout.LayoutParams(-1,-1));
        if(VelocityGpuSurface.supported(this)){
            gpu=new VelocityGpuSurface(this,()->surface.invalidateGpu());gpu.setOnTouchListener((v,e)->surface.onTouchEvent(e));
            surface.attachGpu(gpu);root.addView(gpu,new FrameLayout.LayoutParams(-1,-1));
        }
        View wash=new View(this);wash.setBackground(new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM,new int[]{0x8c111619,0x00111619}));add(root,wash,-1,102,Gravity.TOP,0,0,0,0);
        TextView monogram=text("RV",21,ACCENT);monogram.setGravity(Gravity.CENTER);monogram.setTypeface(Typeface.create("sans-serif-condensed",Typeface.BOLD));monogram.setBackground(shape(0xc9141b1c,0x704d6252,12));add(root,monogram,40,40,Gravity.TOP|Gravity.LEFT,16,16,0,0);
        TextView brand=text("REVERSE\nVELOCITY",15,WHITE);brand.setLetterSpacing(.12f);brand.setTypeface(Typeface.create("sans-serif-condensed",Typeface.BOLD));add(root,brand,132,40,Gravity.TOP|Gravity.LEFT,66,16,0,0);
        renderInfo=text(surface.graphics().name,9,MUTED);add(root,renderInfo,240,18,Gravity.TOP|Gravity.LEFT,66,59,0,0);
        speed=text("0 km/h",30,WHITE);speed.setGravity(Gravity.CENTER);speed.setTypeface(Typeface.create("sans-serif-condensed",Typeface.BOLD));speed.setShadowLayer(dp(2),0,dp(1),0xa8000000);add(root,speed,170,39,Gravity.TOP|Gravity.CENTER_HORIZONTAL,0,13,0,0);
        timer=text("12:00 · 0.00 km",10,0xffd4ddd8);timer.setGravity(Gravity.CENTER);add(root,timer,170,18,Gravity.TOP|Gravity.CENTER_HORIZONTAL,0,54,0,0);
        Button menu=new VelocityMenuButton(this);menu.setOnClickListener(v->openMenu(0));add(root,menu,44,44,Gravity.TOP|Gravity.RIGHT,0,15,16,0);
        sector=text("SECTOR 01 / 08",9,0xffc7d0cb);sector.setGravity(Gravity.RIGHT);add(root,sector,120,18,Gravity.TOP|Gravity.RIGHT,0,65,16,0);
        status=text("",12,WHITE);status.setGravity(Gravity.CENTER);status.setBackground(shape(0xc9182021,0,12));add(root,status,230,30,Gravity.TOP|Gravity.CENTER_HORIZONTAL,0,79,0,0);status.setVisibility(View.GONE);
        warning=text("",10,0xffffd69b);warning.setGravity(Gravity.CENTER);warning.setShadowLayer(dp(2),0,dp(1),0xcc000000);add(root,warning,290,24,Gravity.TOP|Gravity.CENTER_HORIZONTAL,0,112,0,0);
        countdown=text("",64,ACCENT);countdown.setGravity(Gravity.CENTER);add(root,countdown,104,100,Gravity.CENTER,0,0,0,0);countdown.setVisibility(View.GONE);
        try{atlas=new VelocityForestAtlas(this,game.track());}catch(Exception e){throw new IllegalStateException("No se pudo cargar el mapa",e);}
        map=atlas.view(this,false);map.setOnClickListener(v->openMenu(3));add(root,map,94,66,Gravity.TOP|Gravity.LEFT,16,86,0,0);
        steering=new VelocitySteeringFrame(this);steering.setSteeringListener(value->{touchSteer=value;controls();android.util.Log.i("ReverseVelocity","ANALOG_STEERING value="+value);});add(root,steering,116,116,Gravity.BOTTOM|Gravity.LEFT,16,0,0,12);
        Button driftButton=button("DERRAPE");driftButton.setTextSize(8);driftButton.setContentDescription("Derrape");hold(driftButton,4);add(root,driftButton,78,44,Gravity.BOTTOM|Gravity.LEFT,34,0,0,138);
        Button throttle=new VelocityPedalButton(this,"ACELERAR",false);hold(throttle,3);add(root,throttle,76,94,Gravity.BOTTOM|Gravity.RIGHT,0,0,16,12);
        Button brakePedal=new VelocityPedalButton(this,"FRENO",true);hold(brakePedal,2);add(root,brakePedal,66,76,Gravity.BOTTOM|Gravity.RIGHT,0,0,102,12);
        nitroButton=new VelocityActionButton(this,"NITRO",false);hold(nitroButton,5);add(root,nitroButton,52,62,Gravity.BOTTOM|Gravity.RIGHT,0,0,18,118);
        jumpButton=new VelocityActionButton(this,"SALTO",true);hold(jumpButton,6);add(root,jumpButton,52,62,Gravity.BOTTOM|Gravity.RIGHT,0,0,82,118);
        gearButton=button("D");gearButton.setTextSize(16);gearButton.setTextColor(ACCENT);gearButton.setOnClickListener(v->changeGear());add(root,gearButton,44,44,Gravity.BOTTOM|Gravity.RIGHT,0,0,145,120);
        setContentView(root);if(foreground){if(gpu!=null)gpu.onResume();surface.resumeLoop();}
    }
    private void openMenu(int selectedPage){
        if(surface==null)return;
        if(!menuVisible){
            releaseControls();resumeAfterMenu=!surface.isPaused();if(resumeAfterMenu)surface.togglePause();
            menuVisible=true;drawer=new FrameLayout(this);drawer.setBackgroundColor(0x9805080a);drawer.setClickable(true);
            drawer.setOnClickListener(v->closeMenu(false));root.addView(drawer,new FrameLayout.LayoutParams(-1,-1));
            android.util.Log.i("ReverseVelocity","MENU_OPEN paused=true");
        }
        showPage(selectedPage);
    }
    private void closeMenu(boolean continueDriving){
        if(!menuVisible)return;
        if(menuMap!=null){atlas.release(menuMap);menuMap=null;}
        root.removeView(drawer);drawer=null;menuVisible=false;
        releaseControls();if((continueDriving||resumeAfterMenu)&&surface.isPaused())surface.togglePause();
        android.util.Log.i("ReverseVelocity","MENU_CLOSE paused="+surface.isPaused());
    }
    private void section(String title){TextView t=text(title,10,MUTED);t.setLetterSpacing(.12f);LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,dp(28));p.topMargin=dp(10);drawerBody.addView(t,p);}
    private void row(String title,String value,Runnable action){
        Button b=button(title+"\n"+value);b.setGravity(Gravity.LEFT|Gravity.CENTER_VERTICAL);b.setText(styled(title,value));b.setContentDescription(title+". "+value);b.setOnClickListener(v->action.run());
        LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,dp(58));p.bottomMargin=dp(8);drawerBody.addView(b,p);
    }
    private SpannableString styled(String title,String detail){
        SpannableString s=new SpannableString(title+"\n"+detail);int start=title.length()+1;
        s.setSpan(new ForegroundColorSpan(MUTED),start,s.length(),Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        s.setSpan(new RelativeSizeSpan(.78f),start,s.length(),Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);return s;
    }
    private void showPage(int selected){
        page=selected;if(menuMap!=null){atlas.release(menuMap);menuMap=null;}drawer.removeAllViews();
        int width=Math.min(360,Math.round(getResources().getDisplayMetrics().widthPixels/getResources().getDisplayMetrics().density)-40);
        FrameLayout panel=new FrameLayout(this);panel.setBackground(shape(0xff141a1d,0xff303a38,22));panel.setClickable(true);
        add(drawer,panel,width,-1,Gravity.RIGHT,0,8,8,8);
        String[] titles={"Tu recorrido","Gráficos","Garaje","Mapa"};
        TextView kicker=text("REVERSE VELOCITY",9,ACCENT);kicker.setLetterSpacing(.16f);add(panel,kicker,-2,18,Gravity.TOP|Gravity.LEFT,24,20,0,0);
        TextView title=text(titles[page],25,WHITE);title.setTypeface(Typeface.create("sans-serif-condensed",Typeface.BOLD));add(panel,title,-2,35,Gravity.TOP|Gravity.LEFT,24,39,0,0);
        Button back=button(page==0?"×":"‹");back.setTextSize(24);back.setPadding(0,0,0,0);back.setContentDescription(page==0?"Cerrar menú":"Volver al menú");back.setOnClickListener(v->{if(page==0)closeMenu(false);else showPage(0);});add(panel,back,40,40,Gravity.TOP|Gravity.RIGHT,0,24,20,0);
        ScrollView scroll=new ScrollView(this);scroll.setFillViewport(false);scroll.setClipToPadding(false);scroll.setVerticalScrollBarEnabled(false);
        drawerBody=new LinearLayout(this);drawerBody.setOrientation(LinearLayout.VERTICAL);drawerBody.setPadding(dp(20),0,dp(20),dp(12));scroll.addView(drawerBody);
        add(panel,scroll,-1,-1,Gravity.TOP,0,86,0,82);
        Button resume=button("Continuar");resume.setTextColor(INK);resume.setTypeface(Typeface.DEFAULT_BOLD);resume.setBackground(shape(ACCENT,0,14));resume.setOnClickListener(v->closeMenu(true));add(panel,resume,-1,48,Gravity.BOTTOM,20,0,20,18);
        if(page==1){
            section("ELIGE TU EQUILIBRIO");
            for(VelocityGraphics g:VelocityGraphics.ALL){
                Button b=button("");b.setGravity(Gravity.LEFT|Gravity.CENTER_VERTICAL);b.setText(styled(g.name,g.description));b.setSelected(g==surface.graphics());
                b.setContentDescription("Gráficos: "+g.name+(g==surface.graphics()?", seleccionado":"")+". "+g.width+" por "+g.height);
                b.setOnClickListener(v->{surface.setGraphics(g);preferences.edit().putInt("graphics",g.id).apply();showPage(1);});
                LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,dp(62));p.bottomMargin=dp(9);drawerBody.addView(b,p);
            }
        }else if(page==2){
            section("TRES FORMAS DE EXPLORAR");
            for(int i=0;i<CARS.length;i++){
                final int car=i;Button b=button("");b.setGravity(Gravity.LEFT|Gravity.CENTER_VERTICAL);b.setText(styled(CARS[i],CAR_NOTES[i]));b.setSelected(surface.selectedCar()==i);b.setContentDescription("Elegir "+CARS[i]);
                b.setOnClickListener(v->{surface.selectCar(car);showPage(2);});LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,dp(70));p.bottomMargin=dp(10);drawerBody.addView(b,p);
            }
            row("Color del coche","Toca para cambiar el acabado",()->{surface.cyclePaint();});
        }else if(page==3){
            menuMap=atlas.view(this,true);drawerBody.addView(menuMap,new LinearLayout.LayoutParams(-1,dp(164)));
            TextView destination=text(atlas.destination(),11,MUTED);destination.setPadding(0,dp(12),0,dp(8));drawerBody.addView(destination);
            for(int i=0;i<atlas.places.size();i++){final int index=i;row(atlas.places.get(i).name,"Marcar destino",()->{atlas.select(index);destination.setText(atlas.destination());});}
            row("Quitar destino","Seguir explorando libremente",()->{atlas.select(-1);destination.setText(atlas.destination());});
            android.util.Log.i("ReverseVelocity","MAP_OPEN trails=4 places=6");
        }else{
            section("A TU MANERA");
            row("Gráficos",surface.graphics().name+" · "+surface.graphics().height+"p",()->showPage(1));
            row("Garaje",CARS[surface.selectedCar()],()->showPage(2));
            row("Mapa","Cuatro senderos · seis destinos",()->showPage(3));
            row("Conducción",new String[]{"Manual","Asistida","Piloto"}[surface.assistMode()],()->{surface.cycleAssistMode();showPage(0);});
            row("Cámara",CAMERAS[surface.selectedCamera()],()->{surface.cycleCamera();showPage(0);});
            row("Centrar cámara","Volver detrás del coche",()->surface.centerCamera());
            row("Hora del día",TIMES[surface.worldTime()],()->{surface.cycleWorldTime();showPage(0);});
            row("Sonido",ambient.isEnabled()?"Activado":"Desactivado",()->{ambient.toggle();showPage(0);});
            row("Mostrar FPS",showMetrics?"Activado":"Desactivado",()->{showMetrics=!showMetrics;preferences.edit().putBoolean("metrics",showMetrics).apply();showPage(0);});
            section("RECORRIDO");
            row("Reiniciar","Volver al comienzo",()->{releaseControls();surface.reset();closeMenu(true);});
            row("Salir del juego","Cerrar Reverse Velocity",()->finish());
        }
    }
    @Override public void onBackPressed(){if(menuVisible){if(page==0)closeMenu(false);else showPage(0);}else openMenu(0);}
    @Override public boolean onKeyDown(int key,KeyEvent event){
        if(key==KeyEvent.KEYCODE_P||key==KeyEvent.KEYCODE_ESCAPE){if(event.getRepeatCount()==0)togglePause();return true;}
        if(key==KeyEvent.KEYCODE_G){if(event.getRepeatCount()==0)changeGear();return true;}
        if(key==KeyEvent.KEYCODE_C){if(surface!=null)surface.centerCamera();return true;}
        if(key==KeyEvent.KEYCODE_R){if(surface!=null){releaseControls();surface.reset();if(menuVisible)closeMenu(true);}return true;}
        if(menuVisible)return super.onKeyDown(key,event);
        if(key==KeyEvent.KEYCODE_W||key==KeyEvent.KEYCODE_DPAD_UP)keyGas=true;
        else if(key==KeyEvent.KEYCODE_S||key==KeyEvent.KEYCODE_DPAD_DOWN)keyBrake=true;
        else if(key==KeyEvent.KEYCODE_A||key==KeyEvent.KEYCODE_DPAD_LEFT)keyLeft=true;
        else if(key==KeyEvent.KEYCODE_D||key==KeyEvent.KEYCODE_DPAD_RIGHT)keyRight=true;
        else if(key==KeyEvent.KEYCODE_SPACE)keyDrift=true;
        else if(key==KeyEvent.KEYCODE_N)keyNitro=true;
        else if(key==KeyEvent.KEYCODE_J)keyJump=true;
        else return super.onKeyDown(key,event);
        controls();return true;
    }
    @Override public boolean onKeyUp(int key,KeyEvent event){
        if(key==KeyEvent.KEYCODE_W||key==KeyEvent.KEYCODE_DPAD_UP)keyGas=false;
        else if(key==KeyEvent.KEYCODE_S||key==KeyEvent.KEYCODE_DPAD_DOWN)keyBrake=false;
        else if(key==KeyEvent.KEYCODE_A||key==KeyEvent.KEYCODE_DPAD_LEFT)keyLeft=false;
        else if(key==KeyEvent.KEYCODE_D||key==KeyEvent.KEYCODE_DPAD_RIGHT)keyRight=false;
        else if(key==KeyEvent.KEYCODE_SPACE)keyDrift=false;
        else if(key==KeyEvent.KEYCODE_N)keyNitro=false;
        else if(key==KeyEvent.KEYCODE_J)keyJump=false;
        else return super.onKeyUp(key,event);
        controls();return true;
    }
    @Override protected void onResume(){super.onResume();foreground=true;ambient.resume();if(immersiveReady)WorkbenchActivity.immersive(this);if(gpu!=null)gpu.onResume();if(surface!=null)surface.resumeLoop();}
    @Override protected void onPause(){foreground=false;ambient.pause();if(surface!=null){releaseControls();surface.pauseLoop();}if(gpu!=null)gpu.onPause();super.onPause();}
    @Override public void onWindowFocusChanged(boolean focus){super.onWindowFocusChanged(focus);if(!focus)releaseControls();}
    @Override protected void onDestroy(){ambient.close();if(surface!=null)surface.closeLoop();super.onDestroy();}
}
