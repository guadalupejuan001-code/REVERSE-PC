package com.reversepc.os;

import android.content.Context;
import android.util.Log;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Locale;

/** RXE catalog and transactions for the current desktop. Call on RuntimeExecutor. */
final class WorkbenchPrograms {
    static final String BBYQ="Aplicaciones/BBY-Q.rxe";
    private final Context context;
    private final WorkspaceFiles files;

    WorkbenchPrograms(Context context)throws Exception{
        this.context=context.getApplicationContext();files=new WorkspaceFiles(context.getFilesDir());
        // Use the same executable paths and private memories as DesktopActivity.
        // Never replace a user's executable or restore a deliberately removed app.
        android.content.SharedPreferences prefs=context.getSharedPreferences("workbench-programs",0);
        if(!prefs.getBoolean("breaker-v1-seeded",false)){
            try(InputStream input=context.getAssets().open(BreakerSession.ASSET)){
                byte[] image=read(input);info(image);String game="Aplicaciones/REVERSE-BREAKER.rxe";
                if(!exists(game))files.write(game,image,false);
            }
            prefs.edit().putBoolean("breaker-v1-seeded",true).apply();
        }
        if(!prefs.getBoolean("seeded",false)){
            android.content.SharedPreferences previous=context.getSharedPreferences("desktop-v1",0);
            if(!exists(BBYQ)&&!previous.getBoolean("bbyq-rxe-e016-seeded",false))try(InputStream in=context.getAssets().open("native-apps/BBY-Q.rxe")){
                byte[] image=read(in);info(image);files.write(BBYQ,image,false);
            }
            String hello="Aplicaciones/Hola-REVERSE.rxe";
            if(!exists(hello)&&!previous.getBoolean("rxe-seeded-v1",false))files.write(hello,NativeRuntime.compileRxe(
                "#!reverse-pc-machine-v1\nset r0 6\nmul r0 7\nprint r0\nhalt\n".getBytes(StandardCharsets.UTF_8),
                "Hola REVERSE".getBytes(StandardCharsets.UTF_8)),false);
            prefs.edit().putBoolean("seeded",true).apply();
        }
    }
    private boolean exists(String path)throws Exception{
        for(WorkspaceFiles.Entry entry:files.list("Aplicaciones"))if(entry.path.equals(path))return true;
        return false;
    }
    static byte[] read(InputStream input)throws IOException{
        if(input==null)throw new IOException("No se pudo leer el archivo");
        ByteArrayOutputStream output=new ByteArrayOutputStream();byte[] buffer=new byte[8192];int count;
        while((count=input.read(buffer))!=-1){if(output.size()+count>WorkspaceFiles.MAX_FILE)throw new IOException("El ejecutable supera 8 MiB");output.write(buffer,0,count);}
        return output.toByteArray();
    }
    private static String path(String value)throws Exception{
        if(value==null||!WorkspaceFiles.parent(value).equals("Aplicaciones")||!value.toLowerCase(Locale.ROOT).endsWith(".rxe"))throw new IOException("Selecciona un ejecutable de Aplicaciones");
        WorkspaceFiles.name(value.substring("Aplicaciones/".length()));return value;
    }
    private JSONObject info(byte[] image)throws Exception{
        JSONObject metadata=new JSONObject(new String(NativeRuntime.inspectRxe(image),StandardCharsets.UTF_8));
        if(BreakerSession.recognizes(context,image))metadata.put("ui","breaker-v1").put("app_version","1.0.0");
        return metadata;
    }
    private static String identity(byte[] image)throws Exception{
        StringBuilder hex=new StringBuilder();for(byte b:MessageDigest.getInstance("SHA-256").digest(image))hex.append(String.format(Locale.ROOT,"%02x",b&255));return hex.toString();
    }
    private byte[] checked(JSONObject request)throws Exception{
        byte[] image=files.read(path(request.getString("path")));
        if(!identity(image).equals(request.getString("identity")))throw new IOException("El ejecutable cambió. Vuelve a abrirlo antes de continuar");
        return image;
    }
    JSONObject catalog()throws Exception{
        JSONArray apps=new JSONArray();int rejected=0;
        for(WorkspaceFiles.Entry entry:files.list("Aplicaciones"))if(!entry.directory&&entry.path.toLowerCase(Locale.ROOT).endsWith(".rxe")){
            try{byte[] image=files.read(entry.path);apps.put(new JSONObject().put("path",entry.path).put("metadata",info(image)).put("bytes",image.length).put("identity",identity(image)));}
            catch(Exception invalid){rejected++;Log.w("ReverseWorkbench","RXE_CATALOG_REJECT "+entry.path,invalid);}
        }
        return new JSONObject().put("ok",true).put("apps",apps).put("rejected",rejected);
    }
    private JSONObject snapshot(String path,byte[] image,JSONObject metadata)throws Exception{
        JSONObject result=new JSONObject().put("ok",true).put("path",path).put("identity",identity(image)).put("metadata",metadata);
        if("chat".equals(metadata.optString("ui"))){
            RxeAppStore.Saved saved=new RxeAppStore(context,image).load(image);
            result.put("history",saved.history).put("language",saved.language);
        }else result.put("output",context.getSharedPreferences("desktop-v1",0).getString("rxe-output:"+path,""));
        return result;
    }
    JSONObject open(String selected)throws Exception{
        String selectedPath=path(selected);byte[] image=files.read(selectedPath);
        return snapshot(selectedPath,image,info(image));
    }
    JSONObject ask(JSONObject request)throws Exception{
        byte[] image=checked(request);JSONObject metadata=info(image);
        if(!"chat".equals(metadata.optString("ui")))throw new IOException("Este ejecutable no ofrece una conversación");
        String text=request.getString("text").trim();int language=request.getInt("language");
        if(text.isEmpty()||text.getBytes(StandardCharsets.UTF_8).length>255||(language!=1&&language!=2))throw new IOException("Escribe un mensaje de hasta 255 bytes y elige un idioma");
        RxeAppStore app=new RxeAppStore(context,image);RxeAppStore.Saved saved=app.ask(image,text,language);
        Log.i("ReverseWorkbench","WORKBENCH_APP_TURN_OK "+app.identity);
        return new JSONObject().put("ok",true).put("path",request.getString("path")).put("identity",app.identity).put("metadata",metadata).put("history",saved.history).put("language",saved.language);
    }
    JSONObject run(JSONObject request,SessionStore session)throws Exception{
        byte[] image=checked(request);
        if("chat".equals(info(image).optString("ui")))throw new IOException("Abre la conversación de esta aplicación");
        if("breaker-v1".equals(info(image).optString("ui")))throw new IOException("Abre el juego con su control gráfico");
        ResultPacket result=ResultPacket.parse(NativeRuntime.executeRxe(session.loadState(),image));
        session.writeState(result.state);
        String output=result.output.length()>48000?result.output.substring(0,48000)+"\n[Salida visible recortada]":result.output;
        context.getSharedPreferences("desktop-v1",0).edit().putString("rxe-output:"+request.getString("path"),output).apply();
        Log.i("ReverseWorkbench","WORKBENCH_RXE_RUN_OK "+request.getString("path"));
        return new JSONObject().put("ok",true).put("output",output);
    }
    void checkGame(JSONObject request)throws Exception{
        if(!BreakerSession.recognizes(context,checked(request)))throw new IOException("El ejecutable no corresponde a REVERSE BREAKER 1.0");
    }
    JSONObject compile(JSONObject request)throws Exception{
        String source=request.getString("source");byte[] bytes=source.getBytes(StandardCharsets.UTF_8);
        if(bytes.length>WorkspaceFiles.MAX_TEXT)throw new IOException("El programa supera 256 KiB");
        String name=WorkspaceFiles.name(request.getString("name"));if(!name.toLowerCase(Locale.ROOT).endsWith(".rxe"))name+=".rxe";
        String target=path("Aplicaciones/"+name);
        byte[] image=NativeRuntime.compileRxe(bytes,name.substring(0,name.length()-4).getBytes(StandardCharsets.UTF_8));
        files.write(target,image,false);return new JSONObject().put("ok",true).put("path",target);
    }
    JSONObject importImage(byte[] image)throws Exception{
        JSONObject metadata=info(image);String title=metadata.getString("title").replaceAll("[\\\\/\\p{Cntrl}]","_").trim();
        if(title.isEmpty()||title.startsWith("."))title="Programa";
        // UTF-8 names must fit WorkspaceFiles' byte limit even with a copy suffix.
        while(title.length()>60||title.getBytes(StandardCharsets.UTF_8).length>140)title=title.substring(0,title.length()-1);
        String target="Aplicaciones/"+title+".rxe";int suffix=2;
        while(exists(target)){if(suffix>1000)throw new IOException("Hay demasiadas copias de esta aplicación");target="Aplicaciones/"+title+"-"+(suffix++)+".rxe";}
        files.write(target,image,false);return new JSONObject().put("ok",true).put("path",target);
    }
    byte[] exportImage(JSONObject request,boolean memory)throws Exception{
        byte[] image=checked(request);info(image);
        if(!memory)return image;
        if(!"chat".equals(info(image).optString("ui")))throw new IOException("La aplicación no ofrece una memoria privada");
        return new RxeAppStore(context,image).load(image).state;
    }
}
