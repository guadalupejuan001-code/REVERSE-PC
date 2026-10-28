package com.reversepc.os;

import android.content.Context;
import android.util.AtomicFile;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import org.json.JSONObject;

/** One guest session, serialized by RuntimeExecutor; desktop/BBY Q state is separate. */
public final class GuestStore {
    private final AtomicFile file;
    public GuestStore(Context context){file=new AtomicFile(new File(context.getFilesDir(),"guest-aarch64.rvg"));}
    private byte[] state()throws Exception{
        if(file.getBaseFile().length()>32L*1024*1024)throw new IllegalStateException("Checkpoint del invitado demasiado grande");
        return file.readFully();
    }
    private JSONObject commit(byte[] packet)throws Exception{
        ResultPacket result=ResultPacket.parse(packet);
        JSONObject report=new JSONObject(result.output);
        FileOutputStream output=null;
        try{output=file.startWrite();output.write(result.state);file.finishWrite(output);}
        catch(Exception error){if(output!=null)file.failWrite(output);throw error;}
        return report.put("ok",true).put("loaded",true);
    }
    public JSONObject inspect()throws Exception{
        if(!file.getBaseFile().exists())return new JSONObject().put("ok",true).put("loaded",false);
        byte[] saved=state();
        return new JSONObject().put("ok",true).put("loaded",true).put("snapshot_bytes",saved.length)
            .put("guest",new JSONObject(NativeRuntime.guestInspect(saved)));
    }
    public JSONObject create(byte[] elf)throws Exception{return commit(NativeRuntime.guestInitialize(elf,1L<<30,65536));}
    public JSONObject run(int steps)throws Exception{return commit(NativeRuntime.guestRun(state(),steps));}
    public JSONObject xi(String source)throws Exception{
        if(source==null||source.getBytes(java.nio.charset.StandardCharsets.UTF_8).length>65536)
            throw new IllegalArgumentException("Programa XI del delta supera 64 KiB");
        return commit(NativeRuntime.guestXi(state(),source));
    }
    public byte[] export()throws Exception{return state();}
    public static byte[] readElf(InputStream input)throws Exception{
        if(input==null)throw new IllegalArgumentException("Archivo no disponible");
        ByteArrayOutputStream bytes=new ByteArrayOutputStream();byte[] block=new byte[8192];int count;
        while((count=input.read(block))!=-1){if(bytes.size()>16*1024*1024-count)throw new IllegalArgumentException("ELF supera 16 MiB");bytes.write(block,0,count);}
        return bytes.toByteArray();
    }
}
