#pragma once
#include "xi_state_space.hpp"
#include "xi_geometry_delta.hpp"
#include "qssd/shared_projection.hpp"
#include <memory>
#include <mutex>
#include <utility>

namespace reverse_pc {
// Retains the original compact QuantumRuntime between calls. RVPC2 remains the
// checkpoint format. No game equations or dense replacement memory live here.
class XiLiveSession {
 public:
  using Publication=XiCpuPublication;
  using Inputs=XiInputs;
  using StateBus=qssd::StateBus<XiSessionGraph>;
  explicit XiLiveSession(const std::vector<std::uint8_t>& initial)
      :XiLiveSession(initialGraph(initial)){}
  explicit XiLiveSession(XiSessionGraph initial):state_bus_(std::move(initial),32,xi_validate_graph){}
  std::shared_ptr<const Publication> retain()const{return state_bus_.snapshot()->value->cpu;}
  StateBus::View retainSpace()const{return state_bus_.snapshot();}
  StateBus::Stats spaceStats()const{return state_bus_.stats();}
  std::string checkpointSpace()const{const auto root=state_bus_.snapshot();return xi_save_graph(*root->value,root->serial);}
  void registerResources(const std::map<std::string,std::string>& values){
    const auto resources=xi_resources(values);
    state_bus_.update([&](XiSessionGraph& state){state.resources=resources;return true;},"resources");
  }
  void setComponent(const std::string& name,std::string bytes){
    xi_resource_name(name);if(bytes.size()>65536)throw std::length_error("XI component state bytes");
    const auto value=std::make_shared<const std::string>(std::move(bytes));
    state_bus_.update([&](XiSessionGraph& state){
      const auto found=state.components->find(name);
      if(found!=state.components->end()&&*found->second==*value)return false;
      auto next=std::make_shared<XiComponents>(*state.components);(*next)[name]=value;state.components=std::move(next);return true;
    },"component:"+name);
  }
  std::string component(const std::string& name)const{
    xi_resource_name(name);const auto state=state_bus_.snapshot();const auto found=state->value->components->find(name);
    return found==state->value->components->end()?std::string{}:*found->second;
  }
  std::string stateOutput()const{return retain()->output;}
  std::shared_ptr<XiLiveSession> forkSpace()const{return std::shared_ptr<XiLiveSession>(new XiLiveSession(state_bus_.fork()));}
  void bookmark(const std::string& name){state_bus_.bookmark(name,state_bus_.snapshot());}
  std::uint64_t rewind(const std::string& name){
    std::scoped_lock lock(writer_mutex_,geometry_mutex_);
    auto target=*state_bus_.bookmark(name)->value;
    const auto generation=retain()->generation;
    if(generation>=INT64_MAX)throw std::overflow_error("XI publication counter exhausted");
    target.cpu=std::make_shared<const Publication>(target.cpu->runtime,target.cpu->output,generation+1,target.cpu->command);
    pending_.reset();state_bus_.publish(std::move(target),"rewind:"+name);
    shared_geometry_.reset();shared_program_.reset();geometry_program_.reset();return generation+1;
  }
  // Java validates the observed registers before commit. A rejected candidate
  // never replaces the state from which renderers and physics read.
  std::string stage(const std::string& source){
    std::lock_guard<std::mutex> writer(writer_mutex_);
    if(pending_)throw std::logic_error("XI candidate already pending");
    const auto current=retain();
    if(current->generation>=INT64_MAX)throw std::overflow_error("XI publication counter exhausted");
    auto candidate=std::make_shared<Publication>(current->runtime,std::string{},current->generation+1);
    candidate->output=candidate->runtime.execute(source);
    candidate->command=current->command&&*current->command==source?current->command:std::make_shared<const std::string>(source);
    pending_=std::move(candidate);return pending_->output;
  }
  std::uint64_t commit(){
    std::lock_guard<std::mutex> writer(writer_mutex_);
    if(!pending_)throw std::logic_error("No validated XI candidate");
    const auto candidate=pending_;
    state_bus_.update([&](XiSessionGraph& state){state.cpu=candidate;return true;},"cpu");
    pending_.reset();return candidate->generation;
  }
  void discard(){std::lock_guard<std::mutex> writer(writer_mutex_);pending_.reset();}
  struct Observation {std::string output,frame;std::uint64_t generation;};
  Observation observe(const std::string& source,const Inputs& inputs={})const {
    if(inputs.size()>32)throw std::length_error("XI input mailbox budget");
    const auto retained=retain();
    return {retained->output,retained->runtime.observe(source,false,inputs),retained->generation};
  }
  // Serialize only this retained transport channel, never the physics writer.
  // Every packet carries both a publication identity and an exact base serial.
  std::vector<std::uint8_t> observeGeometryDelta(const std::string& source,const Inputs& inputs={})const {
    if(inputs.size()>32)throw std::length_error("XI input mailbox budget");
    std::lock_guard<std::mutex> stream(geometry_mutex_);
    return geometryDeltaLocked(source,inputs);
  }
  void registerGeometryProgram(std::string source){
    if(source.empty()||source.size()>16U*1024U*1024U)throw std::length_error("XI registered geometry source budget");
    std::lock_guard<std::mutex> stream(geometry_mutex_);
    const auto current=state_bus_.snapshot();
    if(source==*current->value->program)return;
    XiBlob program;
    for(const auto& resource:current->value->resources->files)if(*resource.second==source){program=resource.second;break;}
    if(!program)program=std::make_shared<const std::string>(std::move(source));
    state_bus_.update([&](XiSessionGraph& state){state.program=program;return true;},"geometry-program");
    shared_geometry_.reset();shared_program_.reset();shared_inputs_.clear();
  }
  std::vector<std::uint8_t> observePreparedGeometry(const Inputs& inputs={})const {
    if(inputs.size()>32)throw std::length_error("XI input mailbox budget");
    std::lock_guard<std::mutex> stream(geometry_mutex_);
    if(state_bus_.snapshot()->value->program->empty())throw std::logic_error("XI geometry program is not registered");
    return geometryDeltaLocked(*state_bus_.snapshot()->value->program,inputs);
  }
  using SharedGeometry = qssd::SharedProjection<std::string>;
  struct SharedObservation {
    std::string output;
    std::uint64_t generation;
    SharedGeometry::Lease geometry;
    bool executed;
  };
  // qSSD keeps the original XI observation by identity/version. A physical API
  // projection is explicit; handing the immutable observation to CPU/SSD/GPU
  // does not build an XGD1 packet or reconstruct another complete Java array.
  SharedObservation observePreparedSharedGeometry(const Inputs& inputs={},unsigned quality=2,const std::string& viewState={})const {
    if(inputs.size()>32)throw std::length_error("XI input mailbox budget");
    std::lock_guard<std::mutex> stream(geometry_mutex_);
    if(state_bus_.snapshot()->value->program->empty())throw std::logic_error("XI geometry program is not registered");
    if(quality>4||viewState.size()>65536)throw std::invalid_argument("XI GPU quality/view state policy");
    const auto root=state_bus_.snapshot();const auto retained=root->value->cpu;const auto programSource=root->value->program;
    const auto parsed=shared_program_.lock();
    SharedGeometry::Lease lease;bool executed=true;
    if(parsed&&parsed->deterministic&&retained==shared_cpu_&&
       parsed->source==*programSource&&inputs==shared_inputs_){
      lease=shared_geometry_.acquire(qssd::ProjectionPort::GPU);executed=false;
    }else{
      auto frame=retained->runtime.observe(*programSource,false,inputs);
      if(frame.size()<2064||frame.size()>XiGeometryDelta::max_frame_bytes||frame.size()%4||frame.compare(0,4,"XFG4"))
        throw std::length_error("XI shared geometry transport bounds");
      lease=shared_geometry_.publish(std::move(frame));
      const auto program=mundo_x::infinite_program_detail::machine_parse_cache_state().program;
      if(program&&program->source==*programSource&&program->deterministic)shared_program_=program;
      else shared_program_.reset();
      shared_inputs_=inputs;shared_cpu_=retained;
    }
    auto capture=std::make_shared<XiGpuState>();capture->cpu=retained;capture->resources=root->value->resources;
    capture->components=root->value->components;
    if(!viewState.empty()){
      const auto old=capture->components->find("view");
      if(old==capture->components->end()||*old->second!=viewState){auto next=std::make_shared<XiComponents>(*capture->components);(*next)["view"]=std::make_shared<const std::string>(viewState);capture->components=std::move(next);}
    }
    capture->program=programSource;capture->inputs=inputs;capture->geometry=lease;capture->quality=quality;
    state_bus_.update([&](XiSessionGraph& state){
      const auto& old=state.gpu;
      if(old&&old->cpu==capture->cpu&&old->resources==capture->resources&&old->components==capture->components&&old->program==capture->program&&
         old->inputs==inputs&&old->quality==quality&&old->geometry.value==lease.value)return false;
      state.gpu=capture;
      if(!viewState.empty()){
        if(state.components==root->value->components)state.components=capture->components;
        else{auto merged=std::make_shared<XiComponents>(*state.components);(*merged)["view"]=capture->components->at("view");state.components=std::move(merged);}
      }
      return true;
    },"gpu-prepared");
    return {retained->output,retained->generation,std::move(lease),executed};
  }
  std::vector<std::uint8_t> checkpoint()const{return rvpc2::save(retain()->runtime);}
 private:
  explicit XiLiveSession(StateBus initial):state_bus_(std::move(initial)){}
  std::vector<std::uint8_t> geometryDeltaLocked(const std::string& source,const Inputs& inputs)const {
    const auto retained=retain();
    const auto parsed=geometry_program_.lock();
    if(parsed&&parsed->deterministic&&retained->generation==geometry_generation_&&
       parsed->source==source&&inputs==geometry_inputs_)
      return geometry_delta_.repeat(retained->output,retained->generation);
    auto frame=retained->runtime.observe(source,false,inputs);
    auto packet=geometry_delta_.encode(retained->output,std::move(frame),retained->generation);
    const auto program=mundo_x::infinite_program_detail::machine_parse_cache_state().program;
    if(program&&program->source==source&&program->deterministic)geometry_program_=program;
    else geometry_program_.reset();
    geometry_inputs_=inputs;geometry_generation_=retained->generation;return packet;
  }
  std::mutex writer_mutex_;
  mutable StateBus state_bus_;
  static XiSessionGraph initialGraph(const std::vector<std::uint8_t>& initial){XiSessionGraph graph;graph.cpu=std::make_shared<const Publication>(rvpc2::restore(initial));return graph;}
  std::shared_ptr<Publication> pending_;
  mutable std::mutex geometry_mutex_;
  mutable XiGeometryDelta geometry_delta_;
  mutable SharedGeometry shared_geometry_;
  mutable std::weak_ptr<const mundo_x::infinite_program_detail::MachineParsedProgram> shared_program_;
  mutable Inputs shared_inputs_;
  mutable std::shared_ptr<const Publication> shared_cpu_;
  mutable std::weak_ptr<const mundo_x::infinite_program_detail::MachineParsedProgram> geometry_program_;
  mutable Inputs geometry_inputs_;
  mutable std::uint64_t geometry_generation_=0;
};
}
