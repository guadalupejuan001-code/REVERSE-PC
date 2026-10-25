#pragma once
// REVERSE-PC adaptive factorization layer for the pinned Mundo X Reduced backend.
//
// Stores independent entangled blocks as small dense vectors. It does NOT
// expand their tensor product. A cross-block CX/CZ first checks exact
// single-qubit eigenstate identities; otherwise blocks are joined when small.
// Once a join exceeds the configured dense-block limit, the full recorded
// circuit is replayed into the original ReducedExactTRepresentation backend.
// No pruning, measurement, qubit truncation, or change to Mundo X is used.
#include "mundo_x/exact_t_experiment.hpp"

#include <algorithm>
#include <cmath>
#include <complex>
#include <cstddef>
#include <cstdint>
#include <limits>
#include <memory>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace reverse_pc {

using Complex = std::complex<double>;
using Reduced = mundo_x::ReducedExactTRepresentation;
enum class Operation : unsigned char { H, X, Z, S, T, TDag, CX, CZ };
struct Gate {
  Operation operation;
  std::size_t a;
  std::size_t b = 0;
};

class AdaptiveReduced {
 public:
  explicit AdaptiveReduced(std::size_t qubits,
                           std::size_t max_dense_block = 14,
                           std::size_t max_components = 65536)
      : n_(qubits), max_block_(max_dense_block), max_components_(max_components),
        owner_(qubits) {
    if (qubits == 0 || qubits > 1000)
      throw std::invalid_argument("adaptive reduced supports 1..1000 qubits");
    if (max_dense_block == 0 || max_dense_block > 20)
      throw std::invalid_argument("max_dense_block must be within 1..20");
    if (max_components == 0)
      throw std::invalid_argument("max_components must be positive");
    blocks_.reserve(n_);
    for (std::size_t q = 0; q < n_; ++q) {
      Block block;
      block.ids = {q};
      block.psi = {Complex{1., 0.}, Complex{0., 0.}};
      blocks_.push_back(std::move(block));
      owner_[q] = q;
    }
  }

  void apply(Operation op, std::size_t a, std::size_t b = 0) {
    check(a);
    if (op == Operation::CX || op == Operation::CZ) {
      check(b);
      if (a == b) throw std::invalid_argument("two-qubit gate requires distinct wires");
    }
    const Gate gate{op, a, b};
    if (reduced_) {
      apply_reduced(*reduced_, gate);
      ++gates_;
      return;
    }
    if (op != Operation::CX && op != Operation::CZ) {
      // Record first to avoid a partially updated state on allocation failure.
      history_.push_back(gate);
      apply_single(blocks_[owner_[a]], local(owner_[a], a), op);
      ++gates_;
      return;
    }

    const auto first = owner_[a], second = owner_[b];
    if (first == second) {
      history_.push_back(gate);
      apply_pair(blocks_[first], local(first, a), local(first, b), op);
      ++gates_;
      return;
    }

    // Only simplify exact eigenvectors in the represented floating-point
    // state. Numerically near-eigenstates must NOT be silently approximated.
    const int control_z = eigen(blocks_[first], local(first, a), 'Z');
    const int target_axis = eigen(blocks_[second], local(second, b),
                                  op == Operation::CX ? 'X' : 'Z');
    if (control_z != 0) {
      history_.push_back(gate);
      if (control_z == -1) apply_single(blocks_[second], local(second, b),
                                       op == Operation::CX ? Operation::X : Operation::Z);
      ++gates_;
      return;
    }
    if (target_axis != 0) {
      history_.push_back(gate);
      if (target_axis == -1)
        apply_single(blocks_[first], local(first, a), Operation::Z);
      ++gates_;
      return;
    }

    const auto width = blocks_[first].ids.size() + blocks_[second].ids.size();
    if (width > max_block_) {
      // Fallback uses the ORIGINAL canonical Reduced algorithm, with all
      // gates replayed from the same |0...0> initial state.
      auto next = std::make_unique<Reduced>(n_, max_components_);
      for (const auto& old : history_) apply_reduced(*next, old);
      apply_reduced(*next, gate);
      reduced_ = std::move(next);
      history_.clear();
      blocks_.clear();
      owner_.clear();
      ++gates_;
      return;
    }

    // Construct the tensor product before mutating the existing partition.
    Block merged;
    merged.ids = blocks_[first].ids;
    merged.ids.insert(merged.ids.end(), blocks_[second].ids.begin(),
                      blocks_[second].ids.end());
    const auto left = blocks_[first].psi.size();
    const auto right = blocks_[second].psi.size();
    merged.psi.resize(left * right);
    for (std::size_t j = 0; j < right; ++j)
      for (std::size_t i = 0; i < left; ++i)
        merged.psi[i | (j << blocks_[first].ids.size())] =
            blocks_[first].psi[i] * blocks_[second].psi[j];
    apply_pair(merged, local(first, a),
               blocks_[first].ids.size() + local(second, b), op);
    history_.push_back(gate);
    blocks_[first] = std::move(merged);
    blocks_.erase(blocks_.begin() + static_cast<std::ptrdiff_t>(second));
    refresh_owners();
    ++gates_;
  }

