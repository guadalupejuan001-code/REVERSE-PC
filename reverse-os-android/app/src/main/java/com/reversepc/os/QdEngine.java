package com.reversepc.os;

import android.content.Context;
import org.json.JSONArray;
import org.json.JSONObject;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.security.SecureRandom;
import java.util.regex.Pattern;

/** Qd/Cody: bounded XI coding lessons backed by BBY Q's exact private RVPC2.
 * Java transports examples, executes an independent oracle and checks permissions.
 * The template memory, selection and learning transactions execute in XI/Ether.
 * Qd v1 is pattern learning, not an unconstrained code-generating model.
 */
final class QdEngine {
    private static final long B=8440000000000000000L;
    private static final long M=8410000000000000000L;
    private static final String HEADER="#!reverse-pc-machine-v1\n";
    private static final Pattern INSTRUCTION=Pattern.compile(
        "(?:set|add|sub|mul|div|mod) r[0-3] (?:r[0-3]|-?[0-9]+|\\{\\{a\\}\\}|\\{\\{b\\}\\})"
        +"|mov r[0-3] r[0-3]|print r0|halt");
    private static final int[][] TRAIN={{6,7},{12,4},{9,3},{15,8}};
    // The independent host selects a NEW held-out exam for each attempted lesson.
    // These examples are never fed back into XI as training data; XI receives only
    // the pass/total verdict, not the answers. Keep counts within store8 (0..255).
    private static final int HELDOUT_COUNT=28;
    private static final int ACCEPTANCE_CASES=TRAIN.length+HELDOUT_COUNT;
    private static int[][] heldout(){
        List<int[]> cases=new ArrayList<>();
        HashSet<Integer> seen=new HashSet<>();
        for(int[] item:TRAIN)seen.add(item[0]*100+item[1]);
        int[][] boundaries={{0,1},{99,99},{99,1},{0,99}};
        for(int[] pair:boundaries)if(seen.add(pair[0]*100+pair[1]))cases.add(pair);
        SecureRandom random=new SecureRandom();
        while(cases.size()<HELDOUT_COUNT){
            int a=random.nextInt(100),b=1+random.nextInt(99);
            if(seen.add(a*100+b))cases.add(new int[]{a,b});
        }
        return cases.toArray(new int[0][]);
    }
    private final Context context;
    private final byte[] bbyq;
    QdEngine(Context context,byte[] bbyq)throws Exception{
        this.context=context.getApplicationContext();this.bbyq=bbyq;
        if(!BbyqInterface.trusted(context,bbyq))
            throw new IllegalStateException("Qd requiere el BBY Q original y verificado.");
    }
    private String xi(String name)throws Exception{
        try(java.io.InputStream input=context.getAssets().open("workbench/qd/"+name+".xi")){
            byte[] bytes=WorkbenchPrograms.read(input);
            String code=new String(bytes,StandardCharsets.UTF_8);
            if(!code.startsWith(HEADER)||bytes.length>8192)
                throw new IllegalStateException("El programa XI Qd no es válido.");
            return code.substring(HEADER.length());
        }
    }
    private static String pre(String code){return HEADER+code;}
    private ResultPacket shared(String code,boolean save)throws Exception{
        return new RxeAppStore(context,bbyq).runTrustedXi(bbyq,code,save);
    }
    private static List<Integer> numbers(String output)throws Exception{
        List<Integer> values=new ArrayList<>();
        for(String line:output.split("\n")){
            if(!line.startsWith("{"))continue;
            JSONObject o=new JSONObject(line);
            if(!o.has("register")||!o.has("value"))continue;
            long value=o.getLong("value");
            if(value<Integer.MIN_VALUE||value>Integer.MAX_VALUE)throw new IllegalStateException("Salida XI fuera de rango");
            values.add((int)value);
        }
        return values;
    }
    private JSONObject status()throws Exception{
        List<Integer> counts=numbers(shared(pre(xi("status")),false).output);
        if(counts.size()!=6||(counts.get(0)!=0&&counts.get(0)!=81))
            throw new IllegalStateException("La región Qd no corresponde a su versión.");
        JSONArray learned=new JSONArray();
        for(int i=1;i<=4;i++)learned.put(counts.get(i)>0);
        return new JSONObject().put("ok",true).put("learned",learned)
            .put("approved_lessons",counts.get(5))
            .put("language","XI/Ether").put("storage","BBY Q / RVPC2");
    }
    private static String checked(String source)throws Exception{
        if(source==null||!source.startsWith(HEADER)||source.indexOf('\r')>=0)
            throw new IllegalArgumentException("Programa XI inválido.");
        if(!source.endsWith("\n"))source+="\n";
        if(source.length()>192||!StandardCharsets.US_ASCII.newEncoder().canEncode(source))
            throw new IllegalArgumentException("Usa un programa XI ASCII de hasta 192 bytes.");
        int instructions=0;boolean a=false,b=false,printed=false,ended=false;
        for(String raw:source.split("\n")){
            String line=raw.trim();
            if(line.isEmpty()||line.startsWith("#"))continue;
            if(!INSTRUCTION.matcher(line).matches()||ended)
                throw new IllegalArgumentException("Qd v1 admite set/mov/aritmética/print/halt, sin acceso a memoria ni bucles.");
            instructions++;
            a|=line.contains("{{a}}");b|=line.contains("{{b}}");
            if(line.equals("print r0"))printed=true;
            if(line.equals("halt"))ended=true;
        }
        if(!a||!b||!printed||!ended||instructions>24)
            throw new IllegalArgumentException("Incluye {{a}}, {{b}}, print r0 y halt.");
        return source;
    }
    private static String materialize(String source,int a,int b){
        return source.replace("{{a}}",Integer.toString(a)).replace("{{b}}",Integer.toString(b));
    }
    private static int expected(int kind,int a,int b){
        return switch(kind){case 1->a+b;case 2->a-b;case 3->a*b;case 4->a%b;default->throw new IllegalArgumentException("Lección desconocida");};
    }
    private static int execute(String source)throws Exception{
        ResultPacket result=ResultPacket.parse(NativeRuntime.execute(NativeRuntime.initialize(),source));
        List<Integer> values=numbers(result.output);
        if(values.size()!=1)throw new IllegalStateException("XI debe imprimir solamente r0 una vez.");
        return values.get(0);
    }
    private static JSONObject grade(String template,int skill,boolean includeHoldout)throws Exception{
        JSONArray rows=new JSONArray();int pass=0;
        int[][] exam=includeHoldout?heldout():new int[0][];
        for(int section=0;section<(includeHoldout?2:1);section++){
            for(int[] pair:(section==0?TRAIN:exam)){
                int a=pair[0],b=pair[1],truth=expected(skill,a,b);
                JSONObject row=new JSONObject().put("a",a).put("b",b).put("expected",truth)
                    .put("set",section==0?"práctica":"evaluación");
                try{
                    int result=execute(materialize(template,a,b));
                    boolean correct=result==truth;row.put("actual",result).put("pass",correct);
                    if(correct)pass++;
                }catch(Exception failure){row.put("pass",false).put("error",failure.getMessage());}
                rows.put(row);
            }
        }
        return new JSONObject().put("passed",pass).put("total",rows.length())
            .put("all_passed",pass==rows.length()).put("cases",rows);
    }
    private JSONObject teach(int skill,String source)throws Exception{
        String template=checked(source);JSONObject result=grade(template,skill,true);
        if(result.getInt("total")!=ACCEPTANCE_CASES)
            throw new IllegalStateException("El examen Qd está incompleto.");
        // Independent host grading supplies evidence; XI decides acceptance.
        String evidence="store8 "+M+" 81\nstore8 "+(M+1)+" 3\n"
            +"store8 "+(M+4)+" "+result.getInt("passed")+"\n"
            +"store8 "+(M+5)+" "+result.getInt("total")+"\n";
        List<Integer> decision=numbers(shared(pre(evidence+xi("judge")),false).output);
        if(decision.size()!=1)throw new IllegalStateException("Qd no emitió evaluación XI");
        if(decision.get(0)==0)return result.put("ok",true).put("learned",false);
        if(decision.get(0)!=1)throw new IllegalStateException("Decisión XI no válida");
        StringBuilder stage=new StringBuilder();
        stage.append("store8 ").append(M).append(" 81\n");
        stage.append("store8 ").append(M+1).append(" 1\n");
        stage.append("store8 ").append(M+2).append(' ').append(skill).append('\n');
        stage.append("store8 ").append(M+4).append(' ').append(ACCEPTANCE_CASES).append('\n');
        stage.append("store8 ").append(M+5).append(' ').append(ACCEPTANCE_CASES).append('\n');
        byte[] code=template.getBytes(StandardCharsets.US_ASCII);
        stage.append("store8 ").append(M+3).append(' ').append(code.length).append('\n');
        for(int i=0;i<code.length;i++)stage.append("store8 ").append(M+16+i).append(' ').append(code[i]&255).append('\n');
        List<Integer> confirmation=numbers(shared(pre(stage+xi("learn")),true).output);
        if(confirmation.size()!=2||confirmation.get(0)!=skill||confirmation.get(1)!=code.length)
            throw new IllegalStateException("XI no confirmó la enseñanza.");
        return result.put("ok",true).put("learned",true).put("status",status());
    }
    private JSONObject solve(int skill,int a,int b)throws Exception{
        if(a<0||a>99||b<1||b>99)throw new IllegalArgumentException("Usa a=0..99 y b=1..99.");
        String stage="store8 "+M+" 81\nstore8 "+(M+1)+" 2\nstore8 "+(M+2)+" "+skill+"\n";
        List<Integer> chars=numbers(shared(pre(stage+xi("recall")),false).output);
        if(chars.isEmpty())return new JSONObject().put("ok",true).put("learned",false);
        if(chars.size()>192)throw new IllegalStateException("Patrón Qd corrupto.");
        StringBuilder template=new StringBuilder();
        for(int v:chars){if(v!=10&&(v<32||v>126))throw new IllegalStateException("Byte Qd inválido");template.append((char)v);}
        String program=materialize(checked(template.toString()),a,b);
        int result=execute(program),truth=expected(skill,a,b);
        return new JSONObject().put("ok",true).put("learned",true).put("program",program)
            .put("actual",result).put("expected",truth).put("pass",result==truth);
    }
    JSONObject handle(JSONObject request)throws Exception{
        String action=request.optString("action","status");
        if("status".equals(action))return status();
        if("order".equals(action)||"delegate".equals(action))return QdDelegation.delegate(context,bbyq,request.getString("text"));
        if("run_code".equals(action))return QdOrders.runCode(request.getString("source"));
        int skill=request.getInt("skill");
        if(skill<1||skill>4)throw new IllegalArgumentException("Lección Qd inválida.");
        if("evaluate".equals(action))return grade(checked(request.getString("source")),skill,false).put("ok",true);
        if("teach".equals(action))return teach(skill,request.getString("source"));
        if("solve".equals(action))return solve(skill,request.getInt("a"),request.getInt("b"));
        throw new IllegalArgumentException("Acción Qd no admitida.");
    }
}
