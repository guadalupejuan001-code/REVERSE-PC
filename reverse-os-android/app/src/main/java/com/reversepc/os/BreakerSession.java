package com.reversepc.os;

import android.content.Context;
import android.util.AtomicFile;
import org.json.JSONObject;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.Arrays;

/** Private RVPC2 checkpoint; all gameplay is executed by the packaged XI RXE. */
final class BreakerSession {
    static final String ASSET="native-games/REVERSE-BREAKER.rxe";
    final byte[] executable;
    private byte[] state;
    private final AtomicFile checkpoint;
    static final class Frame {
        final int[] values;
        Frame(String output)throws Exception{
            values=new int[18];int n=0;
            for(String line:output.split("\n"))if(line.startsWith("{")){JSONObject row=new JSONObject(line);if(row.has("value")){if(n==18)throw new IllegalStateException("Salida de juego excesiva");values[n++]=row.getInt("value");}}
            if(n!=18||values[6]<0||values[6]>3||values[7]<0||values[7]>3||values[8]<1||values[8]>5||values[9]<0||values[9]>50)throw new IllegalStateException("Salida de juego inválida");
        }
        int get(int index){return values[index];}
    }
    BreakerSession(Context context)throws Exception{
        try(InputStream input=context.getAssets().open(ASSET)){executable=WorkbenchPrograms.read(input);}
        NativeRuntime.inspectRxe(executable);
        checkpoint=new AtomicFile(new File(context.getFilesDir(),"reverse-breaker-v1.rvp"));
        if(checkpoint.getBaseFile().length()>256*1024)throw new IllegalStateException("Partida demasiado grande");
        state=checkpoint.getBaseFile().exists()?checkpoint.readFully():new byte[0];
    }
    static boolean recognizes(Context context,byte[] image)throws Exception{
        try(InputStream input=context.getAssets().open(ASSET)){return Arrays.equals(image,WorkbenchPrograms.read(input));}
    }
    Frame step(int paddle,int command,int ticks)throws Exception{
        ResultPacket result=ResultPacket.parse(NativeRuntime.gameFrame(state,executable,paddle,command,ticks));
        Frame frame=new Frame(result.output);state=result.state;return frame;
    }
    void save()throws Exception{
        if(state==null||state.length==0)return;
        FileOutputStream output=null;
        try{output=checkpoint.startWrite();output.write(state);checkpoint.finishWrite(output);}
        catch(Exception error){if(output!=null)checkpoint.failWrite(output);throw error;}
    }
    int stateBytes(){return state.length;}
}
