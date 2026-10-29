package com.reversepc.os;

import android.content.Context;
import android.util.AtomicFile;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.nio.charset.StandardCharsets;
import android.graphics.Bitmap;
import android.util.Base64;
import org.json.JSONObject;

/** One guest session, serialized by RuntimeExecutor; desktop/BBY Q state is separate. */
public final class GuestStore {
    private final AtomicFile file;
    private final File cache;
    private final File disks;
    private static final long MAX_CHECKPOINT=256L*1024*1024;
    public GuestStore(Context context){file=new AtomicFile(new File(context.getFilesDir(),"guest-aarch64.rvg"));cache=context.getCacheDir();disks=new File(context.getFilesDir(),"guest-disks");}
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
    private static long littleLong(RandomAccessFile f)throws Exception{return Long.reverseBytes(f.readLong());}
    private File diskFor(File state)throws Exception{
        // A snapshot supplies a content hash, never a host path. Native restore
        // still validates the whole RVG and the explicitly resolved disk hash.
        try(RandomAccessFile f=new RandomAccessFile(state,"r")){
            byte[] magic=new byte[4];f.readFully(magic);String version=new String(magic,StandardCharsets.US_ASCII);
            if(!version.equals("RVG2")&&!version.equals("RVG3"))return null;
            long start=8+(version.equals("RVG3")?44:43)*8;f.seek(8+39*8);long length=littleLong(f);
            if(length<128||length>128L*1024*1024||start+length>f.length())return null;
            f.seek(start);f.readFully(magic);if(!new String(magic,StandardCharsets.US_ASCII).equals("RVI3"))return null;
            f.seek(start+40);if(littleLong(f)!=80)return null;
            f.seek(start+length-80);if(littleLong(f)!=1)return null;if(littleLong(f)==0)return null;
            byte[] hash=new byte[64];f.readFully(hash);String name=new String(hash,StandardCharsets.US_ASCII);
            if(!name.matches("[0-9a-f]{64}"))return null;
            File result=new File(disks,name+".raw");return result.isFile()?result:null;
        }
    }
    private JSONObject report(File input,File output,int operation,int steps,String text)throws Exception{
        File disk=operation==4?null:diskFor(input);
        return new JSONObject(new String(NativeRuntime.guestFileDevices(input.getAbsolutePath(),
            output==null?null:output.getAbsolutePath(),operation,steps,text,disk==null?null:disk.getAbsolutePath()),StandardCharsets.UTF_8));
    }
    public JSONObject importDisk(InputStream input)throws Exception{
        if(!disks.isDirectory()&&!disks.mkdirs())throw new IllegalStateException("No se pudo preparar el disco");
        File candidate=File.createTempFile("disk-",".raw",disks);
        try{
            copySparseDisk(input,candidate);
            JSONObject info=new JSONObject(new String(NativeRuntime.guestFileDevices(null,null,6,0,"",candidate.getAbsolutePath()),StandardCharsets.UTF_8));
            String hash=info.getString("disk_sha256");if(!hash.matches("[0-9a-f]{64}"))throw new IllegalStateException("Identidad del disco no válida");
            File destination=new File(disks,hash+".raw");if(!destination.exists()&&!candidate.renameTo(destination))throw new IllegalStateException("No se pudo guardar el disco");
            return inspect().put("disk_attached",info);
        }finally{candidate.delete();}
    }
    public JSONObject display()throws Exception{
        File frame=File.createTempFile("reverse-frame-",".rgb",cache);
        try{
            JSONObject result=report(current(),frame,5,0,"").put("ok",true);
            if(!result.optBoolean("display_ready"))return result;
            JSONObject state=result.getJSONObject("guest");int w=state.getInt("display_width"),h=state.getInt("display_height");
            if(w<1||h<1||w>1280||h>1024||frame.length()!=3L*w*h)throw new IllegalStateException("Dimensiones de pantalla no válidas");
            byte[] rgb=new byte[3*w*h];try(InputStream input=new FileInputStream(frame)){int at=0,n;while(at<rgb.length&&(n=input.read(rgb,at,rgb.length-at))>0)at+=n;if(at!=rgb.length)throw new IllegalStateException("Imagen incompleta");}
            int[] colors=new int[w*h];for(int i=0;i<colors.length;i++)colors[i]=0xff000000|((rgb[3*i]&255)<<16)|((rgb[3*i+1]&255)<<8)|(rgb[3*i+2]&255);
            Bitmap bitmap=Bitmap.createBitmap(colors,w,h,Bitmap.Config.ARGB_8888);ByteArrayOutputStream encoded=new ByteArrayOutputStream();
            if(w>480||h>480){float scale=Math.min(480f/w,480f/h);Bitmap preview=Bitmap.createScaledBitmap(bitmap,Math.max(1,Math.round(w*scale)),Math.max(1,Math.round(h*scale)),false);if(preview!=bitmap){bitmap.recycle();bitmap=preview;}}
            try{if(!bitmap.compress(Bitmap.CompressFormat.PNG,100,encoded))throw new IllegalStateException("No se pudo presentar la imagen");}finally{bitmap.recycle();}
            return result.put("frame_png","data:image/png;base64,"+Base64.encodeToString(encoded.toByteArray(),Base64.NO_WRAP));
        }finally{frame.delete();}
    }
    private static void copy(InputStream input,OutputStream output,long maximum)throws Exception{
        if(input==null)throw new IllegalArgumentException("Archivo no disponible");
        byte[] buffer=new byte[8192];long total=0;int count;
        while((count=input.read(buffer))!=-1){if(total>maximum-count)throw new IllegalArgumentException("Archivo del invitado demasiado grande");output.write(buffer,0,count);total+=count;}
    }
    private static void copySparseDisk(InputStream input,File target)throws Exception{
        if(input==null)throw new IllegalArgumentException("Disco no disponible");long total=0;
        try(FileOutputStream output=new FileOutputStream(target)){
            byte[] buffer=new byte[8192];int count;
            while((count=input.read(buffer))!=-1){if(total>(1L<<40)-count)throw new IllegalArgumentException("Disco demasiado grande");boolean zero=true;for(int i=0;i<count;i++)if(buffer[i]!=0){zero=false;break;}
                if(zero)output.getChannel().position(total+count);else output.write(buffer,0,count);total+=count;}
        }
        try(RandomAccessFile file=new RandomAccessFile(target,"rw")){file.setLength(total);}
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

