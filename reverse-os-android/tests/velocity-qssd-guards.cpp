#define main inherited_open_contract
#include "open-forest-contract.cpp"
#undef main
#include "integration/xi_live_session.hpp"
#include <thread>
int main(int argc,char**argv){try{
 const std::filesystem::path root=argv[1];
 Runtime original;original.execute(read(root/"world.xi"));
 const auto drive=read(root/"drive.xi");
 original.execute(header+"store8 128 0\nstore8 129 0\nstore8 130 1\nstore8 131 0\nstore8 132 1\nstore8 133 0\nstore8 134 0\nstore8 135 0\nstore8 136 0\nstore8 138 255\n"+drive.substr(header.size()));
 reverse_pc::XiLiveSession live(reverse_pc::rvpc2::save(original));
 const auto render=read(root/"render4k.xi");
 const reverse_pc::XiLiveSession::Inputs inputs{{"141",1},{"200",1},{"201",0},{"202",0},{"203",0},{"204",0},{"205",0},{"206",0},{"207",0}};
 bool rejected=false;try{live.observePreparedSharedGeometry(inputs);}catch(const std::exception&){rejected=true;}
 check(rejected,"unregistered source cannot reuse a projection");
 live.registerGeometryProgram(render);
 const auto checkpoint=live.checkpoint();
 auto a=live.observePreparedSharedGeometry(inputs),b=live.observePreparedSharedGeometry(inputs);
 check(a.executed&&!b.executed&&a.geometry.value==b.geometry.value,"deterministic repeated state retains one immutable value");
 check(*a.geometry.value==original.observe(render,false,inputs),"shared observation equals original XI");
 live.registerGeometryProgram(render);
 check(!live.observePreparedSharedGeometry(inputs).executed,"same source registration preserves identity");
 auto changed=inputs;changed[2].second=1;
 check(live.observePreparedSharedGeometry(changed).executed,"every view input invalidates execution reuse");
 check(*a.geometry.value==original.observe(render,false,inputs),"old lease survives a newer view");
 live.observePreparedGeometry(changed);
 check(!live.observePreparedSharedGeometry(changed).executed,"legacy delta observer cannot corrupt shared identity");
 live.stage(header+"print r0\n");live.commit();
 const auto afterCommit=live.checkpoint();
 auto newer=live.observePreparedSharedGeometry(changed);
 check(newer.executed&&newer.generation==1,"publication changes force original XI execution even when geometry is equal");
 auto priorId=newer.geometry.identity;
 live.registerGeometryProgram(render+"\n# different exact program\n");
 auto reset=live.observePreparedSharedGeometry(changed);
 check(reset.executed&&reset.geometry.identity!=priorId,"changed source resets the projection namespace");
 live.registerGeometryProgram(header+"h 77\n"+render.substr(header.size()));
 live.observePreparedSharedGeometry(changed);
 check(live.observePreparedSharedGeometry(changed).executed,"quantum commands never authorize deterministic execution reuse");
 live.registerGeometryProgram(render+"\n#"+std::string(40*1024,'x')+"\n");
 live.observePreparedSharedGeometry(changed);
 check(live.observePreparedSharedGeometry(changed).executed,"sources outside parse-cache budget still execute");
 live.registerGeometryProgram(header+"unknown_opcode\n");rejected=false;
 try{live.observePreparedSharedGeometry(changed);}catch(const std::exception&){rejected=true;}
 check(rejected,"unknown source cannot be accepted as cached geometry");
 live.registerGeometryProgram(header+"print r0\n");rejected=false;
 try{live.observePreparedSharedGeometry(changed);}catch(const std::exception&){rejected=true;}
 check(rejected,"non-XFG4 output is rejected before publication");
 check(afterCommit==live.checkpoint()&&live.retain()->generation==1,"readers never commit a world or quantum state");
 // Save every actual publisher generation, then verify raced observations
 // against that exact retained state after the threads finish.
 reverse_pc::XiLiveSession raced(checkpoint);raced.registerGeometryProgram(render);
 std::vector<std::shared_ptr<const reverse_pc::XiLiveSession::Publication>> history{raced.retain()};
 std::vector<reverse_pc::XiLiveSession::SharedObservation> observed;
 std::exception_ptr readerFailure;
 std::thread reader([&]{try{for(unsigned i=0;i<24;i++)observed.push_back(raced.observePreparedSharedGeometry(inputs));}catch(...){readerFailure=std::current_exception();}});
 for(unsigned i=0;i<32;i++){
  raced.stage(header+"store8 400 "+std::to_string(i)+"\nload8 r0 400\nprint r0\n");
  raced.commit();history.push_back(raced.retain());
 }
 reader.join();if(readerFailure)std::rethrow_exception(readerFailure);
 for(const auto& frame:observed){
  check(frame.generation<history.size(),"raced generation stays within retained history");
  const auto& state=*history[frame.generation];
  check(frame.output==state.output&&*frame.geometry.value==state.runtime.observe(render,false,inputs),"state, geometry and publication remain coherent during concurrent writes");
 }
 std::cout<<"VELOCITY_QSSD_GUARDS_PASS concurrentReads="<<observed.size()<<"\n";return 0;
}catch(const std::exception& error){std::cerr<<"VELOCITY_QSSD_GUARDS_FAIL "<<error.what()<<"\n";return 1;}}
