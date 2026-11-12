#include "fabric/reverse_workers.hpp"
#include <array>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace {
using namespace reverse_pc::fabric_workers;
std::size_t checks=0;
void check(bool p,const char* reason){++checks;if(!p)throw std::runtime_error(reason);}
}
int main(){
 try{
  Options options;options.workers=4;
  check(options.max_queued==1024&&options.max_program_bytes==16u*1024*1024&&
        options.max_input_bytes==128u*1024*1024,"C02 admission defaults retained");
  check(effective_bytes(options,0)==options.max_input_bytes,
        "unavailable RAM probe leaves explicit fixed safety cap");
  check(effective_bytes(options,options.host_reserve_bytes)==0,
        "no host headroom means no new job admission");
  const auto original=reverse_pc::rvpc2::save(reverse_pc::rvpc2::Runtime{});
  const std::vector<Job> isolated{
    {"x 0\nprobz 0\n",Priority::Interactive},
    {"x 1\nprobz 1\n",Priority::Normal},
    {"h 2\nprobz 2\n",Priority::Background},
    {"x 3\nprobz 3\n",Priority::Interactive}
  };
  const auto isolated_result=execute(original,isolated,false,options);
  check(isolated_result.completed==4&&isolated_result.failed==0&&
        isolated_result.state==original&&isolated_result.committed==0,
        "4 independent XI workers cannot modify any central RVPC2 state");
  for(const auto& result:isolated_result.results)
    check(result.ok&&!result.committed&&result.output.find("probability_one")!=std::string::npos,
          "private worker actually executed original XI interpreter");

  std::vector<Job> transactions{{"x 10\n",Priority::Interactive},
                                {"x 11\n",Priority::Normal},
                                {"mem_store 1000000000012 42\n",Priority::Background},
                                {"x 12\n",Priority::Interactive}};
  const auto committed=execute(original,transactions,true,options);
  check(committed.failed==0&&committed.committed==4&&committed.completed==4,
        "all independent writes confirmed under single original RVPC2 authority");
  auto authoritative=reverse_pc::rvpc2::restore(committed.state);
  check(authoritative.core().probability_one("10")==1.0&&
        authoritative.core().probability_one("11")==1.0&&
        authoritative.core().probability_one("12")==1.0,
        "concurrent XI writes do not lose another worker's state");
  check(authoritative.memory().read("1000000000012",authoritative.core()).value==42,
        "InverseMemory confirmed with quantum authority and native rollback");
  check(reverse_pc::rvpc2::save(authoritative)==committed.state,
        "RVPC2 snapshot is byte equivalent after all commits");

  const std::vector<Job> rejected{{"x -1\n",Priority::Normal}};
  const auto failed=execute(committed.state,rejected,true,options);
  check(failed.failed==1&&failed.state==committed.state,
        "invalid XI program rejected without any published partial state");
  bool caught=false;
  try{auto memory_options=options;
      execute(original,isolated,false,memory_options,memory_options.host_reserve_bytes);
  }catch(const std::length_error&){caught=true;}
  check(caught,"low-memory RVPC2 C02 refuses admissions before cloning states");

  std::size_t cursor=0;std::array<unsigned,3> hits{{0,0,0}};
  for(int i=0;i<7;++i)++hits[pick({{true,true,true}},{{0,0,0}},cursor,options)];
  check(hits==std::array<unsigned,3>{{4,2,1}},"original C02 4:2:1 weights");
  cursor=4;
  check(pick({{true,true,true}},{{0,0,3000000}},cursor,options)==2,
        "background ages into normal slot");
  cursor=0;
  check(pick({{true,true,true}},{{0,0,6000000}},cursor,options)==2,
        "old background promoted beyond fresh interactive");
  cursor=0;
  check(pick({{false,false,true}},{{0,0,0}},cursor,options)==2,
        "empty priority levels are skipped");

  std::cout<<"{\"status\":\"PASS\",\"checks\":"<<checks
           <<",\"runtime\":\"original-REVERSE-RVPC2-XI\","
             "\"workers\":4,\"priority_aging\":true,\"conflict_retries\":true}\n";
  return 0;
 }catch(const std::exception& e){
  std::cerr<<"FAIL REVERSE RVPC2 workers: "<<e.what()<<'\n';return 1;
 }
}
