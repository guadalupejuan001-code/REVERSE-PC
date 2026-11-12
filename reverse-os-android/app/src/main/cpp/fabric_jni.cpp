#include "reverse_fabric.hpp"

#include <jni.h>
#include <array>
#include <cstdint>
#include <limits>
#include <map>
#include <memory>
#include <mutex>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace {
std::mutex registry_lock;
std::map<jlong,std::shared_ptr<reverse_fabric::Fabric>> registry;
jlong next_id=1;

std::string text(JNIEnv* env,jstring value,std::size_t max_bytes){
  if(!value)throw std::invalid_argument("missing fabric string");
  const jsize size=env->GetStringLength(value);
  if(size<0||std::size_t(size)>max_bytes)
    throw std::length_error("fabric request exceeds source limit");
  const char* pointer=env->GetStringUTFChars(value,nullptr);
  if(!pointer)throw std::runtime_error("fabric JNI text unavailable");
  std::string result(pointer);
  env->ReleaseStringUTFChars(value,pointer);
  if(result.size()>max_bytes)throw std::length_error("fabric encoded text exceeds budget");
  return result;
}
std::vector<std::uint8_t> byte_array(JNIEnv* env,jbyteArray value){
  if(!value)throw std::invalid_argument("missing RVPC2 state");
  const jsize n=env->GetArrayLength(value);
  if(n<0||std::size_t(n)>32*1024*1024+29)
    throw std::length_error("RVPC2 state exceeds REVERSE budget");
  std::vector<std::uint8_t> out(std::size_t(n));
  if(n)env->GetByteArrayRegion(value,0,n,reinterpret_cast<jbyte*>(out.data()));
  if(env->ExceptionCheck())throw std::runtime_error("unable to read RVPC2 state");
  return out;
}
jbyteArray bytes(JNIEnv* env,const std::vector<std::uint8_t>& src){
  if(src.size()>std::size_t(std::numeric_limits<jsize>::max()))
    throw std::length_error("fabric packet too large");
  auto out=env->NewByteArray(jsize(src.size()));
  if(!out)throw std::runtime_error("fabric JVM allocation failed");
  if(!src.empty())env->SetByteArrayRegion(out,0,jsize(src.size()),reinterpret_cast<const jbyte*>(src.data()));
  return out;
}
std::string cleared_error(JNIEnv* env){
  if(!env->ExceptionCheck())return {};
  jthrowable error=env->ExceptionOccurred();
  env->ExceptionClear();
  if(!error)return "native runtime rejected the request";
  jclass cls=env->GetObjectClass(error);
  const auto method=cls?env->GetMethodID(cls,"getMessage","()Ljava/lang/String;"):nullptr;
  auto msg=method?static_cast<jstring>(env->CallObjectMethod(error,method)):nullptr;
  if(env->ExceptionCheck())env->ExceptionClear();
  std::string result="native runtime rejected the request";
  if(msg){
    const char* p=env->GetStringUTFChars(msg,nullptr);
    if(p){result=p;env->ReleaseStringUTFChars(msg,p);}
    if(env->ExceptionCheck())env->ExceptionClear();
    env->DeleteLocalRef(msg);
  }
  if(cls)env->DeleteLocalRef(cls);
  env->DeleteLocalRef(error);
  return result;
}
void require_success(JNIEnv* env,const char* operation) {
  const auto error=cleared_error(env);
  if(!error.empty())throw std::runtime_error(std::string(operation)+": "+error);
}

struct StateBridge {
  JNIEnv* env;
  jclass cls=nullptr;
  jmethodID execute=nullptr,read=nullptr,write=nullptr;
  jbyteArray state=nullptr;

