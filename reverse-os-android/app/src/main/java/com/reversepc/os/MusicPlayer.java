package com.reversepc.os;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.media.MediaMetadata;
import android.media.session.MediaSession;
import android.media.session.PlaybackState;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.PermissionRequest;
import android.webkit.RenderProcessGoneDetail;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.concurrent.atomic.AtomicInteger;
import org.json.JSONObject;
import org.json.JSONTokener;

/** Network player overlaid inside a desktop window. The remote view has NO native bridge. */
final class MusicPlayer {
    interface Listener { void state(JSONObject state); }
    private final Activity activity;
    private final FrameLayout root;
    private final WebView desktop;
    private final Listener listener;
    private final Handler ui = new Handler(Looper.getMainLooper());
    private final SharedPreferences prefs;
    private final AtomicInteger blocked = new AtomicInteger();
    private final AudioManager audio;
    private final AudioFocusRequest focus;
    private final MediaSession session;
    private volatile boolean shield;
    private boolean focused, suspended, disposed, polling, receiverRegistered, recovering;
    private WebView remote;
    private String injection, error = "", notice = "", phase = "idle";
    private int pollGeneration, documentEpoch;
    private Runnable pollTimeout;
    private JSONObject bounds = new JSONObject(), snapshot = new JSONObject();
    private final Runnable poll = this::poll;
    private final BroadcastReceiver noisy = new BroadcastReceiver() {
        @Override public void onReceive(Context context, Intent intent) { interrupt("Auriculares desconectados. Pulsa Reproducir para continuar."); }
    };

