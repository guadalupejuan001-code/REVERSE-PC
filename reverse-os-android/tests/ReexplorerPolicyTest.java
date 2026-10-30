package com.reversepc.os;

import java.util.Arrays;

/** Host-independent URL security tests. Run with javac/java, no Android stubs. */
public final class ReexplorerPolicyTest {
    private static int checks=0;
    private static void accept(String url){
        String normalized=ReexplorerPolicy.normalize(url);
        if(!ReexplorerPolicy.isSecureUrl(normalized))
            throw new AssertionError("Should accept "+url);
        checks++;
    }
    private static void deny(String url){
        try{ReexplorerPolicy.normalize(url);throw new AssertionError("Should reject "+url);}
        catch(IllegalArgumentException expected){checks++;}
    }
    private static void agent(String url,boolean expected){
        if(ReexplorerPolicy.isAgentAllowed(url)!=expected)
            throw new AssertionError("Agent URL scope mismatch: "+url);
        checks++;
    }
    public static void main(String[] args){
        for(String url:Arrays.asList(
            "robinhood.com","https://robinhood.com/","https://www.robinhood.com/",
            "https://example.org/path?q=value#section","example.net/a/b","https://openai.com",
            "https://sub.example.com:443/page","https://xn--bcher-kva.de/"))
            accept(url);
        for(String url:Arrays.asList(
            null,"","x","http://robinhood.com/","ftp://example.com/",
            "https://127.0.0.1/","https://192.168.1.5/","https://10.20.0.1/",
            "https://[::1]/","https://localhost/","https://a.local/",
            "https://private.lan/","https://www.reverse.local/",
            "https://internal.test/","https://site.internal/","https://site.onion/",
            "https://robinhood.com@evil.com/","https://name:password@robinhood.com/",
            "https://robinhood.com:8080/","https://robinhood.com\\@evil.com/",
            "https://robinhood.com/ bad","javascript:alert(1)",
            "file:///sdcard/private","content://contacts/people",
            "https://-invalid.example.com","https://a..example.com",
            "https://example.com.","https://0000000000001/"))
            deny(url);
        agent("https://example.org/",false);
        agent("example.org",false);
        agent("https://ROBINHOOD.com/",false);
        agent("https://www.example.org/",false);
        agent("https://example.org/trade",false);
        agent("https://example.org/?auto=true",false);
        agent("https://example.org/#login",false);
        agent("https://example.org.evil.com/",false);
        agent("http://example.org/",false);
        System.out.println("{\"suite\":\"REexplorerPolicy\",\"checks\":"+checks+
                ",\"agent_navigation_disabled\":true,\"method\":\"pure JVM\"}");
    }
}
