#pragma once
// RXE3 packages an existing XI executable plus local presentation assets.
// XI remains the sole game-state authority. The UI/GPU is a host adapter.
#include "rxe.hpp"
#include "rvpc2.hpp"
#include <charconv>
namespace reverse_pc::rxe_graphics {
using rxe::Bytes;using rxe::require;
inline constexpr unsigned char magic[8]={'R','X','E','3',13,10,26,10};
inline constexpr std::uint64_t mailbox=UINT64_C(7500000000000000000);
inline bool has_magic(const Bytes& b){return b.size()>=8&&std::equal(std::begin(magic),std::end(magic),b.begin());}
inline bool path(const std::string& p){
 if(p.empty()||p.size()>160||p.front()=='/'||p.back()=='/')return false;
 if(!std::all_of(p.begin(),p.end(),[](unsigned char c){return(c>='a'&&c<='z')||(c>='A'&&c<='Z')||(c>='0'&&c<='9')||c=='.'||c=='_'||c=='-'||c=='/';}))return false;
 std::istringstream in(p);std::string part;while(std::getline(in,part,'/'))if(part.empty()||part=="."||part=="..")return false;return true;
}
struct App {std::string id,title,version,source;Bytes code,seed;std::map<std::string,Bytes> assets;};
inline void validate(const App& a){
 require(!a.id.empty()&&a.id.size()<=96&&a.id.front()>='a'&&a.id.front()<='z'&&std::all_of(a.id.begin(),a.id.end(),[](unsigned char c){return(c>='a'&&c<='z')||(c>='0'&&c<='9')||c=='.'||c=='-';}),"Identidad gráfica RXE no válida");
 require(!a.title.empty()&&a.title.size()<=160&&rxe::utf8(a.title),"Nombre gráfico RXE no válido");
 require(!a.version.empty()&&a.version.size()<=64&&rxe::utf8(a.version),"Versión gráfica RXE no válida");
 require(a.source.size()==40&&std::all_of(a.source.begin(),a.source.end(),[](unsigned char c){return(c>='0'&&c<='9')||(c>='a'&&c<='f');}),"Referencia gráfica RXE no válida");
 require(a.assets.size()>0&&a.assets.size()<=64&&a.assets.count("index.html"),"La aplicación requiere index.html y hasta 64 activos locales");
 std::size_t total=80+a.id.size()+a.title.size()+a.version.size()+40+a.code.size()+a.seed.size();
 for(const auto& [name,bytes]:a.assets){require(path(name)&&!bytes.empty()&&bytes.size()<=2*1024*1024,"Activo gráfico RXE no válido");total+=8+name.size()+bytes.size();require(total<=rxe::max_image,"La aplicación gráfica supera 8 MiB");}
 (void)rxe::disassemble(rxe::decode(a.code));require(!a.seed.empty()&&a.seed.size()<=rxe::max_image,"Memoria gráfica RXE no válida");(void)rvpc2::restore(a.seed);
}
inline Bytes pack(const App& a){
 validate(a);Bytes b(magic,magic+8);rxe::put(b,3,2);rxe::put(b,3,2);rxe::put(b,80,4);rxe::put(b,0,4);
 for(auto v:{a.id.size(),a.title.size(),a.version.size(),a.code.size(),a.seed.size()})rxe::put(b,v,4);
 rxe::put(b,0,8);for(auto v:{std::size_t(a.assets.size()),std::size_t(40),std::size_t(1),std::size_t(2)})rxe::put(b,v,4);rxe::put(b,0,8);rxe::put(b,0,8);
 for(const auto* s:{&a.id,&a.title,&a.version,&a.source})b.insert(b.end(),s->begin(),s->end());b.insert(b.end(),a.code.begin(),a.code.end());b.insert(b.end(),a.seed.begin(),a.seed.end());
 for(const auto& [name,data]:a.assets){rxe::put(b,name.size(),2);rxe::put(b,0,2);rxe::put(b,data.size(),4);b.insert(b.end(),name.begin(),name.end());b.insert(b.end(),data.begin(),data.end());}
 rxe::patch(b,16,b.size(),4);rxe::patch(b,40,rxe::checksum(b),8);return b;
}
inline App decode(const Bytes& b){
 require(b.size()>=80&&b.size()<=rxe::max_image&&has_magic(b),"No es una aplicación gráfica RXE3");rxe::Reader in{b,8};
 require(in.get(2)==3&&in.get(2)==3&&in.get(4)==80,"Versión o ABI gráfica no compatible");require(in.get(4)==b.size(),"Longitud gráfica RXE incorrecta");
 const auto ni=in.get(4),nt=in.get(4),nv=in.get(4),nc=in.get(4),ns=in.get(4),hash=in.get(8),count=in.get(4);
 require(hash==rxe::checksum(b),"Integridad gráfica RXE incorrecta");require(in.get(4)==40&&in.get(4)==1&&in.get(4)==2&&in.get(8)==0&&in.get(8)==0,"Perfil gráfico RXE no compatible");
 require(ni>0&&ni<=96&&nt>0&&nt<=160&&nv>0&&nv<=64&&nc>=56&&nc<=rxe::max_image&&ns>=29&&ns<=rxe::max_image&&count>0&&count<=64,"Secciones gráficas RXE no válidas");
 App a;a.id=in.text(ni);a.title=in.text(nt);a.version=in.text(nv);a.source=in.text(40);auto code=in.text(nc),seed=in.text(ns);a.code.assign(code.begin(),code.end());a.seed.assign(seed.begin(),seed.end());
 for(std::uint64_t i=0;i<count;i++){const auto n=in.get(2);require(in.get(2)==0,"Activo con indicadores desconocidos");const auto size=in.get(4);require(n>0&&n<=160&&size>0&&size<=2*1024*1024,"Tamaño de activo no válido");auto name=in.text(n),data=in.text(size);require(a.assets.emplace(name,Bytes(data.begin(),data.end())).second,"Activo gráfico RXE duplicado");}
 require(in.pos==b.size(),"Datos sobrantes en aplicación gráfica RXE");validate(a);return a;
}
inline std::string describe(const Bytes& b){const auto a=decode(b);return "{\"format\":\"RXE\",\"version\":3,\"abi\":\"XI-graphics-v1\",\"ui\":\"graphics\",\"app_id\":"+rxe::quote(a.id)+",\"title\":"+rxe::quote(a.title)+",\"app_version\":"+rxe::quote(a.version)+",\"source_sha\":"+rxe::quote(a.source)+",\"instructions\":"+std::to_string(rxe::decode(a.code).code.size())+",\"assets\":"+std::to_string(a.assets.size())+",\"seed_bytes\":"+std::to_string(a.seed.size())+",\"bytes\":"+std::to_string(b.size())+"}";}
inline std::string state_json(const std::string& rows){
 std::map<unsigned,std::uint64_t> values;std::istringstream input(rows);std::string line;
 while(std::getline(input,line)){const auto at=line.find("\"register\":\"r");if(at==std::string::npos)continue;unsigned reg=99;auto parsed=std::from_chars(line.data()+at+13,line.data()+line.size(),reg);require(parsed.ec==std::errc{}&&reg<5,"Registro gráfico de salida no válido");const auto key=line.find("\"value\":");require(key!=std::string::npos,"Salida gráfica incompleta");std::uint64_t value=0;parsed=std::from_chars(line.data()+key+8,line.data()+line.size(),value);require(parsed.ec==std::errc{}&&parsed.ptr<line.data()+line.size()&&*parsed.ptr=='}'&&value<=UINT32_MAX,"Valor gráfico fuera de rango");require(values.emplace(reg,value).second,"Registro gráfico duplicado");}
 require(values.size()==5,"El programa gráfico no produjo su estado completo");return "{\"score\":"+std::to_string(values.at(0))+",\"combo\":"+std::to_string(values.at(1))+",\"hits\":"+std::to_string(values.at(2))+",\"misses\":"+std::to_string(values.at(3))+",\"maxCombo\":"+std::to_string(values.at(4))+"}";
}
struct Turn {std::string text;Bytes state;};
inline Turn turn(const Bytes& image,const Bytes& previous,unsigned kind,unsigned quality){
 require(kind<=3&&quality<=150&&(kind==1||quality==0),"Evento gráfico no válido");const auto a=decode(image);auto source=rxe::disassemble(rxe::decode(a.code));source.erase(0,source.find('\n')+1);
 const std::string prefix=std::string(rxe::xi::machine_header)+"\nstore8 "+std::to_string(mailbox)+" "+std::to_string(kind)+"\nstore8 "+std::to_string(mailbox+1)+" "+std::to_string(quality)+"\n";
 auto runtime=rvpc2::restore(previous.empty()?a.seed:previous);const auto json=state_json(runtime.execute(prefix+source));return {json,rvpc2::save(runtime)};
}
}
