package com.reversepc.os;

import android.content.Context;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONObject;

/**
 * Physical input -> XI RXE transaction -> immutable observation.
 *
 * The authoritative game state is the private RVPC2 snapshot owned by
 * QuantumRuntime / InverseMemory. This class implements no driving equations,
 * no road equation, no checkpoint rules, and no graphics engine.
 */
final class VelocityXiEngine {
    static final class Snapshot {
        // Assigned once before the immutable observation is published.
        long publication;
        final long xCm,zCm,ticks,totalProgress;
        final int yaw4096,speedCmps,slideCmps,checkpoint,position,laps,trackS,segment,countdown;
        final boolean finished,offRoad,wallContact,nitroActive,landingPulse;
        final int nitroCharge,jumpHeightCm,airPulse,jumpCooldown;
        final int driftScore,driftComboPct,surface;
        final boolean drafting;
        final boolean openWorld,roadEnd;
        final int groundHeightCm,sector,dayPhase,ambientMode,biome;
        final int waterDepthCm,wetness,splash;
        final int forwardGear,engineRpm,gearSelection;
        Snapshot(long[] values){
            if(values==null||(values.length!=26&&values.length!=32&&values.length!=35&&values.length!=38))throw new IllegalArgumentException("XI output needs 26, 32, 35 or 38 world registers");
            for(int i=2;i<values.length;i++)if(values[i]<Integer.MIN_VALUE||values[i]>Integer.MAX_VALUE)
                throw new IllegalArgumentException("XI race register exceeds integer range");
            xCm=values[0];zCm=values[1];yaw4096=(int)values[2];
            speedCmps=(int)values[3];slideCmps=(int)values[4];
            checkpoint=(int)values[5];ticks=values[6];
            finished=values[7]==1;offRoad=values[8]==1;
            position=(int)values[9];laps=(int)values[10];trackS=(int)values[11];
            segment=(int)values[12];countdown=(int)values[13];wallContact=values[14]==1;
            totalProgress=values[15];
            nitroCharge=(int)values[16];nitroActive=values[17]==1;
            jumpHeightCm=(int)values[18];airPulse=(int)values[19];
            jumpCooldown=(int)values[20];landingPulse=values[21]==1;
            driftScore=(int)values[22];driftComboPct=(int)values[23];
            drafting=values[24]==1;surface=(int)values[25];
            openWorld=values.length>=32;
            groundHeightCm=openWorld?(int)values[26]:0;sector=openWorld?(int)values[27]:0;
            dayPhase=openWorld?(int)values[28]:0;ambientMode=openWorld?(int)values[29]:0;
            biome=openWorld?(int)values[30]:0;roadEnd=openWorld&&values[31]==1;
            waterDepthCm=values.length>=35?(int)values[32]:0;
            wetness=values.length>=35?(int)values[33]:0;splash=values.length>=35?(int)values[34]:0;
            forwardGear=values.length>=38?(int)values[35]:1;
            engineRpm=values.length>=38?(int)values[36]:800;
            gearSelection=values.length>=38?(int)values[37]:0;
            if(forwardGear<1||forwardGear>6||engineRpm<0||engineRpm>7200||gearSelection<0||gearSelection>6)
                throw new IllegalArgumentException("XI powertrain observation outside limits");
            if(waterDepthCm<0||waterDepthCm>40||wetness<0||wetness>1000||splash<0||splash>255)
                throw new IllegalArgumentException("XI wetland observation outside limits");
            if(groundHeightCm<0||groundHeightCm>4096||sector<0||sector>7||dayPhase<0||dayPhase>=4096||ambientMode<0||ambientMode>2||biome<0||biome>5)
                throw new IllegalArgumentException("XI world state outside limits");
            if(driftScore<0||driftScore>9_999_999||driftComboPct<100||driftComboPct>400||
                    values[24]<0||values[24]>1||surface<0||surface>4)
                throw new IllegalArgumentException("XI drift/rebufo/surface state outside limits");
            if(nitroCharge<0||nitroCharge>1000||values[17]<0||values[17]>1||
                    jumpHeightCm<0||jumpHeightCm>600||airPulse<0||airPulse>30||
                    jumpCooldown<0||jumpCooldown>90||values[21]<0||values[21]>1)
                throw new IllegalArgumentException("XI air/nitro state outside physical bounds");
            if(xCm< -1_000_000_000L||xCm>1_000_000_000L||zCm< -1_000_000_000L||zCm>1_000_000_000L||
                    yaw4096<0||yaw4096>=4096||speedCmps<0||speedCmps>6500||
                    slideCmps< -6500||slideCmps>6500||checkpoint<0||checkpoint>12||
                    ticks<0||ticks>Integer.MAX_VALUE||values[7]<0||values[7]>1||
                    values[8]<0||values[8]>1||position<1||position>4||laps<0||laps>3||
                    trackS<0||trackS>=160000||segment<0||segment>=80||countdown<0||countdown>150||
                    values[14]<0||values[14]>1||totalProgress<0||totalProgress>1_000_000)
                throw new IllegalArgumentException("XI game output beyond the bounded protocol");
        }
        int speedKmh(){return (int)Math.round(speedCmps*.036);}
        int nitroPercent(){return nitroCharge/10;}
        long seconds(){return ticks/50;}
        int displayedLap(){return Math.min(3,laps+1);}
    }

