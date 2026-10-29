package com.reversepc.os;

import android.content.Context;
import android.util.AtomicFile;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import org.json.JSONObject;

/** One guest session, serialized by RuntimeExecutor; desktop/BBY Q state is separate. */
public final class GuestStore {
    private final AtomicFile file;
    private final File cache;
    private static final long MAX_CHECKPOINT=256L*1024*1024;
    public GuestStore(Context context){file=new AtomicFile(new File(context.getFilesDir(),"guest-aarch64.rvg"));cache=context.getCacheDir();}
    private byte[] state()throws Exception{
        if(file.getBaseFile().length()>MAX_CHECKPOINT)throw new IllegalStateException("Checkpoint del invitado demasiado grande");
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
        if(!file.getBaseFile().exists()&&!new File(file.getBaseFile()+".bak").exists())return new JSONObject().put("ok",true).put("loaded",false);
        return report(current(),null,0,0,"").put("ok",true).put("loaded",true);
    }
    private File current()throws Exception{
        try(InputStream ignored=file.openRead()){} // Recover an interrupted AtomicFile publication.
        if(file.getBaseFile().length()>MAX_CHECKPOINT)throw new IllegalStateException("Checkpoint del invitado demasiado grande");
        return file.getBaseFile();
    }
    private static JSONObject report(File input,File output,int operation,int steps,String text)throws Exception{
        return new JSONObject(new String(NativeRuntime.guestFileOperation(input.getAbsolutePath(),
            output==null?null:output.getAbsolutePath(),operation,steps,text),StandardCharsets.UTF_8));
    }
    private static void copy(InputStream input,OutputStream output,long maximum)throws Exception{
        if(input==null)throw new IllegalArgumentException("Archivo no disponible");
        byte[] buffer=new byte[8192];long total=0;int count;
        while((count=input.read(buffer))!=-1){if(total>maximum-count)throw new IllegalArgumentException("Archivo del invitado demasiado grande");output.write(buffer,0,count);total+=count;}
    }
    private JSONObject publish(File candidate,JSONObject result)throws Exception{
        FileOutputStream output=null;
        try(InputStream input=new FileInputStream(candidate)){
            output=file.startWrite();copy(input,output,MAX_CHECKPOINT);file.finishWrite(output);output=null;
        }catch(Exception error){if(output!=null)file.failWrite(output);throw error;}
        return result.put("ok",true).put("loaded",true);
    }
    private JSONObject fileOperation(int operation,int steps,String text)throws Exception{
        File candidate=File.createTempFile("reverse-guest-",".candidate",cache);
        try{return publish(candidate,report(current(),candidate,operation,steps,text));}
        finally{candidate.delete();}
    }
    public JSONObject importCheckpoint(InputStream input)throws Exception{
        File candidate=File.createTempFile("reverse-guest-import-",".rvg",cache);
        try{
            try(OutputStream output=new FileOutputStream(candidate)){copy(input,output,MAX_CHECKPOINT);}
            return publish(candidate,report(candidate,null,0,0,""));
        }finally{candidate.delete();}
    }
    public JSONObject importLinuxImage(InputStream input)throws Exception{
        File image=File.createTempFile("reverse-linux-",".image",cache),candidate=null;
        try{
            try(OutputStream output=new FileOutputStream(image)){copy(input,output,64L*1024*1024);}
            candidate=File.createTempFile("reverse-guest-",".candidate",cache);
            return publish(candidate,report(image,candidate,4,0,""));
        }finally{image.delete();if(candidate!=null)candidate.delete();}
    }
    public JSONObject create(byte[] elf)throws Exception{return commit(NativeRuntime.guestInitialize(elf,1L<<30,65536));}
    public JSONObject createSystem(byte[] image,int kind)throws Exception{return commit(NativeRuntime.guestInitializeSystem(image,kind));}
    public JSONObject input(String text)throws Exception{
        if(text==null||text.getBytes(java.nio.charset.StandardCharsets.UTF_8).length>4096)throw new IllegalArgumentException("Entrada de consola supera 4096 bytes");
        return fileOperation(3,0,text);
    }
    public JSONObject run(int steps)throws Exception{
        if(steps<1||steps>10000)throw new IllegalArgumentException("Pasos: 1..10000");
        return fileOperation(1,steps,"");
    }
    public JSONObject runContinuous()throws Exception{return fileOperation(1,250000,"");}
    public JSONObject xi(String source)throws Exception{
        if(source==null||source.getBytes(java.nio.charset.StandardCharsets.UTF_8).length>65536)
            throw new IllegalArgumentException("Programa XI del delta supera 64 KiB");
        return fileOperation(2,0,source);
    }
    public byte[] export()throws Exception{return state();}
    public void exportTo(OutputStream output)throws Exception{
        try(InputStream input=file.openRead()){copy(input,output,MAX_CHECKPOINT);}
    }
    public static byte[] readElf(InputStream input)throws Exception{
        if(input==null)throw new IllegalArgumentException("Archivo no disponible");
        ByteArrayOutputStream bytes=new ByteArrayOutputStream();byte[] block=new byte[8192];int count;
        while((count=input.read(block))!=-1){if(bytes.size()>16*1024*1024-count)throw new IllegalArgumentException("ELF supera 16 MiB");bytes.write(block,0,count);}
        return bytes.toByteArray();
    }
}
