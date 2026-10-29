package com.reversepc.os;

/** Host-JVM smoke and invariant tests; no Android SDK required. */
public final class VelocityPhysicsTest {
    private static void check(boolean ok,String label){
        if(!ok)throw new AssertionError(label);
    }
    public static void main(String[] args){
        VelocityPhysics car=new VelocityPhysics();
        check(car.speedMmps==0&&car.checkpoint==0,"initial state");
        check(!car.offRoad,"spawn on road");
        for(int i=0;i<100;i++)car.step(1000,0,0,false);
        check(car.speedKmh()>20,"car accelerates");
        int accelerated=car.speedMmps;
        for(int i=0;i<40;i++)car.step(0,1000,0,false);
        check(car.speedMmps<accelerated,"braking reduces speed");
        VelocityPhysics left=new VelocityPhysics(),right=new VelocityPhysics();
        for(int i=0;i<180;i++){
            left.step(1000,0,900,false);
            right.step(1000,0,-900,false);
        }
        check(left.xMm!=right.xMm,"steering changes trajectory");
        VelocityPhysics a=new VelocityPhysics(),b=new VelocityPhysics();
        for(int i=0;i<1600;i++){
            int throttle=(i%70<53)?1000:0,brake=(i%70>65)?500:0,steer=(i%120<60)?280:-280;
            boolean drift=i%103<12;
            a.step(throttle,brake,steer,drift);
            b.step(throttle,brake,steer,drift);
            check(a.xMm==b.xMm&&a.zMm==b.zMm&&a.yaw16==b.yaw16
                &&a.speedMmps==b.speedMmps&&a.checkpoint==b.checkpoint
                &&a.slipMmps==b.slipMmps,
                "deterministic frame "+i);
            check(a.speedMmps>=0&&a.speedMmps<=VelocityPhysics.MAX_SPEED_MMPS,
                "speed bounded");
        }
        VelocityPhysics paved=new VelocityPhysics(),dirt=new VelocityPhysics();
        dirt.xMm+=220_000;
        for(int i=0;i<100;i++){paved.step(1000,0,0,false);dirt.step(1000,0,0,false);}
        check(dirt.speedMmps<paved.speedMmps,"off-road traction penalty");
        VelocityPhysics drifting=new VelocityPhysics();
        drifting.speedMmps=42000;
        for(int i=0;i<25;i++)drifting.step(900,0,1000,true);
        check(Math.abs(drifting.lateralSlipMmps())>2000,"handbrake creates lateral slip");
        VelocityPhysics clean=new VelocityPhysics();
        clean.zMm=900_050L;clean.xMm=Math.round(VelocityPhysics.roadX(900)*1000);
        clean.speedMmps=30000;
        clean.step(0,0,0,false);
        check(clean.checkpoint==1,"swept crossing counts centerline gate");
        VelocityPhysics missed=new VelocityPhysics();
        missed.zMm=900_050L;missed.xMm=Math.round(VelocityPhysics.roadX(900)*1000)+19_000;
        missed.speedMmps=30000;
        missed.step(0,0,0,false);
        check(missed.checkpoint==0,"missed gate not awarded");
        VelocityPhysics winner=new VelocityPhysics();
        winner.checkpoint=5;winner.zMm=-599_950L;
        winner.xMm=Math.round(VelocityPhysics.roadX(-600)*1000);
        winner.speedMmps=30000;
        winner.step(0,0,0,false);
        check(winner.finished&&winner.checkpoint==6&&winner.finishMs==20,"finish is recorded");
        winner.step(1000,0,0,false);
        check(winner.elapsedMs==winner.finishMs,"finish time stops");
        a.reset();
        check(a.elapsedMs==0&&a.speedMmps==0&&a.checkpoint==0,"reset");
        System.out.println("REVERSE_VELOCITY_PHYSICS_OK");
    }
}