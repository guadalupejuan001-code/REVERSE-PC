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
    private volatile VelocityGraphics graphics=VelocityGraphics.fromId(2);
    private volatile int physicsHz;
    private volatile boolean paused,stateTransfer,closed;
    private final VelocityGearbox gearbox=new VelocityGearbox();
    boolean isPaused(){return paused;}
    VelocityGraphics graphics(){return graphics;}
    void setGraphics(VelocityGraphics value){
        if(value==null)throw new IllegalArgumentException("Missing graphics profile");
        if(graphics==value)return;graphics=value;repaintRequested.set(true);
        Log.i("ReverseVelocity","GRAPHICS_REQUEST preset="+value.id+" width="+value.width+" height="+value.height+" fpsLimit="+value.maxFps);
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
                    " pitch="+VelocityOrbitMath.pitch(orbitPacked));
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
    int selectedCamera(){return cameraMode;}
    int worldTime(){return game.environmentMode();}
    void selectCar(int selection){
        if(selection<0||selection>2)throw new IllegalArgumentException("Vehículo XI desconocido");
        carId=selection;
        // A paused preview must also update the selected silhouette.
        repaintRequested.set(true);
    }
    void resumeLoop(){if(stateTransfer||closed)return;error="";physicsHz=0;physicsLifecycle.resume();lifecycle.resume();}
    void pauseLoop(){
        orbitDragging=false;
        physicsLifecycle.pause();lifecycle.pause();
        physicsLifecycle.awaitStopped(250);lifecycle.awaitStopped(250);
    }
    void closeLoop(){
        closed=true;
        physicsLifecycle.close();lifecycle.close();
        physicsLifecycle.awaitStopped(250);lifecycle.awaitStopped(250);
        game.close();
    }
    void beginStateTransfer(){
        if(stateTransfer||closed)throw new IllegalStateException("Hay una operación de estado en curso");
        stateTransfer=true;physicsLifecycle.pause();lifecycle.pause();
    }
    void finishStateTransfer(){stateTransfer=false;}
    private void awaitStateTransfer()throws Exception{
        if(!stateTransfer||closed)throw new IllegalStateException("El recorrido ya está cerrado");
        if(!physicsLifecycle.awaitStopped(4000)||!lifecycle.awaitStopped(4000))throw new IllegalStateException("El recorrido todavía está terminando un trabajo");
    }
    private VelocitySessionState viewState(){
        long now=SystemClock.elapsedRealtimeNanos();int[] gear=gearbox.checkpoint();
        return new VelocitySessionState(new int[]{graphics.id,cameraMode,paintId,carId,assistMode,orbitPacked,displayedOrbit,gear[0],gear[1],input,analogSteering,paused?1:0,resetRequested.get()?1:0,game.environmentMode()},
            chaseCamera.checkpoint(now),Math.max(0,Math.min(2_600_000_000L,manualCameraUntil-now)));
    }
    void saveState(java.io.File file)throws Exception{
        awaitStateTransfer();byte[] bytes=game.checkpointSpace(viewState().encode());
        android.util.AtomicFile target=new android.util.AtomicFile(file);java.io.FileOutputStream out=null;
        try{out=target.startWrite();out.write(bytes);out.getFD().sync();target.finishWrite(out);out=null;}
        finally{if(out!=null)target.failWrite(out);}
    }
    void loadState(java.io.File file)throws Exception{
        awaitStateTransfer();byte[] bytes;
        try(java.io.InputStream in=new android.util.AtomicFile(file).openRead();java.io.ByteArrayOutputStream out=new java.io.ByteArrayOutputStream()){
            byte[] scratch=new byte[8192];int n;
            while((n=in.read(scratch))>=0){if(out.size()+n>64*1024*1024)throw new IllegalArgumentException("El estado supera el presupuesto de lectura");out.write(scratch,0,n);}bytes=out.toByteArray();
        }
        VelocitySessionState stored=VelocitySessionState.decode(game.restoreSpace(bytes));int[] v=stored.values;
        graphics=VelocityGraphics.fromId(v[0]);cameraMode=v[1];paintId=v[2];carId=v[3];assistMode=v[4];orbitPacked=v[5];displayedOrbit=v[6];gearbox.restore(v[7],v[8]);
        input=v[9];analogSteering=v[10];paused=true;resetRequested.set(v[12]==1);
        long now=SystemClock.elapsedRealtimeNanos();manualCameraUntil=now+stored.manualRemaining;chaseCamera.restore(stored.camera,now);
        orbitDragging=false;repaintRequested.set(true);error="";
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
        int width=0,height=0,frames=0,fps=0;
        long lastHud=0,lastFps=SystemClock.elapsedRealtimeNanos();
        boolean firstFramePosted=false,previousGpu=false;
        int cacheHits=0,xiRenders=0,lastCameraOrbit=Integer.MIN_VALUE,lastPreset=-1;
        final VelocityFrameReuse frameReuse=new VelocityFrameReuse();
        final VelocityFrameProfiler profiler=new VelocityFrameProfiler();
        final VelocityFrameAhead<VelocityXiEngine.Observation> ahead=new VelocityFrameAhead<>();
        try{
            while(lifecycle.shouldRun()){
                long begin=SystemClock.elapsedRealtimeNanos();
                final VelocityGraphics selectedGraphics=graphics;
                final int stride=selectedGraphics.softwareStride;
                int selectedCamera=cameraMode,selectedPaint=paintId,selectedCar=carId;
                int manualOrbit=orbitPacked;
                VelocityXiEngine.Snapshot cameraState=game.current();
                int selectedOrbit=chaseCamera.update(manualOrbit,orbitDragging||begin<manualCameraUntil,
                    paused,cameraState.yaw4096,cameraState.speedCmps,cameraState.jumpHeightCm,gearbox.isReverse(),begin);
                displayedOrbit=selectedOrbit;
                final VelocityGpuSurface selectedGpuSurface=gpu;
                final boolean selectedGpu=selectedGpuSurface!=null&&selectedGpuSurface.available();
                final boolean overlapGpu=selectedGpu&&selectedGpuSurface.canOverlapCpu();
                if(selectedGpu!=previousGpu){
                    frameReuse.invalidate();ahead.invalidate();previousGpu=selectedGpu;lastPreset=-1;
                    if(overlapGpu)NativeRuntime.releaseThreadScratch();
                }
                if(selectedOrbit!=lastCameraOrbit||selectedGraphics.id!=lastPreset)frameReuse.invalidate();
                int selectedYaw=VelocityOrbitMath.yaw(selectedOrbit),selectedPitch=VelocityOrbitMath.xiPitch(selectedOrbit);
                final byte[] selectedViewState=viewState().encode();
                if(repaintRequested.getAndSet(false)){frameReuse.invalidate();ahead.invalidate();}
                VelocityXiEngine.Snapshot state=game.current();
                if(frameReuse.canReuse(paused,state,selectedCamera,selectedPaint,stride,false)){
                    cacheHits++;ahead.invalidate();
                }else{
                    VelocityXiEngine.Observation observation;
                    if(overlapGpu){
                        // Camera/profile/pause changes discard the prepared view. The
                        // native producer retains one coherent XI publication per frame.
                        String key=selectedCamera+":"+selectedPaint+":"+selectedCar+":"+selectedOrbit+":"+
                            selectedGraphics.id+":"+(paused?state.publication:-1);
                        observation=ahead.acquire(key,()->game.observeGpuFrame(selectedCamera,selectedPaint,selectedCar,selectedYaw,selectedPitch,selectedGraphics.id,selectedViewState));
                    }else{
                        ahead.invalidate();
                        observation=selectedGpu?game.observeGpuFrame(selectedCamera,selectedPaint,selectedCar,selectedYaw,selectedPitch,selectedGraphics.id,selectedViewState):
                            game.observeFrame(stride,selectedCamera,selectedPaint,selectedCar,selectedYaw,selectedPitch);
                    }
                    xiRenders++;
                    if(selectedCamera!=cameraMode||selectedPaint!=paintId||selectedCar!=carId||
                            selectedGraphics!=graphics||manualOrbit!=orbitPacked)continue;
                    if(!lifecycle.shouldRun())break;
                    long expandNanos=0,bitmapNanos=0,presentNanos=0;boolean presented=false;
                    state=observation.state;
                    if(selectedGpu){
                        long start=System.nanoTime();
                        try{selectedGpuSurface.draw(observation.geometry,observation.colors,state,selectedYaw,selectedGraphics);}
                        catch(RuntimeException gpuFailure){
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
                                canvas.drawColor(0xff101318);
                                float fit=Math.min((float)canvas.getWidth()/width,(float)canvas.getHeight()/height);
                                int sw=Math.round(width*fit),sh=Math.round(height*fit),left=(canvas.getWidth()-sw)/2,top=(canvas.getHeight()-sh)/2;
                                targetRect.set(left,top,left+sw,top+sh);canvas.drawBitmap(image,sourceRect,targetRect,paint);
                            }
                        }finally{if(canvas!=null)getHolder().unlockCanvasAndPost(canvas);}
                        presentNanos=System.nanoTime()-start;presented=canvas!=null;
                    }
                    if(presented){
                        frameReuse.framePosted(state,selectedCamera,selectedPaint,stride,false);frames++;
                        if(overlapGpu)profiler.recordOverlapped(observation.executeNanos,observation.decodeNanos,
                            presentNanos,SystemClock.elapsedRealtimeNanos()-begin,observation.payloadBytes);
                        else profiler.record(false,observation.executeNanos,observation.decodeNanos,
                            expandNanos,bitmapNanos,presentNanos,SystemClock.elapsedRealtimeNanos()-begin,observation.payloadBytes);
                        if(!firstFramePosted){
                            firstFramePosted=true;Log.i("ReverseVelocity","FRAME_READY "+width+"x"+height+
                                " speed="+state.speedKmh()+" ticks="+state.ticks+" xCm="+state.xCm+" zCm="+state.zCm+
                                " yaw4096="+state.yaw4096+" reverse="+gearbox.isReverse());
                        }
                        if(lastPreset!=selectedGraphics.id){
                            lastPreset=selectedGraphics.id;
                            Log.i("ReverseVelocity","GRAPHICS_FRAME preset="+lastPreset+" width="+width+" height="+height+
                                " shaderQuality="+selectedGraphics.id+" fpsLimit="+selectedGraphics.maxFps+" gpu="+selectedGpu);
                        }
                        if(lastCameraOrbit!=selectedOrbit){
                            lastCameraOrbit=selectedOrbit;Log.i("ReverseVelocity","ORBIT_FRAME yaw="+selectedYaw+
                                " pitch="+VelocityOrbitMath.pitch(selectedOrbit)+" width="+width+" height="+height);
                        }
                    }
                }
                long now=SystemClock.elapsedRealtimeNanos();
                if(now-lastFps>=1_000_000_000L){
                    long elapsed=now-lastFps;fps=(int)Math.round(frames*1_000_000_000.0/elapsed);
                    Log.i("ReverseVelocity","FRAME_STATS frames="+frames+" elapsedNanos="+elapsed+
                        " fps="+fps+" width="+width+" height="+height+" ticks="+state.ticks+
                        " xCm="+state.xCm+" zCm="+state.zCm+" yaw4096="+state.yaw4096+
                        " speed="+state.speedCmps+" reverse="+gearbox.isReverse()+" physicsHz="+physicsHz+
                        " fixedDetail=true paused="+paused+" preset="+selectedGraphics.id+
                        " backend="+(selectedGpu?"REgraphics_XI_GPU":"REgraphics_XI_NATIVE_LIVE")+
                        " cacheHits="+cacheHits+" xiRenders="+xiRenders);
                    String timings=profiler.drain(false);if(!timings.isEmpty())Log.i("ReverseVelocity","FRAME_PIPELINE "+timings);
                    if(selectedGpu)Log.i("ReverseVelocity","CPU_GPU_COORDINATION acquired="+ahead.acquired+
                        " discarded="+ahead.discarded+" prepareWaitNanos="+ahead.waitNanos+
                        " queued="+ahead.queued()+" maxQueued=1 overlap="+overlapGpu+" completion=after_swap");
                    frames=cacheHits=xiRenders=0;lastFps=now;
                }
                if(now-lastHud>=100_000_000L){lastHud=now;hud.update(state,paused,fps,width,height,error);}
                long budget=paused?70_000_000L:selectedGpu?selectedGraphics.frameBudgetNanos():Math.max(33_333_333L,selectedGraphics.frameBudgetNanos());
                long remaining=budget-(now-begin);if(remaining>1_000_000L)Thread.sleep(remaining/1_000_000L);
            }
        }catch(InterruptedException interrupted){physicsLifecycle.fail();lifecycle.fail();Thread.currentThread().interrupt();}
        catch(Throwable failure){if(lifecycle.shouldRun())failed(failure);}
        finally{ahead.close();if(image!=null&&!image.isRecycled())image.recycle();}
    }
}
