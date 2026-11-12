// Positive rendering test for GPU Virtual adaptive fidelity (real EGL/GLES2,
// not proof of performance or of rendering the 369B logical population).
#include "lab_api.hpp"
#include "graphics_stream.hpp"
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES2/gl2.h>
#include <algorithm>
#include <array>
#include <cstdint>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

namespace {
constexpr int W=480,H=270;
void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
struct Context {
  EGLDisplay display=EGL_NO_DISPLAY;EGLSurface surface=EGL_NO_SURFACE;EGLContext context=EGL_NO_CONTEXT;
  Context(){
    auto platform=reinterpret_cast<PFNEGLGETPLATFORMDISPLAYEXTPROC>(eglGetProcAddress("eglGetPlatformDisplayEXT"));
    require(platform!=nullptr,"EGL platform display API missing");
    display=platform(0x31DD,EGL_DEFAULT_DISPLAY,nullptr);require(eglInitialize(display,nullptr,nullptr),"EGL init");
    EGLConfig format{};EGLint count=0;
    const EGLint config[]={EGL_SURFACE_TYPE,EGL_PBUFFER_BIT,EGL_RENDERABLE_TYPE,EGL_OPENGL_ES2_BIT,EGL_RED_SIZE,8,EGL_GREEN_SIZE,8,EGL_BLUE_SIZE,8,EGL_ALPHA_SIZE,8,EGL_DEPTH_SIZE,16,EGL_NONE};
    require(eglChooseConfig(display,config,&format,1,&count)&&count==1,"choose EGL config");
    const EGLint ctx[]={EGL_CONTEXT_CLIENT_VERSION,2,EGL_NONE};
    const EGLint pb[]={EGL_WIDTH,W,EGL_HEIGHT,H,EGL_NONE};
    context=eglCreateContext(display,format,EGL_NO_CONTEXT,ctx);surface=eglCreatePbufferSurface(display,format,pb);
    require(context!=EGL_NO_CONTEXT&&surface!=EGL_NO_SURFACE,"allocate EGL surface");
    require(eglMakeCurrent(display,surface,surface,context),"current EGL context");
  }
  ~Context(){if(display!=EGL_NO_DISPLAY){eglMakeCurrent(display,EGL_NO_SURFACE,EGL_NO_SURFACE,EGL_NO_CONTEXT);if(context!=EGL_NO_CONTEXT)eglDestroyContext(display,context);if(surface!=EGL_NO_SURFACE)eglDestroySurface(display,surface);eglTerminate(display);}}
  using Image=std::vector<std::uint8_t>;
  Image pixels(){Image out(std::size_t(W)*H*4);glFinish();glReadPixels(0,0,W,H,GL_RGBA,GL_UNSIGNED_BYTE,out.data());require(glGetError()==GL_NO_ERROR,"GL pixel readback");return out;}
};
using Image=Context::Image;
std::array<int,4> color(const Image& pixels,int x,int y){const auto o=(std::size_t(y)*W+x)*4;return {pixels[o],pixels[o+1],pixels[o+2],pixels[o+3]};}
std::array<int,2> counts(const Image&pixels){std::array<int,2> result{};for(int y=H/2-12;y<H/2+12;++y)for(int x=W/2;x<W/2+24;++x){auto p=color(pixels,x,y);if(p[0]>p[1]+55&&p[0]>p[2]+55)++result[0];if(p[1]>p[0]+55&&p[1]>p[2]+55)++result[1];}return result;}
xgpu::GraphicsInstance effect(float x,float y,float z,float world_size,float r,float g,float b,float a){
  xgpu::GraphicsInstance v;v.payload={x,y,z,world_size,1,0,0,world_size,0,1,0,world_size,r,g,b,a};return v;
}
xlab::Packet packet(const std::vector<xgpu::GraphicsInstance>& effects){
  xlab::Packet p;p.eye={0,0,10};p.look={0,0,0};p.fog={0.01f,.01f,.015f};
  auto stream=std::make_shared<xgpu::GraphicsStream>();stream->source_hash=0xBADA551;
  stream->variant_count=1;stream->variants[0]=effects;
  xlab::CompactGroup g;g.program=xlab::COMPACT_EFFECTS_FIELD;g.count=int(effects.size());g.resolved=stream;
  g.relation_hash=stream->source_hash;g.logical_population=std::uint64_t(effects.size());p.compact_groups.push_back(g);
  return p;
}
Image render(xlab::Renderer& renderer,Context& egl,const xlab::Packet& p,int route){
  xlab::Config config;config.scene=xlab::EFFECTS;config.load=4;config.graphics_path=route;config.resolution=1.f;
  renderer.configure(config);const auto stats=renderer.draw(p,std::uint64_t(route));
  require(stats.draw_calls>=2&&stats.camera_instances>=1,"actual GPU draw missing");
  const auto caps=renderer.capabilities();
  if(route==5){
    require(caps.find("\"adaptive_field_active\":true")!=std::string::npos,"quality route not enabled");
    require(caps.find("\"adaptive_effect_divisor\":1")!=std::string::npos,"quality FBO not full-res");
  }
  return egl.pixels();
}
}
int main(){
  try{
    Context egl;xlab::Renderer renderer;renderer.initialize();renderer.resize(W,H);
    const auto opaque=packet({effect(0,0,-1,.25f,0,0,1,1),effect(0,0,1,.25f,1,0,0,1)});
    const auto fast=render(renderer,egl,opaque,4),quality=render(renderer,egl,opaque,5);
    const auto f=color(fast,W/2,H/2),q=color(quality,W/2,H/2);
    require(q[0]>q[2]+80&&q[0]>100,"frontmost opaque red not preserved on GPU");
    require(f[2]>q[2]+30,"legacy compressed collision did not differ on GPU");
    const auto trans=packet({effect(0,0,-1,.25f,0,0,1,.6f),effect(0,0,1,.25f,1,0,0,.6f)});
    const auto tq=render(renderer,egl,trans,5),tf=render(renderer,egl,trans,4);
    const auto t=color(tq,W/2,H/2),fl=color(tf,W/2,H/2);
    require(t[0]>t[2]&&t[2]>20,"GLES2 layered transparency was lost");
    require(t[0]>fl[0]+10,"adaptive alpha depth did not improve reference color");
    const auto thin=packet({effect(.14f,0,0,.035f,1,0,0,.95f),effect(.25f,0,0,.035f,0,1,0,.95f)});
    const auto iq=render(renderer,egl,thin,5),ifl=render(renderer,egl,thin,4);
    const auto cr=counts(iq),cf=counts(ifl);
    require(cr[0]>0&&cr[1]>0,"independent red/green thin effects not visible");
    require(cf[0]==0||cf[1]==0,"legacy field unexpectedly preserves both silhouettes");
    std::cout<<"{\"suite\":\"adaptive_fidelity_real_egl\",\"passed\":true,\"opaque_fast_blue\":"<<f[2]
             <<",\"opaque_adaptive_blue\":"<<q[2]<<",\"opaque_adaptive_red\":"<<q[0]
             <<",\"transparent_red\":"<<t[0]<<",\"transparent_blue\":"<<t[2]
             <<",\"independent_red_pixels\":"<<cr[0]<<",\"independent_green_pixels\":"<<cr[1]
             <<",\"android_mali_tested\":false,\"fps_measured\":false}\n";
    return 0;
  }catch(const std::exception&ex){std::cerr<<"ADAPTIVE_GLES_FAIL: "<<ex.what()<<'\n';return 1;}
}
