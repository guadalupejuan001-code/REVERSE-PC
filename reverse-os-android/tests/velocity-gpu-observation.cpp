#define main inherited_open_forest_contract
#include "open-forest-contract.cpp"
#undef main
#include "integration/readonly_geometry.hpp"
int main(int argc,char**argv){try{
 const std::filesystem::path root=argc>1?argv[1]:"reverse-os-android/app/src/main/assets/velocity",out=argc>2?argv[2]:"build/open-forest";
 const auto source=read(root/"render4k.xi");Runtime seed;seed.execute(read(root/"world.xi"));seed.execute(header+"store8 128 0\nstore8 129 0\nstore8 130 1\nstore8 132 1\n"+read(root/"drive.xi").substr(header.size()));
 const auto initial=reverse_pc::rvpc2::save(seed);int cases=0;
 for(int yaw:{0,700,2048,4095})for(int pitch:{0,450}){
  const std::vector<std::pair<std::uint32_t,std::uint8_t>> input{{200,1},{201,0},{202,0},{203,0},{204,std::uint8_t(yaw)},{205,std::uint8_t(yaw>>8)},{206,std::uint8_t(pitch)},{207,std::uint8_t(pitch>>8)}};
  const auto actual=reverse_pc::observe_geometry(initial,source,input);
  auto legacy=reverse_pc::rvpc2::restore(initial);const auto expected=legacy.execute(header+"store8 200 1\nstore8 201 0\nstore8 202 0\nstore8 203 0\nstore16 204 "+std::to_string(yaw)+"\nstore16 206 "+std::to_string(pitch)+"\n"+source.substr(header.size()));
  check(actual==expected,"immutable byte mailbox equals XI-authored control instructions");
  check(reverse_pc::rvpc2::save(seed)==initial,"GPU observation cannot mutate authoritative Ether");
  std::ofstream f(out/("gpu-"+std::to_string(yaw)+"-"+std::to_string(pitch)+".xfg4"),std::ios::binary);f.write(actual.data(),actual.size());cases++;
 }

 const auto route=numbers(seed.execute(read(root/"world.xi")));
 const auto drive=read(root/"drive.xi");
 const auto command=[&](int nitro,int jump,int gas){return header+"store8 128 "+std::to_string(gas)+"\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 0\nstore8 133 0\nstore8 134 "+std::to_string(nitro)+"\nstore8 135 "+std::to_string(jump)+"\nstore8 136 0\n"+drive.substr(header.size());};
 auto pose=[&](int segment,int lateral,int speed){
  auto r=reverse_pc::rvpc2::restore(initial);double dx=route[2*segment+2]-route[2*segment],dz=route[2*segment+3]-route[2*segment+1],len=std::hypot(dx,dz),a=std::atan2(dx,dz);
  long long x=std::llround((route[2*segment]+route[2*segment+2])/2.+lateral*dz/len),z=std::llround((route[2*segment+1]+route[2*segment+3])/2.-lateral*dx/len);
  int heading=(int(std::llround(a*4096/(2*std::acos(-1.))))+4096)%4096;
  r.execute(header+"store32 100 "+std::to_string(2000000+x)+"\nstore32 104 "+std::to_string(2000000+z)+"\nstore8 273 "+std::to_string(segment)+"\nstore16 108 "+std::to_string(heading)+"\nstore16 261 "+std::to_string(32768+int(speed*std::sin(a)))+"\nstore16 263 "+std::to_string(32768+int(speed*std::cos(a)))+"\nstore16 110 "+std::to_string(speed)+"\nhalt\n");return r;
 };
 auto dry=pose(1,0,1200),mud=pose(21,0,1200),water=pose(28,0,1200),puddle=pose(4,0,1200);State d{},m{},w{},p{};
 for(int i=0;i<4;i++){d=observe(dry.execute(command(0,0,0)));m=observe(mud.execute(command(0,0,0)));w=observe(water.execute(command(0,0,0)));p=observe(puddle.execute(command(0,0,0)));}
 check(m[25]==3&&m[3]<d[3]&&m[33]>d[33],"mud changes physical drag and accumulated wetness");
 check(w[25]==4&&w[32]>0&&w[34]>0&&w[3]<d[3],"river has depth, spray and water drag");
 check(p[32]==4&&p[34]>0,"authored standing puddle has a physical wet footprint");
 save(water,out/"gpu-ford.rvp");
 for(int lateral:{-1000,1000}){auto r=pose(28,lateral,0);auto s=observe(r.execute(command(0,0,0)));check(s[14]&&s[3]==0,"both ford banks are bounded without signed16 exceptions");}
 const std::vector<std::pair<std::uint32_t,std::uint8_t>> view{{200,1},{201,0},{202,0},{203,0},{204,188},{205,2},{206,0},{207,0}};
 auto geometry=[&](const Runtime& r,const std::string& name){const auto frame=reverse_pc::observe_geometry(reverse_pc::rvpc2::save(r),source,view);std::ofstream f(out/(name+".xfg4"),std::ios::binary);f.write(frame.data(),frame.size());return frame;};
 auto countBase=[](const std::string& frame,int base){int n=0;for(std::size_t at=2064;at+60<=frame.size();at+=60)if((unsigned char)frame[at+54]==base)n++;return n;};
 auto effects=reverse_pc::rvpc2::restore(initial);effects.execute(command(1,0,1));const auto nitro=geometry(effects,"gpu-nitro");
 bool effectUvs=false;for(std::size_t at=2064;at+60<=nitro.size();at+=60)if((unsigned char)nitro[at+54]==56)for(int k=36;k<48;k++)effectUvs|=nitro[at+k]!=0;
 check(effectUvs,"GPU jet envelope UVs are transported by XI");
 check(countBase(nitro,56)>=16,"four crossed rear jets generate sixteen XI triangles");
 effects.execute(command(0,1,0));for(int i=0;i<15;i++)effects.execute(command(0,0,0));const auto air=geometry(effects,"gpu-air");
 check(countBase(air,244)>=16,"four wheel nozzles generate visible pneumatic geometry in flight");
 const auto ford=geometry(water,"gpu-ford");check(countBase(ford,32)>4,"river and splash have real XI geometry");
 auto squirrel=pose(18,0,0);squirrel.execute(command(0,0,0));const auto animals=geometry(squirrel,"gpu-squirrel");
 const auto physical=reverse_pc::rvpc2::save(squirrel);
 auto hiddenView=view;hiddenView.push_back({139,1});const auto hidden=reverse_pc::observe_geometry(physical,source,hiddenView);
 check(animals!=hidden&&animals.size()>=hidden.size()+40*60,"squirrel geometry is causally present near the road");
 bool rejected=false;try{reverse_pc::observe_geometry(initial,header+"halt\n",{});}catch(const std::invalid_argument&){rejected=true;}check(rejected,"GPU protocol rejects non-geometry XI programs");
 rejected=false;try{reverse_pc::observe_geometry(initial,source,std::vector<std::pair<std::uint32_t,std::uint8_t>>(33));}catch(const std::length_error&){rejected=true;}check(rejected,"GPU mailbox has a finite budget");
 std::cout<<"VELOCITY_GPU_OBSERVATION_PASS cases="<<cases<<" immutable=true byteExact=true\n";return 0;
}catch(const std::exception& e){std::cerr<<"VELOCITY_GPU_OBSERVATION_FAIL "<<e.what()<<"\n";return 1;}}
