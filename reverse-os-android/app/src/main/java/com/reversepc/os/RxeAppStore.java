package com.reversepc.os;

import android.content.Context;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.nio.channels.FileLock;
import java.nio.channels.OverlappingFileLockException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

/** One mutable RVPC2 authority per exact executable, independent of desktop RVPC2.
 * State and transcript publish together in one atomic file, before any answer.
 * File locks also protect against a still-finishing worker during recreation. */
final class RxeAppStore {
    static final int HISTORY_LIMIT=80,MAX_METADATA=512*1024;
    final String identity;
    private final File directory,record;
    static final class Saved {
        final byte[] state;final JSONArray history;final int language;
        Saved(byte[] state,JSONArray history,int language){this.state=state;this.history=history;this.language=language;}
    }
    RxeAppStore(Context ctx,byte[] executable)throws Exception{
        byte[] digest=MessageDigest.getInstance("SHA-256").digest(executable);
        StringBuilder name=new StringBuilder();for(byte b:digest)name.append(String.format(java.util.Locale.ROOT,"%02x",b&255));
        identity=name.toString();directory=new File(new File(ctx.getFilesDir(),"rxe-apps"),identity);
        if(!directory.isDirectory()&&!directory.mkdirs())throw new IOException("No se pudo abrir la memoria de la aplicación");
        record=new File(directory,"session.rxas");
    }
    Saved load(byte[] executable)throws Exception{
        if(!record.exists())return new Saved(NativeRuntime.appSeed(executable),new JSONArray(),1);
        if(record.length()>33L*1024*1024)throw new IOException("Sesión de aplicación demasiado grande");
        ResultPacket packet=ResultPacket.parse(Files.readAllBytes(record.toPath()));
        if(packet.state.length<29||packet.output.getBytes(StandardCharsets.UTF_8).length>MAX_METADATA)throw new IOException("Sesión incompleta o historial demasiado grande");
        JSONObject metadata=new JSONObject(packet.output);
        if(metadata.getInt("version")!=1||!identity.equals(metadata.getString("executable_sha256")))throw new IOException("La sesión pertenece a otro ejecutable");
        int language=metadata.getInt("language");JSONArray history=metadata.getJSONArray("history");
        if((language!=1&&language!=2)||history.length()>HISTORY_LIMIT||history.length()%2!=0)throw new IOException("Sesión de aplicación inválida");
        for(int i=0;i<history.length();i++){
            JSONObject item=history.getJSONObject(i);String role=item.getString("role"),text=item.getString("text");
            if(!(i%2==0?"user":"assistant").equals(role)||text.getBytes(StandardCharsets.UTF_8).length>(i%2==0?255:4096))throw new IOException("Historial de aplicación inválido");
        }
        NativeRuntime.inspect(packet.state);return new Saved(packet.state,history,language);
    }
    private void save(Saved saved)throws Exception{
        NativeRuntime.inspect(saved.state);
        JSONObject metadata=new JSONObject();metadata.put("version",1);metadata.put("executable_sha256",identity);metadata.put("language",saved.language);metadata.put("history",saved.history);
        String json=metadata.toString();if(json.getBytes(StandardCharsets.UTF_8).length>MAX_METADATA)throw new IOException("Historial demasiado grande");
        byte[] data=ResultPacket.encode(json,saved.state);File pending=new File(directory,"session.pending");
        try{
            try(FileOutputStream out=new FileOutputStream(pending)){out.write(data);out.getFD().sync();}
            Files.move(pending.toPath(),record.toPath(),StandardCopyOption.ATOMIC_MOVE,StandardCopyOption.REPLACE_EXISTING);
        }finally{try{Files.deleteIfExists(pending.toPath());}catch(IOException cleanup){android.util.Log.w("RxeAppStore","No se pudo retirar el archivo temporal",cleanup);}}
    }
    Saved ask(byte[] executable,String text,int language)throws Exception{
        try(FileChannel channel=FileChannel.open(new File(directory,"writer.lock").toPath(),StandardOpenOption.CREATE,StandardOpenOption.WRITE)){
            FileLock lock;
            try{lock=channel.tryLock();}catch(OverlappingFileLockException busy){throw new IOException("BBY Q está trabajando en otra ventana");}
            if(lock==null)throw new IOException("BBY Q está trabajando en otra ventana");
            try(FileLock held=lock){
                Saved before=load(executable);
                ResultPacket response=ResultPacket.parse(NativeRuntime.appTurn(before.state,executable,text.getBytes(StandardCharsets.UTF_8),language));
                JSONArray history=new JSONArray(before.history.toString());
                JSONObject question=new JSONObject();question.put("role","user");question.put("text",text);history.put(question);
                JSONObject answer=new JSONObject();answer.put("role","assistant");answer.put("text",response.output);history.put(answer);
                while(history.length()>HISTORY_LIMIT){history.remove(0);history.remove(0);}
                Saved after=new Saved(response.state,history,language);save(after);return after;
            }
        }
    }
    static void backup(Context ctx,java.util.zip.ZipOutputStream zip,int[] count,long[] total)throws IOException{
        File root=new File(ctx.getFilesDir(),"rxe-apps");File[] folders=root.listFiles();if(folders==null)return;
        for(File folder:folders){
            if(!folder.getName().matches("[0-9a-f]{64}")||Files.isSymbolicLink(folder.toPath()))continue;
            File file=new File(folder,"session.rxas");if(!file.isFile())continue;
            if(Files.isSymbolicLink(file.toPath())||file.length()>33L*1024*1024)throw new IOException("Memoria de aplicación fuera del presupuesto de respaldo");
            if(++count[0]>2048)throw new IOException("El respaldo admite hasta 2.048 elementos");
            byte[] content=Files.readAllBytes(file.toPath());total[0]+=content.length;if(total[0]>64L*1024*1024)throw new IOException("El respaldo supera 64 MiB");
            zip.putNextEntry(new java.util.zip.ZipEntry("datos-aplicaciones/"+folder.getName()+"/session.rxas"));zip.write(content);zip.closeEntry();
        }
    }
}
