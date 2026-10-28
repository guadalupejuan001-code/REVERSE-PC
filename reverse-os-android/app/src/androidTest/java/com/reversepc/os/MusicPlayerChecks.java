package com.reversepc.os;

import android.app.Instrumentation;
import android.content.Context;
import android.view.View;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
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
        throw new AssertionError("Music fixture timed out: " + expression);
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
                    web.loadDataWithBaseURL("https://m.youtube.com/watch?v=abcdefghijk",
                        "<html><head><meta name='viewport' content='width=device-width'></head><body><div id='movie_player'><video></video></div><div id='player-ads'>Ad</div>"
                        + "<script>window.clock={time:12,duration:120,paused:true};const v=document.querySelector('video');"
                        + "Object.defineProperties(v,{currentTime:{get:()=>clock.time,set:t=>clock.time=t},duration:{get:()=>clock.duration},paused:{get:()=>clock.paused}});"
                        + "v.play=async()=>{clock.paused=false};v.pause=()=>{clock.paused=true};</script></body></html>", "text/html", "UTF-8", null);
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
            runner.runOnMainSync(() -> player.get().destroy());
            check(web.getParent() == null, "Closed player still owns a desktop view");
            return 14;
        } finally {
            runner.runOnMainSync(() -> { if (player.get() != null) player.get().destroy(); });
            activity.getSharedPreferences("reverse-music", Context.MODE_PRIVATE).edit().putBoolean("shield", previousShield).commit();
        }
    }
    private static JSONObject bounds(int viewport, boolean visible) {
        try { return new JSONObject().put("viewport", viewport).put("x", 20).put("y", 30).put("w", 240).put("h", 100).put("visible", visible); }
        catch (Exception error) { throw new RuntimeException(error); }
    }
    private static WebResourceRequest request(String url) {
        return new WebResourceRequest() {
            public android.net.Uri getUrl() { return android.net.Uri.parse(url); }
            public boolean isForMainFrame() { return false; }
            public boolean isRedirect() { return false; }
            public boolean hasGesture() { return false; }
            public String getMethod() { return "GET"; }
            public Map<String,String> getRequestHeaders() { return Collections.emptyMap(); }
        };
    }
}
