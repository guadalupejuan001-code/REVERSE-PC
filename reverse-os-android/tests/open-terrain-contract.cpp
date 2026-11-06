#define main inherited_world_contract
#include "open-forest-contract.cpp"
#undef main
#include "integration/readonly_geometry.hpp"
#include <cstring>
static int i32(const std::string& b,std::size_t at){std::int32_t v;std::memcpy(&v,b.data()+at,4);return v;}
static unsigned u16(const std::string& b,std::size_t at){return (unsigned char)b[at]+256*(unsigned char)b[at+1];}
static bool groundMatches(const std::string& frame){
 const double sx=1920,sy=1080+126.0*3264/780;bool seen=false;
 for(std::size_t at=2064;at+60<=frame.size();at+=60){
  if((unsigned char)frame[at+54]!=12||(unsigned char)frame[at+55]!=8||u16(frame,at+48)!=43520||u16(frame,at+50)!=43520||u16(frame,at+52)!=43520)continue;
  double x[3],y[3],z[3];for(int v=0;v<3;v++){x[v]=i32(frame,at+12*v);y[v]=i32(frame,at+12*v+4);z[v]=i32(frame,at+12*v+8);}
  const double den=(y[1]-y[2])*(x[0]-x[2])+(x[2]-x[1])*(y[0]-y[2]);if(std::abs(den)<1e-6)continue;
  double a=((y[1]-y[2])*(sx-x[2])+(x[2]-x[1])*(sy-y[2]))/den,b=((y[2]-y[0])*(sx-x[2])+(x[0]-x[2])*(sy-y[2]))/den,c=1-a-b;
  if(a<-.00001||b<-.00001||c<-.00001)continue;
  const double depth=1/(a/z[0]+b/z[1]+c/z[2]);if(std::abs(depth-780)<8)seen=true;
 }
 return seen;
}
int main(int argc,char**argv){try{
 const std::filesystem::path root=argc>1?argv[1]:"reverse-os-android/app/src/main/assets/velocity",out=argc>2?argv[2]:"build/open-forest";
 std::filesystem::create_directories(out);Runtime seed;seed.execute(read(root/"world.xi"));const auto drive=read(root/"drive.xi"),render=read(root/"render4k.xi");
 auto command=[&](int gas,int analog=255){return header+"store8 128 "+std::to_string(gas)+"\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 0\nstore8 133 0\nstore8 134 0\nstore8 135 0\nstore8 136 0\nstore8 138 "+std::to_string(analog)+"\n"+drive.substr(header.size());};
 seed.execute(header+"store8 132 1\n"+drive.substr(header.size()));const auto initial=reverse_pc::rvpc2::save(seed);
 auto pose=[&](long long x,long long z,int speed=0){auto r=reverse_pc::rvpc2::restore(initial);r.execute(header+"store32 100 "+std::to_string(2000000000LL+x)+"\nstore32 104 "+std::to_string(2000000000LL+z)+"\nstore16 108 0\nstore16 261 32768\nstore16 263 "+std::to_string(32768+speed)+"\nstore16 110 "+std::to_string(speed)+"\nstore8 138 255\nhalt\n");return r;};
 const std::vector<std::pair<std::uint32_t,std::uint8_t>> view{{141,1},{200,1},{201,0},{202,0},{203,0},{204,0},{205,0},{206,0},{207,0}};
 int poses=0;for(const auto& p:std::vector<std::pair<long long,long long>>{{10000,25000},{15000,30000},{-18000,90000},{-13000,89000},{20000,30000},{-20000,55000},{100000,90000},{-100000,145000},{0,-20000},{0,190000},{2000000,-2000000},{-2000000,2000000}}){
  auto r=pose(p.first,p.second);State s{};for(int i=0;i<4;i++)s=observe(r.execute(command(0)));
  check(!s[14]&&s[0]==p.first&&s[1]==p.second,"open terrain never projects a distant car onto the road");
  const auto frame=reverse_pc::observe_geometry(reverse_pc::rvpc2::save(r),render,view);
  check(groundMatches(frame),"visible ground and XI wheel support agree at the car footprint");
  std::ofstream f(out/("open-terrain-"+std::to_string(poses)+".xfg4"),std::ios::binary);f.write(frame.data(),frame.size());save(r,out/("open-terrain-"+std::to_string(poses)+".rvp"));poses++;
 }
 auto freely=pose(20000,20000);State free{};for(int i=0;i<400;i++)free=observe(freely.execute(command(1)));
 check(free[0]==20000&&free[1]>35000&&!free[14],"the car drives freely more than 50m outside the road corridor");
 auto beyond=pose(0,170000);for(int i=0;i<150;i++)free=observe(beyond.execute(command(1)));check(free[1]>172000,"manual driving continues beyond the road endpoint");
 auto quarter=pose(0,-2000,500),full=pose(0,-2000,500);State q{},f{};for(int i=0;i<18;i++){q=observe(quarter.execute(command(0,125)));f=observe(full.execute(command(0,200)));}
 check(q[2]>0&&f[2]>q[2]*2,"analog quarter and full input produce different physical steering authority");
 check(f[2]>80,"low-speed maneuvering has a usable turn radius");
 auto spring=pose(0,1000);spring.execute(command(0));const auto before=reverse_pc::rvpc2::save(spring);
 auto frameAt=[&](Runtime& r){return reverse_pc::observe_geometry(reverse_pc::rvpc2::save(r),render,view);};
 const auto wind0=frameAt(spring);spring.execute(header+"store32 115 40\nhalt\n");const auto wind1=frameAt(spring);auto vegetation=[](const std::string& frame,bool grass){std::string out;for(std::size_t at=2064;at+60<=frame.size();at+=60){const auto base=(unsigned char)frame[at+54],count=(unsigned char)frame[at+55];if(grass?(base==14&&count==3):(base==12&&count==8&&u16(frame,at+48)!=43520))out.append(frame,at,36);}return out;};
 check(!vegetation(wind0,true).empty()&&vegetation(wind0,true)!=vegetation(wind1,true),"rooted grass vertices sway with the world wind tick");
 check(!vegetation(wind0,false).empty()&&vegetation(wind0,false)!=vegetation(wind1,false),"tree crowns and branches sway with the world wind tick");
 auto trunk=pose(-1914,3754);const auto hit=observe(trunk.execute(command(0)));check(hit[14]&&hit[3]==0,"the globally streamed visible trunk has a matching collider");
 std::ofstream report(out/"open-terrain-results.json");report<<"{\"passed\":true,\"supportPoses\":"<<poses<<",\"maxTestedDistanceM\":20000,\"groundSupportMatchesGeometry\":true,\"oldRoadWallRemoved\":true,\"analogSteering\":true,\"wind\":true,\"streamedTreeCollision\":true}\n";
 std::cout<<"OPEN_TERRAIN_PASS poses="<<poses<<" footprint=true freeDriving=true analog=true wind=true\n";return 0;
}catch(const std::exception&e){std::cerr<<"OPEN_TERRAIN_FAIL "<<e.what()<<"\n";return 1;}}
