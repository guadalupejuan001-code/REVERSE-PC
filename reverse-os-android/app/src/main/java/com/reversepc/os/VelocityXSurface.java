package com.reversepc.os;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.SystemClock;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.MotionEvent;
import java.util.concurrent.atomic.AtomicBoolean;

/** Independent XI driving transactions and REgraphics observations. */
final class VelocityXSurface extends SurfaceView implements SurfaceHolder.Callback,Runnable {
    interface Hud {
        void update(VelocityXiEngine.Snapshot state,boolean paused,int fps,int width,int height,String error);
    }
    private final VelocityXiEngine game;
    private volatile VelocityGpuSurface gpu;
    private final VelocityChaseCamera chaseCamera=new VelocityChaseCamera();
    private volatile long manualCameraUntil;
    private volatile int displayedOrbit;
    void attachGpu(VelocityGpuSurface value){gpu=value;invalidateGpu();}
    void invalidateGpu(){repaintRequested.set(true);}
    String rendererLabel(){return gpu!=null&&gpu.available()?"XI · GPU":"XI · CPU";}
    private final Hud hud;
    private final Paint paint=new Paint(Paint.FILTER_BITMAP_FLAG);
    private final Rect sourceRect=new Rect(),targetRect=new Rect();
    private final VelocityLoopLifecycle lifecycle,physicsLifecycle;
    private final AtomicBoolean resetRequested=new AtomicBoolean();
    private final AtomicBoolean repaintRequested=new AtomicBoolean(true);
    private volatile int analogSteering=255;
    void steering(int value){analogSteering=value;}
    private volatile int input=4,cameraMode,paintId,carId,assistMode;
    // Packed yaw+elevation is read atomically by the XI render thread.
    private volatile int orbitPacked;
    private volatile boolean orbitDragging;
    private int orbitPointer=-1;
    private float orbitLastX,orbitLastY,orbitDownX,orbitDownY,lastTapX,lastTapY;
    private boolean orbitMoved;
    private long lastTapUptime;
    private final Object detailLock=new Object();
    private int quality=2;
    private int fastFrames;
    private boolean fixedDetail=true;
    private volatile int physicsHz;
    private volatile boolean paused;
    private final VelocityGearbox gearbox=new VelocityGearbox();
    private volatile boolean native4K;
    private volatile boolean pausedBeforePhoto;
    boolean is4KEnabled(){return native4K;}
    boolean isPaused(){return paused;}
    /**
     * A real XI 3840x2160 image is a photo mode, never a live racing preset.
     * Software raster takes hundreds of ms/frame on phones: pausing once means
     * we preserve the true native pixels without reducing driving to ~2 FPS.
     */
    synchronized boolean toggle4K(){
        if(!native4K){
            pausedBeforePhoto=paused;
            input=4;
            paused=true;
            physicsHz=0;
            native4K=true;
        }else {
            native4K=false;
            paused=pausedBeforePhoto;
            pausedBeforePhoto=false;
        }
        error="";
        repaintRequested.set(true);
        return native4K;
    }
    private volatile String error="";

