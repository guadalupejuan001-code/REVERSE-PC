// Included in InfiniteCore. State preparation and rotations use the same
// candidate/commit boundary, component authority and limits as historical XI.
void prepare_zero_block(const std::string& raw, std::size_t width) {
  if (!width || width > limits_.max_component_qubits)
    throw std::length_error("zero-block width exceeds component budget");
  if (background_ != Background::Zero || state_->ether.rule_count())
    throw std::invalid_argument("zero-block preparation requires a zero, empty Ether frame");
  std::vector<std::string> ids;
  std::map<std::string, bool, infinite_detail::AddressLess> requested;
  auto id = canonical(raw);
  for (std::size_t q = 0; q < width; ++q) {
    ids.push_back(id); requested.emplace(id, true);
    for (std::size_t k = id.size(); k; --k) {
      if (id[k-1] != '9') { ++id[k-1]; break; }
      id[k-1] = '0';
      if (k == 1) id.insert(id.begin(), '1');
    }
    if (id.size() > limits_.max_address_digits) throw std::length_error("address overflow");
  }
  // Never silently reset an entangled partner outside the requested block.
  for (const auto& address : ids) {
    const auto it = state_->locations.find(address);
    if (it == state_->locations.end()) continue;
    for (const auto& partner : state_->components[it->second.component]->ids)
      if (!requested.count(partner))
        throw std::invalid_argument("zero-block preparation splits an existing component");
  }
  require_next_revision();
  auto next = program_candidate_ && state_.unique() ? state_ : std::make_shared<State>(*state_);
  for (const auto& address : ids) {
    auto it = next->locations.find(address);
    if (it == next->locations.end()) continue;
    const auto slot = it->second.component;
    const auto previous_ids = next->components[slot]->ids;
    next->tableau_bytes -= next->components[slot]->core.state_bytes();
    for (const auto& partner : previous_ids) {
      next->address_bytes -= partner.size(); next->locations.erase(partner);
    }
    erase_slot(*next, slot);
  }
  auto component = std::make_shared<Component>(ids,
      reverse_pc::QuantumBlock(CompactCore(width), limits_.max_reduced_components,
                             limits_.max_dense_block, limits_.fast_reduced_clifford));
  const auto bytes = checked_add(next->tableau_bytes, component->core.state_bytes(), "reset payload overflow");
  check_resources(checked_add(next->locations.size(), width, "reset width overflow"), width, bytes);
  const auto slot = next->components.size();
  for (std::size_t q = 0; q < width; ++q) {
    next->locations.emplace(ids[q], Location{slot, q});
    next->address_bytes = checked_add(next->address_bytes, ids[q].size(), "reset addresses overflow");
  }
  next->components.push_back(std::move(component)); next->tableau_bytes = bytes;
  ++next->revision; state_.swap(next);
}

void rotate(const std::string& raw, char axis, double angle) {
  if ((axis != 'X' && axis != 'Y' && axis != 'Z') || !std::isfinite(angle))
    throw std::invalid_argument("rotation requires X/Y/Z and a finite angle");
  const auto id = canonical(raw);
  const auto pulled = pull_pauli(*state_, {{id, axis}});
  if (pulled.terms.empty()) return; // global phase
  require_next_revision();
  auto next = program_candidate_ && state_.unique() ? state_ : std::make_shared<State>(*state_);
  const auto first = pulled.terms.front().address;
  for (const auto& term : pulled.terms) materialize(*next, term.address);
  for (const auto& term : pulled.terms) join(*next, first, term.address);
  const auto slot = next->locations.at(first).component;
  auto p = identity_pauli(next->components[slot]->ids.size());
  for (const auto& term : pulled.terms) set_axis(p, next->locations.at(term.address).qubit, term.axis);
  const auto before = next->components[slot]->core.state_bytes();
  auto& block = mutable_component(*next, slot).core;
  block.rotate_pauli(p, angle * pulled.sign);
  next->tableau_bytes = checked_add(next->tableau_bytes - before, block.state_bytes(), "rotation payload overflow");
  check_resources(next->locations.size(), block.qubits(), next->tableau_bytes);
  ++next->revision; state_.swap(next);
}
