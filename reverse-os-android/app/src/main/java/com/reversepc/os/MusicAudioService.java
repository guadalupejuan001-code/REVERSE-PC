package com.reversepc.os;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ServiceInfo;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.media.MediaMetadata;
import android.media.MediaPlayer;
import android.media.session.MediaSession;
import android.media.session.PlaybackState;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.PowerManager;
import java.util.ArrayList;
import org.json.JSONObject;

/** Explicitly started local playback survives leaving the desktop to play a game. */
public final class MusicAudioService extends Service {
    private static final int NOTIFICATION = 7301;
    private static final String CHANNEL = "reverse-music-playback";
    private static volatile MusicAudioService active;
    private static volatile String latest = "{}";
    private static long generation;
    static JSONObject state() {
        try { return new JSONObject(latest); } catch (Exception ignored) { return new JSONObject(); }
    }
    static void select(Context context, String id, boolean repeat) {
        context.startForegroundService(new Intent(context, MusicAudioService.class).setAction("select")
            .putExtra("id", id).putExtra("repeat", repeat).putExtra("generation", ++generation));
    }
    static void control(String action, double value) { if (active != null) active.command(action, value); }
    static void stopPlayback() { generation++; if (active != null) active.command("stop", 0); }
    private final Handler ui = new Handler(Looper.getMainLooper());
    private final AudioAttributes attributes = new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA)
        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build();
    private MediaPlayer player;
    private MediaSession session;
    private AudioManager audio;
    private AudioFocusRequest focus;
    private boolean prepared, playWhenReady, repeatOne, foreground, hasFocus;
    private String id = "", title = "", phase = "idle", error = "";
    private final Runnable idleStop = this::stopSelf;
    private final Runnable tick = new Runnable() { public void run() { capture(); ui.postDelayed(this, 500); } };
    private final BroadcastReceiver noisy = new BroadcastReceiver() {
        @Override public void onReceive(Context context, Intent intent) { command("pause", 0); }
    };
    @Override public void onCreate() {
        super.onCreate(); active = this;
        audio = (AudioManager)getSystemService(AUDIO_SERVICE);
        focus = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN).setAudioAttributes(attributes)
            .setOnAudioFocusChangeListener(change -> {
                if (change == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK) {
                    if (player != null && prepared) player.setVolume(.2f, .2f);
                } else if (change == AudioManager.AUDIOFOCUS_GAIN) {
                    if (player != null && prepared) player.setVolume(1, 1);
                    // A pause caused by another app always needs an explicit Play.
                } else if (change == AudioManager.AUDIOFOCUS_LOSS || change == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT) {
                    command("pause", 0);
                }
            }, ui).build();
        ((NotificationManager)getSystemService(NOTIFICATION_SERVICE)).createNotificationChannel(
            new NotificationChannel(CHANNEL, "Música sin conexión", NotificationManager.IMPORTANCE_LOW));
        session = new MediaSession(this, "REVERSE Music · Sin conexión");
        session.setCallback(new MediaSession.Callback() {
            @Override public void onPlay() { command("play", 0); }
            @Override public void onPause() { command("pause", 0); }
            @Override public void onStop() { command("stop", 0); }
            @Override public void onSkipToNext() { command("next", 0); }
            @Override public void onSkipToPrevious() { command("previous", 0); }
            @Override public void onSeekTo(long position) { command("seek", position / 1000.0); }
        }, ui);
        IntentFilter filter = new IntentFilter(AudioManager.ACTION_AUDIO_BECOMING_NOISY);
        if (Build.VERSION.SDK_INT >= 33) registerReceiver(noisy, filter, Context.RECEIVER_NOT_EXPORTED);
        else registerReceiver(noisy, filter);
        ui.post(tick);
    }
    @Override public int onStartCommand(Intent intent, int flags, int startId) {
        // Become a media foreground service before requesting focus on Android 15.
        enterForeground();
        if (intent == null) { stopSelf(); return START_NOT_STICKY; }
        if ("select".equals(intent.getAction())) {
            if (intent.getLongExtra("generation", -1) != generation) {
                if (id.isEmpty()) stopSelf(startId);
                return START_NOT_STICKY;
            }
            repeatOne = intent.getBooleanExtra("repeat", false); selectTrack(intent.getStringExtra("id"));
        } else command(intent.getAction(), 0);
        return START_NOT_STICKY;
    }
    @Override public IBinder onBind(Intent intent) { return null; }
    private boolean playing() { return prepared && player != null && player.isPlaying(); }
    private void selectTrack(String trackId) {
        try {
            MusicLibrary library = MusicLibrary.get(this); JSONObject item = library.ready(trackId);
            releasePlayer(); id = trackId; title = item.getString("title"); error = ""; phase = "loading"; playWhenReady = true;
            ui.removeCallbacks(idleStop);
            MediaPlayer source = new MediaPlayer(); player = source;
            source.setAudioAttributes(attributes); source.setWakeMode(this, PowerManager.PARTIAL_WAKE_LOCK);
            source.setDataSource(library.audio(trackId).getAbsolutePath()); source.setLooping(repeatOne);
            source.setOnPreparedListener(value -> {
                if (player != source) return;
                prepared = true; phase = "ready";
                if (playWhenReady) play(); else changed();
            });
            source.setOnCompletionListener(value -> {
                if (player != source) return;
                ArrayList<String> ids = library.readyIds(); int position = ids.indexOf(id);
                if (!repeatOne && position >= 0 && position + 1 < ids.size()) selectTrack(ids.get(position + 1));
                else { playWhenReady = false; abandonFocus(); changed(); }
            });
            source.setOnErrorListener((value, what, extra) -> {
                if (player == source) failed("No se pudo reproducir el archivo. Prueba con otro formato de audio.");
                return true;
            });
            source.prepareAsync(); changed();
        } catch (Exception failure) { failed("No se pudo abrir la canción: " + failure.getMessage()); }
    }
    private void play() {
        if (id.isEmpty()) return;
        playWhenReady = true; ui.removeCallbacks(idleStop);
        if (!prepared) { if (!phase.equals("loading")) selectTrack(id); return; }
        enterForeground();
        if (!hasFocus) hasFocus = audio.requestAudioFocus(focus) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED;
        if (!hasFocus) { playWhenReady = false; error = "Otra aplicación está usando el audio. Pulsa Reproducir para reintentar."; changed(); return; }
        error = "";
        if (player.getCurrentPosition() >= player.getDuration() - 50) player.seekTo(0);
        player.start(); changed();
    }
    private void command(String action, double value) {
        if (action == null) return;
        try {
            if (action.equals("stop")) { releasePlayer(); abandonFocus(); id = ""; title = ""; phase = "idle"; capture(); stopForeground(STOP_FOREGROUND_REMOVE); foreground = false; stopSelf(); return; }
            if (action.equals("repeat")) { repeatOne = value == 1; if (player != null) player.setLooping(repeatOne); changed(); return; }
            if (action.equals("play") || (action.equals("toggle") && !playing())) { play(); return; }
            if (action.equals("pause") || action.equals("toggle")) {
                playWhenReady = false; if (playing()) player.pause(); abandonFocus(); changed(); return;
            }
            if (action.equals("seek") && prepared && Double.isFinite(value)) {
                player.seekTo((int)Math.max(0, Math.min(player.getDuration(), value * 1000))); changed(); return;
            }
            if (action.equals("next") || action.equals("previous")) {
                ArrayList<String> ids = MusicLibrary.get(this).readyIds(); int index = ids.indexOf(id);
                if (ids.size() > 1 && index >= 0) selectTrack(ids.get((index + (action.equals("next") ? 1 : ids.size() - 1)) % ids.size()));
            }
        } catch (Exception failure) { failed("El control de audio falló. Vuelve a seleccionar la canción."); }
    }
    private void abandonFocus() { if (hasFocus) { audio.abandonAudioFocusRequest(focus); hasFocus = false; } }
    private void releasePlayer() {
        prepared = false; playWhenReady = false;
        if (player != null) { player.release(); player = null; }
    }
    private void failed(String message) { releasePlayer(); abandonFocus(); error = message; phase = "error"; changed(); }
    private void capture() {
        try {
            boolean playing = playing();
            int position = prepared ? player.getCurrentPosition() : 0, duration = prepared ? player.getDuration() : 0;
            boolean queue = MusicLibrary.get(this).readyIds().size() > 1;
            latest = new JSONObject().put("source", "local").put("localId", id).put("title", title)
                .put("loaded", prepared).put("hasMedia", prepared).put("phase", phase).put("paused", !playing)
                .put("time", position / 1000.0).put("duration", duration / 1000.0).put("error", error)
                .put("repeatOne", repeatOne)
                .put("canSeek", prepared).put("canNext", queue && prepared).put("canPrevious", queue && prepared)
                .put("live", false).put("ad", false).put("held", !playing).put("url", "").put("notice", "").put("mediaError", "").toString();
        } catch (Exception ignored) {}
    }
    private void changed() {
        capture(); boolean playing = playing(); JSONObject status = state();
        session.setActive(!id.isEmpty());
        session.setMetadata(new MediaMetadata.Builder().putString(MediaMetadata.METADATA_KEY_TITLE, title)
            .putString(MediaMetadata.METADATA_KEY_ARTIST, "REVERSE · Sin conexión")
            .putLong(MediaMetadata.METADATA_KEY_DURATION, (long)(status.optDouble("duration") * 1000)).build());
        long actions = PlaybackState.ACTION_PLAY | PlaybackState.ACTION_PAUSE | PlaybackState.ACTION_PLAY_PAUSE | PlaybackState.ACTION_STOP | PlaybackState.ACTION_SEEK_TO;
        if (status.optBoolean("canNext")) actions |= PlaybackState.ACTION_SKIP_TO_NEXT | PlaybackState.ACTION_SKIP_TO_PREVIOUS;
        session.setPlaybackState(new PlaybackState.Builder().setActions(actions).setState(phase.equals("loading") ? PlaybackState.STATE_BUFFERING : playing ? PlaybackState.STATE_PLAYING : PlaybackState.STATE_PAUSED,
            (long)(status.optDouble("time") * 1000), playing ? 1 : 0).build());
        if (foreground) ((NotificationManager)getSystemService(NOTIFICATION_SERVICE)).notify(NOTIFICATION, notification());
        ui.removeCallbacks(idleStop);
        if (!playing && !phase.equals("loading")) ui.postDelayed(idleStop, 5 * 60 * 1000);
    }
    private PendingIntent action(String action) {
        return PendingIntent.getService(this, action.hashCode(), new Intent(this, MusicAudioService.class).setAction(action), PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }
    private Notification notification() {
        boolean playing = playing();
        PendingIntent open = PendingIntent.getActivity(this, 7301, new Intent(this, WorkbenchActivity.class)
            .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP), PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        return new Notification.Builder(this, CHANNEL).setSmallIcon(getApplicationInfo().icon)
            .setContentTitle(title.isEmpty() ? "REVERSE Music" : title).setContentText("Música sin conexión · " + (playing ? "Reproduciendo" : "En pausa"))
            .setContentIntent(open).setOnlyAlertOnce(true).setVisibility(Notification.VISIBILITY_PUBLIC).setOngoing(playing)
            .addAction(new Notification.Action.Builder(playing ? android.R.drawable.ic_media_pause : android.R.drawable.ic_media_play,
                playing ? "Pausar" : "Reproducir", action(playing ? "pause" : "play")).build())
            .addAction(new Notification.Action.Builder(android.R.drawable.ic_menu_close_clear_cancel, "Detener", action("stop")).build())
            .setDeleteIntent(action("stop")).setStyle(new Notification.MediaStyle().setMediaSession(session.getSessionToken()).setShowActionsInCompactView(0, 1)).build();
    }
    private void enterForeground() {
        startForeground(NOTIFICATION, notification(), ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK); foreground = true;
    }
    @Override public void onDestroy() {
        ui.removeCallbacksAndMessages(null); releasePlayer(); abandonFocus();
        unregisterReceiver(noisy); session.release(); stopForeground(STOP_FOREGROUND_REMOVE);
        if (active == this) { active = null; latest = "{}"; }
        super.onDestroy();
    }
}
