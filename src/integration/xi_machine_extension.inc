// REVERSE-PC machine profile: interpreted by the original XI candidate owner.
// Included inside mundo_x::infinite_program_detail, after execute_line().
// The explicit shebang opt-in keeps legacy XI semantics byte-identical.
#include "integration/xi_mesh_raster.inc"
inline constexpr const char machine_header[] = "#!reverse-pc-machine-v1";
inline constexpr std::size_t machine_max_steps = 1000000;
inline constexpr std::size_t machine_register_count = 16;

struct MachineInstruction {
  std::vector<std::string> words;
  std::size_t line = 0;
};

// One immutable, exact-source parse per worker thread. No register, local,
// mesh, quantum state or InverseMemory object is retained by this cache.
inline constexpr std::size_t machine_parse_cache_max_source_bytes=512U*1024U;
struct MachineParsedProgram {
  std::string source;
  std::vector<MachineInstruction> code;
  std::map<std::string,std::size_t> labels;
};
struct MachineParseCacheState {
  std::shared_ptr<const MachineParsedProgram> program;
  std::uint64_t hits=0,misses=0;
};
inline MachineParseCacheState& machine_parse_cache_state() {
  static thread_local MachineParseCacheState cache;
  return cache;
}

inline unsigned machine_register(const std::string& name) {
  if (name.size() < 2 || (name.front() != 'r' && name.front() != 'R'))
    throw std::invalid_argument("expected register r0..r15");
  const auto value = decimal<unsigned>(name.substr(1), "register");
  if (value >= machine_register_count)
    throw std::out_of_range("register out of range (r0..r15)");
  return value;
}

inline std::int64_t machine_integer(const std::string& word) {
  if (word.empty()) throw std::invalid_argument("empty integer");
  const bool negative = word.front() == '-';
  const std::size_t start = (negative || word.front() == '+') ? 1 : 0;
  if (start == word.size()) throw std::invalid_argument("integer needs decimal digits");
  const auto max_positive = static_cast<std::uint64_t>(std::numeric_limits<std::int64_t>::max());
  const auto limit = negative ? max_positive + 1U : max_positive;
  std::uint64_t value = 0;
  for (std::size_t i = start; i < word.size(); ++i) {
    const char ch = word[i];
    if (ch < '0' || ch > '9') throw std::invalid_argument("integer needs decimal digits");
    const auto digit = static_cast<unsigned>(ch - '0');
    if (value > (limit - digit) / 10U)
      throw std::out_of_range("signed 64-bit integer overflow");
    value = value * 10U + digit;
  }
  if (negative && value == max_positive + 1U)
    return std::numeric_limits<std::int64_t>::min();
  const auto signed_value = static_cast<std::int64_t>(value);
  return negative ? -signed_value : signed_value;
}

inline std::int64_t machine_value(const std::string& token,
                                 const std::array<std::int64_t, machine_register_count>& registers) {
  if (!token.empty() && (token.front() == 'r' || token.front() == 'R'))
    return registers[machine_register(token)];
  return machine_integer(token);
}

inline std::int64_t machine_arithmetic(const std::string& op, std::int64_t a,
                                       std::int64_t b) {
  using I = std::int64_t;
  const auto low = std::numeric_limits<I>::min();
  const auto high = std::numeric_limits<I>::max();
  if (op == "add") {
    if ((b > 0 && a > high - b) || (b < 0 && a < low - b))
      throw std::overflow_error("signed addition overflow");
    return a + b;
  }
  if (op == "sub") {
    if ((b < 0 && a > high + b) || (b > 0 && a < low + b))
      throw std::overflow_error("signed subtraction overflow");
    return a - b;
  }
  if (op == "mul") {
    if ((a == low && b == -1) || (b == low && a == -1))
      throw std::overflow_error("signed multiplication overflow");
    if (a > 0) {
      if ((b > 0 && a > high / b) || (b < 0 && b < low / a))
        throw std::overflow_error("signed multiplication overflow");
    } else if (a < 0) {
      if ((b > 0 && a < low / b) || (b < 0 && a < high / b))
        throw std::overflow_error("signed multiplication overflow");
    }
    return a * b;
  }
  if (b == 0) throw std::domain_error("division or remainder by zero");
  if (a == low && b == -1) throw std::overflow_error("signed division overflow");
  if (op == "div") return a / b;
  if (op == "mod") return a % b;
  throw std::invalid_argument("unsupported arithmetic opcode");
}

