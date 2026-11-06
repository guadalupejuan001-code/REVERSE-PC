#define main previous_open_forest_contract
#include "open-forest-contract.cpp"
#undef main
#include <algorithm>

// Controlled straight-road dynamometer: keep the contact patch on the same
// clear asphalt each tick. All forces, wheel velocities and time execute in XI.
int main(int argc,char**argv){try{
 const std::filesystem::path assets=argv[1],baseline=argv[2],out=argv[3];
 std::filesystem::create_directories(out);Runtime seed;seed.execute(read(assets/"world.xi"));
 const auto current=read(assets/"drive.xi"),old=read(baseline/"drive.xi");
 auto command=[&](const std::string& drive,int gas,int brake,int gear=0,int boost=0){return header+
  "store32 100 2000000000\nstore32 104 2000000000\nstore16 108 0\nstore8 273 0\nstore8 489 0\n"
  "store8 128 "+std::to_string(gas)+"\nstore8 129 "+std::to_string(brake)+"\nstore8 130 1\nstore8 131 0\nstore8 132 0\nstore8 133 0\nstore8 134 "+std::to_string(boost)+"\nstore8 135 0\nstore8 136 0\nstore8 138 255\nstore8 142 "+std::to_string(gear)+"\n"+drive.substr(header.size());};
 seed.execute(command(current,0,0));auto initial=reverse_pc::rvpc2::save(seed);
 auto velocity=[&](Runtime& r,int speed){r.execute(header+"store16 110 "+std::to_string(speed)+"\nstore16 261 32768\nstore16 263 "+std::to_string(32768+speed)+"\nhalt\n");};
 struct Stop{int ticks;double distance;};
 auto stop=[&](const std::string& source,int speed,int gas,int boost){auto r=reverse_pc::rvpc2::restore(initial);velocity(r,speed);int n=0,previous=speed;double cm=0;
  for(;n<500&&previous>0;n++){auto s=observe(r.execute(command(source,gas,1,0,boost)));check(s[3]<=previous,"brake speed is monotonic with overlapping controls");previous=int(s[3]);cm+=s[3]/50.;check(!s[17],"braking cancels nitro");}
  check(previous==0,"service brake stops without reversing");return Stop{n,cm/100.};};
 std::ofstream report(out/"powertrain-results.json");report<<"{\"passed\":true,\"fixture\":\"XI straight asphalt dynamometer, 50 Hz\",\"braking\":[";
 int row=0;
 for(int speed:{833,1667,2778,5556,6500}){
  auto before=stop(old,speed,0,0),after=stop(current,speed,0,0),overlap=stop(current,speed,1,1);
  check(after.ticks<before.ticks&&after.distance<before.distance,"new brake stops sooner at every tested speed");
  check(after.ticks==overlap.ticks&&after.distance==overlap.distance,"accelerator/nitro cannot oppose the service brake");
  if(row++)report<<',';report<<"{\"kmh\":"<<speed*.036<<",\"oldSeconds\":"<<before.ticks*.02<<",\"newSeconds\":"<<after.ticks*.02<<",\"oldMetres\":"<<before.distance<<",\"newMetres\":"<<after.distance<<"}";
 }
 auto launch=[&](const std::string& source){auto r=reverse_pc::rvpc2::restore(initial);int time100=0,v1=0;std::set<int> gears;
  for(int i=0;i<1400;i++){auto s=observe(r.execute(command(source,1,0)));if(i==49)v1=int(s[3]);if(!time100&&s[3]>=2778)time100=i+1;if(source==current)gears.insert(int(s[35]));}
  return std::make_tuple(time100,v1,gears);};
 auto [old100,old1,unused]=launch(old);auto [new100,new1,gears]=launch(current);
 check(new1<old1&&new100>old100&&new100>0,"launch and acceleration are more progressive");check(gears.size()==6,"all six real automatic gears engage");
 auto coast=reverse_pc::rvpc2::restore(initial),low=reverse_pc::rvpc2::restore(initial);velocity(coast,1000);velocity(low,1000);State c{},l{};
 for(int i=0;i<40;i++){c=observe(coast.execute(command(current,0,0,6)));l=observe(low.execute(command(current,0,0,1)));}
 check(l[3]<c[3],"lower gear provides stronger engine braking");
 auto limit=reverse_pc::rvpc2::restore(initial);State selected{};for(int i=0;i<400;i++)selected=observe(limit.execute(command(current,1,0,1)));
 check(selected[35]==1&&selected[3]<1450,"first gear has real torque/redline limits");
 auto boosted=reverse_pc::rvpc2::restore(initial);int boostMax=0;
 for(int i=0;i<400;i++){auto s=observe(boosted.execute(command(current,1,0,1,1)));boostMax=std::max(boostMax,int(s[3]));}
 check(boostMax<1450,"nitro cannot bypass a manual gear's torque/redline limit");
 auto safe=reverse_pc::rvpc2::restore(initial);velocity(safe,4000);safe.execute(header+"store8 568 5\nhalt\n");
 auto down=observe(safe.execute(command(current,0,0,1)));check(down[35]==5&&down[37]==1&&down[3]>3800,"unsafe downshift stays pending without deleting speed");
 auto bytes=reverse_pc::rvpc2::save(safe);auto copy=reverse_pc::rvpc2::restore(bytes);
 for(int i=0;i<100;i++)check(observe(safe.execute(command(current,0,0,1)))==observe(copy.execute(command(current,0,0,1))),"transmission, RPM, ramp and future restore exactly");
 report<<"],\"old0to100Seconds\":"<<old100*.02<<",\"new0to100Seconds\":"<<new100*.02<<",\"oldSpeedAfter1sKmh\":"<<old1*.036<<",\"newSpeedAfter1sKmh\":"<<new1*.036<<",\"automaticGears\":6,\"checks\":"<<checks<<",\"physicalPhoneMeasured\":false}\n";
 std::cout<<"VELOCITY_POWERTRAIN_PASS checks="<<checks<<" old0to100="<<old100*.02<<" new0to100="<<new100*.02<<" gears="<<gears.size()<<"\n";return 0;
}catch(const std::exception&e){std::cerr<<"VELOCITY_POWERTRAIN_FAIL "<<e.what()<<"\n";return 1;}}
