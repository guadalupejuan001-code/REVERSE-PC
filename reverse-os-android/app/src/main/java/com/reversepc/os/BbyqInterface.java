package com.reversepc.os;

import android.content.Context;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import org.json.JSONArray;
import org.json.JSONObject;

/** Typed observation/action transport. No words, prompts or intent are parsed here. */
final class BbyqInterface {
    static final long A=8200000000000000000L;
    static final String LEGACY_SHA="2e189e11a9ceda2d4dfc2299e61892929dc696411d595b8e3c138c8134c2802f";
    private static String bundledIdentity;
    private BbyqInterface(){}
    static String identity(byte[] bytes)throws Exception{
        StringBuilder result=new StringBuilder();for(byte b:MessageDigest.getInstance("SHA-256").digest(bytes))result.append(String.format(java.util.Locale.ROOT,"%02x",b&255));return result.toString();
    }
    static byte[] asset(Context ctx,String path)throws Exception{
        try(InputStream in=ctx.getAssets().open(path)){return WorkbenchPrograms.read(in);}
    }
    static boolean trusted(Context ctx,byte[] image)throws Exception{
        if(bundledIdentity==null){
            byte[] bundled=asset(ctx,"native-apps/BBY-Q.rxe");
            JSONObject info=new JSONObject(new String(NativeRuntime.inspectRxe(bundled),StandardCharsets.UTF_8));
            bundledIdentity="E022-Control-1".equals(info.optString("app_version"))&&"org.reverse.bbyq".equals(info.optString("app_id"))?identity(bundled):"";
        }
        return bundledIdentity.equals(identity(image));
    }
    private static String put(long address,int value){return "store8 "+address+" "+value+"\n";}
    static byte[] observe(byte[] state,JSONObject observation)throws Exception{
        if(observation==null)return state;
        int active=observation.getInt("active"),count=observation.getInt("count");
        JSONArray present=observation.getJSONArray("present");
        String view=observation.getString("view");
        if(active<0||active>15||count<0||count>128||present.length()!=16||view.length()>32768)throw new IOException("Observación del escritorio inválida");
        StringBuilder source=new StringBuilder("#!reverse-pc-machine-v1\n");
        source.append(put(A+16,1)).append(put(A+17,active)).append(put(A+18,count));
        for(int i=0;i<16;i++){int n=present.getInt(i);if(n<0||n>128)throw new IOException("Cantidad de ventanas inválida");source.append(put(A+32+i,n));}
        return ResultPacket.parse(NativeRuntime.execute(state,source.toString())).state;
    }
    static JSONObject action(byte[] state)throws Exception{
        String source="#!reverse-pc-machine-v1\nload8 r0 "+(A+64)+"\nprint r0\nload8 r1 "+(A+65)+"\nprint r1\n";
        ResultPacket read=ResultPacket.parse(NativeRuntime.execute(state,source));int[] values=new int[2];int i=0;
        for(String row:read.output.split("\\n"))if(row.startsWith("{")){JSONObject item=new JSONObject(row);if("register".equals(item.optString("type"))){if(i>=2)throw new IOException("Respuesta de control inválida");values[i++]=item.getInt("value");}}
        if(i!=2)throw new IOException("Respuesta de control incompleta");
        int op=values[0],target=values[1];if(op==0)return null;
        boolean valid=(op==1&&target>=1&&target<=10)||(op>=2&&op<=6&&((target>=1&&target<=10)||target==15))||((op==7||op==8)&&target==0)||(op==9&&(target==13||target==14));
        if(!valid)throw new IOException("El programa devolvió una acción fuera del contrato");
        return new JSONObject().put("op",op).put("target",target);
    }
    static byte[] consume(Context ctx,byte[] state)throws Exception{
        return ResultPacket.parse(NativeRuntime.execute(state,new String(asset(ctx,"bbyq-interface/consume.xi"),StandardCharsets.UTF_8))).state;
    }
    static ResultPacket feedback(Context ctx,byte[] state,int language,boolean success)throws Exception{
        String body=new String(asset(ctx,"bbyq-interface/feedback.xi"),StandardCharsets.UTF_8);
        body=body.substring(body.indexOf('\n')+1);
        String source="#!reverse-pc-machine-v1\n"+put(7400000000000000003L,language)+put(A+67,success?2:3)+body;
        ResultPacket result=ResultPacket.parse(NativeRuntime.execute(state,source));ByteArrayOutputStream bytes=new ByteArrayOutputStream();
        for(String row:result.output.split("\\n"))if(row.startsWith("{")){
            JSONObject item=new JSONObject(row);if(!"r14".equals(item.optString("register")))continue;
            int b=item.getInt("value");if(b<0||b>255||bytes.size()>=4096)throw new IOException("Confirmación XI inválida");bytes.write(b);
        }
        if(bytes.size()==0)throw new IOException("Falta la confirmación XI");
        String text=StandardCharsets.UTF_8.newDecoder().decode(java.nio.ByteBuffer.wrap(bytes.toByteArray())).toString();
        return ResultPacket.parse(ResultPacket.encode(text,result.state));
    }
}
