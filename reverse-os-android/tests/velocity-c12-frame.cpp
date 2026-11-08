#include "velocity_c12_frame.hpp"
#include <array>
#include <atomic>
#include <bit>
#include <cmath>
#include <exception>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string>
#include <thread>

using velocity_c12::FrameInput;

static void require(bool condition,const char* message){
  if(!condition)throw std::runtime_error(message);
}

static void verify(const FrameInput& input){
  static_assert(sizeof(float)==sizeof(std::uint32_t));
  static_assert(std::numeric_limits<float>::is_iec559);
  const auto actual=velocity_c12::evaluate(input);
  require(actual.steps==9 && actual.relation_nodes>0,
          "Expected a complete original C12 dispatch, not cached or substitute values");
  // Independent scalar float32 reference. Scale the integer light levels:
  // e.g. 480 * .001f can differ by one ULP from the decimal literal .48f.
  const std::array<unsigned,3> daylight{1000,480,120},lamps{0,600,1000};
  const std::array<float,5> expected{
    static_cast<float>(input.wetness)*.001f,
    static_cast<float>(input.water_depth_cm),
    static_cast<float>(input.ticks)*.02f,
    static_cast<float>(daylight[input.ambient_mode])*.001f,
    static_cast<float>(lamps[input.ambient_mode])*.001f};
  for(std::size_t i=0;i<expected.size();++i){
    require(std::isfinite(actual.values[i]),"C12 produced non-finite material data");
    if(std::bit_cast<std::uint32_t>(actual.values[i])!=
       std::bit_cast<std::uint32_t>(expected[i]))
      throw std::runtime_error("C12 float32 bits differ at uniform "+std::to_string(i)+
                               " for tick "+std::to_string(input.ticks));
  }
}

int main(){
  unsigned cases=0;
  for(auto wet:{0u,1u,317u,999u,1000u})
    for(auto water:{0u,1u,20u,40u})
      // Cover the integer->float precision boundary and the Java int ceiling.
      for(auto ticks:{0u,1u,500u,12000u,16777215u,16777216u,16777217u,
                      1073741823u,2147483646u,2147483647u})
        for(auto ambient:{0u,1u,2u}){
          verify({wet,water,ticks,ambient});
          ++cases;
        }
  const std::array<FrameInput,8> invalid{{
    {1001,0,0,0},{UINT32_MAX,0,0,0},
    {0,41,0,0},{0,UINT32_MAX,0,0},
    {0,0,2147483648u,0},{0,0,UINT32_MAX,0},
    {0,0,0,3},{0,0,0,UINT32_MAX}}};
  for(const auto& input:invalid){
    bool rejected=false;
    try{velocity_c12::evaluate(input);}
    catch(const std::invalid_argument&){rejected=true;}
    require(rejected,"C12 accepted an out-of-range observation");
    verify({0,0,0,0}); // Failure must not poison the following valid dispatch.
  }

  // Overlapping calls model replacement render workers or multiple surfaces.
  // Distinct changing inputs expose any accidentally shared runtime or output.
  constexpr unsigned workers=4,per_worker=128;
  std::array<std::thread,workers> threads;
  std::array<std::exception_ptr,workers> failures{};
  std::atomic<unsigned> ready{0};
  std::atomic<bool> start{false};
  for(unsigned worker=0;worker<workers;++worker){
    threads[worker]=std::thread([&,worker]{
      ready.fetch_add(1,std::memory_order_release);
      while(!start.load(std::memory_order_acquire))std::this_thread::yield();
      try{
        for(unsigned i=0;i<per_worker;++i){
          const unsigned index=worker*per_worker+i;
          verify({(worker*251+i*37)%1001,(worker*7+i)%41,
                  i%2?2147483647u-index:50u*index,(worker+i)%3});
        }
      }catch(...){failures[worker]=std::current_exception();}
    });
  }
  while(ready.load(std::memory_order_acquire)!=workers)std::this_thread::yield();
  start.store(true,std::memory_order_release);
  for(auto& thread:threads)thread.join();
  for(const auto& failure:failures)if(failure)std::rethrow_exception(failure);

  std::cout<<"VELOCITY_C12_REAL_EXECUTION_PASS cases="<<cases
           <<" invalid="<<invalid.size()<<" concurrent="<<workers*per_worker
           <<" comparison=float32_bits profile=C12\n";
}
