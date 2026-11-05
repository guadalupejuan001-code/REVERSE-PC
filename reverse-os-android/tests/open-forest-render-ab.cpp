#define main previous_open_contract
#include "open-forest-contract.cpp"
#undef main
#include <algorithm>
#include <chrono>
std::vector<unsigned char> unpack(const std::string& f){
 const auto u16=[&](int n){return (unsigned char)f[n]+256*(unsigned char)f[n+1];};
 if(f.substr(0,4)=="XFB5")return {f.begin()+16,f.end()};
 check(f.substr(0,4)=="XFS1","reference spans");const int w=u16(6),h=u16(8);
 std::vector<unsigned char> out(w*h);
 for(std::size_t n=16;n+14<=f.size()-8;n+=14){const int y=u16(n+2),a=u16(n+4),b=u16(n+6);std::fill(out.begin()+y*w+a,out.begin()+y*w+b+1,(unsigned char)f[n+1]);}
 return out;
}
int main(int argc,char** argv){try{
 using Clock=std::chrono::steady_clock;
 const std::filesystem::path root=argc>1?argv[1]:"reverse-os-android/app/src/main/assets/velocity";
 const std::filesystem::path output=argc>2?argv[2]:"build/open-forest";
 const std::array<std::string,2> sources{read(root/"render.xi"),read(root/"render-live.xi")};
 std::ofstream report(output/"render-ab.json");report<<"{\"hostOnly\":true,\"measuredRegion\":\"XI execute, excluding RVPC2 restore and Java presentation\",\"samplesPerVariant\":18,\"frames\":[\n";bool first=true;
 for(const auto& name:{"start","bridge","lake","night"})for(int stride:{4,2,1}){
  const auto bytes=read(output/"gameplay"/(std::string(name)+".rvp"));
  std::vector<unsigned char> reference;std::vector<double> times[2];std::size_t sizes[2]{};
  for(int round=0;round<3;round++)for(int slot=0;slot<2;slot++){
   const int version=(round+slot)%2;
   const auto program=header+"store8 200 "+std::to_string(stride)+"\nstore8 201 0\nstore8 202 0\nstore8 203 0\n"+sources[version].substr(header.size());
   for(int i=0;i<8;i++){
    auto r=reverse_pc::rvpc2::restore(std::vector<std::uint8_t>(bytes.begin(),bytes.end()));
    const auto begin=Clock::now();const auto f=r.execute(program);
    const auto ms=std::chrono::duration<double,std::milli>(Clock::now()-begin).count();
    const auto pixels=unpack(f);if(reference.empty())reference=pixels;
    check(pixels==reference,"native/legacy pixels remain identical while benchmarking");
    sizes[version]=f.size();if(i>=2)times[version].push_back(ms);
   }
  }
  for(auto& t:times)std::sort(t.begin(),t.end());
  if(!first)report<<",\n";first=false;
  report<<"{\"scene\":\""<<name<<"\",\"stride\":"<<stride<<",\"identicalPixels\":true,\"spanP50Ms\":"<<times[0][9]<<",\"nativeP50Ms\":"<<times[1][9]<<",\"spanP95Ms\":"<<times[0][17]<<",\"nativeP95Ms\":"<<times[1][17]<<",\"spanBytes\":"<<sizes[0]<<",\"nativeBytes\":"<<sizes[1]<<"}";
 }
 report<<"\n],\"phoneFpsMeasured\":false}\n";
 std::cout<<"OPEN_FOREST_RENDER_AB_PASS scenes=4 resolutions=3 pairedBatches=3 exactPixels=true hostOnly=true\n";return 0;
}catch(const std::exception& e){std::cerr<<"OPEN_FOREST_RENDER_AB_FAIL "<<e.what()<<"\n";return 1;}}
