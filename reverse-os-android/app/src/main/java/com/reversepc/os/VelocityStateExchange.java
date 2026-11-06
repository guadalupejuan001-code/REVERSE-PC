package com.reversepc.os;

/** One atomic publication of a validated RVPC2 state and its matching observation.
 * Published byte arrays are exclusively owned and never mutated. JNI copies its
 * input before execution. Readers retain a completed publication without taking
 * the writer's transaction monitor or copying the entire world again.
 */
final class VelocityStateExchange<T> {
    static final class Entry<T> {
        final byte[] state;
        final T observation;
        Entry(byte[] state,T observation){this.state=state;this.observation=observation;}
    }
    private volatile Entry<T> published;
    void publish(byte[] state,T observation){
        if(state==null||observation==null)throw new IllegalArgumentException("Incomplete XI publication");
        published=new Entry<>(state,observation);
    }
    Entry<T> read(){
        Entry<T> value=published;
        if(value==null)throw new IllegalStateException("XI state has not been published");
        return value;
    }
}
