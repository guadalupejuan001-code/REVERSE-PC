// Generic numeric and quantum XI instructions. No agent, target, optimizer,
// reward function or task-specific circuit is implemented here.
inline constexpr std::size_t machine_float_count = 32;
inline unsigned machine_float(const std::string& name) {
  if (name.size() < 2 || name[0] != 'f') throw std::invalid_argument("expected f0..f31");
  const auto n = decimal<unsigned>(name.substr(1), "float register");
  if (n >= machine_float_count) throw std::out_of_range("float register out of range");
  return n;
}
inline double machine_real(const std::string& word, const std::array<double, machine_float_count>& f) {
  if (!word.empty() && word[0] == 'f') return f[machine_float(word)];
  double value = 0.;
#if defined(__GLIBCXX__)
  const auto parsed = std::from_chars(word.data(), word.data()+word.size(), value, std::chars_format::general);
  if (parsed.ec != std::errc{} || parsed.ptr != word.data()+word.size() || !std::isfinite(value))
    throw std::invalid_argument("expected finite binary64 number");
#else
  // Android NDK's older libc++ has no floating-point from_chars overload.
  std::istringstream stream(word); stream.imbue(std::locale::classic()); char trailing;
  if (!(stream >> value) || (stream >> trailing) || !std::isfinite(value))
    throw std::invalid_argument("expected finite binary64 number");
#endif
  return value;
}
inline std::string machine_next_address(std::string address) {
  for (std::size_t k = address.size(); k; --k) {
    if (address[k-1] != '9') { ++address[k-1]; return address; }
    address[k-1] = '0';
  }
  address.insert(address.begin(), '1'); return address;
}
struct MachineQuantumTrace {
  bool enabled = false;
  std::size_t rotations = 0, observations = 0, preparations = 0, gates = 0, max_prepared_block = 0;
  std::set<std::string> rotated, observed;
  std::string report(const InfiniteCore& core) const {
    std::ostringstream o; o << "{\"type\":\"quantum_trace\",\"active_qubits\":" << core.stats().active_qubits
      << ",\"rotations\":" << rotations << ",\"observations\":" << observations
      << ",\"gates\":" << gates << ",\"preparations\":" << preparations
      << ",\"max_prepared_block\":" << max_prepared_block
      << ",\"distinct_rotated_qubits\":" << rotated.size()
      << ",\"distinct_observed_qubits\":" << observed.size() << "}\n";
    return o.str();
  }
};
inline bool machine_numeric(const std::string& op, const std::vector<std::string>& words,
    std::array<std::int64_t, machine_register_count>& r,
    std::array<double, machine_float_count>& f, InfiniteCore& core, InverseMemory* memory,
    ProgramResult& result, MachineQuantumTrace& trace, int& comparison, bool& comparison_valid) {
  auto value = [&](const std::string& t) { return machine_real(t, f); };
  auto emit = [&](const std::string& text) {
    if (text.size() > max_response_bytes - result.output.size()) throw std::length_error("XI output budget");
    result.output += text;
  };
  if (op == "fset" || op == "fmov" || op == "fadd" || op == "fsub" || op == "fmul" ||
      op == "fdiv" || op == "fmin" || op == "fmax") {
    require_count(words, 3); auto& dest = f[machine_float(words[1])]; const double v = value(words[2]);
    double next = v;
    if (op == "fadd") next = dest + v;
    if (op == "fsub") next = dest - v;
    if (op == "fmul") next = dest * v;
    if (op == "fdiv") { if (v == 0.) throw std::domain_error("float division by zero"); next = dest / v; }
    if (op == "fmin") next = std::min(dest, v);
    if (op == "fmax") next = std::max(dest, v);
    if (!std::isfinite(next)) throw std::overflow_error("nonfinite float arithmetic");
    dest = next; return true;
  }
  if (op == "fsin" || op == "fcos" || op == "fexp" || op == "flog" || op == "fsqrt") {
    require_count(words, 3); const double v = value(words[2]);
    const double next = op == "fsin" ? std::sin(v) : op == "fcos" ? std::cos(v) :
        op == "fexp" ? std::exp(v) : op == "flog" ? std::log(v) : std::sqrt(v);
    if (!std::isfinite(next)) throw std::domain_error("nonfinite float function");
    f[machine_float(words[1])] = next; return true;
  }
  if (op == "itof") {
    require_count(words, 3); f[machine_float(words[1])] = static_cast<double>(machine_value(words[2], r)); return true;
  }
  if (op == "ftoi") {
    require_count(words, 3); const auto v = value(words[2]);
    if (v < -9223372036854775808. || v >= 9223372036854775808.) throw std::out_of_range("float to integer overflow");
    r[machine_register(words[1])] = static_cast<std::int64_t>(v); return true;
  }
  if (op == "fcmp") {
    require_count(words, 3); const auto a = value(words[1]), b = value(words[2]);
    comparison = a < b ? -1 : a > b ? 1 : 0; comparison_valid = true; return true;
  }
  if (op == "clock") {
    require_count(words, 2); f[machine_float(words[1])] =
        std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now().time_since_epoch()).count();
    return true;
  }
  if (op == "femit") {
    require_count(words, 3); const auto name = machine_label(words[1]);
    std::ostringstream o; o.imbue(std::locale::classic());
    o << std::setprecision(17) << "{\"type\":\"metric\",\"name\":\"" << name << "\",\"value\":" << value(words[2]) << "}\n";
    emit(o.str()); return true;
  }
  if (op == "fload" || op == "fstore" || op == "load64" || op == "store64") {
    require_count(words, 3); if (!memory) throw std::invalid_argument("InverseMemory required");
    const bool load = op == "fload" || op == "load64", real = op == "fload" || op == "fstore";
    auto address = canonical(core, machine_substitute(words[load ? 2 : 1], r));
    const auto reg = load ? words[1] : words[2]; std::uint64_t bits = 0;
    if (!load) {
      if (real) { const auto v = value(reg); std::memcpy(&bits, &v, 8); }
      else { const auto v = machine_value(reg, r); std::memcpy(&bits, &v, 8); }
    }
    for (unsigned k = 0; k < 8; ++k) {
      if (load) {
        const auto byte = memory->read(address, core);
        if (!byte.deterministic) throw std::runtime_error("numeric load requires deterministic memory");
        bits |= std::uint64_t(byte.value) << (8*k);
      } else memory->store(address, static_cast<std::uint8_t>(bits >> (8*k)), core);
      address = machine_next_address(std::move(address));
      if (address.size() > core.limits().max_address_digits) throw std::length_error("numeric address overflow");
    }
    if (load) {
      if (real) { double v; std::memcpy(&v, &bits, 8); if (!std::isfinite(v)) throw std::domain_error("nonfinite memory float"); f[machine_float(reg)] = v; }
      else { std::int64_t v; std::memcpy(&v, &bits, 8); r[machine_register(reg)] = v; }
    } else result.explicit_mutation = true;
    return true;
  }
  if (op == "rx" || op == "ry" || op == "rz") {
    require_count(words, 3); const auto address = canonical(core, machine_substitute(words[1], r));
    core.rotate(address, op == "rx" ? 'X' : op == "ry" ? 'Y' : 'Z', value(words[2]));
    if (trace.enabled) { ++trace.rotations; trace.rotated.insert(address); }
    result.explicit_mutation = true; return true;
  }
  if (op == "qprepare") {
    require_count(words, 3); const auto width = machine_value(words[2], r);
    if (width <= 0) throw std::out_of_range("positive block width required");
    core.prepare_zero_block(machine_substitute(words[1], r), static_cast<std::size_t>(width));
    if (trace.enabled) { ++trace.preparations; trace.max_prepared_block = std::max(trace.max_prepared_block, static_cast<std::size_t>(width)); }
    result.explicit_mutation = true; return true;
  }
  if (op == "fexpect" || op == "fprobz") {
    if (words.size() < 3) throw std::invalid_argument("observation requires register and observable");
    double answer;
    if (op == "fexpect") {
      auto expanded = words;
      for (std::size_t k = 2; k < words.size(); ++k) expanded[k] = machine_substitute(words[k], r);
      const auto p = parse_observable_words(expanded, 2, core.limits().max_query_terms);
      answer = core.expectation(p.terms, p.sign);
      if (trace.enabled) for (const auto& term : p.terms) trace.observed.insert(term.address);
    } else {
      require_count(words, 3); const auto address = canonical(core, machine_substitute(words[2], r));
      answer = core.probability_one(address); if (trace.enabled) trace.observed.insert(address);
    }
    f[machine_float(words[1])] = answer; if (trace.enabled) ++trace.observations; return true;
  }
  if (op == "qtrace") {
    require_count(words, 2);
    if (words[1] == "reset") { trace = MachineQuantumTrace{}; trace.enabled = true; }
    else if (words[1] == "report") emit(trace.report(core));
    else throw std::invalid_argument("qtrace expects reset or report");
    return true;
  }
  return false;
}
