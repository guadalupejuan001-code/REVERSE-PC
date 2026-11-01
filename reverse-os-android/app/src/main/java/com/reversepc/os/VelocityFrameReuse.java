package com.reversepc.os;

/**
 * Own-renderer frame reuse policy, intentionally independent of Android APIs.
 * XI keeps the authoritative state; this caches only a reference to the last
 * immutable observation whose pixels were successfully posted to the surface.
 */
final class VelocityFrameReuse {
    private Object state;
    private int camera=-1,paint=-1,stride=-1;
    private boolean native4K;
    private boolean valid;

    boolean canReuse(boolean paused,Object current,int camera,int paint,int stride,boolean is4K) {
        return paused && valid && current!=null && current==state &&
            camera==this.camera && paint==this.paint &&
            stride==this.stride && is4K==native4K;
    }

    void framePosted(Object observed,int camera,int paint,int stride,boolean is4K) {
        if(observed==null)throw new IllegalArgumentException("Missing XI observation");
        state=observed;
        this.camera=camera;
        this.paint=paint;
        this.stride=stride;
        native4K=is4K;
        valid=true;
    }

    void invalidate(){
        valid=false;
        state=null;
    }
}
