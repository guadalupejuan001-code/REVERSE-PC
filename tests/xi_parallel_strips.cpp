#include <algorithm>
#include <array>
#include <atomic>
#include <chrono>
#include <cstdint>
#include <cstring>
#include <exception>
#include <iostream>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>
namespace original {
#define REGRAPHICS_FORCE_SERIAL_STRIPS
#include "../src/integration/xi_mesh_raster.inc"
#undef REGRAPHICS_FORCE_SERIAL_STRIPS
}
namespace parallel {
#include "../src/integration/xi_mesh_raster.inc"
}
static int checks=0;
static void require(bool v,const char* why){++checks;if(!v)throw std::runtime_error(why);}
static uint32_t seed=0x1d721c43;
static uint32_t rnd(){seed^=seed<<13;seed^=seed>>17;seed^=seed<<5;return seed;}
static int r(int lo,int hi){return lo+int(rnd()%unsigned(hi-lo+1));}
template<class M> static void prepare(M& mesh,unsigned width,unsigned height){
 mesh.begin(width,height,5,3);
 for(int y=0;y<16;y++){
   std::string row="0123456789abcdef";
   std::rotate(row.begin(),row.begin()+y,row.end());
   mesh.texture_row(0,y,row);
 }
}
template<class M> static void face(M& mesh,typename M::Vertex a,typename M::Vertex b,typename M::Vertex c,int index){
 if(index%7==0)mesh.triangle(c,b,a,9+index%120);
 else mesh.triangle(a,b,c,9+index%120);
}
template<class M> static void extra_gradient(M& mesh,int width,int height,int i){
 mesh.vertex(0,{-7,6,14});mesh.vertex(1,{7,6,17});mesh.vertex(2,{-7,-6,22});
 mesh.texcoord(0,i,0);mesh.texcoord(1,16+i,0);mesh.texcoord(2,i,16);
 mesh.shade(0,70+i);mesh.shade(1,180);mesh.shade(2,250-i);
 mesh.textured_gradient_face(0,1,2,72,24,0,9,width/2,width/2,height/2,1);
}
static void case_one(int w,int h,int count,uint32_t initial){
 seed=initial;
 original::MachineMeshRaster a;parallel::MachineMeshRaster b;
 prepare(a,w,h);prepare(b,w,h);
 for(int i=0;i<count;i++){
   int x=r(-150,w+120),y=r(-100,h+80),dx=r(20,230),dy=r(8,165),z=r(4,800);
   if(i%4==0)dx=r(300,std::min(1000,w+400));
   original::MachineMeshRaster::Vertex p{x,y,z},q{x+dx,y+dy,z},s{x+dx,y+dy+r(1,20),z};
   face(a,p,q,s,i);
   face(b,{p.x,p.y,p.z},{q.x,q.y,q.z},{s.x,s.y,s.z},i);
 }
 for(int i=0;i<10;i++){extra_gradient(a,w,h,i);extra_gradient(b,w,h,i);}
 auto baseline=a.finish(),candidate=b.finish();
 require(baseline==candidate,"parallel XI output differs from serial XI");
 require(a.pixel_tests()==b.pixel_tests(),"concurrent XI work budget diverged");
 require(candidate.size()==16ULL+unsigned(w)*h,"4K frame byte count");
 require(candidate.substr(0,4)=="XFB5","same XI output format");
 require(a.native_workers_used()==1,"serial reference must use one worker");
 if(w>=1280&&count>=128&&std::thread::hardware_concurrency()>1)
   require(b.native_workers_used()>1,"large native scenes must use parallel regions");
 require(b.finish()==candidate,"repeated parallel rendering is not deterministic");
 std::cout<<"XI_PARALLEL_STRIPS_EQUAL width="<<w<<" height="<<h<<" faces="<<count
          <<" work="<<a.pixel_tests()<<" checks="<<checks<<'\n';
}
int main(){
 try{
  case_one(320,180,200,0x4a1);
  case_one(1280,720,210,0x4a2);
  case_one(1920,1080,220,0x4a3);
  case_one(3840,2160,225,0x4a4);
  // Even with concurrent workers the global XI work ceiling must hold.
  parallel::MachineMeshRaster heavy;
  heavy.begin(1280,720,5,0);
  for(int i=0;i<150;i++)
    heavy.triangle({0,0,10},{1280,0,10},{0,720,10},8+i%10);
  bool rejected=false;
  try{(void)heavy.finish();}
  catch(const std::length_error&){rejected=true;}
  require(rejected,"parallel work must not bypass global XI pixel budget");
  std::cout<<"XI_PARALLEL_STRIPS_PASS checks="<<checks
           <<" availableWorkers="<<std::thread::hardware_concurrency()<<'\n';
 }catch(const std::exception& e){
  std::cerr<<"XI_PARALLEL_STRIPS_FAIL "<<e.what()<<'\n';return 1;
 }
}
