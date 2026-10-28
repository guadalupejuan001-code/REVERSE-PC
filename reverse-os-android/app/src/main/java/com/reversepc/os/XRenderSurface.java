package com.reversepc.os;

import android.content.Context;
import android.opengl.GLSurfaceView;
import java.util.concurrent.atomic.AtomicReference;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

/** Ether Render X CPU surfaces, presented by GLES. One replaceable frame slot. */
final class XRenderSurface extends GLSurfaceView implements GLSurfaceView.Renderer {
    private final AtomicReference<float[]> newest=new AtomicReference<>();
    private final java.util.function.Consumer<String> failure;
    private volatile String info="{\"frames\":0}";
    private volatile boolean released=false;
    private long nativeHandle;
    private float[] current;
    XRenderSurface(Context context,java.util.function.Consumer<String> failure){
        super(context);this.failure=failure;
        setEGLContextClientVersion(3);setEGLConfigChooser(8,8,8,8,0,0);
        setPreserveEGLContextOnPause(true);setRenderer(this);setRenderMode(RENDERMODE_WHEN_DIRTY);
    }
    void submit(float[] frame){
        if(released||frame==null||frame.length<16||frame.length>16+64*12)return;
        newest.set(frame);requestRender();
    }
    String info(){return info;}
    @Override public void onSurfaceCreated(GL10 unused,EGLConfig config){
        if(released)return;
        try{if(nativeHandle!=0)NativeRuntime.xRenderDestroy(nativeHandle,false);nativeHandle=NativeRuntime.xRenderCreate();}
        catch(Exception error){fail(error);}
    }
    @Override public void onSurfaceChanged(GL10 unused,int width,int height){
        if(released||nativeHandle==0)return;
        try{NativeRuntime.xRenderResize(nativeHandle,width,height);}
        catch(Exception error){fail(error);}
    }
    @Override public void onDrawFrame(GL10 unused){
        if(released||nativeHandle==0)return;
        float[] next=newest.getAndSet(null);if(next!=null)current=next;
        if(current==null)return;
        try{info=NativeRuntime.xRenderFrame(nativeHandle,current);}
        catch(Exception error){fail(error);}
    }
    private void fail(Exception error){
        info="{\"frames\":0,\"error\":true}";
        released=true;post(()->failure.accept("X Render: "+error.getMessage()));
        if(nativeHandle!=0){NativeRuntime.xRenderDestroy(nativeHandle,true);nativeHandle=0;}
    }
    void release(){
        released=true;newest.set(null);
        queueEvent(()->{if(nativeHandle!=0){NativeRuntime.xRenderDestroy(nativeHandle,true);nativeHandle=0;}current=null;});
    }
}
