#include <algorithm>
#include <array>
#include <chrono>
#include <cstdint>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
namespace spatial_reference {
#define REGRAPHICS_DISABLE_SPATIAL_CANDIDATES
#include "../src/integration/xi_mesh_raster.inc"
#undef REGRAPHICS_DISABLE_SPATIAL_CANDIDATES
}
namespace spatial_optimized {
#include "../src/integration/xi_mesh_raster.inc"
}
using Ref=spatial_reference::MachineMeshRaster;
using Opt=spatial_optimized::MachineMeshRaster;
static int checks=0;
void check(bool ok,const char* why){++checks;if(!ok)throw std::runtime_error(why);}
std::uint32_t seed=0xAA721B9u;
std::uint32_t random32(){seed^=seed<<13;seed^=seed>>17;seed^=seed<<5;return seed;}
int range(int lo,int hi){return lo+static_cast<int>(random32()%static_cast<unsigned>(hi-lo+1));}
template<class Mesh> void setup(Mesh& m,int w,int h){
 m.begin(w,h,5,1);
 for(int row=0;row<16;++row){
   std::string hex="0123456789abcdef";
   std::rotate(hex.begin(),hex.begin()+(row%16),hex.end());
   m.texture_row(0,row,hex);
 }
}
template<class Mesh>
void add_face(Mesh& m,typename Mesh::Vertex a,typename Mesh::Vertex b,
              typename Mesh::Vertex c,int material,int kind,int w,int h){
 if(kind==0)m.triangle(a,b,c,material);
 else if(kind==1)m.triangle(c,b,a,material);
 else if(kind==2){
   m.vertex(0,{-4,4,8});m.vertex(1,{4,4,18});m.vertex(2,{-4,-4,18});
   m.shade(0,32);m.shade(1,184);m.shade(2,248);
   m.gradient_face(0,1,2,32,24,w/3,w/2,h/2,1);
 }else{
   m.vertex(0,{-5,5,10});m.vertex(1,{5,5,10});m.vertex(2,{-5,-5,10});
   m.texcoord(0,0,0);m.texcoord(1,16,0);m.texcoord(2,0,16);
   m.shade(0,65);m.shade(1,190);m.shade(2,120);
   m.textured_gradient_face(0,1,2,64,24,0,12,w/3,w/2,h/2,1);
 }
}
void scenario(int w,int h,int triangles){
 Ref a;Opt b;setup(a,w,h);setup(b,w,h);
 for(int i=0;i<triangles;++i){
   const Ref::Vertex u{range(-w/3,w+w/3),range(-h/3,h+h/3),range(5,400)};
   const Ref::Vertex v{range(-w/3,w+w/3),range(-h/3,h+h/3),range(5,400)};
   const Ref::Vertex q{range(-w/3,w+w/3),range(-h/3,h+h/3),range(5,400)};
   const Opt::Vertex ou{u.x,u.y,u.z},ov{v.x,v.y,v.z},oq{q.x,q.y,q.z};
   const int mode=i%7==0?3:i%7==1?2:i%7==2?1:0;
   const int color=88+(i%48);
   add_face(a,u,v,q,color,mode,w,h);
   add_face(b,ou,ov,oq,color,mode,w,h);
 }
 auto before=a.finish(),after=b.finish();
 check(before.size()==after.size(),"XI frame size changed");
 check(before==after,"XI spatial candidates changed an output pixel");
 check(b.pixel_tests()<=a.pixel_tests(),"candidate work unexpectedly increased");
 std::cout<<"XI_SPATIAL_PARITY_OK resolution="<<w<<"x"<<h<<" faces="<<triangles
          <<" referenceTests="<<a.pixel_tests()<<" candidateTests="<<b.pixel_tests()<<'\n';
}
int main(){
 try{
  scenario(8,8,8);
  scenario(320,180,28);
  scenario(640,360,20);
  scenario(1536,864,38);
  scenario(3840,2160,34);
  // Deliberately diagonal thin faces: huge boxes, minimal coverage.
  Ref ref;Opt candidate;ref.begin(3840,2160,5,0);candidate.begin(3840,2160,5,0);
  for(int i=0;i<12;++i){
    auto a=Ref::Vertex{0,0+i*3,10},b=Ref::Vertex{3840,2150-i*3,10},c=Ref::Vertex{3840,2160-i*3,10};
    ref.triangle(a,b,c,9+i);
    candidate.triangle({a.x,a.y,a.z},{b.x,b.y,b.z},{c.x,c.y,c.z},9+i);
  }
  const auto beforeStart=std::chrono::steady_clock::now();auto before=ref.finish();
  const auto beforeMs=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-beforeStart).count();
  const auto afterStart=std::chrono::steady_clock::now();auto after=candidate.finish();
  const auto afterMs=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-afterStart).count();
  check(before==after,"4K thin diagonal changes depth/material");
  check(candidate.pixel_tests()*4<ref.pixel_tests(),"conservative spatial skip missed opportunity");
  std::cout<<"XI_SPATIAL_CANDIDATES_PASS checks="<<checks<<" referencePixels="<<ref.pixel_tests()
           <<" candidatePixels="<<candidate.pixel_tests()<<" isolatedReferenceMs="<<beforeMs
           <<" isolatedCandidateMs="<<afterMs<<'\n';
  return 0;
 }catch(const std::exception& e){std::cerr<<"XI_SPATIAL_CANDIDATES_FAIL "<<e.what()<<'\n';return 1;}
}