inline std::string machine_label(const std::string& token) {
  if (token.empty() ||
      !((token.front() >= 'a' && token.front() <= 'z') ||
        (token.front() >= 'A' && token.front() <= 'Z') || token.front() == '_'))
    throw std::invalid_argument("label must start with an ASCII letter or underscore");
  for (const char c : token)
    if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
          (c >= '0' && c <= '9') || c == '_'))
      throw std::invalid_argument("invalid label character");
  return lower_ascii(token);
}

inline bool machine_is_jump(const std::string& name) {
  return name == "jmp" || name == "je" || name == "jne" ||
         name == "jlt" || name == "jle" || name == "jgt" || name == "jge";
}

inline std::string machine_substitute(const std::string& token,
                          const std::array<std::int64_t, machine_register_count>& registers) {
  if (token.size() > 1 && token[0] == '$')
    return std::to_string(registers[machine_register(token.substr(1))]);
  if (token.size() > 3 && token[1] == ':' && token[2] == '$' &&
      (token[0] == 'I' || token[0] == 'X' || token[0] == 'Y' || token[0] == 'Z'))
    return token.substr(0, 2) +
           std::to_string(registers[machine_register(token.substr(3))]);
  return token;
}

// CPU instructions operate on 16 ephemeral signed registers. InverseMemory
// retains durable bytes. Quantum gates retain the sole InfiniteCore authority.
inline ProgramResult run_machine(InfiniteCore& core, InverseMemory* memory,
                                 const std::string& program,
                                 bool require_matching_background = false,
                                 std::size_t max_steps = machine_max_steps) {
  if (program.size() > max_program_bytes)
    throw std::length_error("program exceeds 16 MiB transport budget");
  if (!max_steps) throw std::invalid_argument("machine step budget must be positive");
  auto& parse_cache=machine_parse_cache_state();
  const bool cacheable=program.size()<=machine_parse_cache_max_source_bytes;
  std::shared_ptr<const MachineParsedProgram> parsed;
  if(cacheable&&parse_cache.program&&parse_cache.program->source==program) {
    ++parse_cache.hits;parsed=parse_cache.program;
  }else{
    ++parse_cache.misses;
    auto candidate=std::make_shared<MachineParsedProgram>();
    auto& code=candidate->code;
    auto& labels=candidate->labels;
    std::size_t cursor = 0, source_line = 0;
    while (cursor < program.size()) {
      ++source_line;
      const auto newline = program.find('\n', cursor);
      const auto end = newline == std::string::npos ? program.size() : newline;
      if (end - cursor > max_line_bytes)
        throw std::length_error("line " + std::to_string(source_line) + ": over 1 MiB");
      auto words = tokens(program.substr(cursor, end - cursor));
      cursor = newline == std::string::npos ? program.size() : newline + 1;
      if (words.empty()) continue;
      if (code.size() >= max_commands)
        throw std::length_error("program exceeds 131072 commands");
      const auto cmd = lower_ascii(words.front());
      if (cmd == "label") {
        require_count(words, 2);
        const auto name = machine_label(words[1]);
        if (!labels.emplace(name, code.size()).second)
          throw std::invalid_argument("line " + std::to_string(source_line) + ": duplicate label " + name);
      }
      code.push_back({std::move(words), source_line});
    }
    for (const auto& inst : code) {
      const auto op = lower_ascii(inst.words.front());
      if (machine_is_jump(op)) {
        require_count(inst.words, 2);
        if (!labels.count(machine_label(inst.words[1])))
          throw std::invalid_argument("line " + std::to_string(inst.line) + ": unknown jump label");
      }
    }
    // Only fully parsed and jump-validated candidates can replace the entry.
    // Large programs execute normally without retaining another source copy.
    if(cacheable) { candidate->source=program;parse_cache.program=candidate; }
    parsed=std::move(candidate);
  }
  const auto& code=parsed->code;
  const auto& labels=parsed->labels;

  std::array<std::int64_t, machine_register_count> registers{};
  // Zeroed CPU scratch belongs to this execution only. It never becomes an
  // InverseMemory override, a quantum binding or part of a saved snapshot.
  std::array<std::int64_t,4096> locals{};
  ProgramResult result;
  bool first_command = true, in_batch = false, comparison_valid = false;
  int comparison = 0;
  std::size_t pc = 0, steps = 0, address_bytes = 0;
  std::vector<InfiniteCore::Gate> batch;
  // XFS1 binary output is buffered locally until frameend. A failed program
  // cannot publish a partial frame. XI remains the sole source of spans.
  std::string frame;
  bool frame_active = false;
  std::uint32_t frame_revision = 0;
  std::uint16_t frame_width = 0, frame_height = 0;
  MachineMeshRaster mesh;
  bool mesh_active = false;
  auto append16 = [&](std::uint16_t n) {
    frame.push_back(static_cast<char>(n & 255));
    frame.push_back(static_cast<char>((n >> 8) & 255));
  };
  auto append32 = [&](std::uint32_t n) {
    for (unsigned shift = 0; shift < 32; shift += 8)
      frame.push_back(static_cast<char>((n >> shift) & 255));
  };
  while (pc < code.size()) {
    const auto& inst = code[pc];
    try {
      if (++steps > max_steps)
        throw std::length_error("XI machine instruction-step budget exceeded");
      const auto& words = inst.words;
      const auto op = lower_ascii(words.front());
      auto output_line = [&](const std::string& output) {
        if (mesh_active) throw std::invalid_argument("text output inside XI mesh");
        if (output.size() > max_response_bytes - result.output.size())
          throw std::length_error("machine output exceeds 16 MiB");
        result.output += output;
      };
      if (op == "background") {
        require_count(words, 2);
        if (!first_command || in_batch)
          throw std::invalid_argument("background must be the first command");
        const auto background = parse_background(words[1]);
        if (require_matching_background && background != core.background())
          throw std::invalid_argument("program background conflicts with --background");
        core = InfiniteCore(background, core.limits());
        result.explicit_mutation = true;
      } else if (op == "begin") {
        require_count(words, 1);
        if (in_batch) throw std::invalid_argument("nested batches are not supported");
        in_batch = true; batch.clear(); address_bytes = 0;
      } else if (op == "end") {
        require_count(words, 1);
        if (!in_batch) throw std::invalid_argument("end has no matching begin");
        core.apply(batch); batch.clear(); in_batch = false;
      } else if (in_batch) {
        if (!is_gate(op)) throw std::invalid_argument("a batch accepts gates only");
        if (batch.size() == max_batch_gates)
          throw std::length_error("batch exceeds 65536 gates");
        auto expanded = words;
        for (std::size_t i = 1; i < expanded.size(); ++i)
          expanded[i] = machine_substitute(expanded[i], registers);
        auto gate = parse_gate(expanded);
        gate.first = canonical(core, gate.first);
        if (!gate.second.empty()) gate.second = canonical(core, gate.second);
        const auto bytes = gate.first.size() + gate.second.size();
        if (bytes > max_batch_address_bytes - address_bytes)
          throw std::length_error("batch address text exceeds 16 MiB");
        batch.push_back(std::move(gate)); address_bytes += bytes;
      } else if (op == "label") {
        require_count(words, 2);
      } else if (op == "set" || op == "mov") {
        require_count(words, 3);
        registers[machine_register(words[1])] = machine_value(words[2], registers);
      } else if (op == "add" || op == "sub" || op == "mul" ||
                 op == "div" || op == "mod") {
        require_count(words, 3);
        const auto index = machine_register(words[1]);
        const auto new_value = machine_arithmetic(op, registers[index],
                                                  machine_value(words[2], registers));
        registers[index] = new_value;
      } else if (op == "cmp") {
        require_count(words, 3);
        const auto a = machine_value(words[1], registers);
        const auto b = machine_value(words[2], registers);
        comparison = a < b ? -1 : (a > b ? 1 : 0);
        comparison_valid = true;
      } else if (machine_is_jump(op)) {
        require_count(words, 2);
        if (op != "jmp" && !comparison_valid)
          throw std::invalid_argument("conditional jump without cmp");
        const bool take = op == "jmp" ||
          (op == "je" && comparison == 0) ||
          (op == "jne" && comparison != 0) ||
          (op == "jlt" && comparison < 0) ||
          (op == "jle" && comparison <= 0) ||
          (op == "jgt" && comparison > 0) ||
          (op == "jge" && comparison >= 0);
        if (take) { pc = labels.at(machine_label(words[1])); first_command = false; continue; }
      } else if (op == "localget") {
        require_count(words, 3);
        const auto destination=machine_register(words[1]);
        const auto address=machine_value(words[2],registers);
        if(address<0 || address>=static_cast<std::int64_t>(locals.size()))
          throw std::out_of_range("local scratch index must be in 0..4095");
        registers[destination]=locals[static_cast<std::size_t>(address)];
      } else if (op == "localset") {
        require_count(words, 3);
        const auto address=machine_value(words[1],registers);
        if(address<0 || address>=static_cast<std::int64_t>(locals.size()))
          throw std::out_of_range("local scratch index must be in 0..4095");
        const auto value=machine_value(words[2],registers);
        locals[static_cast<std::size_t>(address)]=value;
      } else if (op == "load8") {
        require_count(words, 3);
        if (!memory) throw std::invalid_argument("Inverse Memory is not enabled");
        const auto index = machine_register(words[1]);
        const auto read = memory->read(machine_substitute(words[2], registers), core);
        if (!read.deterministic)
          throw std::runtime_error("load8 requires a deterministic byte; quantum handle " + read.handle);
        registers[index] = read.value;
      } else if (op == "load16" || op == "load32") {
        require_count(words, 3);
        if (!memory) throw std::invalid_argument("Inverse Memory is not enabled");
        const auto index = machine_register(words[1]);
        const unsigned count = op == "load16" ? 2U : 4U;
        const auto address = decimal<std::uint64_t>(machine_substitute(words[2],registers),"bulk memory address");
        if (address > std::numeric_limits<std::uint64_t>::max()-(count-1))
          throw std::out_of_range("bulk memory address range exceeds uint64");
        std::uint64_t value=0;
        for (unsigned i=0;i<count;++i) {
          const auto read=memory->read(std::to_string(address+i),core);
          if (!read.deterministic)
            throw std::runtime_error(op+" requires deterministic bytes; quantum handle "+read.handle);
          value |= std::uint64_t(read.value)<<(8*i);
        }
        registers[index]=static_cast<std::int64_t>(value);
      } else if (op == "store16" || op == "store32") {
        require_count(words, 3);
        if (!memory) throw std::invalid_argument("Inverse Memory is not enabled");
        const unsigned count = op == "store16" ? 2U : 4U;
        const auto address = decimal<std::uint64_t>(machine_substitute(words[1],registers),"bulk memory address");
        if (address > std::numeric_limits<std::uint64_t>::max()-(count-1))
          throw std::out_of_range("bulk memory address range exceeds uint64");
        const auto value=machine_value(words[2],registers);
        const std::int64_t maximum=count==2 ? INT64_C(65535) : INT64_C(4294967295);
        if (value<0 || value>maximum)
          throw std::out_of_range(op+" value exceeds unsigned "+std::to_string(count*8)+"-bit range");
        for (unsigned i=0;i<count;++i)
          memory->store(std::to_string(address+i),static_cast<std::uint8_t>((std::uint64_t(value)>>(8*i))&255),core);
      } else if (op == "store8") {
        require_count(words, 3);
        if (!memory) throw std::invalid_argument("Inverse Memory is not enabled");
        const auto address = machine_substitute(words[1], registers);
        const auto value = machine_value(words[2], registers);
        if (value < 0 || value > 255)
          throw std::out_of_range("store8 value must be in 0..255");
        memory->store(address, static_cast<std::uint8_t>(value), core);
      } else if (op == "meshbegin") {
        require_count(words, 5);
        if (mesh_active || frame_active || !result.output.empty())
          throw std::invalid_argument("meshbegin requires a fresh output");
        mesh.begin(machine_value(words[1],registers),machine_value(words[2],registers),
                   machine_value(words[3],registers),machine_value(words[4],registers));
        mesh_active=true;
      } else if (op == "meshvertex") {
        require_count(words, 5);
        if (!mesh_active) throw std::invalid_argument("meshvertex without meshbegin");
        mesh.vertex(machine_value(words[1],registers),
                    {machine_value(words[2],registers),machine_value(words[3],registers),machine_value(words[4],registers)});
      } else if (op == "meshshade") {
        require_count(words, 3);
        if (!mesh_active) throw std::invalid_argument("meshshade without meshbegin");
        mesh.shade(machine_value(words[1],registers),machine_value(words[2],registers));
      } else if (op == "meshfacegradient") {
        require_count(words, 10);
        if (!mesh_active) throw std::invalid_argument("meshfacegradient without meshbegin");
        mesh.gradient_face(machine_value(words[1],registers),machine_value(words[2],registers),machine_value(words[3],registers),
                           machine_value(words[4],registers),machine_value(words[5],registers),machine_value(words[6],registers),
                           machine_value(words[7],registers),machine_value(words[8],registers),machine_value(words[9],registers));
      } else if (op == "meshread") {
        require_count(words, 5);
        if (!mesh_active) throw std::invalid_argument("meshread without meshbegin");
        const auto x=machine_register(words[1]),y=machine_register(words[2]),z=machine_register(words[3]);
        if (x==y || y==z || x==z)
          throw std::invalid_argument("meshread requires three distinct destination registers");
        // Resolve and validate the source before assigning any destination;
        // the vertex-id operand may itself be one of these input registers.
        const auto vertex=mesh.read(machine_value(words[4],registers));
        registers[x]=vertex.x;registers[y]=vertex.y;registers[z]=vertex.z;
      } else if (op == "meshface") {
        require_count(words, 9);
        if (!mesh_active) throw std::invalid_argument("meshface without meshbegin");
        mesh.face(machine_value(words[1],registers),machine_value(words[2],registers),machine_value(words[3],registers),
                  machine_value(words[4],registers),machine_value(words[5],registers),machine_value(words[6],registers),
                  machine_value(words[7],registers),machine_value(words[8],registers));
      } else if (op == "meshtri") {
        require_count(words, 11);
        if (!mesh_active) throw std::invalid_argument("meshtri without meshbegin");
        mesh.triangle({machine_value(words[1],registers),machine_value(words[2],registers),machine_value(words[3],registers)},
                      {machine_value(words[4],registers),machine_value(words[5],registers),machine_value(words[6],registers)},
                      {machine_value(words[7],registers),machine_value(words[8],registers),machine_value(words[9],registers)},
                      machine_value(words[10],registers));
      } else if (op == "meshtri3") {
        require_count(words, 15);
        if (!mesh_active) throw std::invalid_argument("meshtri3 without meshbegin");
        mesh.triangle3({machine_value(words[1],registers),machine_value(words[2],registers),machine_value(words[3],registers)},
                       {machine_value(words[4],registers),machine_value(words[5],registers),machine_value(words[6],registers)},
                       {machine_value(words[7],registers),machine_value(words[8],registers),machine_value(words[9],registers)},
                       machine_value(words[10],registers),machine_value(words[11],registers),
                       machine_value(words[12],registers),machine_value(words[13],registers),machine_value(words[14],registers));
      } else if (op == "meshend") {
        require_count(words, 1);
        if (!mesh_active) throw std::invalid_argument("meshend without meshbegin");
        auto visible=mesh.finish();
        if (visible.size()>max_response_bytes) throw std::length_error("XI mesh output exceeds transport budget");
        result.output=std::move(visible);mesh_active=false;
      } else if (op == "framebegin") {
        require_count(words, 4);
        if (frame_active || mesh_active || !result.output.empty())
          throw std::invalid_argument("framebegin requires a fresh output");
        const auto width = machine_value(words[1], registers);
        const auto height = machine_value(words[2], registers);
        const auto revision = machine_value(words[3], registers);
        if (width < 1 || width > 8192 || height < 1 || height > 8192 ||
            width * height > 16777216 || revision < 0 ||
            revision > std::numeric_limits<std::uint32_t>::max())
          throw std::out_of_range("invalid XFS1 dimensions or revision");
        frame_width = static_cast<std::uint16_t>(width);
        frame_height = static_cast<std::uint16_t>(height);
        frame_revision = static_cast<std::uint32_t>(revision);
        frame.assign("XFS1", 4);
        frame.push_back(char(1)); frame.push_back(char(0));
        append16(frame_width); append16(frame_height);
        append32(frame_revision); append16(0);
        frame_active = true;
      } else if (op == "framespan") {
        require_count(words, 6);
        if (!frame_active) throw std::invalid_argument("framespan without framebegin");
        const auto y = machine_value(words[1], registers);
        const auto x0 = machine_value(words[2], registers);
        const auto x1 = machine_value(words[3], registers);
        const auto material = machine_value(words[4], registers);
        const auto depth = machine_value(words[5], registers);
        if (y < 0 || y >= frame_height || x0 < 0 || x1 < x0 ||
            x1 >= frame_width || material < 0 || material > 255 ||
            depth < 1 || depth > 65535)
          throw std::out_of_range("invalid XFS1 span");
        if (frame.size() > max_response_bytes - 14 - 8)
          throw std::length_error("XFS1 output exceeds transport budget");
        frame.push_back(char(2));frame.push_back(static_cast<char>(material));
        append16(static_cast<std::uint16_t>(y));
        append16(static_cast<std::uint16_t>(x0));
        append16(static_cast<std::uint16_t>(x1));
        append16(static_cast<std::uint16_t>(depth));
        append32(frame_revision);
      } else if (op == "frameend") {
        require_count(words, 1);
        if (!frame_active) throw std::invalid_argument("frameend without framebegin");
        if (frame.size() > max_response_bytes - 8)
          throw std::length_error("XFS1 output exceeds transport budget");
        frame.push_back(char(3));frame.push_back(char(0));append16(0);
        append32(frame_revision);
        result.output = std::move(frame);
        frame_active = false;
      } else if (op == "print") {
        require_count(words, 2);
        const auto index = machine_register(words[1]);
        output_line("{\"type\":\"register\",\"register\":\"r" + std::to_string(index) +
                    "\",\"value\":" + std::to_string(registers[index]) + "}\n");
      } else if (op == "halt") {
        require_count(words, 1);
        if (frame_active || mesh_active) throw std::invalid_argument("unterminated XFS1 frame or mesh");
        break;
      } else {
        auto expanded = words;
        for (std::size_t i = 1; i < expanded.size(); ++i)
          expanded[i] = machine_substitute(expanded[i], registers);
        std::ostringstream line;
        line.imbue(std::locale::classic());
        line.exceptions(std::ios::badbit | std::ios::failbit);
        line << std::setprecision(17);
        execute_line(expanded, core, memory, line, result.explicit_mutation);
        output_line(line.str());
      }
      first_command = false;
      ++pc;
    } catch (const std::exception& error) {
      throw std::runtime_error("line " + std::to_string(inst.line) + ": " + error.what());
    }
  }
  if (in_batch) throw std::invalid_argument("unterminated batch: expected end");
  if (frame_active || mesh_active) throw std::invalid_argument("unterminated XFS1 frame or mesh");
  return result;
}
