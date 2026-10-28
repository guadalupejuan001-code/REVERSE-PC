#include "minimal_guest.hpp"
#include <future>
#include <iostream>
using namespace reverse_pc::guest;
namespace {
unsigned checks=0;
void check(bool okay,const char* message){++checks;if(!okay)throw std::runtime_error(message);}
template<class F>void fails(F action,const char* message){bool failed=false;try{action();}catch(const std::exception&){failed=true;}check(failed,message);}
Bytes elf(std::initializer_list<std::uint32_t> words,bool system=false){
  Bytes code;for(auto word:words)put(code,word,4);const auto entry=system?0x40080000:0x1000;
  Bytes bytes{0x7f,'E','L','F',2,1,1,0,0,0,0,0,0,0,0,0};
  put(bytes,2,2);put(bytes,183,2);put(bytes,1,4);put(bytes,entry);put(bytes,64);put(bytes,0);
  put(bytes,0,4);put(bytes,64,2);put(bytes,56,2);put(bytes,1,2);put(bytes,0,2);put(bytes,0,2);put(bytes,0,2);
  put(bytes,1,4);put(bytes,7,4);put(bytes,0x100);put(bytes,entry);put(bytes,entry);put(bytes,code.size());put(bytes,code.size());put(bytes,0x100);
  bytes.resize(0x100);bytes.insert(bytes.end(),code.begin(),code.end());return bytes;
}
void arithmetic(){
  FloatingState state;ArmFloat fp(state);
  check(fp.binary(2,32,0x3f800000,0x40000000)==0x40400000,"FP32 addition");
  check(fp.sqrt(64,UINT64_C(0x4010000000000000))==UINT64_C(0x4000000000000000),"FP64 square root");
  state.fpsr=0;check(fp.binary(1,32,0x3f800000,0)==0x7f800000&&state.fpsr==2,"Divide by zero result/flag");
  state.fpsr=0;check(fp.binary(1,32,0,0)==0x7fc00000&&state.fpsr==1,"Invalid result/flag");
  state.fpsr=0;check(fp.binary(4,32,0,0x80000000)==0&&fp.binary(5,32,0,0x80000000)==0x80000000,"Min/max signed zero");
  check(fp.binary(6,32,0x7fc12345,0x3f800000)==0x3f800000,"Maximum number and quiet NaN");
  check(fp.binary(6,32,0x7f812345,0x3f800000)==0x7fc12345&&state.fpsr==1,"Signaling NaN propagation");
  state.fpsr=0;state.fpcr=1u<<22;
  check(fp.binary(2,32,0x3f800000,0x33800000)==0x3f800001&&state.fpsr==16,"Round toward positive infinity");
  state.fpcr=2u<<22;check(fp.binary(2,32,0x3f800000,0x33800000)==0x3f800000,"Round toward negative infinity");
  state.fpcr=1u<<24;state.fpsr=0;
  check(fp.binary(2,32,1,0)==0&&state.fpsr==128,"FZ input denormal and IDC");
  state.fpsr=0;check(fp.binary(0,32,0x00800000,0x3f000000)==0&&state.fpsr==8,"FZ output underflow");
  state.fpcr=1u<<25;state.fpsr=0;
  check(fp.binary(2,32,0x7fc12345,0)==0x7fc00000,"Default NaN mode");
  state.fpcr=0;state.fpsr=0;
  check(fp.to_int(64,UINT64_C(0xc004000000000000),true,64,softfloat_round_minMag)==UINT64_MAX-1&&state.fpsr==16,"Signed conversion truncation and IXC");
  check(fp.to_int(32,0x7fc12345,true,32,softfloat_round_minMag)==0&&(state.fpsr&1),"NaN conversion saturation");
  auto worker=[](unsigned mode,std::uint64_t expected){FloatingState s;s.fpcr=mode<<22;ArmFloat f(s);for(unsigned n=0;n<20000;++n)if(f.binary(2,32,0x3f800000,0x33800000)!=expected)return false;return true;};
  auto up=std::async(std::launch::async,worker,1,0x3f800001),down=std::async(std::launch::async,worker,2,0x3f800000);
  check(up.get()&&down.get(),"Concurrent guest rounding modes contaminated one another");
}
void sparse_state(){
  FloatingState state;check(state.save().empty(),"Zero FP state should occupy no snapshot payload");
  state.v[31]={1,UINT64_MAX};check(state.save().size()==36,"One nonzero register should need one mask bit and 16 bytes");
  check(FloatingState::restore(state.save()).save()==state.save(),"Sparse FP state is not exact");
  for(auto& v:state.v)v={UINT64_MAX,UINT64_MAX};state.fpcr=0x03c00000;state.fpsr=0x0800009f;
  check(state.save().size()==532&&FloatingState::restore(state.save()).save()==state.save(),"Full FP register state exceeds finite bound or loses bits");
  auto malformed=state.save();malformed.pop_back();fails([&]{FloatingState::restore(malformed);},"Truncated FP state accepted");
  malformed=state.save();malformed[8]|=1;fails([&]{FloatingState::restore(malformed);},"Unsupported FPCR state accepted");
  malformed={'R','F','P','1',13,10,26,10};malformed.resize(20);fails([&]{FloatingState::restore(malformed);},"Redundant all-zero FP payload accepted");
}
void architectural_state(){
  // Opcodes independently assembled and covered again by the full QEMU witness.
  const auto image=elf({0x1e2e1000,0x1e201001,0x1e212802,0x1e260040,0x4f02e443,0x4e238463});
  MinimalGuest whole(65536);whole.load_elf(image);
  check(whole.snapshot()[3]=='1',"Legacy integer checkpoint changed before any FP state exists");
  whole.apply_xi_delta("h 4095\n");const auto core=whole.runtime().core_snapshot();
  auto sliced=MinimalGuest::from_snapshot(whole.snapshot());whole.run(6);
  for(unsigned n=0;n<6;++n){sliced.run(1);sliced=MinimalGuest::from_snapshot(sliced.snapshot());}
  check(whole.registers().x[0]==0x40400000,"FMOV/FADD scalar instruction decoder");
  check(whole.floating().v[3].low==UINT64_C(0x8484848484848484)&&whole.floating().v[3].high==whole.floating().v[3].low,"MOVI/ADD vector decoder");
  check(whole.snapshot()[3]=='3'&&whole.snapshot()==sliced.snapshot(),"RVG3 sliced execution is not bit-exact");
  check(whole.runtime().core_snapshot()==core,"FP/SIMD execution changed original quantum core");
  check(whole.runtime().memory().stats().overrides==0,"FP registers allocated guest RAM differences");
  const auto before=whole.snapshot();fails([&]{whole.run(1);},"End of executable accepted");check(before==whole.snapshot(),"Rejected instruction changed FP/CPU/core state");
  whole.load_elf(elf({0x1e2703e0}));whole.run(1);check(whole.snapshot()[3]=='1'&&!whole.floating().nonzero(),"Writing a zero register materialized redundant state");
  const auto trap_image=elf({0x1e2e1000},true);MinimalGuest trap(128*1024*1024);trap.load_elf(trap_image,true);trap.run(1);
  check(trap.machine().exceptions==1&&(trap.machine().esr>>26)==7&&!trap.floating().nonzero(),"CPACR FPEN did not trap before changing a register");
  // MSR CPACR_EL1,x0, with x0 built from a MOVZ of the FPEN field.
  MinimalGuest allowed(128*1024*1024);allowed.load_elf(elf({0xd2a00600,0xd5181040,0x1e2e1000},true),true);allowed.run(3);
  check(allowed.machine().exceptions==0&&allowed.floating().v[0].low==0x3f800000,"Enabled FPEN rejected EL1 FP");
  check(MinimalGuest::from_snapshot(allowed.snapshot()).snapshot()==allowed.snapshot(),"System FP checkpoint lost architectural state");
}
}
int main(){try{arithmetic();sparse_state();architectural_state();std::cout<<"{\"checks\":"<<checks<<",\"fp\":\"ARMv8 bounded FP32/FP64 + SIMD\",\"state\":\"sparse RVG3\",\"quantum_engine\":\"unchanged\"}\n";}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
