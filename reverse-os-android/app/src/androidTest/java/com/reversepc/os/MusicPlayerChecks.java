package com.reversepc.os;

import android.app.Instrumentation;
import android.content.Context;
import android.view.View;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import android.widget.FrameLayout;
import java.util.Collections;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import org.json.JSONArray;
import org.json.JSONObject;

/** Actual Android WebView/lifecycle checks using an entirely offline YouTube-shaped fixture. */
final class MusicPlayerChecks {
    private static void check(boolean value, String message) { if (!value) throw new AssertionError(message); }
    private static String js(Instrumentation runner, WebView view, String script) throws Exception {
        CountDownLatch ready = new CountDownLatch(1); AtomicReference<String> result = new AtomicReference<>();
        runner.runOnMainSync(() -> view.evaluateJavascript(script, raw -> {result.set(raw); ready.countDown();}));
        check(ready.await(10, TimeUnit.SECONDS), "Music WebView callback timed out");
        return String.valueOf(new JSONArray("[" + result.get() + "]").get(0));
    }
    private static void waitFor(Instrumentation runner, WebView view, String expression) throws Exception {
        for (int n = 0; n < 60; n++) {
            if (js(runner, view, expression).equals("true")) return;
            Thread.sleep(100);
        }
        throw new AssertionError("Music fixture timed out: " + expression + " document="
            + js(runner, view, "JSON.stringify({url:location.href,ready:document.readyState,body:document.body?.innerHTML.slice(0,600)})"));
    }
    static int run(Instrumentation runner, WorkbenchActivity activity) throws Exception {
        AtomicReference<MusicPlayer> player = new AtomicReference<>();
        AtomicReference<WebView> remote = new AtomicReference<>();
        AtomicReference<JSONObject> status = new AtomicReference<>();
        AtomicReference<Throwable> setupError = new AtomicReference<>();
        WebView desktop = activity.testingWebView();
        FrameLayout root = (FrameLayout) desktop.getParent();
        boolean previousShield = activity.getSharedPreferences("reverse-music", Context.MODE_PRIVATE).getBoolean("shield", true);
        try {
            runner.runOnMainSync(() -> {
                try {
                    MusicPlayer p = new MusicPlayer(activity, root, desktop, status::set); player.set(p);
                    // Create the production view without issuing any network navigation.
                    java.lang.reflect.Method create = MusicPlayer.class.getDeclaredMethod("createView");
                    create.setAccessible(true); create.invoke(p);
                    java.lang.reflect.Field field = MusicPlayer.class.getDeclaredField("remote"); field.setAccessible(true);
                    WebView web = (WebView) field.get(p); remote.set(web); web.getSettings().setBlockNetworkLoads(true);
                    p.command("shield", new JSONObject().put("enabled", true));
                    final String html = "<html><head><meta name='viewport' content='width=device-width'></head><body><div id='movie_player'><video></video></div><div id='player-ads'>Ad</div>"
                        + "<script>window.clock={time:12,duration:120,paused:true};const v=document.querySelector('video');"
                        + "Object.defineProperties(v,{currentTime:{get:()=>clock.time,set:t=>clock.time=t},duration:{get:()=>clock.duration},paused:{get:()=>clock.paused}});"
                        + "v.play=async()=>{clock.paused=false};v.pause=()=>{clock.paused=true};</script></body></html>";
                    final WebViewClient production = web.getWebViewClient();
                    // Exercise the normal HTTPS navigation/injection path; no synthetic data URL.
                    web.setWebViewClient(new WebViewClient() {
                        @Override public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
                            WebResourceResponse filtered = production.shouldInterceptRequest(view, request);
                            if (filtered != null) return filtered;
                            if (request.isForMainFrame() && request.getUrl().toString().equals("https://m.youtube.com/watch?v=abcdefghijk"))
                                return new WebResourceResponse("text/html", "UTF-8", new ByteArrayInputStream(html.getBytes(StandardCharsets.UTF_8)));
                            return new WebResourceResponse("text/plain", "UTF-8", new ByteArrayInputStream(new byte[0]));
                        }
                        @Override public void onPageStarted(WebView view, String url, android.graphics.Bitmap icon) { production.onPageStarted(view, url, icon); }
                        @Override public void onPageCommitVisible(WebView view, String url) { production.onPageCommitVisible(view, url); }
                        @Override public void onPageFinished(WebView view, String url) { production.onPageFinished(view, url); }
                        @Override public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) { return production.shouldOverrideUrlLoading(view, request); }
                        @Override public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse response) { production.onReceivedHttpError(view,request,response); }
                    });
                    p.command("open", new JSONObject().put("input", "https://m.youtube.com/watch?v=abcdefghijk"));
                } catch (Throwable failure) { setupError.set(failure); }
            });
            if (setupError.get() != null) throw new AssertionError("Music setup failed", setupError.get());
            WebView web = remote.get();
            waitFor(runner, web, "!!window.__reverseMusic");
            check(js(runner, web, "typeof ReverseNative").equals("undefined"), "Remote view has the desktop bridge");
            boolean[] secure = {false}; runner.runOnMainSync(() -> secure[0] = !web.getSettings().getAllowFileAccess()
                && !web.getSettings().getAllowContentAccess() && !web.getSettings().getAllowUniversalAccessFromFileURLs());
            check(secure[0], "Remote view can access local files");
            check(js(runner, web, "clock.time===12&&!document.querySelector('video').muted").equals("true"), "Shield changed a song");
            js(runner, web, "document.getElementById('movie_player').classList.add('ad-showing');true");
            waitFor(runner, web, "clock.time===120&&document.querySelector('video').muted");
            js(runner, web, "document.getElementById('movie_player').classList.remove('ad-showing');clock.time=0;true");
            waitFor(runner, web, "clock.time===0&&!document.querySelector('video').muted");
            AtomicReference<WebResourceResponse> blocked = new AtomicReference<>();
            runner.runOnMainSync(() -> {
                blocked.set(web.getWebViewClient().shouldInterceptRequest(web, request("https://googleads.g.doubleclick.net/pagead/id")));
                try { player.get().command("status", new JSONObject()); } catch (Exception failure) { throw new RuntimeException(failure); }
            });
            check(blocked.get() != null && blocked.get().getStatusCode() == 204, "Network ad was not blocked");
            check(status.get().getInt("blocked") == 1, "Blocked counter is not a request count");
            int[] layout = new int[3];
            runner.runOnMainSync(() -> {
                player.get().layout(bounds(desktop.getWidth(), true));
                FrameLayout.LayoutParams p = (FrameLayout.LayoutParams) web.getLayoutParams();
                layout[0] = p.leftMargin; layout[1] = p.topMargin; layout[2] = p.width;
            });
            check(layout[0] == 20 && layout[1] == 30 && layout[2] == 240, "Native bounds do not match the desktop");
            runner.runOnMainSync(() -> player.get().layout(bounds(desktop.getWidth(), false)));
            check(web.getVisibility() == View.INVISIBLE, "Background player covers another app");
            check(js(runner, web, "!!window.__reverseMusic").equals("true"), "Hiding discarded the session");
            js(runner, web, "window.__reverseMusic.command('play');true");
            waitFor(runner, web, "!clock.paused");
            runner.runOnMainSync(() -> player.get().pause());
            waitFor(runner, web, "clock.paused");
            runner.runOnMainSync(() -> player.get().resume());
            check(js(runner, web, "clock.paused").equals("true"), "Resuming unexpectedly started playback");
            runner.runOnMainSync(() -> {
                try { player.get().command("shield", new JSONObject().put("enabled", false)); }
                catch (Exception failure) { throw new RuntimeException(failure); }
            });
            waitFor(runner, web, "!document.getElementById('reverse-music-filter')");
            runner.runOnMainSync(() -> player.get().audioFocusChanged(android.media.AudioManager.AUDIOFOCUS_LOSS));
            waitFor(runner, web, "clock.paused&&window.__reverseMusic.snapshot().held");
            js(runner, web, "clock.paused=false;document.querySelector('video').dispatchEvent(new Event('play'));true");
            check(js(runner, web, "clock.paused").equals("true"), "Automatic playback escaped an audio interruption");
            // Decode a real local PCM/WAV stream through HTMLMediaElement and Android audio.
            String wav=android.util.Base64.encodeToString(tone(),android.util.Base64.NO_WRAP);
            js(runner, web, "(()=>{const bytes=Uint8Array.from(atob("+JSONObject.quote(wav)+"),c=>c.charCodeAt(0));"
                +"document.getElementById('movie_player').innerHTML='<video id=real preload=auto></video>';"
                +"document.getElementById('real').src=URL.createObjectURL(new Blob([bytes],{type:'audio/wav'}));return true;})()");
            runner.runOnMainSync(() -> player.get().layout(bounds(desktop.getWidth(), true)));
            waitFor(runner, web, "document.getElementById('real').readyState>=2&&document.getElementById('real').duration>10");
            control(runner,player.get(),"play");
            waitFor(runner, web, "!document.getElementById('real').paused&&document.getElementById('real').currentTime>.15");
            control(runner,player.get(),"pause");
            waitFor(runner, web, "document.getElementById('real').paused");
            double stopped=Double.parseDouble(js(runner,web,"document.getElementById('real').currentTime"));
            Thread.sleep(400);
            check(Math.abs(Double.parseDouble(js(runner,web,"document.getElementById('real').currentTime"))-stopped)<.1,"Paused PCM audio kept advancing");
            control(runner,player.get(),"play");
            waitFor(runner, web, "!document.getElementById('real').paused");
            runner.runOnMainSync(() -> player.get().audioFocusChanged(android.media.AudioManager.AUDIOFOCUS_LOSS_TRANSIENT));
            waitFor(runner, web, "document.getElementById('real').paused&&window.__reverseMusic.snapshot().held");
            // Resuming the Activity must retain that pause even with a real media decoder.
            runner.runOnMainSync(() -> {player.get().pause();player.get().resume();});
            check(js(runner,web,"document.getElementById('real').paused").equals("true"),"Activity resume restarted PCM audio");
            control(runner,player.get(),"play");
            waitFor(runner, web, "!document.getElementById('real').paused");
            runner.runOnMainSync(() -> {
                try {
                    player.get().command("open",new JSONObject().put("input","https://m.youtube.com/watch?v=abcdefghijk"));
                    JSONObject loading=status.get();
                    check(loading.getString("phase").equals("loading")&&!loading.getBoolean("hasMedia")&&loading.getString("title").isEmpty(),"Navigation published the previous track");
                }catch(Exception failure){throw new RuntimeException(failure);}
            });
            waitFor(runner,web,"!document.getElementById('real')&&!!window.__reverseMusic");
            runner.runOnMainSync(() -> web.getWebViewClient().onReceivedHttpError(web,request("https://m.youtube.com/watch?v=abcdefghijk",true),
                new WebResourceResponse("text/html","UTF-8",503,"Unavailable",Collections.emptyMap(),new ByteArrayInputStream(new byte[0]))));
            check(status.get().getString("phase").equals("error")&&!status.get().getBoolean("hasMedia")&&status.get().getString("title").isEmpty(),"HTTP failure retained playback controls or stale metadata");
            control(runner,player.get(),"reload");
            for(int n=0;n<80&&!status.get().optString("phase").equals("ready");n++)Thread.sleep(100);
            check(status.get().getString("phase").equals("ready"),"Reload did not recover from an HTTP failure");
            runner.runOnMainSync(() -> player.get().destroy());
            check(web.getParent() == null, "Closed player still owns a desktop view");
            return 25;
        } finally {
            runner.runOnMainSync(() -> { if (player.get() != null) player.get().destroy(); });
            activity.getSharedPreferences("reverse-music", Context.MODE_PRIVATE).edit().putBoolean("shield", previousShield).commit();
        }
    }
    private static void control(Instrumentation runner, MusicPlayer player, String action) {
        runner.runOnMainSync(() -> {try {player.command(action,new JSONObject());} catch(Exception error){throw new RuntimeException(error);}});
    }
    private static byte[] tone() {
        int samples=8000*12,bytes=samples*2;
        java.nio.ByteBuffer wav=java.nio.ByteBuffer.allocate(44+bytes).order(java.nio.ByteOrder.LITTLE_ENDIAN);
        wav.put("RIFF".getBytes(StandardCharsets.US_ASCII)).putInt(36+bytes).put("WAVEfmt ".getBytes(StandardCharsets.US_ASCII));
        wav.putInt(16).putShort((short)1).putShort((short)1).putInt(8000).putInt(16000).putShort((short)2).putShort((short)16);
        wav.put("data".getBytes(StandardCharsets.US_ASCII)).putInt(bytes);
        for(int i=0;i<samples;i++)wav.putShort((short)(900*Math.sin(2*Math.PI*440*i/8000)));
        return wav.array();
    }
    private static JSONObject bounds(int viewport, boolean visible) {
        try { return new JSONObject().put("viewport", viewport).put("x", 20).put("y", 30).put("w", 240).put("h", 100).put("visible", visible); }
        catch (Exception error) { throw new RuntimeException(error); }
    }
    private static WebResourceRequest request(String url) { return request(url,false); }
    private static WebResourceRequest request(String url, boolean mainFrame) {
        return new WebResourceRequest() {
            public android.net.Uri getUrl() { return android.net.Uri.parse(url); }
            public boolean isForMainFrame() { return mainFrame; }
            public boolean isRedirect() { return false; }
            public boolean hasGesture() { return false; }
            public String getMethod() { return "GET"; }
            public Map<String,String> getRequestHeaders() { return Collections.emptyMap(); }
        };
    }
}
