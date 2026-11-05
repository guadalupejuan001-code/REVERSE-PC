package com.reversepc.os;

import android.app.ActivityManager;
import android.content.Context;
import android.graphics.Bitmap;
import android.opengl.GLES30;
import android.opengl.GLSurfaceView;
import android.opengl.GLUtils;
import android.util.Log;
import android.view.View;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.security.MessageDigest;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;
import static android.opengl.GLES30.*;

/** REgraphics GPU backend. XI alone supplies every triangle and world state. */
final class VelocityGpuSurface extends GLSurfaceView implements GLSurfaceView.Renderer {
    private final Runnable invalidated;
    private final Object mailbox=new Object();
    private volatile boolean ready,failed,suspended;
    private Request queued,active;
    private int sceneProgram,postProgram,vao,vbo,paletteTexture,atlasTexture,photoTexture;
    private int framebuffer,colorTexture,depthBuffer,targetWidth,targetHeight;
    private int projectionU,aspectU,timeU,dayU,yawU,wetU,depthU,paletteU,atlasU;
    private int imageU,texelU,photoU,lampOriginU,lampDirectionU,lampPowerU;
    private final float[] lampFrame=new float[6];
    private volatile boolean firstFrame;
    private boolean hdVerified;
    private int lastFx=-1;
    private ByteBuffer photoReadback;
    private final FloatBuffer vertices=ByteBuffer.allocateDirect(RegraphicsGeometry.MAX_FACES*3*RegraphicsGeometry.FLOATS*4).order(ByteOrder.nativeOrder()).asFloatBuffer();
    private final ByteBuffer paletteBytes=ByteBuffer.allocateDirect(1024),atlasBytes=ByteBuffer.allocateDirect(2048);
    static final class Request {
        final RegraphicsGeometry geometry;final Bitmap photo;final int[] palette;
        final VelocityXiEngine.Snapshot state;final int yaw,width;
        final CountDownLatch done=new CountDownLatch(1);volatile RuntimeException error;
        Request(RegraphicsGeometry g,Bitmap photo,int[] palette,VelocityXiEngine.Snapshot s,int yaw,int width){this.geometry=g;this.photo=photo;this.palette=palette;state=s;this.yaw=yaw;this.width=width;}
    }
    static boolean supported(Context context){
        ActivityManager manager=(ActivityManager)context.getSystemService(Context.ACTIVITY_SERVICE);
        return manager!=null&&manager.getDeviceConfigurationInfo().reqGlEsVersion>=0x30000;
    }
    VelocityGpuSurface(Context context,Runnable invalidated){
        super(context);this.invalidated=invalidated;
        setEGLContextClientVersion(3);setEGLConfigChooser(8,8,8,8,24,0);
        setPreserveEGLContextOnPause(true);setZOrderMediaOverlay(true);
        setRenderer(this);setRenderMode(RENDERMODE_WHEN_DIRTY);
        setClickable(true);
        setContentDescription("Cámara 3D. Arrastra para inspeccionar el coche; vuelve automáticamente al conducir.");
    }
    boolean hasPresentedFrame(){return firstFrame;}
    boolean available(){return ready&&!failed&&!suspended;}
    void disable(Throwable why){
        failed=true;ready=false;cancel("GPU unavailable");
        Log.w("ReverseVelocity","GPU_FALLBACK software=REgraphics_XI reason="+why);
        post(()->setVisibility(View.GONE));invalidated.run();
    }
    private void cancel(String why){synchronized(mailbox){for(Request r:new Request[]{queued,active})if(r!=null){r.error=new IllegalStateException(why);r.done.countDown();}queued=null;}}
    @Override public void onPause(){suspended=true;ready=false;cancel("GPU suspended");super.onPause();}
    @Override public void onResume(){suspended=false;super.onResume();invalidated.run();requestRender();}
    void draw(RegraphicsGeometry geometry,int[] palette,VelocityXiEngine.Snapshot state,int yaw,int width)throws InterruptedException{
        submit(new Request(geometry,null,palette,state,yaw,width));
    }
    void photo(Bitmap bitmap,VelocityXiEngine.Snapshot state)throws InterruptedException{
        submit(new Request(null,bitmap,null,state,0,bitmap.getWidth()));
    }
    private void submit(Request request)throws InterruptedException{
        if(!available())throw new IllegalStateException("GPU surface is not ready");
        synchronized(mailbox){if(queued!=null)throw new IllegalStateException("GPU mailbox already occupied");queued=request;}
        requestRender();
        if(!request.done.await(request.width==3840||!firstFrame?15:5,TimeUnit.SECONDS))throw new IllegalStateException("GPU frame timed out");
        if(request.error!=null)throw request.error;
    }
    private String asset(String name){
        try(InputStream in=getContext().getAssets().open("velocity/"+name);ByteArrayOutputStream out=new ByteArrayOutputStream()){
            byte[] b=new byte[4096];int n;while((n=in.read(b))>=0){if(out.size()+n>65536)throw new IllegalStateException("Shader source budget");out.write(b,0,n);}return out.toString("UTF-8");
        }catch(Exception error){throw new IllegalStateException("REgraphics shader missing: "+name,error);}
    }
    private int shader(int kind,String source){int shader=glCreateShader(kind);glShaderSource(shader,source);glCompileShader(shader);int[] ok={0};glGetShaderiv(shader,GL_COMPILE_STATUS,ok,0);if(ok[0]==0){String why=glGetShaderInfoLog(shader);glDeleteShader(shader);throw new IllegalStateException(why);}return shader;}
    private int program(String vertex,String fragment){int v=shader(GL_VERTEX_SHADER,asset(vertex)),f=shader(GL_FRAGMENT_SHADER,asset(fragment)),p=glCreateProgram();try{glAttachShader(p,v);glAttachShader(p,f);glLinkProgram(p);int[] ok={0};glGetProgramiv(p,GL_LINK_STATUS,ok,0);if(ok[0]==0)throw new IllegalStateException(glGetProgramInfoLog(p));return p;}finally{glDeleteShader(v);glDeleteShader(f);}}
    private static void checked(String stage){int error=glGetError();if(error!=GL_NO_ERROR)throw new IllegalStateException(stage+" GLES 0x"+Integer.toHexString(error));}
    private static int uniform(int p,String name){int n=glGetUniformLocation(p,name);if(n<0)throw new IllegalStateException("Missing shader uniform "+name);return n;}
    private static int texture(){int[] id={0};glGenTextures(1,id,0);glBindTexture(GL_TEXTURE_2D,id[0]);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);return id[0];}
    @Override public void onSurfaceCreated(GL10 ignored,EGLConfig config){
        ready=false;firstFrame=false;hdVerified=false;framebuffer=colorTexture=depthBuffer=0;targetWidth=targetHeight=0;
        try{
            sceneProgram=program("gpu-scene.vert","gpu-scene.frag");postProgram=program("gpu-post.vert","gpu-post.frag");
            projectionU=uniform(sceneProgram,"uProjection");aspectU=uniform(sceneProgram,"uAspect");timeU=uniform(sceneProgram,"uTime");dayU=uniform(sceneProgram,"uDay");yawU=uniform(sceneProgram,"uSunDirection");wetU=uniform(sceneProgram,"uWet");depthU=uniform(sceneProgram,"uWaterDepth");paletteU=uniform(sceneProgram,"uPalette");atlasU=uniform(sceneProgram,"uAtlas");
            lampOriginU=uniform(sceneProgram,"uLampOrigin");lampDirectionU=uniform(sceneProgram,"uLampDirection");lampPowerU=uniform(sceneProgram,"uLampPower");
            imageU=uniform(postProgram,"uImage");texelU=uniform(postProgram,"uTexel");photoU=uniform(postProgram,"uPhoto");
            paletteTexture=texture();glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,256,1,0,GL_RGBA,GL_UNSIGNED_BYTE,null);
            atlasTexture=texture();glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);glTexImage2D(GL_TEXTURE_2D,0,GL_R8,128,16,0,GL_RED,GL_UNSIGNED_BYTE,null);
            photoTexture=texture();int[] id={0};glGenVertexArrays(1,id,0);vao=id[0];glBindVertexArray(vao);glGenBuffers(1,id,0);vbo=id[0];glBindBuffer(GL_ARRAY_BUFFER,vbo);glBufferData(GL_ARRAY_BUFFER,vertices.capacity()*4,null,GL_DYNAMIC_DRAW);
            int stride=RegraphicsGeometry.FLOATS*4;int[] sizes={3,2,1,4,1},offsets={0,3,5,6,10};
            for(int i=0;i<5;i++){glEnableVertexAttribArray(i);glVertexAttribPointer(i,sizes[i],GL_FLOAT,false,stride,offsets[i]*4);}glBindVertexArray(0);
            glDisable(GL_CULL_FACE);checked("GPU initialization");failed=false;
            Log.i("ReverseVelocity","GPU_SHADERS_READY owner=REgraphics geometry=XI_XFG4 renderer="+glGetString(GL_RENDERER));
        }catch(RuntimeException error){disable(error);}
    }
    @Override public void onSurfaceChanged(GL10 ignored,int w,int h){if(!failed){ready=true;invalidated.run();}}
    private void target(int w,int h){
        if(framebuffer!=0&&w==targetWidth&&h==targetHeight)return;
        int[] id={0};if(framebuffer!=0){glDeleteFramebuffers(1,new int[]{framebuffer},0);glDeleteTextures(1,new int[]{colorTexture},0);glDeleteRenderbuffers(1,new int[]{depthBuffer},0);}
        colorTexture=texture();glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,w,h,0,GL_RGBA,GL_UNSIGNED_BYTE,null);
        glGenRenderbuffers(1,id,0);depthBuffer=id[0];glBindRenderbuffer(GL_RENDERBUFFER,depthBuffer);glRenderbufferStorage(GL_RENDERBUFFER,GL_DEPTH_COMPONENT24,w,h);
        glGenFramebuffers(1,id,0);framebuffer=id[0];glBindFramebuffer(GL_FRAMEBUFFER,framebuffer);glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,colorTexture,0);glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,GL_RENDERBUFFER,depthBuffer);
        if(glCheckFramebufferStatus(GL_FRAMEBUFFER)!=GL_FRAMEBUFFER_COMPLETE)throw new IllegalStateException("REgraphics framebuffer incomplete");targetWidth=w;targetHeight=h;checked("GPU target");
    }
    @Override public void onDrawFrame(GL10 ignored){
        if(failed||suspended)return;
        Request r;synchronized(mailbox){r=queued;queued=null;active=r;}
        if(!ready){ready=true;invalidated.run();}
        if(r==null){glBindFramebuffer(GL_FRAMEBUFFER,0);glViewport(0,0,getWidth(),getHeight());glClearColor(.025f,.045f,.06f,1);glClear(GL_COLOR_BUFFER_BIT);if(colorTexture!=0)post(colorTexture,targetWidth,targetHeight,false);return;}
        try{
            if(r.geometry!=null)scene(r);else image(r);
            checked("REgraphics GPU frame");
            // GLSurfaceView swaps after onDrawFrame. Its next queued event runs
            // after that swap, so the caller only marks an actually posted view.
            queueEvent(()->{if(!firstFrame&&r.geometry!=null){firstFrame=true;Log.i("ReverseVelocity","GPU_FRAME_READY source=XI_XFG4 shaders=REgraphics faces="+r.geometry.faces+" width="+targetWidth+" height="+targetHeight);}r.done.countDown();synchronized(mailbox){if(active==r)active=null;}});
        }catch(RuntimeException error){r.error=error;r.done.countDown();disable(error);}
    }
    private void scene(Request r){
        boolean nativePhoto=r.width==3840;
        int w=nativePhoto?3840:Math.max(320,Math.min(1280,r.width)),h=nativePhoto?2160:w==1280?720:Math.max(360,Math.round(w*(float)getHeight()/Math.max(1,getWidth())));
        target(w,h);glBindFramebuffer(GL_FRAMEBUFFER,framebuffer);glViewport(0,0,w,h);glDepthMask(true);glClearColor(.08f,.12f,.14f,1);glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
        RegraphicsGeometry g=r.geometry;g.vertices(vertices);
        int fx=(r.state.nitroActive?1:0)|(r.state.airPulse>0?2:0)|(r.state.waterDepthCm>0?4:0);
        if(fx!=lastFx){lastFx=fx;Log.i("ReverseVelocity","GPU_FX_STATE nitro="+r.state.nitroActive+" air="+(r.state.airPulse>0)+" waterDepth="+r.state.waterDepthCm+" emittedNitro="+g.categoryFaces(5)+" emittedAir="+g.categoryFaces(4));}
        glBindVertexArray(vao);glBindBuffer(GL_ARRAY_BUFFER,vbo);glBufferSubData(GL_ARRAY_BUFFER,0,vertices.remaining()*4,vertices);
        glUseProgram(sceneProgram);boolean lamp=g.lightFrame(lampFrame);glUniform3f(lampOriginU,lampFrame[0],lampFrame[1],lampFrame[2]);glUniform3f(lampDirectionU,lampFrame[3]-lampFrame[0],lampFrame[4]-lampFrame[1],lampFrame[5]-lampFrame[2]);glUniform1f(lampPowerU,lamp?(r.state.ambientMode==0?0:r.state.ambientMode==1?.6f:1):0);glUniform2f(projectionU,g.width,g.height);glUniform1f(aspectU,(float)w/h);glUniform1f(timeU,r.state.ticks*.02f);glUniform1f(dayU,r.state.ambientMode==0?1:r.state.ambientMode==1?.48f:.12f);double sunAngle=(r.state.yaw4096+r.yaw)*(Math.PI/2048);float sunCos=(float)Math.cos(sunAngle),sunSin=(float)Math.sin(sunAngle),sunNorm=(float)(1/Math.sqrt(1.1525));glUniform3f(yawU,(-.55f*sunCos+.38f*sunSin)*sunNorm,.84f*sunNorm,(-.55f*sunSin-.38f*sunCos)*sunNorm);glUniform1f(wetU,r.state.wetness/1000f);glUniform1f(depthU,r.state.waterDepthCm);
        paletteBytes.clear();for(int c:r.palette)paletteBytes.put((byte)(c>>16)).put((byte)(c>>8)).put((byte)c).put((byte)255);paletteBytes.flip();glActiveTexture(GL_TEXTURE0);glBindTexture(GL_TEXTURE_2D,paletteTexture);glTexSubImage2D(GL_TEXTURE_2D,0,0,0,256,1,GL_RGBA,GL_UNSIGNED_BYTE,paletteBytes);glUniform1i(paletteU,0);
        atlasBytes.clear();for(int y=0;y<16;y++)for(int tile=0;tile<8;tile++)for(int x=0;x<16;x++)atlasBytes.put(g.bytes[16+tile*256+y*16+x]);atlasBytes.flip();glActiveTexture(GL_TEXTURE1);glBindTexture(GL_TEXTURE_2D,atlasTexture);glTexSubImage2D(GL_TEXTURE_2D,0,0,0,128,16,GL_RED,GL_UNSIGNED_BYTE,atlasBytes);glUniform1i(atlasU,1);
        glDisable(GL_DEPTH_TEST);glDepthMask(false);glDisable(GL_BLEND);glDrawArrays(GL_TRIANGLES,g.starts[0],g.counts[0]);
        glEnable(GL_DEPTH_TEST);glDepthFunc(GL_LEQUAL);glDepthMask(true);glDrawArrays(GL_TRIANGLES,g.starts[1],g.counts[1]);
        glDepthMask(false);glEnable(GL_BLEND);glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);glDrawArrays(GL_TRIANGLES,g.starts[2],g.counts[2]);
        glBlendFunc(GL_SRC_ALPHA,GL_ONE);glDrawArrays(GL_TRIANGLES,g.starts[3],g.counts[3]);
        glDepthMask(true);glDisable(GL_BLEND);glDisable(GL_DEPTH_TEST);glBindVertexArray(0);
        if(nativePhoto||(!hdVerified&&w==1280&&h==720)){
            if(photoReadback==null||photoReadback.capacity()<w*h*4)photoReadback=ByteBuffer.allocateDirect(w*h*4);
            photoReadback.clear();photoReadback.limit(w*h*4);glReadPixels(0,0,w,h,GL_RGBA,GL_UNSIGNED_BYTE,photoReadback);checked("GPU 4K readback");photoReadback.rewind();
            try{MessageDigest digest=MessageDigest.getInstance("SHA-256");digest.update(photoReadback);StringBuilder hash=new StringBuilder();for(byte b:digest.digest())hash.append(String.format(java.util.Locale.ROOT,"%02x",b&255));Log.i("ReverseVelocity",(nativePhoto?"GPU_NATIVE_4K_PIXELS":"GPU_HD_PIXELS")+" source=XI_XFG4_GLSL width="+w+" height="+h+" pixels="+(w*h)+" sha256="+hash);}
            catch(Exception error){throw new IllegalStateException("GPU pixel verification failed",error);}
            if(!nativePhoto)hdVerified=true;
        }
        glBindFramebuffer(GL_FRAMEBUFFER,0);glViewport(0,0,getWidth(),getHeight());
        if(nativePhoto||w==1280){float fit=Math.min((float)getWidth()/w,(float)getHeight()/h);int shownW=Math.round(w*fit),shownH=Math.round(h*fit);glClearColor(.025f,.04f,.06f,1);glClear(GL_COLOR_BUFFER_BIT);glViewport((getWidth()-shownW)/2,(getHeight()-shownH)/2,shownW,shownH);}
        post(colorTexture,w,h,false);
    }
    private void image(Request r){
        if(r.photo==null||r.photo.isRecycled())throw new IllegalStateException("Photo bitmap unavailable");
        glActiveTexture(GL_TEXTURE0);glBindTexture(GL_TEXTURE_2D,photoTexture);GLUtils.texImage2D(GL_TEXTURE_2D,0,r.photo,0);
        glBindFramebuffer(GL_FRAMEBUFFER,0);glDisable(GL_DEPTH_TEST);glDisable(GL_BLEND);glBindVertexArray(0);glViewport(0,0,getWidth(),getHeight());glClearColor(.025f,.04f,.06f,1);glClear(GL_COLOR_BUFFER_BIT);
        float fit=Math.min((float)getWidth()/r.photo.getWidth(),(float)getHeight()/r.photo.getHeight());int w=Math.round(r.photo.getWidth()*fit),h=Math.round(r.photo.getHeight()*fit);glViewport((getWidth()-w)/2,(getHeight()-h)/2,w,h);post(photoTexture,r.photo.getWidth(),r.photo.getHeight(),true);
    }
    private void post(int texture,int w,int h,boolean photo){glUseProgram(postProgram);glActiveTexture(GL_TEXTURE0);glBindTexture(GL_TEXTURE_2D,texture);glUniform1i(imageU,0);glUniform2f(texelU,1f/w,1f/h);glUniform1i(photoU,photo?1:0);glDrawArrays(GL_TRIANGLES,0,3);}
    int outputWidth(){return targetWidth;}int outputHeight(){return targetHeight;}
}
