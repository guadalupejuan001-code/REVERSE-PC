#include "velocity_c12_frame.hpp"
#include "ejecucion_gpu.hpp" // Pinned upstream XGPU-C12, never a substitute kernel
#include <array>
#include <cstring>
#include <stdexcept>

namespace velocity_c12 {
namespace {
using Op=xgpu::StateOp;
xgpu::Kernel materials(){
  // Five C12 lanes share one program. Input words 0..4; multipliers 5..9.
  return {{ {Op::Index,0},
            {Op::LoadGlobal,1,0},
            {Op::FloatFromUnsigned,2,1},
            {Op::Constant,3,0,0,0,5},
            {Op::Add,4,0,3},
            {Op::LoadGlobal,5,4},
            {Op::FloatMultiply,6,2,5},
            {Op::Output,6},
            {Op::Halt} }};
}
xgpu::Word bits(float f){
  static_assert(sizeof(f)==sizeof(xgpu::Word));
  xgpu::Word w=0;std::memcpy(&w,&f,sizeof(w));return w;
}
float to_float(xgpu::Word w){
  float f=0;std::memcpy(&f,&w,sizeof(f));return f;
}
}
FrameOutput evaluate(const FrameInput& input){
  if(input.wetness>1000||input.water_depth_cm>40||
     input.ambient_mode>2||input.ticks>2147483647u)
    throw std::invalid_argument("C12 needs a validated XI/QSSD observation");
  const std::array<xgpu::Word,10> words{
    input.wetness,input.water_depth_cm,input.ticks,
    input.ambient_mode==0?1000u:input.ambient_mode==1?480u:120u,
    input.ambient_mode==0?0u:input.ambient_mode==1?600u:1000u,
    bits(.001f),bits(1.f),bits(.02f),bits(.001f),bits(.001f)};
  xgpu::Field field(10);
  for(xgpu::Index i=0;i<words.size();++i)
    if(words[static_cast<std::size_t>(i)]!=0)
      // This unpublished field belongs only to this call. The upstream setter
      // avoids copying all previous patches; initialize_global validates it.
      xgpu::set_field_word(field,i,words[static_cast<std::size_t>(i)]);
  xgpu::Execution runtime(10,{},xgpu::ExecutionProfile::C12);
  runtime.initialize_global(std::move(field));
  const auto job=runtime.enqueue(materials(),5,5);
  if(!runtime.run(16)||!runtime.dispatch(job).output_valid.full())
    throw std::runtime_error("Original XGPU-C12 frame kernel incomplete");
  FrameOutput result;
  for(xgpu::Index i=0;i<5;++i)
    result.values[static_cast<std::size_t>(i)]=to_float(runtime.dispatch(job).output->at(i));
  result.steps=runtime.counters().steps;
  result.relation_nodes=runtime.counters().relation_nodes_created;
  if(runtime.profile()!=xgpu::ExecutionProfile::C12||!result.steps)
    throw std::runtime_error("Original XGPU-C12 was not executed");
  return result;
}
}
