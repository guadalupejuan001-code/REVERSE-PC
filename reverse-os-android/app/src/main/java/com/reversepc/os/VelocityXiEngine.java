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
        final long xCm,zCm,ticks;
        final int yaw4096,speedCmps,slideCmps,checkpoint;
        final boolean finished,offRoad;
        Snapshot(long[] values){
            if(values==null||values.length!=9)throw new IllegalArgumentException("XI game output needs nine registers");
            xCm=values[0];zCm=values[1];yaw4096=(int)values[2];
            speedCmps=(int)values[3];slideCmps=(int)values[4];
            checkpoint=(int)values[5];ticks=values[6];
            finished=values[7]==1;offRoad=values[8]==1;
            if(xCm< -1_500_000||xCm>1_500_000||zCm< -1_500_000||zCm>1_500_000||
                    yaw4096<0||yaw4096>=4096||speedCmps<0||speedCmps>7800||
                    slideCmps< -2600||slideCmps>2600||checkpoint<0||checkpoint>6||
                    ticks<0||ticks>Integer.MAX_VALUE||values[7]<0||values[7]>1||
                    values[8]<0||values[8]>1)
                throw new IllegalArgumentException("XI game output beyond the bounded protocol");
        }
        int speedKmh(){return (int)Math.round(speedCmps*.036);}
        long seconds(){return ticks/50;}
    }

    private byte[] privateState,compiledXi;
    private final float[] worldPoints; // read-only XI generated geometry samples
    private Snapshot snapshot;

    VelocityXiEngine(Context context)throws Exception{
        String drive=asset(context,"velocity/drive.xi");
        String world=asset(context,"velocity/world.xi");
        if(!drive.startsWith("#!reverse-pc-machine-v1\n")||
           !world.startsWith("#!reverse-pc-machine-v1\n"))
            throw new IllegalStateException("XI game code header missing");
        compiledXi=NativeRuntime.compileRxe(
            drive.getBytes(StandardCharsets.UTF_8),
            "REVERSE VELOCITY XI".getBytes(StandardCharsets.UTF_8));
        ResultPacket generated=ResultPacket.parse(NativeRuntime.execute(NativeRuntime.initialize(),world));
        worldPoints=parseRoute(generated.output);
        privateState=NativeRuntime.initialize(); // isolated from REVERSE Desktop/BBY Q
        step(0,0,1,0,true);
        if(snapshot.ticks!=0)throw new IllegalStateException("XI game reset consumed a tick");
    }

    private static String asset(Context context,String path)throws Exception{
        try(InputStream in=context.getAssets().open(path)){
            ByteArrayOutputStream out=new ByteArrayOutputStream();
            byte[] buffer=new byte[8192];int n;
            while((n=in.read(buffer))>=0){
                if(out.size()+n>128*1024)throw new IllegalArgumentException("Velocity XI source exceeds limit");
                out.write(buffer,0,n);
            }
            return out.toString("UTF-8");
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
        if(numbers.size()!=482)throw new IllegalStateException("XI track requires 241 (z,x) points");
        float[] points=new float[numbers.size()];
        for(int i=0;i<numbers.size();i+=2){
            long z=numbers.get(i),x=numbers.get(i+1);
            if(z!=-85000L+(long)(i/2)*1000L||Math.abs(x)>8000)
                throw new IllegalStateException("XI track samples are out of range");
            points[i]=z/100.f;
            points[i+1]=x/100.f;
        }
        return points;
    }

    private static Snapshot parseState(String output)throws Exception{
        long[] observed=new long[9];int n=0;
        for(String line:output.split("\n")){
            if(line.trim().isEmpty())continue;
            if(n>=9)throw new IllegalArgumentException("XI game published too many registers");
            JSONObject row=new JSONObject(line);
            if(!"register".equals(row.getString("type"))||
               !("r"+n).equals(row.getString("register")))
                throw new IllegalArgumentException("XI game register order mismatch");
            observed[n++]=row.getLong("value");
        }
        if(n!=9)throw new IllegalArgumentException("Incomplete XI game observation");
        return new Snapshot(observed);
    }

    synchronized Snapshot step(int gas,int brake,int steer,int drift,boolean reset)throws Exception{
        if(gas<0||gas>1||brake<0||brake>1||steer<0||steer>2||
           drift<0||drift>1)throw new IllegalArgumentException("XI physical control out of range");
        ResultPacket result=ResultPacket.parse(NativeRuntime.velocityTick(
            privateState,compiledXi,gas,brake,steer,drift,reset?1:0));
        // Validate the observation BEFORE publishing the candidate snapshot.
        Snapshot observed=parseState(result.output);
        privateState=result.state;
        snapshot=observed;
        return observed;
    }
    synchronized Snapshot current(){return snapshot;}
    float[] track(){return worldPoints;} // Adapter must never mutate this array.
}
