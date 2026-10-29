package com.reversepc.os;

import java.util.ArrayDeque;
import java.util.Objects;

/**
 * REexplorer active interception policy. Runs inside the unprivileged browser
 * activity; it never receives BBY Q memory, DOM, cookies or page text.
 *
 * This checks WebView-observable requests/events, not every socket or DNS
 * answer. Its decisions are bounded and fail closed for explicitly forbidden
 * navigation. No claim of complete network interception.
 */
final class ReexplorerAttackMonitor {
    enum Event {
        NAVIGATION, PAGE_START, SUBRESOURCE, TLS_FAILURE, SAFE_BROWSING,
        PERMISSION, DOWNLOAD, FILE_PICKER, POPUP, HTTP_AUTH, RENDERER_FAILURE
    }
    enum Action { ALLOW, BLOCK, QUARANTINE }

    static final class Decision {
        final Action action;
        final String reason;
        final int intercepted;
        final int risk;
        Decision(Action action,String reason,int intercepted,int risk){
            this.action=action;this.reason=reason;this.intercepted=intercepted;this.risk=risk;
        }
        boolean blocked(){return action!=Action.ALLOW;}
    }

    private static final long WINDOW=30_000L;
    private static final long REDIRECT_WINDOW=15_000L;
    private static final int MAINFRAME_LIMIT=3;
    private static final int RESOURCE_LIMIT=24;
    private static final int PERMISSION_LIMIT=5;
    private static final int HOP_LIMIT=12;

    private final ArrayDeque<Long> deniedNavigation=new ArrayDeque<>();
    private final ArrayDeque<Long> deniedResources=new ArrayDeque<>();
    private final ArrayDeque<Long> deniedCapabilities=new ArrayDeque<>();
    private final ArrayDeque<Long> originHops=new ArrayDeque<>();
    private String lastPageHost;
    private int intercepted;
    private boolean quarantined;
    private String quarantineReason="";
    private int risk;

    private static void prune(ArrayDeque<Long> events,long now,long window) {
        while(!events.isEmpty()&&(now-events.peekFirst()>window||now<events.peekFirst()))
            events.removeFirst();
    }
    private Decision outcome(Action action,String reason){
        return new Decision(action,reason,intercepted,risk);
    }
    private Decision quarantine(String reason){
        quarantined=true;quarantineReason=reason;risk=100;
        return outcome(Action.QUARANTINE,reason);
    }
    synchronized boolean isQuarantined(){return quarantined;}
    synchronized int interceptedCount(){return intercepted;}
    synchronized String lastQuarantineReason(){return quarantineReason;}

    /** Clock is monotonic milliseconds supplied by the caller, never site data. */
    synchronized Decision inspect(Event event,String url,boolean mainFrame,long now) {
        Objects.requireNonNull(event,"event");
        if(quarantined)return outcome(Action.QUARANTINE,quarantineReason);
        if(event==Event.TLS_FAILURE||event==Event.SAFE_BROWSING||
                event==Event.RENDERER_FAILURE){
            intercepted++;
            return quarantine(event==Event.TLS_FAILURE?"TLS_REJECTED":
                    event==Event.SAFE_BROWSING?"KNOWN_THREAT":"RENDERER_FAILURE");
        }
        if(event==Event.PERMISSION||event==Event.DOWNLOAD||event==Event.FILE_PICKER||
                event==Event.POPUP||event==Event.HTTP_AUTH) {
            intercepted++;
            deniedCapabilities.addLast(now);
            prune(deniedCapabilities,now,WINDOW);
            risk=Math.max(risk,30);
            if(deniedCapabilities.size()>=PERMISSION_LIMIT)
                return quarantine("REPEATED_CAPABILITY_REQUESTS");
            return outcome(Action.BLOCK,"SENSITIVE_CAPABILITY_DENIED");
        }
        // Non-network renderer resources are not exported or interpreted.
        // WebView may process these internally and will not call us for all.
        if(event==Event.SUBRESOURCE&&!mainFrame&&url!=null&&
                (url.startsWith("data:")||url.startsWith("blob:")||
                 url.equals("about:blank")))
            return outcome(Action.ALLOW,"INTERNAL_RENDERER_RESOURCE");
        if(url==null||!ReexplorerPolicy.isSecureUrl(url)){
            intercepted++;
            if(event==Event.SUBRESOURCE&&!mainFrame){
                deniedResources.addLast(now);
                prune(deniedResources,now,WINDOW);
                risk=Math.max(risk,20);
                if(deniedResources.size()>=RESOURCE_LIMIT)
                    return quarantine("RESOURCE_ABUSE");
            }else{
                deniedNavigation.addLast(now);
                prune(deniedNavigation,now,WINDOW);
                risk=Math.max(risk,50);
                if(deniedNavigation.size()>=MAINFRAME_LIMIT)
                    return quarantine("REPEATED_FORBIDDEN_NAVIGATION");
            }
            return outcome(Action.BLOCK,"UNSAFE_SCHEME_OR_DESTINATION");
        }
        if(event==Event.PAGE_START){
            String host=ReexplorerPolicy.host(url);
            if(lastPageHost!=null&&!host.equals(lastPageHost)){
                originHops.addLast(now);
                prune(originHops,now,REDIRECT_WINDOW);
                if(originHops.size()>=HOP_LIMIT){
                    intercepted++;
                    return quarantine("RAPID_CROSS_ORIGIN_NAVIGATION");
                }
            }
            lastPageHost=host;
        }
        return outcome(Action.ALLOW,"HTTPS_ALLOWED");
    }

    /** Only a confirmed local UI action may call this. No website API exists. */
    synchronized void reset(){
        deniedNavigation.clear();deniedResources.clear();deniedCapabilities.clear();
        originHops.clear();lastPageHost=null;intercepted=0;
        quarantined=false;quarantineReason="";risk=0;
    }
}
