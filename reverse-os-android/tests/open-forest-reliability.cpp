#define main open_forest_previous_contract
#include "open-forest-contract.cpp"
#undef main
#include <algorithm>

std::vector<unsigned char> materialPixels(const std::string& frame){
 const auto u16=[&](std::size_t at){return (unsigned char)frame.at(at)+256*(unsigned char)frame.at(at+1);};
 if(frame.substr(0,4)=="XFB5")return {frame.begin()+16,frame.end()};
 check(frame.substr(0,4)=="XFS1","reference packet signature");
 const auto w=u16(6),h=u16(8);std::vector<unsigned char> out(w*h);
 for(std::size_t at=16;at+14<=frame.size()-8;at+=14){
  const auto y=u16(at+2),x0=u16(at+4),x1=u16(at+6);
  check(y<h&&x0<=x1&&x1<w,"bounded reference spans");
  std::fill(out.begin()+y*w+x0,out.begin()+y*w+x1+1,(unsigned char)frame[at+1]);
 }
 return out;
}
int main(int argc,char** argv){int pose=0;try{
 const std::filesystem::path root=argc>1?argv[1]:"reverse-os-android/app/src/main/assets/velocity";
 const std::filesystem::path output=argc>2?argv[2]:"build/v31";
 std::filesystem::create_directories(output);
 const auto drive=read(root/"drive.xi"),live=read(root/"render-live.xi"),reference=read(root/"render.xi");
 check(live==[&]{auto s=reference;const std::string from="meshbegin r0 r1 2 0";s.replace(s.find(from),from.size(),"meshbegin r0 r1 5 0");return s;}(),"live geometry and materials are the reference XI scene");
 Runtime seed;const auto p=numbers(seed.execute(read(root/"world.xi")));
 const auto input=[&](int n,int reverse){return header+"store8 128 "+std::to_string(n<36)+"\nstore8 129 "+std::to_string(n>=36)+"\nstore8 130 "+std::to_string(n<12?1:pose%3)+"\nstore8 131 "+std::to_string(n>=18&&n<30)+"\nstore8 132 0\nstore8 133 "+std::to_string(reverse)+"\nstore8 134 "+std::to_string(n<5)+"\nstore8 135 "+std::to_string(n==10)+"\nstore8 136 "+std::to_string(pose%3)+"\n"+drive.substr(header.size());};
 seed.execute(input(48,0));const auto initial=reverse_pc::rvpc2::save(seed);int ticks=0,comparisons=0;
 for(int segment:{0,11,27,28,32,49,55,63,79})for(int side:{-500,0,500})for(int direction=0;direction<2;direction++,pose++){
  auto r=reverse_pc::rvpc2::restore(initial);
  const double dx=p[2*segment+2]-p[2*segment],dz=p[2*segment+3]-p[2*segment+1],length=std::hypot(dx,dz);
  const int heading=(int(std::llround(std::atan2(dx,dz)*4096/(2*std::acos(-1.))))+4096+pose%4*1024)%4096;
  const auto x=std::llround((p[2*segment]+p[2*segment+2])/2.+side*dz/length);
  const auto z=std::llround((p[2*segment+1]+p[2*segment+3])/2.-side*dx/length);
  r.execute(header+"store32 100 "+std::to_string(2000000+x)+"\nstore32 104 "+std::to_string(2000000+z)+"\nstore8 273 "+std::to_string(segment)+"\nstore16 108 "+std::to_string(heading)+"\nstore8 137 "+std::to_string(1+pose%3)+"\nhalt\n");
  for(int n=0;n<48;n++){const auto s=observe(r.execute(input(n,direction)));check(std::abs(s[0])<100000&&s[1]>-10000&&s[1]<180000,"manual physics stays in the finite world");ticks++;}
  const auto retained=reverse_pc::rvpc2::save(r);
  const int stride=pose%3==0?4:pose%3==1?2:1;
  const auto visual=header+"store8 200 "+std::to_string(stride)+"\nstore8 201 "+std::to_string(pose%3)+"\nstore8 202 "+std::to_string(pose%5)+"\nstore8 203 "+std::to_string(pose%3)+"\nstore16 204 "+std::to_string(pose*293%4096)+"\nstore16 206 "+std::to_string(pose%2==0?0:450)+"\n";
  auto a=reverse_pc::rvpc2::restore(retained),b=reverse_pc::rvpc2::restore(retained);
  const auto native=a.execute(visual+live.substr(header.size())),legacy=b.execute(visual+reference.substr(header.size()));
  check(native.substr(0,4)=="XFB5","manual live frame uses exact native pixels");
  check(materialPixels(native)==materialPixels(legacy),"native strip frame is pixel-identical to reference while exploring");
  comparisons++;save(r,output/"last-reliability-pose.rvp");
 }
 std::ofstream out(output/"reliability-results.json");out<<"{\"passed\":true,\"poses\":"<<pose<<",\"physicsTicks\":"<<ticks<<",\"pixelComparisons\":"<<comparisons<<",\"unsigned16Failures\":0,\"phoneMeasured\":false}\n";
 std::cout<<"OPEN_FOREST_RELIABILITY_PASS poses="<<pose<<" ticks="<<ticks<<" exactFrames="<<comparisons<<"\n";return 0;
}catch(const std::exception& e){std::cerr<<"OPEN_FOREST_RELIABILITY_FAIL pose="<<pose<<" "<<e.what()<<"\n";return 1;}}
