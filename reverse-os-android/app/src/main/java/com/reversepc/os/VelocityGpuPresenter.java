package com.reversepc.os;

import android.graphics.Bitmap;
import android.opengl.EGL14;
import android.opengl.EGLConfig;
import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLSurface;
import android.opengl.GLES30;
import android.util.Log;
import android.view.Surface;

import java.io.File;
import java.io.FileOutputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * REgraphics GLES3 presentation of XI's captured XFG4 triangle stream.
 * No vehicle geometry, road equations, physics or lighting are invented here.
 *
 * Native 4K is a bounded opt-in FBO. 1080p/720p are honest fallback resolutions
 * if the GPU cannot allocate the real 3840x2160 render target.
 */
final class VelocityGpuPresenter implements AutoCloseable {
    static final int TARGET_W=3840,TARGET_H=2160;
    private static final int EGL_ES3_BIT=0x0040,VERTEX_BYTES=40;
    private static final String VERTEX_SHADER=VelocityMaterialShader.VERTEX;
    private static final String FRAGMENT_SHADER=VelocityMaterialShader.FRAGMENT;

    private EGLDisplay display=EGL14.EGL_NO_DISPLAY;
    private EGLContext context=EGL14.EGL_NO_CONTEXT;
    private EGLSurface window=EGL14.EGL_NO_SURFACE;
    private int program,vbo,vao,tileTexture,paletteTexture,framebuffer,colorTexture,depthBuffer;
    private int internalW,internalH;
    private int[] palette;
    private boolean textureAtlasUploaded;
    private final byte[] cachedTileAtlas=new byte[2048];
    private boolean closed;
    private final int[] tmp=new int[1];

    VelocityGpuPresenter(Surface target,int[] sourcePalette) {
        if(target==null||!target.isValid())throw new IllegalStateException("4K target surface is invalid");
        if(sourcePalette==null||sourcePalette.length!=256)
            throw new IllegalArgumentException("4K palette must contain 256 colors");
        palette=sourcePalette.clone();
        try{initialize(target);}catch(RuntimeException ex){close();throw ex;}
    }

    int width(){return internalW;}
    int height(){return internalH;}
    boolean isNative4K(){return internalW==TARGET_W&&internalH==TARGET_H;}

