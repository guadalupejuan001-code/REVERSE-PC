package com.reversepc.os;

import android.app.ActivityManager;
import android.content.Context;
import android.opengl.GLES30;
import android.opengl.GLSurfaceView;
import android.util.Log;
import android.view.View;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Arrays;
import x.gpu.virtual.CompactTriangleStream;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.security.MessageDigest;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;
import static android.opengl.GLES30.*;

/** REgraphics GPU backend. XI alone supplies every triangle and world state. */
final class VelocityGpuSurface extends GLSurfaceView implements GLSurfaceView.Renderer {
    private final Runnable invalidated;
    private final VelocityXiEngine game;
    private final boolean verifyPixels;
    private final Object mailbox=new Object();
    private volatile boolean ready,failed,suspended;
    private Request queued,active;
    private int postProgram,depthProgram,depthProjection,depthAspect,vao,vbo,paletteTexture,atlasTexture;
    private final SceneShader[] sceneShaders=new SceneShader[3];
    private boolean materialVariants;
    private int framebuffer,colorTexture,depthBuffer,targetWidth,targetHeight;
    private int imageU,texelU,photoU,postQualityU;
    private static final class SceneShader {
        final int program,projection,aspect,time,day,sun,wet,water,palette,atlas,lampOrigin,lampDirection,lampPower,quality;
        SceneShader(int p){
            program=p;quality=glGetUniformLocation(p,"uQuality");projection=glGetUniformLocation(p,"uProjection");aspect=glGetUniformLocation(p,"uAspect");
            time=glGetUniformLocation(p,"uTime");day=glGetUniformLocation(p,"uDay");sun=glGetUniformLocation(p,"uSunDirection");
            wet=glGetUniformLocation(p,"uWet");water=glGetUniformLocation(p,"uWaterDepth");palette=glGetUniformLocation(p,"uPalette");atlas=glGetUniformLocation(p,"uAtlas");
            lampOrigin=glGetUniformLocation(p,"uLampOrigin");lampDirection=glGetUniformLocation(p,"uLampDirection");lampPower=glGetUniformLocation(p,"uLampPower");
        }
    }
    private final float[] lampFrame=new float[6];
    private final float[] c12Frame=new float[5]; // Reused only on the GL thread.
    private static final int[] DEPTH_ATTACHMENTS={GL_DEPTH_ATTACHMENT};
    private float sunX,sunY,sunZ,frameLampPower;
    private volatile boolean firstFrame;
    private volatile boolean independentGpu=true;
    private final boolean[] verifiedProfiles=new boolean[5];
    private VelocityGraphics lastGraphics=VelocityGraphics.fromId(2);
    private int lastFx=-1;
    private int lastMaterialRoute=-1;
    private long measuredFrom,measuredFrames,queueNanos,commandNanos,swapNanos;
    private ByteBuffer presetReadback;
    private final CompactTriangleStream vertices=new CompactTriangleStream();
    // The immutable native qSSD projection is the only GLES resource authority.
    private final VelocityQssdGraphicsBridge qssd=new VelocityQssdGraphicsBridge();
    private int vertexCapacity;
    private int atlasFilter=-1;
    private long reusedGeometryFrames;
    private long vertexUploadBytes,vertexUploadCalls,textureUploadBytes,textureUploadCalls,resourceFrames;
    private final ByteBuffer paletteBytes=ByteBuffer.allocateDirect(1024),atlasBytes=ByteBuffer.allocateDirect(2048);
    static final class Request {
        final VelocityQssdGraphicsBridge.Frame resources;
        final RegraphicsGeometry geometry;final int[] palette;final VelocityGraphics graphics;
        final VelocityXiEngine.Snapshot state;final int yaw,width;
        final long submittedNanos=System.nanoTime();
        final CountDownLatch done=new CountDownLatch(1);volatile RuntimeException error;
        Request(VelocityQssdGraphicsBridge.Frame lease,VelocityXiEngine.Snapshot s,int yaw,VelocityGraphics graphics){
            resources=lease;geometry=lease.geometry;palette=lease.palette;
            state=s;this.yaw=yaw;this.graphics=graphics;this.width=graphics.width;
        }
    }
    static boolean supported(Context context){
        ActivityManager manager=(ActivityManager)context.getSystemService(Context.ACTIVITY_SERVICE);
        return manager!=null&&manager.getDeviceConfigurationInfo().reqGlEsVersion>=0x30000;
    }
    VelocityGpuSurface(Context context,Runnable invalidated,VelocityXiEngine game,boolean verifyPixels){
        super(context);this.invalidated=invalidated;this.game=game;this.verifyPixels=verifyPixels;
        setEGLContextClientVersion(3);setEGLConfigChooser(8,8,8,8,24,0);
        setPreserveEGLContextOnPause(true);setZOrderMediaOverlay(true);
        setRenderer(this);setRenderMode(RENDERMODE_WHEN_DIRTY);
        setClickable(true);
        setContentDescription("Cámara 3D. Arrastra para inspeccionar el coche; vuelve automáticamente al conducir.");
    }
    boolean hasPresentedFrame(){return firstFrame;}
    boolean canOverlapCpu(){return independentGpu;}
    boolean available(){return ready&&!failed&&!suspended;}
    void disable(Throwable why){
        failed=true;ready=false;cancel("GPU unavailable");
        Log.w("ReverseVelocity","GPU_FALLBACK software=REgraphics_XI reason="+why);
        post(()->setVisibility(View.GONE));invalidated.run();
    }
    private void cancel(String why){synchronized(mailbox){for(Request r:new Request[]{queued,active})if(r!=null){r.error=new IllegalStateException(why);r.done.countDown();}queued=null;}}
    @Override public void onPause(){suspended=true;ready=false;cancel("GPU suspended");super.onPause();}
    @Override public void onResume(){suspended=false;super.onResume();invalidated.run();requestRender();}
    void draw(VelocityXiEngine.Observation observed,int yaw,VelocityGraphics graphics)throws InterruptedException{
        if(observed.geometry==null||observed.colors==null)
            throw new IllegalArgumentException("Missing validated XI/qSSD XFG4 observation");
        VelocityQssdGraphicsBridge.Frame lease=qssd.publish(
            observed.geometry,observed.colors,observed.qssdSession,observed.qssdIdentity,observed.qssdRevision);
        // Geometry and shader state must come from the same retained CPU publication.
        submit(new Request(lease,observed.state,yaw,graphics));
    }
    private void submit(Request request)throws InterruptedException{
        if(!available())throw new IllegalStateException("GPU surface is not ready");
        synchronized(mailbox){if(queued!=null)throw new IllegalStateException("GPU mailbox already occupied");queued=request;}
        requestRender();
        if(!request.done.await(!firstFrame?15:8,TimeUnit.SECONDS))throw new IllegalStateException("GPU frame timed out");
        if(request.error!=null)throw request.error;
    }
    private String asset(String name){
        String value=game.resourceText(name);
        if(value.length()>65536)throw new IllegalStateException("Shader source budget");return value;
    }
    private int shader(int kind,String source){int shader=glCreateShader(kind);glShaderSource(shader,source);glCompileShader(shader);int[] ok={0};glGetShaderiv(shader,GL_COMPILE_STATUS,ok,0);if(ok[0]==0){String why=glGetShaderInfoLog(shader);glDeleteShader(shader);throw new IllegalStateException(why);}return shader;}
    private int program(String vertex,String fragment){return program(vertex,fragment,0);}
    private int program(String vertex,String fragment,int variant){
        int v=0,f=0,p=0;
        try{
            String source=asset(fragment);
            if(variant!=0){int line=source.indexOf('\n')+1;source=source.substring(0,line)+"#define REGRAPHICS_CLASS "+variant+"\n"+source.substring(line);}
            v=shader(GL_VERTEX_SHADER,asset(vertex));f=shader(GL_FRAGMENT_SHADER,source);p=glCreateProgram();
            glAttachShader(p,v);glAttachShader(p,f);glLinkProgram(p);int[] ok={0};glGetProgramiv(p,GL_LINK_STATUS,ok,0);
            if(ok[0]==0)throw new IllegalStateException(glGetProgramInfoLog(p));return p;
        }catch(RuntimeException failure){if(p!=0)glDeleteProgram(p);throw failure;}
        finally{if(v!=0)glDeleteShader(v);if(f!=0)glDeleteShader(f);}
    }
    private static void checked(String stage){int error=glGetError();if(error!=GL_NO_ERROR)throw new IllegalStateException(stage+" GLES 0x"+Integer.toHexString(error));}
    private static int uniform(int p,String name){int n=glGetUniformLocation(p,name);if(n<0)throw new IllegalStateException("Missing shader uniform "+name);return n;}
    private static int texture(){int[] id={0};glGenTextures(1,id,0);glBindTexture(GL_TEXTURE_2D,id[0]);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);return id[0];}
    @Override public void onSurfaceCreated(GL10 ignored,EGLConfig config){
        ready=false;firstFrame=false;Arrays.fill(verifiedProfiles,false);framebuffer=colorTexture=depthBuffer=0;targetWidth=targetHeight=0;
        try{
            String renderer=glGetString(GL_RENDERER).toLowerCase(java.util.Locale.ROOT);
            independentGpu=!(renderer.contains("swiftshader")||renderer.contains("llvmpipe")||renderer.contains("softpipe")||renderer.contains("software rasterizer"));
            Log.i("ReverseVelocity","CPU_GPU_EXECUTION overlap="+independentGpu+" policy="+(independentGpu?"independent_gpu":"shared_cpu_rasterizer"));
            Arrays.fill(sceneShaders,null);materialVariants=false;lastMaterialRoute=-1;
            sceneShaders[0]=new SceneShader(program("gpu-compact.vert","gpu-scene.frag"));
            try{
                sceneShaders[1]=new SceneShader(program("gpu-compact.vert","gpu-scene.frag",1));
                sceneShaders[2]=new SceneShader(program("gpu-compact.vert","gpu-scene.frag",2));
                materialVariants=true;
            }catch(RuntimeException specializationFailure){
                for(int i=1;i<3;i++){if(sceneShaders[i]!=null)glDeleteProgram(sceneShaders[i].program);sceneShaders[i]=null;}
                Log.w("ReverseVelocity","GPU_MATERIAL_GENERIC reason="+specializationFailure.getMessage());
            }
            depthProgram=program("gpu-compact-depth.vert","gpu-depth.frag");
            depthProjection=uniform(depthProgram,"uProjection");depthAspect=uniform(depthProgram,"uAspect");
            postProgram=program("gpu-post.vert","gpu-post.frag");
            imageU=uniform(postProgram,"uImage");texelU=uniform(postProgram,"uTexel");photoU=uniform(postProgram,"uPhoto");postQualityU=uniform(postProgram,"uQuality");
            paletteTexture=texture();glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,256,1,0,GL_RGBA,GL_UNSIGNED_BYTE,null);
            atlasTexture=texture();glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);glTexImage2D(GL_TEXTURE_2D,0,GL_R8,128,16,0,GL_RED,GL_UNSIGNED_BYTE,null);
            int[] id={0};glGenVertexArrays(1,id,0);vao=id[0];glBindVertexArray(vao);glGenBuffers(1,id,0);vbo=id[0];glBindBuffer(GL_ARRAY_BUFFER,vbo);glBufferData(GL_ARRAY_BUFFER,4,null,GL_DYNAMIC_DRAW);
            vertexCapacity=4;vertices.invalidateGpuCopy();qssd.contextLost();atlasFilter=-1;
            int stride=CompactTriangleStream.STRIDE;
            glVertexAttribPointer(0,2,GL_INT,false,stride,0);
            glVertexAttribPointer(1,2,GL_SHORT,false,stride,12);
            glVertexAttribPointer(2,1,GL_FLOAT,false,stride,16);
            glVertexAttribPointer(3,4,GL_UNSIGNED_BYTE,false,stride,20);
            glVertexAttribIPointer(4,1,GL_UNSIGNED_INT,stride,8);
            for(int i=0;i<5;i++)glEnableVertexAttribArray(i);glBindVertexArray(0);
            glDisable(GL_CULL_FACE);checked("GPU initialization");failed=false;
            Log.i("ReverseVelocity","GPU_SHADERS_READY owner=REgraphics geometry=XI_XFG4 execution=GPU_VIRTUAL vertexBytes=24 materialPrograms="+(materialVariants?3:1)+" renderer="+glGetString(GL_RENDERER));
            Log.i("ReverseVelocity","GPU_READBACK_POLICY enabled="+verifyPixels+" scope=explicit_pixel_validation");
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
        if(r==null){glBindFramebuffer(GL_FRAMEBUFFER,0);glViewport(0,0,getWidth(),getHeight());glClearColor(.025f,.045f,.06f,1);glClear(GL_COLOR_BUFFER_BIT);if(colorTexture!=0)post(colorTexture,targetWidth,targetHeight,lastGraphics.id);return;}
        final long entered=System.nanoTime();
        try{
            scene(r);
            checked("REgraphics GPU frame");
            final long recorded=System.nanoTime();
            // GLSurfaceView swaps after onDrawFrame. Its next queued event runs
            // after that swap, so the caller only marks an actually posted view.
            queueEvent(()->{
                long posted=System.nanoTime();
                {
                    if(measuredFrom==0)measuredFrom=r.submittedNanos;
                    measuredFrames++;queueNanos+=entered-r.submittedNanos;commandNanos+=recorded-entered;swapNanos+=posted-recorded;
                    if(posted-measuredFrom>=1_000_000_000L){
                        double scale=1.0/(measuredFrames*1_000_000.0);
                        Log.i("ReverseVelocity",String.format(java.util.Locale.ROOT,
                            "GPU_PIPELINE timing=wall_not_gpu_timestamp samples=%d queueMeanMs=%.3f commandsMeanMs=%.3f swapMeanMs=%.3f width=%d height=%d",
                            measuredFrames,queueNanos*scale,commandNanos*scale,swapNanos*scale,targetWidth,targetHeight));
                        measuredFrames=queueNanos=commandNanos=swapNanos=0;measuredFrom=posted;
                    }
                }
                if(!firstFrame&&r.geometry!=null){firstFrame=true;Log.i("ReverseVelocity","GPU_FRAME_READY source=XI_XFG4 shaders=REgraphics faces="+r.geometry.faces+" width="+targetWidth+" height="+targetHeight);}
                r.done.countDown();synchronized(mailbox){if(active==r)active=null;}
            });
        }catch(RuntimeException error){
            // Preparation updates the CPU staging copy before the driver accepts it.
            // A failed partial upload therefore invalidates both residency records.
            vertices.invalidateGpuCopy();qssd.contextLost();
            r.error=error;r.done.countDown();disable(error);
        }
    }
    private void scene(Request r){
        // Native C12 must execute for every submitted GLES frame; no fake
        // Java result when the dependency is absent. XI fallback is separate.
        NativeRuntime.velocityC12Frame(r.state.wetness,r.state.waterDepthCm,
            (int)r.state.ticks,r.state.ambientMode,r.state.publication,c12Frame);
        int w=r.graphics.width,h=r.graphics.height;
        target(w,h);glBindFramebuffer(GL_FRAMEBUFFER,framebuffer);glViewport(0,0,w,h);glDepthMask(true);glClearColor(.08f,.12f,.14f,1);glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
        // REgraphics -> native qSSD versioned geometry -> resource bus -> GLES.
        VelocityQssdGraphicsBridge.Plan plan=qssd.plan(r.resources);
        RegraphicsGeometry g=plan.frame.geometry;
        boolean geometryChanged=plan.geometryDirty;
        if(geometryChanged)g.compact(vertices);else reusedGeometryFrames++;
        int fx=(r.state.nitroActive?1:0)|(r.state.airPulse>0?2:0)|(r.state.waterDepthCm>0?4:0);
        if(fx!=lastFx){lastFx=fx;Log.i("ReverseVelocity","GPU_FX_STATE nitro="+r.state.nitroActive+" air="+(r.state.airPulse>0)+" waterDepth="+r.state.waterDepthCm+" emittedNitro="+g.categoryFaces(5)+" emittedAir="+g.categoryFaces(4));}
        glBindVertexArray(vao);glBindBuffer(GL_ARRAY_BUFFER,vbo);
        if(vertexCapacity<vertices.capacityBytes()){
            vertexCapacity=vertices.capacityBytes();
            glBufferData(GL_ARRAY_BUFFER,vertexCapacity,null,GL_DYNAMIC_DRAW);
            // A GL storage replacement requires every resident page to be uploaded.
            vertices.invalidateGpuCopy();g.compact(vertices);geometryChanged=true;
        }
        for(int i=0;geometryChanged&&i<vertices.uploadCount();i++){
            int offset=vertices.uploadOffset(i),length=vertices.uploadLength(i);
            glBufferSubData(GL_ARRAY_BUFFER,offset,length,vertices.view(offset,length));
            vertexUploadBytes+=length;vertexUploadCalls++;
        }
        glActiveTexture(GL_TEXTURE0);glBindTexture(GL_TEXTURE_2D,paletteTexture);
        // qSSD supplies granular palette texels and 128x1 atlas row deltas.
        for(int range=0;range<plan.paletteRanges.length;range+=2){
            int first=plan.paletteRanges[range],size=plan.paletteRanges[range+1];
            paletteBytes.clear();
            for(int j=first;j<first+size;j++){
                int color=plan.frame.palette[j];
                paletteBytes.put((byte)(color>>16)).put((byte)(color>>8))
                    .put((byte)color).put((byte)255);
            }
            paletteBytes.flip();
            glTexSubImage2D(GL_TEXTURE_2D,0,first,0,size,1,
                GL_RGBA,GL_UNSIGNED_BYTE,paletteBytes);
            textureUploadBytes+=4L*size;textureUploadCalls++;
        }
        glActiveTexture(GL_TEXTURE1);glBindTexture(GL_TEXTURE_2D,atlasTexture);
        int filter=r.graphics.id<=1?GL_NEAREST:GL_LINEAR;
        if(filter!=atlasFilter){
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,filter);
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,filter);atlasFilter=filter;
        }
        for(int row=0;row<16;){
            if((plan.atlasRowsMask&(1<<row))==0){row++;continue;}
            int first=row++;
            while(row<16&&(plan.atlasRowsMask&(1<<row))!=0)row++;
            int rows=row-first,bytes=rows*128;
            atlasBytes.clear();atlasBytes.put(plan.frame.atlas,first*128,bytes);atlasBytes.flip();
            glTexSubImage2D(GL_TEXTURE_2D,0,0,first,128,rows,GL_RED,GL_UNSIGNED_BYTE,atlasBytes);
            textureUploadBytes+=bytes;textureUploadCalls++;
        }
        checked("QSSD resource delta uploads");
        qssd.confirm(plan); // Commit only after the GL driver accepts all resources.
        if(resourceFrames==0)
            Log.i("ReverseVelocity","QSSD_GPU_BRIDGE_ACTIVE source=XI_XFG4 identity="+plan.frame.sourceIdentity+
                " revision="+plan.frame.sourceRevision+" session="+plan.frame.sourceSession+" paletteVersion="+plan.frame.paletteRevision+
                " atlasVersion="+plan.frame.atlasRevision+" route=REgraphics_QSSD_GLES");
        if(++resourceFrames>=60){
            Log.i("ReverseVelocity","GPU_VIRTUAL_RESOURCES frames="+resourceFrames+" vertexStride=24 stagingCapacityBytes="+vertices.capacityBytes()+" vboCapacityBytes="+vertexCapacity+" liveVertexBytes="+vertices.usedBytes()+" vertexUploadBytes="+vertexUploadBytes+" vertexUploadCalls="+vertexUploadCalls+" textureUploadBytes="+textureUploadBytes+" reusedGeometryFrames="+reusedGeometryFrames+" scope=geometry_transport_not_process_ram");
            Log.i("ReverseVelocity","QSSD_RENDER_BUS frames="+resourceFrames+
                " sourceIdentity="+plan.frame.sourceIdentity+" sourceRevision="+plan.frame.sourceRevision+
                " serial="+plan.frame.serial+" gpuUploadCommits="+qssd.uploadCommits()+
                " reusedPublications="+qssd.reusedPublications()+
                " geometryDirty="+plan.geometryDirty+" paletteDirtyTexels="+plan.changedPaletteTexels()+
                " atlasDirtyRows="+plan.changedAtlasRows()+" vboBytes="+vertexUploadBytes+
                " textureBytes="+textureUploadBytes+" textureUploadCalls="+textureUploadCalls+" route=REgraphics_QSSD_GLES");
            resourceFrames=vertexUploadBytes=vertexUploadCalls=textureUploadBytes=textureUploadCalls=reusedGeometryFrames=0;
        }
        // Resolve visibility with the exact same vertex transform before doing
        // material work. Sky and hidden opaque surfaces then cost no shading.
        glDisable(GL_BLEND);glEnable(GL_DEPTH_TEST);glDepthFunc(GL_LEQUAL);glDepthMask(true);
        glUseProgram(depthProgram);glUniform2f(depthProjection,g.width,g.height);glUniform1f(depthAspect,(float)w/h);
        glColorMask(false,false,false,false);glDrawArrays(GL_TRIANGLES,g.starts[1],g.counts[1]);
        glColorMask(true,true,true,true);glDepthMask(false);
        // Specialize material work without sorting opaque faces. Equal-depth
        // ties, alpha order, attributes and the depth prepass stay unchanged.
        boolean specialized=materialVariants&&g.opaqueRunCount()<=128;
        if(lastMaterialRoute!=(specialized?1:0)){
            lastMaterialRoute=specialized?1:0;
            Log.i("ReverseVelocity","GPU_MATERIAL_ROUTE specialized="+specialized+" opaqueRuns="+g.opaqueRunCount()+" order=original");
        }
        boolean lamp=g.lightFrame(lampFrame);frameLampPower=lamp?c12Frame[4]:0;
        double sunAngle=(r.state.yaw4096+r.yaw)*(Math.PI/2048);
        float sunCos=(float)Math.cos(sunAngle),sunSin=(float)Math.sin(sunAngle),sunNorm=(float)(1/Math.sqrt(1.1525));
        sunX=(-.55f*sunCos+.38f*sunSin)*sunNorm;sunY=.84f*sunNorm;sunZ=(-.55f*sunSin-.38f*sunCos)*sunNorm;
        useScene(sceneShaders[0],r,g,w,h);
        if(specialized){useScene(sceneShaders[1],r,g,w,h);useScene(sceneShaders[2],r,g,w,h);}
        glUseProgram(sceneShaders[specialized?1:0].program);glDrawArrays(GL_TRIANGLES,g.starts[0],g.counts[0]);
        glDepthFunc(GL_EQUAL);
        if(specialized){
            int previous=0;
            for(int run=0;run<g.opaqueRunCount();run++){
                int end=g.opaqueRunEnd(run);glUseProgram(sceneShaders[g.opaqueRunShader(run)].program);
                glDrawArrays(GL_TRIANGLES,g.starts[1]+previous,end-previous);previous=end;
            }
        }else{glUseProgram(sceneShaders[0].program);glDrawArrays(GL_TRIANGLES,g.starts[1],g.counts[1]);}
        glUseProgram(sceneShaders[0].program);
        glDepthFunc(GL_LEQUAL);glEnable(GL_BLEND);glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
        glDrawArrays(GL_TRIANGLES,g.starts[2],g.counts[2]);
        glBlendFunc(GL_SRC_ALPHA,GL_ONE);glDrawArrays(GL_TRIANGLES,g.starts[3],g.counts[3]);
        glDepthMask(true);glDisable(GL_BLEND);glDisable(GL_DEPTH_TEST);glBindVertexArray(0);
        if(verifyPixels&&!verifiedProfiles[r.graphics.id]){
            // Hash every original RGBA byte in row order using bounded scratch.
            // Scratch remains below 0.5 MB through the maximum 1080p preset.
            int stripeRows=64,stripeBytes=w*stripeRows*4;
            if(presetReadback==null||presetReadback.capacity()<stripeBytes)presetReadback=ByteBuffer.allocateDirect(stripeBytes);
            try{MessageDigest digest=MessageDigest.getInstance("SHA-256");
                for(int y=0;y<h;y+=stripeRows){
                    int rows=Math.min(stripeRows,h-y);presetReadback.clear();presetReadback.limit(w*rows*4);
                    glReadPixels(0,y,w,rows,GL_RGBA,GL_UNSIGNED_BYTE,presetReadback);checked("GPU preset readback");
                    presetReadback.rewind();digest.update(presetReadback);
                }
                StringBuilder hash=new StringBuilder();for(byte b:digest.digest())hash.append(String.format(java.util.Locale.ROOT,"%02x",b&255));Log.i("ReverseVelocity","GPU_PRESET_PIXELS preset="+r.graphics.id+" source=XI_XFG4_GLSL width="+w+" height="+h+" pixels="+(w*h)+" sha256="+hash+" readbackCapacityBytes="+presetReadback.capacity());}
            catch(Exception error){throw new IllegalStateException("GPU pixel verification failed",error);}
            verifiedProfiles[r.graphics.id]=true;
        }
        // No later pass consumes scene depth. Let tile-based GPUs discard it.
        glInvalidateFramebuffer(GL_FRAMEBUFFER,1,DEPTH_ATTACHMENTS,0);
        glBindFramebuffer(GL_FRAMEBUFFER,0);glViewport(0,0,getWidth(),getHeight());
        {float fit=Math.min((float)getWidth()/w,(float)getHeight()/h);int shownW=Math.round(w*fit),shownH=Math.round(h*fit);glClearColor(.025f,.04f,.06f,1);glClear(GL_COLOR_BUFFER_BIT);glViewport((getWidth()-shownW)/2,(getHeight()-shownH)/2,shownW,shownH);}
        lastGraphics=r.graphics;post(colorTexture,w,h,r.graphics.id);
    }
    private void useScene(SceneShader shader,Request r,RegraphicsGeometry g,int w,int h){
        glUseProgram(shader.program);glUniform1i(shader.quality,r.graphics.id);glUniform3f(shader.lampOrigin,lampFrame[0],lampFrame[1],lampFrame[2]);glUniform3f(shader.lampDirection,lampFrame[3]-lampFrame[0],lampFrame[4]-lampFrame[1],lampFrame[5]-lampFrame[2]);glUniform1f(shader.lampPower,frameLampPower);glUniform2f(shader.projection,g.width,g.height);glUniform1f(shader.aspect,(float)w/h);glUniform1f(shader.time,c12Frame[2]);glUniform1f(shader.day,c12Frame[3]);glUniform3f(shader.sun,sunX,sunY,sunZ);glUniform1f(shader.wet,c12Frame[0]);glUniform1f(shader.water,c12Frame[1]);
        glUniform1i(shader.palette,0);glUniform1i(shader.atlas,1);
    }
    private void post(int texture,int w,int h,int quality){glUseProgram(postProgram);glActiveTexture(GL_TEXTURE0);glBindTexture(GL_TEXTURE_2D,texture);glUniform1i(imageU,0);glUniform2f(texelU,1f/w,1f/h);glUniform1i(photoU,0);glUniform1i(postQualityU,quality);glDrawArrays(GL_TRIANGLES,0,3);}
    int outputWidth(){return targetWidth;}int outputHeight(){return targetHeight;}
}
