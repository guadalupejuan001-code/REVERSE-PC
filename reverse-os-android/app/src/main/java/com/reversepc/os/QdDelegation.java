package com.reversepc.os;

import android.content.Context;
import org.json.JSONArray;
import org.json.JSONObject;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.List;

/**
 * T1: explicit coding-request route through the same BBY Q / w4U / QdU.
 * BBY Q XI classifies task type; w4U XI plans a one-use sandbox action and
 * independently reviews QdU output; QdU XI does code interpretation/emission.
 * Every intermediary RVPC2 is a disposable copy of the authenticated BBY Q
 * state under the existing writer.lock, NEVER persisted or sent to the desktop.
 *
 * This is bounded task routing, NOT generalized BBY Q language understanding
 * or unsupervised access to project files, applications, or GitHub.
 */
final class QdDelegation {
    private static final long B=8460000000000000000L;
    private static final String HEADER="#!reverse-pc-machine-v1\n";
    private QdDelegation(){}

    private static String put(long address,int n){
        if(n<0||n>255)throw new IllegalArgumentException("Byte XI fuera de rango");
        return "store8 "+address+" "+n+"\n";
    }
    private static String code(Context ctx,String role)throws Exception{
        if(!role.matches("(?:bbyq/qdu-(?:intent|result)|w4u/qdu-(?:plan|dispatch|review))"))
            throw new IllegalArgumentException("Rol XI no autorizado");
        try(java.io.InputStream in=ctx.getAssets().open("workbench/"+role+".xi")){
            byte[] bytes=WorkbenchPrograms.read(in);
            if(bytes.length>8192)throw new IllegalStateException("Rol XI demasiado grande");
            String s=new String(bytes,StandardCharsets.UTF_8);
            if(!s.startsWith(HEADER))throw new IllegalStateException("Rol XI sin cabecera");
            return s.substring(HEADER.length());
        }
    }
    private static final class Step {
        final byte[] state;
        final List<Integer> values;
        Step(byte[] state,List<Integer> values){this.state=state;this.values=values;}
        int status(){
            if(values.size()!=1)throw new IllegalStateException("Un rol XI debe producir un estado");
            return values.get(0);
        }
    }
    private static Step step(byte[] from,String source)throws Exception{
        ResultPacket p=ResultPacket.parse(NativeRuntime.execute(from,source));
        List<Integer> values=new ArrayList<>();
        for(String line:p.output.split("\n")){
            if(!line.startsWith("{"))continue;
            JSONObject item=new JSONObject(line);
            if(!item.has("register")||!item.has("value"))continue;
            long value=item.getLong("value");
            if(value<Integer.MIN_VALUE||value>Integer.MAX_VALUE||values.size()>=8)
                throw new IllegalStateException("Salida XI de delegación fuera del contrato");
            values.add((int)value);
        }
        return new Step(p.state,values);
    }
    private static Step role(Context ctx,byte[] state,String stage,String name)throws Exception{
        return step(state,HEADER+stage+code(ctx,name));
    }
    private static JSONObject unavailable(String reason,JSONArray trace)throws Exception{
        return new JSONObject().put("ok",true).put("delegated",false)
            .put("understood",false).put("reason",reason)
            .put("pipeline",trace).put("persisted",false);
    }
    private static JSONObject process(Context context,byte[] initial,String text,boolean strict,boolean pending)throws Exception{
        String frozen=BbyqInterface.identity(initial);
        QdOrders.Lexemes data;try{data=QdOrders.tokenize(text);}catch(IllegalArgumentException invalid){if(!strict)return null;throw invalid;}
        if(data.values.size()!=2)
            return strict?unavailable("QdU requiere dos operandos de 0 a 99.",new JSONArray()):null;
        final JSONArray[] trace={new JSONArray()};

        byte[] digest=MessageDigest.getInstance("SHA-256").digest(text.getBytes(StandardCharsets.UTF_8));
        int[] nonce=new int[4];
        SecureRandom random=new SecureRandom();
        int sum=0;
        for(int i=0;i<4;i++){nonce[i]=random.nextInt(256);sum+=nonce[i];}
        if(sum==0)nonce[0]=1;
        StringBuilder stage=new StringBuilder()
            .append(put(B,66)).append(put(B+1,1))
            .append(put(B+2,data.keys.size())).append(put(B+3,2))
            .append(put(B+4,data.values.get(0))).append(put(B+5,data.values.get(1)));
        for(int i=0;i<data.keys.size();i++){
            int hash=data.keys.get(i);
            stage.append(put(B+16+i*2L,hash&255)).append(put(B+17+i*2L,(hash>>>8)&255));
        }
        for(int i=0;i<4;i++)stage.append(put(B+60+i,nonce[i]));
        stage.append(put(B+64,1)).append(put(B+65,1));
        for(int i=0;i<4;i++)stage.append(put(B+70+i,digest[i]&255));
            Step current=role(context,initial,stage.toString(),"bbyq/qdu-intent");
            if(current.status()!=0){
                return strict?unavailable("BBY Q no clasificó la orden como una tarea explícita de código.",trace[0]):null;
            }
            if(pending)throw new IllegalStateException("w4U tiene una acción pendiente: confírmala antes de delegar.");
            trace[0].put("BBY Q · XI / solicitud de programación");
            current=role(context,current.state,"","w4u/qdu-plan");
            if(current.status()!=0){
                return unavailable("w4U rechazó la capacidad o el estado inicial.",trace[0]);
            }
            trace[0].put("w4U · XI / plan de una acción local");
            current=role(context,current.state,"","w4u/qdu-dispatch");
            if(current.status()!=0){
                return unavailable("w4U rechazó el ticket o la revisión de la tarea.",trace[0]);
            }
            trace[0].put("w4U · XI / permiso de un solo uso");
            JSONObject generated=QdOrders.order(context,text);
            if(!generated.optBoolean("understood",false)||!generated.optBoolean("pass",false)){
                return unavailable("QdU no puede generar código verificable para esta orden.",trace[0]);
            }
            int a=generated.getInt("a"),b=generated.getInt("b"),actual=generated.getInt("actual");
            if(a!=data.values.get(0)||b!=data.values.get(1)||actual<-32768||actual>32767)
                throw new IllegalStateException("QdU cambió los operandos o salió del contrato.");
            String operation=generated.getString("operation");
            // Java only transports QdU's already selected opcode to the w4U XI judge.
            int op=switch(operation){
                case "add"->1;case "sub"->2;case "mul"->3;case "div"->4;case "mod"->5;
                default->throw new IllegalStateException("Operación QdU no admitida");
            };
            trace[0].put("QdU · XI / fuente y sandbox comprobados");
            int packed=actual&65535;
            String review=put(B+80,1)+put(B+81,op)+put(B+82,a)+put(B+83,b)
                +put(B+84,packed&255)+put(B+85,(packed>>>8)&255);
            current=role(context,current.state,review,"w4u/qdu-review");
            if(current.status()!=0){
                return unavailable("w4U rechazó el resultado aritmético independiente.",trace[0]);
            }
            trace[0].put("w4U · XI / oráculo independiente y tarea cerrada");
            current=role(context,current.state,"","bbyq/qdu-result");
            if(current.status()!=0){
                return unavailable("BBY Q no confirmó el resultado verificado.",trace[0]);
            }
            trace[0].put("BBY Q · XI / entrega de resultado verificado");
            if(!frozen.equals(BbyqInterface.identity(initial)))throw new IllegalStateException("Se alteró la memoria original");
            return generated.put("delegated",true).put("verified",true)
                .put("authorized_by","w4U/XI").put("task_type","single_local_code_run")
                .put("pipeline",trace[0]).put("persisted",false)
                .put("scope","generación aritmética acotada XI; no edición general de proyectos");
    }
    static JSONObject tryChat(Context context,byte[] initial,String text,boolean pending)throws Exception{
        return process(context,initial,text,false,pending);
    }
    static JSONObject delegate(Context context,byte[] executable,String text)throws Exception{
        final JSONObject[] answer={null};
        new RxeAppStore(context,executable).withLockedSnapshot(executable,saved->{
            answer[0]=process(context,saved.state,"programa "+text,true,saved.pending!=null);
        });
        return answer[0];
    }
    static String chatText(JSONObject result,int language)throws Exception{
        boolean en=language==2;
        if(!result.optBoolean("delegated",false))return (en?"Programming request declined: ":"Solicitud de programación detenida: ")+result.optString("reason");
        return "BBY Q → w4U → QdU → w4U → BBY Q\n\n"+
            (en?"Verified XI program:\n":"Programa XI verificado:\n")+result.getString("program")+"\n"+
            (en?"Verified result: ":"Resultado verificado: ")+result.getInt("actual")+".\n"+
            (en?"Executed in a temporary sandbox. No project files were changed.":"Ejecutado en un sandbox temporal. No se modificaron archivos de proyectos.");
    }
}