  std::size_t qubits() const { return n_; }
  std::size_t gate_count() const { return gates_; }
  bool uses_original_reduced() const { return static_cast<bool>(reduced_); }
  std::size_t block_count() const { return blocks_.size(); }
  std::size_t max_block_width() const {
    std::size_t width = 0;
    for (const auto& block : blocks_) width = std::max(width, block.ids.size());
    return width;
  }
  std::size_t factor_amplitudes() const {
    std::size_t count = 0;
    for (const auto& block : blocks_) count += block.psi.size();
    return count;
  }
  std::size_t component_count() const {
    return reduced_ ? reduced_->component_count() : 0;
  }
  std::size_t estimated_payload_bytes() const {
    if (reduced_) return reduced_->logical_payload_bytes();
    std::size_t bytes = owner_.capacity() * sizeof(std::size_t)
                      + history_.capacity() * sizeof(Gate)
                      + blocks_.capacity() * sizeof(Block);
    for (const auto& block : blocks_)
      bytes += block.ids.capacity() * sizeof(std::size_t)
            + block.psi.capacity() * sizeof(Complex);
    return bytes;
  }
  double expectation(char axis, std::size_t q) const {
    check(q);
    if (reduced_) return reduced_->pauli_expectation(axis, q);
    if (axis != 'Z' && axis != 'X')
      throw std::invalid_argument("factorized expectation supports Z or X");
    const auto idx = owner_[q];
    return expectation_local(blocks_[idx], local(idx, q), axis);
  }
  double norm() const {
    if (reduced_) return reduced_->sparse_norm();
    double result = 1.;
    for (const auto& block : blocks_) {
      double local_norm = 0.;
      for (Complex c : block.psi) local_norm += std::norm(c);
      result *= local_norm;
    }
    return result;
  }
  std::vector<Complex> dense() const {
    if (n_ > 20) throw std::runtime_error("dense oracle limited to 20 qubits");
    if (reduced_) return reduced_->dense_from_reduced();
    std::vector<Complex> out(std::size_t{1} << n_, Complex{1., 0.});
    for (std::size_t bits = 0; bits < out.size(); ++bits) {
      for (const auto& block : blocks_) {
        std::size_t local_bits = 0;
        for (std::size_t p = 0; p < block.ids.size(); ++p)
          if ((bits >> block.ids[p]) & 1u) local_bits |= std::size_t{1} << p;
        out[bits] *= block.psi[local_bits];
      }
    }
    return out;
  }

 private:
  struct Block {
    std::vector<std::size_t> ids;
    std::vector<Complex> psi;
  };

  static constexpr double kEigenTolerance = 0.;
  std::size_t n_, max_block_, max_components_;
  std::size_t gates_ = 0;
  std::vector<Block> blocks_;
  std::vector<std::size_t> owner_;
  std::vector<Gate> history_;
  std::unique_ptr<Reduced> reduced_;

