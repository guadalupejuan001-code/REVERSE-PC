#pragma once
#include <algorithm>
#include <array>
#include <complex>
#include <vector>
#include "integration/state_io.hpp"

namespace reverse_pc {
// One connected pure-state authority, with no SVD truncation, coefficient
// pruning, fixed qubit groups, or external simulator. Exact MPO application
// grows virtual bonds; exceeding a resource budget fails instead of changing
// the requested circuit. Binary64 roundoff is the only numerical approximation.
class MpsState {
 public:
  using C = std::complex<double>;
  using Matrix = std::array<C,4>;
  struct Tensor {
    std::size_t left=1, right=1;
    std::vector<C> a = {C(1),C(0)};
    C& at(std::size_t l,unsigned s,std::size_t r) { return a[(l*2+s)*right+r]; }
    C at(std::size_t l,unsigned s,std::size_t r) const { return a[(l*2+s)*right+r]; }
  };
  explicit MpsState(std::size_t n=1,std::size_t bond_budget=64)
      : sites_(n), bond_budget_(bond_budget) {
    if(!n || n>4096 || !bond_budget || bond_budget>65536)
      throw std::length_error("MPS register/resource budget");
  }
  std::size_t qubits() const { return sites_.size(); }
  std::size_t max_bond() const {
    std::size_t n=1;for(const auto& t:sites_)n=std::max(n,t.right);return n;
  }
  std::size_t amplitudes() const { std::size_t n=0;for(const auto& t:sites_)n+=t.a.size();return n; }
  std::size_t state_bytes() const { return 16*amplitudes(); }
  void local(std::size_t q,const Matrix& u) {
    auto& t=sites_.at(q);
    for(std::size_t l=0;l<t.left;++l)for(std::size_t r=0;r<t.right;++r){
      const C a=t.at(l,0,r),b=t.at(l,1,r);
      t.at(l,0,r)=u[0]*a+u[1]*b;t.at(l,1,r)=u[2]*a+u[3]*b;
    }
    valid_=false;
  }
  void rotate(std::size_t q,char axis,double angle) {
    const double c=std::cos(angle/2),s=std::sin(angle/2);
    if(axis=='Y')local(q,{c,-s,s,c});
    else if(axis=='X')local(q,{c,C(0,-s),C(0,-s),c});
    else if(axis=='Z')local(q,{C(c,-s),0.,0.,C(c,s)});
    else throw std::invalid_argument("MPS rotation axis");
  }
  void cnot(std::size_t control,std::size_t target) { pair(control,target,false); }
  void cz(std::size_t a,std::size_t b) { pair(a,b,true); }
  double norm() const { cache();return norm_; }
  double probability_z(std::size_t q,bool one) const {
    cache();const Matrix projector=one?Matrix{0.,0.,0.,1.}:Matrix{1.,0.,0.,0.};
    const auto v=transfer(sites_.at(q),left_[q],projector,false);C sum{};
    for(std::size_t k=0;k<v.size();++k)sum+=v[k]*right_[q+1][k];
    const auto p=sum.real()/norm_;
    if(!std::isfinite(p)||p < -1e-12||p>1+1e-12)throw std::runtime_error("MPS Born normalization");
    return std::clamp(p,0.,1.);
  }
  double expectation(const std::vector<std::uint64_t>& x,
                     const std::vector<std::uint64_t>& z,unsigned phase) const {
    cache();std::size_t count=0,one=0;unsigned ys=0;
    for(std::size_t q=0;q<qubits();++q){
      const bool a=(x.at(q/64)>>(q%64))&1,b=(z.at(q/64)>>(q%64))&1;
      if(a||b){++count;one=q;}if(a&&b)++ys;
    }
    if(!count)return unit(phase).real();
    if(count==1){
      const bool a=(x[one/64]>>(one%64))&1,b=(z[one/64]>>(one%64))&1;
      return bounded((unit(phase-ys)*single_[one][a?(b?1:0):2]).real());
    }
    std::vector<C> env(1,C(1));
    for(std::size_t q=0;q<qubits();++q){
      const bool a=(x[q/64]>>(q%64))&1,b=(z[q/64]>>(q%64))&1;
      env=transfer(sites_[q],env,pauli(a,b),false);
    }
    return bounded((unit(phase)*env[0]/norm_).real());
  }
  double purity(std::size_t cut) const {
    if(!cut||cut>=qubits())throw std::out_of_range("MPS cut");
    cache();const auto d=sites_[cut-1].right;
    const auto& l=left_[cut];const auto& r=right_[cut];
    std::vector<C> m(d*d);
    for(std::size_t a=0;a<d;++a)for(std::size_t b=0;b<d;++b)
      for(std::size_t k=0;k<d;++k)m[a*d+b]+=l[a*d+k]*r[b*d+k];
    C p{};for(std::size_t a=0;a<d;++a)for(std::size_t b=0;b<d;++b)p+=m[a*d+b]*m[b*d+a];
    return p.real()/(norm_*norm_);
  }
  void project_z(std::size_t q,bool one) {
    const double p=probability_z(q,one);
    if(!(p>0))throw std::invalid_argument("impossible MPS measurement");
    const auto scale=1/std::sqrt(norm()*p);
    local(q,one?Matrix{0.,0.,0.,scale}:Matrix{scale,0.,0.,0.});
  }
  // Used only for bounded independent test oracles / joining small old states.
  static MpsState from_dense(const std::vector<C>& v,std::size_t n,std::size_t budget) {
    if(n>=20||v.size()!=(std::size_t(1)<<n))throw std::length_error("dense-to-MPS budget");
    MpsState out(n,budget);std::size_t d=1;
    for(std::size_t q=0;q<n;++q){
      auto& t=out.sites_[q];t.left=d;t.right=q+1==n?1:2*d;
      if(t.right>budget)throw std::length_error("MPS bond resource budget");
      t.a.assign(2*t.left*t.right,{});
      for(std::size_t l=0;l<d;++l)for(unsigned s=0;s<2;++s){
        auto k=l+(std::size_t(s)<<q);
        t.at(l,s,q+1==n?0:k)=q+1==n?v[k]:C(1);
      }
      d=t.right;
    }
    return out;
  }
  std::vector<C> dense() const {
    if(qubits()>18)throw std::length_error("MPS dense export resource budget");
    std::vector<C> out(std::size_t(1)<<qubits());
    for(std::size_t bits=0;bits<out.size();++bits){
      std::vector<C> v(1,C(1));
      for(std::size_t q=0;q<qubits();++q){
        const auto& t=sites_[q];std::vector<C> next(t.right);
        for(std::size_t l=0;l<t.left;++l)for(std::size_t r=0;r<t.right;++r)
          next[r]+=v[l]*t.at(l,(bits>>q)&1,r);
        v=std::move(next);
      }
      out[bits]=v[0];
    }
    return out;
  }
  static MpsState tensor_product(const MpsState& a,const MpsState& b){
    MpsState out=a;out.sites_.insert(out.sites_.end(),b.sites_.begin(),b.sites_.end());
    out.bond_budget_=std::min(a.bond_budget_,b.bond_budget_);out.valid_=false;
    if(out.qubits()>4096)throw std::length_error("MPS register budget");
    return out;
  }
  std::string snapshot() const {
    state_io::Writer w;w.data="MPS1";w.u64(qubits());w.u64(bond_budget_);
    for(const auto& t:sites_){w.u64(t.left);w.u64(t.right);for(auto a:t.a)w.complex(a);}
    return w.finish();
  }
  static MpsState from_snapshot(const std::string& data,std::size_t maximum_bond=64){
    state_io::Reader r(data);r.require(4);if(data.substr(0,4)!="MPS1")throw std::invalid_argument("MPS version");
    r.at=4;const auto n=r.u64(),budget=r.u64();
    if(budget>maximum_bond)throw std::length_error("restored MPS bond budget");
    MpsState out(n,budget);std::size_t previous=1;
    for(auto& t:out.sites_){
      t.left=r.u64();t.right=r.u64();
      if(t.left!=previous||!t.right||t.right>budget)throw std::invalid_argument("MPS bond dimensions");
      const auto count=2*t.left*t.right;r.require(16*count);t.a.resize(count);
      for(auto& a:t.a)a=r.complex();
      previous=t.right;
    }
    if(previous!=1)throw std::invalid_argument("MPS open boundary");
    r.done();
    const auto norm=out.norm();if(!(norm>0)||std::abs(norm-1)>1e-8)throw std::invalid_argument("MPS normalization");
    return out;
  }
 private:
  std::vector<Tensor> sites_;
  std::size_t bond_budget_;
  mutable bool valid_=false;
  mutable double norm_=1;
  mutable std::vector<std::vector<C>> left_,right_;
  mutable std::vector<std::array<C,3>> single_;
  static Matrix identity(){return {1.,0.,0.,1.};}
  static C unit(unsigned p){switch(p&3){case 0:return 1.;case 1:return C(0,1);case 2:return -1.;default:return C(0,-1);}}
  static Matrix pauli(bool x,bool z){if(x)return z?Matrix{0.,-1.,1.,0.}:Matrix{0.,1.,1.,0.};return z?Matrix{1.,0.,0.,-1.}:identity();}
  static double bounded(double v){if(!std::isfinite(v)||std::abs(v)>1+1e-9)throw std::runtime_error("MPS expectation normalization");return std::clamp(v,-1.,1.);}
  static std::vector<C> transfer(const Tensor& t,const std::vector<C>& env,const Matrix& op,bool reverse){
    const auto d=reverse?t.right:t.left,o=reverse?t.left:t.right;
    std::vector<C> out(o*o);
    for(std::size_t a=0;a<o;++a)for(std::size_t b=0;b<o;++b)
      for(std::size_t l=0;l<d;++l)for(std::size_t k=0;k<d;++k)
        for(unsigned s=0;s<2;++s)for(unsigned v=0;v<2;++v){
          if(op[2*s+v]==C{})continue;
          const auto bra=reverse?t.at(a,s,l):t.at(l,s,a);
          const auto ket=reverse?t.at(b,v,k):t.at(k,v,b);
          out[a*o+b]+=std::conj(bra)*env[l*d+k]*op[2*s+v]*ket;
        }
    return out;
  }
  void cache() const {
    if(valid_)return;
    const auto n=qubits();
    left_.assign(n+1,{});right_.assign(n+1,{});single_.resize(n);
    left_[0]={C(1)};right_[n]={C(1)};
    for(std::size_t q=0;q<n;++q)left_[q+1]=transfer(sites_[q],left_[q],identity(),false);
    norm_=left_[n][0].real();if(!(norm_>0)||!std::isfinite(norm_))throw std::runtime_error("MPS norm underflow");
    for(std::size_t q=n;q--;)right_[q]=transfer(sites_[q],right_[q+1],identity(),true);
    const Matrix ops[3]={{0.,1.,1.,0.},{0.,C(0,-1),C(0,1),0.},{1.,0.,0.,-1.}};
    for(std::size_t q=0;q<n;++q)for(unsigned axis=0;axis<3;++axis){
      const auto v=transfer(sites_[q],left_[q],ops[axis],false);C sum{};
      for(std::size_t k=0;k<v.size();++k)sum+=v[k]*right_[q+1][k];
      single_[q][axis]=sum/norm_;
    }
    valid_=true;
  }
  void adjacent(std::size_t q,const std::array<Matrix,2>& a,const std::array<Matrix,2>& b){
    const auto& l=sites_.at(q);const auto& r=sites_.at(q+1);
    if(l.right!=r.left||l.right>bond_budget_/2)throw std::length_error("MPS bond resource budget; no truncation performed");
    Tensor nl,nr;nl.left=l.left;nl.right=l.right*2;nr.left=r.left*2;nr.right=r.right;
    if(16*(2*nl.left*nl.right+2*nr.left*nr.right)>64*1024*1024)throw std::length_error("MPS tensor byte budget");
    nl.a.assign(2*nl.left*nl.right,{});nr.a.assign(2*nr.left*nr.right,{});
    for(unsigned k=0;k<2;++k){
      for(std::size_t i=0;i<l.left;++i)for(std::size_t j=0;j<l.right;++j)
        for(unsigned s=0;s<2;++s)for(unsigned t=0;t<2;++t)nl.at(i,s,j*2+k)+=a[k][s*2+t]*l.at(i,t,j);
      for(std::size_t i=0;i<r.left;++i)for(std::size_t j=0;j<r.right;++j)
        for(unsigned s=0;s<2;++s)for(unsigned t=0;t<2;++t)nr.at(i*2+k,s,j)+=b[k][s*2+t]*r.at(i,t,j);
    }
    sites_[q]=std::move(nl);sites_[q+1]=std::move(nr);valid_=false;
  }
  void swap_adjacent(std::size_t q){adjacent_pair(q,q+1,false);adjacent_pair(q+1,q,false);adjacent_pair(q,q+1,false);}
  void adjacent_pair(std::size_t a,std::size_t b,bool z){
    const Matrix p0={1.,0.,0.,0.},p1={0.,0.,0.,1.};
    const auto target=z?Matrix{1.,0.,0.,-1.}:Matrix{0.,1.,1.,0.};
    if(a<b)adjacent(a,{p0,p1},{identity(),target});
    else adjacent(b,{identity(),target},{p0,p1});
  }
  void pair(std::size_t a,std::size_t b,bool z){
    if(a>=qubits()||b>=qubits()||a==b)throw std::out_of_range("MPS pair qubits");
    if(a+1==b||b+1==a){adjacent_pair(a,b,z);return;}
    // Route non-neighbours exactly. Work on a candidate to retain the strong
    // guarantee if intermediate swap bonds exhaust the configured budget.
    MpsState next=*this;const auto lo=std::min(a,b),hi=std::max(a,b);
    for(std::size_t q=hi-1;q>lo;--q)next.swap_adjacent(q);
    next.adjacent_pair(a<b?lo:lo+1,a<b?lo+1:lo,z);
    for(std::size_t q=lo+1;q<hi;++q)next.swap_adjacent(q);
    *this=std::move(next);
  }
};
} // namespace reverse_pc
