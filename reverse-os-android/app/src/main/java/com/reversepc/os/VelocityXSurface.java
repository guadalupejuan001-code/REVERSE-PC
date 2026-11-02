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
    private final Hud hud;
    private final Paint paint=new Paint(Paint.FILTER_BITMAP_FLAG);
    private final Rect sourceRect=new Rect(),targetRect=new Rect();
    private final VelocityLoopLifecycle lifecycle,physicsLifecycle;
    private final AtomicBoolean resetRequested=new AtomicBoolean();
    private final AtomicBoolean repaintRequested=new AtomicBoolean(true);
    private volatile int input=4,cameraMode,paintId,carId,assistMode;
    // Packed yaw+elevation is read atomically by the XI render thread.
    private volatile int orbitPacked;
    private volatile boolean orbitDragging;
    private int orbitPointer=-1;
    private float orbitLastX,orbitLastY,orbitDownX,orbitDownY,lastTapX,lastTapY;
    private boolean orbitMoved;
    private long lastTapUptime;
    private final Object detailLock=new Object();
    private int quality=1;
    private boolean fixedDetail;
    private volatile int physicsHz;
    private volatile boolean paused;
    private volatile boolean reverseGear;
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
                        orbitPacked=0;
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
    void centerCamera(){orbitPacked=0;repaintRequested.set(true);}
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
        resetRequested.set(true);paused=false;reverseGear=false;
        repaintRequested.set(true);
    }
    boolean isReverseGear(){return reverseGear;}
    boolean isBrakePressed(){return (input&2)!=0;}
    boolean isAccelerating(){return (input&1)!=0;}
    boolean setReverseGear(boolean reverse){
        VelocityXiEngine.Snapshot s=game.current();
        // A stationary-only gear selector avoids reversing a moving drivetrain.
        if(s!=null&&s.speedCmps>25)return false;
        reverseGear=reverse;
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
        error="No se pudo continuar la carrera: "+thrown.getMessage();
        physicsLifecycle.fail();lifecycle.fail();
        hud.update(game.current(),paused,0,0,0,error);
        Log.e("ReverseVelocity","Race worker failed",thrown);
    }
    private void runPhysics(){
        long next=SystemClock.elapsedRealtimeNanos();
        long measuredFrom=next;int measuredSteps=0;
        try{
            while(physicsLifecycle.shouldRun()){
                if(resetRequested.getAndSet(false)){
                    game.step(0,0,1,0,false,true);next=SystemClock.elapsedRealtimeNanos();
                    measuredFrom=next;measuredSteps=0;
                }
                if(paused){
                    physicsHz=0;measuredFrom=SystemClock.elapsedRealtimeNanos();measuredSteps=0;
                    next=measuredFrom+20_000_000L;Thread.sleep(10);continue;
                }
                long now=SystemClock.elapsedRealtimeNanos(),wait=next-now;
                if(wait>0){Thread.sleep(Math.max(1L,wait/1_000_000L));continue;}
                int current=input;
                game.step(current&1,(current>>>1)&1,(current>>>2)&3,(current>>>4)&1,
                     (current&32)!=0,(current&64)!=0,reverseGear,false,assistMode);
                measuredSteps++;
                next+=20_000_000L;
                // Keep fixed XI steps; a slow host does not invent simulation ticks.
                now=SystemClock.elapsedRealtimeNanos();
                if(now-next>100_000_000L)next=now;
                if(now-measuredFrom>=1_000_000_000L){
                    physicsHz=(int)Math.round(measuredSteps*1_000_000_000.0/(now-measuredFrom));
                    Log.i("ReverseVelocity","PHYSICS_STATS steps="+measuredSteps+
                        " elapsedNanos="+(now-measuredFrom)+" physicsHz="+physicsHz);
                    measuredFrom=now;measuredSteps=0;
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
        final VelocityFrameReuse frameReuse=new VelocityFrameReuse();
        final VelocityFrameProfiler profiler=new VelocityFrameProfiler();
        try{
            while(lifecycle.shouldRun()){
                long begin=SystemClock.elapsedRealtimeNanos();
                final int selected;final boolean selectedFixed;
                synchronized(detailLock){selected=fixedDetail?2:Math.max(0,Math.min(2,quality));selectedFixed=fixedDetail;}
                int stride=selected==0?4:selected==1?2:1;
                int selectedCamera=cameraMode,selectedPaint=paintId,selectedCar=carId;
                int selectedOrbit=orbitPacked;
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
                            " physicsHz="+physicsHz+" fixedDetail="+selectedFixed+
                            " paused="+paused+
                            " backend="+(selected4K?"REgraphics_XI_4K_NATIVE":"REgraphics_XI_CPU")+
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
                // REgraphics rasteriza triángulos XI y emite XFS1. Android solo presenta píxeles.
                    VelocityXiEngine.Observation observation;
                    if(selected4K){
                        try{observation=game.observeNative4KFrame(selectedCamera,selectedPaint,selectedCar,
                            selectedYaw,selectedPitch);}
                        catch(Exception nativeFailure){
                            Log.w("ReverseVelocity","Native XI 4K unavailable on this device",nativeFailure);
                            native4K=false;
                            paused=pausedBeforePhoto;pausedBeforePhoto=false;
                            frameReuse.invalidate();
                            error="Foto 4K no disponible: "+nativeFailure.getMessage();
                            continue;
                        }
                    }else observation=game.observeFrame(stride,selectedCamera,selectedPaint,selectedCar,
                        selectedYaw,selectedPitch);
                    xiRenders++;
                    // If a camera, paint, resolution or 4K switch happened during
                    // this expensive XI render, do not publish an obsolete frame.
                    boolean stale=selectedCamera!=cameraMode||selectedPaint!=paintId||
                        selectedCar!=carId||selected4K!=native4K||selectedOrbit!=orbitPacked;
                    if(!selected4K){
                        synchronized(detailLock){
                            int active=fixedDetail?2:Math.max(0,Math.min(2,quality));
                            stale|=stride!=(active==0?4:active==1?2:1);
                        }
                    }
                    if(stale){
                        Log.i("ReverseVelocity","FRAME_DROPPED obsolete XI camera/material/profile");
                        continue;
                    }
                    RegraphicsFrame frame=observation.frame;
                    if(!lifecycle.shouldRun())break;
                    if(frame.width!=width||frame.height!=height||pixels==null){
                        width=frame.width;height=frame.height;pixels=new int[width*height];
                        if(image!=null)image.recycle();
                        image=Bitmap.createBitmap(width,height,Bitmap.Config.ARGB_8888);
                        sourceRect.set(0,0,width,height);
                    }
                    final long expandStart=System.nanoTime();
                    frame.present(pixels,width,height);
                    final long expandNanos=System.nanoTime()-expandStart;
                    final long bitmapStart=System.nanoTime();
                    image.setPixels(pixels,0,width,0,0,width,height);
                    final long bitmapNanos=System.nanoTime()-bitmapStart;
                    final long presentStart=System.nanoTime();
                    Canvas canvas=null;
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
                    final long presentNanos=System.nanoTime()-presentStart;
                    state=observation.state;
                    presented=canvas!=null;
                    if(presented)frameReuse.framePosted(state,selectedCamera,selectedPaint,stride,selected4K);
                    if(presented&&selected4K)
                        Log.i("ReverseVelocity","NATIVE_4K_FRAME_READY source=XI_XFB5 width="+
                            width+" height="+height+" pixels="+(width*height)+
                            " speed="+state.speedKmh()+" ticks="+state.ticks);
                if(presented&&!firstFramePosted){
                    firstFramePosted=true;
                    Log.i("ReverseVelocity","FRAME_READY "+width+"x"+height+
                        " speed="+state.speedKmh()+" ticks="+state.ticks+
                        " xCm="+state.xCm+" zCm="+state.zCm+" yaw4096="+state.yaw4096+
                        " camera="+selectedCamera+" paint="+selectedPaint+" car="+selectedCar);
                }
                if(presented)frames++;
                if(presented&&lastCameraOrbit!=selectedOrbit){
                    lastCameraOrbit=selectedOrbit;
                    Log.i("ReverseVelocity","ORBIT_FRAME yaw="+selectedYaw+
                        " pitch="+VelocityOrbitMath.pitch(selectedOrbit)+
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
                        " physicsHz="+physicsHz+" fixedDetail="+selectedFixed+" paused="+paused+
                        " backend="+(selected4K?"REgraphics_XI_4K_NATIVE":"REgraphics_XI_CPU")+
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
                synchronized(detailLock){
                    if(!native4K&&!fixedDetail&&!selectedFixed&&quality==selected&&cost>45_000_000L&&selected>0){
                        if(++slowFrames>=5){quality=selected-1;slowFrames=0;}
                    }else slowFrames=0;
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