    private volatile long liveSession;
    private volatile boolean closed;
    private final String[] resourceNames;
    private final String driveXi;
    private final String xiRenderer;
    private final String xiGpuRenderer;
    private final Object renderSourceLock=new Object();
    private String renderProgramCache,driveProgramCache;
    private final Object gpuStateLock=new Object();
    private RegraphicsGeometry retainedGpuGeometry;
    private long retainedGpuIdentity,retainedGpuRevision;
    private int retainedPalettePhase=-1;
    private int[] retainedPalette;
    private long qssdFrames,qssdExecutions,qssdProjectionBytes,qssdGeometryBytes,qssdSharedDeliveries;
    private static final int[] GPU_ADDRESSES={200,201,202,203,204,205,206,207,141};
    private int renderProgramKey=-1,driveProgramKey=-1;
    private static final String XI_HEADER="#!reverse-pc-machine-v1\n";
    private final float[] worldPoints; // read-only XI generated geometry samples
    private final int[] palette,paletteDusk,paletteNight;
    private final String environmentXi;
    private volatile int environmentMode;
    private volatile Snapshot snapshot;
    static final class Observation {
        final RegraphicsFrame frame;
        final Snapshot state;
        // Measured using the same monotonic Java clock as the display worker.
        // executeNanos includes native XI preparation and wire transport;
        // decodeNanos covers exact reconstruction and geometry validation.
        final long executeNanos,decodeNanos;
        final int payloadBytes;
        final RegraphicsGeometry geometry;
        final int[] colors;
        final long qssdIdentity,qssdRevision,qssdSession; // Native lease plus session epoch.
        Observation(RegraphicsFrame frame,Snapshot state,long executeNanos,
                    long decodeNanos,int payloadBytes){
            this.frame=frame;this.state=state;
            this.executeNanos=executeNanos;this.decodeNanos=decodeNanos;
            this.payloadBytes=payloadBytes;
            geometry=null;colors=null;qssdIdentity=0;qssdRevision=0;qssdSession=0;
        }
        Observation(RegraphicsGeometry geometry,int[] colors,Snapshot state,long executeNanos,long decodeNanos,int bytes,long identity,long revision,long session){
            frame=null;this.geometry=geometry;this.colors=colors;this.state=state;this.executeNanos=executeNanos;this.decodeNanos=decodeNanos;payloadBytes=bytes;qssdIdentity=identity;qssdRevision=revision;qssdSession=session;
        }
    }

