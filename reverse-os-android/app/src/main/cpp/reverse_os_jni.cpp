#include "session.hpp"
#include "rxe.hpp"
#include "rxe_app.hpp"
#include <jni.h>
#include <exception>
#include <limits>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>
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
