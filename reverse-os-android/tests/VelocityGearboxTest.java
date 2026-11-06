package com.reversepc.os;
public final class VelocityGearboxTest {
    static void check(boolean ok,String why){if(!ok)throw new AssertionError(why);}
    public static void main(String[] args){
        VelocityGearbox g=new VelocityGearbox();
        check(!g.isReverse()&&!g.isPending(),"forward default");
        g.request(true,3200);
        check(g.isPending()&&g.requestedReverse()&&!g.isReverse(),"request while moving is retained");
        for(int speed:new int[]{3200,1800,300,26}){
            int input=g.prepare(1|8|16|32|64,speed);
            check(input==10&&!g.isReverse(),"actual brake overrides held gas, boost and jump before shifting");
        }
        int reverse=g.prepare(1|8,25);
        check(reverse==(1|8|128)&&g.isReverse()&&!g.isPending(),"reverse engages once XI reports a stop");
        g.request(false,700);check(g.isPending()&&g.isReverse(),"forward also waits for stop");
        g.request(true,700);check(!g.isPending()&&g.isReverse(),"a second request cancels the pending change");
        g.request(false,0);check(!g.isReverse()&&!g.isPending(),"stationary selector is immediate, including while paused");
        g.request(true,100);g.reset();check(!g.isReverse()&&!g.isPending()&&g.prepare(1,0)==1,"restart clears all gear requests");
        System.out.println("VELOCITY_GEARBOX_PASS requestedBrakeThenReverse=true");
    }
}
