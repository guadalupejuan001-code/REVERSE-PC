package com.reversepc.os;

/** Input sequencing only: XI remains the authority for speed and braking. */
final class VelocityGearbox {
    private boolean reverse;
    private int requested=-1;
    private int forwardSelection;
    synchronized int forwardSelection(){return forwardSelection;}
    synchronized void automatic(){forwardSelection=0;}
    synchronized void shift(int delta,int observedGear){
        if(reverse||requested>=0)return;
        forwardSelection=Math.max(1,Math.min(6,(forwardSelection==0?observedGear:forwardSelection)+delta));
    }
    synchronized boolean isReverse(){return reverse;}
    synchronized boolean isPending(){return requested>=0;}
    synchronized boolean requestedReverse(){return requested<0?reverse:requested==1;}
    synchronized void reset(){reverse=false;requested=-1;forwardSelection=0;}
    synchronized int[] checkpoint(){return new int[]{reverse?1:0,requested,forwardSelection};}
    synchronized void restore(int direction,int pending){
        restore(direction,pending,0);
    }
    synchronized void restore(int direction,int pending,int forward){
        if(forward<0||forward>6)throw new IllegalArgumentException("Stored forward gear");
        if(direction<0||direction>1||pending<-1||pending>1)throw new IllegalArgumentException("Stored gear protocol");
        reverse=direction==1;requested=pending;forwardSelection=forward;
    }
    synchronized void request(boolean direction,int observedSpeedCmps){
        requested=direction==reverse?-1:direction?1:0;
        settle(observedSpeedCmps);
    }
    private void settle(int speed){
        if(requested>=0&&speed<=25){reverse=requested==1;requested=-1;}
    }
    /** Bits 0..6 retain pedal input; bit 7 publishes the selected direction. */
    synchronized int prepare(int rawInput,int observedSpeedCmps){
        settle(observedSpeedCmps);
        // An intentional accelerator press cancels a queued direction change.
        // Never silently keep the brake locked while the driver asks to move.
        // Reverse still requires an actual stop; gas does not engage reverse.
        if(requested>=0 && (rawInput&1)!=0 && (rawInput&2)==0)requested=-1;
        int controls=requested<0?rawInput:(rawInput&12)|2;
        return (controls&127)|(reverse?128:0);
    }
}
