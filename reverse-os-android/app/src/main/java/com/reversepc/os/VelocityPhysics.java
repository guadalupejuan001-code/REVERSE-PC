package com.reversepc.os;

/**
 * REVERSE VELOCITY: deterministic fixed-step driving state.
 *
 * The authoritative moving state is 4 integers (xMm, zMm, yaw16, speedMmps).
 * No Android dependency, no hidden second game-world copy, no frame-rate
 * dependent integration. Renderer reads the state and does not mutate it.
 *
 * XI/Ether integration is a future ABI change: do not claim that an RXE
 * currently owns this live loop or can draw on the GPU.
 */
final class VelocityPhysics {
    static final int TICK_MS=20;
    static final int MAX_SPEED_MMPS=78000;
    private static final int ANGLE_STEPS=65536;
    private static final int TABLE_SIZE=4096;
    private static final int TRIG=1<<20;
    private static final int[] SIN=new int[TABLE_SIZE+1],COS=new int[TABLE_SIZE+1];
    static {
        for(int i=0;i<=TABLE_SIZE;i++){
            double rad=2.0*Math.PI*i/TABLE_SIZE;
            SIN[i]=(int)Math.round(Math.sin(rad)*TRIG);
            COS[i]=(int)Math.round(Math.cos(rad)*TRIG);
        }
    }

    long xMm,zMm;
    int yaw16,speedMmps,checkpoint,slipMmps;
    boolean finished;
    long finishMs;
    long elapsedMs;
    boolean offRoad;
    private static final int[] GATES={900,600,300,0,-300,-600};

    VelocityPhysics(){reset();}

    void reset(){
        zMm=1100_000L;
        xMm=Math.round(roadX(1100)*1000);
        yaw16=0;speedMmps=0;checkpoint=0;slipMmps=0;
        elapsedMs=0;finishMs=0;finished=false;offRoad=false;
    }

    static double roadX(double z){
        return 22.0*Math.sin(z/230.0)+8.0*Math.sin(z/78.0);
    }

    static double terrainY(double x,double z){
        double distance=Math.abs(x-roadX(z));
        double blend=Math.min(1.0,Math.max(0.0,(distance-13.0)/48.0));
        double hills=2.8*Math.sin(x/135.0)*Math.cos(z/155.0)
                    +1.4*Math.sin(z/64.0+x/98.0);
        return blend*hills;
    }

    static int clamp(int value,int lo,int hi){return Math.max(lo,Math.min(hi,value));}

    void step(int gas,int brake,int steering,boolean handbrake){
        gas=clamp(gas,0,1000);brake=clamp(brake,0,1000);
        steering=clamp(steering,-1000,1000);
        long beforeZ=zMm,beforeX=xMm;
        offRoad=Math.abs(xMm/1000.0-roadX(zMm/1000.0))>10.5;

        int acceleration=gas*10000/1000;
        int braking=brake*21000/1000;
        int resistance=420+(int)(((long)speedMmps*speedMmps)/1_700_000L);
        if(offRoad)resistance+=5000;
        if(handbrake)resistance+=3300;
        int increment=(acceleration-braking-resistance)*TICK_MS/1000;
        speedMmps=clamp(speedMmps+increment,0,MAX_SPEED_MMPS);

        int turn=(int)((long)steering*Math.min(speedMmps,35000)*TICK_MS/2_800_000L);
        if(handbrake)turn=turn*16/10;
        yaw16=(yaw16+turn)&(ANGLE_STEPS-1);

        // Low grip permits real lateral motion independent of the nose heading.
        // All evolving quantities are integers: reproducible on every host.
        int desiredSlide=(int)((long)steering*speedMmps*(handbrake?340:58)/1_000_000L);
        int response=handbrake?135:offRoad?100:290;
        slipMmps=clamp(slipMmps+(desiredSlide-slipMmps)*response/1000,-26000,26000);
        if(speedMmps<1000)slipMmps=0;

        int index=yaw16>>>4,fraction=yaw16&15;
        long sin=((long)SIN[index]*(16-fraction)+(long)SIN[index+1]*fraction)/16;
        long cos=((long)COS[index]*(16-fraction)+(long)COS[index+1]*fraction)/16;
        long forward=(long)speedMmps*TICK_MS/1000;
        long lateral=(long)slipMmps*TICK_MS/1000;
        xMm+=(forward*sin+lateral*cos)/TRIG;
        zMm+=(-forward*cos+lateral*sin)/TRIG;
        offRoad=Math.abs(xMm/1000.0-roadX(zMm/1000.0))>10.5;

        if(!finished)elapsedMs+=TICK_MS;
        if(!finished&&checkpoint<GATES.length){
            int gate=GATES[checkpoint];
            long gateMm=gate*1000L;
            if(beforeZ>gateMm&&zMm<=gateMm){
                // Intersect the *swept* vehicle trajectory with the gate plane.
                // Evaluating only the new end point could award a missed gate.
                double t=(double)(beforeZ-gateMm)/(beforeZ-zMm);
                double crossingX=(beforeX+t*(xMm-beforeX))/1000.0;
                if(Math.abs(crossingX-roadX(gate))<=15.0){
                    checkpoint++;
                    if(checkpoint==GATES.length){finished=true;finishMs=elapsedMs;}
                }
            }
        }
    }

    double speedKmh(){return speedMmps*0.0036;}
    double headingRadians(){return yaw16*(2.0*Math.PI/ANGLE_STEPS);}
    int checkpointCount(){return GATES.length;}
    int nextGateZ(){return GATES[Math.min(checkpoint,GATES.length-1)];}
    int lateralSlipMmps(){return slipMmps;}
    double progressKm(){return Math.max(0.0,(1100_000L-zMm)/1_000_000.0);}
}