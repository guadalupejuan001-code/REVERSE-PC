#include "qssd/graphics_port.hpp" // Comes from the exact original QSSD dependency.
#include <jni.h>
#include <optional>
#include <unordered_map>
#include <limits>

namespace {
struct Port {
  qssd::GraphicsPort component;
  std::mutex mutex;
  std::optional<qssd::GraphicsPort::Plan> pending;
};
std::mutex registry_mutex;
std::unordered_map<jlong,std::shared_ptr<Port>> registry;
jlong next_handle=1;
std::shared_ptr<Port> port(jlong id){
  std::lock_guard<std::mutex> lock(registry_mutex);
  const auto i=registry.find(id);
  if(i==registry.end())throw std::invalid_argument("qSSD native graphics handle is closed");
  return i->second;
}
void fail(JNIEnv* e,const std::exception& error){
  if(e->ExceptionCheck())return;
  const auto type=e->FindClass("java/lang/IllegalArgumentException");
  if(type)e->ThrowNew(type,error.what());
}
jlongArray longs(JNIEnv* e,const std::vector<jlong>& values){
  auto out=e->NewLongArray(static_cast<jsize>(values.size()));
  if(out)e->SetLongArrayRegion(out,0,static_cast<jsize>(values.size()),values.data());
  return out;
}
std::uint32_t u32(const std::uint8_t* p){
  return std::uint32_t(p[0])|(std::uint32_t(p[1])<<8)|(std::uint32_t(p[2])<<16)|(std::uint32_t(p[3])<<24);
}
}
extern "C" JNIEXPORT jlong JNICALL
Java_com_reversepc_os_VelocityQssdGraphicsBridge_nativeOpen(JNIEnv* e,jclass){
  try{
    auto instance=std::make_shared<Port>();
    std::lock_guard<std::mutex> lock(registry_mutex);
    if(next_handle==INT64_MAX)throw std::overflow_error("qSSD graphics handles exhausted");
    const auto id=next_handle++;registry.emplace(id,std::move(instance));return id;
  }catch(const std::exception& x){fail(e,x);return 0;}
}
extern "C" JNIEXPORT void JNICALL
Java_com_reversepc_os_VelocityQssdGraphicsBridge_nativeClose(JNIEnv*,jclass,jlong id){
  std::lock_guard<std::mutex> lock(registry_mutex);registry.erase(id);
}
extern "C" JNIEXPORT jlongArray JNICALL
Java_com_reversepc_os_VelocityQssdGraphicsBridge_nativePublish(JNIEnv* e,jclass,jlong id,
  jlong session,jlong identity,jlong revision,jobject geometry,jintArray palette){
  try{
    if(session<=0||identity<=0||revision<=0||!geometry||!palette||e->GetArrayLength(palette)!=256)
      throw std::invalid_argument("qSSD graphics needs the original native lease and palette");
    const auto* bytes=static_cast<const std::uint8_t*>(e->GetDirectBufferAddress(geometry));
    const auto capacity=e->GetDirectBufferCapacity(geometry);
    if(!bytes||capacity<2064||std::memcmp(bytes,"XFG4",4)||u32(bytes+8)!=4||u32(bytes+12)>8192||
       capacity!=static_cast<jlong>(2064+std::uint64_t(u32(bytes+12))*60))
      throw std::invalid_argument("qSSD native import requires a complete direct XFG4 projection");
    std::array<jint,256> input{};e->GetIntArrayRegion(palette,0,256,input.data());
    if(e->ExceptionCheck())return nullptr;
    qssd::GraphicsPalette colors{};
    for(std::size_t i=0;i<colors.size();++i)colors[i]=static_cast<std::uint32_t>(input[i]);
    auto p=port(id);std::lock_guard<std::mutex> lock(p->mutex);
    const auto view=p->component.publish({static_cast<std::uint64_t>(session),static_cast<std::uint64_t>(identity),
      static_cast<std::uint64_t>(revision)},colors,bytes+16,2048);
    return longs(e,{static_cast<jlong>(view->serial),static_cast<jlong>(view->value->palette_revision),
      static_cast<jlong>(view->value->atlas_revision),static_cast<jlong>(p->component.counters().reused)});
  }catch(const std::exception& x){fail(e,x);return nullptr;}
}
extern "C" JNIEXPORT jbyteArray JNICALL
Java_com_reversepc_os_VelocityQssdGraphicsBridge_nativeAtlas(JNIEnv* e,jclass,jlong id,jlong serial){
  try{
    const auto view=port(id)->component.at(static_cast<std::uint64_t>(serial));
    if(!view->value->device_atlas)throw std::invalid_argument("qSSD atlas not published");
    auto out=e->NewByteArray(2048);
    if(out)e->SetByteArrayRegion(out,0,2048,reinterpret_cast<const jbyte*>(view->value->device_atlas->data()));
    return out;
  }catch(const std::exception& x){fail(e,x);return nullptr;}
}
extern "C" JNIEXPORT jlongArray JNICALL
Java_com_reversepc_os_VelocityQssdGraphicsBridge_nativePlan(JNIEnv* e,jclass,jlong id,jlong serial){
  try{
    auto p=port(id);std::lock_guard<std::mutex> lock(p->mutex);
    auto result=p->component.plan(p->component.at(static_cast<std::uint64_t>(serial)));
    std::vector<jlong> data{static_cast<jlong>(result.context),result.geometry_dirty?1:0,
      result.atlas_rows,static_cast<jlong>(result.palette_spans.size())};
    for(const auto& span:result.palette_spans){data.push_back(span.first);data.push_back(span.count);}
    auto out=longs(e,data);
    if(out&&!e->ExceptionCheck())p->pending=std::move(result);
    return out;
  }catch(const std::exception& x){fail(e,x);return nullptr;}
}
extern "C" JNIEXPORT jlong JNICALL
Java_com_reversepc_os_VelocityQssdGraphicsBridge_nativeConfirm(JNIEnv* e,jclass,jlong id,jlong serial,jlong context){
  try{
    auto p=port(id);std::lock_guard<std::mutex> lock(p->mutex);
    if(!p->pending||p->pending->target->serial!=static_cast<std::uint64_t>(serial)||
       p->pending->context!=static_cast<std::uint64_t>(context))
      throw std::invalid_argument("qSSD upload lacks its matching native plan");
    p->component.confirm(*p->pending);p->pending.reset();
    return static_cast<jlong>(p->component.counters().confirmed);
  }catch(const std::exception& x){fail(e,x);return 0;}
}
extern "C" JNIEXPORT void JNICALL
Java_com_reversepc_os_VelocityQssdGraphicsBridge_nativeInvalidate(JNIEnv* e,jclass,jlong id){
  try{
    auto p=port(id);std::lock_guard<std::mutex> lock(p->mutex);
    p->component.invalidate_device();p->pending.reset();
  }catch(const std::exception& x){fail(e,x);}
}
