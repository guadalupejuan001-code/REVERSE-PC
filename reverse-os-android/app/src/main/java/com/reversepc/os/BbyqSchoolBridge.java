package com.reversepc.os;

import android.content.Context;
import android.util.Log;
import org.json.JSONObject;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;

/**
 * Android I/O adapter for the owner's ORIGINAL XI developmental programs.
 * Observations/expected answers come from curriculum files, while ALL
 * recognition, word memory, mathematics, scoring and milestones run in XI.
 * This class never creates a second AI or a second Ether memory authority.
 */
final class BbyqSchoolBridge {
    private static final long B=7200000000000000000L;
    private static final String TAG="BBYQDevelopment";
    private BbyqSchoolBridge(){}

    static final class Status {
        final int signature, concepts, phase, language;
        Status(long[] row) {
            signature=(int)row[0];concepts=(int)row[1];
            phase=(int)row[2];language=(int)row[3];
        }
        boolean ready(){return signature==83&&concepts>=22&&phase>=2;}
        String description(){return ready()?
            "22 conceptos ES / EN · reconocimiento y operaciones XI":
            "Currículo adaptativo no validado. Estado actual "+phase;}
    }
    private static String asset(Context ctx,String name)throws IOException {
        try(InputStream in=ctx.getAssets().open("bbyq/"+name);
            ByteArrayOutputStream out=new ByteArrayOutputStream()) {
            byte[] bytes=new byte[8192];int n;
            while((n=in.read(bytes))!=-1) {
                if(out.size()+n>256*1024)throw new IOException("Asset XI demasiado grande");
                out.write(bytes,0,n);
            }
            return out.toString(StandardCharsets.UTF_8.name());
        }
    }
    private static ResultPacket result(byte[] state,String program) {
        return ResultPacket.parse(NativeRuntime.execute(state,program));
    }
    private static byte[] xi(byte[] state,String program) {
        return result(state,program).state;
    }
    private static ResultPacket execute(Context ctx,byte[] state,String path)throws IOException {
        return result(state,asset(ctx,"school/"+path+".xi"));
    }
    private static byte[] run(Context ctx,byte[] state,String name)throws IOException {
        return execute(ctx,state,name).state;
    }
    private static long[] values(String text)throws IOException {
        ArrayList<Long> regs=new ArrayList<>();
        for(String line:text.split("\\n")) {
            if(line.trim().isEmpty())continue;
            try {
                JSONObject obj=new JSONObject(line);
                if("register".equals(obj.optString("type")))
                    regs.add(obj.getLong("value"));
            }catch(Exception err){throw new IOException("Resultado XI corrupto: "+err.getMessage(),err);}
        }
        long[] row=new long[regs.size()];
        for(int i=0;i<row.length;i++)row[i]=regs.get(i);
        return row;
    }
    private static String source(){return "#!reverse-pc-machine-v1\n";}
    private static String set(long at,long value) {
        if(value<0||value>255)throw new IllegalArgumentException("Byte de sensor inválido");
        return "store8 "+at+" "+value+"\n";
    }
    private static String word(long at,String text) {
        if(text==null||!text.matches("[a-z]{1,8}"))
            throw new IllegalArgumentException("Admite palabras ASCII en minúsculas de 1 a 8 letras");
        StringBuilder s=new StringBuilder(set(at,text.length()));
        for(int i=0;i<text.length();i++)s.append(set(at+1+i,text.charAt(i)));
        return s.toString();
    }
    private static String speak(String jsonl)throws IOException {
        StringBuilder out=new StringBuilder();
        for(long n:values(jsonl)) {
            if(n<32||n>126)throw new IOException("El XI emitió un byte de texto inválido");
            out.append((char)n);
        }
        return out.toString();
    }
    static Status status(byte[] state)throws IOException {
        String s=source()
            +"load8 r0 "+B+"\nprint r0\n"
            +"load8 r1 "+(B+10)+"\nprint r1\n"
            +"load8 r2 "+(B+3)+"\nprint r2\n"
            +"load8 r3 "+(B+4)+"\nprint r3\n";
        long[] regs=values(result(state,s).output);
        if(regs.length!=4)throw new IOException("Estado de desarrollo XI incompleto");
        return new Status(regs);
    }
    private static byte[] train(Context ctx,byte[] state,String[] row)throws IOException {
        if(row.length!=6)throw new IOException("Lección de concepto incompleta");
        String s=source()+set(B+100,1)+set(B+101,Integer.parseInt(row[0]))
            +set(B+102,Integer.parseInt(row[1]))+set(B+103,Integer.parseInt(row[2]))
            +set(B+104,Integer.parseInt(row[3]))
            +word(B+105,row[4])+word(B+115,row[5]);
        return run(ctx,xi(state,s),"learn");
    }
    private static byte[] language(Context ctx,byte[] state,int choice)throws IOException {
        if(choice!=1&&choice!=2)throw new IllegalArgumentException("Idioma 1=ES 2=EN");
        return run(ctx,xi(state,source()+set(B+80,choice)),"set-language");
    }
    private static final class Classified {
        final byte[] memory;
        final String name;
        final int status,slot;
        Classified(byte[] memory,String name,int status,int slot){
            this.memory=memory;this.name=name;this.status=status;this.slot=slot;
        }
    }
    private static Classified recognize(Context ctx,byte[] state,int d,int x,int y,int z)
        throws IOException {
        String s=source()+set(B+100,2)+set(B+101,d)
            +set(B+102,x)+set(B+103,y)+set(B+104,z);
        ResultPacket classified=execute(ctx,xi(state,s),"recognize");
        long[] regs=values(classified.output);
        if(regs.length<2)throw new IOException("Clasificación XI incompleta");
        ResultPacket named=execute(ctx,classified.state,"name");
        return new Classified(named.state,speak(named.output),(int)regs[0],(int)regs[1]);
    }
    private static byte[] grade(Context ctx,Classified prediction,int expected)throws IOException {
        byte[] input=xi(prediction.memory,source()+set(B+300,1)+set(B+301,expected));
        ResultPacket grade=execute(ctx,input,"grade");
        long[] scores=values(grade.output);
        if(scores.length<1||scores[0]!=1)
            throw new IOException("BBY Q no pasó examen de observaciones");
        return grade.state;
    }
    private static byte[] teachOperation(Context ctx,byte[] state,int op,int before,int amount,int after)
        throws IOException {
        String sample=source()+set(B+340,1)+set(B+341,op)+set(B+342,before)
            +set(B+343,amount)+set(B+344,after);
        return run(ctx,xi(state,sample),"learn-operation");
    }
    private static final class MathAnswer {
        final byte[] memory;
        final String word;
        final int slot,status;
        MathAnswer(byte[] memory,String word,int status,int slot) {
            this.memory=memory;this.word=word;this.status=status;this.slot=slot;
        }
    }
    private static MathAnswer calculate(Context ctx,byte[] state,int a,int b,int op)
        throws IOException {
        String s=source()+set(B+320,1)+set(B+321,a)+set(B+322,b)+set(B+323,op);
        ResultPacket thought=execute(ctx,xi(state,s),"calculate");
        long[] regs=values(thought.output);
        if(regs.length<2)throw new IOException("Resultado aritmético XI incompleto");
        ResultPacket named=execute(ctx,thought.state,"name");
        return new MathAnswer(named.state,speak(named.output),(int)regs[0],(int)regs[1]);
    }
    private static byte[] gradeMath(Context ctx,MathAnswer answer,int expected)throws IOException {
        ResultPacket grade=execute(ctx,xi(answer.memory,source()
            +set(B+350,1)+set(B+351,expected)),"grade-math");
        long[] regs=values(grade.output);
        if(regs.length<1||regs[0]!=1)
            throw new IOException("La operación XI falló el examen independiente");
        return grade.state;
    }
    private static byte[] audit(Context ctx,byte[] state)throws IOException {
        return run(ctx,state,"audit");
    }
    private static String[] dataset(Context ctx,String name)throws IOException {
        return asset(ctx,"school/data/"+name).split("\\r?\\n");
    }
    private static String[] columns(String line,int count)throws IOException {
        String[] pieces=line.split("\\|",-1);
        if(pieces.length!=count)throw new IOException("Registro del curriculum inválido");
        return pieces;
    }
    static Status install(Context ctx,SessionStore store,BbyqBridge.Progress callback)throws IOException {
        byte[] original=store.loadState();
        BbyqBridge.Status source=BbyqBridge.status(original);
        if(!source.ready())throw new IOException("Inicia primero la inteligencia E009");
        Status existing=status(original);
        if(existing.ready()){
            audit(ctx,original);
            return existing;
        }
        if(existing.signature!=0)
            throw new IOException("Desarrollo XI parcial o incompatible. No borré tu memoria.");
        byte[] state=run(ctx,original,"birth");
        if(callback!=null)callback.show("Aprendiendo colores, animales, figuras y cantidades...");
        String[] examples=dataset(ctx,"observations-v1.psv");
        int taught=0;
        for(int pass=0;pass<2;pass++)for(String line:examples) {
            line=line.trim();
            if(line.isEmpty()||line.startsWith("#"))continue;
            state=train(ctx,state,columns(line,6));
            taught++;
        }
        if(taught!=44)throw new IOException("Faltan experiencias sensoriales XI");
        state=audit(ctx,state);
        if(callback!=null)callback.show("Comprobando conceptos con ejemplos no vistos...");
        String[] holdout=dataset(ctx,"holdout-v1.psv");
        for(int lang=1;lang<=2;lang++) {
            state=language(ctx,state,lang);
            int tested=0;
            for(String line:holdout) {
                line=line.trim();
                if(line.isEmpty()||line.startsWith("#"))continue;
                String[] f=columns(line,7);
                int d=Integer.parseInt(f[0]),x=Integer.parseInt(f[1]),
                    y=Integer.parseInt(f[2]),z=Integer.parseInt(f[3]),
                    expected=Integer.parseInt(f[4]);
                Classified prediction=recognize(ctx,state,d,x,y,z);
                String right=lang==1?f[5]:f[6];
                if(!prediction.name.equals(right)||prediction.slot!=expected)
                    throw new IOException("BBY Q falló prueba bilingüe "+d+"/"+tested);
                state=grade(ctx,prediction,expected);
                tested++;
            }
            if(tested!=30)throw new IOException("Examen E010 incompleto");
        }
        ResultPacket promotion=execute(ctx,state,"next");
        if(values(promotion.output)[0]!=1)
            throw new IOException("La entidad aún no domina sus cuatro categorías");
        state=promotion.state;
        if(callback!=null)callback.show("Enseñando el efecto de juntar y quitar cantidades...");
        state=teachOperation(ctx,state,1,2,1,3);
        state=teachOperation(ctx,state,1,4,2,6);
        state=teachOperation(ctx,state,2,6,2,4);
        state=teachOperation(ctx,state,2,7,3,4);
        int[][] cases={{3,2,1,5},{5,4,1,9},{9,2,2,7},{5,3,2,2},{9,3,1,255}};
        String[] es={"cinco","nueve","siete","dos","?"};
        String[] en={"five","nine","seven","two","?"};
        for(int lang=1;lang<=2;lang++) {
            state=language(ctx,state,lang);
            for(int i=0;i<cases.length;i++){
                int[] task=cases[i];
                MathAnswer outcome=calculate(ctx,state,task[0],task[1],task[2]);
                String expect=lang==1?es[i]:en[i];
                if(!outcome.word.equals(expect))
                    throw new IOException("BBY Q no generalizó operación "+i);
                state=gradeMath(ctx,outcome,task[3]);
            }
        }
        promotion=execute(ctx,state,"next");
        if(values(promotion.output)[0]!=2)
            throw new IOException("Operaciones no aprobaron el examen XI");
        state=language(ctx,promotion.state,1); // initial UI language: Español
        state=audit(ctx,state);
        state=ResultPacket.parse(NativeRuntime.execute(state,
            asset(ctx,"e008/audit-organism.xi"))).state;
        state=ResultPacket.parse(NativeRuntime.execute(state,
            asset(ctx,"language/audit.xi"))).state;
        Status passed=status(state);
        if(!passed.ready())throw new IOException("El desarrollo XI quedó incompleto");
        // One RVPC2 publish only after the whole curriculum and two-language
        // exams finish. Failure always preserves the original organism.
        store.writeState(state);
        Log.i(TAG,"BBYQ_SCHOOL_INSTALL_OK count="+passed.concepts+
            " phase="+passed.phase+" lang="+passed.language);
        if(callback!=null)callback.show("BBY Q continúa aprendiendo en español e inglés.");
        return passed;
    }
    static Status setLanguage(Context ctx,SessionStore store,int language)throws IOException {
        byte[] initial=store.loadState();
        if(!status(initial).ready())throw new IOException("Desarrollo XI no instalado");
        byte[] updated=audit(ctx,language(ctx,initial,language));
        store.writeState(updated);
        Log.i(TAG,"BBYQ_LANGUAGE_SWITCH_OK lang="+language);
        return status(updated);
    }
    static String identify(Context ctx,SessionStore store,int domain,int x,int y,int z)
        throws IOException {
        if(domain<1||domain>4)throw new IOException("Dominio fuera de 1..4");
        byte[] initial=store.loadState();
        if(!status(initial).ready())throw new IOException("Escuela adaptativa no preparada");
        Classified result=recognize(ctx,initial,domain,x,y,z);
        byte[] audited=audit(ctx,result.memory);
        store.writeState(audited);
        Log.i(TAG,"BBYQ_CATEGORY_OK domain="+domain+" name="+result.name+
            " confidence="+result.status);
        return result.name;
    }
    static String arithmetic(Context ctx,SessionStore store,int a,int amount,int operator)
        throws IOException {
        if(a<0||a>9||amount<1||amount>9||operator<1||operator>2)
            throw new IOException("Cuentas XI de 0 a 9, cantidad positiva");
        byte[] initial=store.loadState();
        if(!status(initial).ready())throw new IOException("Operaciones XI no aprobadas");
        MathAnswer result=calculate(ctx,initial,a,amount,operator);
        store.writeState(audit(ctx,result.memory));
        Log.i(TAG,"BBYQ_ARITHMETIC_OK count="+a+" value="+amount+
            " operator="+operator+" result="+result.word);
        return result.word;
    }
    static Status teachObservation(Context ctx,SessionStore store,int domain,int x,int y,int z,
                                  String spanish,String english)throws IOException {
        byte[] initial=store.loadState();
        if(!status(initial).ready())throw new IOException("Desarrollo XI no disponible");
        String[] event={String.valueOf(domain),String.valueOf(x),String.valueOf(y),
                        String.valueOf(z),spanish,english};
        byte[] staged=train(ctx,initial,event);
        staged=train(ctx,staged,event);
        store.writeState(audit(ctx,staged));
        Log.i(TAG,"BBYQ_SCHOOL_TEACH_OK domain="+domain);
        return status(staged);
    }
}
