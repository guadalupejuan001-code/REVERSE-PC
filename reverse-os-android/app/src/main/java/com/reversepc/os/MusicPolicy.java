package com.reversepc.os;

import java.net.URI;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.Locale;

/** Pure URL/filter policy shared by the native player and its host-side tests. */
public final class MusicPolicy {
    private MusicPolicy() {}
    public static final String HOME = "https://m.youtube.com/";
    private static final String[] AD_HOSTS = {
        "doubleclick.net", "googlesyndication.com", "googleadservices.com",
        "googletagservices.com", "google-analytics.com"
    };
    private static boolean domain(String host, String suffix) {
        return host.equals(suffix) || host.endsWith("." + suffix);
    }
    private static URI uri(String value) {
        try {
            URI uri = new URI(value);
            if (!"https".equalsIgnoreCase(uri.getScheme()) || uri.getRawUserInfo() != null
                || (uri.getPort() != -1 && uri.getPort() != 443) || uri.getHost() == null) return null;
            return uri;
        } catch (Exception ignored) { return null; }
    }
    public static boolean pageAllowed(String value) {
        URI uri = uri(value);
        if (uri == null) return false;
        String host = uri.getHost().toLowerCase(Locale.ROOT);
        return host.equals("youtube.com") || host.equals("www.youtube.com")
            || host.equals("m.youtube.com") || host.equals("music.youtube.com")
            || host.equals("consent.youtube.com") || host.equals("youtu.be");
    }
    public static boolean isAdRequest(String value) {
        URI uri = uri(value);
        if (uri == null) return false;
        String host = uri.getHost().toLowerCase(Locale.ROOT);
        if (host.endsWith(".")) host = host.substring(0,host.length()-1);
        for (String ad : AD_HOSTS) if (domain(host, ad)) return true;
        String path = uri.getPath() == null ? "" : uri.getPath();
        return domain(host, "youtube.com") && (
            path.equals("/pagead") || path.startsWith("/pagead/")
            || path.equals("/api/stats/ads") || path.startsWith("/api/stats/ads/")
            || path.equals("/get_midroll_info") || path.equals("/ptracking"));
    }
    private static String encode(String text) {
        try { return URLEncoder.encode(text, "UTF-8").replace("+", "%20"); }
        catch (java.io.UnsupportedEncodingException impossible) { throw new AssertionError(impossible); }
    }
    private static String param(URI uri, String key) {
        String query = uri.getRawQuery();
        if (query == null) return "";
        for (String part : query.split("&")) {
            String[] pair = part.split("=", 2);
            if (pair.length == 2 && pair[0].equals(key)) {
                try { return URLDecoder.decode(pair[1], "UTF-8"); }
                catch (Exception ignored) { return ""; }
            }
        }
        return "";
    }
    public static String resolve(String input) {
        if (input == null || input.trim().isEmpty()) return HOME;
        String text = input.trim();
        if (text.length() > 2048 || text.codePoints().anyMatch(c -> Character.isISOControl(c)))
            throw new IllegalArgumentException("Búsqueda o enlace demasiado largo o no válido.");
        if (!text.matches("(?i)^[a-z][a-z0-9+.-]*:.*")
            && text.matches("(?i)^(?:(?:www|m|music)\\.)?youtube\\.com(?:/.*)?$|^youtu\\.be(?:/.*)?$"))
            text = "https://" + text;
        // A colon in an artist/title is text, not an instruction to navigate.
        if (!text.matches("(?i)^(?:[a-z][a-z0-9+.-]*://|(?:https?|javascript|data|file|content|intent|about|blob|mailto|tel):).*"))
            return "https://m.youtube.com/results?search_query=" + encode(text);
        URI uri = uri(text);
        if (uri == null || !pageAllowed(text) || "consent.youtube.com".equalsIgnoreCase(uri.getHost()))
            throw new IllegalArgumentException("Usa una búsqueda o un enlace HTTPS de YouTube.");
        String path = uri.getPath() == null ? "/" : uri.getPath();
        String video = path.equals("/watch") ? param(uri, "v") : "", list = param(uri, "list");
        if (uri.getHost().equalsIgnoreCase("youtu.be")) video = path.length() > 1 ? path.substring(1).split("/", 2)[0] : "";
        else if (path.startsWith("/shorts/") || path.startsWith("/live/") || path.startsWith("/embed/"))
            video = path.substring(path.indexOf('/', 1) + 1).split("/", 2)[0];
        if (!video.isEmpty()) {
            if (!video.matches("[A-Za-z0-9_-]{11}")) throw new IllegalArgumentException("ID de video no válido.");
            String result = "https://m.youtube.com/watch?v=" + video;
            if (!list.isEmpty()) {
                if (!list.matches("[A-Za-z0-9_-]{1,160}")) throw new IllegalArgumentException("Lista no válida.");
                result += "&list=" + list;
            }
            String time = param(uri, "t");
            if (time.matches("[0-9hms]{1,16}")) result += "&t=" + time;
            return result;
        }
        if (path.equals("/playlist") && list.matches("[A-Za-z0-9_-]{1,160}"))
            return "https://m.youtube.com/playlist?list=" + list;
        if (path.equals("/results")) return "https://m.youtube.com/results?search_query=" + encode(param(uri, "search_query"));
        if (path.equals("/") || path.isEmpty()) return HOME;
        throw new IllegalArgumentException("Pega el enlace de un video o una lista, o escribe una búsqueda.");
    }
}