    private void initialize(Surface target){
        display=EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY);
        if(display==EGL14.EGL_NO_DISPLAY||!EGL14.eglInitialize(display,new int[2],0,new int[2],0))
            throw new IllegalStateException("No EGL display for REgraphics");
        int[] attrs={EGL14.EGL_SURFACE_TYPE,EGL14.EGL_WINDOW_BIT,
            EGL14.EGL_RENDERABLE_TYPE,EGL_ES3_BIT,
            EGL14.EGL_RED_SIZE,8,EGL14.EGL_GREEN_SIZE,8,EGL14.EGL_BLUE_SIZE,8,
            EGL14.EGL_ALPHA_SIZE,8,EGL14.EGL_DEPTH_SIZE,16,EGL14.EGL_NONE};
        EGLConfig[] configs=new EGLConfig[1];int[] count={0};
        if(!EGL14.eglChooseConfig(display,attrs,0,configs,0,1,count,0)||count[0]<1)
            throw new IllegalStateException("GLES3 EGL config unavailable");
        context=EGL14.eglCreateContext(display,configs[0],EGL14.EGL_NO_CONTEXT,
            new int[]{EGL14.EGL_CONTEXT_CLIENT_VERSION,3,EGL14.EGL_NONE},0);
        if(context==EGL14.EGL_NO_CONTEXT)throw new IllegalStateException("GLES3 context unavailable");
        window=EGL14.eglCreateWindowSurface(display,configs[0],target,
            new int[]{EGL14.EGL_NONE},0);
        if(window==EGL14.EGL_NO_SURFACE||!EGL14.eglMakeCurrent(display,window,window,context))
            throw new IllegalStateException("GLES3 window surface unavailable");
        String version=GLES30.glGetString(GLES30.GL_VERSION);
        if(version==null||!version.contains("OpenGL ES 3"))
            throw new IllegalStateException("OpenGL ES 3 required: "+version);
        program=link();
        GLES30.glUseProgram(program);
        GLES30.glUniform2f(GLES30.glGetUniformLocation(program,"sourceSize"),TARGET_W,TARGET_H);
        GLES30.glUniform1i(GLES30.glGetUniformLocation(program,"tileAtlas"),0);
        GLES30.glUniform1i(GLES30.glGetUniformLocation(program,"palette"),1);
        GLES30.glGenVertexArrays(1,tmp,0);vao=tmp[0];
        GLES30.glBindVertexArray(vao);
        GLES30.glGenBuffers(1,tmp,0);vbo=tmp[0];
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER,vbo);
        for(int i=0;i<5;++i)GLES30.glEnableVertexAttribArray(i);
        GLES30.glVertexAttribPointer(0,3,GLES30.GL_FLOAT,false,VERTEX_BYTES,0);
        GLES30.glVertexAttribPointer(1,2,GLES30.GL_FLOAT,false,VERTEX_BYTES,12);
        GLES30.glVertexAttribPointer(2,1,GLES30.GL_FLOAT,false,VERTEX_BYTES,20);
        GLES30.glVertexAttribPointer(3,2,GLES30.GL_FLOAT,false,VERTEX_BYTES,24);
        GLES30.glVertexAttribPointer(4,2,GLES30.GL_FLOAT,false,VERTEX_BYTES,32);
        GLES30.glGenTextures(1,tmp,0);tileTexture=tmp[0];
        GLES30.glGenTextures(1,tmp,0);paletteTexture=tmp[0];
        ByteBuffer colors=ByteBuffer.allocateDirect(256*4).order(ByteOrder.nativeOrder());
        for(int rgb:palette){colors.put((byte)(rgb>>16)).put((byte)(rgb>>8))
            .put((byte)rgb).put((byte)255);}
        colors.flip();
        GLES30.glActiveTexture(GLES30.GL_TEXTURE1);
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D,paletteTexture);
        setNearest();
        GLES30.glTexImage2D(GLES30.GL_TEXTURE_2D,0,GLES30.GL_RGBA8,256,1,0,
            GLES30.GL_RGBA,GLES30.GL_UNSIGNED_BYTE,colors);
        GLES30.glGetIntegerv(GLES30.GL_MAX_TEXTURE_SIZE,tmp,0);
        int maxTexture=tmp[0];
        GLES30.glGetIntegerv(GLES30.GL_MAX_RENDERBUFFER_SIZE,tmp,0);
        int maxRenderbuffer=tmp[0];
        for(int[] size:new int[][]{{3840,2160},{1920,1080},{1280,720}}) {
            if(size[0]<=maxTexture&&size[1]<=maxRenderbuffer&&allocateTarget(size[0],size[1]))break;
        }
        if(framebuffer==0)throw new IllegalStateException("Unable to allocate a hardware REgraphics FBO");
        GLES30.glUseProgram(program);
        GLES30.glUniform2f(GLES30.glGetUniformLocation(program,"renderSize"),internalW,internalH);
        Log.i("ReverseVelocity","GPU_INITIALIZED source=3840x2160 internal="+internalW+"x"+internalH+
            " gles="+version+" maxTexture="+maxTexture+" maxRenderbuffer="+maxRenderbuffer);
    }

    private boolean allocateTarget(int w,int h) {
        releaseTarget();
        GLES30.glGenFramebuffers(1,tmp,0);framebuffer=tmp[0];
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER,framebuffer);
        GLES30.glGenTextures(1,tmp,0);colorTexture=tmp[0];
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D,colorTexture);
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_MIN_FILTER,GLES30.GL_LINEAR);
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_MAG_FILTER,GLES30.GL_LINEAR);
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_WRAP_S,GLES30.GL_CLAMP_TO_EDGE);
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_WRAP_T,GLES30.GL_CLAMP_TO_EDGE);
        GLES30.glTexImage2D(GLES30.GL_TEXTURE_2D,0,GLES30.GL_RGBA8,w,h,0,
            GLES30.GL_RGBA,GLES30.GL_UNSIGNED_BYTE,null);
        GLES30.glFramebufferTexture2D(GLES30.GL_FRAMEBUFFER,GLES30.GL_COLOR_ATTACHMENT0,
            GLES30.GL_TEXTURE_2D,colorTexture,0);
        GLES30.glGenRenderbuffers(1,tmp,0);depthBuffer=tmp[0];
        GLES30.glBindRenderbuffer(GLES30.GL_RENDERBUFFER,depthBuffer);
        GLES30.glRenderbufferStorage(GLES30.GL_RENDERBUFFER,GLES30.GL_DEPTH_COMPONENT16,w,h);
        GLES30.glFramebufferRenderbuffer(GLES30.GL_FRAMEBUFFER,GLES30.GL_DEPTH_ATTACHMENT,
            GLES30.GL_RENDERBUFFER,depthBuffer);
        boolean good=GLES30.glCheckFramebufferStatus(GLES30.GL_FRAMEBUFFER)==
            GLES30.GL_FRAMEBUFFER_COMPLETE&&GLES30.glGetError()==GLES30.GL_NO_ERROR;
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER,0);
        if(good){internalW=w;internalH=h;return true;}
        releaseTarget();return false;
    }

    private static void setNearest(){
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_MIN_FILTER,GLES30.GL_NEAREST);
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_MAG_FILTER,GLES30.GL_NEAREST);
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_WRAP_S,GLES30.GL_CLAMP_TO_EDGE);
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_WRAP_T,GLES30.GL_CLAMP_TO_EDGE);
    }

    void render(VelocityGpuFrame frame) {
        if(closed||frame==null||frame.width!=TARGET_W||frame.height!=TARGET_H)
            throw new IllegalArgumentException("Invalid 4K REgraphics render");
        GLES30.glUseProgram(program);
        GLES30.glActiveTexture(GLES30.GL_TEXTURE0);
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D,tileTexture);
        // Filter the original XI texels rather than enlarging 16x16 blocks.
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_MIN_FILTER,GLES30.GL_LINEAR);
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D,GLES30.GL_TEXTURE_MAG_FILTER,GLES30.GL_LINEAR);
        boolean changed=!textureAtlasUploaded;
        frame.tiles.position(0);
        for(int i=0;i<cachedTileAtlas.length;i++){
            byte value=frame.tiles.get(i);
            if(value!=cachedTileAtlas[i])changed=true;
        }
        if(changed){
            GLES30.glPixelStorei(GLES30.GL_UNPACK_ALIGNMENT,1);
            frame.tiles.position(0);
            GLES30.glTexImage2D(GLES30.GL_TEXTURE_2D,0,GLES30.GL_R8,16,128,0,
                GLES30.GL_RED,GLES30.GL_UNSIGNED_BYTE,frame.tiles);
            frame.tiles.position(0);
            frame.tiles.get(cachedTileAtlas);
            textureAtlasUploaded=true;
        }
        GLES30.glActiveTexture(GLES30.GL_TEXTURE1);
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D,paletteTexture);
        GLES30.glBindVertexArray(vao);
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER,vbo);
        frame.vertices.position(0);
        GLES30.glBufferData(GLES30.GL_ARRAY_BUFFER,frame.vertices.remaining(),
            frame.vertices,GLES30.GL_STREAM_DRAW);
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER,framebuffer);
        GLES30.glViewport(0,0,internalW,internalH);
        GLES30.glEnable(GLES30.GL_DEPTH_TEST);
        GLES30.glDepthFunc(GLES30.GL_LESS);
        GLES30.glDisable(GLES30.GL_CULL_FACE);
        GLES30.glDisable(GLES30.GL_BLEND);
        GLES30.glClearColor((palette[0]>>16&255)/255f,(palette[0]>>8&255)/255f,
            (palette[0]&255)/255f,1);
        GLES30.glClearDepthf(1f);
        GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT|GLES30.GL_DEPTH_BUFFER_BIT);
        GLES30.glDrawArrays(GLES30.GL_TRIANGLES,0,frame.faces*3);
        int[] dims=new int[1];
        EGL14.eglQuerySurface(display,window,EGL14.EGL_WIDTH,dims,0);int w=Math.max(1,dims[0]);
        EGL14.eglQuerySurface(display,window,EGL14.EGL_HEIGHT,dims,0);int h=Math.max(1,dims[0]);
        GLES30.glBindFramebuffer(GLES30.GL_READ_FRAMEBUFFER,framebuffer);
        GLES30.glBindFramebuffer(GLES30.GL_DRAW_FRAMEBUFFER,0);
        GLES30.glDisable(GLES30.GL_DEPTH_TEST);
        GLES30.glBlitFramebuffer(0,0,internalW,internalH,0,0,w,h,
            GLES30.GL_COLOR_BUFFER_BIT,GLES30.GL_LINEAR);
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER,0);
        int error=GLES30.glGetError();
        if(error!=GLES30.GL_NO_ERROR)throw new IllegalStateException("GLES3 render error "+error);
        if(!EGL14.eglSwapBuffers(display,window))
            throw new IllegalStateException("REgraphics GLES3 present failed");
    }

    private static int shader(int kind,String source) {
        int id=GLES30.glCreateShader(kind);
        GLES30.glShaderSource(id,source);GLES30.glCompileShader(id);
        int[] ok=new int[1];GLES30.glGetShaderiv(id,GLES30.GL_COMPILE_STATUS,ok,0);
        if(ok[0]==0){String reason=GLES30.glGetShaderInfoLog(id);GLES30.glDeleteShader(id);
            throw new IllegalStateException("REgraphics GLSL compilation: "+reason);}
        return id;
    }
    private static int link(){
        int v=shader(GLES30.GL_VERTEX_SHADER,VERTEX_SHADER),f=shader(GLES30.GL_FRAGMENT_SHADER,FRAGMENT_SHADER);
        int id=GLES30.glCreateProgram();
        GLES30.glAttachShader(id,v);GLES30.glAttachShader(id,f);
        GLES30.glLinkProgram(id);int[] ok=new int[1];
        GLES30.glGetProgramiv(id,GLES30.GL_LINK_STATUS,ok,0);
        GLES30.glDeleteShader(v);GLES30.glDeleteShader(f);
        if(ok[0]==0){String reason=GLES30.glGetProgramInfoLog(id);GLES30.glDeleteProgram(id);
            throw new IllegalStateException("REgraphics GLSL link: "+reason);}
        return id;
    }

    private void releaseTarget(){
        if(colorTexture!=0){tmp[0]=colorTexture;GLES30.glDeleteTextures(1,tmp,0);colorTexture=0;}
        if(depthBuffer!=0){tmp[0]=depthBuffer;GLES30.glDeleteRenderbuffers(1,tmp,0);depthBuffer=0;}
        if(framebuffer!=0){tmp[0]=framebuffer;GLES30.glDeleteFramebuffers(1,tmp,0);framebuffer=0;}
    }

    @Override public void close(){
        if(closed)return;closed=true;
        if(display!=EGL14.EGL_NO_DISPLAY&&context!=EGL14.EGL_NO_CONTEXT&&
           window!=EGL14.EGL_NO_SURFACE)EGL14.eglMakeCurrent(display,window,window,context);
        if(display!=EGL14.EGL_NO_DISPLAY&&context!=EGL14.EGL_NO_CONTEXT){
            releaseTarget();
            if(tileTexture!=0){tmp[0]=tileTexture;GLES30.glDeleteTextures(1,tmp,0);}
            if(paletteTexture!=0){tmp[0]=paletteTexture;GLES30.glDeleteTextures(1,tmp,0);}
            if(vbo!=0){tmp[0]=vbo;GLES30.glDeleteBuffers(1,tmp,0);}
            if(vao!=0){tmp[0]=vao;GLES30.glDeleteVertexArrays(1,tmp,0);}
            if(program!=0)GLES30.glDeleteProgram(program);
        }
        if(display!=EGL14.EGL_NO_DISPLAY){
            EGL14.eglMakeCurrent(display,EGL14.EGL_NO_SURFACE,EGL14.EGL_NO_SURFACE,EGL14.EGL_NO_CONTEXT);
            if(window!=EGL14.EGL_NO_SURFACE)EGL14.eglDestroySurface(display,window);
            if(context!=EGL14.EGL_NO_CONTEXT)EGL14.eglDestroyContext(display,context);
            EGL14.eglTerminate(display);
        }
        window=EGL14.EGL_NO_SURFACE;context=EGL14.EGL_NO_CONTEXT;display=EGL14.EGL_NO_DISPLAY;
    }
}
