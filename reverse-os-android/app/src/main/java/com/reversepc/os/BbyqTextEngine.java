package com.reversepc.os;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** Byte transport, native roles and immutable candidate arrays. No prompt,
 * lesson, algorithm or scheduling decisions are implemented in Java. */
public final class BbyqTextEngine {
    public static final int INPUT_LIMIT=16384,OUTPUT_LIMIT=65536;
    static final long F=9100000000000200000L,C=F+256,
        B=9090000000000000000L,Q=8460000000000000000L,M=8300000000000000000L;
    public interface Assets { byte[] get(String name)throws Exception; }
    public interface Backend {
        byte[] execute(byte[] state,String source)throws Exception;
        byte[] executeRxe(byte[] state,byte[] program)throws Exception;
        byte[] compile(byte[] source,byte[] title)throws Exception;
        byte[] initialize()throws Exception;
    }
    public static final Backend JNI=new Backend(){
        public byte[] execute(byte[] state,String source){return NativeRuntime.execute(state,source);}
        public byte[] executeRxe(byte[] state,byte[] program){return NativeRuntime.executeRxe(state,program);}
        public byte[] compile(byte[] source,byte[] title){return NativeRuntime.compileRxe(source,title);}
        public byte[] initialize(){return NativeRuntime.initialize();}
    };
    public interface DispatchCommit {void save(byte[] dispatched,String progressText)throws Exception;}
    public static final class Phase {
        public final String file,sha256;public final long marker;public final int magic;
        public Phase(String file,String sha256){this(file,sha256,0,0);}
        public Phase(String file,String sha256,long marker,int magic){this.file=file;this.sha256=sha256;this.marker=marker;this.magic=magic;}
    }
    public static final class Delivery {
        public final byte[] state;public final String text;public final boolean executed,verified;
        Delivery(byte[] state,String text,boolean executed,boolean verified){this.state=state;this.text=text;this.executed=executed;this.verified=verified;}
    }
    final Backend backend;final Assets assets;final String codeHash;final Map<String,String> roles;
    private static final Pattern EVENT=Pattern.compile("^\\{\\s*\"type\"\\s*:\\s*\"register\"\\s*,\\s*\"register\"\\s*:\\s*\"(r(?:[0-9]|1[0-5]))\"\\s*,\\s*\"value\"\\s*:\\s*(-?[0-9]+)\\s*\\}$");
    public BbyqTextEngine(Backend backend,Assets assets,String codeHash,Map<String,String> roles){this.backend=backend;this.assets=assets;this.codeHash=codeHash;this.roles=new HashMap<>(roles);}
    public static String hash(byte[] b)throws Exception{StringBuilder s=new StringBuilder();for(byte n:MessageDigest.getInstance("SHA-256").digest(b))s.append(String.format(java.util.Locale.ROOT,"%02x",n&255));return s.toString();}
    byte[] trusted(String name,String expected)throws Exception{byte[] b=assets.get(name);if(expected==null||!hash(b).equals(expected))throw new IOException("E_BUILD: archivo de programa incompatible: "+name);return b;}
    ResultPacket source(byte[] state,String code)throws Exception{return ResultPacket.parse(backend.execute(state,code));}
    ResultPacket role(byte[] state,String name)throws Exception{return source(state,decode(trusted(name,roles.get(name))));}
    public byte[] migrate(byte[] previous,List<Phase> phases)throws Exception{
        byte[] candidate=previous;
        for(Phase phase:phases){if(phase.marker!=0&&new Cells(candidate).at(phase.marker)==phase.magic)continue;candidate=ResultPacket.parse(backend.executeRxe(candidate,trusted(phase.file,phase.sha256))).state;}
        candidate=role(candidate,"guard.xi").state;candidate=role(candidate,"guard-x07.xi").state;return candidate;
    }
    public Delivery turn(byte[] previous,String message,int language,DispatchCommit checkpoint)throws Exception{
        byte[] raw=encode(message);if(raw.length>INPUT_LIMIT)throw new IOException("E_SIZE: el mensaje supera 16384 bytes");if(language!=1&&language!=2)throw new IOException("E_LANGUAGE: idioma no válido");
        byte[] candidate=role(previous,"guard.xi").state;candidate=role(candidate,"guard-x07.xi").state;
        if(!Arrays.equals(candidate,previous))throw new IOException("E_PREFLIGHT: una comprobación modificó la sesión");
        // Small transport chunks also fit the unchanged Android raw-source ABI.
        for(int start=0;start<raw.length||start==0;start+=4096){int end=Math.min(raw.length,start+4096);StringBuilder stage=new StringBuilder("#!reverse-pc-machine-v1\n");
            if(start==0)stage.append(put(F+2,0)).append(put(F+3,0)).append(put(F+4,language)).append(put(F+8,raw.length&255)).append(put(F+9,raw.length>>>8)).append(put(F+10,0));
            for(int i=start;i<end;i++)stage.append(put(C+i,raw[i]&255));if(end==raw.length)stage.append(put(F+2,1));stage.append("halt\n");candidate=source(candidate,stage.toString()).state;if(end==raw.length)break;
        }
        ResultPacket reply=ResultPacket.parse(backend.executeRxe(candidate,trusted("code.rxe",codeHash)));candidate=reply.state;Cells fields=new Cells(candidate);
        if(fields.at(F+3)==3){String[] errors={"E_PROTOCOL","E_EMPTY","E_SIZE","E_UTF8","E_CONTROL","E_VERSION","E_LANGUAGE","E_UNSUPPORTED_TEXT"};int n=fields.at(F+10);throw new IOException((n<errors.length?errors[n]:errors[0])+": entrada rechazada sin publicar cambios");}
        if(fields.at(F+2)!=0||(fields.at(F+3)!=1&&fields.at(F+3)!=2))throw new IOException("E_PROTOCOL: el mensaje no fue consumido");
        String text=speech(reply.output);boolean executed=false,verified=false;
        if(fields.at(B+2)==2){Delivery coded=executeTask(candidate,checkpoint);candidate=coded.state;text=coded.text;executed=coded.executed;verified=coded.verified;}
        candidate=role(candidate,"text-finish.xi").state;
        if(encode(text).length>OUTPUT_LIMIT)throw new IOException("E_OUTPUT_SIZE: respuesta fuera del contrato");
        return new Delivery(candidate,text,executed,verified);
    }
    Delivery executeTask(byte[] state,DispatchCommit checkpoint)throws Exception{
        Cells before=new Cells(state);if(before.occupied(Q,Q+128)||before.occupied(M+768,M+786))throw new IOException("E_DELEGATION: región temporal ocupada");
        byte[] program=before.bytes(B+1024,(int)before.uint(B+8,2),4096),digest=MessageDigest.getInstance("SHA-256").digest(program);long generation=before.uint(B+10,4),attempt=before.uint(B+14,4);if(attempt==0)throw new IOException("E_ATTEMPT: falta la solicitud nativa");
        StringBuilder bind=new StringBuilder("#!reverse-pc-machine-v1\n");for(int i=0;i<32;i++)bind.append(put(B+32+i,digest[i]&255));bind.append(put(Q,66)).append(put(Q+1,1)).append(put(Q+6,1)).append(put(Q+64,1)).append(put(Q+65,1));for(int i=0;i<4;i++)bind.append(put(Q+60+i,(int)(attempt>>>(i*8))&255)).append(put(Q+70+i,digest[i]&255));bind.append("halt\n");byte[] candidate=source(state,bind.toString()).state;
        for(String name:new String[]{"qdu-plan.xi","qdu-dispatch.xi","dispatch.xi"}){ResultPacket p=role(candidate,name);List<Long> status=registers(p.output,null);if(status.size()!=1||status.get(0)!=0){byte[] failed=source(state,"#!reverse-pc-machine-v1\n"+put(B+2,5)+put(B+7,2)+"halt\n").state;return new Delivery(failed,"w4U rechazó la ejecución. No se ejecutó el programa.",false,false);}candidate=p.state;}
        Cells dispatched=new Cells(candidate);if(dispatched.at(B+2)!=3||dispatched.uint(B+10,4)!=generation||dispatched.uint(B+14,4)!=attempt||!Arrays.equals(program,dispatched.bytes(B+1024,(int)dispatched.uint(B+8,2),4096)))throw new IOException("E_BINDING: cambió la tarea autorizada");
        // The session owner persists this consumed dispatch before native code.
        String dispatchHash=hash(candidate);
        if(checkpoint!=null)checkpoint.save(candidate.clone(),"Ejecución XI autorizada; falta confirmar el resultado.");
        if(!dispatchHash.equals(hash(candidate)))throw new IOException("E_BINDING: cambió la memoria de ejecución");
        int hostStatus=1;List<Long> values=new ArrayList<>();byte[] binary=null;
        try{binary=backend.compile(program,encode("BBY Q X07 isolated XI program"));}catch(Exception failed){hostStatus=2;}
        if(binary!=null)try{ResultPacket actual=ResultPacket.parse(backend.executeRxe(backend.initialize(),binary));values=registers(actual.output,null);if(values.size()<1||values.size()>16)throw new IOException("Unexpected native output count");for(long value:values)if(value < -1000000000000L||value>1000000000000L)throw new IOException("Native output outside ABI");}catch(Exception failed){hostStatus=3;values.clear();}
        StringBuilder receipt=new StringBuilder("#!reverse-pc-machine-v1\n");for(int i=0;i<4;i++)receipt.append(put(B+256+i,(int)(generation>>>(i*8))&255)).append(put(B+260+i,(int)(attempt>>>(i*8))&255));for(int i=0;i<32;i++)receipt.append(put(B+264+i,digest[i]&255));receipt.append(put(B+296,hostStatus)).append(put(B+297,values.size()));for(int i=0;i<values.size();i++){long value=values.get(i),magnitude=Math.abs(value),p=B+512+i*9L;receipt.append(put(p,value<0?1:0));for(int j=0;j<8;j++)receipt.append(put(p+1+j,(int)(magnitude>>>(j*8))&255));}receipt.append("halt\n");candidate=source(candidate,receipt.toString()).state;
        ResultPacket reviewed=role(candidate,"review.xi");List<Long> verdict=registers(reviewed.output,null);if(verdict.size()!=1)throw new IOException("E_REVIEW: respuesta incompleta");ResultPacket delivered=role(reviewed.state,"result.xi");return new Delivery(delivered.state,speech(delivered.output),true,verdict.get(0)==0);
    }
    static String put(long address,int value){return "store8 "+address+" "+value+"\n";}
    static byte[] encode(String text)throws CharacterCodingException{if(text==null)throw new IllegalArgumentException("Missing text");ByteBuffer b=StandardCharsets.UTF_8.newEncoder().onMalformedInput(CodingErrorAction.REPORT).onUnmappableCharacter(CodingErrorAction.REPORT).encode(java.nio.CharBuffer.wrap(text));byte[] out=new byte[b.remaining()];b.get(out);return out;}
    static String decode(byte[] b)throws CharacterCodingException{return StandardCharsets.UTF_8.newDecoder().onMalformedInput(CodingErrorAction.REPORT).onUnmappableCharacter(CodingErrorAction.REPORT).decode(ByteBuffer.wrap(b)).toString();}
    static List<Long> registers(String jsonl,String selected)throws IOException{List<Long> values=new ArrayList<>();for(String line:jsonl.split("\n")){if(!line.startsWith("{"))continue;Matcher m=EVENT.matcher(line);if(!m.matches()){if(line.contains("\"type\":\"register\""))throw new IOException("E_EVENT: registro nativo inválido");continue;}if(selected==null||selected.equals(m.group(1)))try{values.add(Long.parseLong(m.group(2)));}catch(NumberFormatException invalid){throw new IOException("E_EVENT: número nativo inválido");}}return values;}
    static String speech(String jsonl)throws Exception{ByteArrayOutputStream out=new ByteArrayOutputStream();for(String line:jsonl.split("\n")){Matcher m=EVENT.matcher(line);if(!m.matches()){if(line.startsWith("{")&&line.contains("\"type\":\"register\""))throw new IOException("E_EVENT: registro nativo inválido");continue;}if(!"r14".equals(m.group(1))&&!"r9".equals(m.group(1)))continue;long n=Long.parseLong(m.group(2));if(n<0||n>255||n==127||(n<32&&n!=9&&n!=10&&n!=13)||out.size()>=OUTPUT_LIMIT)throw new IOException("E_OUTPUT: byte o longitud fuera del contrato");out.write((int)n);}if(out.size()==0)throw new IOException("E_OUTPUT_EMPTY: falta la respuesta");return decode(out.toByteArray());}
    static final class Cells {
        final Map<Long,Integer> cells=new HashMap<>();
        Cells(byte[] state)throws Exception{if(state.length<29)throw new IOException("Invalid RVPC2");long core=ByteBuffer.wrap(state).order(ByteOrder.LITTLE_ENDIAN).getLong(5);if(core<0||core>state.length-29)throw new IOException("Invalid RVPC2 dimensions");String memory=decode(Arrays.copyOfRange(state,(int)(29+core),state.length));for(String line:memory.split("\n")){if(!line.startsWith("O "))continue;String[] p=line.split(" ");if(p.length!=3)continue;long address;try{address=Long.parseLong(p[1]);}catch(NumberFormatException outsideHostDomain){continue;}boolean wanted=(address>=8700000000000000000L&&address<8700000000000018008L)||(address>=9180000000000000000L&&address<9180000000000000008L)||(address>=9180000000001000000L&&address<9180000000001000512L)||(address>=9120000000000000000L&&address<9120000000000000256L)||(address>=B&&address<B+8192)||(address>=F&&address<F+256)||(address>=Q&&address<Q+128)||(address>=M+768&&address<M+786)||address==9060000000000000000L||address==9070000000000000000L||address==9080000000000000000L||address==9100000000000000000L||address==9110000000000000000L;if(wanted){int value=Integer.parseInt(p[2]);if(value<0||value>255)throw new IOException("Invalid logical byte");if(value!=0)cells.put(address,value);}}}
        int at(long p){Integer n=cells.get(p);return n==null?0:n;}
        long uint(long p,int n){long x=0;for(int i=0;i<n;i++)x|=((long)at(p+i))<<(8*i);return x;}
        byte[] bytes(long p,int n,int limit)throws IOException{if(n<0||n>limit)throw new IOException("Invalid byte span");byte[] b=new byte[n];for(int i=0;i<n;i++)b[i]=(byte)at(p+i);return b;}
        boolean occupied(long a,long b){for(long p:cells.keySet())if(p>=a&&p<b)return true;return false;}
    }
}
