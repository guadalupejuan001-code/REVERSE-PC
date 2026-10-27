#include "rxe_game.hpp"
#include <fstream>
#include <iostream>
#include <sstream>
#include <chrono>
#include <algorithm>
#include <cmath>
using Bytes=reverse_pc::rxe::Bytes;
using namespace reverse_pc;
static void check(bool ok,const char* text){if(!ok)throw std::runtime_error(text);}
static std::vector<long long> values(const std::string& output){std::vector<long long> result;std::istringstream rows(output);std::string line;while(std::getline(rows,line)){auto p=line.find("\"value\":");if(p!=std::string::npos)result.push_back(std::stoll(line.substr(p+8)));}check(result.size()==18,"Frame ABI output must have 18 values");return result;}
static Bytes patch(const Bytes& state,std::string code){auto r=rvpc2::restore(state);r.execute(std::string(rxe::xi::machine_header)+"\n"+code+"\nhalt\n");return rvpc2::save(r);}
int main(int argc,char** argv){try{
 check(argc==2,"Supply game.xi");std::ifstream file(argv[1]);std::string source((std::istreambuf_iterator<char>(file)),{});auto image=rxe::compile(source,"REVERSE BREAKER");
 auto start=rxe_game::frame({},image,500,0,0);auto v=values(start.output);check(v[6]==3&&v[7]==0&&v[8]==1&&v[9]==50&&v[10]==0,"Initial state");
 auto serve=rxe_game::frame(start.state,image,500,1,4);v=values(serve.output);check(v[7]==1&&v[0]==516&&v[1]==482,"Serve uses four fixed XI ticks");
 auto low=rxe_game::frame(serve.state,image,0,0,0);check(values(low.output)[4]==85,"Paddle left clamp");auto high=rxe_game::frame(serve.state,image,1000,0,0);check(values(high.output)[4]==915,"Paddle right clamp");
 auto wall=patch(serve.state,"store8 4 25\nstore8 5 0\nstore8 6 144\nstore8 7 1\nstore8 8 121\nstore8 9 121");v=values(rxe_game::frame(wall,image,500,0,1).output);check(v[0]==24&&v[2]==7,"Wall reflection");
 auto brick=patch(serve.state,"store8 4 104\nstore8 5 0\nstore8 6 108\nstore8 7 0\nstore8 9 121");auto hit=rxe_game::frame(brick,image,500,0,1);v=values(hit.output);check(v[5]==60&&v[9]==49&&v[10]==60&&v[12]==1022&&v[3]==7,"Brick removal, score and best all execute in XI");
 auto paddle=patch(serve.state,"store8 4 38\nstore8 5 2\nstore8 6 5\nstore8 7 2\nstore8 9 138");v=values(rxe_game::frame(paddle,image,500,0,1).output);check(v[3]<0&&v[2]>0&&v[11]==2,"Paddle angle reflection");
 auto lost=patch(hit.state,"store8 4 50\nstore8 5 0\nstore8 6 78\nstore8 7 2\nstore8 9 138");auto life=rxe_game::frame(lost,image,500,0,1);v=values(life.output);check(v[6]==2&&v[7]==0&&v[10]==60,"Life loss preserves best");
 auto last=patch(lost,"store8 2 1");v=values(rxe_game::frame(last,image,500,0,1).output);check(v[6]==0&&v[7]==2,"Game over");
 auto clear=patch(brick,"store8 14 1\nstore8 32 1\nstore8 33 0\nstore8 34 0\nstore8 35 0\nstore8 36 0\nstore8 37 0\nstore8 38 0\nstore8 39 0\nstore8 40 0\nstore8 41 0");v=values(rxe_game::frame(clear,image,500,0,1).output);check(v[8]==2&&v[7]==0&&v[9]==50,"Next wave");
 clear=patch(clear,"store8 3 5");v=values(rxe_game::frame(clear,image,500,0,1).output);check(v[8]==5&&v[7]==3&&v[9]==0,"Five-sector victory");
 auto reset=rxe_game::frame(hit.state,image,500,2,0);v=values(reset.output);check(v[10]==60&&v[5]==0&&v[6]==3,"New game keeps best");
 bool rejected=false;try{rxe_game::frame(start.state,image,1001,0,1);}catch(...){rejected=true;}check(rejected,"Invalid input rejected");
 Bytes state=start.state;std::vector<double> elapsed;
 for(int n=0;n<1200;n++){
  auto current=values(rxe_game::frame(state,image,500,0,0).output);int command=current[7]==0?1:current[7]==2?2:0;int p=int(std::clamp(current[0],85LL,915LL));
  auto begin=std::chrono::steady_clock::now();auto next=rxe_game::frame(state,image,p,command,4);elapsed.push_back(std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-begin).count());v=values(next.output);int remaining=0;for(int row=12;row<17;row++)remaining+=__builtin_popcount(unsigned(v[row]));check(remaining==v[9],"Live bricks differ from XI remaining count");check(v[6]>=0&&v[6]<=3&&v[8]>=1&&v[8]<=5,"Game bounds");state=std::move(next.state);
 }
 auto a=rxe_game::frame(state,image,500,0,4),b=rxe_game::frame(rvpc2::save(rvpc2::restore(state)),image,500,0,4);check(a.state==b.state&&a.output==b.output,"Checkpoint continuation must be deterministic");std::sort(elapsed.begin(),elapsed.end());
 std::cout<<"BREAKER_TESTS_OK frames=1200 max_ticks=4800 executable_bytes="<<image.size()<<" state_bytes="<<state.size()<<" median_ms="<<elapsed[600]<<" p95_ms="<<elapsed[1140]<<" physics=XI checkpoint=RVPC2\n";
}catch(const std::exception& e){std::cerr<<"BREAKER_TESTS_FAILED "<<e.what()<<'\n';return 1;}}