    VelocityXiEngine(Context context)throws Exception{
        String[] names=context.getAssets().list("velocity");
        if(names==null||names.length==0)throw new IllegalStateException("Missing Velocity resources");
        java.util.Arrays.sort(names);resourceNames=names.clone();byte[][] data=new byte[names.length][];String world=null;
        for(int i=0;i<names.length;i++){
            try(InputStream in=context.getAssets().open("velocity/"+names[i]);ByteArrayOutputStream out=new ByteArrayOutputStream()){
                byte[] scratch=new byte[8192];int count;
                while((count=in.read(scratch))>=0){if(out.size()+count>1024*1024)throw new IllegalArgumentException("Velocity resource budget");out.write(scratch,0,count);}
                data[i]=out.toByteArray();
            }
            if(names[i].equals("world.xi"))world=new String(data[i],StandardCharsets.UTF_8);
        }
        if(world==null||!world.startsWith(XI_HEADER))throw new IllegalStateException("XI world source header missing");
        ResultPacket generated=ResultPacket.parse(NativeRuntime.execute(NativeRuntime.initialize(),world));
        worldPoints=parseRoute(generated.output);liveSession=NativeRuntime.sessionOpen(generated.state);
        try{
            NativeRuntime.sessionRegisterResources(liveSession,names,data);
            driveXi=resourceText("drive.xi");xiRenderer=resourceText("render-live.xi");xiGpuRenderer=resourceText("render4k.xi");
            palette=parsePalette(resourceText("palette.txt"));paletteDusk=parsePalette(resourceText("palette-dusk.txt"));paletteNight=parsePalette(resourceText("palette-night.txt"));
            environmentXi=resourceText("environment.xi");
            if(!driveXi.startsWith(XI_HEADER)||!xiRenderer.startsWith(XI_HEADER)||!xiGpuRenderer.startsWith(XI_HEADER))throw new IllegalStateException("XI program header missing");
            NativeRuntime.sessionSetGeometryProgram(liveSession,xiGpuRenderer);
            step(0,0,1,0,false,true);
            if(snapshot.ticks!=0)throw new IllegalStateException("XI game reset consumed a tick");
            NativeRuntime.sessionBookmark(liveSession,"start");
            android.util.Log.i("ReverseVelocity","QSSD_SPACE_READY "+NativeRuntime.sessionInspectSpace(liveSession));
        }catch(Exception failure){close();throw failure;}
    }
    synchronized String resourceText(String name){return new String(NativeRuntime.sessionReadResource(liveSession,name),StandardCharsets.UTF_8);}
    synchronized byte[] checkpointSpace(byte[] view)throws Exception{
        if(closed)throw new IllegalStateException("XI session closed");
        synchronized(gpuStateLock){
            NativeRuntime.sessionSetComponent(liveSession,"view",view);
            NativeRuntime.sessionSetComponent(liveSession,"environment",new byte[]{(byte)environmentMode});
            NativeRuntime.sessionBookmark(liveSession,"saved");
            byte[] bytes=NativeRuntime.sessionCheckpointSpace(liveSession);
            android.util.Log.i("ReverseVelocity","QSSD_CHECKPOINT bytes="+bytes.length+" ticks="+snapshot.ticks+" space="+NativeRuntime.sessionInspectSpace(liveSession));
            return bytes;
        }
    }
    synchronized byte[] restoreSpace(byte[] archive)throws Exception{
        if(closed)throw new IllegalStateException("XI session closed");
        synchronized(gpuStateLock){
            long candidate=NativeRuntime.sessionOpenSpace(archive);boolean accepted=false;
            try{
                JSONObject info=new JSONObject(NativeRuntime.sessionInspectSpace(candidate));
                if(info.getInt("resources")!=resourceNames.length)throw new IllegalArgumentException("El inventario de recursos no coincide");
                for(String name:resourceNames)if(!java.util.Arrays.equals(NativeRuntime.sessionReadResource(liveSession,name),NativeRuntime.sessionReadResource(candidate,name)))
                    throw new IllegalArgumentException("El estado pertenece a otra versión de los recursos: "+name);
                byte[] view=NativeRuntime.sessionGetComponent(candidate,"view");VelocitySessionState.decode(view);
                byte[] environment=NativeRuntime.sessionGetComponent(candidate,"environment");
                if(environment.length!=1||environment[0]<0||environment[0]>3)throw new IllegalArgumentException("Invalid stored environment mode");
                Snapshot restored=parseState(new String(NativeRuntime.sessionStateOutput(candidate),StandardCharsets.UTF_8));
                JSONObject space=new JSONObject(NativeRuntime.sessionInspectSpace(candidate));restored.publication=space.getLong("cpu_generation");
                long previous=liveSession;liveSession=candidate;snapshot=restored;environmentMode=environment[0];
                retainedGpuGeometry=null;retainedGpuIdentity=retainedGpuRevision=0;driveProgramKey=renderProgramKey=-1;
                qssdFrames=qssdExecutions=qssdProjectionBytes=qssdGeometryBytes=qssdSharedDeliveries=0;
                accepted=true;NativeRuntime.sessionClose(previous);
                android.util.Log.i("ReverseVelocity","QSSD_RESTORED ticks="+restored.ticks+" space="+NativeRuntime.sessionInspectSpace(candidate));
                return view;
            }finally{if(!accepted)NativeRuntime.sessionClose(candidate);}
        }
    }

