#pragma once
// REVERSE adapts the C02 scheduling policy to its ORIGINAL RVPC2 QuantumRuntime.
// Private workers restore full RVPC2 states. The single authority serializes
// optimistic commits, preserving XI/InverseMemory/RNG rollback. No new engine.
#include "rvpc2.hpp"

#include <algorithm>
#include <array>
#include <atomic>
#include <chrono>
#include <cstdint>
#include <deque>
#include <limits>
#include <mutex>
#include <stdexcept>
#include <string>
#include <thread>
#include <utility>
#include <vector>

namespace reverse_pc::fabric_workers {
using Clock=std::chrono::steady_clock;
inline std::uint64_t usec(Clock::duration d){
  const auto x=std::chrono::duration_cast<std::chrono::microseconds>(d).count();
  return x<0?0:static_cast<std::uint64_t>(x);
}
inline std::string quote(const std::string& value){
  static const char hex[]="0123456789abcdef";
  std::string out("\"");out.reserve(value.size()+8);
  for(unsigned char c:value){
    if(c=='"'||c=='\\'){out.push_back('\\');out.push_back(char(c));}
    else if(c=='\n')out+="\\n";
    else if(c=='\r')out+="\\r";
    else if(c=='\t')out+="\\t";
    else if(c<32){out+="\\u00";out.push_back(hex[c>>4]);out.push_back(hex[c&15]);}
    else out.push_back(char(c));
  }
  return out+'"';
}
enum class Priority : std::size_t { Interactive=0, Normal=1, Background=2 };
struct Job {std::string program; Priority priority=Priority::Normal;};
struct Result {
  bool ok=false,committed=false,isolated=true,conflict_exhausted=false;
  std::size_t job=0,worker=0,conflicts=0;
  std::uint64_t wait_us=0,execution_us=0,revision=0;
  std::string output,error;
};
struct Options {
  std::size_t workers=2;
  std::size_t max_queued=1024;
  std::size_t max_program_bytes=16u*1024u*1024u;
  std::size_t max_input_bytes=128u*1024u*1024u;
  std::size_t retry_conflicts=4;
  std::uint64_t host_reserve_bytes=384ull*1024ull*1024ull;
  std::uint64_t aging_normal_us=2000000;
  std::uint64_t aging_interactive_us=5000000;
};
struct Batch {
  std::vector<Result> results;
  std::vector<std::uint8_t> state;
  std::size_t completed=0,failed=0,committed=0,conflicts=0,peak_active=0;
  std::size_t workers=0,accepted_input_bytes=0,effective_input_cap=0;
  std::uint64_t elapsed_us=0;
  bool isolated=true;
  std::string json()const{
    std::string s="{\"engine\":\"REVERSE RVPC2 XI C02\",\"isolated\":";
    s+=isolated?"true":"false";
    s+=",\"workers\":"+std::to_string(workers);
    s+=",\"jobs\":"+std::to_string(results.size());
    s+=",\"completed\":"+std::to_string(completed);
    s+=",\"failed\":"+std::to_string(failed);
    s+=",\"committed\":"+std::to_string(committed);
    s+=",\"conflicts\":"+std::to_string(conflicts);
    s+=",\"peak_active\":"+std::to_string(peak_active);
    s+=",\"input_bytes\":"+std::to_string(accepted_input_bytes);
    s+=",\"effective_input_cap\":"+std::to_string(effective_input_cap);
    s+=",\"elapsed_us\":"+std::to_string(elapsed_us);
    s+=",\"results\":[";
    for(std::size_t i=0;i<results.size();++i){
      const auto& r=results[i];
      if(i)s+=",";
      s+="{\"job\":"+std::to_string(r.job)+",\"worker\":"+std::to_string(r.worker);
      s+=",\"ok\":";s+=r.ok?"true":"false";
      s+=",\"committed\":";s+=r.committed?"true":"false";
      s+=",\"conflict_exhausted\":";s+=r.conflict_exhausted?"true":"false";
      s+=",\"conflicts\":"+std::to_string(r.conflicts);
      s+=",\"wait_us\":"+std::to_string(r.wait_us);
      s+=",\"execution_us\":"+std::to_string(r.execution_us);
      s+=",\"revision\":"+std::to_string(r.revision);
      s+=",\"output\":"+quote(r.output)+",\"error\":"+quote(r.error)+"}";
    }
    return s+"]}";
  }
};
inline std::size_t pick(const std::array<bool,3>& pending,
                        const std::array<std::uint64_t,3>& ages,
                        std::size_t& cursor,const Options& options){
  if(pending[2]&&ages[2]>=options.aging_interactive_us&&
     (!pending[1]||ages[2]>=ages[1]||ages[1]<options.aging_interactive_us))return 2;
  if(pending[1]&&ages[1]>=options.aging_interactive_us)return 1;
  static const std::array<std::size_t,7> slots{{0,0,0,0,1,1,2}};
  for(std::size_t n=0;n<slots.size();++n){
    const auto level=slots[cursor];
    cursor=(cursor+1)%slots.size();
    if(level==1 && pending[2] && ages[2]>=options.aging_normal_us)return 2;
    if(pending[level])return level;
  }
  throw std::logic_error("RVPC2 C02 has no work");
}
inline std::size_t effective_bytes(const Options& o,std::uint64_t host_available){
  if(!host_available)return o.max_input_bytes;
  const auto free=host_available>o.host_reserve_bytes?
      host_available-o.host_reserve_bytes:0;
  return std::size_t(std::min<std::uint64_t>(o.max_input_bytes,free/5));
}
inline Batch execute(const std::vector<std::uint8_t>& initial,
                     const std::vector<Job>& jobs, bool transactional,
                     Options options={},std::uint64_t available_host_bytes=0){
  if(!options.workers||options.workers>64||!options.max_queued||
     !options.max_program_bytes||!options.max_input_bytes||
     options.max_program_bytes>options.max_input_bytes||
     options.aging_normal_us>options.aging_interactive_us)
    throw std::invalid_argument("RVPC2 C02 invalid worker/admission policy");
  if(jobs.empty()||jobs.size()>options.max_queued)
    throw std::length_error("RVPC2 C02 job count out of configured bounds");
  if(initial.size()>rvpc2::max_state+29)
    throw std::length_error("RVPC2 C02 checkpoint exceeds its exact format");
  std::size_t total=0;
  for(const auto& job:jobs){
    if(static_cast<std::size_t>(job.priority)>=3||job.program.size()>options.max_program_bytes)
      throw std::invalid_argument("RVPC2 C02 invalid job priority or length");
    if(total>options.max_input_bytes-job.program.size())
      throw std::length_error("RVPC2 C02 input budget exceeded");
    total+=job.program.size();
  }
  const auto cap=effective_bytes(options,available_host_bytes);
  if(total>cap)throw std::length_error("RVPC2 C02 low-memory admission rejected");
  // 3 state copies per worker is a conservative peak estimate and prevents
  // admitting jobs on very low-memory hosts. Snapshot payload != full heap.
  const auto worker_count=std::min(options.workers,jobs.size());
  if(available_host_bytes){
    const auto margin=available_host_bytes>options.host_reserve_bytes?
        available_host_bytes-options.host_reserve_bytes:0;
    if(initial.size() && std::uint64_t(initial.size())>
       margin/(worker_count*3u+2u))
      throw std::length_error("RVPC2 C02 checkpoint clones exceed host headroom");
  }
  rvpc2::restore(initial);  // Validate before starting any native worker.
  Batch result;
  result.state=initial;result.results.resize(jobs.size());
  result.isolated=!transactional;result.workers=worker_count;
  result.accepted_input_bytes=total;result.effective_input_cap=cap;
  std::mutex queue_mutex,authority_mutex,metrics_mutex;
  std::array<std::deque<std::size_t>,3> queued;
  std::vector<Clock::time_point> enqueued(jobs.size(),Clock::now());
  for(std::size_t i=0;i<jobs.size();++i)
    queued[static_cast<std::size_t>(jobs[i].priority)].push_back(i);
  std::size_t cursor=0,active=0;
  std::uint64_t authority_epoch=0;
  const auto started=Clock::now();
  auto worker=[&](std::size_t worker_id){
    for(;;){
      std::size_t i=0;
      {
        std::lock_guard<std::mutex> lock(queue_mutex);
        std::array<bool,3> pending{{false,false,false}};
        std::array<std::uint64_t,3> ages{{0,0,0}};
        for(std::size_t level=0;level<3;++level)if(!queued[level].empty()){
          pending[level]=true;
          ages[level]=usec(Clock::now()-enqueued[queued[level].front()]);
        }
        if(!pending[0]&&!pending[1]&&!pending[2])break;
        const auto level=pick(pending,ages,cursor,options);
        i=queued[level].front();queued[level].pop_front();
      }
      const auto begin=Clock::now();
      Result item;item.job=i;item.worker=worker_id;item.isolated=!transactional;
      item.wait_us=usec(begin-enqueued[i]);
      {
        std::lock_guard<std::mutex> lock(metrics_mutex);
        ++active;result.peak_active=std::max(result.peak_active,active);
      }
      try {
        for(std::size_t attempt=0;;++attempt){
          std::vector<std::uint8_t> original;
          std::uint64_t stamp=0;
          {
            std::lock_guard<std::mutex> lock(authority_mutex);
            original=transactional?result.state:initial;
            stamp=authority_epoch;
          }
          auto local=rvpc2::restore(original);
          auto output=local.execute(jobs[i].program);
          const auto candidate=rvpc2::save(local);
          const auto revision=local.core().stats().revision;
          if(!transactional){
            item.ok=true;item.output=std::move(output);item.revision=revision;
            break;
          }
          bool conflict=false,changed=candidate!=original;
          {
            std::lock_guard<std::mutex> lock(authority_mutex);
            if(stamp!=authority_epoch)conflict=true;
            else {
              if(changed){result.state=candidate;++authority_epoch;item.committed=true;}
              item.ok=true;item.output=std::move(output);item.revision=revision;
            }
          }
          if(!conflict)break;
          ++item.conflicts;
          if(attempt>=options.retry_conflicts){
            item.conflict_exhausted=true;
            item.error="RVPC2 C02 optimistic authority conflict exhausted";
            break;
          }
        }
      }catch(const std::exception& e){item.error=e.what();}
      catch(...){item.error="unknown XI worker error";}
      item.execution_us=usec(Clock::now()-begin);
      {
        std::lock_guard<std::mutex> lock(metrics_mutex);
        --active;++result.completed;
        if(!item.ok)++result.failed;
        if(item.committed)++result.committed;
        result.conflicts+=item.conflicts;
      }
      result.results[i]=std::move(item);
    }
  };
  std::vector<std::thread> threads;
  threads.reserve(worker_count);
  try{
    for(std::size_t i=0;i<worker_count;++i)threads.emplace_back(worker,i);
  }catch(...){
    for(auto& t:threads)if(t.joinable())t.join();
    throw;
  }
  for(auto& t:threads)t.join();
  result.elapsed_us=usec(Clock::now()-started);
  if(result.completed!=jobs.size())throw std::logic_error("RVPC2 C02 silently lost jobs");
  return result;
}
} // namespace reverse_pc::fabric_workers
