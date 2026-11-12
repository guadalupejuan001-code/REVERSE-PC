package com.reversepc.os;

/** Integrated Mundo X PC, GPU-VIRTUAL and qSSD through REVERSE's existing RVPC2 owner. */
public final class NativeFabric {
    static { System.loadLibrary("reverse_fabric"); }
    private NativeFabric() {}
    public static native long create();
    public static native void destroy(long handle);
    /** RXOS1 packet: JSON report plus the *same* canonical RVPC2 state, committed by SessionStore. */
    public static native byte[] apply(long handle, byte[] canonicalRvpc2, String action, String argument);
}
