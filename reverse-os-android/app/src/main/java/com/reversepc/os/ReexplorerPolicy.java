package com.reversepc.os;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.Locale;

/**
 * REexplorer navigation boundary. No DNS lookups and no claims of verifying a
 * site's identity: validate the URL before handing it to the Android WebView.
 * A hostname allowlist is intentionally NOT required for manual HTTPS browsing.
 * Manual launch is independent of BBY Q. Legacy agent helpers are unused.
 */
final class ReexplorerPolicy {
    static final String HOME="https://example.org/";
    private ReexplorerPolicy(){}

    static String normalize(String raw) {
        if(raw==null)throw new IllegalArgumentException("Dirección vacía");
        String value=raw.trim();
        if(value.length()<4||value.length()>2048)throw new IllegalArgumentException("Dirección fuera del límite");
        for(int i=0;i<value.length();i++) {
            char ch=value.charAt(i);
            if(Character.isISOControl(ch)||Character.isWhitespace(ch)||ch=='\\')
                throw new IllegalArgumentException("Dirección con caracteres no permitidos");
        }
        if(!value.contains("://")&&!value.startsWith("about:"))
            value="https://"+value;
        URI uri;
        try{uri=new URI(value);}catch(URISyntaxException invalid){
            throw new IllegalArgumentException("Dirección web no válida",invalid);
        }
        if(!"https".equalsIgnoreCase(uri.getScheme())||uri.isOpaque()||
                uri.getRawUserInfo()!=null||uri.getRawAuthority()==null||
                (uri.getPort()!=-1&&uri.getPort()!=443)||
                uri.getHost()==null)
            throw new IllegalArgumentException("REexplorer solo acepta sitios HTTPS públicos");
        String host=uri.getHost().toLowerCase(Locale.ROOT);
        if(!safeHost(host))throw new IllegalArgumentException("Destino local o reservado bloqueado");
        return value;
    }

    static boolean isSecureUrl(String url){
        if(url==null||!url.regionMatches(true,0,"https://",0,8))return false;
        try{normalize(url);return true;}
        catch(IllegalArgumentException invalid){return false;}
    }

    static boolean safeHost(String host){
        if(host==null||host.length()>253||host.indexOf('.')<=0||host.endsWith(".")||
                !host.matches("[a-z0-9.-]+"))return false;
        for(String label:host.split("\\.",-1))
            if(label.isEmpty()||label.length()>63||label.startsWith("-")||label.endsWith("-"))
                return false;
        for(String suffix:new String[]{".localhost",".local",".lan",".internal",".home",
                ".onion",".invalid",".test",".example",".arpa"})
            if(host.endsWith(suffix))return false;
        if(host.equals("localhost")||host.equals("reverse.local"))return false;
        // Hostnames containing an IP address or numeric-only TLDs must not
        // route to LAN, loopback, link-local, multicast or literal IP endpoints.
        if(host.matches("[0-9.]+")||host.matches(".*\\.[0-9]+"))return false;
        // All IPv6 literals are rejected by the hostname character check.
        return true;
    }

    static String host(String httpsUrl){
        String value=normalize(httpsUrl);
        return URI.create(value).getHost().toLowerCase(Locale.ROOT);
    }

    // Remote browsing is manual and isolated; agent navigation is disabled.
    static boolean isAgentAllowed(String url){return false;}
}