    VelocityXSurface(Context context,VelocityXiEngine game,Hud hud){
        super(context);this.game=game;this.hud=hud;
        lifecycle=new VelocityLoopLifecycle(this);
        physicsLifecycle=new VelocityLoopLifecycle(this::runPhysics);
        getHolder().addCallback(this);setKeepScreenOn(true);
        setClickable(true);
        setContentDescription("Cámara 3D. Arrastra sobre el paisaje a izquierda o derecha para orbitar el auto, o verticalmente para subir y bajar la vista. Doble toque para recentrar.");
    }
    /** Touch the unoccupied 3D scene; overlay controls remain separate Views. */
    @Override public boolean onTouchEvent(MotionEvent event){
        final int action=event.getActionMasked();
        switch(action){
            case MotionEvent.ACTION_DOWN:
                orbitPacked=displayedOrbit;manualCameraUntil=SystemClock.elapsedRealtimeNanos()+2_600_000_000L;
                orbitPointer=event.getPointerId(0);
                orbitLastX=orbitDownX=event.getX(0);
                orbitLastY=orbitDownY=event.getY(0);
                orbitMoved=false;orbitDragging=true;
                return true;
            case MotionEvent.ACTION_POINTER_DOWN:
                return true; // Do not interpret a second finger as car steering.
            case MotionEvent.ACTION_MOVE: {
                int i=event.findPointerIndex(orbitPointer);
                if(i<0)return true;
                float x=event.getX(i),y=event.getY(i);
                if(Math.abs(x-orbitDownX)>8||Math.abs(y-orbitDownY)>8)
                    orbitMoved=true;
                final int newState=VelocityOrbitMath.drag(orbitPacked,
                    x-orbitLastX,y-orbitLastY,getWidth());
                orbitLastX=x;orbitLastY=y;
                manualCameraUntil=SystemClock.elapsedRealtimeNanos()+2_600_000_000L;
                if(newState!=orbitPacked){
                    orbitPacked=newState;
                    repaintRequested.set(true);
                }
                return true;
            }
            case MotionEvent.ACTION_POINTER_UP: {
                int id=event.getPointerId(event.getActionIndex());
                if(id==orbitPointer){
                    int other=event.getActionIndex()==0?1:0;
                    if(other<event.getPointerCount()){
                        orbitPointer=event.getPointerId(other);
                        orbitLastX=event.getX(other);orbitLastY=event.getY(other);
                    }else orbitPointer=-1;
                }
                return true;
            }
            case MotionEvent.ACTION_UP: {
                long now=SystemClock.uptimeMillis();
                float x=event.getX(),y=event.getY();
                if(!orbitMoved){
                    if(now-lastTapUptime<330 &&
                        Math.hypot(x-lastTapX,y-lastTapY)<getResources().getDisplayMetrics().density*45){
                        orbitPacked=0;manualCameraUntil=0;chaseCamera.reset();
                        repaintRequested.set(true);
                        lastTapUptime=0;
                    }else{
                        lastTapUptime=now;
                        lastTapX=x;lastTapY=y;
                    }
                }
                orbitPointer=-1;orbitDragging=false;
                Log.i("ReverseVelocity","ORBIT_INPUT yaw="+VelocityOrbitMath.yaw(orbitPacked)+
                    " pitch="+VelocityOrbitMath.pitch(orbitPacked)+" photo="+native4K);
                performClick();
                return true;
            }
            case MotionEvent.ACTION_CANCEL:
                orbitPointer=-1;orbitDragging=false;return true;
            default:return true;
        }
    }
    @Override public boolean performClick(){super.performClick();return true;}
    void centerCamera(){orbitPacked=0;manualCameraUntil=0;chaseCamera.reset();repaintRequested.set(true);}
    int cameraOrbit(){return orbitPacked;}

