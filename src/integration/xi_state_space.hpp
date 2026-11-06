#pragma once
#include "rvpc2.hpp"
#include "xi_geometry_delta.hpp"
#include "qssd/shared_projection.hpp"
#include "qssd/state_bus.hpp"
#include "qssd/state_archive.hpp"
#include <charconv>
#include <map>
#include <set>

namespace reverse_pc {
using XiInputs=std::vector<std::pair<std::string,std::uint8_t>>;
using XiBlob=qssd::StateArchive::Blob;
struct XiCpuPublication {
  rvpc2::Runtime runtime;
  std::string output;
  std::uint64_t generation;
  XiBlob command;
  XiCpuPublication(rvpc2::Runtime value,std::string text={},std::uint64_t serial=0,XiBlob source=std::make_shared<const std::string>())
    :runtime(std::move(value)),output(std::move(text)),generation(serial),command(std::move(source)){}
};
struct XiResources {
  std::map<std::string,XiBlob> files;
  std::size_t uniqueBytes=0;
};
using XiComponents=std::map<std::string,XiBlob>;
struct XiGpuState {
  std::shared_ptr<const XiCpuPublication> cpu;
  std::shared_ptr<const XiResources> resources;
  std::shared_ptr<const XiComponents> components;
  XiBlob program;
  XiInputs inputs;
  qssd::SharedProjection<std::string>::Lease geometry;
  unsigned quality=2;
};
// One complete logical root: actual native CPU/RNG/InverseMemory, all resources,
// producer programs, component state and the last prepared GPU job with its
// EXACT CPU/resource dependencies. Driver handles are rebuilt, never serialized.
struct XiSessionGraph {
  std::uint64_t restoredFrom=0;
  std::shared_ptr<const XiCpuPublication> cpu;
  std::shared_ptr<const XiResources> resources=std::make_shared<const XiResources>();
  std::shared_ptr<const XiComponents> components=std::make_shared<const XiComponents>();
  XiBlob program=std::make_shared<const std::string>();
  std::shared_ptr<const XiGpuState> gpu;
};
inline void xi_resource_name(const std::string& name){
  if(name.empty()||name.size()>100||name=="."||name=="..")throw std::invalid_argument("XI resource name");
  for(unsigned char c:name)if(!((c>='a'&&c<='z')||(c>='A'&&c<='Z')||(c>='0'&&c<='9')||c=='.'||c=='-'||c=='_'))
    throw std::invalid_argument("XI resource name character");
}
inline std::shared_ptr<const XiResources> xi_resources(const std::map<std::string,std::string>& values){
  if(values.size()>128)throw std::length_error("XI resource count budget");
  auto result=std::make_shared<XiResources>();std::vector<XiBlob> unique;
  for(const auto& item:values){
    xi_resource_name(item.first);XiBlob value;
    for(const auto& prior:unique)if(*prior==item.second){value=prior;break;}
    if(!value){
      if(item.second.size()>16u*1024u*1024u-result->uniqueBytes)throw std::length_error("XI unique resource byte budget");
      value=std::make_shared<const std::string>(item.second);result->uniqueBytes+=value->size();unique.push_back(value);
    }
    result->files.emplace(item.first,std::move(value));
  }return result;
}
inline void xi_validate_graph(const XiSessionGraph& state){
  if(!state.cpu||!state.cpu->command||state.cpu->command->size()>16u*1024u*1024u||!state.resources||!state.components||!state.program||state.cpu->generation>INT64_MAX||state.cpu->output.size()>65536||
     state.resources->files.size()>128||state.resources->uniqueBytes>16u*1024u*1024u||state.components->size()>16||state.program->size()>16u*1024u*1024u)
    throw std::length_error("XI complete state graph bounds");
  for(const auto& item:*state.components){xi_resource_name(item.first);if(!item.second||item.second->size()>65536)throw std::length_error("XI component state bounds");}
  if(state.gpu){
    const auto& gpu=*state.gpu;
    if(!gpu.cpu||!gpu.cpu->command||gpu.cpu->command->size()>16u*1024u*1024u||!gpu.resources||!gpu.components||!gpu.program||gpu.program->size()>16u*1024u*1024u||!gpu.geometry.value||gpu.quality>4||gpu.inputs.size()>32||
       gpu.cpu->generation>INT64_MAX||gpu.cpu->output.size()>65536||gpu.resources->files.size()>128||gpu.resources->uniqueBytes>16u*1024u*1024u||gpu.components->size()>16)
      throw std::invalid_argument("XI incomplete GPU dependency graph");
    for(const auto& item:*gpu.components){xi_resource_name(item.first);if(!item.second||item.second->size()>65536)throw std::length_error("XI stored GPU component bounds");}
    const auto& frame=*gpu.geometry.value;
    if(frame.size()<2064||frame.size()>XiGeometryDelta::max_frame_bytes||frame.size()%4||frame.compare(0,4,"XFG4"))
      throw std::invalid_argument("XI GPU state frame bounds");
    const auto word=[&](std::size_t at){std::uint32_t v=0;for(unsigned i=0;i<4;i++)v|=std::uint32_t(static_cast<unsigned char>(frame[at+i]))<<(8*i);return v;};
    if(word(12)>8192||2064u+word(12)*60u!=frame.size())throw std::invalid_argument("XI GPU frame inventory");
    for(const auto& input:gpu.inputs){
      if(input.first.empty()||input.first.size()>4096)throw std::invalid_argument("XI stored GPU mailbox address");
      for(char c:input.first)if(c<'0'||c>'9')throw std::invalid_argument("XI stored GPU address character");
    }
  }
}
inline std::string xi_save_graph(const XiSessionGraph& graph,std::uint64_t serial){
  xi_validate_graph(graph);qssd::StateArchive archive;
  archive.add("schema","XI-QSSD-STATE-3");archive.add("bus.source-revision",std::to_string(serial));
  auto cpu=[&](const std::string& prefix,const std::shared_ptr<const XiCpuPublication>& value){
    auto saved=rvpc2::save(value->runtime);archive.add(prefix+"native",std::string(saved.begin(),saved.end()));
    archive.add(prefix+"output",value->output);archive.add(prefix+"generation",std::to_string(value->generation));
    archive.add(prefix+"command",value->command);
  };
  auto resources=[&](const std::string& prefix,const XiResources& values){for(const auto& item:values.files)archive.add(prefix+item.first,item.second);};
  auto components=[&](const std::string& prefix,const XiComponents& values){for(const auto& item:values)archive.add(prefix+item.first,item.second);};
  cpu("cpu.",graph.cpu);resources("resource.",*graph.resources);components("component.",*graph.components);
  archive.add("program.geometry",graph.program);archive.add("gpu.present",graph.gpu?"1":"0");
  if(graph.gpu){
    const auto& gpu=*graph.gpu;
    if(gpu.cpu==graph.cpu){for(const auto& suffix:{"native","output","generation","command"})archive.add(std::string("gpu.cpu.")+suffix,archive.blob(std::string("cpu.")+suffix));}
    else cpu("gpu.cpu.",gpu.cpu);
    resources("gpu.resource.",*gpu.resources);components("gpu.component.",*gpu.components);
    archive.add("gpu.program",gpu.program);archive.add("gpu.frame",gpu.geometry.value);
    archive.add("gpu.quality",std::to_string(gpu.quality));archive.add("gpu.inputs",std::to_string(gpu.inputs.size()));
    for(std::size_t i=0;i<gpu.inputs.size();i++){
      auto prefix="gpu.input."+std::to_string(i)+".";
      archive.add(prefix+"address",gpu.inputs[i].first);archive.add(prefix+"byte",std::to_string(gpu.inputs[i].second));
    }
  }return archive.encode();
}
inline XiSessionGraph xi_restore_graph(const std::string& bytes){
  const auto archive=qssd::StateArchive::decode(bytes);std::set<std::string> used;
  auto blob=[&](const std::string& name){used.insert(name);return archive.blob(name);};
  auto text=[&](const std::string& name){return *blob(name);};
  auto number=[&](const std::string& name,std::uint64_t max){
    const auto value=text(name);std::uint64_t n=0;auto parsed=std::from_chars(value.data(),value.data()+value.size(),n);
    if(value.empty()||(value.size()>1&&value[0]=='0')||parsed.ec!=std::errc{}||parsed.ptr!=value.data()+value.size()||n>max)
      throw std::invalid_argument("XI state archive integer");
    return n;
  };
  if(text("schema")!="XI-QSSD-STATE-3")throw std::invalid_argument("XI state archive schema");
  (void)number("bus.source-revision",INT64_MAX);
  auto cpu=[&](const std::string& prefix){
    const auto native=blob(prefix+"native");if(native->size()>rvpc2::max_state+29)throw std::length_error("XI stored native CPU bounds");
    return std::make_shared<const XiCpuPublication>(rvpc2::restore({native->begin(),native->end()}),text(prefix+"output"),number(prefix+"generation",INT64_MAX),blob(prefix+"command"));
  };
  auto resources=[&](const std::string& prefix){
    auto values=std::make_shared<XiResources>();std::set<const std::string*> unique;
    for(const auto& item:archive.entries())if(item.first.compare(0,prefix.size(),prefix)==0){
      auto name=item.first.substr(prefix.size());xi_resource_name(name);used.insert(item.first);values->files.emplace(name,item.second);
      if(unique.insert(item.second.get()).second){
        if(item.second->size()>16u*1024u*1024u-values->uniqueBytes)throw std::length_error("XI restored resource byte budget");
        values->uniqueBytes+=item.second->size();
      }
    }
    if(values->files.size()>128)throw std::length_error("XI restored resource count");
    return std::shared_ptr<const XiResources>(values);
  };
  auto components=[&](const std::string& prefix){
    auto values=std::make_shared<XiComponents>();
    for(const auto& item:archive.entries())if(item.first.compare(0,prefix.size(),prefix)==0){
      auto name=item.first.substr(prefix.size());xi_resource_name(name);used.insert(item.first);values->emplace(name,item.second);
    }
    if(values->size()>16)throw std::length_error("XI component state count");
    return std::shared_ptr<const XiComponents>(values);
  };
  XiSessionGraph state;state.restoredFrom=number("bus.source-revision",INT64_MAX);state.cpu=cpu("cpu.");state.resources=resources("resource.");state.components=components("component.");state.program=blob("program.geometry");
  const auto present=number("gpu.present",1);
  if(present){
    auto gpu=std::make_shared<XiGpuState>();
    if(archive.blob("gpu.cpu.native")==archive.blob("cpu.native")&&archive.get("gpu.cpu.output")==state.cpu->output&&archive.get("gpu.cpu.generation")==archive.get("cpu.generation")&&archive.blob("gpu.cpu.command")==archive.blob("cpu.command")){
      gpu->cpu=state.cpu;for(const auto& suffix:{"native","output","generation","command"})(void)blob(std::string("gpu.cpu.")+suffix);
    }else gpu->cpu=cpu("gpu.cpu.");
    gpu->resources=resources("gpu.resource.");gpu->components=components("gpu.component.");
    gpu->program=blob("gpu.program");gpu->geometry={1,1,blob("gpu.frame")};gpu->quality=static_cast<unsigned>(number("gpu.quality",4));
    const auto count=number("gpu.inputs",32);
    for(std::uint64_t i=0;i<count;i++){auto prefix="gpu.input."+std::to_string(i)+".";gpu->inputs.emplace_back(text(prefix+"address"),static_cast<std::uint8_t>(number(prefix+"byte",255)));}
    state.gpu=std::move(gpu);
  }
  if(used.size()!=archive.entries().size())throw std::invalid_argument("XI unrecognized state archive sections");
  xi_validate_graph(state);return state;
}
} // namespace reverse_pc
