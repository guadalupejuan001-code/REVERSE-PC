package com.reversepc.os;

public final class MusicDownloadPolicyTest {
    private static int checks;
    private static void check(boolean value) { if (!value) throw new AssertionError("Check " + (checks + 1)); checks++; }
    private static void denied(String value) {
        boolean rejected = false;
        try { MusicDownloadPolicy.resolve(value); } catch (IllegalArgumentException expected) { rejected = true; }
        check(rejected);
    }
    public static void main(String[] args) {
        check(MusicDownloadPolicy.resolve(" https://audio.example/song.mp3?signature=a%2Bb&format=mp3 ").toString().equals("https://audio.example/song.mp3?signature=a%2Bb&format=mp3"));
        check(MusicDownloadPolicy.resolve("https://audio.example:443/music").getPort() == 443);
        for (String input : new String[]{null, "", "musica", "http://audio.example/a.mp3", "file:///tmp/song.mp3", "content://media/audio/1", "javascript:alert(1)", "https://user:pass@audio.example/a.mp3", "https://audio.example:8443/a.mp3", "https://audio.example/a.mp3#fragment", "https://audio.example/a\n.mp3", "https:///song.mp3", "https://youtube.com/watch?v=abcdefghijk", "https://m.youtube.com/watch?v=abcdefghijk", "https://music.youtube.com/watch?v=abcdefghijk", "https://YOUTUBE.COM./watch?v=abcdefghijk", "https://youtu.be/abcdefghijk", "https://www.youtube-nocookie.com/embed/abcdefghijk", "https://audio.example/" + "a".repeat(4096)}) denied(input);
        for (String type : new String[]{"audio/mpeg", "audio/flac; charset=binary", "application/ogg", "application/octet-stream", "Audio/WAV"}) check(MusicDownloadPolicy.audioType(type));
        for (String type : new String[]{null, "", "text/html", "text/html;audio/mpeg", "application/json", "video/mp4"}) check(!MusicDownloadPolicy.audioType(type));
        check(MusicDownloadPolicy.title("../folder\n/song.wav").equals(".. folder  song.wav"));
        check(MusicDownloadPolicy.title(null).equals("Audio guardado"));
        check(MusicDownloadPolicy.title("x".repeat(300)).length() == 240);
        check(MusicDownloadPolicy.MAX_BYTES == 209715200L);
        System.out.println("MUSIC_DOWNLOAD_POLICY_PASS " + checks);
    }
}