    void controls(int gas,int brake,int steer,boolean handbrake){
        controls(gas,brake,steer,handbrake,false,false);
    }
    void controls(int gas,int brake,int steer,boolean handbrake,boolean nitro,boolean jump){
        if(gas<0||gas>1||brake<0||brake>1||steer<0||steer>2)
            throw new IllegalArgumentException("Control fuera del protocolo XI");
        input=gas|(brake<<1)|(steer<<2)|(handbrake?16:0)|(nitro?32:0)|(jump?64:0);
    }
    void reset(){
        native4K=false;
        pausedBeforePhoto=false;
        input=4;
        resetRequested.set(true);paused=false;gearbox.reset();error="";
        repaintRequested.set(true);
        // Restart also recovers workers that stopped after a rejected XI step.
        physicsLifecycle.resume();lifecycle.resume();
    }
    boolean isReverseGear(){return gearbox.isReverse();}
    boolean isGearPending(){return gearbox.isPending();}
    boolean isReverseRequested(){return gearbox.requestedReverse();}
    boolean isBrakePressed(){return (input&2)!=0;}
    boolean isAccelerating(){return (input&1)!=0;}
    boolean setReverseGear(boolean reverse){
        VelocityXiEngine.Snapshot s=game.current();
        gearbox.request(reverse,s==null?0:s.speedCmps);
        Log.i("ReverseVelocity","GEAR_REQUEST reverse="+reverse+
            " pending="+gearbox.isPending()+" speed="+(s==null?0:s.speedCmps));
        return true;
    }
    boolean togglePause(){
        if(native4K)return paused; // Photo stays frozen until leaving 4K.
        paused=!paused;
        if(paused){physicsHz=0;controls(0,0,1,false);}
        return paused;
    }
    int cycleAssistMode(){
        assistMode=(assistMode+1)%3;
        Log.i("ReverseVelocity","ASSIST_MODE mode="+assistMode+" source=XI");
        return assistMode;
    }
    int assistMode(){return assistMode;}
    int cycleWorldTime(){
        int mode=(game.environmentMode()+1)%4;
        try{game.setEnvironmentMode(mode);repaintRequested.set(true);Log.i("ReverseVelocity","WORLD_TIME mode="+mode+" phase="+game.current().dayPhase+" ticks="+game.current().ticks);}
        catch(Exception failure){error="No se pudo cambiar la hora: "+failure.getMessage();return game.environmentMode();}
        return mode;
    }
    int cycleCamera(){cameraMode=(cameraMode+1)%3;return cameraMode;}
    int cyclePaint(){paintId=(paintId+1)%5;return paintId;}
    int selectedCar(){return carId;}
    void selectCar(int selection){
        if(selection<0||selection>2)throw new IllegalArgumentException("Vehículo XI desconocido");
        carId=selection;
        // Even a frozen 4K capture must update to the newly authored silhouette.
        repaintRequested.set(true);
    }
    boolean toggleSharpness(){
        synchronized(detailLock){
            fixedDetail=!fixedDetail;quality=fixedDetail?2:1;return fixedDetail;
        }
    }
    void resumeLoop(){error="";physicsHz=0;physicsLifecycle.resume();lifecycle.resume();}
    void pauseLoop(){
        orbitDragging=false;
        physicsLifecycle.pause();lifecycle.pause();
        physicsLifecycle.awaitStopped(250);lifecycle.awaitStopped(250);
    }
    void closeLoop(){
        physicsLifecycle.close();lifecycle.close();
        physicsLifecycle.awaitStopped(250);lifecycle.awaitStopped(250);
        game.close();
    }
    @Override public void surfaceCreated(SurfaceHolder holder){
        repaintRequested.set(true);
        boolean ready=holder.getSurface().isValid();
        physicsLifecycle.setSurfaceReady(ready);lifecycle.setSurfaceReady(ready);
    }
    @Override public void surfaceChanged(SurfaceHolder holder,int format,int w,int h){
        repaintRequested.set(true);
    }
    @Override public void surfaceDestroyed(SurfaceHolder holder){
        repaintRequested.set(true);
        physicsLifecycle.setSurfaceReady(false);lifecycle.setSurfaceReady(false);
        physicsLifecycle.awaitStopped(250);lifecycle.awaitStopped(250);
    }
    private void failed(Throwable thrown){
        physicsHz=0;
        error="No se pudo continuar la exploración: "+thrown.getMessage();
        physicsLifecycle.fail();lifecycle.fail();
        hud.update(game.current(),paused,0,0,0,error);
        Log.e("ReverseVelocity","Race worker failed",thrown);
    }
    private void runPhysics(){
        long next=SystemClock.elapsedRealtimeNanos();
        long measuredFrom=next;int measuredSteps=0;
        long stepNanos=0,maxStepNanos=0;
        boolean previousReverse=gearbox.isReverse();
        try{
            while(physicsLifecycle.shouldRun()){
                if(resetRequested.getAndSet(false)){
                    game.step(0,0,1,0,false,true);next=SystemClock.elapsedRealtimeNanos();
                    measuredFrom=next;measuredSteps=0;stepNanos=maxStepNanos=0;
                }
                if(paused){
                    physicsHz=0;measuredFrom=SystemClock.elapsedRealtimeNanos();measuredSteps=0;stepNanos=maxStepNanos=0;
                    next=measuredFrom+20_000_000L;Thread.sleep(10);continue;
                }
                long now=SystemClock.elapsedRealtimeNanos(),wait=next-now;
                if(wait>0){Thread.sleep(Math.max(1L,wait/1_000_000L));continue;}
                int current=gearbox.prepare(input,game.current().speedCmps);
                boolean reverse=(current&128)!=0;
                if(reverse!=previousReverse){
                    Log.i("ReverseVelocity","GEAR_APPLIED reverse="+reverse+
                        " ticks="+game.current().ticks);
                    previousReverse=reverse;
                }
                long stepStart=SystemClock.elapsedRealtimeNanos();
                game.step(current&1,(current>>>1)&1,(current>>>2)&3,(current>>>4)&1,
                     (current&32)!=0,(current&64)!=0,reverse,false,assistMode,analogSteering);
                long stepCost=SystemClock.elapsedRealtimeNanos()-stepStart;
                stepNanos+=stepCost;maxStepNanos=Math.max(maxStepNanos,stepCost);
                measuredSteps++;
                next+=20_000_000L;
                // Keep fixed XI steps; a slow host does not invent simulation ticks.
                now=SystemClock.elapsedRealtimeNanos();
                if(now-next>100_000_000L)next=now;
                if(now-measuredFrom>=1_000_000_000L){
                    physicsHz=(int)Math.round(measuredSteps*1_000_000_000.0/(now-measuredFrom));
                    Log.i("ReverseVelocity","PHYSICS_STATS steps="+measuredSteps+
                        " elapsedNanos="+(now-measuredFrom)+" physicsHz="+physicsHz+
                        " stepMeanMs="+(stepNanos/(measuredSteps*1_000_000.0))+
                        " stepMaxMs="+(maxStepNanos/1_000_000.0));
                    measuredFrom=now;measuredSteps=0;stepNanos=maxStepNanos=0;
                }
            }
        }catch(InterruptedException interrupted){
            physicsLifecycle.fail();lifecycle.fail();Thread.currentThread().interrupt();
        }
        catch(Throwable failure){if(physicsLifecycle.shouldRun())failed(failure);}
    }
    @Override public void run(){
        Bitmap image=null;int[] pixels=null;
        int width=0,height=0,frames=0,fps=0,slowFrames=0;
        long lastHud=0,lastFps=SystemClock.elapsedRealtimeNanos();
        boolean firstFramePosted=false;
        int cacheHits=0,xiRenders=0,lastCameraOrbit=Integer.MIN_VALUE;
        boolean previousGpu=false;
        final int[] gpuWidths={640,960,1280};
        int gpuLevel=1,gpuSlow=0,gpuFast=0;
        final VelocityFrameReuse frameReuse=new VelocityFrameReuse();
        final VelocityFrameProfiler profiler=new VelocityFrameProfiler();
        try{
            while(lifecycle.shouldRun()){
                long begin=SystemClock.elapsedRealtimeNanos();
                final int selected;final boolean selectedFixed;
                synchronized(detailLock){selected=fixedDetail?2:Math.max(0,Math.min(2,quality));selectedFixed=fixedDetail;}
                int stride=selected==0?4:selected==1?2:1;
                int selectedCamera=cameraMode,selectedPaint=paintId,selectedCar=carId;
                int manualOrbit=orbitPacked;
                VelocityXiEngine.Snapshot cameraState=game.current();
                int selectedOrbit=chaseCamera.update(manualOrbit,orbitDragging||begin<manualCameraUntil,
                    paused||native4K,cameraState.yaw4096,cameraState.speedCmps,cameraState.jumpHeightCm,gearbox.isReverse(),begin);
                displayedOrbit=selectedOrbit;
                final VelocityGpuSurface selectedGpuSurface=gpu;
                final boolean selectedGpu=selectedGpuSurface!=null&&selectedGpuSurface.available();
                if(selectedGpu!=previousGpu){frameReuse.invalidate();previousGpu=selectedGpu;}
                if(selectedOrbit!=lastCameraOrbit)frameReuse.invalidate();
                int selectedYaw=VelocityOrbitMath.yaw(selectedOrbit);
                int selectedPitch=VelocityOrbitMath.xiPitch(selectedOrbit);
                VelocityXiEngine.Snapshot state;
                boolean presented=false;
                boolean selected4K=native4K;
                if(repaintRequested.getAndSet(false))frameReuse.invalidate();
                VelocityXiEngine.Snapshot currentState=game.current();
                // Do not rasterize multiple 8.3M-pixel photos while dragging.
                // The final released angle receives one fresh native 4K frame.
                if(selected4K&&orbitDragging){Thread.sleep(35);continue;}
                if(frameReuse.canReuse(paused,currentState,selectedCamera,selectedPaint,stride,selected4K)){
                    // Static XI snapshot: leave the already-posted SurfaceView pixels
                    // untouched. In 4K this avoids all 8.3M fragments, packet copies,
                    // Bitmap upload and heat while paused. The HUD remains responsive.
                    cacheHits++;
                    long now=SystemClock.elapsedRealtimeNanos();
                    if(now-lastFps>=1_000_000_000L){
                        long elapsed=now-lastFps;
                        fps=(int)Math.round(frames*1_000_000_000.0/elapsed);
                        Log.i("ReverseVelocity","FRAME_STATS frames="+frames+
                            " elapsedNanos="+elapsed+" fps="+fps+" width="+width+
                            " height="+height+" ticks="+currentState.ticks+
                            " xCm="+currentState.xCm+" zCm="+currentState.zCm+" yaw4096="+currentState.yaw4096+
                            " speed="+currentState.speedCmps+
                            " reverse="+gearbox.isReverse()+
                            " physicsHz="+physicsHz+" fixedDetail="+selectedFixed+
                            " paused="+paused+
                            " backend="+(selectedGpu?"REgraphics_XI_GPU":selected4K?"REgraphics_XI_4K_NATIVE":"REgraphics_XI_NATIVE_LIVE")+
                            " cacheHits="+cacheHits+" xiRenders="+xiRenders);
                        String normal=profiler.drain(false),nativeTimes=profiler.drain(true);
                        if(!normal.isEmpty())Log.i("ReverseVelocity","FRAME_PIPELINE "+normal);
                        if(!nativeTimes.isEmpty())Log.i("ReverseVelocity","FRAME_PIPELINE "+nativeTimes);
                        frames=0;cacheHits=0;xiRenders=0;lastFps=now;
                    }
                    if(now-lastHud>=100_000_000L){
                        lastHud=now;hud.update(currentState,paused,fps,width,height,error);
                    }
                    Thread.sleep(70);
                    continue;
                }
                VelocityXiEngine.Observation observation;
                if(selectedGpu){
                    observation=game.observeGpuFrame(selectedCamera,selectedPaint,selectedCar,selectedYaw,selectedPitch);
                }else if(selected4K){
                    try{observation=game.observeNative4KFrame(selectedCamera,selectedPaint,selectedCar,selectedYaw,selectedPitch);}
                    catch(Exception nativeFailure){
                        native4K=false;paused=pausedBeforePhoto;pausedBeforePhoto=false;
                        frameReuse.invalidate();error="Foto 4K no disponible: "+nativeFailure.getMessage();continue;
                    }
                }else observation=game.observeFrame(stride,selectedCamera,selectedPaint,selectedCar,
                    selectedYaw,selectedPitch);
                xiRenders++;
                boolean stale=selectedCamera!=cameraMode||selectedPaint!=paintId||selectedCar!=carId||
                    selected4K!=native4K||manualOrbit!=orbitPacked;
                if(stale)continue;
                if(!lifecycle.shouldRun())break;
                long expandNanos=0,bitmapNanos=0,presentNanos=0;
                state=observation.state;
                if(selectedGpu){
                    long start=System.nanoTime();
                    try{
                        selectedGpuSurface.draw(observation.geometry,observation.colors,state,selectedYaw,
                            selected4K?3840:selectedFixed?1280:gpuWidths[gpuLevel]);
                    }catch(RuntimeException gpuFailure){
                        if(lifecycle.shouldRun()&&selectedGpuSurface.available())selectedGpuSurface.disable(gpuFailure);
                        frameReuse.invalidate();continue;
                    }
                    presentNanos=System.nanoTime()-start;
                    width=selectedGpuSurface.outputWidth();height=selectedGpuSurface.outputHeight();presented=true;
                }else{
                    RegraphicsFrame frame=observation.frame;
                    if(frame.width!=width||frame.height!=height||pixels==null||pixels.length!=frame.width*frame.height){
                        width=frame.width;height=frame.height;pixels=new int[width*height];
                        if(image!=null)image.recycle();image=Bitmap.createBitmap(width,height,Bitmap.Config.ARGB_8888);
                        sourceRect.set(0,0,width,height);
                    }
                    long start=System.nanoTime();frame.present(pixels,width,height);expandNanos=System.nanoTime()-start;
                    start=System.nanoTime();image.setPixels(pixels,0,width,0,0,width,height);bitmapNanos=System.nanoTime()-start;
                    start=System.nanoTime();Canvas canvas=null;
                    try{
                        canvas=getHolder().lockCanvas();
                        if(canvas!=null){
                            canvas.drawColor(0xff101a24);
                            float fit=Math.min((float)canvas.getWidth()/width,(float)canvas.getHeight()/height);
                            int shownWidth=Math.round(width*fit),shownHeight=Math.round(height*fit);
                            int left=(canvas.getWidth()-shownWidth)/2,top=(canvas.getHeight()-shownHeight)/2;
                            targetRect.set(left,top,left+shownWidth,top+shownHeight);
                            canvas.drawBitmap(image,sourceRect,targetRect,paint);
                        }
                    }finally{if(canvas!=null)getHolder().unlockCanvasAndPost(canvas);}
                    presentNanos=System.nanoTime()-start;presented=canvas!=null;
                }
                if(presented)frameReuse.framePosted(state,selectedCamera,selectedPaint,stride,selected4K);
                if(presented&&selected4K)Log.i("ReverseVelocity","NATIVE_4K_FRAME_READY source="+
                    (selectedGpu?"XI_XFG4_GLSL":"XI_XFB5")+" width="+width+" height="+height+
                    " pixels="+(width*height)+" speed="+state.speedKmh()+" ticks="+state.ticks);
                if(presented&&!firstFramePosted){
                    firstFramePosted=true;
                    Log.i("ReverseVelocity","FRAME_READY "+width+"x"+height+
                        " speed="+state.speedKmh()+" ticks="+state.ticks+
                        " xCm="+state.xCm+" zCm="+state.zCm+" yaw4096="+state.yaw4096+" yaw4096="+state.yaw4096+
                        " reverse="+gearbox.isReverse()+
                        " camera="+selectedCamera+" paint="+selectedPaint+" car="+selectedCar);
                }
                if(presented)frames++;
                if(presented&&lastCameraOrbit!=selectedOrbit){
                    lastCameraOrbit=selectedOrbit;
                    if(orbitDragging||begin-lastHud>=100_000_000L)Log.i("ReverseVelocity","ORBIT_FRAME yaw="+selectedYaw+
                        " pitch="+VelocityOrbitMath.pitch(selectedOrbit)+" auto="+(begin>=manualCameraUntil)+
                        " width="+width+" height="+height);
                }
                long now=SystemClock.elapsedRealtimeNanos();
                if(presented)profiler.record(selected4K,
                    observation.executeNanos,observation.decodeNanos,
                    expandNanos,bitmapNanos,presentNanos,now-begin,
                    observation.payloadBytes);
                if(now-lastFps>=1_000_000_000L){
                    long elapsed=now-lastFps;
                    fps=(int)Math.round(frames*1_000_000_000.0/elapsed);
                    Log.i("ReverseVelocity","FRAME_STATS frames="+frames+" elapsedNanos="+elapsed+
                        " fps="+fps+" width="+width+" height="+height+" ticks="+state.ticks+
                        " xCm="+state.xCm+" zCm="+state.zCm+" yaw4096="+state.yaw4096+
                        " speed="+state.speedCmps+
                        " reverse="+gearbox.isReverse()+
                        " physicsHz="+physicsHz+" fixedDetail="+selectedFixed+" paused="+paused+
                        " backend="+(selectedGpu?"REgraphics_XI_GPU":selected4K?"REgraphics_XI_4K_NATIVE":"REgraphics_XI_NATIVE_LIVE")+
                        " cacheHits="+cacheHits+" xiRenders="+xiRenders);
                    String normal=profiler.drain(false),nativeTimes=profiler.drain(true);
                    if(!normal.isEmpty())Log.i("ReverseVelocity","FRAME_PIPELINE "+normal);
                    if(!nativeTimes.isEmpty())Log.i("ReverseVelocity","FRAME_PIPELINE "+nativeTimes);
                    frames=0;cacheHits=0;xiRenders=0;lastFps=now;
                }
                if(now-lastHud>=100_000_000L){
                    lastHud=now;hud.update(state,paused,fps,width,height,error);
                }
                long cost=now-begin;
                // HD is explicit. Fluid mode scales only against measured GPU presentation,
                // never against the CPU cost of preparing the immutable XI scene.
                if(selectedGpu&&!selected4K&&!selectedFixed&&!paused&&presented){
                    if(presentNanos>30_000_000L){
                        gpuFast=0;
                        if(++gpuSlow>=4&&gpuLevel>0){gpuLevel--;gpuSlow=0;Log.i("ReverseVelocity","GPU_BUDGET width="+gpuWidths[gpuLevel]+" reason=gpu_present_cost");}
                    }else if(presentNanos<15_000_000L){
                        gpuSlow=0;
                        if(++gpuFast>=120&&gpuLevel<gpuWidths.length-1){gpuLevel++;gpuFast=0;}
                    }else{gpuSlow=0;gpuFast=0;}
                }
                synchronized(detailLock){
                    if(!selectedGpu&&!native4K&&!fixedDetail&&!selectedFixed&&quality==selected&&cost>45_000_000L&&selected>0){
                        if(++slowFrames>=5){quality=selected-1;slowFrames=0;}
                    }else {
                        slowFrames=0;
                        if(!selectedGpu&&!native4K&&!fixedDetail&&quality==selected&&cost<23_000_000L&&selected<2){
                            if(++fastFrames>=90){quality=selected+1;fastFrames=0;}
                        }else fastFrames=0;
                    }
                }
                long remaining=(paused?100_000_000L:33_333_333L)-cost;
                if(remaining>1_000_000L)Thread.sleep(remaining/1_000_000L);
            }
        }catch(InterruptedException interrupted){
            physicsLifecycle.fail();lifecycle.fail();Thread.currentThread().interrupt();
        }
        catch(Throwable failure){if(lifecycle.shouldRun())failed(failure);}
        finally{
            if(image!=null&&!image.isRecycled())image.recycle();
        }
    }
}
