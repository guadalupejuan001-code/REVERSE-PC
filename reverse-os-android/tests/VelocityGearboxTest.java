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
        g.shift(-1,4);check(g.forwardSelection()==3,"manual downshift starts from the actual XI gear");
        g.shift(1,4);check(g.forwardSelection()==4,"subsequent manual shifts use the requested selection");
        for(int i=0;i<10;i++)g.shift(1,4);check(g.forwardSelection()==6,"upper gear bound");
        for(int i=0;i<10;i++)g.shift(-1,4);check(g.forwardSelection()==1,"lower gear bound");
        g.restore(0,-1,3);check(g.checkpoint()[2]==3,"manual selector round trip");g.automatic();check(g.forwardSelection()==0,"automatic return");
        System.out.println("VELOCITY_GEARBOX_PASS requestedBrakeThenReverse=true");
    }
}
