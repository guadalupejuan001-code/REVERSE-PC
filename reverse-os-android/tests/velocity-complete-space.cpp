#define main inherited_open_contract
#include "open-forest-contract.cpp"
#undef main
#include "integration/xi_live_session.hpp"

int main(int argc,char** argv){try{
 const std::filesystem::path assets=argv[1];std::map<std::string,std::string> files;
 for(const auto& entry:std::filesystem::directory_iterator(assets))if(entry.is_regular_file())files.emplace(entry.path().filename().string(),read(entry.path()));
 Runtime native;native.execute(files.at("world.xi"));
 std::string quantum="seed 73\nh 0\n";for(unsigned i=1;i<1000;i++)quantum+="cx 0 "+std::to_string(i)+"\n";
 quantum+="t 0\nmem_bind 999999999999999999999999999999 0\n";native.execute(quantum);
 reverse_pc::XiLiveSession live(reverse_pc::rvpc2::save(native));live.registerResources(files);live.registerGeometryProgram(files.at("render4k.xi"));
 const auto command=header+"store8 128 1\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 1\nstore8 133 0\nstore8 134 0\nstore8 135 0\nstore8 136 0\nstore8 138 255\n"+files.at("drive.xi").substr(header.size());
 live.stage(command);live.commit();live.setComponent("view",std::string("view\0state",10));live.setComponent("environment",std::string(1,0));
 const reverse_pc::XiLiveSession::Inputs inputs{{"141",1},{"200",1},{"201",0},{"202",0},{"203",0},{"204",0},{"205",0},{"206",0},{"207",0}};
 const auto observed=live.observePreparedSharedGeometry(inputs,4);const auto pinned=live.retainSpace();const auto nativeBefore=live.checkpoint();
 check(pinned->value->cpu==live.retain()&&pinned->value->gpu->cpu==live.retain(),"CPU and GPU must use the complete bus authority");
 check(pinned->value->gpu->quality==4&&pinned->value->gpu->program==pinned->value->resources->files.at("render4k.xi"),"GPU policy and original program are retained in the resource graph");
 check(pinned->value->resources->files.at("palette.txt")==pinned->value->resources->files.at("palette-day.txt"),"equal original resources share one byte object");
 const auto serial=pinned->serial;const auto encoded=live.checkpointSpace();
 auto restored=std::make_shared<reverse_pc::XiLiveSession>(reverse_pc::xi_restore_graph(encoded));
 check(restored->checkpoint()==nativeBefore&&restored->retain()->output==live.retain()->output,"full CPU state/output/InverseMemory/RNG restored exactly");
 check(restored->retain()->runtime.core().stats().active_qubits==1000,"all 1000 correlated qubits survive full graph persistence");
 check(restored->component("view")==live.component("view"),"binary component state restored");
 const auto recovered=restored->retainSpace();
 check(reverse_pc::xi_save_graph(*recovered->value,serial)==encoded,"complete graph archive round trip is canonical and exact");
 check(recovered->value->resources->files.at("render4k.xi")==recovered->value->gpu->resources->files.at("render4k.xi"),"restored CPU/GPU resources retain shared blob identity");
 check(recovered->value->cpu==recovered->value->gpu->cpu,"restored matching CPU dependencies share the publication");
 check(*restored->observePreparedSharedGeometry(inputs,4).geometry.value==*observed.geometry.value,"first reconstructed GPU frame matches before save");
 auto branch=restored->forkSpace();branch->stage(header+"measure 0\n");branch->commit();
 restored->stage(header+"measure 0\n");restored->commit();
 check(branch->retain()->output==restored->retain()->output&&branch->checkpoint()==restored->checkpoint(),"quantum future/RNG resumes identically in independent forks");
 check(live.checkpoint()==nativeBefore,"fork execution cannot change the original CPU state");
 live.bookmark("before");live.stage(header+"store8 550 22\n");live.commit();const auto later=live.retain()->generation;
 check(live.checkpoint()!=nativeBefore,"published CPU changes are stored by the bus");live.rewind("before");
 check(live.checkpoint()==nativeBefore&&live.retain()->generation>later,"rewind restores full state under a fresh publication identity");
 check(*pinned->value->gpu->geometry.value==*observed.geometry.value,"retained older complete state remains immutable");
 for(std::size_t at:{std::size_t(0),encoded.size()/2,encoded.size()-1}){
   auto corrupt=encoded;corrupt[at]^=1;bool rejected=false;try{reverse_pc::xi_restore_graph(corrupt);}catch(const std::exception&){rejected=true;}
   check(rejected&&live.checkpoint()==nativeBefore,"corrupt archive rejected without changing live authority");
 }
 std::cout<<"VELOCITY_COMPLETE_SPACE_PASS resources="<<files.size()<<" checkpointBytes="<<encoded.size()<<" qubits=1000 history="<<live.spaceStats().history<<"\n";return 0;
}catch(const std::exception& error){std::cerr<<"VELOCITY_COMPLETE_SPACE_FAIL "<<error.what()<<"\n";return 1;}}