    private static float[] parseRoute(String text)throws Exception{
        List<Long> numbers=new ArrayList<>();
        for(String line:text.split("\n")){
            if(line.trim().isEmpty())continue;
            JSONObject row=new JSONObject(line);
            if(!"register".equals(row.getString("type")))
                throw new IllegalStateException("Track output is not XI register data");
            numbers.add(row.getLong("value"));
        }
        if(numbers.size()!=162)throw new IllegalStateException("XI circuit requires 81 (x,z) points");
        float[] points=new float[numbers.size()];
        for(int i=0;i<numbers.size();i+=2){
            long x=numbers.get(i),z=numbers.get(i+1);
            if(Math.abs(x)>1_500_000||Math.abs(z)>1_500_000)
                throw new IllegalStateException("XI track samples are out of range");
            points[i]=x/100.f;
            points[i+1]=z/100.f;
        }
        return points;
    }

    private static Snapshot parseState(String output)throws Exception{
        long[] observed=new long[38];int n=0;
        for(String line:output.split("\n")){
            if(line.trim().isEmpty())continue;
            if(n>=38)throw new IllegalArgumentException("XI game published too many registers");
            JSONObject row=new JSONObject(line);
            if(!"register".equals(row.getString("type"))||
               !("r"+(n%16)).equals(row.getString("register")))
                throw new IllegalArgumentException("XI game register order mismatch");
            observed[n++]=row.getLong("value");
        }
        if(n!=26&&n!=32&&n!=35&&n!=38)throw new IllegalArgumentException("Incomplete XI game observation");
        return new Snapshot(java.util.Arrays.copyOf(observed,n));
    }

