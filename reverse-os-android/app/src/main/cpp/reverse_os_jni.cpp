#include "session.hpp"
#include "rxe.hpp"
#include "rxe_app.hpp"
#include "integration/readonly_geometry.hpp"
#include "integration/xi_live_session.hpp"
#include <jni.h>
#include <exception>
#include <limits>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>
#include <unordered_map>
#include <cstring>
namespace {
std::vector<std::uint8_t> bytes(JNIEnv* e,jbyteArray value) {
  if(!value)return {};
  const jsize n=e->GetArrayLength(value);
  if(n<0||std::size_t(n)>reverse_os::max_state+29)
    throw std::length_error("Android state exceeds transport budget");
  std::vector<std::uint8_t> out(static_cast<std::size_t>(n));
  if(n)e->GetByteArrayRegion(value,0,n,reinterpret_cast<jbyte*>(out.data()));
  if(e->ExceptionCheck())throw std::runtime_error("JNI state read failed");
  return out;
}
jbyteArray output(JNIEnv* e,const std::vector<std::uint8_t>& v){
  if(v.size()>std::size_t(std::numeric_limits<jsize>::max()))throw std::length_error("JNI result too long");
  jbyteArray arr=e->NewByteArray(jsize(v.size()));
  if(arr&&!v.empty())e->SetByteArrayRegion(arr,0,jsize(v.size()),reinterpret_cast<const jbyte*>(v.data()));
  return arr;
}
// Read-only XI image observation: write the interpreter's binary result
// directly into the JNI output. No RXOS1 envelope, copied state, or temporary
// uint8 vector. Java owns the resulting fresh array exclusively.
jbyteArray output_frame(JNIEnv* e,const std::string& frame){
  if(frame.size()>std::size_t(std::numeric_limits<jsize>::max()))
    throw std::length_error("XI observation exceeds JNI array limit");
  jbyteArray arr=e->NewByteArray(jsize(frame.size()));
  if(arr&&!frame.empty())
    e->SetByteArrayRegion(arr,0,jsize(frame.size()),
       reinterpret_cast<const jbyte*>(frame.data()));
  return arr;
}
std::string source(JNIEnv* e,jstring text){
  if(!text)throw std::invalid_argument("XI program missing");
  const char* chars=e->GetStringUTFChars(text,nullptr);
  if(!chars)throw std::runtime_error("JNI string unavailable");
  std::string s(chars);e->ReleaseStringUTFChars(text,chars);
  if(s.size()>16*1024*1024)throw std::length_error("XI program too large");
  return s;
}
void throw_java(JNIEnv* e,const std::exception& err){
  if(e->ExceptionCheck())return;
  auto cls=e->FindClass("java/lang/IllegalStateException");
  if(cls)e->ThrowNew(cls,err.what());
}
std::mutex sessions_mutex;
struct LiveSessionEntry {
  std::shared_ptr<reverse_pc::XiLiveSession> live;
  std::mutex projection_mutex;
  JavaVM* vm=nullptr;
  jclass buffer_class=nullptr,packet_class=nullptr;
  jmethodID allocate=nullptr,readonly=nullptr,packet_ctor=nullptr;
  jweak projected=nullptr;
  std::uint64_t identity=0,revision=0;
  LiveSessionEntry(JNIEnv* env,const std::vector<std::uint8_t>& initial)
      :live(std::make_shared<reverse_pc::XiLiveSession>(initial)) {
    if(env->GetJavaVM(&vm)!=JNI_OK)throw std::runtime_error("JNI VM is unavailable");
    try{
      auto buffer=env->FindClass("java/nio/ByteBuffer");
      auto packet=env->FindClass("com/reversepc/os/XiSharedGeometryPacket");
      if(!buffer||!packet)throw std::runtime_error("qSSD projection classes unavailable");
      buffer_class=static_cast<jclass>(env->NewGlobalRef(buffer));
      packet_class=static_cast<jclass>(env->NewGlobalRef(packet));
      if(!buffer_class||!packet_class)throw std::runtime_error("qSSD projection class reference failed");
      allocate=env->GetStaticMethodID(buffer_class,"allocateDirect","(I)Ljava/nio/ByteBuffer;");
      readonly=env->GetMethodID(buffer_class,"asReadOnlyBuffer","()Ljava/nio/ByteBuffer;");
      packet_ctor=env->GetMethodID(packet_class,"<init>","(Ljava/lang/String;Ljava/nio/ByteBuffer;JJJJZ)V");
      if(!allocate||!readonly||!packet_ctor)throw std::runtime_error("qSSD projection API unavailable");
    }catch(...){
      if(buffer_class)env->DeleteGlobalRef(buffer_class);
      if(packet_class)env->DeleteGlobalRef(packet_class);
      throw;
    }
  }
  ~LiveSessionEntry(){
    if(!vm)return;
    JNIEnv* env=nullptr;bool attached=false;
    const auto status=vm->GetEnv(reinterpret_cast<void**>(&env),JNI_VERSION_1_6);
    if(status==JNI_EDETACHED){
#ifdef __ANDROID__
      if(vm->AttachCurrentThread(&env,nullptr)!=JNI_OK)return;
#else
      if(vm->AttachCurrentThread(reinterpret_cast<void**>(&env),nullptr)!=JNI_OK)return;
#endif
      attached=true;
    }else if(status!=JNI_OK)return;
    if(projected)env->DeleteWeakGlobalRef(projected);
    if(buffer_class)env->DeleteGlobalRef(buffer_class);
    if(packet_class)env->DeleteGlobalRef(packet_class);
    if(attached)vm->DetachCurrentThread();
  }
};
std::unordered_map<jlong,std::shared_ptr<LiveSessionEntry>> sessions;
jlong next_session=1;
std::shared_ptr<LiveSessionEntry> session_entry(jlong handle){
  std::lock_guard<std::mutex> lock(sessions_mutex);
  const auto found=sessions.find(handle);
  if(found==sessions.end())throw std::invalid_argument("XI session is closed");
  return found->second;
}
std::shared_ptr<reverse_pc::XiLiveSession> session(jlong handle){return session_entry(handle)->live;}
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_initialize(JNIEnv* e,jclass){
  try{return output(e,reverse_os::save(reverse_os::Runtime{}));}
  catch(const std::exception& x){throw_java(e,x);return nullptr;}
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_execute(JNIEnv* e,jclass,jbyteArray state,jstring text){
  try{
    auto runtime=reverse_os::restore(bytes(e,state));
    const auto lines=runtime.execute(source(e,text));
    return output(e,reverse_os::packet(lines,reverse_os::save(runtime)));
  }catch(const std::exception& x){throw_java(e,x);return nullptr;}
}
// One-shot immutable observation. The renderer executes the exact same XI
// program against a private restored RVPC2 snapshot as execute(), but its
// candidate state is deliberately discarded. Only original XFS1/XFB5 bytes
// cross JNI; no engine equations, pixels or materials are implemented here.
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_observeFrame(JNIEnv* e,jclass,
    jbyteArray state,jstring text){
  try{
    auto runtime=reverse_os::restore(bytes(e,state));
    const auto frame=runtime.execute(source(e,text));
    // Reject text/unknown opcodes on this high-throughput binary-only path.
    // Frame headers are fully checked by RegraphicsFrame after JNI transfer.
    if(frame.size()<4 || (frame.compare(0,4,"XFS1")!=0 &&
                          frame.compare(0,4,"XFB5")!=0))
      throw std::invalid_argument("Read-only XI observation requires XFS1/XFB5 output");
    return output_frame(e,frame);
  }catch(const std::exception& x){throw_java(e,x);return nullptr;}
}

extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_observeGeometry(JNIEnv* e,jclass,
    jbyteArray state,jstring text,jintArray addresses,jbyteArray values){
  try{
    if(!addresses||!values)throw std::invalid_argument("Geometry input mailbox missing");
    const auto count=e->GetArrayLength(addresses);
    if(count<0||count>32||e->GetArrayLength(values)!=count)
      throw std::invalid_argument("Geometry input mailbox bounds");
    std::vector<jint> indices(count);std::vector<jbyte> data(count);
    if(count){e->GetIntArrayRegion(addresses,0,count,indices.data());e->GetByteArrayRegion(values,0,count,data.data());}
    if(e->ExceptionCheck())throw std::runtime_error("Geometry inputs could not be read");
    std::vector<std::pair<std::uint32_t,std::uint8_t>> inputs;inputs.reserve(count);
    for(int i=0;i<count;i++){
      if(indices[i]<0)throw std::invalid_argument("Geometry input address must be nonnegative");
      inputs.emplace_back(static_cast<std::uint32_t>(indices[i]),static_cast<std::uint8_t>(data[i]));
    }
    return output_frame(e,reverse_pc::observe_geometry(bytes(e,state),source(e,text),inputs));
  }catch(const std::exception& x){throw_java(e,x);return nullptr;}
}

extern "C" JNIEXPORT jlong JNICALL
Java_com_reversepc_os_NativeRuntime_sessionOpen(JNIEnv* e,jclass,jbyteArray state){
  try{
    auto value=std::make_shared<LiveSessionEntry>(e,bytes(e,state));
    std::lock_guard<std::mutex> lock(sessions_mutex);
    if(sessions.size()>=64||next_session==std::numeric_limits<jlong>::max())
      throw std::length_error("XI live session budget");
    const auto handle=next_session++;sessions.emplace(handle,std::move(value));return handle;
  }catch(const std::exception& x){throw_java(e,x);return 0;}
}
extern "C" JNIEXPORT void JNICALL
Java_com_reversepc_os_NativeRuntime_sessionClose(JNIEnv*,jclass,jlong handle){
  std::lock_guard<std::mutex> lock(sessions_mutex);sessions.erase(handle);
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_sessionStage(JNIEnv* e,jclass,jlong handle,jstring text){
  try{return output_frame(e,session(handle)->stage(source(e,text)));}
  catch(const std::exception& x){throw_java(e,x);return nullptr;}
}
extern "C" JNIEXPORT jlong JNICALL
Java_com_reversepc_os_NativeRuntime_sessionCommit(JNIEnv* e,jclass,jlong handle){
  try{return static_cast<jlong>(session(handle)->commit());}
  catch(const std::exception& x){throw_java(e,x);return 0;}
}
extern "C" JNIEXPORT void JNICALL
Java_com_reversepc_os_NativeRuntime_sessionDiscard(JNIEnv* e,jclass,jlong handle){
  try{session(handle)->discard();}catch(const std::exception& x){throw_java(e,x);}
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_sessionObserve(JNIEnv* e,jclass,jlong handle,
    jstring text,jintArray addresses,jbyteArray values){
  try{
    if(!addresses||!values)throw std::invalid_argument("XI input mailbox missing");
    const auto count=e->GetArrayLength(addresses);
    if(count>32||e->GetArrayLength(values)!=count)throw std::length_error("XI input mailbox bounds");
    std::vector<jint> indices(count);std::vector<jbyte> data(count);
    if(count){e->GetIntArrayRegion(addresses,0,count,indices.data());e->GetByteArrayRegion(values,0,count,data.data());}
    if(e->ExceptionCheck())throw std::runtime_error("XI inputs could not be read");
    reverse_pc::XiLiveSession::Inputs inputs;
    for(int i=0;i<count;i++){
      if(indices[i]<0)throw std::invalid_argument("XI input address must be nonnegative");
      inputs.emplace_back(std::to_string(indices[i]),static_cast<std::uint8_t>(data[i]));
    }
    auto observed=session(handle)->observe(source(e,text),inputs);
    const auto& frame=observed.frame;
    if(frame.size()<4||(frame.compare(0,4,"XFG4")&&frame.compare(0,4,"XFB5")&&frame.compare(0,4,"XFS1")))
      throw std::invalid_argument("XI session observation requires original frame bytes");
    if(frame.size()>40u*1024*1024||observed.output.size()>64u*1024)
      throw std::length_error("XI observation packet budget");
    std::vector<std::uint8_t> packet{'X','I','O','2'};
    reverse_os::put32(packet,observed.output.size());reverse_os::put32(packet,frame.size());
    reverse_os::put64(packet,observed.generation);
    packet.insert(packet.end(),observed.output.begin(),observed.output.end());
    packet.insert(packet.end(),frame.begin(),frame.end());
    return output(e,packet);
  }catch(const std::exception& x){throw_java(e,x);return nullptr;}
}

extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_sessionObserveGeometryDelta(JNIEnv* e,jclass,jlong handle,
    jstring text,jintArray addresses,jbyteArray values){
  try{
    if(!addresses||!values)throw std::invalid_argument("XI input mailbox missing");
    const auto count=e->GetArrayLength(addresses);
    if(count>32||e->GetArrayLength(values)!=count)throw std::length_error("XI input mailbox bounds");
    std::vector<jint> indices(count);std::vector<jbyte> data(count);
    if(count){e->GetIntArrayRegion(addresses,0,count,indices.data());e->GetByteArrayRegion(values,0,count,data.data());}
    if(e->ExceptionCheck())throw std::runtime_error("XI inputs could not be read");
    reverse_pc::XiLiveSession::Inputs inputs;inputs.reserve(count);
    for(int i=0;i<count;i++){
      if(indices[i]<0)throw std::invalid_argument("XI input address must be nonnegative");
      inputs.emplace_back(std::to_string(indices[i]),static_cast<std::uint8_t>(data[i]));
    }
    return output(e,session(handle)->observeGeometryDelta(source(e,text),inputs));
  }catch(const std::exception& x){throw_java(e,x);return nullptr;}
}

// A producer moves between bounded workers when the graphics backend changes.
// Release only this idle thread's immutable parsed instructions, never state.
extern "C" JNIEXPORT void JNICALL
Java_com_reversepc_os_NativeRuntime_releaseThreadScratch(JNIEnv*,jclass){
  mundo_x::infinite_program_detail::machine_parse_cache_state().program.reset();
}

extern "C" JNIEXPORT void JNICALL
Java_com_reversepc_os_NativeRuntime_sessionSetGeometryProgram(JNIEnv* e,jclass,jlong handle,jstring text){
  try{session(handle)->registerGeometryProgram(source(e,text));}
  catch(const std::exception& x){throw_java(e,x);}
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_sessionObservePreparedGeometry(JNIEnv* e,jclass,jlong handle,
    jintArray addresses,jbyteArray values){
  try{
    if(!addresses||!values)throw std::invalid_argument("XI input mailbox missing");
    const auto count=e->GetArrayLength(addresses);
    if(count>32||e->GetArrayLength(values)!=count)throw std::length_error("XI input mailbox bounds");
    std::vector<jint> indices(count);std::vector<jbyte> data(count);
    if(count){e->GetIntArrayRegion(addresses,0,count,indices.data());e->GetByteArrayRegion(values,0,count,data.data());}
    if(e->ExceptionCheck())throw std::runtime_error("XI inputs could not be read");
    reverse_pc::XiLiveSession::Inputs inputs;inputs.reserve(count);
    for(int i=0;i<count;i++){
      if(indices[i]<0)throw std::invalid_argument("XI input address must be nonnegative");
      inputs.emplace_back(std::to_string(indices[i]),static_cast<std::uint8_t>(data[i]));
    }
    return output(e,session(handle)->observePreparedGeometry(inputs));
  }catch(const std::exception& x){throw_java(e,x);return nullptr;}
}

// Java allocates the physical projection, so the VM owns its lifetime. Native
// qSSD caches only a weak reference: closing a session cannot free memory still
// read by an old Java/GPU observation, and the cache cannot pin dead projections.
extern "C" JNIEXPORT jobject JNICALL
Java_com_reversepc_os_NativeRuntime_sessionObserveSharedGeometry(JNIEnv* e,jclass,jlong handle,
    jintArray addresses,jbyteArray values){
  try{
    if(!addresses||!values)throw std::invalid_argument("XI input mailbox missing");
    const auto count=e->GetArrayLength(addresses);
    if(count>32||e->GetArrayLength(values)!=count)throw std::length_error("XI input mailbox bounds");
    std::vector<jint> indices(count);std::vector<jbyte> data(count);
    if(count){e->GetIntArrayRegion(addresses,0,count,indices.data());e->GetByteArrayRegion(values,0,count,data.data());}
    if(e->ExceptionCheck())throw std::runtime_error("XI inputs could not be read");
    reverse_pc::XiLiveSession::Inputs inputs;inputs.reserve(count);
    for(int i=0;i<count;i++){
      if(indices[i]<0)throw std::invalid_argument("XI input address must be nonnegative");
      inputs.emplace_back(std::to_string(indices[i]),static_cast<std::uint8_t>(data[i]));
    }
    auto entry=session_entry(handle);
    const auto observed=entry->live->observePreparedSharedGeometry(inputs);
    std::lock_guard<std::mutex> projection(entry->projection_mutex);
    const auto& frame=*observed.geometry.value;
    jobject view=nullptr;jlong materialized=0;
    if(entry->projected&&entry->identity==observed.geometry.identity&&entry->revision==observed.geometry.revision)
      view=e->NewLocalRef(entry->projected);
    if(e->ExceptionCheck())throw std::runtime_error("qSSD projection reference unavailable");
    if(!view){
      auto backing=e->CallStaticObjectMethod(entry->buffer_class,entry->allocate,static_cast<jint>(frame.size()));
      if(e->ExceptionCheck()||!backing)throw std::runtime_error("qSSD projection allocation failed");
      auto destination=e->GetDirectBufferAddress(backing);
      if(!destination||e->GetDirectBufferCapacity(backing)!=static_cast<jlong>(frame.size()))
        throw std::runtime_error("qSSD direct projection bounds");
      std::memcpy(destination,frame.data(),frame.size());
      view=e->CallObjectMethod(backing,entry->readonly);
      if(e->ExceptionCheck()||!view)throw std::runtime_error("qSSD read-only view failed");
      auto weak=e->NewWeakGlobalRef(view);
      if(!weak)throw std::runtime_error("qSSD weak projection reference failed");
      if(entry->projected)e->DeleteWeakGlobalRef(entry->projected);
      entry->projected=weak;entry->identity=observed.geometry.identity;entry->revision=observed.geometry.revision;
      materialized=static_cast<jlong>(frame.size());
    }
    auto text=e->NewStringUTF(observed.output.c_str());
    if(!text)throw std::runtime_error("qSSD observation text unavailable");
    return e->NewObject(entry->packet_class,entry->packet_ctor,text,view,static_cast<jlong>(observed.generation),
      static_cast<jlong>(observed.geometry.identity),static_cast<jlong>(observed.geometry.revision),
      materialized,observed.executed?JNI_TRUE:JNI_FALSE);
  }catch(const std::exception& x){throw_java(e,x);return nullptr;}
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_reversepc_os_NativeRuntime_inspect(JNIEnv* e,jclass,jbyteArray state){
  try{
    auto runtime=reverse_os::restore(bytes(e,state));
    const auto q=runtime.core().stats();
    const auto m=runtime.memory().stats();
    std::ostringstream s;
    s<<"{\"active_qubits\":"<<q.active_qubits
     <<",\"components\":"<<q.components
     <<",\"largest_component\":"<<q.largest_component
     <<",\"tableau_bytes\":"<<q.tableau_bytes
     <<",\"ether_rules\":"<<q.ether_rules
     <<",\"core_revision\":"<<q.revision
     <<",\"memory_revision\":"<<m.revision
     <<",\"memory_overrides\":"<<m.overrides
     <<",\"quantum_bindings\":"<<m.quantum_bindings
     <<",\"state_format\":\"RVPC2\"}";
    return e->NewStringUTF(s.str().c_str());
  }catch(const std::exception& x){throw_java(e,x);return nullptr;}
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_compileRxe(JNIEnv* e,jclass,jbyteArray program,jbyteArray title){
  try{const auto p=bytes(e,program),t=bytes(e,title);return output(e,reverse_pc::rxe::compile(std::string(p.begin(),p.end()),std::string(t.begin(),t.end())));}
  catch(const std::exception& x){throw_java(e,x);return nullptr;}
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_inspectRxe(JNIEnv* e,jclass,jbyteArray program){
  try{const auto image=bytes(e,program);const auto description=reverse_pc::rxe_app::has_magic(image)?reverse_pc::rxe_app::describe(image):reverse_pc::rxe::describe(image);return output(e,std::vector<std::uint8_t>(description.begin(),description.end()));}
  catch(const std::exception& x){throw_java(e,x);return nullptr;}
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_executeRxe(JNIEnv* e,jclass,jbyteArray state,jbyteArray program){
  try{const auto image=reverse_pc::rxe::decode(bytes(e,program));const auto source=reverse_pc::rxe::disassemble(image);auto runtime=reverse_os::restore(bytes(e,state));const auto lines=runtime.execute(source);return output(e,reverse_os::packet(lines,reverse_os::save(runtime)));}
  catch(const std::exception& x){throw_java(e,x);return nullptr;}
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_appSeed(JNIEnv* e,jclass,jbyteArray program){
  try{return output(e,reverse_pc::rxe_app::decode(bytes(e,program)).seed);}
  catch(const std::exception& x){throw_java(e,x);return nullptr;}
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_appTurn(JNIEnv* e,jclass,jbyteArray state,jbyteArray program,jbyteArray message,jint language){
  try{const auto text=bytes(e,message);const auto result=reverse_pc::rxe_app::turn(bytes(e,program),bytes(e,state),std::string(text.begin(),text.end()),unsigned(language));return output(e,reverse_os::packet(result.text,result.state));}
  catch(const std::exception& x){throw_java(e,x);return nullptr;}
}


// REVERSE VELOCITY is authored in XI/RXE. JNI only injects five bounded
// physical inputs, executes the owner's *existing* QuantumRuntime transaction
// and returns its original RXOS1 packet. No game physics in this adapter.
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeRuntime_velocityTick(
    JNIEnv* e,jclass,jbyteArray state,jbyteArray executable,
    jint gas,jint brake,jint steering,jint drift,jint reset){
  try{
    if(gas<0||gas>1||brake<0||brake>1||steering<0||steering>2||
       drift<0||drift>1||reset<0||reset>1)
      throw std::invalid_argument("XI velocity input out of bounds");
    const auto image=reverse_pc::rxe::decode(bytes(e,executable));
    const auto compiled=reverse_pc::rxe::disassemble(image);
    const std::string header=mundo_x::infinite_program_detail::machine_header;
    if(compiled.compare(0,header.size(),header)!=0||
       compiled.size()<=header.size()||compiled[header.size()]!='\n')
      throw std::invalid_argument("Velocity program requires XI Machine v1");
    const std::string input=
      header+"\nstore8 128 "+std::to_string(gas)+
      "\nstore8 129 "+std::to_string(brake)+
      "\nstore8 130 "+std::to_string(steering)+
      "\nstore8 131 "+std::to_string(drift)+
      "\nstore8 132 "+std::to_string(reset)+"\n";
    auto runtime=reverse_os::restore(bytes(e,state));
    const auto output_lines=runtime.execute(input+compiled.substr(header.size()+1));
    return output(e,reverse_os::packet(output_lines,reverse_os::save(runtime)));
  }catch(const std::exception& error){throw_java(e,error);return nullptr;}
}
