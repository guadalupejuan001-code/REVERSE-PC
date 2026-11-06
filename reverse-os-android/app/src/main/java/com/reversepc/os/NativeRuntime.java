package com.reversepc.os;
public final class NativeRuntime {
    // Generic compact XI sessions. Candidates commit only after validation.
    public static native long sessionOpen(byte[] state);
    public static native void sessionClose(long session);
    public static native byte[] sessionStage(long session,String source);
    public static native long sessionCommit(long session);
    public static native void sessionDiscard(long session);
    public static native byte[] sessionObserve(long session,String source,int[] addresses,byte[] values);
    public static native byte[] sessionObserveGeometryDelta(long session,String source,int[] addresses,byte[] values);
    public static native void sessionSetGeometryProgram(long session,String source);
    public static native byte[] sessionObservePreparedGeometry(long session,int[] addresses,byte[] values);
    static native XiSharedGeometryPacket sessionObserveSharedGeometry(long session,int[] addresses,byte[] values);
    static native XiSharedGeometryPacket sessionObserveSharedGeometryView(long session,int[] addresses,byte[] values,int quality,byte[] viewState);
    public static native void sessionRegisterResources(long session,String[] names,byte[][] values);
    public static native byte[] sessionReadResource(long session,String name);
    public static native void sessionSetComponent(long session,String name,byte[] bytes);
    public static native byte[] sessionGetComponent(long session,String name);
    public static native byte[] sessionStateOutput(long session);
    public static native byte[] sessionCheckpointSpace(long session);
    public static native long sessionOpenSpace(byte[] archive);
    public static native long sessionForkSpace(long session);
    public static native String sessionInspectSpace(long session);
    public static native void sessionBookmark(long session,String name);
    public static native long sessionRewind(long session,String name);
    public static native void releaseThreadScratch();
    static { System.loadLibrary("reverse_os"); }
    private NativeRuntime() {}
    public static native byte[] initialize();
    public static native byte[] execute(byte[] state,String source);
    /**
     * Executes exactly the same XI program on a restored private snapshot,
     * returning the raw XFS1/XFB5 image. Never publishes a mutated RVPC2
     * state. The freshly allocated result may be transferred to an internal
     * owned-frame decoder without another 8.3 MiB defensive copy.
     */
    public static native byte[] observeFrame(byte[] state,String source);
    /** XI-owned geometry on a private snapshot with at most 32 byte inputs. */
    public static native byte[] observeGeometry(byte[] state,String source,int[] addresses,byte[] values);
    public static native String inspect(byte[] state);
    public static native byte[] compileRxe(byte[] sourceUtf8,byte[] titleUtf8);
    public static native byte[] inspectRxe(byte[] executable);
    public static native byte[] executeRxe(byte[] state,byte[] executable);
    public static native byte[] appSeed(byte[] executable);
    public static native byte[] appTurn(byte[] state,byte[] executable,byte[] messageUtf8,int language);
    // Existing XI Machine v1; input mailbox and one atomic isolated game transaction.
    public static native byte[] velocityTick(byte[] state,byte[] executable,
                      int gas,int brake,int steering,int drift,int reset);
}
