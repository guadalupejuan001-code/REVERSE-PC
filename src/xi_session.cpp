// Persistent XI transport only. All circuit descriptions, learning,
// environments and parameter updates are supplied as XI source by the caller.
#define main reverse_pc_embedded_cli_main
#include "reverse_pc.cpp"
#undef main
#include <sys/resource.h>

namespace {
void reply(bool ok, const std::string& body) {
  std::cout << (ok ? "OK " : "ERROR ") << body.size() << '\n';
  std::cout.write(body.data(), static_cast<std::streamsize>(body.size())); std::cout.flush();
}
std::string read_payload(std::size_t n) {
  if (n > 16*1024*1024) throw std::length_error("session payload budget");
  std::string data(n, '\0'); std::cin.read(data.data(), static_cast<std::streamsize>(n));
  if (static_cast<std::size_t>(std::cin.gcount()) != n) throw std::runtime_error("truncated session payload");
  return data;
}
}
int main(int argc, char** argv) {
  try {
    if (argc != 2) throw std::invalid_argument("usage: reverse_xi_session INPUT.rvp");
    auto current = load_state(argv[1]);
    std::string header;
    while (std::getline(std::cin, header)) {
      if (header.size() > 64) throw std::length_error("session header budget");
      std::istringstream in(header); std::string command, extra; std::size_t length = 0;
      in >> command;
      if (command == "METRICS" && !(in >> extra)) {
        struct rusage usage{}; if (getrusage(RUSAGE_SELF, &usage)) throw std::runtime_error("getrusage failed");
        const auto stats = current.core().stats();
        std::ostringstream o; o << std::setprecision(17)
          << "{\"peak_rss_kib\":" << usage.ru_maxrss
          << ",\"cpu_ms\":" << (usage.ru_utime.tv_sec + usage.ru_stime.tv_sec)*1000. +
               (usage.ru_utime.tv_usec + usage.ru_stime.tv_usec)/1000.
          << ",\"active_qubits\":" << stats.active_qubits
          << ",\"quantum_payload_bytes\":" << current.core().quantum_stats().payload_bytes << "}";
        reply(true, o.str()); continue;
      }
      if (!(in >> length) || in >> extra || (command != "EXEC" && command != "SAVE"))
        throw std::invalid_argument("expected EXEC n, SAVE n, or METRICS");
      const auto payload = read_payload(length);
      try {
        if (command == "SAVE") {
          if (payload.empty() || payload.find('\0') != std::string::npos) throw std::invalid_argument("invalid checkpoint path");
          if (fs::exists(payload)) throw std::invalid_argument("checkpoint exists; choose a new path");
          save_state(payload, current); reply(true, "{}");
        } else reply(true, current.execute(payload));
      } catch (const std::exception& e) { reply(false, e.what()); }
    }
    return 0;
  } catch (const std::exception& e) { std::cerr << "XI_SESSION_FAIL " << e.what() << '\n'; return 1; }
}
