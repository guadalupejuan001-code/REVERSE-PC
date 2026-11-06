// Compile the production JNI translation unit, with one test-only checkpoint
// observation. The same shim also compiles the pinned original 3.7 source.
#ifndef VELOCITY_QSSD_JNI_SOURCE
#define VELOCITY_QSSD_JNI_SOURCE "../app/src/main/cpp/reverse_os_jni.cpp"
#endif
#include VELOCITY_QSSD_JNI_SOURCE
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_VelocityStateSpaceTest_checkpoint(JNIEnv* e,jclass,jlong handle){
  try{return output(e,session(handle)->checkpoint());}
  catch(const std::exception& error){throw_java(e,error);return nullptr;}
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_VelocityQssdNativeTrace_checkpoint(JNIEnv* e,jclass,jlong handle){
  try{return output(e,session(handle)->checkpoint());}
  catch(const std::exception& error){throw_java(e,error);return nullptr;}
}
