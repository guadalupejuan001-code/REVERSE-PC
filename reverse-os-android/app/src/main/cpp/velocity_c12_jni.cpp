#include "velocity_c12_frame.hpp"
#include <jni.h>
#include <android/log.h>
#include <atomic>
#include <chrono>
#include <exception>
#include <stdexcept>

extern "C" JNIEXPORT void JNICALL
Java_com_reversepc_os_NativeRuntime_velocityC12Frame(
  JNIEnv* env,jclass,jint wetness,jint waterDepth,jint ticks,jint ambient,
  jlong publication,jfloatArray output){
  try{
    if(!output||env->GetArrayLength(output)!=
        static_cast<jsize>(velocity_c12::material_uniform_count))
      throw std::invalid_argument("C12 output must contain exactly five material uniforms");
    if(wetness<0||waterDepth<0||ticks<0||ambient<0||publication<0)
      throw std::invalid_argument("Negative C12 input/QSSD publication");
    const auto started=std::chrono::steady_clock::now();
    auto result=velocity_c12::evaluate({
      static_cast<std::uint32_t>(wetness),static_cast<std::uint32_t>(waterDepth),
      static_cast<std::uint32_t>(ticks),static_cast<std::uint32_t>(ambient)});
    const auto dispatchNanos=std::chrono::duration_cast<std::chrono::nanoseconds>(
      std::chrono::steady_clock::now()-started).count();
    // The GL renderer owns this buffer. Native dispatch state stays local, and
    // failed validation/execution never publishes partial material values.
    env->SetFloatArrayRegion(output,0,static_cast<jsize>(result.values.size()),result.values.data());
    if(env->ExceptionCheck())return;
    static std::atomic<std::uint64_t> frames{0};
    const auto count=frames.fetch_add(1,std::memory_order_relaxed)+1;
    if(count==1||count%120==0)
      __android_log_print(ANDROID_LOG_INFO,"ReverseVelocity",
        "GPU_C12_EXECUTED frames=%llu profile=C12 host=CPU steps=%llu relationNodes=%llu qssdPublication=%lld output=material_uniforms GLES=presenter dispatchNanos=%llu timing=host_wall outputBuffer=reused",
        static_cast<unsigned long long>(count),
        static_cast<unsigned long long>(result.steps),
        static_cast<unsigned long long>(result.relation_nodes),
        static_cast<long long>(publication),
        static_cast<unsigned long long>(dispatchNanos));
  }catch(const std::exception& failure){
    if(!env->ExceptionCheck()){
      jclass type=env->FindClass("java/lang/IllegalStateException");
      if(type)env->ThrowNew(type,failure.what());
    }
  }
}
