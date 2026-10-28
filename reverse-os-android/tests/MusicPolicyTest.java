package com.reversepc.os;

public final class MusicPolicyTest {
    private static int checks;
    private static void check(boolean value, String message) {
        if (!value) throw new AssertionError(message); checks++;
    }
    private static void reject(String input) {
        try { MusicPolicy.resolve(input); throw new AssertionError("Accepted: " + input); }
        catch (IllegalArgumentException expected) { checks++; }
    }
    public static void main(String[] args) {
        check(MusicPolicy.resolve("").equals(MusicPolicy.HOME), "Home");
        check(MusicPolicy.resolve("café & jazz").endsWith("caf%C3%A9%20%26%20jazz"), "UTF-8 search");
        for (String input : new String[]{"https://youtu.be/abcdefghijk?si=tracking", "youtube.com/watch?v=abcdefghijk",
            "https://music.youtube.com/watch?v=abcdefghijk", "https://www.youtube.com/shorts/abcdefghijk",
            "https://www.youtube.com/live/abcdefghijk", "https://www.youtube.com/embed/abcdefghijk"})
            check(MusicPolicy.resolve(input).equals("https://m.youtube.com/watch?v=abcdefghijk"), input);
        check(MusicPolicy.resolve("https://m.youtube.com/watch?v=abcdefghijk&list=PL_123&t=1m30s&si=secret")
            .equals("https://m.youtube.com/watch?v=abcdefghijk&list=PL_123&t=1m30s"), "Playlist/time without tracking");
        check(MusicPolicy.resolve("https://youtube.com/playlist?list=PL_123").endsWith("/playlist?list=PL_123"), "List");
        check(MusicPolicy.resolve("https://m.youtube.com/results?search_query=hi%26there").endsWith("hi%26there"), "Query");
        check(MusicPolicy.resolve("https://m.youtube.com/results?search_query=https%3A%2F%2Fevil.test")
            .endsWith("https%3A%2F%2Fevil.test"), "Search stays a search");
        for (String input : new String[]{"javascript:alert(1)", "file:///etc/passwd", "content://private", "intent://app",
            "http://youtube.com/watch?v=abcdefghijk", "https://youtube.com.evil.test/watch?v=abcdefghijk",
            "https://youtube.com@evil.test/watch?v=abcdefghijk", "https://evil.test@youtube.com/watch?v=abcdefghijk",
            "https://youtube.com:8443/watch?v=abcdefghijk", "https://youtu.be/short", "https://youtube.com/shorts/",
            "https://consent.youtube.com/", "https://youtube.com/redirect?q=https://evil.test", "hello\u0000world"}) reject(input);
        check(MusicPolicy.pageAllowed("https://consent.youtube.com/m"), "Consent stays in isolated view");
        check(!MusicPolicy.pageAllowed("https://accounts.google.com/"), "No embedded credentials flow");
        check(!MusicPolicy.pageAllowed("https://reverse.local/"), "Desktop origin is isolated");
        check(!MusicPolicy.pageAllowed(null), "Null URL");
        for (String url : new String[]{"https://googleads.g.doubleclick.net/pagead/id", "https://tpc.googlesyndication.com/a",
            "https://www.googleadservices.com/pagead/", "https://www.youtube.com/api/stats/ads?x=1",
            "https://m.youtube.com/pagead/interaction", "https://www.youtube.com/get_midroll_info?v=x"})
            check(MusicPolicy.isAdRequest(url), "Ad blocked: " + url);
        for (String url : new String[]{"https://rr1---sn.googlevideo.com/videoplayback?source=youtube&mime=audio/mp4",
            "https://www.youtube.com/youtubei/v1/player", "https://www.youtube.com/youtubei/v1/browse",
            "https://i.ytimg.com/vi/abcdefghijk/hqdefault.jpg", "https://doubleclick.net.evil.test/",
            "https://m.youtube.com/watch?v=abcdefghijk", "https://m.youtube.com/api/stats/playback"})
            check(!MusicPolicy.isAdRequest(url), "Content preserved: " + url);
        System.out.println("MUSIC_POLICY_PASS " + checks);
    }
}
