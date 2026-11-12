package com.reversepc.os;
public final class NativeRuntime {
    static { System.loadLibrary("reverse_os"); }
    private NativeRuntime() {}
    public static native byte[] initialize();
    public static native byte[] execute(byte[] state,String source);
    public static native String inspect(byte[] state);
    /** Direct, no-measurement bridge for Mundo X PC Ether aperture into original RVPC2. */
    public static native int fabricReadByte(byte[] state,long logicalAddress);
    public static native byte[] fabricWriteByte(byte[] state,long logicalAddress,int value);
    /** Original RVPC2 XI workers C02: private copies or optimistic commits on the same authority. */
    public static native byte[] executeWorkers(byte[] canonicalRvpc2,String[] programs,
                                                int workers,boolean transactional,long hostAvailableBytes);
    public static native byte[] compileRxe(byte[] sourceUtf8,byte[] titleUtf8);
    public static native byte[] inspectRxe(byte[] executable);
    public static native byte[] executeRxe(byte[] state,byte[] executable);
    public static native byte[] graphicsAsset(byte[] executable,byte[] pathUtf8);
    public static native byte[] graphicsTurn(byte[] state,byte[] executable,int kind,int quality);
    static native long xRenderCreate();
    static native void xRenderResize(long renderer,int width,int height);
    static native String xRenderFrame(long renderer,float[] frame);
    static native void xRenderDestroy(long renderer,boolean releaseGl);
    public static native byte[] appSeed(byte[] executable);
    public static native byte[] appTurn(byte[] state,byte[] executable,byte[] messageUtf8,int language);
}
