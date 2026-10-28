package com.reversepc.os;

import android.app.Instrumentation;
import android.app.NotificationManager;
import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.net.Uri;
import android.os.ParcelFileDescriptor;
import android.service.notification.StatusBarNotification;
import android.widget.FrameLayout;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.Predicate;
import org.json.JSONArray;
import org.json.JSONObject;

/** Actual private copies, MediaPlayer decoder, media notification and background service. */
final class MusicOfflineChecks {
    private static int checks;
    private static void check(boolean ok, String message) { if (!ok) throw new AssertionError(message + " service=" + MusicAudioService.state()); checks++; }
    private static JSONObject waitAudio(Predicate<JSONObject> condition) throws Exception {
        for (int i = 0; i < 120; i++) { JSONObject state = MusicAudioService.state(); if (condition.test(state)) return state; Thread.sleep(100); }
        throw new AssertionError("Offline audio timed out: " + MusicAudioService.state());
    }
    private static JSONObject waitTrack(MusicLibrary library, String id, String status) throws Exception {
        for (int i = 0; i < 120; i++) {
            JSONArray items = library.list();
            for (int j = 0; j < items.length(); j++) { JSONObject item = items.getJSONObject(j); if (id.equals(item.optString("id")) && status.equals(item.optString("status"))) return item; }
            Thread.sleep(100);
        }
        throw new AssertionError("Library transfer timed out: " + library.list());
    }
    private static void control(Instrumentation runner, MusicPlayer player, String action, JSONObject data) {
        runner.runOnMainSync(() -> { try { player.command(action, data); } catch (Exception error) { throw new RuntimeException(error); } });
    }
    private static void shell(Instrumentation runner, String command) throws Exception {
        try (ParcelFileDescriptor output = runner.getUiAutomation().executeShellCommand(command);
             java.io.InputStream stream = new ParcelFileDescriptor.AutoCloseInputStream(output)) {
            byte[] bytes = new byte[1024]; while (stream.read(bytes) != -1) {}
        }
    }
    static int run(Instrumentation runner, WorkbenchActivity activity) throws Exception {
        checks = 0; MusicLibrary library = MusicLibrary.get(activity); ArrayList<String> created = new ArrayList<>();
        File first = new File(activity.getCacheDir(), "offline-game-a.wav"), second = new File(activity.getCacheDir(), "offline-game-b.wav"), bad = new File(activity.getCacheDir(), "offline-invalid.wav");
        AtomicReference<MusicPlayer> player = new AtomicReference<>();
        AudioManager audio = (AudioManager)activity.getSystemService(Context.AUDIO_SERVICE);
        AudioFocusRequest competing = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .setAudioAttributes(new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_GAME).setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build())
            .setOnAudioFocusChangeListener(change -> {}).build();
        try {
            Files.write(first.toPath(), MusicPlayerChecks.tone()); Files.write(second.toPath(), MusicPlayerChecks.tone());
            Files.write(bad.toPath(), "<html>This is not an audio file</html>".getBytes(StandardCharsets.UTF_8));
            String a = library.importAudio(Uri.fromFile(first)); created.add(a);
            JSONObject saved = waitTrack(library, a, "ready");
            check(saved.getDouble("duration") > 10, "Native metadata did not validate the real WAV");
            check(library.audio(a).length() == first.length(), "Private offline copy is incomplete");
            check(first.delete() && library.audio(a).isFile(), "Audio still depends on its original provider file");
            String b = library.importAudio(Uri.fromFile(second)); created.add(b); waitTrack(library, b, "ready");
            String rejected = library.importAudio(Uri.fromFile(bad)); created.add(rejected);
            check(!waitTrack(library, rejected, "error").getString("error").isEmpty(), "A fake audio download was accepted");
            check(!library.readyIds().contains(rejected), "Failed transfers appear as playable songs");
            boolean[] unknownRejected = {false};
            try { library.audio("../../session.rvp"); } catch (Exception expected) { unknownRejected[0] = true; }
            check(unknownRejected[0], "Library identifier can access another app file");
            runner.runOnMainSync(() -> player.set(new MusicPlayer(activity, (FrameLayout)activity.testingWebView().getParent(), activity.testingWebView(), state -> {})));
            check(MusicAudioService.state().optString("localId").isEmpty(), "Opening Music automatically started local playback");
            control(runner, player.get(), "repeat", new JSONObject().put("enabled", true));
            control(runner, player.get(), "local", new JSONObject().put("id", a));
            JSONObject started = waitAudio(s -> a.equals(s.optString("localId")) && !s.optBoolean("paused", true) && s.optDouble("time") > .2);
            check(started.getBoolean("hasMedia") && started.getBoolean("repeatOne"), "Actual offline audio failed to start with repeat one");
            check(started.getBoolean("canNext"), "Offline queue cannot reach another saved song");
            NotificationManager notifications = (NotificationManager)activity.getSystemService(Context.NOTIFICATION_SERVICE);
            StatusBarNotification notification = null;
            for (StatusBarNotification item : notifications.getActiveNotifications()) if (item.getId() == 7301) notification = item;
            check(notification != null && notification.getNotification().actions.length == 2, "Background playback has no real media notification");
            control(runner, player.get(), "seek", new JSONObject().put("time", started.getDouble("duration") - .2));
            Thread.sleep(700);
            JSONObject looped = waitAudio(s -> a.equals(s.optString("localId")) && !s.optBoolean("paused", true) && s.optDouble("time") < 2);
            check(looped.getDouble("time") < 2, "Repeat one did not wrap the real offline PCM stream");
            // A real Activity leaves the foreground while the local service owns playback.
            runner.runOnMainSync(() -> player.get().pause());
            double before = MusicAudioService.state().optDouble("time");
            shell(runner, "input keyevent KEYCODE_HOME"); Thread.sleep(1300);
            JSONObject background = MusicAudioService.state();
            check(!background.optBoolean("paused", true) && background.optDouble("time") > before + .3, "Leaving the desktop stopped offline music");
            shell(runner, "am start -W -n " + activity.getPackageName() + "/com.reversepc.os.WorkbenchActivity");
            runner.runOnMainSync(() -> player.get().resume());
            // The notification action, rather than a mocked transport, pauses the service.
            for (StatusBarNotification item : notifications.getActiveNotifications()) if (item.getId() == 7301) notification = item;
            notification.getNotification().actions[0].actionIntent.send();
            JSONObject paused = waitAudio(s -> s.optBoolean("paused", true));
            double stopped = paused.getDouble("time"); Thread.sleep(650);
            check(Math.abs(MusicAudioService.state().optDouble("time") - stopped) < .1, "Notification Pause left the native audio clock running");
            control(runner, player.get(), "play", new JSONObject()); waitAudio(s -> !s.optBoolean("paused", true));
            runner.runOnMainSync(() -> check(audio.requestAudioFocus(competing) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED, "Competing game focus was denied"));
            waitAudio(s -> s.optBoolean("paused", true));
            runner.runOnMainSync(() -> audio.abandonAudioFocusRequest(competing)); Thread.sleep(400);
            check(MusicAudioService.state().optBoolean("paused"), "Audio resumed automatically after a competing app released focus");
            control(runner, player.get(), "repeat", new JSONObject().put("enabled", false));
            control(runner, player.get(), "play", new JSONObject()); waitAudio(s -> !s.optBoolean("paused", true));
            control(runner, player.get(), "seek", new JSONObject().put("time", started.getDouble("duration") - .2));
            JSONObject advanced = waitAudio(s -> b.equals(s.optString("localId")) && !s.optBoolean("paused", true));
            check(!advanced.getBoolean("repeatOne"), "Queue advancement retained repeat after it was disabled");
            runner.runOnMainSync(() -> { player.get().stopLocal(); player.get().destroy(); });
            waitAudio(s -> s.optString("localId").isEmpty());
            check(!MusicAudioService.state().optBoolean("hasMedia"), "Closing Music left offline playback active");
            runner.runOnMainSync(() -> { MusicAudioService.select(activity, a, false); MusicAudioService.stopPlayback(); });
            Thread.sleep(700);
            check(MusicAudioService.state().optString("localId").isEmpty(), "A queued service start escaped an immediate Close");
            return checks;
        } finally {
            runner.runOnMainSync(() -> { audio.abandonAudioFocusRequest(competing); MusicAudioService.stopPlayback(); if (player.get() != null) player.get().destroy(); });
            for (String id : created) library.remove(id);
            first.delete(); second.delete(); bad.delete();
            shell(runner, "am start -W -n " + activity.getPackageName() + "/com.reversepc.os.WorkbenchActivity");
        }
    }
}
