#include "rvpc2.hpp"
#include <array>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <set>
#include <sstream>
#include <stdexcept>
#include <vector>
using Runtime=reverse_pc::rvpc2::Runtime;
using State=std::array<long long,32>;
const std::string header="#!reverse-pc-machine-v1\n";
int checks=0;
void check(bool ok,const std::string& why){if(!ok)throw std::runtime_error(why);checks++;}
std::string read(const std::filesystem::path& p){std::ifstream f(p,std::ios::binary);check(bool(f),"read "+p.string());return {std::istreambuf_iterator<char>(f),{}};}
std::vector<long long> numbers(const std::string& text){std::vector<long long> r;std::istringstream s(text);std::string line;while(std::getline(s,line)){auto at=line.find("\"value\":");if(at!=std::string::npos)r.push_back(std::stoll(line.substr(at+8)));}return r;}
State observe(const std::string& text){auto a=numbers(text);check(a.size()==32,"open environment ABI has 32 integer observations");State r{};std::copy(a.begin(),a.end(),r.begin());check(r[5]==0&&r[7]==0&&r[10]==0,"exploration has neither laps nor finish freeze");check(r[11]>=0&&r[11]<160000&&r[12]>=0&&r[12]<80,"finite route cursor");check(r[25]>=0&&r[25]<=3&&r[26]>=0&&r[26]<600&&r[27]>=0&&r[27]<8&&r[28]>=0&&r[28]<4096,"bounded environment fields");return r;}
void save(const Runtime& r,const std::filesystem::path& p){auto bytes=reverse_pc::rvpc2::save(r);std::ofstream f(p,std::ios::binary);f.write((const char*)bytes.data(),bytes.size());}
int main(int argc,char**argv){try{
 const std::filesystem::path root=argc>1?argv[1]:"reverse-os-android/app/src/main/assets/velocity",out=argc>2?argv[2]:"build/open-forest/gameplay";
 std::filesystem::create_directories(out);auto drive=read(root/"drive.xi"),env=read(root/"environment.xi");
 auto command=[&](int gas,int brake,int steer,int reverse=0,int assist=0,int reset=0){return header+"store8 128 "+std::to_string(gas)+"\nstore8 129 "+std::to_string(brake)+"\nstore8 130 "+std::to_string(steer)+"\nstore8 131 0\nstore8 132 "+std::to_string(reset)+"\nstore8 133 "+std::to_string(reverse)+"\nstore8 134 0\nstore8 135 0\nstore8 136 "+std::to_string(assist)+"\n"+drive.substr(header.size());};
 Runtime r;auto p=numbers(r.execute(read(root/"world.xi")));check(p.size()==162,"81 finite route samples");check(p[0]!=p[160]||p[1]!=p[161],"open road endpoints differ");check(p[161]>150000,"road traverses a 1.6 km forest");
 State s=observe(r.execute(command(0,0,1,0,0,1)));check(s[13]==0,"exploration starts without race countdown");save(r,out/"start.rvp");const auto initial=reverse_pc::rvpc2::save(r);
 auto pilot=reverse_pc::rvpc2::restore(initial);std::set<int> sectors;int contacts=0,offroad=0,steps=0;bool arrived=false,capturedBridge=false,capturedLake=false;
 for(;steps<16000;steps++){
  s=observe(pilot.execute(command(0,0,1,0,2)));sectors.insert(int(s[27]));contacts+=int(s[14]);offroad+=int(s[8]);
  if(steps%1500==0)std::cerr<<"OPEN_FOREST_PROGRESS ticks="<<steps<<" distance="<<s[11]<<" sector="<<s[27]<<" speed="<<s[3]<<" contacts="<<contacts<<"\n";
  if(s[30]==1&&!capturedBridge){save(pilot,out/"bridge.rvp");capturedBridge=true;}
  if(s[30]==2&&!capturedLake){save(pilot,out/"lake.rvp");capturedLake=true;}
  if(s[31]&&s[11]>158400&&s[3]<30){arrived=true;break;}
 }
 check(arrived&&sectors.size()==8,"pilot traverses all eight finite sectors and brakes at the road end");
 check(contacts==0,"one-lane route pilot does not strike map boundaries or water");save(pilot,out/"end.rvp");
 // Real drift events retain the elevation of the road in each mark sample.
 auto drift=reverse_pc::rvpc2::restore(initial);
 const int d=55;const double dyaw=std::atan2(double(p[(d+1)*2]-p[d*2]),double(p[(d+1)*2+1]-p[d*2+1]));
 const int heading=(int(std::round(dyaw*4096/(2*std::acos(-1.))))+4096)%4096;
 drift.execute(header+"store32 100 "+std::to_string(p[d*2]+2000000)+"\nstore32 104 "+std::to_string(p[d*2+1]+2000000)+"\nstore8 273 55\nstore16 108 "+std::to_string(heading)+"\nstore16 261 "+std::to_string(32768+int(2000*std::sin(dyaw)))+"\nstore16 263 "+std::to_string(32768+int(2000*std::cos(dyaw)))+"\nstore16 110 2000\nhalt\n");
 State drifting{};
 for(int i=0;i<8;i++)drifting=observe(drift.execute(header+"store8 128 1\nstore8 129 0\nstore8 130 2\nstore8 131 1\nstore8 132 0\nstore8 136 0\n"+drive.substr(header.size())));
 const auto markHeight=drift.memory().read("411",drift.core());
 check(markHeight.deterministic&&markHeight.value>0&&std::abs(int(markHeight.value)-int(drifting[26]))<10,"skid samples stay on the actual elevated road");
 save(drift,out/"forest-drift.rvp");
 // The map end remains playable and reverse never teleports to the old start seam.
 auto before=s;for(int i=0;i<100;i++)s=observe(pilot.execute(command(1,0,1,1,0)));
 check(s[1]>140000&&s[11]<before[11],"reverse from road end moves back through the same world");check(s[7]==0,"road end is not a race finish");
 auto reverse=reverse_pc::rvpc2::restore(initial);for(int i=0;i<80;i++)s=observe(reverse.execute(command(1,0,1,1)));
 check(s[1]<0&&s[1]>-10000&&s[11]<1000,"reverse at start cannot wrap to the far endpoint");
 // Time controls are XI-only environment transactions and do not drive the car.
 auto time=reverse_pc::rvpc2::restore(initial);State previous=observe(time.execute(header+env.substr(header.size())));
 for(int mode=1;mode<=3;mode++){
  auto now=observe(time.execute(header+"store8 137 "+std::to_string(mode)+"\n"+env.substr(header.size())));
  check(now[0]==previous[0]&&now[1]==previous[1]&&now[6]==previous[6],"changing time does not advance or move the car");
  check(now[28]==(mode==1?0:mode==2?2048:3072),"day/dusk/night XI phase");save(time,out/(mode==1?"day.rvp":mode==2?"dusk.rvp":"night.rvp"));previous=now;
 }
 const auto checkpoint=reverse_pc::rvpc2::save(pilot);auto clone=reverse_pc::rvpc2::restore(checkpoint);
 check(observe(clone.execute(command(0,1,1)))==observe(pilot.execute(command(0,1,1))),"open world and time resume exactly from RVPC2");
 // Drive into the first visible trunk from a nearby traversable patch.
 auto trunk=reverse_pc::rvpc2::restore(initial);
 trunk.execute(header+"store32 100 1999500\nstore32 104 2000000\nstore16 108 3072\nstore16 261 31568\nstore16 263 32768\nstore16 110 1200\nhalt\n");
 const auto contact=observe(trunk.execute(command(0,0,1)));
 check(contact[14]==1&&contact[0]==-500&&contact[3]==0,"a visible forest trunk blocks the car instead of being a ghost object");
 std::ofstream f(out/"results.json");f<<"{\"passed\":true,\"checks\":"<<checks<<",\"sectors\":"<<sectors.size()<<",\"traversalTicks\":"<<steps<<",\"contacts\":"<<contacts<<",\"offroadTicks\":"<<offroad<<",\"roadLengthM\":1600,\"roadWidthM\":3.6,\"androidDeviceMeasured\":false}\n";
 std::cout<<"OPEN_FOREST_GAMEPLAY_PASS checks="<<checks<<" sectors="<<sectors.size()<<" traversalTicks="<<steps<<"\n";return 0;
 }catch(const std::exception&e){std::cerr<<"OPEN_FOREST_GAMEPLAY_FAIL "<<e.what()<<"\n";return 1;}}
