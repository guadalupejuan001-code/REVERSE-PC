package com.reversepc.os;
public final class NativeRuntime {
    static { System.loadLibrary("reverse_os"); }
    private NativeRuntime() {}
    public static native byte[] initialize();
    public static native byte[] execute(byte[] state,String source);
    public static native String inspect(byte[] state);
    public static native byte[] compileRxe(byte[] sourceUtf8,byte[] titleUtf8);
    public static native byte[] inspectRxe(byte[] executable);
    public static native byte[] executeRxe(byte[] state,byte[] executable);
}
