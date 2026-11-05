package com.reversepc.os;

/** Input sequencing only: XI remains the authority for speed and braking. */
final class VelocityGearbox {
    private boolean reverse;
    private int requested=-1;
    synchronized boolean isReverse(){return reverse;}
    synchronized boolean isPending(){return requested>=0;}
    synchronized boolean requestedReverse(){return requested<0?reverse:requested==1;}
    synchronized void reset(){reverse=false;requested=-1;}
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
        // A request made while moving holds the actual XI brake until stopped.
        // Holding the accelerator cannot counteract this requested gear change.
        int controls=requested<0?rawInput:(rawInput&12)|2;
        return (controls&127)|(reverse?128:0);
    }
}
