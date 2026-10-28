#include <jni.h>
#include <GLES3/gl3.h>
#include "prisma_xrender.hpp"
#include "prisma_xrender_present.hpp"
#include <map>
#include <mutex>

namespace {
using Engine=reverse_pc::PrismaXRender;
static GLuint shader(GLenum kind,const char* source){
  GLuint id=glCreateShader(kind);glShaderSource(id,1,&source,nullptr);glCompileShader(id);
  GLint ok=0;glGetShaderiv(id,GL_COMPILE_STATUS,&ok);
  if(!ok){char log[2048]{};glGetShaderInfoLog(id,sizeof(log),nullptr,log);glDeleteShader(id);throw std::runtime_error(log);}
  return id;
}
class Presenter {
 public:
  Presenter(){
    const GLuint vertex=shader(GL_VERTEX_SHADER,reverse_pc::xrender_present_vertex);
    GLuint fragment=0;
    try{fragment=shader(GL_FRAGMENT_SHADER,reverse_pc::xrender_present_fragment);program_=glCreateProgram();glAttachShader(program_,vertex);glAttachShader(program_,fragment);glLinkProgram(program_);
      GLint linked=0;glGetProgramiv(program_,GL_LINK_STATUS,&linked);if(!linked)throw std::runtime_error("X Render presenter link failed");
    }catch(...){glDeleteShader(vertex);if(fragment)glDeleteShader(fragment);if(program_)glDeleteProgram(program_);throw;}
    glDeleteShader(vertex);glDeleteShader(fragment);glGenVertexArrays(1,&vao_);glGenTextures(1,&texture_);
    glBindTexture(GL_TEXTURE_2D,texture_);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
    for(const char* name:{"resolution","view","green","coral","time","energy","quiet","surfaces"})uniform_[name]=glGetUniformLocation(program_,name);
  }
  ~Presenter(){glDeleteTextures(1,&texture_);glDeleteVertexArrays(1,&vao_);glDeleteProgram(program_);}
  void abandon(){texture_=0;vao_=0;program_=0;}
  void resize(int w,int h){engine_.resize(w,h);width_=w;height_=h;glViewport(0,0,w,h);glClearColor(0,0,0,1);glClear(GL_COLOR_BUFFER_BIT);}
  std::string frame(Engine::Frame f){
    const auto& stats=engine_.render(f);glBindTexture(GL_TEXTURE_2D,texture_);glPixelStorei(GL_UNPACK_ALIGNMENT,1);
    if(texture_w_!=stats.width||texture_h_!=stats.height){
      texture_w_=stats.width;texture_h_=stats.height;
      glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,texture_w_,texture_h_,0,GL_RGBA,GL_UNSIGNED_BYTE,engine_.rgba().data());
    }else glTexSubImage2D(GL_TEXTURE_2D,0,0,0,texture_w_,texture_h_,GL_RGBA,GL_UNSIGNED_BYTE,engine_.rgba().data());
    glViewport(0,0,width_,height_);glDisable(GL_DEPTH_TEST);glDisable(GL_CULL_FACE);glDisable(GL_BLEND);
    glUseProgram(program_);glBindVertexArray(vao_);glActiveTexture(GL_TEXTURE0);glBindTexture(GL_TEXTURE_2D,texture_);
    glUniform1i(uniform_["surfaces"],0);glUniform2f(uniform_["resolution"],width_,height_);
    const auto* p=f.data.data();glUniform4fv(uniform_["view"],1,p+4);glUniform3fv(uniform_["green"],1,p+8);glUniform3fv(uniform_["coral"],1,p+11);
    glUniform1f(uniform_["time"],p[1]);glUniform1f(uniform_["energy"],p[2]);glUniform1f(uniform_["quiet"],p[3]);glDrawArrays(GL_TRIANGLES,0,3);
    if(glGetError()!=GL_NO_ERROR)throw std::runtime_error("X Render surface presentation failed");
    return stats.json();
  }
 private:
  Engine engine_;
  GLuint texture_=0,vao_=0,program_=0;
  int width_=0,height_=0;
  std::size_t texture_w_=0,texture_h_=0;
  std::map<std::string,GLint> uniform_;
};
std::mutex registry_mutex;
std::map<jlong,std::unique_ptr<Presenter>> registry;
jlong next_handle=1;
Presenter& lookup(jlong handle){const auto it=registry.find(handle);if(it==registry.end())throw std::invalid_argument("closed X Render surface");return *it->second;}
void error(JNIEnv* env,const std::exception& e){env->ThrowNew(env->FindClass("java/lang/IllegalArgumentException"),e.what());}
}
extern "C" JNIEXPORT jlong JNICALL Java_com_reversepc_os_NativeRuntime_xRenderCreate(JNIEnv* env,jclass){
  try{std::lock_guard<std::mutex> lock(registry_mutex);auto instance=std::make_unique<Presenter>();const auto handle=next_handle++;registry.emplace(handle,std::move(instance));return handle;}
  catch(const std::exception& e){error(env,e);return 0;}
}
extern "C" JNIEXPORT void JNICALL Java_com_reversepc_os_NativeRuntime_xRenderResize(JNIEnv* env,jclass,jlong handle,jint w,jint h){
  try{std::lock_guard<std::mutex> lock(registry_mutex);if(w<1||h<1)throw std::invalid_argument("invalid X Render dimensions");lookup(handle).resize(w,h);}
  catch(const std::exception& e){error(env,e);}
}
extern "C" JNIEXPORT jstring JNICALL Java_com_reversepc_os_NativeRuntime_xRenderFrame(JNIEnv* env,jclass,jlong handle,jfloatArray packet){
  try{
    if(!packet)throw std::invalid_argument("missing X Render frame");const auto length=env->GetArrayLength(packet);
    if(length<16||length>16+64*12)throw std::invalid_argument("invalid X Render frame size");
    std::vector<float> values(length);env->GetFloatArrayRegion(packet,0,length,values.data());if(env->ExceptionCheck())return nullptr;
    Engine::Frame frame(std::move(values));std::lock_guard<std::mutex> lock(registry_mutex);
    const auto info=lookup(handle).frame(std::move(frame));return env->NewStringUTF(info.c_str());
  }catch(const std::exception& e){error(env,e);return nullptr;}
}
extern "C" JNIEXPORT void JNICALL Java_com_reversepc_os_NativeRuntime_xRenderDestroy(JNIEnv*,jclass,jlong handle,jboolean release_gl){
  std::lock_guard<std::mutex> lock(registry_mutex);const auto it=registry.find(handle);
  if(it!=registry.end()){if(!release_gl)it->second->abandon();registry.erase(it);}
}
