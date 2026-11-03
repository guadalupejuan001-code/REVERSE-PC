#include <iostream>
#include <random>
#include "integration/mps_state.hpp"
using M=reverse_pc::MpsState;using C=M::C;
static std::size_t checks=0;static double error=0;
void close(C a,C b,double tolerance=2e-11){
  ++checks;error=std::max(error,std::abs(a-b));
  if(std::abs(a-b)>tolerance)throw std::runtime_error("independent dense/MPS mismatch");
}
void local(std::vector<C>& v,unsigned q,const M::Matrix& u){
  for(std::size_t i=0;i<v.size();++i)if(!(i&(1u<<q))){
    auto j=i|(1u<<q);const auto a=v[i],b=v[j];v[i]=u[0]*a+u[1]*b;v[j]=u[2]*a+u[3]*b;
  }
}
void cx(std::vector<C>& v,unsigned a,unsigned b){
  for(std::size_t i=0;i<v.size();++i)if((i&(1u<<a))&&!(i&(1u<<b)))std::swap(v[i],v[i|(1u<<b)]);
}
C expect(const std::vector<C>& v,std::uint64_t x,std::uint64_t z,unsigned phase){
  const C p[4]={1.,C(0,1),-1.,C(0,-1)};C out{};
  for(std::size_t i=0;i<v.size();++i)out+=std::conj(v[i^x])*v[i]*p[phase&3]*(__builtin_parityll(i&z)?-1.:1.);
  return out;
}
double purity(const std::vector<C>& v,unsigned cut){
  const auto d=std::size_t(1)<<cut,r=v.size()/d;C result{};
  for(std::size_t a=0;a<d;++a)for(std::size_t b=0;b<d;++b){
    C m{};for(std::size_t k=0;k<r;++k)m+=v[a+k*d]*std::conj(v[b+k*d]);result+=m*std::conj(m);
  }
  return result.real();
}
int main(){try{
  std::mt19937 rng(7821);std::uniform_real_distribution<double> angle(-1.3,1.3);
  for(unsigned n=2;n<=9;++n){
    M m(n);std::vector<C> v(std::size_t(1)<<n);v[0]=1.;
    for(unsigned sweep=0;sweep<2;++sweep){
      for(unsigned q=0;q<n;++q){const auto a=angle(rng);const auto c=std::cos(a/2),s=std::sin(a/2);
        m.rotate(q,'Y',a);local(v,q,{c,-s,s,c});
        const auto b=angle(rng);m.rotate(q,'Z',b);local(v,q,{std::polar(1.,-b/2),0.,0.,std::polar(1.,b/2)});
        const auto x=angle(rng),cx=std::cos(x/2),sx=std::sin(x/2);
        m.rotate(q,'X',x);local(v,q,{cx,C(0,-sx),C(0,-sx),cx});
      }
      for(unsigned q=0;q+1<n;++q){if(sweep){m.cnot(q+1,q);cx(v,q+1,q);}else{m.cnot(q,q+1);cx(v,q,q+1);}}
    }
    for(unsigned q=0;q+1<n;++q){m.cz(q,q+1);for(std::size_t i=0;i<v.size();++i)if((i&(1u<<q))&&(i&(1u<<(q+1))))v[i]=-v[i];}
    const auto a=m.dense();for(std::size_t i=0;i<a.size();++i)close(a[i],v[i]);
    for(unsigned test=0;test<80;++test){
      const auto x=rng()%v.size(),z=rng()%v.size();const unsigned phase=__builtin_popcountll(x&z);
      close(m.expectation({x},{z},phase),expect(v,x,z,phase));
    }
    for(unsigned q=1;q<n;++q)close(m.purity(q),purity(v,q));
    auto restored=M::from_snapshot(m.snapshot());
    const auto b=restored.dense();for(std::size_t i=0;i<b.size();++i)close(b[i],v[i]);
    const double p=m.probability_z(n-1,true);double expected=0;
    for(std::size_t i=0;i<v.size();++i)if(i&(std::size_t(1)<<(n-1)))expected+=std::norm(v[i]);
    close(p,expected);m.project_z(n-1,true);
    const auto collapsed=m.dense();for(std::size_t i=0;i<v.size();++i)close(collapsed[i],i&(std::size_t(1)<<(n-1))?v[i]/std::sqrt(expected):C{});
  }
  M small(3);small.rotate(0,'Y',.8);small.cnot(0,2);close(small.expectation({0},{5},0),1.);
  M tiny(2);tiny.rotate(0,'Y',1e-10);close(tiny.probability_z(0,true),2.5e-21,1e-34);
  M limited(2,2);limited.rotate(0,'Y',.2);limited.cnot(0,1);auto before=limited.snapshot();
  bool rejected=false;try{limited.cnot(0,1);}catch(const std::length_error&){rejected=true;}
  if(!rejected||limited.snapshot()!=before)throw std::runtime_error("MPS resource failure changed state");
  M wide(1000);for(unsigned q=0;q<1000;++q)wide.rotate(q,'Y',.31+.0001*q);
  for(unsigned q=0;q<999;++q)wide.cnot(q,q+1);
  std::size_t nonproduct=0;for(unsigned q=1;q<1000;++q)if(wide.purity(q)<1-1e-10)++nonproduct;
  if(nonproduct!=999||wide.max_bond()!=2)throw std::runtime_error("not one entangled 1000-wire chain");
  auto saved=wide.snapshot();auto again=M::from_snapshot(saved);close(again.norm(),1.);
  std::cout<<"{\"checks\":"<<checks<<",\"max_absolute_error\":"<<error<<",\"register_qubits\":1000,\"entangled_cuts\":"<<nonproduct<<",\"bond_dimension\":"<<wide.max_bond()<<",\"state_payload_bytes\":"<<wide.state_bytes()<<"}\n";
}catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}}
