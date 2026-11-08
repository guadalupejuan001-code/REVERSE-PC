// Host-only microbenchmark: not Android FPS, JNI cost or GPU presentation.
// Build the same harness with the baseline and candidate frame .cpp files:
//   git show cb7903bd596f1f0c382d3ba880e47086dfc37014:reverse-os-android/app/src/main/cpp/velocity_c12_frame.cpp > /tmp/c12-before.cpp
//   g++ -std=c++20 -O2 -I deps/gpu-virtual/include -I reverse-os-android/app/src/main/cpp /tmp/c12-before.cpp reverse-os-android/tests/velocity-c12-benchmark.cpp -o /tmp/c12-before
//   g++ -std=c++20 -O2 -I deps/gpu-virtual/include -I reverse-os-android/app/src/main/cpp reverse-os-android/app/src/main/cpp/velocity_c12_frame.cpp reverse-os-android/tests/velocity-c12-benchmark.cpp -o /tmp/c12-after
// Run alternating before/after trials; argv[1] is the dispatch count (10000).
#include "velocity_c12_frame.hpp"
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <new>

namespace {
bool counting=false;
std::uint64_t allocations=0,allocated_bytes=0;
void* allocate(std::size_t size){
  // This benchmark is single-threaded. Count ordinary C++ heap allocations in
  // a separate pass; the timed pass does not update allocation counters.
  void* pointer=std::malloc(size?size:1);
  if(!pointer)throw std::bad_alloc();
  if(counting){++allocations;allocated_bytes+=size;}
  return pointer;
}
double run(unsigned iterations){
  double checksum=0;
  for(unsigned i=0;i<iterations;++i){
    const auto frame=velocity_c12::evaluate({317,20,12000+i,1});
    for(float value:frame.values)checksum+=value;
  }
  return checksum;
}
}
void* operator new(std::size_t size){return allocate(size);}
void* operator new[](std::size_t size){return allocate(size);}
void operator delete(void* pointer)noexcept{std::free(pointer);}
void operator delete[](void* pointer)noexcept{std::free(pointer);}
void operator delete(void* pointer,std::size_t)noexcept{std::free(pointer);}
void operator delete[](void* pointer,std::size_t)noexcept{std::free(pointer);}

int main(int argc,char** argv){
  unsigned iterations=10000;
  if(argc>1){
    char* end=nullptr;
    const auto parsed=std::strtoul(argv[1],&end,10);
    if(!*argv[1]||*end||parsed<1||parsed>1000000){
      std::fprintf(stderr,"dispatch count must be between 1 and 1000000\n");
      return 2;
    }
    iterations=static_cast<unsigned>(parsed);
  }
  run(32);
  const auto start=std::chrono::steady_clock::now();
  const auto checksum=run(iterations);
  const auto elapsed=std::chrono::duration_cast<std::chrono::nanoseconds>(
    std::chrono::steady_clock::now()-start).count();
  counting=true;
  const auto allocation_checksum=run(iterations);
  counting=false;
  if(checksum!=allocation_checksum)return 1;
  std::printf("{\"scope\":\"host_native_material_dispatch_only\","
    "\"iterations\":%u,\"elapsed_ns\":%lld,\"mean_dispatch_ns\":%.3f,"
    "\"cpp_allocations_per_dispatch\":%.3f,\"cpp_allocated_bytes_per_dispatch\":%.3f,"
    "\"checksum\":%.9f,\"android_fps_measured\":false}\n",
    iterations,static_cast<long long>(elapsed),static_cast<double>(elapsed)/iterations,
    static_cast<double>(allocations)/iterations,
    static_cast<double>(allocated_bytes)/iterations,checksum);
}
