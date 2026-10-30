package com.reversepc.os;

import android.content.Context;
import java.io.ByteArrayInputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

/** Loads the exact bundled X07 program/roles; no request interpretation. */
final class BbyqModern {
    private static final String PREFIX="bbyq-interface/x07/";
    private static Config cached;
    private static BbyqX09Engine x09;
    private static synchronized BbyqX09Engine x09(Context context)throws Exception{
        if(x09==null){final Context ctx=context.getApplicationContext();x09=new BbyqX09Engine(name->ctx.getAssets().open("bbyq-x09/"+name),BbyqTextEngine.JNI);}return x09;
    }
    static byte[] seed(Context ctx)throws Exception{return x09(ctx).seed();}
    static final class Config {
        final String identity;final BbyqTextEngine engine;final List<BbyqTextEngine.Phase> phases;
        Config(String identity,BbyqTextEngine engine,List<BbyqTextEngine.Phase> phases){this.identity=identity;this.engine=engine;this.phases=phases;}
    }
    private static synchronized Config config(Context context)throws Exception{
        if(cached!=null)return cached;final Context ctx=context.getApplicationContext();
        Properties p=new Properties();byte[] metadata=BbyqInterface.asset(ctx,PREFIX+"engine.properties");
        if(metadata.length>128*1024)throw new IOException("Perfil X07 demasiado grande");
        p.load(new InputStreamReader(new ByteArrayInputStream(metadata),StandardCharsets.UTF_8));
        if(!"X07-Knowledge-Android-1".equals(p.getProperty("version")))throw new IOException("Perfil X07 incompatible");
        Map<String,String> roles=new HashMap<>();for(String key:p.stringPropertyNames())if(key.startsWith("role."))roles.put(key.substring(5),p.getProperty(key));
        BbyqTextEngine.Assets assets=name->{if(!name.matches("[a-z0-9][a-z0-9.-]*"))throw new IOException("Programa de perfil no válido");return BbyqInterface.asset(ctx,PREFIX+name);};
        BbyqTextEngine engine=new BbyqTextEngine(BbyqTextEngine.JNI,assets,p.getProperty("code_sha256"),roles);
        int count=Integer.parseInt(p.getProperty("phase.count"));if(count<1||count>128)throw new IOException("Fases X07 fuera de rango");List<BbyqTextEngine.Phase> phases=new ArrayList<>();
        for(int i=0;i<count;i++){String[] v=p.getProperty("phase."+i,"").split(",");if(v.length!=4||!v[0].matches("[a-z0-9][a-z0-9.-]*")||!v[1].matches("[0-9a-f]{64}"))throw new IOException("Fase X07 incompleta");phases.add(new BbyqTextEngine.Phase(v[0],v[1],Long.parseLong(v[2]),Integer.parseInt(v[3])));}
        String identity=p.getProperty("executable_sha256","");if(!identity.matches("[0-9a-f]{64}"))throw new IOException("Identidad X07 incompleta");
        cached=new Config(identity,engine,phases);return cached;
    }
    static boolean supports(Context ctx,byte[] image)throws Exception{
        try{return config(ctx).identity.equals(BbyqInterface.identity(image));}catch(java.io.FileNotFoundException absent){return false;}
    }
    static boolean supportsIdentity(Context ctx,String identity)throws Exception{
        try{return config(ctx).identity.equals(identity);}catch(java.io.FileNotFoundException absent){return false;}
    }
    static byte[] migrate(Context ctx,byte[] previous)throws Exception{return x09(ctx).migrate(config(ctx).engine.migrate(previous,config(ctx).phases));}
    static ResultPacket ask(Context ctx,byte[] previous,String text,int language,BbyqTextEngine.DispatchCommit checkpoint)throws Exception{
        BbyqTextEngine.Delivery d=x09(ctx).turn(previous,text,language,checkpoint);return ResultPacket.parse(ResultPacket.encode(d.text,d.state));
    }
}
