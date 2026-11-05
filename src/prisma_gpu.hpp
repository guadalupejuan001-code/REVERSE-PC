#pragma once
#include <GLES3/gl3.h>
#include <array>
#include <cmath>
#include <cstdint>
#include "prisma_xrender.hpp"
#include <chrono>
#include <map>
#include <sstream>
#include <stdexcept>
#include <vector>
#include "prisma_gpu_shaders.hpp"

namespace reverse_pc {
// Ether Render X mesh backend. Geometry, depth and lighting execute in GLES.
// Legacy sparse CPU observation remains a separate, compatible backend.
class PrismaGpuRenderer {
  struct World{GLuint vao=0,buffer=0;GLsizei vertices=0;};
  GLuint notes_=0,sky_=0,world_=0,note_vao_=0,note_vertices_=0,note_indices_=0,instances_=0,sky_vao_=0;
  std::array<World,5> worlds_{};
  std::uint64_t frames_=0,uploads_=0;int width_=0,height_=0;
  static GLuint program(const char* vertex,const char* fragment){
    std::vector<GLuint> shaders;GLuint p=0;
    try{for(auto part:{std::make_pair(GL_VERTEX_SHADER,vertex),std::make_pair(GL_FRAGMENT_SHADER,fragment)}){
      GLuint s=glCreateShader(part.first);shaders.push_back(s);glShaderSource(s,1,&part.second,nullptr);glCompileShader(s);
      GLint ok=0;glGetShaderiv(s,GL_COMPILE_STATUS,&ok);if(!ok){char message[2048]{};glGetShaderInfoLog(s,sizeof(message),nullptr,message);throw std::runtime_error(message);}
    }p=glCreateProgram();for(auto s:shaders)glAttachShader(p,s);glLinkProgram(p);GLint ok=0;glGetProgramiv(p,GL_LINK_STATUS,&ok);if(!ok)throw std::runtime_error("Prisma GPU link failed");
    }catch(...){for(auto s:shaders)glDeleteShader(s);if(p)glDeleteProgram(p);throw;}
    for(auto s:shaders)glDeleteShader(s);return p;
  }
  static GLint uniform(GLuint p,const char* n){return glGetUniformLocation(p,n);}
  static std::string quoted(const GLubyte* p){std::string s="\"";if(p)for(char c:std::string(reinterpret_cast<const char*>(p))){if(c=='"'||c=='\\')s+='\\';if(static_cast<unsigned char>(c)>=32)s+=c;}return s+'"';}
 public:
  PrismaGpuRenderer(){
    using namespace prisma_gpu_sources;
    notes_=program(VERTEX,FRAGMENT);sky_=program(BACK_VERTEX,BACK_FRAGMENT);world_=program(WORLD_VERTEX,WORLD_FRAGMENT);
    glGenVertexArrays(1,&note_vao_);glBindVertexArray(note_vao_);
    glGenBuffers(1,&note_vertices_);glBindBuffer(GL_ARRAY_BUFFER,note_vertices_);glBufferData(GL_ARRAY_BUFFER,sizeof(vertices),vertices,GL_STATIC_DRAW);
    for(int i=0;i<2;++i){glEnableVertexAttribArray(i);glVertexAttribPointer(i,3,GL_FLOAT,GL_FALSE,6*sizeof(float),reinterpret_cast<void*>(i*3*sizeof(float)));}
    glGenBuffers(1,&note_indices_);glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,note_indices_);glBufferData(GL_ELEMENT_ARRAY_BUFFER,sizeof(indices),indices,GL_STATIC_DRAW);
    glGenBuffers(1,&instances_);glBindBuffer(GL_ARRAY_BUFFER,instances_);glBufferData(GL_ARRAY_BUFFER,128*12*sizeof(float),nullptr,GL_DYNAMIC_DRAW);
    for(int i=2;i<5;++i){glEnableVertexAttribArray(i);glVertexAttribPointer(i,4,GL_FLOAT,GL_FALSE,12*sizeof(float),reinterpret_cast<void*>((i-2)*4*sizeof(float)));glVertexAttribDivisor(i,1);}
    glGenVertexArrays(1,&sky_vao_);glBindVertexArray(0);
  }
  ~PrismaGpuRenderer(){
    for(auto& w:worlds_){if(w.buffer)glDeleteBuffers(1,&w.buffer);if(w.vao)glDeleteVertexArrays(1,&w.vao);}
    for(auto p:{notes_,sky_,world_})if(p)glDeleteProgram(p);
    for(auto b:{note_vertices_,note_indices_,instances_})if(b)glDeleteBuffers(1,&b);
    for(auto a:{note_vao_,sky_vao_})if(a)glDeleteVertexArrays(1,&a);
  }
  void abandon(){for(auto& w:worlds_)w={};notes_=sky_=world_=note_vao_=note_vertices_=note_indices_=instances_=sky_vao_=0;}
  void resize(int w,int h){width_=w;height_=h;}
  void model(int id,const std::vector<float>& data){
    if(id<0||id>4||data.empty()||data.size()>384000||data.size()%36)throw std::invalid_argument("invalid GPU triangle model");
    for(std::size_t i=0;i<data.size();++i){const float x=data[i];if(!std::isfinite(x))throw std::invalid_argument("nonfinite GPU model");const auto f=i%12;
      if((f<3&&std::abs(x)>100)||(f>=3&&f<6&&std::abs(x)>1.01)||(f>=6&&f<10&&(x<0||x>3))||(f==10&&(x<0||x>7||std::floor(x)!=x))||(f==11&&x!=0))throw std::invalid_argument("invalid GPU model field");}
    auto& w=worlds_[id];if(!w.vao){glGenVertexArrays(1,&w.vao);glGenBuffers(1,&w.buffer);}
    glBindVertexArray(w.vao);glBindBuffer(GL_ARRAY_BUFFER,w.buffer);glBufferData(GL_ARRAY_BUFFER,data.size()*sizeof(float),data.data(),GL_STATIC_DRAW);
    for(int i=0;i<4;++i){glEnableVertexAttribArray(i);glVertexAttribPointer(i,3,GL_FLOAT,GL_FALSE,12*sizeof(float),reinterpret_cast<void*>(i*3*sizeof(float)));}
    w.vertices=static_cast<GLsizei>(data.size()/12);++uploads_;glBindVertexArray(0);
    if(glGetError()!=GL_NO_ERROR)throw std::runtime_error("GPU world upload failed");
  }
  std::string frame(const PrismaXRender::Frame& frame){
    if(width_<1||height_<1)throw std::logic_error("GPU surface not sized");
    const auto start=std::chrono::steady_clock::now();const float* p=frame.data.data();
    const auto code=static_cast<unsigned>(p[14]);const int current=(code>>2)&7,previous=int((code>>5)&7)-1;const float mix=float(code>>8)/255.f;
    int calls=1,vertices=0;glViewport(0,0,width_,height_);glDisable(GL_SCISSOR_TEST);glDisable(GL_CULL_FACE);glDisable(GL_BLEND);glDisable(GL_DEPTH_TEST);glDepthMask(GL_TRUE);glClearColor(.005f,.01f,.02f,1);glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glUseProgram(sky_);glBindVertexArray(sky_vao_);glUniform2f(uniform(sky_,"resolution"),width_,height_);glUniform4fv(uniform(sky_,"view"),1,p+4);glUniform3fv(uniform(sky_,"green"),1,p+8);glUniform3fv(uniform(sky_,"coral"),1,p+11);glUniform1f(uniform(sky_,"time"),p[1]);glUniform1f(uniform(sky_,"energy"),p[2]);glUniform1f(uniform(sky_,"quiet"),p[3]);glDrawArrays(GL_TRIANGLES,0,3);
    glUseProgram(world_);glUniform4fv(uniform(world_,"view"),1,p+4);glUniform1f(uniform(world_,"time"),p[1]);glUniform1f(uniform(world_,"energy"),p[2]);glUniform1f(uniform(world_,"quiet"),p[3]);glEnable(GL_DEPTH_TEST);glDepthFunc(GL_LEQUAL);
    const auto draw_world=[&](int id,float alpha){if(id<0||id>4||alpha<=0||!worlds_[id].vertices)return;const auto& w=worlds_[id];glClear(GL_DEPTH_BUFFER_BIT);glEnable(GL_BLEND);glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);glUniform1f(uniform(world_,"opacity"),alpha);glBindVertexArray(w.vao);glDrawArrays(GL_TRIANGLES,0,w.vertices);++calls;vertices+=w.vertices;};
    if(previous>=0)draw_world(previous,1-mix);draw_world(current,mix);
    // The note field is an independent foreground depth layer: scenery cannot
    // erase notes. Notes still resolve their own 3D faces through a depth buffer.
    glClear(GL_DEPTH_BUFFER_BIT);glUseProgram(notes_);glBindVertexArray(note_vao_);glBindBuffer(GL_ARRAY_BUFFER,instances_);glBufferSubData(GL_ARRAY_BUFFER,0,frame.count*12*sizeof(float),p+16);glUniform4fv(uniform(notes_,"view"),1,p+4);glEnable(GL_BLEND);glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    if(frame.count){glDrawElementsInstanced(GL_TRIANGLES,sizeof(prisma_gpu_sources::indices)/sizeof(unsigned short),GL_UNSIGNED_SHORT,nullptr,frame.count);++calls;}
    glBindVertexArray(0);if(glGetError()!=GL_NO_ERROR)throw std::runtime_error("GPU mesh frame failed");++frames_;
    GLint samples=0,depth=0;glGetIntegerv(GL_SAMPLES,&samples);glGetIntegerv(GL_DEPTH_BITS,&depth);
    const double cpu=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
    std::ostringstream s;s<<"{\"renderer\":\"ether-render-x-gpu\",\"backend\":\"gles3-instanced\",\"frames\":"<<frames_<<",\"width\":"<<width_<<",\"height\":"<<height_<<",\"note_instances\":"<<frame.count<<",\"world\":"<<current<<",\"world_vertices\":"<<vertices<<",\"world_uploads\":"<<uploads_<<",\"draw_calls\":"<<calls<<",\"samples\":"<<samples<<",\"depth_bits\":"<<depth<<",\"submit_cpu_ms\":"<<cpu<<",\"gl_vendor\":"<<quoted(glGetString(GL_VENDOR))<<",\"gl_renderer\":"<<quoted(glGetString(GL_RENDERER))<<"}";return s.str();
  }
};
}
