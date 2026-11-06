package com.reversepc.os;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/** A qSSD state identity and one explicit, VM-owned physical API projection. */
final class XiSharedGeometryPacket {
    final String output;
    final ByteBuffer frame;
    final long publication,identity,revision,materializedBytes;
    final boolean executed;
    XiSharedGeometryPacket(String output,ByteBuffer frame,long publication,long identity,long revision,long materializedBytes,boolean executed){
        if(output==null||output.length()>65536||frame==null||!frame.isDirect()||!frame.isReadOnly()||frame.position()!=0||
           frame.limit()<2064||frame.limit()>2064+8192*60||publication<0||identity<=0||revision<=0||
           (materializedBytes!=0&&materializedBytes!=frame.limit()))
            throw new IllegalArgumentException("Invalid qSSD shared geometry projection");
        this.output=output;this.frame=frame.order(ByteOrder.LITTLE_ENDIAN);this.publication=publication;
        this.identity=identity;this.revision=revision;this.materializedBytes=materializedBytes;this.executed=executed;
    }
}
