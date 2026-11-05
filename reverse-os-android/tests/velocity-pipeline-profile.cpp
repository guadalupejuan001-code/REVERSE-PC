#define main inherited_open_contract
#include "open-forest-contract.cpp"
#undef main
#include "integration/readonly_geometry.hpp"
#include <algorithm>
#include <chrono>
using Clock=std::chrono::steady_clock;
double millis(Clock::time_point a,Clock::time_point b){return std::chrono::duration<double,std::milli>(b-a).count();}
double median(std::vector<double> v){std::sort(v.begin(),v.end());return v[v.size()/2];}
int main(int argc,char**argv){try{
 const std::filesystem::path root=argc>1?argv[1]:"reverse-os-android/app/src/main/assets/velocity";
 const std::filesystem::path output=argc>2?argv[2]:"build/open-forest";
 std::filesystem::create_directories(output);
 Runtime initial;initial.execute(read(root/"world.xi"));const auto drive=read(root/"drive.xi"),render=read(root/"render4k.xi");
 const auto prefix=header+"store8 128 1\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 ";
 initial.execute(prefix+"1\nstore8 133 0\nstore8 134 0\nstore8 135 0\nstore8 136 0\nstore8 138 255\n"+drive.substr(header.size()));
 auto state=reverse_pc::rvpc2::save(initial);
 const auto command=prefix+"0\nstore8 133 0\nstore8 134 0\nstore8 135 0\nstore8 136 0\nstore8 138 255\n"+drive.substr(header.size());
 std::vector<double> restores,executes,saves,totals,geometry;
 // Each iteration uses the actual immutable RVPC2 transport used by Android.
 // Transport overhead is included; this is not an interpreter-only FPS claim.
 for(int i=0;i<70;i++){
  auto a=Clock::now();auto r=reverse_pc::rvpc2::restore(state);auto b=Clock::now();
  const auto observation=observe(r.execute(command));auto c=Clock::now();
  state=reverse_pc::rvpc2::save(r);auto d=Clock::now();
  check(observation[6]==i+1,"each transport transaction advances exactly one physical tick");
  if(i>=10){restores.push_back(millis(a,b));executes.push_back(millis(b,c));saves.push_back(millis(c,d));totals.push_back(millis(a,d));}
 }
 const std::vector<std::pair<std::uint32_t,std::uint8_t>> inputs{{141,1},{200,1},{201,0},{202,0},{203,0},{204,0},{205,0},{206,0},{207,0}};
 std::string frame;
 for(int i=0;i<20;i++){
  auto a=Clock::now();auto candidate=reverse_pc::observe_geometry(state,render,inputs);auto b=Clock::now();
  if(frame.empty())frame=candidate;else check(frame==candidate,"immutable geometry replay must be exact");
  if(i>=4)geometry.push_back(millis(a,b));
 }
 std::ofstream image(output/"profile-hd-geometry.xfg4",std::ios::binary);image.write(frame.data(),frame.size());
 std::ofstream f(output/"pipeline-host-profile.json");
 f<<"{\"passed\":true,\"hostOnly\":true,\"phoneFpsMeasured\":false,\"stateBytes\":"<<state.size()<<",\"physicsSamples\":"<<totals.size()<<",\"restoreP50Ms\":"<<median(restores)<<",\"executeP50Ms\":"<<median(executes)<<",\"saveP50Ms\":"<<median(saves)<<",\"transactionP50Ms\":"<<median(totals)<<",\"geometryObservationP50Ms\":"<<median(geometry)<<",\"geometrySamples\":"<<geometry.size()<<",\"geometryBytes\":"<<frame.size()<<",\"shaderOrPresentationIncluded\":false}\n";
 std::cout<<"VELOCITY_PIPELINE_HOST_PASS physicsSamples="<<totals.size()<<" stateBytes="<<state.size()<<" transactionP50Ms="<<median(totals)<<" geometryObservationP50Ms="<<median(geometry)<<"\n";return 0;
}catch(const std::exception&e){std::cerr<<"VELOCITY_PIPELINE_HOST_FAIL "<<e.what()<<"\n";return 1;}}
