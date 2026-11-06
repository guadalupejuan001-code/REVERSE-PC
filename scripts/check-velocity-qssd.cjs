#!/usr/bin/env node
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const lock=JSON.parse(fs.readFileSync('docs/QSSD_INTEGRATION_LOCK.json','utf8'));
assert.equal(lock.repository,'guadalupejuan001-code/Virtual-qSSD-');
assert.equal(lock.commit,'c9dc0ebf3370a4468e14df92fcebb2a90954c448');
for(const entry of lock.files){
 const value=fs.readFileSync(entry.vendoredPath);
 assert.equal(crypto.createHash('sha256').update(value).digest('hex'),entry.sha256,'qSSD complete-state source differs');
 if(process.argv[2])assert(value.equals(fs.readFileSync(path.join(process.argv[2],entry.upstreamPath))),'exact upstream C03 state bus must execute');
}
const source=fs.readFileSync(lock.vendoredPath);
assert.equal(crypto.createHash('sha256').update(source).digest('hex'),lock.sha256,'qSSD source differs from upstream pin');
if(process.argv[2])assert(source.equals(fs.readFileSync(path.join(process.argv[2],lock.upstreamPath))),'execute the exact upstream qSSD component');
const read=p=>fs.readFileSync(p,'utf8'),java='reverse-os-android/app/src/main/java/com/reversepc/os/';
const session=read('src/integration/xi_live_session.hpp'),jni=read('reverse-os-android/app/src/main/cpp/reverse_os_jni.cpp');
const engine=read(java+'VelocityXiEngine.java'),geometry=read(java+'RegraphicsGeometry.java'),packet=read(java+'XiSharedGeometryPacket.java');
assert(session.includes('qssd::SharedProjection<std::string>')&&session.includes('shared_geometry_.publish(std::move(frame))'),'original XI output must enter qSSD');
assert(session.includes('parsed->deterministic')&&session.includes('inputs==shared_inputs_')&&session.includes('retained==shared_cpu_'),'reuse requires the full state, exact program and mailbox');
assert(jni.includes('live->observePreparedSharedGeometry(inputs,quality,std::string(viewBytes.begin(),viewBytes.end()))')&&jni.includes('NewWeakGlobalRef(view)')&&jni.includes('std::memcpy(destination,frame.data(),frame.size())'),'JNI must expose the real, explicitly counted VM-owned projection');
assert(engine.includes('NativeRuntime.sessionObserveSharedGeometryView(')&&engine.includes('RegraphicsGeometry.decodeShared(packet.frame)'),'qSSD must execute in the game rendering path');
assert(!engine.includes('sessionObservePreparedGeometry(')&&!engine.includes('new XiGeometryDeltaDecoder('),'production shared path must not reconstruct full delta arrays');
assert(geometry.includes('stream.update(source,categories,passes)')&&packet.includes('frame.isReadOnly()')&&packet.includes('materializedBytes'),'GPU consumes the shared source and physical materialization is visible');
assert(session.includes('qssd::StateBus<XiSessionGraph>')&&session.includes('state.cpu=candidate')&&session.includes('state.gpu=capture')&&!session.includes('published_'),'complete qSSD bus must own the actual CPU and GPU graph');
assert(engine.includes('NativeRuntime.sessionRegisterResources(')&&engine.includes('driveXi=resourceText('),'CPU must consume resources from the state bus');
assert(read(java+'VelocityGpuSurface.java').includes('game.resourceText(name)'),'GPU shaders must be consumed from the same state bus');
assert(engine.includes('NativeRuntime.sessionCheckpointSpace(')&&engine.includes('NativeRuntime.sessionOpenSpace('),'complete persistence must execute in the game');
console.log('VELOCITY_QSSD_LOCK_PASS '+JSON.stringify({commit:lock.commit,sha256:lock.sha256,baseline:lock.baselineVelocityCommit,projection:'VM-owned read-only buffer'}));
