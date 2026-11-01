// Test-only driver: the real XI source owns physics, opponents and race rules.
#include "rvpc2.hpp"
#include <algorithm>
#include <array>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <iterator>
#include <map>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>
using Runtime=reverse_pc::rvpc2::Runtime;
using Bytes=std::vector<std::uint8_t>;
using State=std::array<std::int64_t,22>;
using Clock=std::chrono::steady_clock;
const std::string header="#!reverse-pc-machine-v1\n";
static std::size_t checks=0;
void check(bool ok,const std::string& why){if(!ok)throw std::runtime_error(why);++checks;}
std::string read(const std::filesystem::path& p){std::ifstream f(p,std::ios::binary);check(bool(f),"Missing "+p.string());return {std::istreambuf_iterator<char>(f),{}};}
void write(const std::filesystem::path& p,const Bytes& b){std::ofstream f(p,std::ios::binary);f.write(reinterpret_cast<const char*>(b.data()),b.size());check(bool(f),"write snapshot");}
std::string inject(const std::string& body,const std::string& prefix){check(body.compare(0,header.size(),header)==0,"XI header");return header+prefix+body.substr(header.size());}
std::vector<std::int64_t> numbers(const std::string& text,bool world=false){
 std::istringstream lines(text);std::string row;std::vector<std::int64_t> out;
 while(std::getline(lines,row)){if(row.empty())continue;const auto idx=world?out.size()%2:out.size();
  const std::string prefix="{\"type\":\"register\",\"register\":\"r"+std::to_string(idx)+"\",\"value\":";
  check(row.compare(0,prefix.size(),prefix)==0&&row.back()=='}',"XI register ABI");
  std::size_t consumed=0;const auto value=std::stoll(row.substr(prefix.size(),row.size()-prefix.size()-1),&consumed);
  check(consumed==row.size()-prefix.size()-1,"integer observation");out.push_back(value);
 }return out;
}
State state(const std::string& text){const auto n=numbers(text);check(n.size()==22,"22 authoritative game registers");State s{};std::copy(n.begin(),n.end(),s.begin());
 check(s[0]>=-100000&&s[0]<=150000&&s[1]>=-100000&&s[1]<=150000,"bounded world position");
 check(s[2]>=0&&s[2]<4096&&s[3]>=0&&s[3]<=10000,"bounded heading/speed");
 check(s[5]>=0&&s[5]<=12&&s[6]>=0&&s[7]>=0&&s[7]<=1&&s[8]>=0&&s[8]<=1,"progress/clock flags");
 check(s[9]>=1&&s[9]<=4&&s[10]>=0&&s[10]<=3&&s[11]>=0&&s[11]<160000,"race observations");
 check(s[12]>=0&&s[12]<80&&s[13]>=0&&s[13]<=150&&s[14]>=0&&s[14]<=1,"segment/countdown/wall flags");
 check(s[15]>=0&&s[15]<=480000,"unwrapped progress");
 check(s[16]>=0&&s[16]<=1000&&s[17]>=0&&s[17]<=1&&s[18]>=0&&s[18]<=300&&
       s[19]>=0&&s[19]<=30&&s[20]>=0&&s[20]<=90&&s[21]>=0&&s[21]<=1,
       "bounded XI turbo/compressor telemetry");return s;
}
struct Input{int gas=0,brake=0,steer=1,drift=0,nitro=0,jump=0;};
struct Point{double x,z;};
double yaw(double dx,double dz){double value=std::atan2(dx,dz)*4096/(2*std::acos(-1.));if(value<0)value+=4096;return value;}
double difference(double a,double b){double d=a-b;while(d>2048)d-=4096;while(d< -2048)d+=4096;return d;}
std::uint16_t observed16(const Runtime& runtime,unsigned address){const auto a=runtime.memory().read(std::to_string(address),runtime.core()),b=runtime.memory().read(std::to_string(address+1),runtime.core());check(a.deterministic&&b.deterministic,"classical input observation");return unsigned(a.value)+256u*b.value;}
int main(int argc,char** argv){try{
 const std::filesystem::path assets=argc>1?argv[1]:"reverse-os-android/app/src/main/assets/velocity";
 const std::filesystem::path out=argc>2?argv[2]:"build/velocity/gameplay";
 const int limit=argc>3?std::stoi(argv[3]):15000;
 const double gain=argc>4?std::stod(argv[4]):3.0;
 const int lookahead=argc>5?std::stoi(argv[5]):3;
 const int curveSpeed=argc>6?std::stoi(argv[6]):2600;
 std::filesystem::create_directories(out);
 const auto drive=read(assets/"drive.xi"),world=read(assets/"world.xi");
 std::map<int,std::string> programs;
 auto command=[&](Input i)->const std::string&{const int key=i.gas+2*i.brake+4*i.steer+16*i.drift+128*i.nitro+256*i.jump;auto found=programs.find(key);if(found!=programs.end())return found->second;
  return programs.emplace(key,inject(drive,"store8 128 "+std::to_string(i.gas)+"\nstore8 129 "+std::to_string(i.brake)+"\nstore8 130 "+std::to_string(i.steer)+"\nstore8 131 "+std::to_string(i.drift)+"\nstore8 132 0\nstore8 134 "+std::to_string(i.nitro)+"\nstore8 135 "+std::to_string(i.jump)+"\n")).first->second;};
 Runtime runtime;const auto coords=numbers(runtime.execute(world),true);check(coords.size()==162,"81 observed XI vertices");
 std::vector<Point> points;for(std::size_t i=0;i<coords.size();i+=2)points.push_back({double(coords[i]),double(coords[i+1])});
 check(points.front().x==points.back().x&&points.front().z==points.back().z,"closed XI world");
 auto reset=inject(drive,"store8 128 0\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 1\n");
 State s=state(runtime.execute(reset));check(s[0]==0&&s[1]==0&&s[2]==0&&s[13]==150&&s[5]==0,"new race reset");
 const State ready=s;const auto seed=reverse_pc::rvpc2::save(runtime);write(out/"seed.rvp",seed);
 for(int i=0;i<10;i++)check(state(runtime.execute(command({})))==ready,"idle before throttle must wait");
 int countdown=0;while(s[13]>0&&countdown<151){const auto old=s;s=state(runtime.execute(command({1,0,1,0})));++countdown;
  if(s[13]>0)check(s[0]==old[0]&&s[1]==old[1]&&s[3]==0,"countdown must not move car");}
 check(s[13]==0&&countdown==150,"exact 150-tick countdown");
 const auto raceStart=reverse_pc::rvpc2::save(runtime);
 // XI authority: nitro consumes energy and makes the same physical car accelerate.
 auto turbo=reverse_pc::rvpc2::restore(raceStart),cruise=reverse_pc::rvpc2::restore(raceStart);
 State boosted{},normal{};
 for(int i=0;i<35;i++){
   boosted=state(turbo.execute(command({1,0,1,0,1,0})));
   normal=state(cruise.execute(command({1,0,1,0,0,0})));
 }
 check(boosted[3]>normal[3]+500&&boosted[16]<1000&&boosted[17]==1,
       "nitro accelerates the real XI vehicle and consumes energy");
 for(int i=0;i<8;i++)boosted=state(turbo.execute(command({1,0,1,0,0,0})));
 check(boosted[17]==0&&boosted[16]>825,"nitro regenerates when released");
 auto pneumatic=reverse_pc::rvpc2::restore(raceStart);
 State airborne=state(pneumatic.execute(command({1,0,1,0,0,1})));
 check(airborne[18]>0&&airborne[19]>0&&airborne[20]>0,
       "four-wheel pressure impulse starts a real vertical trajectory");
 bool landed=false;int apex=int(airborne[18]);
 for(int i=0;i<110;i++){
   airborne=state(pneumatic.execute(command({1,0,1,0,0,1})));
   apex=std::max(apex,int(airborne[18]));
   landed|=airborne[21]==1;
 }
 check(apex>=100&&landed&&airborne[18]==0,
       "gravity brings chassis down; a held jump cannot auto-repeat");
 state(pneumatic.execute(command({1,0,1,0,0,0})));
 airborne=state(pneumatic.execute(command({1,0,1,0,0,1})));
 check(airborne[18]>0&&airborne[19]>0,
       "jump can fire again only after release and cooldown");
 // Causal branches from an identical authoritative snapshot: no host
 // integration of movement, acceleration, tire grip or collision rules.
 auto accelerated=reverse_pc::rvpc2::restore(raceStart);State moving{};
 for(int i=0;i<180;i++)moving=state(accelerated.execute(command({1,0,1,0})));
 check(moving[3]>1000&&moving[1]>0,"XI throttle produces world-space motion");
 // Reverse is a genuine world-space XI drivetrain state, not a negative HUD number.
 auto reverseRuntime=reverse_pc::rvpc2::restore(raceStart);
 const std::string gearReverse=inject(drive,
  "store8 128 1\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 0\nstore8 133 1\n");
 const std::string reverseBrake=inject(drive,
  "store8 128 0\nstore8 129 1\nstore8 130 1\nstore8 131 0\nstore8 132 0\nstore8 133 1\n");
 State backwards{};
 for(int i=0;i<30;i++)backwards=state(reverseRuntime.execute(gearReverse));
 check(backwards[1]<-10&&backwards[3]>0&&backwards[3]<=800,
  "reverse gear physically moves car backward while enforcing XI speed cap");
 const auto movingReverse=backwards[3];
 State brakingReverse{};
 for(int i=0;i<20;i++)brakingReverse=state(reverseRuntime.execute(reverseBrake));
 check(brakingReverse[3]<movingReverse,"reverse braking reduces actual world-space velocity");
 const auto movingSeed=reverse_pc::rvpc2::save(accelerated);
 auto brake=reverse_pc::rvpc2::restore(movingSeed),coast=reverse_pc::rvpc2::restore(movingSeed),
  powered=reverse_pc::rvpc2::restore(movingSeed),turn=reverse_pc::rvpc2::restore(movingSeed),
  drift=reverse_pc::rvpc2::restore(movingSeed);
 State br{},co{},po{},tu{},dr{};
 for(int i=0;i<30;i++){
  br=state(brake.execute(command({0,1,1,0})));co=state(coast.execute(command({0,0,1,0})));
  po=state(powered.execute(command({1,0,1,0})));tu=state(turn.execute(command({1,0,2,0})));
  dr=state(drift.execute(command({1,0,2,1})));
 }
 check(br[3]<co[3]&&co[3]<moving[3]&&po[3]>moving[3],"braking/coasting/throttle causal order");
 check(co[6]==moving[6]+30,"race clock continues during coasting");
 check(tu[2]!=po[2]&&tu[0]!=po[0],"steering changes actual heading and world position");
 check(std::abs(dr[4])>std::abs(tu[4]),"handbrake reduces grip and increases actual lateral motion");
 auto wall=reverse_pc::rvpc2::restore(raceStart);
 std::string wallSetup=header+"store32 100 2002000\nstore32 104 2010000\nstore16 108 0\n"+
  "store16 110 1800\nstore16 261 32768\nstore16 263 34568\nstore8 273 5\n"+
  "store32 274 10000\nstore32 278 10000\nhalt\n";
 wall.execute(wallSetup);const auto contacted=state(wall.execute(command({1,0,1,0})));
 check(contacted[14]==1&&std::abs(contacted[0])<=1000,"real wall response constrains the car center");
 std::vector<Input> tape;std::vector<State> observations;
 double executeMs=0;int offRoad=0,walls=0,lastLap=0,maxSpeed=0;std::int64_t lastTicks=s[6],lastProgress=s[5];
 int ticks=0;const auto raceBegin=Clock::now();
 for(;ticks<limit&&!s[7];++ticks){
  const auto target=points[(int(s[12])+lookahead)%80];
  const double targetYaw=yaw(target.x-s[0],target.z-s[1]);
  const double error=difference(targetYaw,double(s[2]));
  const double desiredWheel=std::clamp(error*gain,-1000.,1000.);
  const int wheel=int(observed16(runtime,256))-1000;
  const auto a=points[(int(s[12])+lookahead)%80],b=points[(int(s[12])+lookahead+1)%80],
   c=points[(int(s[12])+lookahead+2)%80];
  const bool curve=std::abs(difference(yaw(b.x-a.x,b.z-a.z),yaw(c.x-b.x,c.z-b.z)))>25;
  const int targetSpeed=curve?curveSpeed:6200;
  Input input;input.gas=s[3]<targetSpeed-30;input.brake=s[3]>targetSpeed+120;
  input.steer=wheel<desiredWheel-45?2:wheel>desiredWheel+45?0:1;
  const auto begin=Clock::now();s=state(runtime.execute(command(input)));executeMs+=std::chrono::duration<double,std::milli>(Clock::now()-begin).count();
  tape.push_back(input);if(observations.size()<1000)observations.push_back(s);
  check(s[6]>=lastTicks&&s[5]>=lastProgress&&s[5]<=lastProgress+1,"monotonic ordered sectors and timer");lastTicks=s[6];lastProgress=s[5];
  offRoad+=s[8];walls+=s[14];maxSpeed=std::max(maxSpeed,int(s[3]));
  if((ticks+1)%500==0||s[10]>lastLap){
   const auto bytes=reverse_pc::rvpc2::save(runtime);auto restored=reverse_pc::rvpc2::restore(bytes);check(reverse_pc::rvpc2::save(restored)==bytes,"periodic exact persistence");runtime=std::move(restored);
   std::cout<<"{\"event\":\"race_progress\",\"tick\":"<<ticks+1<<",\"x\":"<<s[0]<<",\"z\":"<<s[1]<<",\"yaw\":"<<s[2]<<",\"speed\":"<<s[3]<<",\"segment\":"<<s[12]<<",\"sectors\":"<<s[5]<<",\"lap\":"<<s[10]<<",\"offRoadTicks\":"<<offRoad<<",\"wallTicks\":"<<walls<<"}"<<std::endl;
  }lastLap=s[10];
 }
 const double raceMs=std::chrono::duration<double,std::milli>(Clock::now()-raceBegin).count();
 const auto final=reverse_pc::rvpc2::save(runtime);write(out/"race-final.rvp",final);
 // Reproduce a thousand actual recorded inputs through resident and per-tick
 // RVPC2 sessions. Both use the identical XI source and authoritative state.
 auto resident=reverse_pc::rvpc2::restore(raceStart);auto serialized=raceStart;
 const std::size_t sample=std::min<std::size_t>(1000,tape.size());double liveMs=0,persistMs=0;
 for(std::size_t i=0;i<sample;i++){
  auto begin=Clock::now();const auto a=state(resident.execute(command(tape[i])));liveMs+=std::chrono::duration<double,std::milli>(Clock::now()-begin).count();
  begin=Clock::now();auto restored=reverse_pc::rvpc2::restore(serialized);const auto b=state(restored.execute(command(tape[i])));serialized=reverse_pc::rvpc2::save(restored);persistMs+=std::chrono::duration<double,std::milli>(Clock::now()-begin).count();
  check(a==b&&a==observations[i],"resident/serialized deterministic observation");
 }
 check(reverse_pc::rvpc2::save(resident)==serialized,"resident/serialized final state exact");
 const auto retained=reverse_pc::rvpc2::save(resident);bool rejected=false;
 try{resident.execute(header+"store8 100 255\nnot_an_instruction\n");}catch(const std::exception&){rejected=true;}
 check(rejected&&reverse_pc::rvpc2::save(resident)==retained,"live XI atomic rollback");
 bool frozen=false;if(s[7]){const auto finished=s;for(int i=0;i<10;i++)s=state(runtime.execute(command({1,0,2,1})));frozen=s==finished;check(frozen,"finish freezes authoritative race observations");check(s[5]==12&&s[10]==3&&s[15]==480000,"three complete physical laps finish exactly");}
 {std::ofstream observation(out/"final-observation.json");observation<<'[';
  for(std::size_t i=0;i<s.size();i++){if(i)observation<<',';observation<<s[i];}
  observation<<"]\n";}
 std::ostringstream report;report<<"{\"passed\":"<<(s[7]?"true":"false")<<",\"checks\":"<<checks<<",\"worldPoints\":81,\"gameRegisters\":22,\"countdownTicks\":"<<countdown<<",\"raceInputTicks\":"<<ticks<<",\"raceVirtualSeconds\":"<<lastTicks/50.<<",\"raceWallMs\":"<<raceMs<<",\"raceExecuteMs\":"<<executeMs<<",\"maxSpeedCmps\":"<<maxSpeed<<",\"offRoadTicks\":"<<offRoad<<",\"wallTicks\":"<<walls<<",\"finished\":"<<(s[7]?"true":"false")<<",\"completedLaps\":"<<s[10]<<",\"sectors\":"<<s[5]<<",\"finishFrozen\":"<<(frozen?"true":"false")<<",\"persistenceSampleTicks\":"<<sample<<",\"residentMsPerTick\":"<<(sample?liveMs/sample:0)<<",\"serializedMsPerTick\":"<<(sample?persistMs/sample:0)<<",\"exactSerializedState\":true,\"seedBytes\":"<<seed.size()<<",\"finalBytes\":"<<final.size()<<",\"pilotGain\":"<<gain<<",\"pilotLookaheadSegments\":"<<lookahead<<",\"curveTargetCmps\":"<<curveSpeed<<",\"androidDeviceMeasured\":false}\n";
 std::ofstream(out/"gameplay-results.json")<<report.str();std::cout<<report.str();return s[7]?0:2;
}catch(const std::exception& e){std::cerr<<"VELOCITY_GAMEPLAY_FAIL "<<e.what()<<"\n";return 1;}}
