#include "velocity_c12_frame.hpp"
#include <algorithm>
#include <cassert>
#include <cmath>
#include <iostream>
#include <stdexcept>

static void close_to(float actual,float expected){
  assert(std::isfinite(actual));
  assert(std::fabs(actual-expected)<=std::max(.0005f,std::fabs(expected)*.000001f));
}
int main(){
  unsigned cases=0;
  for(auto wet:{0u,1u,317u,999u,1000u})
    for(auto water:{0u,1u,20u,40u})
      for(auto ticks:{0u,1u,500u,12000u})
        for(auto ambient:{0u,1u,2u}){
          auto frame=velocity_c12::evaluate({wet,water,ticks,ambient});
          assert(frame.steps>=9 && frame.relation_nodes>0);
          close_to(frame.values[0],float(wet)*.001f);
          close_to(frame.values[1],float(water));
          close_to(frame.values[2],float(ticks)*.02f);
          close_to(frame.values[3],ambient==0?1.f:ambient==1?.48f:.12f);
          close_to(frame.values[4],ambient==0?0.f:ambient==1?.6f:1.f);
          ++cases;
        }
  bool rejected=false;
  try{velocity_c12::evaluate({1001,1,1,1});}catch(const std::invalid_argument&){rejected=true;}
  assert(rejected);
  assert(velocity_c12::evaluate({0,0,200,0}).values[0]!=
         velocity_c12::evaluate({1000,0,200,0}).values[0]);
  std::cout<<"VELOCITY_C12_REAL_EXECUTION_PASS cases="<<cases<<" profile=C12\n";
}
