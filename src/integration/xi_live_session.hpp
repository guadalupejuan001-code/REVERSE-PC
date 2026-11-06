#pragma once
#include "rvpc2.hpp"
#include "xi_geometry_delta.hpp"
#include <memory>
#include <mutex>
#include <utility>

namespace reverse_pc {
// Retains the original compact QuantumRuntime between calls. RVPC2 remains the
// checkpoint format. No game equations or dense replacement memory live here.
class XiLiveSession {
 public:
  struct Publication {
    rvpc2::Runtime runtime;
    std::string output;
    std::uint64_t generation;
    Publication(rvpc2::Runtime value,std::string text={},std::uint64_t generation=0)
        :runtime(std::move(value)),output(std::move(text)),generation(generation){}
  };
  using Inputs=std::vector<std::pair<std::string,std::uint8_t>>;
  explicit XiLiveSession(const std::vector<std::uint8_t>& initial)
      :published_(std::make_shared<Publication>(rvpc2::restore(initial))){}
  std::shared_ptr<const Publication> retain()const {
    std::lock_guard<std::mutex> guard(publication_mutex_);return published_;
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
    pending_=std::move(candidate);return pending_->output;
  }
  std::uint64_t commit(){
    std::lock_guard<std::mutex> writer(writer_mutex_);
    if(!pending_)throw std::logic_error("No validated XI candidate");
    std::lock_guard<std::mutex> publication(publication_mutex_);
    published_=std::move(pending_);
    return published_->generation;
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
    if(source.empty()||source.size()>512U*1024U)throw std::length_error("XI registered geometry source budget");
    std::lock_guard<std::mutex> stream(geometry_mutex_);geometry_source_=std::move(source);
  }
  std::vector<std::uint8_t> observePreparedGeometry(const Inputs& inputs={})const {
    if(inputs.size()>32)throw std::length_error("XI input mailbox budget");
    std::lock_guard<std::mutex> stream(geometry_mutex_);
    if(geometry_source_.empty())throw std::logic_error("XI geometry program is not registered");
    return geometryDeltaLocked(geometry_source_,inputs);
  }
  std::vector<std::uint8_t> checkpoint()const{return rvpc2::save(retain()->runtime);}
 private:
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
  mutable std::mutex publication_mutex_;
  std::mutex writer_mutex_;
  std::shared_ptr<const Publication> published_;
  std::shared_ptr<Publication> pending_;
  mutable std::mutex geometry_mutex_;
  mutable XiGeometryDelta geometry_delta_;
  mutable std::weak_ptr<const mundo_x::infinite_program_detail::MachineParsedProgram> geometry_program_;
  mutable Inputs geometry_inputs_;
  mutable std::uint64_t geometry_generation_=0;
  std::string geometry_source_;
};
}
