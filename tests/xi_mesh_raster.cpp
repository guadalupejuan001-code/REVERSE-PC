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
      check(depth==1&&runs<width&&(runs==0||x0>last_x),"XFS1 final visible runs");
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
  Mesh fragmented;fragmented.begin(640,1,2,0);
  for(int x=0;x<640;++x) {
    const int material=2+x%2;
    fragmented.triangle({x,0,1},{x+1,0,1},{x,1,1},material);
    fragmented.triangle({x+1,0,1},{x+1,1,1},{x,1,1},material);
  }
  for(unsigned x=0;x<640;++x)
    check(fragmented.materials()[x]==2+x%2,"one-pixel material visibility changed");
  const auto fragmented_packet=fragmented.finish();
  check((fragmented_packet.size()-24)/14==641,"maximum valid row lost final runs");
  check(decode(fragmented_packet,640,1)==fragmented.materials(),
        "alternating maximum-width row failed exact XFS1 roundtrip");

  auto gradient_quad=[](Mesh& out,int base,int count,int z=10) {
    out.vertex(0,{-5,5,z});out.vertex(1,{5,5,z});
    out.vertex(2,{-5,-5,z});out.vertex(3,{5,-5,z});
    out.shade(0,0);out.shade(1,255);out.shade(2,0);out.shade(3,255);
    out.gradient_face(0,1,2,base,count,16,8,8,1);
    out.gradient_face(1,3,2,base,count,16,8,8,1);
  };
  Mesh gradient;gradient.begin(16,16,2,0);gradient_quad(gradient,64,24);
  for(unsigned y=0;y<16;++y)for(unsigned x=0;x<16;++x)
    check(gradient.materials()[y*16+x]==64+((2*x+1)*23+16)/32,
          "gradient shared edge, interpolation or palette rounding changed");
  check(decode(gradient.finish(),16,16)==gradient.materials(),"gradient XFS1 final runs changed pixels");

  Mesh constant_gradient;constant_gradient.begin(16,16,2,0);gradient_quad(constant_gradient,93,1);
  for(auto material:constant_gradient.materials())check(material==93,"single-entry gradient ramp changed material");
  Mesh brightest;brightest.begin(16,16,2,0);
  brightest.vertex(0,{-5,5,10});brightest.vertex(1,{5,5,10});brightest.vertex(2,{-5,-5,10});
  brightest.shade(0,255);brightest.shade(1,255);brightest.shade(2,255);
  brightest.gradient_face(0,1,2,0,256,16,8,8,1);
  check(brightest.materials()[0]==255,"full palette ramp did not reach material255");
  brightest.vertex(0,{-5,5,10});brightest.vertex(1,{5,5,10});brightest.vertex(2,{-5,-5,10});
  Mesh defaults;defaults.begin(16,16,2,0);
  defaults.vertex(0,{-5,5,10});defaults.vertex(1,{5,5,10});defaults.vertex(2,{-5,-5,10});
  defaults.gradient_face(0,1,2,64,24,16,8,8,1);
  check(defaults.materials()[0]==64,"new mesh vertex intensity was not zero");
  // Replacing vertices resets a previously assigned attribute, while a flat
  // face remains completely independent of shade attributes.
  brightest.gradient_face(0,1,2,0,256,16,8,8,1);
  Mesh reset_shade;reset_shade.begin(16,16,2,0);
  reset_shade.vertex(0,{-5,5,10});reset_shade.shade(0,255);reset_shade.vertex(0,{-5,5,10});
  reset_shade.vertex(1,{5,5,10});reset_shade.vertex(2,{-5,-5,10});
  reset_shade.gradient_face(0,1,2,64,24,16,8,8,1);
  check(reset_shade.materials()==defaults.materials(),"meshvertex retained stale intensity");

  Mesh perspective_gradient;perspective_gradient.begin(16,16,2,0);
  perspective_gradient.vertex(0,{-5,5,10});
  perspective_gradient.vertex(1,{500,500,1000});
  perspective_gradient.vertex(2,{-500,-500,1000});
  perspective_gradient.shade(0,0);perspective_gradient.shade(1,255);perspective_gradient.shade(2,255);
  perspective_gradient.gradient_face(0,1,2,64,24,16,8,8,1);
  check(perspective_gradient.materials()[1*16+1]==64,"intensity used affine screen-space interpolation");
  for(unsigned y=0;y<15;++y)for(unsigned x=0;x<15-y;++x) {
    const long double w0=(15.0L-x-y)/16.0L,w1=(x+.5L)/16.0L,w2=(y+.5L)/16.0L;
    const long double intensity=255*(w1/1000+w2/1000)/(w0/10+w1/1000+w2/1000);
    const int expected=64+static_cast<int>(intensity*23/255+.5L);
    const int actual=perspective_gradient.materials()[y*16+x];
    check(actual>=expected-1&&actual<=expected+1,"perspective intensity differs from independent I/z oracle");
  }

  auto gradient_occlusion=[&](bool near_first,bool equal_depth) {
    Mesh out;out.begin(16,16,2,0);
    const int far_z=equal_depth?10:1000;
    if(near_first)gradient_quad(out,64,24);
    square(out,16,far_z,70);
    if(!near_first)gradient_quad(out,64,24);
    return out;
  };
  check(gradient_occlusion(false,false).materials()==gradient_occlusion(true,false).materials(),
        "gradient visibility depends on near/far submission order");
  check(gradient_occlusion(false,true).materials()==gradient_occlusion(true,true).materials(),
        "gradient equal-depth tie compares base material instead of sampled material");

  Mesh near_gradient;near_gradient.begin(16,16,2,0);
  near_gradient.vertex(0,{-5,5,0});near_gradient.vertex(1,{5,5,10});near_gradient.vertex(2,{-5,-5,10});
  near_gradient.shade(0,0);near_gradient.shade(1,255);near_gradient.shade(2,0);
  near_gradient.gradient_face(0,1,2,64,24,16,8,8,2);
  Mesh near_gradient_expected;near_gradient_expected.begin(16,16,2,0);
  near_gradient_expected.vertex(0,{-5,3,2});near_gradient_expected.vertex(1,{-3,5,2});
  near_gradient_expected.vertex(2,{5,5,10});near_gradient_expected.vertex(3,{-5,-5,10});
  near_gradient_expected.shade(0,0);near_gradient_expected.shade(1,51);
  near_gradient_expected.shade(2,255);near_gradient_expected.shade(3,0);
  near_gradient_expected.gradient_face(0,1,2,64,24,16,8,8,2);
  near_gradient_expected.gradient_face(0,2,3,64,24,16,8,8,2);
  check(near_gradient.materials()==near_gradient_expected.materials(),"near clipping failed independent interpolated-attribute polygon");
  Mesh reversed_gradient;reversed_gradient.begin(16,16,2,0);
  reversed_gradient.vertex(0,{-5,5,0});reversed_gradient.vertex(1,{5,5,10});reversed_gradient.vertex(2,{-5,-5,10});
  reversed_gradient.shade(0,0);reversed_gradient.shade(1,255);reversed_gradient.shade(2,0);
  reversed_gradient.gradient_face(2,1,0,64,24,16,8,8,2);
  check(reversed_gradient.materials()==near_gradient.materials(),"gradient clipping or winding changed shade association");
  Mesh huge_gradient;huge_gradient.begin(16,16,2,0);
  huge_gradient.vertex(0,{-1000000,1000000,1});huge_gradient.vertex(1,{1000000,1000000,1});
  huge_gradient.vertex(2,{0,-1000000,1});
  huge_gradient.shade(0,0);huge_gradient.shade(1,255);huge_gradient.shade(2,128);
  huge_gradient.gradient_face(0,1,2,0,256,2048,8,8,1);
  for(auto material:huge_gradient.materials())check(material>=127&&material<=128,"bounded huge gradient overflowed");

  rejects([&]{defaults.shade(3,12);},"shade accepted unset vertex");
  rejects([&]{defaults.shade(4096,12);},"shade accepted excessive vertex id");
  rejects([&]{defaults.shade(0,-1);},"negative shade accepted");
  rejects([&]{defaults.shade(0,256);},"excess shade accepted");
  rejects([&]{defaults.gradient_face(0,1,2,64,0,16,8,8,1);},"zero palette ramp accepted");
  rejects([&]{defaults.gradient_face(0,1,2,0,257,16,8,8,1);},"oversize palette ramp accepted");
  rejects([&]{defaults.gradient_face(0,1,2,243,24,16,8,8,1);},"overflowing palette ramp accepted");
  rejects([&]{defaults.gradient_face(0,1,2,-1,24,16,8,8,1);},"negative palette base accepted");
  rejects([&]{defaults.gradient_face(0,1,3,64,24,16,8,8,1);},"gradient accepted unset face vertex");
  defaults.begin(16,16,2,0);
  rejects([&]{defaults.shade(0,12);},"meshbegin retained shade-ready vertices");

  // Golden recorded before adding the gradient path. Flat raster coverage,
  // clipping, deterministic depth ties and XFS1 bytes must remain unchanged.
  Mesh flat_golden;flat_golden.begin(64,36,2,3);std::uint32_t random=42;
  auto next_random=[&](){random=random*1664525U+1013904223U;return random;};
  for(unsigned i=0;i<100;++i) {
    auto vertex=[&](){return V{std::int64_t(next_random()%401)-200,
      std::int64_t(next_random()%301)-150,std::int64_t(next_random()%401)-50};};
    const auto a=vertex(),b=vertex(),c=vertex();
    flat_golden.triangle3(a,b,c,next_random()%256,60,32,18,5);
  }
  std::uint64_t flat_hash=UINT64_C(14695981039346656037);
  for(unsigned char byte:flat_golden.finish()){flat_hash^=byte;flat_hash*=UINT64_C(1099511628211);}
  check(flat_hash==UINT64_C(17159164121277665824),"legacy flat XFS1 bytes changed after gradient addition");
  std::cout<<"XI_MESH_RASTER_PASS checks="<<checks<<"\n";
 }catch(const std::exception& e){std::cerr<<e.what()<<"\n";return 1;}
}
