package com.reversepc.os;

import android.content.Context;
import org.json.JSONObject;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** ReverseCoding instruction transport for the existing Qd skill of BBY Q.
 * Intent matching and source emission are executed by original XI programs,
 * never inferred by this Java class. All programs run on disposable states.
 * No memory writes to BBY Q, W4u or the main desktop are possible here.
 */
final class QdOrders {
    private static final String HEADER="#!reverse-pc-machine-v1\n";
    private static final long BASE=8430000000000000000L;
    private static final int MAX_WORDS=18;
    private static final Pattern ARITHMETIC=Pattern.compile(
        "^#!reverse-pc-machine-v1\\nset r0 ([0-9]{1,2})\\n(add|sub|mul|div|mod) r0 ([0-9]{1,2})\\nprint r0\\nhalt\\n$"
    );
    private QdOrders(){}

    private static final class Lexemes {
        final List<Integer> keys=new ArrayList<>();
        final List<Integer> values=new ArrayList<>();
    }
    // Purely lexical: no word is classified by Java. XI owns the vocabulary,
    // the disambiguation rules, operation selection, and emitted source bytes.
    private static Lexemes tokenize(String input){
        if(input==null||input.isBlank()||input.length()>180||
            input.getBytes(StandardCharsets.UTF_8).length>256)
            throw new IllegalArgumentException("La orden debe contener 1..180 caracteres.");
        String ascii=Normalizer.normalize(input,Normalizer.Form.NFD)
            .replaceAll("\\p{M}+","").toLowerCase(Locale.ROOT);
        if(Pattern.compile("-\\s*\\d").matcher(ascii).find())
            throw new IllegalArgumentException("Los valores negativos aún no están admitidos.");
        ascii=ascii.replaceAll("[^a-z0-9]+"," ").trim();
        Lexemes result=new Lexemes();
        if(ascii.isEmpty())throw new IllegalArgumentException("No se identificaron palabras.");
        for(String token:ascii.split(" +")){
            if(token.matches("[0-9]+")){
                if(token.length()>2||result.values.size()>=2)
                    throw new IllegalArgumentException("Admite exactamente dos números de 0 a 99.");
                result.values.add(Integer.parseInt(token));
            }else{
                if(result.keys.size()>=MAX_WORDS)
                    throw new IllegalArgumentException("Orden demasiado larga para Qd v0.2.");
                int key=0;
                for(int i=0;i<token.length();i++)key=(key*31+token.charAt(i))%65521;
                result.keys.add(key);
            }
        }
        return result;
    }
    private static String asset(Context context,String name)throws Exception{
        try(InputStream stream=context.getAssets().open("workbench/qd/"+name+".xi")){
            byte[] bytes=WorkbenchPrograms.read(stream);
            if(bytes.length>8192)throw new IllegalStateException("Programa de Qd fuera del presupuesto.");
            String program=new String(bytes,StandardCharsets.UTF_8);
            if(!program.startsWith(HEADER))throw new IllegalStateException("Programa XI de Qd inválido.");
            return program.substring(HEADER.length());
        }
    }
    private static List<Integer> numbers(String output)throws Exception{
        List<Integer> values=new ArrayList<>();
        for(String line:output.split("\\n")){
            if(!line.startsWith("{"))continue;
            JSONObject item=new JSONObject(line);
            if(!item.has("register")||!item.has("value"))continue;
            long value=item.getLong("value");
            if(value<Integer.MIN_VALUE||value>Integer.MAX_VALUE)
                throw new IllegalStateException("Valor XI fuera de rango.");
            values.add((int)value);
            if(values.size()>192)throw new IllegalStateException("Salida XI excesiva.");
        }
        return values;
    }
    private static List<Integer> isolated(String xi)throws Exception{
        // Important: NEVER pass an existing .rvp, RXE session or desktop state.
        ResultPacket packet=ResultPacket.parse(NativeRuntime.execute(NativeRuntime.initialize(),xi));
        return numbers(packet.output);
    }
    private static String put(long address,int value){
        if(value<0||value>255)throw new IllegalArgumentException("Byte tipado fuera de rango.");
        return "store8 "+address+" "+value+"\n";
    }
    static JSONObject order(Context context,String prompt)throws Exception{
        Lexemes data=tokenize(prompt);
        StringBuilder stage=new StringBuilder();
        stage.append(put(BASE,81)).append(put(BASE+1,1));
        stage.append(put(BASE+2,data.keys.size())).append(put(BASE+3,data.values.size()));
        stage.append(put(BASE+4,data.values.size()>0?data.values.get(0):0));
        stage.append(put(BASE+5,data.values.size()>1?data.values.get(1):0));
        for(int i=0;i<data.keys.size();i++){
            int hash=data.keys.get(i);
            stage.append(put(BASE+16+2L*i,hash&255));
            stage.append(put(BASE+17+2L*i,hash>>>8));
        }
        List<Integer> decision=isolated(HEADER+stage+asset(context,"understand"));
        if(decision.size()!=4)throw new IllegalStateException("XI no devolvió cuatro campos de interpretación.");
        int status=decision.get(0),operation=decision.get(1),a=decision.get(2),b=decision.get(3);
        String[] errors={
            "", "No reconozco esa operación. Prueba sumar, restar, multiplicar, dividir o calcular el resto.",
            "Necesito exactamente dos números entre 0 y 99.",
            "La orden contiene operaciones incompatibles. Especifica una sola.",
            "La orden está negada; no generaré código sin una instrucción afirmativa.",
            "No puedo dividir ni calcular el resto entre cero.",
            "La orden no cumple el contrato XI."
        };
        if(status<0||status>=errors.length)
            throw new IllegalStateException("XI devolvió una decisión desconocida.");
        if(status!=0)return new JSONObject().put("ok",true).put("understood",false)
            .put("reason",errors[status]).put("status_code",status)
            .put("scope","intérprete de operaciones acotadas XI, no programación general");
        if(operation<1||operation>5||a<0||a>99||b<0||b>99)
            throw new IllegalStateException("Plan XI fuera del dominio permitido.");
        StringBuilder request=new StringBuilder()
            .append(put(BASE,81)).append(put(BASE+1,2))
            .append(put(BASE+2,operation)).append(put(BASE+3,a)).append(put(BASE+4,b));
        List<Integer> encoded=isolated(HEADER+request+asset(context,"compose"));
        if(encoded.isEmpty()||encoded.size()>128)throw new IllegalStateException("XI no generó una fuente válida.");
        StringBuilder generated=new StringBuilder();
        for(int cp:encoded){
            if(cp!=10&&(cp<32||cp>126))
                throw new IllegalStateException("XI generó un byte no permitido.");
            generated.append((char)cp);
        }
        JSONObject execution=runCode(generated.toString());
        if(!execution.getBoolean("pass"))throw new IllegalStateException("El programa XI generado no superó el comprobador independiente.");
        return execution.put("understood",true).put("status_code",0)
            .put("intent_source","XI/Ether").put("source_generator","XI/Ether")
            .put("scope","operaciones aritméticas de dos entradas, no programación general");
    }
    static JSONObject runCode(String source)throws Exception{
        if(source==null||source.length()>192||!StandardCharsets.US_ASCII.newEncoder().canEncode(source))
            throw new IllegalArgumentException("El sandbox admite solo programas XI aritméticos de hasta 192 bytes.");
        Matcher match=ARITHMETIC.matcher(source);
        if(!match.matches())throw new IllegalArgumentException("Fuente fuera del sandbox: set, una operación, print y halt.");
        int a=Integer.parseInt(match.group(1)),b=Integer.parseInt(match.group(3));
        String op=match.group(2);
        if((op.equals("div")||op.equals("mod"))&&b==0)
            throw new IllegalArgumentException("División o resto entre cero.");
        List<Integer> values=isolated(source);
        if(values.size()!=1)throw new IllegalStateException("La ejecución XI debe imprimir un resultado.");
        int expected=switch(op){
            case "add" -> a+b;
            case "sub" -> a-b;
            case "mul" -> a*b;
            case "div" -> a/b;
            case "mod" -> a%b;
            default -> throw new IllegalArgumentException("Operación fuera del sandbox.");
        };
        int actual=values.get(0);
        return new JSONObject().put("ok",true).put("pass",actual==expected)
            .put("program",source).put("actual",actual).put("expected",expected)
            .put("a",a).put("b",b).put("operation",op)
            .put("sandbox","XI / NativeRuntime.initialize (temporal)")
            .put("persisted",false).put("scope","operación aritmética acotada");
    }
}
