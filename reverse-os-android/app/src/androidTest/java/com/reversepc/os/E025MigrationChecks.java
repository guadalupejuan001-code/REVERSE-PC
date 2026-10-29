package com.reversepc.os;

import android.content.Context;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.Arrays;
import org.json.JSONObject;

/** Real JNI migration checks in a disposable installation, before UI tests. */
final class E025MigrationChecks {
    private static int checks;
    private static void require(boolean value,String message)throws Exception{
        if(!value)throw new Exception(message);checks++;
    }
    private static File record(Context context,byte[] executable)throws Exception{
        return new File(context.getFilesDir(),"rxe-apps/"+BbyqInterface.identity(executable)+"/session.rxas");
    }
    static int run(Context target,Context test)throws Exception{
        checks=0;
        byte[] legacy=BbyqInterface.asset(test,"legacy-BBY-Q.rxe");
        byte[] current=BbyqInterface.asset(target,"native-apps/BBY-Q.rxe");
        WorkspaceFiles files=new WorkspaceFiles(target.getFilesDir());
        files.write(WorkbenchPrograms.BBYQ,legacy,false);
        RxeAppStore oldStore=new RxeAppStore(target,legacy);
        RxeAppStore.Saved taught=oldStore.ask(legacy,"aprende que qelora es animal",1);
        require(taught.history.length()==2,"Legacy learning did not commit");
        byte[] oldRecord=Files.readAllBytes(record(target,legacy).toPath());
        new WorkbenchPrograms(target);
        require(Arrays.equals(files.read(WorkbenchPrograms.BBYQ),current),"Known E023 image was not upgraded");
        RxeAppStore currentStore=new RxeAppStore(target,current);
        RxeAppStore.Saved migrated=currentStore.load(current);
        require(migrated.history.toString().equals(taught.history.toString()),"Migration replaced the transcript");
        require(migrated.language==taught.language,"Migration replaced the language");
        ResultPacket answer=ResultPacket.parse(NativeRuntime.appTurn(migrated.state,current,"que es qelora".getBytes(StandardCharsets.UTF_8),1));
        require(answer.output.contains("Qelora")&&answer.output.contains("animal"),"Live user learning was lost");
        require(Arrays.equals(oldRecord,Files.readAllBytes(record(target,legacy).toPath())),"Rollback memory was modified");
        byte[] before=Files.readAllBytes(record(target,current).toPath());
        new WorkbenchPrograms(target);
        require(Arrays.equals(before,Files.readAllBytes(record(target,current).toPath())),"Migration is not idempotent");
        boolean rejected=false;
        try{currentStore.migrate(current,taught,NativeRuntime.appSeed(current));}catch(Exception conflict){rejected=true;}
        require(rejected,"An unrelated destination session was accepted");
        require(Arrays.equals(before,Files.readAllBytes(record(target,current).toPath())),"Destination conflict overwrote data");

        // A user-owned reservation in the new region cannot be replaced.
        ResultPacket oldPacket=ResultPacket.parse(oldRecord);
        byte[] conflict=ResultPacket.parse(NativeRuntime.execute(oldPacket.state,"#!reverse-pc-machine-v1\nstore8 8600000000000000000 2\nhalt\n")).state;
        byte[] conflictRecord=ResultPacket.encode(oldPacket.output,conflict);
        Files.write(record(target,legacy).toPath(),conflictRecord);
        files.write(WorkbenchPrograms.BBYQ,legacy,true);
        new WorkbenchPrograms(target);
        require(Arrays.equals(files.read(WorkbenchPrograms.BBYQ),legacy),"Conflicting legacy image was replaced");
        require(Arrays.equals(conflictRecord,Files.readAllBytes(record(target,legacy).toPath())),"Conflict changed legacy data");

        JSONObject metadata=new JSONObject(oldPacket.output).put("version",2).put("pending_action",new JSONObject().put("ticket",java.util.UUID.randomUUID().toString()).put("op",4).put("target",2).put("view","migration-test"));
        byte[] pendingRecord=ResultPacket.encode(metadata.toString(),oldPacket.state);
        Files.write(record(target,legacy).toPath(),pendingRecord);
        new WorkbenchPrograms(target);
        require(Arrays.equals(files.read(WorkbenchPrograms.BBYQ),legacy),"Pending action was discarded by migration");
        require(Arrays.equals(pendingRecord,Files.readAllBytes(record(target,legacy).toPath())),"Pending transaction changed");
        // An installed E025 state upgrades with its personal facts and history.
        byte[] e025=BbyqInterface.asset(test,"legacy-e025-BBY-Q.rxe");
        RxeAppStore prior=new RxeAppStore(target,e025);
        RxeAppStore.Saved learned=prior.ask(e025,"aprende que xelora es animal",1);
        require(learned.history.length()==2,"E025 learning did not commit");
        // Reuse a clean target identity for this independent migration case.
        java.nio.file.Files.deleteIfExists(record(target,current).toPath());
        files.write(WorkbenchPrograms.BBYQ,e025,true);
        byte[] savedE025=Files.readAllBytes(record(target,e025).toPath());
        new WorkbenchPrograms(target);
        require(Arrays.equals(files.read(WorkbenchPrograms.BBYQ),current),"E025 was not upgraded to X01");
        RxeAppStore.Saved personalized=currentStore.load(current);
        require(personalized.history.toString().equals(learned.history.toString()),"X01 replaced E025 history");
        ResultPacket retained=ResultPacket.parse(NativeRuntime.appTurn(personalized.state,current,"que es xelora".getBytes(StandardCharsets.UTF_8),1));
        require(retained.output.contains("animal"),"X01 lost prior E025 knowledge");
        ResultPacket greeting=ResultPacket.parse(NativeRuntime.appTurn(personalized.state,current,"hola".getBytes(StandardCharsets.UTF_8),1));
        require(greeting.output.equals("Hola, X. Te leo."),"X01 is missing from upgraded app");
        require(Arrays.equals(savedE025,Files.readAllBytes(record(target,e025).toPath())),"X01 changed rollback state");
        return checks;
    }
}
