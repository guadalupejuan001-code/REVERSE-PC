#pragma once
// Transport only. Physics, scoring and levels are instructions in game.xi.
#include "rxe.hpp"
#include "rvpc2.hpp"
namespace reverse_pc::rxe_game {
struct Frame {std::string output; rxe::Bytes state;};
inline Frame frame(const rxe::Bytes& state,const rxe::Bytes& executable,int paddle,int command,int ticks){
    rxe::require(paddle>=0&&paddle<=1000&&command>=0&&command<=2&&ticks>=0&&ticks<=4,"Entrada de juego fuera de rango");
    auto source=rxe::disassemble(rxe::decode(executable));
    source.erase(0,source.find('\n')+1);
    std::string input=std::string(rxe::xi::machine_header)+"\nstore8 64 "+std::to_string(paddle%256)+"\nstore8 65 "+std::to_string(paddle/256)+"\nstore8 66 "+std::to_string(command)+"\nstore8 67 "+std::to_string(ticks)+"\n";
    auto runtime=rvpc2::restore(state);
    const auto output=runtime.execute(input+source);
    return {output,rvpc2::save(runtime)};
}
}
