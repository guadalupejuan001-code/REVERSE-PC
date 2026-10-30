#include <algorithm>
#include <array>
#include <cstdint>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string>
#include <vector>
namespace isolated {
#include "../src/integration/xi_mesh_raster.inc"
}

namespace {
using Mesh=isolated::MachineMeshRaster;
using V=Mesh::Vertex;
unsigned checks=0;
void check(bool ok,const char* why) {
  ++checks;if(!ok)throw std::runtime_error(why);
}
template<class F>void rejects(F action,const char* why) {
  bool failed=false;try{action();}catch(const std::exception&){failed=true;}
  check(failed,why);
}
unsigned u16(const std::string& bytes,std::size_t at) {
  return std::uint8_t(bytes[at])|(unsigned(std::uint8_t(bytes[at+1]))<<8);
}
std::uint32_t u32(const std::string& bytes,std::size_t at) {
  std::uint32_t value=0;
  for(unsigned i=0;i<4;++i)value|=std::uint32_t(std::uint8_t(bytes[at+i]))<<(8*i);
  return value;
}
std::vector<std::uint8_t> decode(const std::string& bytes,unsigned width,unsigned height) {
  check(bytes.size()>=24&&(bytes.size()-24)%14==0,"XFS1 alignment");
  check(bytes.substr(0,4)=="XFS1"&&bytes[4]==1&&bytes[5]==0,"XFS1 signature");
  check(u16(bytes,6)==width&&u16(bytes,8)==height&&u32(bytes,10)==2&&u16(bytes,14)==0,"XFS1 dimensions/revision");
  const auto end=bytes.size()-8;
  check(bytes[end]==3&&bytes[end+1]==0&&u16(bytes,end+2)==0&&u32(bytes,end+4)==2,"XFS1 footer");
  std::vector<std::uint8_t> pixels(width*height);
  unsigned expected_row=0,last_row=height,last_x=0,runs=0;
  for(std::size_t at=16;at<end;at+=14) {
    const unsigned material=std::uint8_t(bytes[at+1]),y=u16(bytes,at+2),
      x0=u16(bytes,at+4),x1=u16(bytes,at+6),depth=u16(bytes,at+8);
    check(bytes[at]==2&&y<height&&x0<=x1&&x1<width&&u32(bytes,at+10)==2,"XFS1 bounded span");
    if(y!=last_row) {
      check(y==expected_row++&&x0==0&&x1==width-1&&depth==100,"XFS1 background row");
      last_row=y;last_x=0;runs=0;
    }else {
      check(depth==1&&runs<47&&(runs==0||x0>last_x),"XFS1 final visible runs");
      ++runs;last_x=x1;
    }
    std::fill(pixels.begin()+y*width+x0,pixels.begin()+y*width+x1+1,std::uint8_t(material));
  }
  check(expected_row==height,"XFS1 full row coverage");return pixels;
}
void square(Mesh& m,int extent,int z,int material) {
  m.triangle({0,0,z},{extent,0,z},{0,extent,z},material);
  m.triangle({extent,0,z},{extent,extent,z},{0,extent,z},material);
}
}

