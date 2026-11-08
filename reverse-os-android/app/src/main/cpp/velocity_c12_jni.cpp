#include "velocity_c12_frame.hpp"
#include <jni.h>
#include <android/log.h>
#include <atomic>
#include <exception>
#include <stdexcept>

extern "C" JNIEXPORT jfloatArray JNICALL
Java_com_reversepc_os_NativeRuntime_velocityC12Frame(
  JNIEnv* env,jclass,jint wetness,jint waterDepth,jint ticks,jint ambient,jlong publication){
  try{
    if(wetness<0||waterDepth<0||ticks<0||ambient<0||publication<0)
      throw std::invalid_argument("Negative C12 input/QSSD publication");
    auto result=velocity_c12::evaluate({
      static_cast<std::uint32_t>(wetness),static_cast<std::uint32_t>(waterDepth),
      static_cast<std::uint32_t>(ticks),static_cast<std::uint32_t>(ambient)});
    auto array=env->NewFloatArray(static_cast<jsize>(result.values.size()));
    if(!array)return nullptr;
    env->SetFloatArrayRegion(array,0,static_cast<jsize>(result.values.size()),result.values.data());
    if(env->ExceptionCheck())return nullptr;
    static std::atomic<std::uint64_t> frames{0};
    auto count=++frames;
    if(count==1||count%120==0)
      __android_log_print(ANDROID_LOG_INFO,"ReverseVelocity",
        "GPU_C12_EXECUTED frames=%llu profile=C12 host=CPU steps=%llu relationNodes=%llu qssdPublication=%lld output=material_uniforms GLES=presenter",
        static_cast<unsigned long long>(count),
        static_cast<unsigned long long>(result.steps),
        static_cast<unsigned long long>(result.relation_nodes),
        static_cast<long long>(publication));
    return array;
  }catch(const std::exception& failure){
    if(!env->ExceptionCheck()){
      jclass type=env->FindClass("java/lang/IllegalStateException");
      if(type)env->ThrowNew(type,failure.what());
    }
    return nullptr;
  }
}
