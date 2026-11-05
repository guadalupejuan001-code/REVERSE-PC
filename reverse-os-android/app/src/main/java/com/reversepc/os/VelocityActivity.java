package com.reversepc.os;

import android.app.Activity;
import android.app.AlertDialog;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.StateListDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.HorizontalScrollView;
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
    private VelocityGpuSurface gpu;
    private final VelocityAmbientAudio ambient=new VelocityAmbientAudio();
    private TextView speed,lap,position,timer,status,countdown,warning,renderInfo;
    private VelocityCockpitView cockpit;
    private Button gearButton,soundButton;
    private Button pauseButton,native4KButton,hudButton,garageButton,assistButton;
    private boolean dashboardVisible,immersiveReady;
    private boolean foreground;
    private static final String[] CARS={
        "AERO X-01 · carrocería original",
        "GRAN TURISMO X-02 · más largo y estrecho",
        "TRACK X-03 · más ancho y bajo"
    };
    private VelocityActionButton nitroButton,jumpButton;
    private VelocityForestAtlas atlas;
    private VelocityForestAtlas.MapView map;
    private int touchSteer=255;
    private boolean gas,brake,left,right,drift,nitro,jump;
    private boolean keyGas,keyBrake,keyLeft,keyRight,keyDrift,keyNitro,keyJump;
    private final List<Set<Integer>> touchPointers=new ArrayList<>();
    private int dp(float value){return Math.round(getResources().getDisplayMetrics().density*value);}
    private GradientDrawable background(int color){
        GradientDrawable drawable=new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM,
            new int[]{0xc8384b5a,color,0xe0091420});
        drawable.setCornerRadius(dp(12));
        drawable.setStroke(dp(1),0x857d9eaf);return drawable;
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
        Button b=new Button(this);b.setText(label);b.setTextColor(0xfff3f8fe);b.setTextSize(11.5f);
        b.setTypeface(Typeface.create("sans-serif-medium",Typeface.BOLD));
        b.setAllCaps(false);
        StateListDrawable states=new StateListDrawable();
        states.addState(new int[]{android.R.attr.state_pressed},background(0xe12b5a70));
        states.addState(new int[]{android.R.attr.state_selected},background(0xe12b5a70));
        states.addState(new int[]{},background(0xbb172738));
        b.setBackground(states);b.setMinWidth(0);b.setMinimumWidth(0);
        b.setMinHeight(0);b.setMinimumHeight(0);b.setPadding(dp(6),0,dp(6),0);
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
            if(which==5)nitro=down;if(which==6)jump=down;
            button.setPressed(down);button.setSelected(down);controls();
            if(action==MotionEvent.ACTION_UP)view.performClick();
            return true;
        });
    }
    private void controls(){
        if(surface==null)return;
        boolean l=left||keyLeft,r=right||keyRight;
        surface.steering(l||r?255:touchSteer);
        surface.controls(gas||keyGas?1:0,brake||keyBrake?1:0,l==r?1:l?0:2,
            drift||keyDrift,nitro||keyNitro,jump||keyJump);
    }
    private void releaseControls(){
        for(Set<Integer> pointers:touchPointers)pointers.clear();
        gas=brake=left=right=drift=nitro=jump=false;touchSteer=255;
        keyGas=keyBrake=keyLeft=keyRight=keyDrift=keyNitro=keyJump=false;
        if(nitroButton!=null)nitroButton.setSelected(false);
        if(jumpButton!=null)jumpButton.setSelected(false);
        controls();
    }
    private void changeGear(){
        if(surface==null||gearButton==null)return;
        surface.setReverseGear(!surface.isReverseRequested());
    }
    private void togglePause(){
        if(surface==null||surface.is4KEnabled())return;
        releaseControls();
        boolean paused=surface.togglePause();pauseButton.setText(paused?"Continuar":"Pausa");
    }
    private void showGarage(){
        if(surface==null)return;
        releaseControls();
        new AlertDialog.Builder(this)
            .setTitle("Garaje · tres carrocerías XI")
            .setSingleChoiceItems(CARS,surface.selectedCar(),(dialog,which)->{
                surface.selectCar(which);
                garageButton.setText("Coche "+(which+1));
                garageButton.setContentDescription("Garaje. "+CARS[which]);
                dialog.dismiss();
            }).setNegativeButton("Cerrar",null).show();
    }
    private void raceHud(VelocityXiEngine.Snapshot s,boolean paused,String error,int w,int h,int fps){
        if(s==null)return;
        if(!immersiveReady&&((gpu!=null&&gpu.hasPresentedFrame())||(gpu==null&&w>0))){immersiveReady=true;WorkbenchActivity.immersive(this);}
        ambient.update(s);if(soundButton!=null)changedText(soundButton,ambient.isEnabled()?"Sonido: on":"Sonido: off");
        changedText(speed,(surface.isReverseGear()?"R · ":"")+s.speedKmh()+" km/h");
        if(gearButton!=null){
            changedText(gearButton,surface.isGearPending()?
                (surface.isReverseRequested()?"Frenando · R":"Frenando · D"):
                surface.isReverseGear()?"Avance D":"Reversa R");
            gearButton.setContentDescription(surface.isGearPending()?
                "Frenando para cambiar. Toca para cancelar":surface.isReverseGear()?
                "Cambiar a marcha adelante":"Cambiar a reversa");
        }
        cockpit.update(s,surface.isReverseGear(),surface.isBrakePressed(),surface.isAccelerating());
        if(nitroButton!=null)nitroButton.setStatus(s.nitroPercent()/100f,s.nitroActive);
        if(jumpButton!=null)jumpButton.setStatus(
            s.jumpHeightCm>0?1f:1f-s.jumpCooldown/90f,s.jumpHeightCm>0);
        changedText(lap,s.openWorld?"OPEN FOREST ROAD":"VUELTA "+s.displayedLap()+" / 3");
        changedText(position,s.openWorld?"SECTOR "+(s.sector+1)+" / 8":"POSICIÓN "+s.position+" / 4");
        long hundredths=s.ticks*2;
        int clock=VelocityWorldLight.minutes(s.dayPhase);
        changedText(timer,s.openWorld?String.format(Locale.ROOT,"%02d:%02d · %.2f km",clock/60,clock%60,s.trackS/100000.0):String.format(Locale.ROOT,"%02d:%02d.%02d",hundredths/6000,(hundredths/100)%60,hundredths%100));
        String center=error;
        boolean isCounting=error.isEmpty()&&!paused&&!s.finished&&
            s.countdown>0&&s.countdown<150;
        boolean photo=surface.is4KEnabled();
        if(center.isEmpty())center=photo?"FOTO 4K · PAUSA":
            paused?"EN PAUSA":s.finished?"META · "+s.position+".º":
            s.openWorld?"":s.countdown==150?"ACELERA PARA SALIR":"";
        changedText(status,center);
        status.setVisibility(center.isEmpty()?View.GONE:View.VISIBLE);
        countdown.setVisibility(isCounting?View.VISIBLE:View.GONE);
        if(isCounting)changedText(countdown,Integer.toString((s.countdown+49)/50));
        String roadWarning=s.jumpHeightCm>0?"AIRE · "+s.jumpHeightCm+" cm":
            s.landingPulse?"ATERRIZAJE":s.wallContact?"CONTACTO":
            s.offRoad?(s.waterDepthCm>0?"AGUA · "+s.waterDepthCm+" cm":s.surface==3?"BARRO · POCO AGARRE":s.surface==2?"TIERRA · AGARRE MEDIO":"PASTO · POCO AGARRE"):
            s.drafting?"REBUFO · NITRO +":
            s.driftComboPct>100?
                "DERRAPE "+s.driftScore+" PTS · x"+String.format(Locale.ROOT,"%.1f",s.driftComboPct/100f):"";
        if(s.openWorld&&roadWarning.isEmpty())roadWarning=s.roadEnd?"FIN DE CARRETERA · SIGUE EXPLORANDO":s.biome==5?"VADO DEL RÍO · "+s.waterDepthCm+" cm":s.biome==4?"LODO · BOSQUE HÚMEDO":s.biome==1?"PUENTE DEL RÍO":s.biome==2?"LAGUNA DE LOS CEDROS":s.ambientMode==2?"NOCHE · FAROS AUTOMÁTICOS":"";
        if(surface.isGearPending())roadWarning=surface.isReverseRequested()?
            "FRENANDO PARA REVERSA":"FRENANDO PARA AVANZAR";
        else if(roadWarning.isEmpty()&&surface.assistMode()>0)
            roadWarning=surface.assistMode()==2?"PILOTO XI":"ASISTIDA XI";
        changedText(warning,roadWarning);
        if(native4KButton!=null)
            changedText(native4KButton,photo?"Salir 4K":"Foto 4K");
        // Only the small race labels remain; never obscure the car with
        // animated dials or the minimap during native-resolution photography.
        cockpit.setVisibility(!photo&&dashboardVisible?View.VISIBLE:View.GONE);
        map.setVisibility(photo?View.GONE:View.VISIBLE);
        speed.setVisibility(photo?View.GONE:View.VISIBLE);
        warning.setVisibility(photo?View.GONE:View.VISIBLE);
        if(pauseButton!=null)pauseButton.setEnabled(!photo);
        if(renderInfo!=null){String backend=w==3840?"REgraphics XI · FOTO 4K":"REgraphics XI";
            changedText(renderInfo,photo?"XI FOTO "+w+"×"+h:
                surface.rendererLabel()+" "+w+"×"+h+" · "+fps+" FPS");}
        atlas.update(s);
    }
    @Override public void onCreate(Bundle saved){
        super.onCreate(saved);getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        TextView loading=text("Preparando el bosque…",17);loading.setPadding(dp(24),dp(24),dp(24),dp(24));loading.setBackgroundColor(0xff10191d);setContentView(loading);
        new Thread(()->{
            try{VelocityXiEngine game=new VelocityXiEngine(this);runOnUiThread(()->{if(!isFinishing()&&!isDestroyed())buildScene(game);else game.close();});}
            catch(Exception failure){runOnUiThread(()->{if(!isFinishing()&&!isDestroyed())loading.setText("No se pudo preparar el bosque: "+failure.getMessage());});}
        },"Velocity-World-Loader").start();
    }
    private void buildScene(VelocityXiEngine game){
        FrameLayout root=new FrameLayout(this);root.setMotionEventSplittingEnabled(true);
        root.setBackgroundColor(0xff101a24);
        surface=new VelocityXSurface(this,game,(s,paused,fps,w,h,error)->runOnUiThread(()->raceHud(s,paused,error,w,h,fps)));
        root.addView(surface,new FrameLayout.LayoutParams(-1,-1));
        if(VelocityGpuSurface.supported(this)){
            gpu=new VelocityGpuSurface(this,()->surface.invalidateGpu());
            gpu.setOnTouchListener((view,event)->surface.onTouchEvent(event));
            surface.attachGpu(gpu);root.addView(gpu,new FrameLayout.LayoutParams(-1,-1));
        }
        View topWash=new View(this);
        topWash.setBackground(new GradientDrawable(
            GradientDrawable.Orientation.TOP_BOTTOM,
            new int[]{0x910a1522,0x4813263a,0x0013263a}));
        add(root,topWash,-1,114,Gravity.TOP,0,0,0,0);
        View bottomWash=new View(this);
        bottomWash.setBackground(new GradientDrawable(
            GradientDrawable.Orientation.BOTTOM_TOP,
            new int[]{0x5208101c,0x0008101c}));
        add(root,bottomWash,-1,130,Gravity.BOTTOM,0,0,0,0);
        lap=text("OPEN FOREST ROAD",18);add(root,lap,-2,-2,Gravity.TOP|Gravity.LEFT,18,14,0,0);
        position=text("SECTOR 1 / 8",18);add(root,position,-2,-2,Gravity.TOP|Gravity.RIGHT,0,14,18,0);
        timer=text("00:00.00",18);add(root,timer,-2,-2,Gravity.TOP|Gravity.CENTER_HORIZONTAL,0,14,0,0);
        // Three distinct bottom zones: wheel, center instruments, pedals.
        // Keep the tachometer clear of the top controls on short landscapes.
        cockpit=new VelocityCockpitView(this);
        add(root,cockpit,194,106,Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL,0,0,0,6);
        cockpit.setVisibility(View.GONE); // Full vehicle silhouette by default.
        speed=text("0 km/h",20);
        speed.setGravity(Gravity.CENTER);
        add(root,speed,116,28,Gravity.TOP|Gravity.CENTER_HORIZONTAL,0,116,0,0);
        warning=text("",12);add(root,warning,-2,-2,Gravity.TOP|Gravity.RIGHT,0,133,18,0);
        renderInfo=text("REgraphics XI",10);renderInfo.setTextColor(0xffb4d5e7);
        add(root,renderInfo,144,24,Gravity.TOP|Gravity.LEFT,132,10,0,0);
        status=text("",14);status.setGravity(Gravity.CENTER);
        status.setBackground(background(0xb322374b));
        status.setPadding(dp(12),dp(2),dp(12),dp(2));
        add(root,status,-2,26,Gravity.TOP|Gravity.CENTER_HORIZONTAL,0,89,0,0);
        // Countdown is separate from the 26dp status badge: 64sp was previously
        // clipped by the status view during the three-second start sequence.
        countdown=text("",64);countdown.setGravity(Gravity.CENTER);
        add(root,countdown,104,100,Gravity.CENTER,0,0,0,0);
        countdown.setVisibility(View.GONE);
        try{atlas=new VelocityForestAtlas(this,game.track());}catch(Exception e){throw new IllegalStateException("No se pudo cargar el mapa",e);}
        map=atlas.view(this,false);map.setOnClickListener(v->showMap());add(root,map,96,68,Gravity.TOP|Gravity.LEFT,16,96,0,0);
        LinearLayout menu=new LinearLayout(this);menu.setOrientation(LinearLayout.HORIZONTAL);
        assistButton=button("Manual");
        assistButton.setContentDescription("Cambiar conducción: Manual, Asistida o Piloto automático. Dirección y freno manual siempre tienen prioridad");
        assistButton.setOnClickListener(v->{
            int mode=surface.cycleAssistMode();
            assistButton.setText(mode==0?"Manual":mode==1?"Asistida":"Piloto");
        });
        Button camera=button("Cámara");
        camera.setContentDescription("Cámara: toque para cambiar de vista; arrastra la pantalla para orbitar 360 grados o cambiar altura; doble toque o pulsación larga aquí para centrar");
        camera.setOnClickListener(v->{int m=surface.cycleCamera();camera.setText(m==0?"Cámara":m==1?"Cercana":"Capó");});
        camera.setOnLongClickListener(v->{surface.centerCamera();return true;});
        Button time=button("Hora: auto");
        time.setContentDescription("Cambiar hora: ciclo automático, día, atardecer o noche");
        time.setOnClickListener(v->{int mode=surface.cycleWorldTime();time.setText(new String[]{"Hora: auto","Día","Atardecer","Noche"}[mode]);});
        Button sound=button("Sonido: off");soundButton=sound;sound.setOnClickListener(v->sound.setText(ambient.toggle()?"Sonido: on":"Sonido: off"));
        Button colors=button("Color");colors.setOnClickListener(v->colors.setText("Color "+(surface.cyclePaint()+1)));
        Button sharpness=button("HD 720p");sharpness.setOnClickListener(v->{
            boolean high=surface.toggleSharpness();sharpness.setText(high?"HD 720p":"Fluido");
            sharpness.setContentDescription(high?"Imagen HD real 1280 por 720":"Modo fluido de resolución adaptable");
        });
        // No third-party GPU renderer. Display the exact REgraphics technical
        // boundary, instead of pretending the XI 640x360 image is native 4K.
        Button native4k=button("Foto 4K");native4KButton=native4k;
        native4k.setContentDescription("Capturar foto nativa 3840 por 2160 con la carrera detenida");
        native4k.setOnClickListener(v->{
            releaseControls();
            boolean enabled=surface.toggle4K();
            native4k.setText(enabled?"Salir 4K":"Foto 4K");
            native4k.setContentDescription(enabled?"Volver a la conducción":
                "Entrar en fotografía 4K de un fotograma");
            pauseButton.setText(surface.isPaused()?"Continuar":"Pausa");
            cockpit.setVisibility(View.GONE);
        });
        Button engine=button("Motor XI");
        engine.setContentDescription("Capacidades y límites actuales del renderizador XI");
        engine.setOnClickListener(v->new AlertDialog.Builder(this)
            .setTitle("REgraphics XI • GPU")
            .setMessage("Open Forest Road 3.4.2 — Conducción y paisajes HD\n\nPuedes salir de la carretera y seguir explorando. El terreno y el bosque se generan alrededor del coche: se eliminó la pared invisible de 50 metros y el suelo visible comparte altura con las ruedas. La carretera principal conserva ocho sectores; el piloto se detiene al final, pero en Manual puedes seguir conduciendo.\n\nEl volante es analógico: desliza el dedo para dosificar el giro y suéltalo para centrar. El giro a baja velocidad es más ágil, con mejor recuperación de agarre.\n\nPuente alineado con el camino, soportes y barandales. Ardillas con cuerpo redondeado y cola curva, ramas y pasto con viento. Lentes transparentes y faros con iluminación suave sobre el terreno y volumen de luz en la GPU.\n\nXI/Ether sigue controlando física, geometría y cámara. REgraphics usa shaders propios en GPU y conserva respaldo por software. HD 720p renderiza 1280 × 720 de verdad. Fluido adapta la resolución según el coste de presentación de la GPU. Mapa muestra cuatro senderos, seis destinos y tu posición. Hay caminos hacia el mirador, el pinar, el vado y la ribera. Foto 4K pausa la conducción y renderiza 3840 × 2160.")
            .setPositiveButton("Entendido",(dialog,which)->dialog.dismiss())
            .show());
        pauseButton=button("Pausa");pauseButton.setOnClickListener(v->togglePause());
        Button restart=button("Reiniciar");restart.setOnClickListener(v->{releaseControls();surface.reset();pauseButton.setText("Pausa");if(gearButton!=null)gearButton.setText("Reversa R");});
        Button exit=button("Salir");exit.setOnClickListener(v->finish());
        garageButton=button("Garaje");
        garageButton.setOnClickListener(v->showGarage());
        hudButton=button("HUD libre");
        hudButton.setOnClickListener(v->{
            dashboardVisible=!dashboardVisible;
            hudButton.setText(dashboardVisible?"HUD tablero":"HUD libre");
            cockpit.setVisibility(dashboardVisible&&!surface.is4KEnabled()?View.VISIBLE:View.GONE);
        });
        Button atlasButton=button("Mapa");atlasButton.setOnClickListener(v->showMap());
        for(Button b:new Button[]{assistButton,camera,atlasButton,time,colors,sharpness,native4k,pauseButton,
                garageButton,hudButton,sound,engine,restart,exit}){
            LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(dp(76),dp(40));p.setMargins(dp(2),0,dp(2),0);menu.addView(b,p);
        }
        HorizontalScrollView tools=new HorizontalScrollView(this);
        tools.setHorizontalScrollBarEnabled(false);
        tools.setFillViewport(false);
        tools.setContentDescription("Opciones del mapa. Desliza esta barra horizontalmente para encontrar Motor XI, Reiniciar, Salir y otros controles.");
        tools.addView(menu,new HorizontalScrollView.LayoutParams(-2,dp(40)));
        add(root,tools,-1,44,Gravity.TOP,8,48,8,0);
        // Native Button descendants keep the accessibility and adb touch contract.
        VelocitySteeringFrame steering=new VelocitySteeringFrame(this);
        steering.setSteeringListener(value->{touchSteer=value;controls();android.util.Log.i("ReverseVelocity","ANALOG_STEERING value="+value);});
        Button bLeft=button("◀");hold(bLeft,0);
        Button bRight=button("▶");hold(bRight,1);
        bLeft.setBackground(background(0x70324a60));bRight.setBackground(background(0x70324a60));
        FrameLayout.LayoutParams leftParams=new FrameLayout.LayoutParams(dp(66),dp(62),Gravity.LEFT|Gravity.CENTER_VERTICAL);
        leftParams.leftMargin=dp(3);steering.addView(bLeft,leftParams);
        FrameLayout.LayoutParams rightParams=new FrameLayout.LayoutParams(dp(66),dp(62),Gravity.RIGHT|Gravity.CENTER_VERTICAL);
        rightParams.rightMargin=dp(3);steering.addView(bRight,rightParams);
        add(root,steering,148,100,Gravity.BOTTOM|Gravity.LEFT,12,0,0,10);
        Button bBrake=new VelocityPedalButton(this,"FRENO",true);hold(bBrake,2);
        Button bGas=new VelocityPedalButton(this,"ACELERAR",false);hold(bGas,3);
        Button bDrift=button("DERRAPE");hold(bDrift,4);
        nitroButton=new VelocityActionButton(this,"NITRO",false);hold(nitroButton,5);
        jumpButton=new VelocityActionButton(this,"SALTO",true);hold(jumpButton,6);
        add(root,nitroButton,94,54,Gravity.BOTTOM|Gravity.RIGHT,0,0,14,120);
        add(root,jumpButton,94,54,Gravity.BOTTOM|Gravity.RIGHT,0,0,116,120);
        add(root,bGas,88,92,Gravity.BOTTOM|Gravity.RIGHT,0,0,14,10);
        add(root,bBrake,76,78,Gravity.BOTTOM|Gravity.RIGHT,0,0,114,10);
        add(root,bDrift,88,42,Gravity.BOTTOM|Gravity.LEFT,16,0,0,116);
        gearButton=button("Reversa R");
        gearButton.setOnClickListener(v->changeGear());
        add(root,gearButton,80,38,Gravity.TOP|Gravity.RIGHT,0,94,16,0);
        setContentView(root);
        if(foreground){if(gpu!=null)gpu.onResume();surface.resumeLoop();}
    }
    private void showMap(){
        releaseControls();boolean resume=!surface.isPaused();if(resume)surface.togglePause();
        LinearLayout panel=new LinearLayout(this);panel.setOrientation(LinearLayout.VERTICAL);panel.setPadding(dp(12),dp(4),dp(12),dp(4));
        VelocityForestAtlas.MapView view=atlas.view(this,true);panel.addView(view,new LinearLayout.LayoutParams(-1,dp(170)));
        TextView destination=text(atlas.destination(),12);panel.addView(destination);
        LinearLayout choices=new LinearLayout(this);choices.setOrientation(LinearLayout.HORIZONTAL);
        for(int i=0;i<atlas.places.size();i++){final int selected=i;Button place=button(atlas.places.get(i).name);place.setOnClickListener(v->{atlas.select(selected);destination.setText(atlas.destination());});choices.addView(place,new LinearLayout.LayoutParams(dp(145),dp(36)));}
        HorizontalScrollView scroll=new HorizontalScrollView(this);scroll.addView(choices);panel.addView(scroll);
        AlertDialog dialog=new AlertDialog.Builder(this).setTitle("Mapa · Open Forest Road").setView(panel).setPositiveButton("Volver",(d,w)->{}).setNeutralButton("Quitar destino",(d,w)->atlas.select(-1)).create();
        dialog.setOnDismissListener(d->{atlas.release(view);if(resume&&surface.isPaused()&&!surface.is4KEnabled())surface.togglePause();});dialog.show();
        android.util.Log.i("ReverseVelocity","MAP_OPEN trails=4 places=6");
    }
    @Override public boolean onKeyDown(int key,KeyEvent event){
        if(key==KeyEvent.KEYCODE_P){if(event.getRepeatCount()==0)togglePause();return true;}
        if(key==KeyEvent.KEYCODE_G){if(event.getRepeatCount()==0)changeGear();return true;}
        if(key==KeyEvent.KEYCODE_C){if(surface!=null)surface.centerCamera();return true;}
        if(key==KeyEvent.KEYCODE_R){if(surface!=null){releaseControls();surface.reset();}if(pauseButton!=null)pauseButton.setText("Pausa");if(gearButton!=null)gearButton.setText("Reversa R");return true;}
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