int main() {
 try {
  Mesh m;
  rejects([&]{m.triangle({0,0,1},{1,0,1},{0,1,1},2);},"triangle without begin");
  rejects([&]{m.finish();},"end without begin");
  rejects([&]{m.begin(641,360,2,0);},"oversize viewport");
  rejects([&]{m.begin(640,361,2,0);},"oversize height");
  rejects([&]{m.begin(0,1,2,0);},"zero viewport");
  rejects([&]{m.begin(1,1,-1,0);},"negative revision");
  rejects([&]{m.begin(1,1,2,256);},"invalid background");
  m.begin(8,8,2,0);square(m,8,100,2);
  const auto full=m.materials();
  for(auto c:full)check(c==2,"shared triangle edge left a crack");
  check(decode(m.finish(),8,8)==full,"serialized visibility differs");
  Mesh reversed;reversed.begin(8,8,2,0);
  reversed.triangle({0,8,100},{8,0,100},{0,0,100},2);
  reversed.triangle({0,8,100},{8,8,100},{8,0,100},2);
  check(reversed.materials()==full,"two-sided winding changed coverage");

  auto occluded=[](bool near_first) {
    Mesh out;out.begin(8,8,2,0);
    if(near_first)out.triangle({0,0,20},{8,0,20},{0,8,20},3);
    square(out,8,100,2);
    if(!near_first)out.triangle({0,0,20},{8,0,20},{0,8,20},3);
    return out;
  };
  auto a=occluded(false),b=occluded(true);
  check(a.materials()==b.materials(),"near/far triangle order changed occlusion");
  check(a.materials()[1*8+1]==3&&a.materials()[7*8+7]==2,"wrong z visibility");
  check(decode(a.finish(),8,8)==a.materials(),"occluded runs differ from zbuffer");

  Mesh perspective;perspective.begin(16,16,2,0);square(perspective,16,100,2);
  perspective.triangle({0,0,10},{16,0,1000},{0,16,1000},3);
  check(perspective.materials()[1*16+1]==3,"near reciprocal depth failed");
  check(perspective.materials()[0*16+14]==2,"camera depth interpolated linearly instead of 1/z");
  Mesh tie1,tie2;tie1.begin(8,8,2,0);tie2.begin(8,8,2,0);
  square(tie1,8,100,9);square(tie1,8,100,2);
  square(tie2,8,100,2);square(tie2,8,100,9);
  check(tie1.materials()==tie2.materials(),"equal-depth tie is order dependent");

  Mesh clipped;clipped.begin(8,8,2,0);
  clipped.triangle({-32768,-32768,1},{32768,0,1000000},{0,32768,1},255);
  check(std::count(clipped.materials().begin(),clipped.materials().end(),255)>0,"large screen triangle clipping failed");
  check(decode(clipped.finish(),8,8)==clipped.materials(),"clipped triangle serialization");
  Mesh outside;outside.begin(8,8,2,7);
  outside.triangle({-20,-20,1},{-10,-20,1},{-20,-10,1},2);
  outside.triangle({1,1,1},{2,2,1},{3,3,1},2);
  for(auto c:outside.materials())check(c==7,"offscreen/degenerate triangle mutated pixels");
  rejects([&]{outside.triangle({0,0,0},{1,0,1},{0,1,1},2);},"nonpositive depth");
  rejects([&]{outside.triangle({0,0,-1},{1,0,1},{0,1,1},2);},"negative depth");
  rejects([&]{outside.triangle({0,0,1000001},{1,0,1},{0,1,1},2);},"excess depth");
  rejects([&]{outside.triangle({32769,0,1},{1,0,1},{0,1,1},2);},"excess coordinate");
  rejects([&]{outside.triangle({0,0,1},{1,0,1},{0,1,1},256);},"excess material");
  rejects([&]{outside.triangle({0,0,1},{1,0,1},{0,1,1},-1);},"negative material");

  Mesh camera;camera.begin(16,16,2,0);
  camera.triangle3({-5,5,10},{5,5,10},{-5,-5,10},4,16,8,8,1);
  Mesh projected;projected.begin(16,16,2,0);
  projected.triangle({0,0,10},{16,0,10},{0,16,10},4);
  check(camera.materials()==projected.materials(),"camera projection differs from screen triangle");
  Mesh indexed;indexed.begin(16,16,2,0);
  indexed.vertex(0,{-5,5,10});indexed.vertex(1,{5,5,10});indexed.vertex(4095,{-5,-5,10});
  const auto read_vertex=indexed.read(4095);
  check(read_vertex.x==-5&&read_vertex.y==-5&&read_vertex.z==10,"meshread differs from authored vertex");
  rejects([&]{indexed.read(2);},"unset meshread accepted");
  rejects([&]{indexed.read(4096);},"out-of-range meshread accepted");
  indexed.face(0,1,4095,4,16,8,8,1);
  check(indexed.materials()==camera.materials(),"indexed meshface differs from camera triangle");
  check(indexed.finish()==camera.finish(),"indexed face XFS1 differs");
  rejects([&]{indexed.face(0,1,2,4,16,8,8,1);},"unset indexed vertex accepted");
  rejects([&]{indexed.face(-1,1,4095,4,16,8,8,1);},"negative indexed face id accepted");
  rejects([&]{indexed.face(0,1,4096,4,16,8,8,1);},"out-of-range indexed face id accepted");
  rejects([&]{indexed.vertex(-1,{0,0,1});},"negative vertex id accepted");
  rejects([&]{indexed.vertex(4096,{0,0,1});},"out-of-range vertex id accepted");
  rejects([&]{indexed.vertex(5,{1000001,0,1});},"out-of-range indexed coordinates accepted");
  indexed.vertex(0,{-5,5,0});indexed.face(0,1,4095,4,16,8,8,2);
  indexed.begin(16,16,2,0);
  rejects([&]{indexed.face(0,1,4095,4,16,8,8,1);},"meshbegin retained previous indexed vertices");
  rejects([&]{indexed.read(0);},"meshbegin retained readable indexed vertices");
  Mesh near;near.begin(16,16,2,0);
  near.triangle3({-5,5,0},{5,5,10},{-5,-5,10},4,16,8,8,2);
  check(std::count(near.materials().begin(),near.materials().end(),4)>0,"near-plane crossing disappeared");
  Mesh near_expected;near_expected.begin(16,16,2,0);
  // Independent intersections at camera z=2 are (-5,3),(-3,5).
  // The four projected vertices form this exact clipped quadrilateral.
  near_expected.triangle({-32,-16,2},{-16,-32,2},{16,0,10},4);
  near_expected.triangle({-32,-16,2},{16,0,10},{0,16,10},4);
  check(near.materials()==near_expected.materials(),"near clipping differs from independent projected polygon");
  Mesh near_reverse;near_reverse.begin(16,16,2,0);
  near_reverse.triangle3({-5,-5,10},{5,5,10},{-5,5,0},4,16,8,8,2);
  check(near.materials()==near_reverse.materials(),"near clipping depends on winding");
  Mesh hidden;hidden.begin(16,16,2,0);
  hidden.triangle3({-5,5,-10},{5,5,0},{-5,-5,1},4,16,8,8,2);
  for(auto c:hidden.materials())check(c==0,"triangle behind near plane leaked");
  Mesh huge;huge.begin(16,16,2,0);
  huge.triangle3({-1000000,1000000,1},{1000000,1000000,1},{0,-1000000,1},255,2048,8,8,1);
  for(auto c:huge.materials())check(c==255,"huge camera projection overflowed/clamped");
  rejects([&]{hidden.triangle3({0,0,10},{1,0,10},{0,1,10},2,0,8,8,2);},"zero focal");
  rejects([&]{hidden.triangle3({0,0,10},{1,0,10},{0,1,10},2,16,8,8,0);},"zero near plane");
  rejects([&]{hidden.triangle3({1000001,0,10},{1,0,10},{0,1,10},2,16,8,8,2);},"camera coordinate budget");

  Mesh budget;budget.begin(1,1,2,0);
  for(unsigned i=0;i<Mesh::max_triangles;++i)budget.triangle({0,0,1},{0,0,1},{0,0,1},0);
  rejects([&]{budget.triangle({0,0,1},{0,0,1},{0,0,1},0);},"triangle count budget");
  Mesh work;work.begin(640,360,2,0);
  bool exhausted=false;
  for(unsigned i=0;i<100;++i)try{work.triangle({0,0,1},{640,0,1},{0,360,1},2);}
    catch(const std::length_error&){exhausted=true;break;}
  check(exhausted&&work.pixel_tests()<=Mesh::max_pixel_tests,"pixel-work budget");
  Mesh fragmented;fragmented.begin(100,1,2,0);
  for(int x=0;x<100;x+=2) {
    fragmented.triangle({x,0,1},{x+1,0,1},{x,1,1},2);
    fragmented.triangle({x+1,0,1},{x+1,1,1},{x,1,1},2);
  }
  rejects([&]{fragmented.finish();},"foreground-run output budget");
  std::cout<<"XI_MESH_RASTER_PASS checks="<<checks<<"\n";
 }catch(const std::exception& e){std::cerr<<e.what()<<"\n";return 1;}
}
