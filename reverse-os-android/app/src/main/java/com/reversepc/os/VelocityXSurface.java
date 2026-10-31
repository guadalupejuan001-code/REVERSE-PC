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
    private volatile int input=4,cameraMode,paintId;
    private final Object detailLock=new Object();
    private int quality=1;
    private boolean fixedDetail;
    private volatile int physicsHz;
    private volatile boolean paused;
    private volatile boolean ultra4K;
    private volatile String error="";

    VelocityXSurface(Context context,VelocityXiEngine game,Hud hud){
        super(context);this.game=game;this.hud=hud;
        lifecycle=new VelocityLoopLifecycle(this);
        physicsLifecycle=new VelocityLoopLifecycle(this::runPhysics);
        getHolder().addCallback(this);setKeepScreenOn(true);
    }
    void controls(int gas,int brake,int steer,boolean handbrake){
        if(gas<0||gas>1||brake<0||brake>1||steer<0||steer>2)
            throw new IllegalArgumentException("Control fuera del protocolo XI");
        input=gas|(brake<<1)|(steer<<2)|(handbrake?16:0);
    }
    void reset(){resetRequested.set(true);paused=false;}
    boolean togglePause(){paused=!paused;if(paused){physicsHz=0;controls(0,0,1,false);}return paused;}
    int cycleCamera(){cameraMode=(cameraMode+1)%3;return cameraMode;}
    int cyclePaint(){paintId=(paintId+1)%5;return paintId;}
    boolean toggle4K(){
        ultra4K=!ultra4K;
        return ultra4K;
    }
    boolean toggleSharpness(){
        synchronized(detailLock){
            fixedDetail=!fixedDetail;quality=fixedDetail?2:1;return fixedDetail;
        }
    }
    void resumeLoop(){error="";physicsHz=0;physicsLifecycle.resume();lifecycle.resume();}
    void pauseLoop(){
        physicsLifecycle.pause();lifecycle.pause();
        physicsLifecycle.awaitStopped(250);lifecycle.awaitStopped(250);
    }
    void closeLoop(){
        physicsLifecycle.close();lifecycle.close();
        physicsLifecycle.awaitStopped(250);lifecycle.awaitStopped(250);
    }
    @Override public void surfaceCreated(SurfaceHolder holder){
        boolean ready=holder.getSurface().isValid();
        physicsLifecycle.setSurfaceReady(ready);lifecycle.setSurfaceReady(ready);
    }
    @Override public void surfaceChanged(SurfaceHolder holder,int format,int w,int h){}
    @Override public void surfaceDestroyed(SurfaceHolder holder){
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
                    game.step(0,0,1,0,true);next=SystemClock.elapsedRealtimeNanos();
                    measuredFrom=next;measuredSteps=0;
                }
                if(paused){
                    physicsHz=0;measuredFrom=SystemClock.elapsedRealtimeNanos();measuredSteps=0;
                    next=measuredFrom+20_000_000L;Thread.sleep(10);continue;
                }
                long now=SystemClock.elapsedRealtimeNanos(),wait=next-now;
                if(wait>0){Thread.sleep(Math.max(1L,wait/1_000_000L));continue;}
                int current=input;
                game.step(current&1,(current>>>1)&1,(current>>>2)&3,(current>>>4)&1,false);
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
        boolean firstFramePosted=false,firstGpuFramePosted=false;
        VelocityGpuPresenter gpu=null;
        try{
            while(lifecycle.shouldRun()){
                long begin=SystemClock.elapsedRealtimeNanos();
                final int selected;final boolean selectedFixed;
                synchronized(detailLock){selected=fixedDetail?2:Math.max(0,Math.min(2,quality));selectedFixed=fixedDetail;}
                int stride=selected==0?4:selected==1?2:1;
                int selectedCamera=cameraMode,selectedPaint=paintId;
                VelocityXiEngine.Snapshot state;
                boolean presented=false;
                boolean requestedGPU=ultra4K;
                if(requestedGPU){
                    try{
                        if(gpu==null)gpu=new VelocityGpuPresenter(getHolder().getSurface(),game.gpuPalette());
                        VelocityXiEngine.GpuObservation observed=game.observe4kFrame(selectedCamera,selectedPaint);
                        if(!lifecycle.shouldRun())break;
                        gpu.render(observed.frame);
                        width=gpu.width();height=gpu.height();state=observed.state;
                        presented=true;
                        if(!firstGpuFramePosted){
                            firstGpuFramePosted=true;
                            Log.i("ReverseVelocity","GPU_FRAME_READY source=3840x2160"+
                                " internal="+width+"x"+height+" native4K="+gpu.isNative4K()+
                                " faces="+observed.frame.faces+
                                " speed="+state.speedKmh()+" ticks="+state.ticks+
                                " camera="+selectedCamera+" paint="+selectedPaint);
                        }
                    }catch(RuntimeException failure){
                        Log.w("ReverseVelocity","4K mode unavailable, returning to XI CPU renderer",failure);
                        ultra4K=false;
                        if(gpu!=null){gpu.close();gpu=null;}
                        error="Modo 4K no disponible en este dispositivo";
                        width=0;height=0;continue;
                    }
                }else{
                    if(gpu!=null){
                        gpu.close();gpu=null;
                        if(image!=null){image.recycle();image=null;}
                        pixels=null;width=0;height=0;
                    }
                    VelocityXiEngine.Observation observation=game.observeFrame(stride,selectedCamera,selectedPaint);
                    RegraphicsFrame frame=observation.frame;
                    if(!lifecycle.shouldRun())break;
                    if(frame.width!=width||frame.height!=height||pixels==null){
                        width=frame.width;height=frame.height;pixels=new int[width*height];
                        if(image!=null)image.recycle();
                        image=Bitmap.createBitmap(width,height,Bitmap.Config.ARGB_8888);
                        sourceRect.set(0,0,width,height);
                    }
                    frame.present(pixels,width,height);
                    image.setPixels(pixels,0,width,0,0,width,height);
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
                    state=observation.state;
                    presented=canvas!=null;
                }
                if(presented&&!requestedGPU&&!firstFramePosted){
                    firstFramePosted=true;
                    Log.i("ReverseVelocity","FRAME_READY "+width+"x"+height+
                        " speed="+state.speedKmh()+" ticks="+state.ticks+
                        " xCm="+state.xCm+" zCm="+state.zCm+" yaw4096="+state.yaw4096+
                        " camera="+selectedCamera+" paint="+selectedPaint);
                }
                if(presented)frames++;
                long now=SystemClock.elapsedRealtimeNanos();
                if(now-lastFps>=1_000_000_000L){
                    long elapsed=now-lastFps;
                    fps=(int)Math.round(frames*1_000_000_000.0/elapsed);
                    Log.i("ReverseVelocity","FRAME_STATS frames="+frames+" elapsedNanos="+elapsed+
                        " fps="+fps+" width="+width+" height="+height+" ticks="+state.ticks+
                        " physicsHz="+physicsHz+" fixedDetail="+selectedFixed+" paused="+paused+
                        " backend="+(requestedGPU?"GLES3":"XI_CPU"));
                    frames=0;lastFps=now;
                }
                if(now-lastHud>=100_000_000L){
                    lastHud=now;hud.update(state,paused,fps,width,height,error);
                }
                long cost=now-begin;
                synchronized(detailLock){
                    if(!fixedDetail&&!selectedFixed&&quality==selected&&cost>45_000_000L&&selected>0){
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
            if(gpu!=null)gpu.close();
            if(image!=null&&!image.isRecycled())image.recycle();
        }
    }
}