  void check(std::size_t q) const {
    if (q >= n_) throw std::out_of_range("qubit out of bounds");
  }
  std::size_t local(std::size_t group, std::size_t global) const {
    const auto& ids = blocks_[group].ids;
    const auto it = std::find(ids.begin(), ids.end(), global);
    if (it == ids.end()) throw std::logic_error("invalid adaptive owner map");
    return static_cast<std::size_t>(it - ids.begin());
  }
  void refresh_owners() {
    for (std::size_t i = 0; i < blocks_.size(); ++i)
      for (std::size_t q : blocks_[i].ids) owner_[q] = i;
  }
  static void apply_single(Block& block, std::size_t bit, Operation op) {
    const std::size_t mask = std::size_t{1} << bit;
    const double inv = 1. / std::sqrt(2.);
    const Complex t = std::polar(1., 0.785398163397448309616);
    for (std::size_t i = 0; i < block.psi.size(); ++i) {
      if (i & mask) continue;
      Complex& a = block.psi[i];
      Complex& b = block.psi[i | mask];
      switch (op) {
        case Operation::H: {
          const Complex left = a, right = b;
          a = (left + right) * inv;
          b = (left - right) * inv;
          break;
        }
        case Operation::X: std::swap(a, b); break;
        case Operation::Z: b = -b; break;
        case Operation::S: b *= Complex{0., 1.}; break;
        case Operation::T: b *= t; break;
        case Operation::TDag: b *= std::conj(t); break;
        default: throw std::logic_error("two-qubit operation passed as single");
      }
    }
  }
  static void apply_pair(Block& block, std::size_t control,
                         std::size_t target, Operation op) {
    const auto c = std::size_t{1} << control;
    const auto t = std::size_t{1} << target;
    for (std::size_t i = 0; i < block.psi.size(); ++i) {
      if (!(i & c)) continue;
      if (op == Operation::CX) {
        if (!(i & t)) std::swap(block.psi[i], block.psi[i | t]);
      } else if (op == Operation::CZ) {
        if (i & t) block.psi[i] = -block.psi[i];
      } else throw std::logic_error("single operation passed as pair");
    }
  }
  static double expectation_local(const Block& block, std::size_t bit, char axis) {
    const auto mask = std::size_t{1} << bit;
    double total = 0.;
    if (axis == 'Z') {
      for (std::size_t i = 0; i < block.psi.size(); ++i)
        total += (i & mask ? -1. : 1.) * std::norm(block.psi[i]);
    } else {
      for (std::size_t i = 0; i < block.psi.size(); ++i)
        if (!(i & mask))
          total += 2. * std::real(std::conj(block.psi[i]) * block.psi[i | mask]);
    }
    return total;
  }
  // Eigenstate detection by a zero vector residual, not an expectation
  // threshold. Nearby nonzero amplitudes are retained by merging instead.
  static int eigen(const Block& block, std::size_t bit, char axis) {
    const std::size_t mask = std::size_t{1} << bit;
    double norm_sq = 0., plus = 0., minus = 0.;
    if (axis == 'Z') {
      for (std::size_t i = 0; i < block.psi.size(); ++i) {
        const double p = std::norm(block.psi[i]);
        norm_sq += p;
        if (i & mask) plus += p;
        else minus += p;
      }
      if (plus <= kEigenTolerance * kEigenTolerance * norm_sq) return +1;
      if (minus <= kEigenTolerance * kEigenTolerance * norm_sq) return -1;
    } else {
      for (std::size_t i = 0; i < block.psi.size(); ++i) {
        if (i & mask) continue;
        const Complex a = block.psi[i], b = block.psi[i | mask];
        norm_sq += std::norm(a) + std::norm(b);
        plus += std::norm(a - b);
        minus += std::norm(a + b);
      }
      if (plus <= kEigenTolerance * kEigenTolerance * norm_sq) return +1;
      if (minus <= kEigenTolerance * kEigenTolerance * norm_sq) return -1;
    }
    return 0;
  }
  static void apply_reduced(Reduced& q, const Gate& gate) {
    switch (gate.operation) {
      case Operation::H: q.hadamard(gate.a); break;
      case Operation::X: q.pauli_x(gate.a); break;
      case Operation::Z: q.pauli_z(gate.a); break;
      case Operation::S: q.phase_s(gate.a); break;
      case Operation::T: q.phase_t(gate.a); break;
      case Operation::TDag: q.phase_t_dagger(gate.a); break;
      case Operation::CX: q.cnot(gate.a, gate.b); break;
      case Operation::CZ: q.controlled_z(gate.a, gate.b); break;
    }
  }
};

}  // namespace reverse_pc
