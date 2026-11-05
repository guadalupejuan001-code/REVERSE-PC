#define main inherited_open_contract
#include "open-forest-contract.cpp"
#undef main
#include "integration/xi_live_session.hpp"
#include <algorithm>
#include <atomic>
#include <chrono>
#include <thread>
using Clock=std::chrono::steady_clock;
double ms(Clock::time_point a,Clock::time_point b){return std::chrono::duration<double,std::milli>(b-a).count();}
double median(std::vector<double> v){std::sort(v.begin(),v.end());return v[v.size()/2];}
int main(int argc,char**argv){try{
 const std::filesystem::path root=argc>1?argv[1]:"reverse-os-android/app/src/main/assets/velocity";
 const std::filesystem::path out=argc>2?argv[2]:"build/open-forest";
 std::filesystem::create_directories(out);
 Runtime initial;initial.execute(read(root/"world.xi"));
 auto state=reverse_pc::rvpc2::save(initial);reverse_pc::XiLiveSession live(state);
 const auto drive=read(root/"drive.xi"),render=read(root/"render4k.xi");
 auto command=[&](int i){return header+"store8 128 "+std::to_string(i%15<12)+
   "\nstore8 129 "+std::to_string(i%15>=12)+"\nstore8 130 1\nstore8 131 0\nstore8 132 "+std::to_string(i==0)+
   "\nstore8 133 0\nstore8 134 0\nstore8 135 0\nstore8 136 0\nstore8 138 255\n"+drive.substr(header.size());};
 std::vector<double> baselineTimes,liveTimes,geometryBefore,geometryAfter;
 for(int i=0;i<90;i++){
   auto source=command(i);auto a=Clock::now();auto old=reverse_pc::rvpc2::restore(state);
   auto text=old.execute(source);state=reverse_pc::rvpc2::save(old);auto b=Clock::now();
   auto observed=live.stage(source);auto generation=live.commit();auto c=Clock::now();
   check(generation==static_cast<std::uint64_t>(i+1),"publication identity advances once per committed transaction");
   check(text==observed,"live XI observation equals original RVPC2 transaction");
   if(i%15==0||i==89)check(live.checkpoint()==state,"compact RVPC2 bytes remain exact");
   if(i>10){baselineTimes.push_back(ms(a,b));liveTimes.push_back(ms(b,c));}
 }
 auto saved=live.checkpoint();
 bool rejected=false;try{live.stage(header+"store8 128 1\nstore16 300 -1\n");}catch(const std::exception&){rejected=true;}
 check(rejected&&saved==live.checkpoint(),"invalid XI rolls back live session");
 live.stage(command(1));live.discard();check(saved==live.checkpoint(),"Java-rejected observation does not publish candidate");
 const reverse_pc::XiLiveSession::Inputs inputs{{"141",1},{"200",1},{"201",0},{"202",0},{"203",0},{"204",0},{"205",0},{"206",0},{"207",0}};
 std::string expected;
 for(int i=0;i<12;i++){
   auto a=Clock::now();auto old=reverse_pc::rvpc2::restore(state);auto core=old.core();auto memory=old.memory();
   for(const auto& input:inputs)memory.store(input.first,input.second,core);
   old.restore(core.snapshot(),memory.snapshot());auto reference=old.execute(render);auto b=Clock::now();
   auto packet=live.observe(render,inputs);auto c=Clock::now();
   check(reference==packet.frame,"live XFG4 geometry equals original XI byte for byte");
   check(packet.output==live.retain()->output,"observed state and geometry share one publication");
   check(packet.generation==live.retain()->generation,"frame retains exact publication identity for paused reuse");
   if(i>1){geometryBefore.push_back(ms(a,b));geometryAfter.push_back(ms(b,c));}
   expected=packet.frame;
 }
 check(saved==live.checkpoint(),"frame observation never mutates compact world");
 std::ofstream image(out/"live-session-geometry.xfg4",std::ios::binary);image.write(expected.data(),expected.size());
 // Race the generic publisher against a reader. The pair must always describe
 // one whole transaction, even when the writer commits during observation.
 reverse_pc::XiLiveSession concurrent(reverse_pc::rvpc2::save(Runtime{}));
 const auto tick=header+"load32 r0 400\nadd r0 1\nstore32 400 r0\nprint r0\n";
 const auto observeTick=header+"load32 r0 400\nprint r0\n";
 concurrent.stage(tick);concurrent.commit();std::atomic<bool> failed{false};std::atomic<int> reads{0};
 std::thread reader([&]{try{for(int i=0;i<500;i++){auto p=concurrent.observe(observeTick);if(p.output!=p.frame)failed=true;reads++;}}catch(...){failed=true;}});
 for(int i=0;i<200;i++){concurrent.stage(tick);concurrent.commit();}
 reader.join();check(!failed&&reads==500,"concurrent readers retain coherent XI publications");
 std::ofstream f(out/"live-session-ab.json");
 f<<"{\"passed\":true,\"hostOnly\":true,\"phoneFpsMeasured\":false,\"pairedTicks\":90,\"concurrentReads\":500,\"checkpointBytes\":"<<state.size()
  <<",\"rvpc2Exact\":true,\"geometryExact\":true,\"beforeTransactionP50Ms\":"<<median(baselineTimes)<<",\"afterTransactionP50Ms\":"<<median(liveTimes)
  <<",\"beforeGeometryP50Ms\":"<<median(geometryBefore)<<",\"afterGeometryP50Ms\":"<<median(geometryAfter)<<"}\n";
 std::cout<<"VELOCITY_LIVE_SESSION_PASS beforeTickMs="<<median(baselineTimes)<<" afterTickMs="<<median(liveTimes)
  <<" beforeGeometryMs="<<median(geometryBefore)<<" afterGeometryMs="<<median(geometryAfter)<<"\n";return 0;
}catch(const std::exception&e){std::cerr<<"VELOCITY_LIVE_SESSION_FAIL "<<e.what()<<"\n";return 1;}}
