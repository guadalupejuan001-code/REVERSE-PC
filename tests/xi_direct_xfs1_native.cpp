#include "mundo_x/quantum_runtime.hpp"
#include "rxe.hpp"
#include <cstdint>
#include <iostream>
#include <stdexcept>
#include <string>
using Runtime=mundo_x::QuantumRuntime;
static void need(bool ok,const char* m){if(!ok)throw std::runtime_error(m);}
static unsigned u16(const std::string& s,std::size_t i){
 return static_cast<unsigned char>(s.at(i)) |
  (unsigned(static_cast<unsigned char>(s.at(i+1)))<<8);
}
static unsigned u32(const std::string& s,std::size_t i){
 return u16(s,i)|(u16(s,i+2)<<16);
}
int main(){
 try{
  Runtime rt;
  constexpr const char* banner="#!reverse-pc-machine-v1\n";
  const auto oldCore=rt.core_snapshot(),oldMem=rt.memory_persistent_snapshot();
  const auto src=std::string(banner)+
   "set r0 8\nset r1 2\nxframe r0 r1 9\n"
   "xspan 0 1 6 2 200\nxspan 0 3 4 3 100\n"
   "xspan 1 0 7 2 200\nxend\nhalt\n";
  const auto out=rt.execute(src);
  need(out.size()==66&&out.substr(0,4)=="XFS1","binary XFS1 size/magic");
  need(static_cast<unsigned char>(out[4])==1&&u16(out,6)==8&&u16(out,8)==2&&u32(out,10)==9,"header");
  need(static_cast<unsigned char>(out[16])==2&&out[17]==2&&u16(out,18)==0
    &&u16(out,20)==1&&u16(out,22)==6&&u16(out,24)==200&&u32(out,26)==9,"span 0");
  need(static_cast<unsigned char>(out[30])==2&&out[31]==3&&u16(out,36)==4
    &&u16(out,38)==100,"span 1");
  need(static_cast<unsigned char>(out[58])==3&&u32(out,62)==9,"end");
  need(rt.core_snapshot()==oldCore&&rt.memory_persistent_snapshot()==oldMem,"frame mutated Ether");
  const auto compiled=reverse_pc::rxe::compile(src,"DIRECT XFS1");
  const auto recovered=reverse_pc::rxe::disassemble(reverse_pc::rxe::decode(compiled));
  Runtime viaRXE;
  need(viaRXE.execute(recovered)==out,"RXE disassemble mismatch");
  need(reverse_pc::rxe::execute(viaRXE,compiled)==out,"RXE execution mismatch");
  unsigned rejects=0;
  auto bad=[&](std::string program,const char* phrase){
    const auto before=rt.core_snapshot(),memory=rt.memory_persistent_snapshot();
    bool caught=false;
    try{(void)rt.execute(std::string(banner)+program);}
    catch(const std::exception& e){caught=std::string(e.what()).find(phrase)!=std::string::npos;}
    need(caught,"invalid XFS1 not rejected");
    need(rt.core_snapshot()==before&&rt.memory_persistent_snapshot()==memory,"rollback broke");
    rejects++;
  };
  bad("xspan 0 0 1 2 3\n","without an open frame");
  bad("xend\n","without an open frame");
  bad("xframe 8 2 1\nxspan 2 0 1 2 100\nxend\n","row");
  bad("xframe 8 2 1\nxspan 0 8 9 2 100\nxend\n","left");
  bad("xframe 8 2 1\nxspan 0 2 1 2 100\nxend\n","right");
  bad("xframe 8 2 1\nxspan 0 0 1 2 0\nxend\n","depth");
  bad("xframe 8 2 1\nxspan 0 0 1 256 1\nxend\n","material");
  bad("xframe 8 2 1\nxframe 8 2 1\nxend\n","start once");
  bad("print r0\nxframe 8 2 1\nxend\n","empty output");
  bad("xframe 8 2 1\nprint r0\nxend\n","cannot mix");
  bad("xframe 8 2 1\nxspan 0 0 1 2 99\n","unterminated XFS1");
  bad("xframe 8192 8192 1\nxend\n","pixel budget");
  bad("xframe 8 2 1\nxend\nxend\n","without an open frame");
  bad("xframe 8 2 1\nxend\nprint r0\n","cannot mix");
  bad("store8 500 99\nxframe 8 2 1\nxspan 0 8 8 2 3\nxend\n","left");
  std::cout<<"XI_DIRECT_XFS1_NATIVE_OK bytes="<<out.size()
     <<" compiledRXE="<<compiled.size()<<" rejected="<<rejects<<" state=unchanged\n";
 }catch(const std::exception& e){
  std::cerr<<"XI_DIRECT_XFS1_NATIVE_FAIL "<<e.what()<<"\n";return 1;
 }
}
