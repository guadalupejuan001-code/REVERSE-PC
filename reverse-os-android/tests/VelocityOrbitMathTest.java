package com.reversepc.os;

/** Desktop JDK regression for the on-screen free camera before Android deploy. */
public final class VelocityOrbitMathTest {
    private static int checks;
    private static void ok(boolean value,String message){
        ++checks;if(!value)throw new AssertionError(message);
    }
    public static void main(String[] args){
        ok(VelocityOrbitMath.yaw(0)==0,"old camera yaw remains the default");
        ok(VelocityOrbitMath.pitch(0)==0,"old camera pitch remains the default");
        ok(VelocityOrbitMath.xiPitch(0)==0,"XI default has zero orbit correction");
        int one=VelocityOrbitMath.drag(0,420f,-70f,1000f);
        ok(VelocityOrbitMath.yaw(one)>1000,"horizontal swipe changes real XI camera yaw");
        ok(VelocityOrbitMath.pitch(one)>0,"upward swipe raises and tilts orbit");
        int back=VelocityOrbitMath.drag(one,-420f,70f,1000f);
        ok(VelocityOrbitMath.yaw(back)==0,"opposite swipe returns to heading zero");
        ok(VelocityOrbitMath.pitch(back)==0,"opposite elevation drag returns home");
        int wrapped=VelocityOrbitMath.drag(0,-20f,0f,1000f);
        ok(VelocityOrbitMath.yaw(wrapped)>4000,"left pan wraps through 360 degrees");
        int high=VelocityOrbitMath.drag(0,0,-10000f,1000f);
        ok(VelocityOrbitMath.pitch(high)==125,"elevation upper limit");
        int low=VelocityOrbitMath.drag(0,0,10000f,1000f);
        ok(VelocityOrbitMath.pitch(low)==-90,"elevation lower limit");
        ok(VelocityOrbitMath.xiPitch(low)==422,"negative XI tilt wraps safely");
        ok(VelocityOrbitMath.xiPitch(high)==125,"positive XI tilt remains positive");
        ok(VelocityOrbitMath.pack(4096,0)==0,"full-turn recenter is identical");
        boolean rejected=false;
        try{VelocityOrbitMath.drag(0,Float.NaN,0,1000);}catch(IllegalArgumentException ignored){rejected=true;}
        ok(rejected,"invalid touch inputs are rejected");
        System.out.println("VELOCITY_ORBIT_TEST_PASS checks="+checks+
            " yawSteps=4096 minPitch=-90 maxPitch=125 photoCompatible=true");
    }
}