    synchronized Snapshot step(int gas,int brake,int steer,int drift,boolean reverse,boolean reset)throws Exception{
        return step(gas,brake,steer,drift,false,false,reverse,reset);
    }
    synchronized Snapshot step(int gas,int brake,int steer,int drift,boolean nitro,boolean jump,boolean reverse,boolean reset)throws Exception{
        return step(gas,brake,steer,drift,nitro,jump,reverse,reset,0);
    }
    synchronized Snapshot step(int gas,int brake,int steer,int drift,boolean nitro,boolean jump,boolean reverse,boolean reset,int assistMode)throws Exception{
        return step(gas,brake,steer,drift,nitro,jump,reverse,reset,assistMode,255);
    }
    synchronized Snapshot step(int gas,int brake,int steer,int drift,boolean nitro,boolean jump,boolean reverse,boolean reset,int assistMode,int analog)throws Exception{
        return step(gas,brake,steer,drift,nitro,jump,reverse,reset,assistMode,analog,0);
    }
    synchronized Snapshot step(int gas,int brake,int steer,int drift,boolean nitro,boolean jump,boolean reverse,boolean reset,int assistMode,int analog,int gearSelection)throws Exception{
        if(gearSelection<0||gearSelection>6)throw new IllegalArgumentException("XI forward gear selector");
        if(analog<0||(analog>200&&analog!=255))throw new IllegalArgumentException("Analog steering protocol");
        if(assistMode<0||assistMode>2)throw new IllegalArgumentException("XI assistant mode outside 0..2");
        if(gas<0||gas>1||brake<0||brake>1||steer<0||steer>2||
           drift<0||drift>1)throw new IllegalArgumentException("XI physical control out of range");
        // Execute the XI source through the *existing* generic runtime.
        // There is no game-specific JNI/C++ renderer, physics or instruction API.
        final int programKey=gas|(brake<<1)|(steer<<2)|(drift<<4)|(reset?32:0)|(reverse?64:0)|(nitro?128:0)|(jump?256:0)|(assistMode<<10)|(analog<<12)|(gearSelection<<20);
        if(programKey!=driveProgramKey){
            driveProgramCache=XI_HEADER+
                "store8 128 "+gas+"\nstore8 129 "+brake+
                "\nstore8 130 "+steer+"\nstore8 131 "+drift+
                "\nstore8 132 "+(reset?1:0)+"\nstore8 133 "+(reverse?1:0)+
                 "\nstore8 134 "+(nitro?1:0)+"\nstore8 135 "+(jump?1:0)+
                 "\nstore8 136 "+assistMode+"\nstore8 138 "+analog+"\nstore8 142 "+gearSelection+"\n"+
                driveXi.substring(XI_HEADER.length());
            driveProgramKey=programKey;
        }
        return executeValidated(driveProgramCache);
    }
    /**
     * Execute the actual XI renderer on a private snapshot. No Java geometry,
     * projection, shading or collision equations are implemented here.
     * Host validates and unpacks the bounded surface observations only.
     */
    RegraphicsFrame renderFrame(int stride,int camera,int paint)throws Exception{
        return observeFrame(stride,camera,paint).frame;
    }
    Observation observeGpuFrame(int camera,int paint,int car,int yaw,int pitch)throws Exception{return observeGpuFrame(camera,paint,car,yaw,pitch,2,null);}
    Observation observeGpuFrame(int camera,int paint,int car,int yaw,int pitch,int quality,byte[] viewState)throws Exception{
        // Lifecycle replacement workers may briefly overlap while native work
        // finishes. Keep wire sequence + Java base atomic, without locking physics.
        synchronized(gpuStateLock){return observeGpuFrameLocked(camera,paint,car,yaw,pitch,quality,viewState);}
    }
    private Observation observeGpuFrameLocked(int camera,int paint,int car,int yaw,int pitch,int quality,byte[] viewState)throws Exception{
        if(camera<0||camera>2||paint<0||paint>4||car<0||car>=3||yaw<0||yaw>=4096||pitch<0||pitch>=512)
            throw new IllegalArgumentException("XI GPU view controls outside range");
        final byte[] inputs={1,(byte)camera,(byte)paint,(byte)car,(byte)yaw,(byte)(yaw>>>8),(byte)pitch,(byte)(pitch>>>8),1};
        long start=System.nanoTime();
        long sessionHandle=liveSession;
        XiSharedGeometryPacket packet=NativeRuntime.sessionObserveSharedGeometryView(sessionHandle,GPU_ADDRESSES,inputs,quality,viewState);
        long execute=System.nanoTime()-start;start=System.nanoTime();
        Snapshot state=observedState(packet.output,packet.publication);
        RegraphicsGeometry geometry=retainedGpuGeometry!=null&&retainedGpuIdentity==packet.identity&&retainedGpuRevision==packet.revision?
            retainedGpuGeometry:RegraphicsGeometry.decodeShared(packet.frame);
        retainedGpuGeometry=geometry;
        retainedGpuIdentity=packet.identity;retainedGpuRevision=packet.revision;
        if(retainedPalette==null||retainedPalettePhase!=state.dayPhase){
            retainedPalette=VelocityWorldLight.palette(palette,paletteDusk,paletteNight,state.dayPhase);
            retainedPalettePhase=state.dayPhase;
        }
        int[] colors=retainedPalette;
        qssdFrames++;qssdExecutions+=packet.executed?1:0;qssdProjectionBytes+=packet.materializedBytes;
        qssdGeometryBytes+=packet.frame.limit();qssdSharedDeliveries+=packet.materializedBytes==0?1:0;
        if(qssdFrames%60==0)android.util.Log.i("ReverseVelocity","QSSD_LINK frames="+qssdFrames+
            " executions="+qssdExecutions+" sharedDeliveries="+qssdSharedDeliveries+" projectionBytes="+qssdProjectionBytes+
            " geometryBytes="+qssdGeometryBytes+" deltaReconstructions=0 readOnly=true source=XI_XFG4");
        // The numeric register observation is ASCII. Count its envelope and the
        // explicit physical projection, rather than reporting fictional zero I/O.
        int projected=(int)packet.materializedBytes+packet.output.length()+40;
        return new Observation(geometry,colors,state,execute,System.nanoTime()-start,projected,packet.identity,packet.revision,sessionHandle);
    }
    Observation observeFrame(int stride,int camera,int paint)throws Exception{
        return observeFrame(stride,camera,paint,0);
    }
    Observation observeFrame(int stride,int camera,int paint,int car)throws Exception{
        return observeFrame(stride,camera,paint,car,0,0);
    }
    Observation observeFrame(int stride,int camera,int paint,int car,int yaw,int pitch)throws Exception{
        if(yaw<0||yaw>=4096||pitch<0||pitch>=512)
            throw new IllegalArgumentException("XI camera orbit outside 4096-step circle");
        if(car<0||car>=3)throw new IllegalArgumentException("Unknown XI car silhouette");
        if(stride!=1&&stride!=2&&stride!=4)throw new IllegalArgumentException("XI frame stride must be 1,2 or 4");
        if(camera<0||camera>2||paint<0||paint>4)throw new IllegalArgumentException("XI visual input out of range");
        final String source;
        final int programKey=(((stride*3+camera)*5+paint)*3+car)*2097152+
            yaw*512+pitch;
        // Cache one authored program, independently of the physics monitor.
        // Observations and state remain fresh on every execution.
        synchronized(renderSourceLock){
            if(programKey!=renderProgramKey){
                renderProgramCache=XI_HEADER+"store8 200 "+stride+
                    "\nstore8 201 "+camera+"\nstore8 202 "+paint+
                    "\nstore8 203 "+car+"\nstore16 204 "+yaw+
                    "\nstore16 206 "+pitch+"\n"+
                    xiRenderer.substring(XI_HEADER.length());
                renderProgramKey=programKey;
            }
            source=renderProgramCache;
        }
        // Original binary frame plus a small coherent register observation.
        // Compact RVPC2 is retained natively instead of crossing JNI per frame.

        // Native observations execute on a private immutable copy. The physics
        // transaction can advance independently while this image is produced.
        final long executeStart=System.nanoTime();
        final byte[] packetBytes=NativeRuntime.sessionObserve(liveSession,source,new int[0],new byte[0]);
        final long executeElapsed=System.nanoTime()-executeStart;
        final long decodeStart=System.nanoTime();
        final XiObservationPacket packet=XiObservationPacket.parse(packetBytes);
        final Snapshot observedState=observedState(packet);
        final byte[] frameBytes=packet.frame;
        final RegraphicsFrame frame=RegraphicsFrame.decodeLiveNativeOwned(frameBytes,stride,VelocityWorldLight.palette(palette,paletteDusk,paletteNight,observedState.dayPhase));
        final long decodeElapsed=System.nanoTime()-decodeStart;
        return new Observation(frame,observedState,executeElapsed,decodeElapsed,frameBytes.length);
    }
    private static int[] parsePalette(String source){
        String[] entries=source.trim().split("\n");
        if(entries.length!=256)throw new IllegalArgumentException("REgraphics palette size mismatch");
        int[] palette=new int[entries.length];
        for(int i=0;i<entries.length;i++){
            if(!entries[i].matches("[0-9a-f]{6}"))throw new IllegalArgumentException("Invalid palette color");
            palette[i]=Integer.parseInt(entries[i],16);
        }
        return palette;
    }
    synchronized Snapshot setEnvironmentMode(int mode)throws Exception{
        if(mode<0||mode>3)throw new IllegalArgumentException("Unknown world time mode");
        Snapshot candidate=executeValidated(XI_HEADER+"store8 137 "+mode+"\n"+
            environmentXi.substring(XI_HEADER.length()));
        environmentMode=mode;return candidate;
    }
    private Snapshot executeValidated(String source)throws Exception{
        if(closed)throw new IllegalStateException("XI session closed");
        byte[] output=NativeRuntime.sessionStage(liveSession,source);
        try {
            Snapshot candidate=parseState(new String(output,StandardCharsets.UTF_8));
            candidate.publication=NativeRuntime.sessionCommit(liveSession);
            snapshot=candidate;return candidate;
        } catch(Exception rejected) {
            NativeRuntime.sessionDiscard(liveSession);throw rejected;
        }
    }
    synchronized void close(){if(!closed){closed=true;NativeRuntime.sessionClose(liveSession);}}
    private Snapshot observedState(XiObservationPacket packet)throws Exception{
        return observedState(packet.output,packet.publication);
    }
    private Snapshot observedState(String output,long publication)throws Exception{
        Snapshot current=snapshot;
        if(current!=null&&current.publication==publication)return current;
        Snapshot observed=parseState(output);observed.publication=publication;return observed;
    }
    int environmentMode(){return environmentMode;}
    Snapshot current(){return snapshot;}
    float[] track(){return worldPoints.clone();} // Read-only circuit samples for HUD.
}
