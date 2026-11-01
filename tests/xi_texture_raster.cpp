#include <algorithm>
#include <array>
#include <atomic>
#include <thread>
#include <exception>
#include <cstring>
#include <cstdint>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string>
#include <vector>
namespace isolated {
#include "../src/integration/xi_mesh_raster.inc"
}
using Mesh=isolated::MachineMeshRaster;
static unsigned checks=0;
void check(bool condition,const char* why){++checks;if(!condition)throw std::runtime_error(why);}
template<class F> void rejects(F f,const char* why){
 bool threw=false;try{f();}catch(const std::exception&){threw=true;}check(threw,why);
}
void quad(Mesh& m,int tex_span=16){
 m.vertex(0,{-5,5,10});m.vertex(1,{5,5,10});
 m.vertex(2,{-5,-5,10});m.vertex(3,{5,-5,10});
 m.texcoord(0,0,0);m.texcoord(1,tex_span,0);
 m.texcoord(2,0,16);m.texcoord(3,tex_span,16);
 for(int i=0;i<4;++i)m.shade(i,128);
 m.textured_gradient_face(0,1,2,64,24,0,10,16,8,8,1);
 m.textured_gradient_face(1,3,2,64,24,0,10,16,8,8,1);
}
int main(){
 try{
  Mesh raster;
  rejects([&]{raster.texture_row(0,0,"0123456789abcdef");},"texture before begin");
  raster.begin(16,16,2,0);
  rejects([&]{raster.texture_row(8,0,"0123456789abcdef");},"texture id upper bound");
  rejects([&]{raster.texture_row(-1,0,"0123456789abcdef");},"negative texture id");
  rejects([&]{raster.texture_row(0,16,"0123456789abcdef");},"texture y upper bound");
  rejects([&]{raster.texture_row(0,0,"1234");},"texture row width");
  rejects([&]{raster.texture_row(0,0,"0123456789abcdeG");},"texture row invalid encoding");
  raster.texture_row(0,0,"0123456789abcdef");
  rejects([&]{raster.texture_row(0,0,"0123456789abcdef");},"duplicate texture row");
  for(int y=1;y<16;++y)raster.texture_row(0,y,"0123456789abcdef");
  rejects([&]{raster.texcoord(0,0,0);},"UV unset vertex");
  raster.vertex(0,{-5,5,10});
  rejects([&]{raster.texcoord(0,32768,0);},"UV coordinate overflow");
  raster.texcoord(0,4,7);
  raster.vertex(4,{0,0,10});
  raster.copy_texcoord(4,0);
  raster.shade(0,128);
  raster.vertex(0,{-5,5,10});
  rejects([&]{raster.copy_texcoord(4,0);},"vertex write resets UV");
  raster.texcoord(0,4,7);
  rejects([&]{raster.textured_gradient_face(0,1,2,64,24,0,10,16,8,8,1);},"unset triangle vertices");
  raster.begin(16,16,2,0);
  quad_test:
  raster.vertex(0,{-5,5,10});raster.vertex(1,{5,5,10});raster.vertex(2,{-5,-5,10});
  raster.texcoord(0,0,0);raster.texcoord(1,16,0);raster.texcoord(2,0,16);
  rejects([&]{raster.textured_gradient_face(0,1,2,64,24,0,10,16,8,8,1);},"row table must reset on begin");
  for(int y=0;y<16;++y)raster.texture_row(0,y,"0123456789abcdef");
  rejects([&]{raster.textured_gradient_face(0,1,2,64,24,0,0,16,8,8,1);},"zero strength rejected");
  rejects([&]{raster.textured_gradient_face(0,1,2,64,24,0,17,16,8,8,1);},"too strong texture rejected");
  rejects([&]{raster.textured_gradient_face(0,1,2,250,24,0,10,16,8,8,1);},"palette ramp overflow");
  raster.begin(16,16,2,0);
  for(int y=0;y<16;++y)raster.texture_row(0,y,"0123456789abcdef");
  quad(raster);
  const auto pixels=raster.materials();
  check(pixels.size()==256,"texture framebuffer dimensions");
  for(int y=0;y<16;++y)for(int x=0;x<16;++x){
   const std::int64_t q8=std::max<std::int64_t>(0,
       std::min<std::int64_t>(65280,32768+(x-8)*10*256));
   const int expected=64+int((q8*23+32640)/65280);
   check(pixels[y*16+x]==expected,"perspective tile shade Q8 oracle");
  }
  check(pixels[8]<pixels[15],"tile's UV should change visible shade");
  Mesh repeat;repeat.begin(16,16,2,0);
  for(int y=0;y<16;++y)repeat.texture_row(0,y,"0123456789abcdef");
  quad(repeat,32);
  check(repeat.materials()[0]==repeat.materials()[8],
        "repeated UV sampler should tile after 16 texels");
  Mesh clipped;clipped.begin(16,16,2,0);
  for(int y=0;y<16;++y)clipped.texture_row(0,y,"0123456789abcdef");
  clipped.vertex(0,{-5,5,0});clipped.vertex(1,{5,5,10});clipped.vertex(2,{-5,-5,10});
  clipped.texcoord(0,0,0);clipped.texcoord(1,16,0);clipped.texcoord(2,0,16);
  clipped.shade(0,128);clipped.shade(1,128);clipped.shade(2,128);
  clipped.textured_gradient_face(0,1,2,64,24,0,10,16,8,8,2);
  check(std::count_if(clipped.materials().begin(),clipped.materials().end(),
     [](std::uint8_t value){return value>=64&&value<=87;})>0,
     "perspective texture near clipping lost all pixels");
  Mesh flat;flat.begin(16,16,2,0);
  flat.vertex(0,{-5,5,10});flat.vertex(1,{5,5,10});flat.vertex(2,{-5,-5,10});
  flat.shade(0,128);flat.shade(1,128);flat.shade(2,128);
  flat.gradient_face(0,1,2,64,24,16,8,8,1);
  check(std::count_if(flat.materials().begin(),flat.materials().end(),
       [](std::uint8_t value){return value>=64&&value<=87;})>0,
       "old untextured shading must still work");
  check(!raster.finish().empty(),"textured XFS1 packet produced");
  std::cout<<"XI_TEXTURE_RASTER_PASS checks="<<checks<<"\n";
 }catch(const std::exception& e){
  std::cerr<<"XI_TEXTURE_RASTER_FAIL "<<e.what()<<"\n";return 1;
 }
}