  StateBridge(JNIEnv* e,jbyteArray original):env(e){
    cls=env->FindClass("com/reversepc/os/NativeRuntime");
    require_success(env,"find canonical RVPC2 runtime");
    if(!cls)throw std::runtime_error("NativeRuntime unavailable");
    execute=env->GetStaticMethodID(cls,"execute","([BLjava/lang/String;)[B");
    read=env->GetStaticMethodID(cls,"fabricReadByte","([BJ)I");
    write=env->GetStaticMethodID(cls,"fabricWriteByte","([BJI)[B");
    require_success(env,"resolve canonical RVPC2 entrypoints");
    if(!execute||!read||!write)throw std::runtime_error("incompatible REVERSE RVPC2 ABI");
    state=static_cast<jbyteArray>(env->NewLocalRef(original));
    if(!state)throw std::runtime_error("RVPC2 state reference unavailable");
  }
  StateBridge(const StateBridge&)=delete;
  StateBridge& operator=(const StateBridge&)=delete;
  ~StateBridge(){
    if(state)env->DeleteLocalRef(state);
    if(cls)env->DeleteLocalRef(cls);
  }
  void replace(jbyteArray next){
    if(!next)throw std::runtime_error("RVPC2 operation returned no state");
    env->DeleteLocalRef(state);
    state=next;
  }
  std::string run(const std::string& xi) {
    auto program=env->NewStringUTF(xi.c_str());
    if(!program)throw std::runtime_error("XI request buffer unavailable");
    auto packet=static_cast<jbyteArray>(
        env->CallStaticObjectMethod(cls,execute,state,program));
    env->DeleteLocalRef(program);
    require_success(env,"REVERSE XI");
    auto source=byte_array(env,packet);
    env->DeleteLocalRef(packet);
    if(source.size()<13 || std::string(source.begin(),source.begin()+5)!="RXOS1")
      throw std::runtime_error("unexpected RVPC2 XI result packet");
    const auto u32=[&](std::size_t offset) -> std::size_t {
      return std::size_t(source[offset])|
        (std::size_t(source[offset+1])<<8)|
        (std::size_t(source[offset+2])<<16)|
        (std::size_t(source[offset+3])<<24);
    };
    const auto length=u32(5), count=u32(9);
    if(length>16*1024*1024 || count>32*1024*1024+29 ||
       length>source.size()-13 || count!=source.size()-13-length)
      throw std::runtime_error("invalid original XI result packet sizes");
    std::string result(source.begin()+13,source.begin()+13+length);
    auto next=env->NewByteArray(jsize(count));
    if(!next)throw std::runtime_error("RVPC2 state allocation failed");
    env->SetByteArrayRegion(next,0,jsize(count),
      reinterpret_cast<const jbyte*>(source.data()+13+length));
    require_success(env,"publish RVPC2 state");
    replace(next);
    return result;
  }
  std::uint8_t load(const std::string& logical_address) {
    const auto address=std::stoll(logical_address);
    const auto result=env->CallStaticIntMethod(cls,read,state,jlong(address));
    require_success(env,"RVPC2 InverseMemory read");
    if(result<0 || result>255)throw std::runtime_error("invalid RVPC2 classical byte");
    return std::uint8_t(result);
  }
  void store(const std::string& logical_address,std::uint8_t value) {
    const auto address=std::stoll(logical_address);
    auto next=static_cast<jbyteArray>(
      env->CallStaticObjectMethod(cls,write,state,jlong(address),jint(value)));
    require_success(env,"RVPC2 InverseMemory store");
    replace(next);
  }
  std::vector<std::uint8_t> saved()const{return byte_array(env,state);}
};

std::vector<std::uint8_t> packet(const std::string& json,
                                  const std::vector<std::uint8_t>& state){
  if(json.size()>1024*1024||state.size()>32*1024*1024+29)
    throw std::length_error("fabric result exceeds REVERSE packet budget");
  std::vector<std::uint8_t> result;
  result.reserve(13+json.size()+state.size());
  for(char c:std::string("RXOS1"))result.push_back(std::uint8_t(c));
  auto u32=[&](std::uint32_t n){for(unsigned i=0;i<4;++i)result.push_back(std::uint8_t(n>>(8*i)));};
  u32(std::uint32_t(json.size()));u32(std::uint32_t(state.size()));
  result.insert(result.end(),json.begin(),json.end());
  result.insert(result.end(),state.begin(),state.end());
  return result;
}
void raise(JNIEnv* env,const std::exception& error){
  if(env->ExceptionCheck())env->ExceptionClear();
  const jclass klass=env->FindClass("java/lang/IllegalStateException");
  if(klass){env->ThrowNew(klass,error.what());env->DeleteLocalRef(klass);}
}
std::shared_ptr<reverse_fabric::Fabric> get(jlong id) {
  std::lock_guard<std::mutex> lock(registry_lock);
  auto it=registry.find(id);
  if(it==registry.end())throw std::invalid_argument("REVERSE Fabric handle is closed");
  return it->second;
}
} // namespace

extern "C" JNIEXPORT jlong JNICALL
Java_com_reversepc_os_NativeFabric_create(JNIEnv* env,jclass){
  try {
    auto item=std::make_shared<reverse_fabric::Fabric>();
    std::lock_guard<std::mutex> guard(registry_lock);
    if(next_id==std::numeric_limits<jlong>::max())throw std::overflow_error("fabric handles exhausted");
    const jlong id=next_id++;
    registry.emplace(id,std::move(item));
    return id;
  }catch(const std::exception& error){raise(env,error);return 0;}
}
extern "C" JNIEXPORT void JNICALL
Java_com_reversepc_os_NativeFabric_destroy(JNIEnv*,jclass,jlong id){
  std::lock_guard<std::mutex> lock(registry_lock);
  registry.erase(id);
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_NativeFabric_apply(JNIEnv* env,jclass,jlong id,jbyteArray raw,
                                         jstring action,jstring argument){
  try {
    auto fabric=get(id);
    StateBridge bridge(env,raw);
    reverse_fabric::Authority authority;
    authority.execute_xi=[&](const std::string& s){return bridge.run(s);};
    authority.read_byte=[&](const std::string& addr){return bridge.load(addr);};
    authority.write_byte=[&](const std::string& addr,std::uint8_t b){bridge.store(addr,b);};
    const auto data=fabric->apply(text(env,action,64),text(env,argument,256*1024),authority);
    return bytes(env,packet(data,bridge.saved()));
  }catch(const std::exception& error){raise(env,error);return nullptr;}
}
