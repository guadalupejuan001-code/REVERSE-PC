#define main inherited_gameplay_contract
#include "open-forest-contract.cpp"
#undef main
#include "integration/readonly_geometry.hpp"
#include <algorithm>
struct Point{double x,z;};
struct Segment{Point a,b;int route;};
static double length(Point a,Point b){return std::hypot(a.x-b.x,a.z-b.z);}
static double wrap(double v){while(v>2048)v-=4096;while(v< -2048)v+=4096;return v;}
int main(int argc,char**argv){try{
 const std::filesystem::path root=argc>1?argv[1]:"reverse-os-android/app/src/main/assets/velocity",out=argc>2?argv[2]:"build/open-forest";std::filesystem::create_directories(out);
 Runtime seed;seed.execute(read(root/"world.xi"));const auto drive=read(root/"drive.xi"),render=read(root/"render4k.xi");
 auto command=[&](int gas,int brake,int analog,int reset=0){return header+"store8 128 "+std::to_string(gas)+"\nstore8 129 "+std::to_string(brake)+"\nstore8 130 1\nstore8 131 0\nstore8 132 "+std::to_string(reset)+"\nstore8 133 0\nstore8 134 0\nstore8 135 0\nstore8 136 0\nstore8 138 "+std::to_string(analog)+"\n"+drive.substr(header.size());};
 const auto initial=observe(seed.execute(command(0,0,100,1)));const auto state=reverse_pc::rvpc2::save(seed);
 auto load=[&](int at){return (long long)seed.memory().read(std::to_string(at),seed.core()).value;};
 auto u32=[&](int at){long long v=0;for(int i=0;i<4;i++)v+=load(at+i)<<(8*i);return v;};
 auto u16=[&](int at){return load(at)+256*load(at+1);};
 const int count=u16(908);check(count>100&&count<240,"connected trail segments are actually packed in the world");std::vector<Point> paths[4];
 for(int i=0;i<count;i++){int at=12000+i*24,route=load(at+19);Point a{double(u32(at)-2000000000LL),double(u32(at+4)-2000000000LL)},b{double(u32(at+8)-2000000000LL),double(u32(at+12)-2000000000LL)};if(paths[route].empty())paths[route].push_back(a);paths[route].push_back(b);}
 std::ofstream trace(out/"trail-manual-inputs.csv");trace<<"route,tick,xCm,zCm,yaw,speed,analog,gas,brake,groundCm,contact,waterCm\n";
 std::ofstream report(out/"trail-driving-results.json");report<<"{\"inputDriver\":\"closed-loop analog and pedals; Manual; no movement injection after spawn\",\"routes\":[";int totalTicks=0,totalContacts=0;
 const std::vector<std::pair<std::uint32_t,std::uint8_t>> view{{141,1},{200,1},{201,0},{202,0},{203,0},{204,0},{205,0},{206,0},{207,0}};
 for(int route=0;route<4;route++){
  auto r=reverse_pc::rvpc2::restore(state);auto& p=paths[route];const double yaw=std::atan2(p[1].x-p[0].x,p[1].z-p[0].z)*4096/(2*std::acos(-1.));
  r.execute(header+"store32 100 "+std::to_string(2000000000LL+std::llround(p[0].x))+"\nstore32 104 "+std::to_string(2000000000LL+std::llround(p[0].z))+"\nstore16 108 "+std::to_string((std::llround(yaw)+4096)%4096)+"\nhalt\n");
  State s=observe(r.execute(command(0,0,100)));int cursor=0,tick=0,contacts=0,water=0,maxHeight=0;double progress=0,maxError=0;int capture=0;bool arrived=false;
  for(;tick<14000;tick++){
   Point car{double(s[0]),double(s[1])};while(cursor+1<int(p.size())-1&&length(car,p[cursor+1])<650)cursor++;
   Point a=p[cursor],b=p[cursor+1];const double dx=b.x-a.x,dz=b.z-a.z,den=dx*dx+dz*dz;
   double t=std::clamp(((car.x-a.x)*dx+(car.z-a.z)*dz)/den,0.,1.);Point projected{a.x+dx*t,a.z+dz*t};double error=length(car,projected);maxError=std::max(maxError,error);
   Point target=projected;double ahead=650;int j=cursor+1;while(j<int(p.size())){const double gap=length(target,p[j]);if(gap>=ahead){target={target.x+(p[j].x-target.x)*ahead/gap,target.z+(p[j].z-target.z)*ahead/gap};break;}target=p[j++];ahead-=gap;}
   double desired=std::atan2(target.x-car.x,target.z-car.z)*4096/(2*std::acos(-1.));const double delta=wrap(desired-s[2]);int analog=std::clamp(100+int(std::round(delta*.55)),0,200);
   int wanted=std::abs(delta)>300?420:650;int gas=s[3]<wanted,brake=s[3]>wanted+100;
   s=observe(r.execute(command(gas,brake,analog)));contacts+=s[14]!=0;water+=s[32]>0;maxHeight=std::max(maxHeight,int(s[26]));
   if(tick%10==0)trace<<route<<','<<tick<<','<<s[0]<<','<<s[1]<<','<<s[2]<<','<<s[3]<<','<<analog<<','<<gas<<','<<brake<<','<<s[26]<<','<<s[14]<<','<<s[32]<<'\n';
   if(tick==200||tick==800||tick==1800){save(r,out/("trail-"+std::to_string(route)+"-"+std::to_string(capture)+".rvp"));auto frame=reverse_pc::observe_geometry(reverse_pc::rvpc2::save(r),render,view);std::ofstream f(out/("trail-"+std::to_string(route)+"-"+std::to_string(capture++)+".xfg4"),std::ios::binary);f.write(frame.data(),frame.size());}
   if(cursor>=int(p.size())-3&&length({double(s[0]),double(s[1])},p.back())<800){arrived=true;break;}
   check(error<3500,"manual trail driver lost the authored trail: route="+std::to_string(route)+" tick="+std::to_string(tick)+" error="+std::to_string(error));
  }
  check(arrived,"analog/pedals driver reaches the actual trail exit: route="+std::to_string(route)+" cursor="+std::to_string(cursor)+" x="+std::to_string(s[0])+" z="+std::to_string(s[1]));
  check(contacts==0,"trail clearance matches tree collision");if(route==0||route==2)check(maxHeight>500,"side trail climbs real visible terrain");
  if(route)report<<',';report<<"{\"route\":"<<route<<",\"ticks\":"<<tick<<",\"reachedExit\":true,\"contacts\":"<<contacts<<",\"waterTicks\":"<<water<<",\"maxHeightCm\":"<<maxHeight<<",\"maxPathErrorCm\":"<<maxError<<"}";
  totalTicks+=tick;totalContacts+=contacts;std::cout<<"TRAIL_DRIVE_ROUTE_PASS route="<<route<<" ticks="<<tick<<" height="<<maxHeight<<" error="<<maxError<<"\n";
 }
 report<<"],\"passed\":true,\"ticks\":"<<totalTicks<<",\"contacts\":"<<totalContacts<<",\"physicalPhoneMeasured\":false}\n";
 std::cout<<"FOREST_TRAILS_DRIVE_PASS routes=4 manualInputs=true collisions="<<totalContacts<<" ticks="<<totalTicks<<"\n";return 0;
}catch(const std::exception&e){std::cerr<<"FOREST_TRAILS_DRIVE_FAIL "<<e.what()<<"\n";return 1;}}
