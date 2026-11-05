package com.reversepc.os;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

public final class VelocityStateExchangeTest {
    static void check(boolean ok,String why){if(!ok)throw new AssertionError(why);}
    public static void main(String[] args)throws Exception{
        VelocityStateExchange<Integer> exchange=new VelocityStateExchange<>();
        byte[] initial={7};exchange.publish(initial,7);
        VelocityStateExchange.Entry<Integer> retained=exchange.read();
        Object writerMonitor=exchange;
        CountDownLatch writing=new CountDownLatch(1),release=new CountDownLatch(1);
        AtomicReference<Throwable> failure=new AtomicReference<>();
        Thread writer=new Thread(()->{
            try{synchronized(writerMonitor){writing.countDown();release.await();}}
            catch(Throwable error){failure.set(error);}
        });
        writer.start();check(writing.await(2,TimeUnit.SECONDS),"writer reached transaction");
        Thread reader=new Thread(()->{
            try{check(exchange.read()==retained,"reader sees last complete publication during a writer transaction");}
            catch(Throwable error){failure.set(error);}
        });
        reader.start();reader.join(1000);
        boolean blocked=reader.isAlive();release.countDown();writer.join(2000);reader.join(2000);
        check(!blocked,"render/HUD reader must not wait for the physics transaction");
        Thread publisher=new Thread(()->{for(int i=0;i<100000;i++)exchange.publish(new byte[]{(byte)i},i);});
        publisher.start();
        int observations=0;
        do{
            VelocityStateExchange.Entry<Integer> view=exchange.read();
            check(view.state[0]==(byte)(int)view.observation,"RVPC2 bytes and observation must come from the same publication");observations++;
        }while(publisher.isAlive());
        publisher.join();
        check(retained.state==initial&&retained.state[0]==7&&retained.observation==7,"an older retained state stays intact");
        if(failure.get()!=null)throw new AssertionError(failure.get());
        System.out.println("VELOCITY_STATE_EXCHANGE_PASS publications=100000 observations="+observations+" readerBlocked=false");
    }
}
