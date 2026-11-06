#define main inherited_open_contract
#include "open-forest-contract.cpp"
#undef main
#include "integration/xi_live_session.hpp"
#include <algorithm>
#include <chrono>
using LinkClock=std::chrono::steady_clock;
double link_ms(LinkClock::time_point a,LinkClock::time_point b){return std::chrono::duration<double,std::milli>(b-a).count();}
double link_median(std::vector<double> v){std::sort(v.begin(),v.end());return v[v.size()/2];}
int main(int argc,char**argv){try{
 const std::filesystem::path root=argv[1],out=argv[2];std::filesystem::create_directories(out);
 Runtime original;original.execute(read(root/"world.xi"));reverse_pc::XiLiveSession live(reverse_pc::rvpc2::save(original));
 const auto drive=read(root/"drive.xi"),render=read(root/"render4k.xi");
#ifndef VELOCITY_REFERENCE
 live.registerGeometryProgram(render);
#endif
 // Advance the actual driving program before the moving/view/effect trace.
 auto warm=[&](bool reset){return header+"store8 128 1\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 "+std::to_string(reset)+
   "\nstore8 133 0\nstore8 134 0\nstore8 135 0\nstore8 136 0\nstore8 138 255\n"+drive.substr(header.size());};
 for(unsigned tick=0;tick<200;tick++){live.stage(warm(tick==0));live.commit();}
 check(observe(live.retain()->output)[6]>=199&&observe(live.retain()->output)[11]>0,"actual car moves before profiling");
 std::vector<double> prepare,changed,unchanged,physics;std::uint64_t wire=0,full=0;const auto initial=live.checkpoint();
 for(unsigned frame=0;frame<72;frame++){
  const unsigned yaw=(frame/12)%3==0?0:((frame/12)%3==1?700:2200),pitch=(frame/24)*160;
  if(frame%3==0){
   auto a=LinkClock::now();auto command=header+"store8 128 1\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 0"+
      "\nstore8 133 "+std::to_string(frame>=48)+"\nstore8 134 "+std::to_string(frame>=60)+"\nstore8 135 0\nstore8 136 0\nstore8 138 255\n"+drive.substr(header.size());
   live.stage(command);live.commit();physics.push_back(link_ms(a,LinkClock::now()));
  }
  const reverse_pc::XiLiveSession::Inputs inputs{{"141",1},{"200",1},{"201",0},{"202",static_cast<std::uint8_t>((frame/24)%3)},
    {"203",static_cast<std::uint8_t>((frame/24)%3)},{"204",static_cast<std::uint8_t>(yaw)},{"205",static_cast<std::uint8_t>(yaw>>8)},
    {"206",static_cast<std::uint8_t>(pitch)},{"207",static_cast<std::uint8_t>(pitch>>8)}};
  const auto frozen=live.checkpoint();const auto generation=live.retain()->generation;
  auto a=LinkClock::now();
#ifdef VELOCITY_REFERENCE
  auto observed=live.observe(render,inputs);auto elapsed=link_ms(a,LinkClock::now());
  wire+=20+observed.output.size()+observed.frame.size();full+=observed.frame.size();
#else
  auto packet=live.observePreparedGeometry(inputs);auto elapsed=link_ms(a,LinkClock::now());
  auto observed=live.observe(render,inputs);wire+=packet.size();full+=observed.frame.size();
  std::ofstream encoded(out/("link-"+std::to_string(frame)+".xgd"),std::ios::binary);
  encoded.write(reinterpret_cast<const char*>(packet.data()),packet.size());
#endif
  check(generation==observed.generation&&observed.output==live.retain()->output,"geometry/state publication is coherent");
  check(frozen==live.checkpoint(),"read-only preparation never changes compact state");
  if(frame>=6){prepare.push_back(elapsed);(frame%3==0?changed:unchanged).push_back(elapsed);}
  std::ofstream f(out/("link-"+std::to_string(frame)+".xfg4"),std::ios::binary);f.write(observed.frame.data(),observed.frame.size());
  std::ofstream text(out/("link-"+std::to_string(frame)+".state"),std::ios::binary);text<<observed.output;
 }
 std::ofstream state(out/"final.rvpc2",std::ios::binary);auto saved=live.checkpoint();state.write(reinterpret_cast<const char*>(saved.data()),saved.size());
 std::ofstream report(out/"cpu-gpu-host.json");report<<"{\"passed\":true,\"hostOnly\":true,\"frames\":72,\"prepareP50Ms\":"<<link_median(prepare)
   <<",\"changedPublicationP50Ms\":"<<link_median(changed)<<",\"unchangedPublicationP50Ms\":"<<link_median(unchanged)
   <<",\"physicsP50Ms\":"<<link_median(physics)<<",\"wireBytes\":"<<wire<<",\"originalGeometryBytes\":"<<full<<"}\n";
 std::cout<<"CPU_GPU_LINK_HOST_PASS prepareP50Ms="<<link_median(prepare)<<" wireBytes="<<wire<<" originalGeometryBytes="<<full<<"\n";return 0;
}catch(const std::exception& e){std::cerr<<"CPU_GPU_LINK_HOST_FAIL "<<e.what()<<"\n";return 1;}}
