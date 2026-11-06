#!/usr/bin/env node
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const lock=JSON.parse(fs.readFileSync('docs/QSSD_INTEGRATION_LOCK.json','utf8'));
assert.equal(lock.repository,'guadalupejuan001-code/Virtual-qSSD-');
assert.equal(lock.commit,'4ee7c5c8c391c0096867669681700c50aaafea1f');
const source=fs.readFileSync(lock.vendoredPath);
assert.equal(crypto.createHash('sha256').update(source).digest('hex'),lock.sha256,'qSSD source differs from upstream pin');
if(process.argv[2])assert(source.equals(fs.readFileSync(path.join(process.argv[2],lock.upstreamPath))),'execute the exact upstream qSSD component');
const read=p=>fs.readFileSync(p,'utf8'),java='reverse-os-android/app/src/main/java/com/reversepc/os/';
const session=read('src/integration/xi_live_session.hpp'),jni=read('reverse-os-android/app/src/main/cpp/reverse_os_jni.cpp');
const engine=read(java+'VelocityXiEngine.java'),geometry=read(java+'RegraphicsGeometry.java'),packet=read(java+'XiSharedGeometryPacket.java');
assert(session.includes('qssd::SharedProjection<std::string>')&&session.includes('shared_geometry_.publish(std::move(frame))'),'original XI output must enter qSSD');
assert(session.includes('parsed->deterministic')&&session.includes('inputs==shared_inputs_')&&session.includes('retained->generation==shared_generation_'),'reuse requires the full state, exact program and mailbox');
assert(jni.includes('live->observePreparedSharedGeometry(inputs)')&&jni.includes('NewWeakGlobalRef(view)')&&jni.includes('std::memcpy(destination,frame.data(),frame.size())'),'JNI must expose the real, explicitly counted VM-owned projection');
assert(engine.includes('NativeRuntime.sessionObserveSharedGeometry(')&&engine.includes('RegraphicsGeometry.decodeShared(packet.frame)'),'qSSD must execute in the game rendering path');
assert(!engine.includes('sessionObservePreparedGeometry(')&&!engine.includes('new XiGeometryDeltaDecoder('),'production shared path must not reconstruct full delta arrays');
assert(geometry.includes('stream.update(source,categories,passes)')&&packet.includes('frame.isReadOnly()')&&packet.includes('materializedBytes'),'GPU consumes the shared source and physical materialization is visible');
console.log('VELOCITY_QSSD_LOCK_PASS '+JSON.stringify({commit:lock.commit,sha256:lock.sha256,baseline:lock.baselineVelocityCommit,projection:'VM-owned read-only buffer'}));
