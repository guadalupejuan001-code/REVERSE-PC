package com.reversepc.os;

import java.io.*;
import java.nio.*;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;
import java.util.zip.*;

/** Android byte transport for the unchanged X08/X09 XI roles. No language,
 * dictionary search, campaign reasoning or generated-program logic runs here. */
public final class BbyqX09Engine {
    public interface Source {InputStream open(String name)throws Exception;}
    private static final long F=9100000000000200000L,C=F+256,X=9120000000000000000L,
        K=9110000000000000000L,D=8700000000000000000L,A=9180000000000000000L;
    private final Source source;private final BbyqTextEngine.Backend backend;
    private final Properties config=new Properties();private final Set<String> verified=new HashSet<>();
    private final BbyqTextEngine execution;private byte[] index;
    public BbyqX09Engine(Source source,BbyqTextEngine.Backend backend)throws Exception{
        this.source=source;this.backend=backend;
        try(InputStream in=source.open("x09.properties")){config.load(new InputStreamReader(in,StandardCharsets.UTF_8));}
        if(!"X09-All-Training-1".equals(config.getProperty("version")))throw new IOException("E_X09_BUILD");
        Map<String,String> roles=new HashMap<>();for(String key:config.stringPropertyNames())if(key.startsWith("sha.")&&key.endsWith(".xi"))roles.put(key.substring(4),config.getProperty(key));
        execution=new BbyqTextEngine(backend,this::asset,config.getProperty("sha.code.rxe"),roles);
    }
    private byte[] asset(String name)throws Exception{
        if(!name.matches("[a-zA-Z0-9][a-zA-Z0-9./-]*")||name.contains(".."))throw new IOException("E_ASSET_PATH");
        byte[] b;try(InputStream in=source.open(name)){b=limited(in,16*1024*1024);}
        if(!BbyqTextEngine.hash(b).equals(config.getProperty("sha."+name)))throw new IOException("E_X09_INTEGRITY: "+name);return b;
    }
    static byte[] limited(InputStream in,int limit)throws IOException{ByteArrayOutputStream out=new ByteArrayOutputStream();byte[] b=new byte[8192];for(int n;(n=in.read(b))!=-1;){if(out.size()+n>limit)throw new IOException("E_ASSET_SIZE");out.write(b,0,n);}return out.toByteArray();}
    public byte[] seed()throws Exception{byte[] data=asset("model.rvp.gz"),state;try(GZIPInputStream in=new GZIPInputStream(new ByteArrayInputStream(data))){state=limited(in,32*1024*1024);}if(!BbyqTextEngine.hash(state).equals(config.getProperty("model.sha256")))throw new IOException("E_X09_MODEL");return state;}
    private ResultPacket xi(byte[] state,String text)throws Exception{return ResultPacket.parse(backend.execute(state,text));}
    private ResultPacket role(byte[] state,String name)throws Exception{return name.endsWith(".rxe")?ResultPacket.parse(backend.executeRxe(state,asset(name))):xi(state,BbyqTextEngine.decode(asset(name)));}
    private static BbyqTextEngine.Cells cells(byte[] s)throws Exception{return new BbyqTextEngine.Cells(s);}
    public byte[] migrate(byte[] previous)throws Exception{
        BbyqTextEngine.Cells c=cells(previous);byte[] s=previous;
        if(c.at(K)!=87)throw new IOException("E_X09_MIGRATION: primero se requiere la migración X07");
        if(c.at(X)!=88){
            long[][] spans={{K+331776,4096L*640+4096-331776},{K+4000000,8192},{X,256},{X+100000,49152},{600000000,8192+225418},{601000000,4096+2048L*256},{602000000,65536+6910L*112}};
            for(long[] span:spans)for(long off=0;off<span[1];off+=32768){long n=Math.min(32768,span[1]-off);String code="#!reverse-pc-machine-v1\nset r0 0\nlabel scan\nset r7 "+(span[0]+off)+"\nadd r7 r0\nload8 r3 $r7\ncmp r3 0\njne refuse\nadd r0 1\ncmp r0 "+n+"\njlt scan\nhalt\nlabel refuse\nset r0 0\nmod r0 0\n";s=xi(s,code).state;}
            int count=Integer.parseInt(config.getProperty("phase.count"));if(count<1||count>512)throw new IOException("E_X09_PHASES");
            for(int i=0;i<count;i++){String name=config.getProperty("phase."+i);ResultPacket r=role(s,name);s=r.state;if(name.startsWith("install-lesson-")){List<Long> v=BbyqTextEngine.registers(r.output,null);if(v.size()!=1||(v.get(0)!=0&&v.get(0)!=2))throw new IOException("E_X09_LESSON: "+name);}}
        }else if(c.at(X+1)!=1)throw new IOException("E_X09_SCHEMA");
        c=cells(s);if(c.at(A+2)!=9){byte[] before=s;ResultPacket r=role(s,"campaign/campaign-migrate.rxe");List<Long> v=BbyqTextEngine.registers(r.output,"r0");if(v.size()!=1||v.get(0)!=0)throw new IOException("E_X09_CAMPAIGN_MIGRATION");
            if(!stableMemory(before,A,A+1000000).equals(stableMemory(r.state,A,A+1000000)))throw new IOException("E_X09_RETENTION");s=r.state;}
        role(s,"guard.xi");role(s,"guard-x07.xi");return s;
    }
    public BbyqTextEngine.Delivery turn(byte[] prior,String message,int language,BbyqTextEngine.DispatchCommit checkpoint)throws Exception{
        byte[] raw=BbyqTextEngine.encode(message);if(raw.length>BbyqTextEngine.INPUT_LIMIT)throw new IOException("E_SIZE");if(language!=1&&language!=2)throw new IOException("E_LANGUAGE");
        byte[] s=migrate(prior);s=role(s,"guard.xi").state;
        for(int start=0;start<raw.length||start==0;start+=4096){int end=Math.min(raw.length,start+4096);StringBuilder q=new StringBuilder("#!reverse-pc-machine-v1\n");if(start==0)q.append(put(F+2,1)).append(put(F+3,0)).append(put(F+4,language)).append(put(F+8,raw.length&255)).append(put(F+9,raw.length>>>8)).append(put(F+10,0));for(int i=start;i<end;i++)q.append(put(C+i,raw[i]&255));q.append("halt\n");s=xi(s,q.toString()).state;if(end==raw.length)break;}
        ResultPacket reply=role(s,"front.rxe");s=reply.state;BbyqTextEngine.Cells c=cells(s);if(c.at(F+3)==3)throw new IOException("E_X09_INPUT_"+c.at(F+10));
        if(c.at(X+2)==0){ResultPacket extension=dictionary(s);if(extension==null)extension=campaign(s);reply=extension==null?role(s,"code.rxe"):extension;s=reply.state;}
        c=cells(s);if(c.at(F+2)!=0||(c.at(F+3)!=1&&c.at(F+3)!=2))throw new IOException("E_X09_PROTOCOL");
        String text=BbyqTextEngine.speech(reply.output);boolean executed=false,checked=false;
        if(c.at(BbyqTextEngine.B+2)==2){BbyqTextEngine.Delivery r=execution.executeTask(s,checkpoint);s=r.state;text=r.text;executed=r.executed;checked=r.verified;}
        s=role(s,"text-finish.xi").state;return new BbyqTextEngine.Delivery(s,text,executed,checked);
    }
    private ResultPacket dictionary(byte[] before)throws Exception{
        BbyqTextEngine.Cells old=cells(before);ResultPacket r=role(before,"dictionary/route.rxe");List<Long> status=BbyqTextEngine.registers(r.output,"r0");if(status.isEmpty())throw new IOException("E_DICT_PROTOCOL");long kind=status.get(status.size()-1);if(kind==0)return null;if(kind==2)return r;if(kind!=1)throw new IOException("E_DICT_ROUTE");
        List<Long> keys=BbyqTextEngine.registers(r.output,"r1");if(keys.isEmpty())throw new IOException("E_DICT_PAGE");int key=Math.toIntExact(keys.get(keys.size()-1));byte[] page=page(key),s=r.state;
        StringBuilder header=new StringBuilder();for(int i=0;i<3;i++)header.append(put(D+8+i,(key>>>(i*8))&255)).append(put(D+16+i,(page.length>>>(i*8))&255));s=xi(s,"#!reverse-pc-machine-v1\n"+header+"halt\n").state;
        for(int start=0;start<page.length;start+=4096){StringBuilder q=new StringBuilder("#!reverse-pc-machine-v1\n");for(int i=start;i<Math.min(page.length,start+4096);i++)q.append(put(D+1024+i,page[i]&255));s=xi(s,q+"halt\n").state;}
        r=role(s,"dictionary/lookup.rxe");List<Long> found=BbyqTextEngine.registers(r.output,"r0");long result=found.isEmpty()?-1:found.get(found.size()-1);if(result==4)return null;if(result!=2)throw new IOException("E_DICT_LOOKUP");
        ResultPacket cleared=role(r.state,"dictionary/clear.rxe");List<Long> erased=BbyqTextEngine.registers(cleared.output,"r0");if(erased.isEmpty()||erased.get(erased.size()-1)!=0)throw new IOException("E_DICT_CLEAR");s=cleared.state;StringBuilder restore=new StringBuilder("#!reverse-pc-machine-v1\n");for(Map.Entry<Long,Integer> e:old.cells.entrySet())if(e.getKey()>=D&&e.getKey()<D+18008)restore.append(put(e.getKey(),e.getValue()));s=xi(s,restore+"halt\n").state;
        return ResultPacket.parse(ResultPacket.encode(r.output,s));
    }
    private ResultPacket campaign(byte[] before)throws Exception{ResultPacket r=role(before,"campaign/campaign-role.rxe");BbyqTextEngine.Cells c=cells(r.state);if(c.at(A+3)==0)return null;if(c.at(A+3)!=1||c.at(F+2)!=0||c.at(F+3)!=1)throw new IOException("E_CAMPAIGN_PROTOCOL");if(!stableMemory(before,A+3,A+8).equals(stableMemory(r.state,A+3,A+8)))throw new IOException("E_CAMPAIGN_RETENTION");for(long p=A+1000000;p<A+1000512;p++)if(c.at(p)!=0)throw new IOException("E_CAMPAIGN_SCRATCH");return r;}
    private synchronized byte[] page(int key)throws Exception{
        if(key<0||key>=131072)throw new IOException("E_DICT_KEY");if(index==null){index=asset("dictionary/pages.index");if(index.length!=64+131072*48||!new String(index,0,13,StandardCharsets.US_ASCII).equals("BBYQ-DICT-X09"))throw new IOException("E_DICT_INDEX");verifyStream("dictionary/pages.data");}
        ByteBuffer v=ByteBuffer.wrap(index).order(ByteOrder.LITTLE_ENDIAN);if(v.getInt(16)!=1||v.getInt(20)!=131072||v.getInt(24)!=48)throw new IOException("E_DICT_FORMAT");int at=64+48*key;long offset=v.getLong(at);int packed=v.getInt(at+8),length=v.getInt(at+12);if(packed==0&&length==0){for(int i=0;i<48;i++)if(index[at+i]!=0)throw new IOException("E_DICT_EMPTY_RECORD");return new byte[0];}if(offset<0||packed<1||length<1||length>16984||offset+packed>Long.parseLong(config.getProperty("dictionary.data.bytes")))throw new IOException("E_DICT_BOUNDS");
        byte[] bytes=new byte[packed];try(InputStream in=source.open("dictionary/pages.data")){skip(in,offset);int got=0;while(got<packed){int n=in.read(bytes,got,packed-got);if(n<1)throw new EOFException();got+=n;}}
        byte[] raw;try(InflaterInputStream in=new InflaterInputStream(new ByteArrayInputStream(bytes),new Inflater(true))){raw=limited(in,length);}if(raw.length!=length)throw new IOException("E_DICT_LENGTH");String expected=hex(Arrays.copyOfRange(index,at+16,at+48));if(!BbyqTextEngine.hash(raw).equals(expected))throw new IOException("E_DICT_PAGE_HASH");return raw;
    }
    private void verifyStream(String name)throws Exception{if(verified.contains(name))return;MessageDigest h=MessageDigest.getInstance("SHA-256");try(InputStream in=source.open(name)){byte[] b=new byte[65536];for(int n;(n=in.read(b))!=-1;)h.update(b,0,n);}if(!hex(h.digest()).equals(config.getProperty("sha."+name)))throw new IOException("E_X09_INTEGRITY: "+name);verified.add(name);}
    private static void skip(InputStream in,long n)throws IOException{while(n>0){long k=in.skip(n);if(k<1){if(in.read()<0)throw new EOFException();k=1;}n-=k;}}
    private static String hex(byte[] b){StringBuilder s=new StringBuilder();for(byte v:b)s.append(String.format(Locale.ROOT,"%02x",v&255));return s.toString();}
    private static String put(long p,int value){return "store8 "+p+" "+value+"\n";}
    private static String stableMemory(byte[] state,long low,long high)throws Exception{
        int core=Math.toIntExact(ByteBuffer.wrap(state).order(ByteOrder.LITTLE_ENDIAN).getLong(5));MessageDigest h=MessageDigest.getInstance("SHA-256");h.update(state,29,core);
        try(BufferedReader in=new BufferedReader(new InputStreamReader(new ByteArrayInputStream(state,29+core,state.length-29-core),StandardCharsets.UTF_8))){for(String line;(line=in.readLine())!=null;){if(!line.startsWith("O "))continue;int end=line.indexOf(' ',2);long a;try{a=Long.parseLong(line.substring(2,end));}catch(NumberFormatException outside){h.update(line.getBytes(StandardCharsets.UTF_8));continue;}if((a>=low&&a<high)||a==F+2||a==F+3)continue;h.update(line.getBytes(StandardCharsets.UTF_8));h.update((byte)10);}}return hex(h.digest());
    }
}
