package com.reversepc.os;

import java.net.URI;
import java.util.Locale;

/** Only explicit HTTPS file transfers; never turns a video page into an audio URL. */
final class MusicDownloadPolicy {
    static final long MAX_BYTES = 200L * 1024 * 1024;
    static URI resolve(String input) {
        try {
            if (input == null || input.length() > 4096) throw new Exception();
            URI uri = new URI(input.trim());
            String host = uri.getHost();
            if (!"https".equalsIgnoreCase(uri.getScheme()) || host == null || host.isEmpty()
                || uri.getRawUserInfo() != null || uri.getFragment() != null
                || (uri.getPort() != -1 && uri.getPort() != 443)) throw new Exception();
            host = host.toLowerCase(Locale.ROOT).replaceAll("\\.+$", "");
            for (String page : new String[]{"youtube.com", "youtu.be", "youtube-nocookie.com"}) {
                if (host.equals(page) || host.endsWith("." + page))
                    throw new IllegalArgumentException("Pega el enlace directo de un archivo de audio. Los enlaces de YouTube se abren en Reproductor.");
            }
            return uri;
        } catch (IllegalArgumentException error) { throw error; }
        catch (Exception error) { throw new IllegalArgumentException("Introduce un enlace HTTPS directo a un archivo de audio."); }
    }
    static boolean audioType(String value) {
        String type = value == null ? "" : value.split(";", 2)[0].trim().toLowerCase(Locale.ROOT);
        return type.startsWith("audio/") || type.equals("application/ogg") || type.equals("application/octet-stream");
    }
    static String title(String name) {
        String value = name == null ? "" : name.replaceAll("[\\p{Cntrl}\\\\/]", " ").trim();
        return value.isEmpty() ? "Audio guardado" : value.substring(0, Math.min(240, value.length()));
    }
}