    MusicPlayer(Activity activity, FrameLayout root, WebView desktop, Listener listener) {
        this.activity = activity; this.root = root; this.desktop = desktop; this.listener = listener;
        prefs = activity.getSharedPreferences("reverse-music", Context.MODE_PRIVATE);
        shield = prefs.getBoolean("shield", true);
        audio = (AudioManager) activity.getSystemService(Context.AUDIO_SERVICE);
        focus = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .setAudioAttributes(new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build())
            .setWillPauseWhenDucked(true).setOnAudioFocusChangeListener(this::audioFocusChanged, ui).build();
        session = new MediaSession(activity, "REVERSE Music");
        session.setCallback(new MediaSession.Callback() {
            @Override public void onPlay() { playback("play", 0); }
            @Override public void onPause() { playback("pause", 0); }
            @Override public void onStop() { playback("pause", 0); }
            @Override public void onSkipToNext() { playback("next", 0); }
            @Override public void onSkipToPrevious() { playback("previous", 0); }
            @Override public void onSeekTo(long pos) { playback("seek", pos / 1000.0); }
        }, ui);
        IntentFilter filter = new IntentFilter(AudioManager.ACTION_AUDIO_BECOMING_NOISY);
        if (Build.VERSION.SDK_INT >= 33) activity.registerReceiver(noisy, filter, Context.RECEIVER_NOT_EXPORTED);
        else activity.registerReceiver(noisy, filter);
        receiverRegistered = true;
    }
    private void createView() throws Exception {
        if (remote != null) return;
        if (injection == null) try (InputStream input = activity.getAssets().open("music/youtube.js")) {
            java.io.ByteArrayOutputStream buffer = new java.io.ByteArrayOutputStream();
            byte[] part = new byte[4096]; int count;
            while ((count = input.read(part)) != -1) buffer.write(part, 0, count);
            injection = new String(buffer.toByteArray(), StandardCharsets.UTF_8);
        }
        recovering = false;
        remote = new WebView(activity);
        WebSettings settings = remote.getSettings();
        settings.setJavaScriptEnabled(true); settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(false); settings.setAllowContentAccess(false);
        settings.setAllowFileAccessFromFileURLs(false); settings.setAllowUniversalAccessFromFileURLs(false);
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
        settings.setSupportMultipleWindows(false); settings.setJavaScriptCanOpenWindowsAutomatically(false);
        settings.setMediaPlaybackRequiresUserGesture(true);
        settings.setGeolocationEnabled(false); settings.setSafeBrowsingEnabled(true);
        CookieManager.getInstance().setAcceptThirdPartyCookies(remote, false);
        remote.setBackgroundColor(0xff101214);
        remote.setWebChromeClient(new WebChromeClient() {
            @Override public void onPermissionRequest(PermissionRequest request) { request.deny(); }
        });
        remote.setWebViewClient(new WebViewClient() {
            @Override public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                if (!request.isForMainFrame()) return !"https".equals(request.getUrl().getScheme());
                if (MusicPolicy.pageAllowed(request.getUrl().toString())) return false;
                notice = "Este enlace sale de YouTube. Usa una búsqueda o un enlace de música.";
                publish(); return true;
            }
            @Override public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
                Uri uri = request.getUrl();
                if (!"https".equals(uri.getScheme()) || "reverse.local".equals(uri.getHost())
                    || (request.isForMainFrame() && !MusicPolicy.pageAllowed(uri.toString()))) return denied();
                if (shield && MusicPolicy.isAdRequest(uri.toString())) {
                    blocked.incrementAndGet(); return denied();
                }
                return null;
            }
            @Override public void onPageStarted(WebView view, String url, android.graphics.Bitmap icon) {
                if (disposed || view != remote) return;
                documentEpoch++; stopPolling(); view.getSettings().setMediaPlaybackRequiresUserGesture(true); phase = "loading"; error = ""; notice = "";
                snapshot = new JSONObject(); releaseFocus(); updateSession(); publish();
            }
            @Override public void onPageCommitVisible(WebView view, String url) { inject(view); }
            @Override public void onPageFinished(WebView view, String url) { inject(view); startPolling(); }
            @Override public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError failure) {
                if (request.isForMainFrame() && view == remote) fail("No se pudo cargar YouTube. Comprueba la conexión y pulsa Recargar.");
            }
            @Override public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse response) {
                if (request.isForMainFrame() && view == remote)
                    fail("YouTube respondió con error " + response.getStatusCode() + ". Pulsa Recargar para reintentar.");
            }
            @Override public boolean onRenderProcessGone(WebView view, RenderProcessGoneDetail detail) {
                root.removeView(view); view.destroy();
                if (remote == view) remote = null;
                recovering = true;
                fail("El reproductor se cerró. Pulsa Abrir YouTube para recuperarlo.");
                return true;
            }
        });
        remote.setDownloadListener((url, agent, disposition, mime, size) -> {
            notice = "Este reproductor reproduce en línea; no descarga archivos."; publish();
        });
        root.addView(remote, new FrameLayout.LayoutParams(1, 1));
        layout(bounds);
    }
    private static WebResourceResponse denied() {
        return new WebResourceResponse("text/plain", "UTF-8", 204, "No Content",
            Collections.emptyMap(), new ByteArrayInputStream(new byte[0]));
    }
    private void inject(WebView view) {
        if (disposed || view != remote || phase.equals("error") || !MusicPolicy.pageAllowed(view.getUrl())) return;
        final int epoch = documentEpoch;
        String script = "(()=>{try{" + injection + "\nwindow.__reverseMusic.setShield(" + shield + ");"
            + (suspended ? "window.__reverseMusic.command('hostPause');" : "") + "return true;}catch(e){return false;}})()";
        view.evaluateJavascript(script, result -> {
            if (disposed || view != remote || epoch != documentEpoch || phase.equals("error")) return;
            if (!"true".equals(result)) { fail("No se pudo iniciar el reproductor. Pulsa Recargar."); return; }
            phase = "ready"; publish(); startPolling();
        });
    }
    void command(String action, JSONObject data) throws Exception {
        if (disposed) return;
        if (action.equals("bounds")) { layout(data); return; }
        if (action.equals("status")) { publish(); return; }
        if (action.equals("shield")) {
            shield = data.getBoolean("enabled"); prefs.edit().putBoolean("shield", shield).apply();
            if (remote != null) remote.evaluateJavascript("window.__reverseMusic&&window.__reverseMusic.setShield(" + shield + ")", null);
            publish(); return;
        }
        if (action.equals("open")) {
            String url = MusicPolicy.resolve(data.optString("input", ""));
            createView(); phase = "loading"; error = ""; notice = ""; snapshot = new JSONObject();
            releaseFocus(); updateSession(); remote.loadUrl(url); publish(); return;
        }
        if (action.equals("reload")) { if (remote != null) { phase = "loading"; error = ""; notice = ""; remote.reload(); } return; }
        if (action.equals("back")) { if (remote != null && remote.canGoBack()) remote.goBack(); return; }
        if (!action.matches("play|pause|toggle|next|previous|seek"))
            throw new IllegalArgumentException("Control de música no permitido.");
        playback(action, data.optDouble("time", 0));
    }
    void layout(JSONObject data) {
        bounds = data;
        if (remote == null) return;
        double viewport = data.optDouble("viewport", 0);
        double x = data.optDouble("x", 0), y = data.optDouble("y", 0);
        double w = data.optDouble("w", 0), h = data.optDouble("h", 0);
        boolean visible = !suspended && data.optBoolean("visible") && viewport > 0
            && Double.isFinite(x + y + w + h + viewport) && w >= 1 && h >= 1 && x >= 0 && y >= 0;
        double scale = viewport > 0 ? desktop.getWidth() / viewport : 0;
        visible &= scale > 0 && (x + w) * scale <= desktop.getWidth() + 2 && (y + h) * scale <= desktop.getHeight() + 2;
        if (visible) {
            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                Math.max(1, (int)Math.round(w * scale)), Math.max(1, (int)Math.round(h * scale)));
            // FrameLayout adds root padding; the desktop occupies that same content origin.
            params.leftMargin = (int)Math.round(x * scale); params.topMargin = (int)Math.round(y * scale);
            remote.setLayoutParams(params);
        }
        remote.setVisibility(visible ? View.VISIBLE : View.INVISIBLE);
    }
    private void send(String action, double value) {
        if (remote == null || disposed) return;
        final WebView source = remote; final int epoch = documentEpoch;
        source.evaluateJavascript("window.__reverseMusic?window.__reverseMusic.command(" + JSONObject.quote(action) + "," + value + "):false", raw -> {
            if (disposed || source != remote || epoch != documentEpoch) return;
            if ("false".equals(raw) && !action.matches("hold|pause|hostPause|hostResume")) {
                notice = "Este control no está disponible en la pista o lista actual."; publish();
            }
        });
    }
    private void playback(String action, double value) {
        if (remote == null || suspended || disposed || phase.equals("error") || !Double.isFinite(value)) return;
        if (action.equals("pause")) { interrupt(""); return; }
        if (action.equals("play") || action.equals("toggle")) {
            if (!focused) focused = audio.requestAudioFocus(focus) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED;
            if (!focused) { interrupt("Otra aplicación tiene el audio. Intenta reproducir de nuevo."); return; }
            remote.getSettings().setMediaPlaybackRequiresUserGesture(false);
        }
        notice = ""; send(action, value);
    }
    void audioFocusChanged(int change) {
        if (!disposed && change < 0) interrupt("Audio interrumpido por otra aplicación. Pulsa Reproducir para continuar.");
    }
    private void interrupt(String message) {
        if (disposed) return;
        // Cancel callbacks sampled before the interruption; they must not reacquire focus.
        stopPolling(); send("hold", 0); releaseFocus(); notice = message;
        try { snapshot.put("paused", true).put("held", true); } catch (Exception ignored) {}
        updateSession(); publish(); startPolling();
    }
    private void releaseFocus() {
        if (focused) audio.abandonAudioFocusRequest(focus);
        focused = false;
    }
    private static double number(JSONObject value, String key) {
        Object raw = value.opt(key);
        double n = raw instanceof Number ? ((Number)raw).doubleValue() : 0;
        return Double.isFinite(n) ? Math.max(0, Math.min(31536000, n)) : 0;
    }
    private static String text(JSONObject value, String key, int limit) {
        Object raw = value.opt(key); String result = raw instanceof String ? (String)raw : "";
        return result.substring(0, Math.min(limit, result.length()));
    }
    private static JSONObject cleanSnapshot(JSONObject value) throws Exception {
        JSONObject result = new JSONObject();
        String url = text(value, "url", 4096);
        result.put("url", MusicPolicy.pageAllowed(url) ? url : "").put("title", text(value, "title", 240));
        for (String key : new String[]{"hasMedia","ad","held","canNext","canPrevious","canSeek","live"})
            result.put(key, Boolean.TRUE.equals(value.opt(key)));
        result.put("paused", !Boolean.FALSE.equals(value.opt("paused")));
        return result.put("time", number(value,"time")).put("duration",number(value,"duration"))
            .put("mediaError",text(value,"mediaError",240));
    }
    private void updateSession() {
        if (disposed) return;
        boolean hasMedia = snapshot.optBoolean("hasMedia") && phase.equals("ready");
        boolean playing = hasMedia && !snapshot.optBoolean("paused",true) && focused && !suspended;
        long duration = (long)(snapshot.optDouble("duration",0)*1000);
        session.setMetadata(new MediaMetadata.Builder().putString(MediaMetadata.METADATA_KEY_TITLE,
            snapshot.optString("title","YouTube")).putLong(MediaMetadata.METADATA_KEY_DURATION,duration).build());
        long actions = PlaybackState.ACTION_PLAY | PlaybackState.ACTION_PAUSE | PlaybackState.ACTION_PLAY_PAUSE;
        if (snapshot.optBoolean("canNext")) actions |= PlaybackState.ACTION_SKIP_TO_NEXT;
        if (snapshot.optBoolean("canPrevious")) actions |= PlaybackState.ACTION_SKIP_TO_PREVIOUS;
        if (snapshot.optBoolean("canSeek")) actions |= PlaybackState.ACTION_SEEK_TO;
        session.setPlaybackState(new PlaybackState.Builder().setActions(actions)
            .setState(playing ? PlaybackState.STATE_PLAYING : PlaybackState.STATE_PAUSED,
                (long)(snapshot.optDouble("time",0)*1000),playing ? 1 : 0).build());
        // Paused foreground sessions must still receive the headset's Play action.
        session.setActive(hasMedia && !suspended);
    }
    private void stopPolling() {
        polling = false; pollGeneration++; ui.removeCallbacks(poll);
        if (pollTimeout != null) ui.removeCallbacks(pollTimeout);
        pollTimeout = null;
    }
    private void startPolling() {
        if (polling || suspended || disposed || remote == null || phase.equals("error")) return;
        polling = true; ui.post(poll);
    }
    private void poll() {
        if (!polling || disposed || suspended || remote == null) return;
        final WebView source = remote; final int generation = pollGeneration, epoch = documentEpoch;
        pollTimeout = () -> {
            if (!disposed && generation == pollGeneration) fail("El reproductor no responde. Pulsa Recargar para recuperarlo.");
        };
        ui.postDelayed(pollTimeout,8000);
        source.evaluateJavascript("JSON.stringify(window.__reverseMusic?window.__reverseMusic.snapshot():null)", raw -> {
            if (disposed || suspended || source != remote || generation != pollGeneration) return;
            ui.removeCallbacks(pollTimeout); pollTimeout = null;
            try {
                if (epoch == documentEpoch && raw != null && raw.length() <= 20000) {
                    Object decoded = new JSONTokener(raw).nextValue();
                    if (decoded instanceof String && !"null".equals(decoded)) snapshot = cleanSnapshot(new JSONObject((String)decoded));
                }
                boolean playing = snapshot.optBoolean("hasMedia") && !snapshot.optBoolean("paused",true);
                if (playing && snapshot.optBoolean("held")) { send("hold",0); playing = false; }
                if (playing && !focused) {
                    focused = audio.requestAudioFocus(focus) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED;
                    if (!focused) { interrupt("El audio está ocupado por otra aplicación."); return; }
                }
                if (!playing && focused) releaseFocus();
                updateSession(); publish();
            } catch (Exception ignored) { /* Navigation can transiently return null. */ }
            if (polling && generation == pollGeneration) ui.postDelayed(poll,1000);
        });
    }
    private void publish() {
        if (disposed) return;
        try {
            // Always publish every track field; partial objects kept stale songs in the UI.
            JSONObject state = cleanSnapshot(snapshot);
            state.put("available",true).put("loaded",remote!=null).put("phase",phase).put("shield",shield)
                .put("blocked",blocked.get()).put("error",error).put("notice",notice).put("recovering",recovering);
            listener.state(state);
        } catch (Exception ignored) {}
    }
    private void fail(String message) {
        stopPolling(); send("hold",0); releaseFocus(); snapshot = new JSONObject();
        error = message; phase = "error"; updateSession(); publish();
    }
    void reportError(String message) { notice = message; publish(); }
    void pause() {
        if (disposed) return;
        suspended = true; stopPolling(); send("hostPause",0); releaseFocus();
        try { snapshot.put("paused",true).put("held",true); } catch (Exception ignored) {}
        if (remote != null) { remote.onPause(); remote.setVisibility(View.INVISIBLE); }
        updateSession(); publish();
    }
    void resume() {
        if (disposed) return;
        suspended = false;
        if (remote != null) { remote.onResume(); send("hostResume",0); layout(bounds); startPolling(); }
        updateSession(); publish();
    }
    void destroy() {
        if (disposed) return;
        pause(); disposed = true; stopPolling();
        if (receiverRegistered) { activity.unregisterReceiver(noisy); receiverRegistered = false; }
        session.release();
        if (remote != null) { root.removeView(remote); remote.stopLoading(); remote.destroy(); remote = null; }
    }
}
