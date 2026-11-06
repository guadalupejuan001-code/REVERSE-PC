package com.reversepc.os;

/** View smoothing only: XI continues to construct and project the camera. */
final class VelocityChaseCamera {
    private double yaw,pitch;
    private int previousVehicleYaw;
    private long previousTime;
    private boolean initialized;
    private static int delta(int a,int b){return ((a-b+2048)&4095)-2048;}
    void reset(){initialized=false;previousTime=0;}
    long[] checkpoint(long now){return new long[]{Double.doubleToRawLongBits(yaw),Double.doubleToRawLongBits(pitch),previousVehicleYaw,initialized?1:0,Math.max(0,Math.min(80_000_000L,now-previousTime))};}
    void restore(long[] state,long now){
        if(state.length!=5)throw new IllegalArgumentException("Stored chase camera length");
        yaw=Double.longBitsToDouble(state[0]);pitch=Double.longBitsToDouble(state[1]);previousVehicleYaw=(int)state[2];initialized=state[3]==1;previousTime=now-state[4];
    }
    int update(int manualOrbit,boolean manual,boolean frozen,int vehicleYaw,int speed,int jump,boolean reverse,long now){
        if(!initialized){yaw=VelocityOrbitMath.yaw(manualOrbit);pitch=VelocityOrbitMath.pitch(manualOrbit);previousVehicleYaw=vehicleYaw;previousTime=now;initialized=true;}
        double dt=Math.max(.001,Math.min(.08,(now-previousTime)/1e9));
        int turn=delta(vehicleYaw,previousVehicleYaw);
        previousVehicleYaw=vehicleYaw;previousTime=now;
        if(manual){yaw=VelocityOrbitMath.yaw(manualOrbit);pitch=VelocityOrbitMath.pitch(manualOrbit);}
        else if(!frozen&&speed>30){
            // A short yaw lag reveals the outside of the car in bends. Reversing
            // moves the camera to the bonnet side so the road behind stays visible.
            double lag=Math.max(-180,Math.min(180,-turn*.11/dt));
            int target=(int)Math.round((reverse?2048:0)+lag);
            double smooth=1-Math.exp(-dt*3.6);
            yaw+=delta(target,(int)Math.round(yaw))*smooth;
            double targetPitch=Math.min(32,speed/150.0)+Math.min(20,jump/10.0);
            pitch+=(targetPitch-pitch)*(1-Math.exp(-dt*2.8));
        }
        return VelocityOrbitMath.pack((int)Math.round(yaw),Math.max(-90,Math.min(125,(int)Math.round(pitch))));
    }
}
