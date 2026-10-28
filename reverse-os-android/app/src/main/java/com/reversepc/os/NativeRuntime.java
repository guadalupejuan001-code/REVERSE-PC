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
    public static native byte[] appSeed(byte[] executable);
    public static native byte[] appTurn(byte[] state,byte[] executable,byte[] messageUtf8,int language);
    public static native byte[] guestInitialize(byte[] elf,long logicalRamBytes,int maxOverrides);
    public static native String guestInspect(byte[] state);
    public static native byte[] guestRun(byte[] state,int steps);
    public static native byte[] guestXi(byte[] state,String deltaProgram);
}
