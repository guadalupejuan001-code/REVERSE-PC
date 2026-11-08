#include "velocity_c12_frame.hpp"
#include "qssd/c12_bridge.hpp" // Original qSSD C06 C12Window, not a parallel executor.
#include <array>
#include <cstring>
#include <optional>
#include <stdexcept>

namespace velocity_c12 {
namespace {
using Op=xgpu::StateOp;
xgpu::Kernel materials(){
  // C12Window retains the complete 10-word qSSD field domain. The upper five
  // lanes explicitly finish with zero; only lanes 0..4 read multipliers 5..9.
  return {{ {Op::BranchIndexLess,0,0,0,5,4},
            {Op::Constant,6}, {Op::Output,6}, {Op::Halt},
            {Op::Index,0}, {Op::LoadGlobal,1,0},
            {Op::FloatFromUnsigned,2,1},
            {Op::Constant,3,0,0,0,5}, {Op::Add,4,0,3},
            {Op::LoadGlobal,5,4}, {Op::FloatMultiply,6,2,5},
            {Op::Output,6}, {Op::Halt} }};
}
xgpu::Word bits(float f){
  static_assert(sizeof(f)==sizeof(xgpu::Word));
  xgpu::Word w=0;std::memcpy(&w,&f,sizeof(w));return w;
}
float to_float(xgpu::Word w){float f=0;std::memcpy(&f,&w,sizeof(f));return f;}
struct MaterialPort {
  // Persistent ORIGINAL component controller. No new qSSD/C12 substitute.
  qssd::Space component;
  const xgpu::Kernel kernel=materials();
  std::array<xgpu::Word,10> previous{};
  std::optional<FrameOutput> cached;
  bool bound=false;
  FrameOutput evaluate(const FrameInput& input){
    const std::array<xgpu::Word,10> words{
      input.wetness,input.water_depth_cm,input.ticks,
      input.ambient_mode==0?1000u:input.ambient_mode==1?480u:120u,
      input.ambient_mode==0?0u:input.ambient_mode==1?600u:1000u,
      bits(.001f),bits(1.f),bits(.02f),bits(.001f),bits(.001f)};
    if(cached && words==previous){auto out=*cached;out.reused=true;return out;}
    xgpu::Field field(10);
    for(xgpu::Index i=0;i<words.size();++i)
      if(words[static_cast<std::size_t>(i)]!=0)
        field.details.emplace(i,words[static_cast<std::size_t>(i)]);
    field.validate();
    component.publish_field("velocity-materials",std::move(field));
    if(!bound){
      component.bind("cpu:velocity-materials","velocity-materials");
      component.route("cpu:velocity-materials","ssd:velocity-materials");
      component.route("cpu:velocity-materials","gpu:velocity-materials");bound=true;
    }
    const auto source=component.acquire("gpu:velocity-materials");
    if(source.field!=component.acquire("cpu:velocity-materials").field ||
       source.field!=component.acquire("ssd:velocity-materials").field)
      throw std::runtime_error("qSSD original ports do not share the producer field");
    qssd::C12Window window(source);
    const auto job=window.enqueue(kernel,source.field->count,5);
    if(!window.run(32) || !window.engine().dispatch(job).output_valid.full() ||
       !window.source_pointer_preserved())
      throw std::runtime_error("qSSD C12Window failed to consume the shared source");
    FrameOutput out;
    for(xgpu::Index i=0;i<5;++i)
      out.values[static_cast<std::size_t>(i)]=to_float(window.engine().dispatch(job).output->at(i));
    out.steps=window.engine().counters().steps;
    out.relation_nodes=window.engine().counters().relation_nodes_created;
    out.qssd_revision=source.revision;out.shared_source=true;
    previous=words;cached=out;return out;
  }
};
}
FrameOutput evaluate(const FrameInput& input){
  if(input.wetness>1000||input.water_depth_cm>40||input.ambient_mode>2||input.ticks>2147483647u)
    throw std::invalid_argument("C12 needs a validated XI producer observation");
  // Per GL/worker thread: component lifetime is independent of individual frames.
  // It owns only these derived material descriptors, never another game world.
  thread_local MaterialPort port;
  return port.evaluate(input);
}
}
