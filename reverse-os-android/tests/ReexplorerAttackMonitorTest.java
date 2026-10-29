package com.reversepc.os;

import java.util.Random;

/** Pure JVM black-box test: no Android device, network, DOM or real exploits. */
public final class ReexplorerAttackMonitorTest {
    private static int checks;
    private static void test(boolean passed,String name){
        if(!passed)throw new AssertionError(name);checks++;
    }
    private static ReexplorerAttackMonitor.Decision inspect(
            ReexplorerAttackMonitor monitor,ReexplorerAttackMonitor.Event e,
            String url,boolean main,long at){
        return monitor.inspect(e,url,main,at);
    }
    private static void decision(ReexplorerAttackMonitor.Decision result,
            ReexplorerAttackMonitor.Action want,String name){
        test(result.action==want,name+" -> "+result.action);
    }
    public static void main(String[] args){
        ReexplorerAttackMonitor guard=new ReexplorerAttackMonitor();
        decision(inspect(guard,ReexplorerAttackMonitor.Event.NAVIGATION,
                "https://robinhood.com/",true,1000),
                ReexplorerAttackMonitor.Action.ALLOW,"Robinhood HTTPS");
        test(guard.interceptedCount()==0,"normal HTTPS should not count as attack");
        decision(inspect(guard,ReexplorerAttackMonitor.Event.SUBRESOURCE,
                "https://cdn.example.org/app.js",false,1001),
                ReexplorerAttackMonitor.Action.ALLOW,"public HTTPS resource");
        for(String url:new String[]{
                "http://evil.example.org/","file:///sdcard/private",
                "content://contacts/people","https://127.0.0.1/",
                "https://192.168.1.1/","https://internal.local/",
                "https://robinhood.com:8080/path","javascript:alert(1)"
        }){
            guard.reset();
            ReexplorerAttackMonitor.Decision blocked=inspect(guard,
                    ReexplorerAttackMonitor.Event.NAVIGATION,url,true,1200);
            decision(blocked,ReexplorerAttackMonitor.Action.BLOCK,"blocked "+url);
            test(!blocked.reason.contains("private")&&!blocked.reason.contains("evil"),
                    "no sensitive URL echo");
        }
        guard.reset();
        for(int i=0;i<3;i++){
            ReexplorerAttackMonitor.Decision d=inspect(guard,
                    ReexplorerAttackMonitor.Event.NAVIGATION,
                    "http://untrusted.example.org/"+i,true,1000+i*100);
            decision(d,i<2?ReexplorerAttackMonitor.Action.BLOCK:
                    ReexplorerAttackMonitor.Action.QUARANTINE,
                    "3 denied top-level navigation attempts -> quarantine");
        }
        test(guard.isQuarantined(),"sticky quarantine after repeated blocked mainframes");
        decision(inspect(guard,ReexplorerAttackMonitor.Event.NAVIGATION,
                "https://robinhood.com/",true,5000),
                ReexplorerAttackMonitor.Action.QUARANTINE,
                "quarantine cannot be bypassed by benign next URL");
        guard.reset();
        test(!guard.isQuarantined()&&guard.interceptedCount()==0,
                "local manual reset clears quarantine and counters");
        for(ReexplorerAttackMonitor.Event event:new ReexplorerAttackMonitor.Event[]{
                ReexplorerAttackMonitor.Event.TLS_FAILURE,
                ReexplorerAttackMonitor.Event.SAFE_BROWSING,
                ReexplorerAttackMonitor.Event.RENDERER_FAILURE}){
            guard.reset();
            decision(inspect(guard,event,null,true,1200),
                    ReexplorerAttackMonitor.Action.QUARANTINE,
                    "high-risk provider signal -> quarantine "+event);
            test(guard.lastQuarantineReason().length()>0,"quarantine reason");
        }
        guard.reset();
        for(int i=0;i<24;i++){
            ReexplorerAttackMonitor.Decision d=inspect(guard,
                    ReexplorerAttackMonitor.Event.SUBRESOURCE,
                    "http://tracker.example.net/"+i,false,1000+i);
            decision(d,i<23?ReexplorerAttackMonitor.Action.BLOCK:
                    ReexplorerAttackMonitor.Action.QUARANTINE,
                    "high-rate forbidden subresources");
        }
        guard.reset();
        for(int i=0;i<5;i++){
            ReexplorerAttackMonitor.Decision d=inspect(guard,
                    ReexplorerAttackMonitor.Event.PERMISSION,null,false,1000+i);
            decision(d,i<4?ReexplorerAttackMonitor.Action.BLOCK:
                    ReexplorerAttackMonitor.Action.QUARANTINE,
                    "repeated sensitive permission requests");
        }
        guard.reset();
        for(int i=0;i<=12;i++){
            ReexplorerAttackMonitor.Decision d=inspect(guard,
                    ReexplorerAttackMonitor.Event.PAGE_START,
                    "https://jump"+i+".example.org/",true,1000+i*100);
            decision(d,i<12?ReexplorerAttackMonitor.Action.ALLOW:
                    ReexplorerAttackMonitor.Action.QUARANTINE,
                    "rapid cross-host navigation threshold");
        }
        guard.reset();
        for(int i=0;i<=12;i++){
            ReexplorerAttackMonitor.Decision d=inspect(guard,
                    ReexplorerAttackMonitor.Event.PAGE_START,
                    "https://slow"+i+".example.org/",true,1000+i*5000);
            decision(d,ReexplorerAttackMonitor.Action.ALLOW,
                    "slow normal host transitions should not quarantine");
        }
        guard.reset();
        decision(inspect(guard,ReexplorerAttackMonitor.Event.SUBRESOURCE,
                "blob:https://example.org/abc",false,1000),
                ReexplorerAttackMonitor.Action.ALLOW,"blob internal resource not network");
        decision(inspect(guard,ReexplorerAttackMonitor.Event.SUBRESOURCE,
                "data:text/plain,hello",false,1000),
                ReexplorerAttackMonitor.Action.ALLOW,"inline data resource");
        decision(inspect(guard,ReexplorerAttackMonitor.Event.NAVIGATION,
                "data:text/html,hello",true,1100),
                ReexplorerAttackMonitor.Action.BLOCK,
                "mainframe data navigation denied");
        guard.reset();
        // Fuzzed URL/signal sequencing against strict observed hard vetoes.
        Random generator=new Random(42519L);
        String[] urls={"https://robinhood.com/","https://example.org/a",
                "http://example.org/","file:///data/local.secret",
                "https://10.0.0.2/","https://127.0.0.1/",
                "javascript:alert(1)","https://cdn.example.net/r"};
        for(int i=0;i<1024;i++){
            guard.reset();
            String url=urls[generator.nextInt(urls.length)];
            boolean main=generator.nextBoolean();
            ReexplorerAttackMonitor.Event e=main?
                    ReexplorerAttackMonitor.Event.NAVIGATION:
                    ReexplorerAttackMonitor.Event.SUBRESOURCE;
            ReexplorerAttackMonitor.Decision d=inspect(guard,e,url,main,2000+i);
            boolean allowed=ReexplorerPolicy.isSecureUrl(url);
            test(allowed?d.action==ReexplorerAttackMonitor.Action.ALLOW:
                    d.action==ReexplorerAttackMonitor.Action.BLOCK,
                    "fuzz security invariant "+i);
        }
        System.out.println("{\"suite\":\"REexplorer active interception\",\"checks\":"+
                checks+",\"scope\":\"WebView-observable events only; no packet-level egress\"}");
    }
}
