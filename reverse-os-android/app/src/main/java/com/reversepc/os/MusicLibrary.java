package com.reversepc.os;

import android.content.Context;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.provider.OpenableColumns;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InterruptedIOException;
import java.net.HttpURLConnection;
import java.net.URI;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import org.json.JSONArray;
import org.json.JSONObject;

/** App-private, offline audio. Metadata never grants access to arbitrary file paths. */
final class MusicLibrary {
    private static MusicLibrary instance;
    static synchronized MusicLibrary get(Context context) {
        if (instance == null) instance = new MusicLibrary(context.getApplicationContext());
        return instance;
    }
    private final Context context;
    private final SharedPreferences prefs;
    private final File directory;
    private final LinkedHashMap<String, JSONObject> tracks = new LinkedHashMap<>();
    private final LinkedHashMap<String, String> pending = new LinkedHashMap<>();
    private final ExecutorService worker = Executors.newSingleThreadExecutor();
    private MusicLibrary(Context context) {
        this.context = context;
        prefs = context.getSharedPreferences("reverse-music-library", Context.MODE_PRIVATE);
        directory = new File(context.getFilesDir(), "music-audio");
        if (!directory.isDirectory()) directory.mkdirs();
        try {
            JSONArray saved = new JSONArray(prefs.getString("tracks", "[]"));
            for (int i = 0; i < Math.min(100, saved.length()); i++) {
                JSONObject item = saved.getJSONObject(i); String id = item.optString("id");
                if (!validId(id)) continue;
                item.put("title", MusicDownloadPolicy.title(item.optString("title")));
                if ("saving".equals(item.optString("status")))
                    item.put("status", "error").put("error", "La transferencia se interrumpió. Vuelve a descargar o importar el audio.");
                if ("ready".equals(item.optString("status")) && !file(id).isFile())
                    item.put("status", "error").put("error", "El archivo ya no está disponible.");
                tracks.put(id, item);
            }
        } catch (Exception ignored) { /* A corrupt index cannot expose other app files. */ }
        File[] parts = directory.listFiles((dir, name) -> name.endsWith(".part"));
        if (parts != null) for (File part : parts) part.delete();
        persist();
    }
    private static boolean validId(String id) { return id != null && id.matches("[a-f0-9-]{36}"); }
    private File file(String id) { return new File(directory, id + ".audio"); }
    private synchronized void persist() {
        JSONArray list = new JSONArray(); for (JSONObject track : tracks.values()) list.put(track);
        prefs.edit().putString("tracks", list.toString()).commit();
    }
    synchronized JSONArray list() {
        JSONArray result = new JSONArray();
        for (JSONObject item : tracks.values()) try { result.put(new JSONObject(item.toString())); } catch (Exception ignored) {}
        return result;
    }
    synchronized JSONObject ready(String id) throws Exception {
        JSONObject item = tracks.get(id);
        if (!validId(id) || item == null || !"ready".equals(item.optString("status")) || !file(id).isFile())
            throw new IOException("La canción no está guardada. Descárgala o impórtala primero.");
        return new JSONObject(item.toString());
    }
    synchronized File audio(String id) throws Exception { ready(id); return file(id); }
    synchronized ArrayList<String> readyIds() {
        ArrayList<String> result = new ArrayList<>();
        for (JSONObject item : tracks.values()) if ("ready".equals(item.optString("status")) && file(item.optString("id")).isFile()) result.add(item.optString("id"));
        return result;
    }
    private synchronized String begin(String source, String title) throws Exception {
        if (pending.containsKey(source)) throw new IOException("Esta transferencia ya está en curso.");
        if (tracks.size() >= 100) throw new IOException("La biblioteca admite 100 archivos. Elimina uno para guardar otro.");
        if (pending.size() >= 3) throw new IOException("Espera a que termine una de las transferencias actuales.");
        String id = UUID.randomUUID().toString();
        tracks.put(id, new JSONObject().put("id", id).put("title", MusicDownloadPolicy.title(title))
            .put("status", "saving").put("bytes", 0).put("total", 0).put("duration", 0).put("error", ""));
        pending.put(source, id); persist(); return id;
    }
    String download(String input) throws Exception {
        URI uri = MusicDownloadPolicy.resolve(input);
        String name = Uri.parse(uri.toString()).getLastPathSegment();
        String id = begin(uri.toString(), name);
        worker.execute(() -> transfer(id, uri)); return id;
    }
    String importAudio(Uri uri) throws Exception {
        if (uri == null || !("content".equals(uri.getScheme()) || "file".equals(uri.getScheme()))) throw new IOException("Archivo de audio no válido.");
        String id = begin(uri.toString(), "Importando audio…");
        worker.execute(() -> {
            try {
                String name = uri.getLastPathSegment(); long size = -1;
                if ("content".equals(uri.getScheme())) try (Cursor cursor = context.getContentResolver().query(uri, new String[]{OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE}, null, null, null)) {
                    if (cursor != null && cursor.moveToFirst()) { name = cursor.getString(0); if (!cursor.isNull(1)) size = cursor.getLong(1); }
                }
                try (InputStream stream = context.getContentResolver().openInputStream(uri)) { save(id, stream, size, name); }
            } catch (Exception error) { failed(id, error); }
            finally { finished(id); }
        }); return id;
    }
    private void transfer(String id, URI uri) {
        HttpURLConnection connection = null;
        try {
            for (int hop = 0; ; hop++) {
                check(id); connection = (HttpURLConnection) uri.toURL().openConnection();
                connection.setInstanceFollowRedirects(false); connection.setConnectTimeout(15000); connection.setReadTimeout(15000);
                connection.setRequestProperty("Accept", "audio/*,application/ogg,application/octet-stream");
                connection.setRequestProperty("Accept-Encoding", "identity");
                int status = connection.getResponseCode();
                if (status == 301 || status == 302 || status == 303 || status == 307 || status == 308) {
                    if (hop >= 5) throw new IOException("El enlace tiene demasiadas redirecciones.");
                    String location = connection.getHeaderField("Location");
                    if (location == null) throw new IOException("Redirección sin destino.");
                    uri = MusicDownloadPolicy.resolve(uri.resolve(location).toString()); connection.disconnect(); continue;
                }
                if (status != 200) throw new IOException("El servidor respondió con error " + status + ".");
                if (!MusicDownloadPolicy.audioType(connection.getContentType())) throw new IOException("El enlace devuelve una página u otro tipo de archivo. Usa el enlace directo al audio.");
                try (InputStream stream = connection.getInputStream()) {
                    save(id, stream, connection.getContentLengthLong(), Uri.parse(uri.toString()).getLastPathSegment());
                }
                break;
            }
        } catch (Exception error) { failed(id, error); }
        finally { if (connection != null) connection.disconnect(); finished(id); }
    }
    private synchronized void check(String id) throws IOException {
        if (!tracks.containsKey(id) || !pending.containsValue(id)) throw new InterruptedIOException("Transferencia cancelada.");
    }
    private void save(String id, InputStream input, long expected, String name) throws Exception {
        if (input == null) throw new IOException("No se pudo leer el audio.");
        if (expected > MusicDownloadPolicy.MAX_BYTES) throw new IOException("El archivo supera el límite de 200 MB.");
        if (expected > 0 && directory.getUsableSpace() < expected + 5 * 1024 * 1024) throw new IOException("No hay espacio suficiente para guardar el audio.");
        File part = new File(directory, id + ".part"); long bytes = 0;
        try {
            try (FileOutputStream output = new FileOutputStream(part)) {
                byte[] block = new byte[32768]; int count;
                while ((count = input.read(block)) != -1) {
                    check(id); bytes += count;
                    if (bytes > MusicDownloadPolicy.MAX_BYTES) throw new IOException("El archivo supera el límite de 200 MB.");
                    output.write(block, 0, count);
                    synchronized (this) { JSONObject item = tracks.get(id); if (item != null) item.put("bytes", bytes).put("total", Math.max(0, expected)); }
                }
                output.getFD().sync();
            }
            if (bytes == 0 || (expected >= 0 && bytes != expected)) throw new IOException("La transferencia llegó incompleta. Vuelve a intentarlo.");
            long duration; String tagged;
            MediaMetadataRetriever metadata = new MediaMetadataRetriever();
            try {
                metadata.setDataSource(part.getAbsolutePath());
                if (!"yes".equals(metadata.extractMetadata(MediaMetadataRetriever.METADATA_KEY_HAS_AUDIO))) throw new IOException("El archivo no contiene audio compatible.");
                duration = Long.parseLong(metadata.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION));
                tagged = metadata.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE);
                if (duration <= 0) throw new IOException("El archivo no contiene una canción reproducible.");
            } catch (RuntimeException invalid) { throw new IOException("El archivo no contiene audio compatible.", invalid); }
            finally { metadata.release(); }
            synchronized (this) {
                check(id);
                if (!part.renameTo(file(id))) throw new IOException("No se pudo guardar el archivo.");
                tracks.get(id).put("status", "ready").put("title", MusicDownloadPolicy.title(tagged == null || tagged.trim().isEmpty() ? name : tagged))
                    .put("bytes", bytes).put("total", bytes).put("duration", duration / 1000.0).put("error", "");
                persist();
            }
        } finally { part.delete(); }
    }
    private synchronized void failed(String id, Exception error) {
        JSONObject item = tracks.get(id); if (item == null) return;
        String message = error.getMessage();
        if (error instanceof java.net.SocketTimeoutException) message = "El servidor tardó demasiado. Vuelve a intentarlo.";
        else if (error instanceof java.io.FileNotFoundException) message = "No se pudo leer o guardar el archivo. Comprueba el archivo y el espacio disponible.";
        else if (message == null || message.contains(directory.getAbsolutePath())) message = "Comprueba el enlace, el formato de audio y el espacio disponible.";
        try { item.put("status", "error").put("error", "No se pudo guardar el audio: " + message); } catch (Exception ignored) {}
        persist();
    }
    private synchronized void finished(String id) { pending.values().remove(id); }
    synchronized void remove(String id) throws Exception {
        if (!validId(id) || !tracks.containsKey(id)) return;
        File audio = file(id);
        if (audio.isFile() && !audio.delete()) throw new IOException("No se pudo eliminar el audio.");
        tracks.remove(id); pending.values().remove(id); persist();
    }
}
