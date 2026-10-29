package com.reversepc.os;

import android.content.Context;
import org.json.JSONObject;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

/**
 * REexplorer Q-Core is a native XI/Ether state machine owned by the browser,
 * not an agent and not BBY Q. Only typed security events enter this machine.
 *
 * NativeRuntime's RVPC2 checkpoint is created afresh in the browser process
 * and is never written into REVERSE's OS or BBY Q session.
 *
 * Q-state is the project's compact state representation, not physical
 * quantum networking, post-quantum cryptography or a new HTML engine.
 */
final class ReexplorerQuantumCore {
    static final int NAVIGATE=0,TLS=1,KNOWN_THREAT=2,PERMISSION=3,
            DOWNLOAD=4,RENDERER=5,ORIGIN_CHANGE=6,POPUP=7;
    static final int ALLOW=0,BLOCK=2,QUARANTINE=3;
    static final long B=9100000000000000000L;
    private final String program;
    private byte[] state;
    private boolean quarantined;

    static final class Verdict {
        final int action,reason,denials;
        Verdict(int action,int reason,int denials){
            this.action=action;this.reason=reason;this.denials=denials;
        }
        boolean allow(){return action==ALLOW;}
        boolean quarantined(){return action==QUARANTINE;}
    }

    ReexplorerQuantumCore(Context context)throws Exception{
        try(InputStream input=context.getAssets().open("reexplorer/navigation-core.xi");
            ByteArrayOutputStream bytes=new ByteArrayOutputStream()){
            byte[] buf=new byte[4096];
            int count;
            while((count=input.read(buf))!=-1){
                if(bytes.size()+count>32768)throw new IllegalStateException("Núcleo XI supera el límite");
                bytes.write(buf,0,count);
            }
            String raw=bytes.toString(StandardCharsets.UTF_8.name());
            if(!raw.startsWith("#!reverse-pc-machine-v1\n"))
                throw new IllegalStateException("REexplorer carece de un núcleo XI válido");
            program=raw.substring(raw.indexOf('\n')+1);
        }
        state=NativeRuntime.initialize(); // Isolated: no BBY Q or OS checkpoint.
        NativeRuntime.inspect(state);      // Fail closed if kernel is unavailable.
    }

    /**
     * Called only for top-level navigation or high-priority security events;
     * no passwords, DOM, cookie strings or page contents are ever serialized.
     * The Android WebView and ReexplorerPolicy remain hard security boundaries.
     */
    synchronized Verdict decide(int event,int flags,int mode){
        if(quarantined)return new Verdict(QUARANTINE,90,3);
        if(event<0||event>7||flags<0||flags>7||mode<0||mode>1)
            return new Verdict(BLOCK,98,0);
        try{
            String source="#!reverse-pc-machine-v1\n"+
                    "store8 "+B+" "+event+"\n"+
                    "store8 "+(B+1)+" "+flags+"\n"+
                    "store8 "+(B+2)+" "+mode+"\n"+
                    program;
            ResultPacket packet=ResultPacket.parse(NativeRuntime.execute(state,source));
            int[] values={-1,-1,-1};
            boolean[] seen={false,false,false};
            for(String line:packet.output.split("\n")){
                if(!line.startsWith("{"))continue;
                JSONObject item=new JSONObject(line);
                if(!"register".equals(item.optString("type")))continue;
                String reg=item.optString("register");
                int index="r0".equals(reg)?0:"r1".equals(reg)?1:"r2".equals(reg)?2:-1;
                if(index<0||seen[index])throw new IllegalStateException("Salida XI inesperada");
                values[index]=item.getInt("value");
                seen[index]=true;
            }
            if(!seen[0]||!seen[1]||!seen[2]||
                    (values[0]!=ALLOW&&values[0]!=BLOCK&&values[0]!=QUARANTINE)||
                    values[1]<0||values[1]>255||values[2]<0||values[2]>3)
                throw new IllegalStateException("Decisión XI inválida");
            state=packet.state; // Commit after full response verification only.
            if(values[0]==QUARANTINE)quarantined=true;
            return new Verdict(values[0],values[1],values[2]);
        }catch(Throwable failure){
            // A native/packet error must never authorize an outgoing request.
            quarantined=true;
            return new Verdict(QUARANTINE,97,3);
        }
    }

    synchronized boolean isQuarantined(){return quarantined;}
}
