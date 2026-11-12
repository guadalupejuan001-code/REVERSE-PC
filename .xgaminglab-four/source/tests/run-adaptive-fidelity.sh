#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p evidence
"${CXX:-g++}" -std=c++20 -O2 -Wall -Wextra -Wpedantic -Werror -Inative -Ivendor/gpu/include tests/adaptive_visual_test.cpp -o /tmp/regraphics-adaptive-field
/tmp/regraphics-adaptive-field | tee evidence/adaptive-host.jsonl
grep -q '"counterexamples_fixed":4' evidence/adaptive-host.jsonl
grep -q '"safe_merged":1' evidence/adaptive-host.jsonl
"${CXX:-g++}" -std=c++20 -O2 -Wall -Wextra -Wpedantic -Werror -Inative -Ivendor/gpu/include tests/adaptive_damage_test.cpp -o /tmp/regraphics-adaptive-damage
/tmp/regraphics-adaptive-damage | tee evidence/adaptive-damage-host.json
"${CXX:-g++}" -std=c++20 -O2 -Wall -Wextra -Wpedantic -Werror -Inative -Ivendor/gpu/include tests/adaptive_stress_test.cpp -o /tmp/regraphics-adaptive-stress
/tmp/regraphics-adaptive-stress | tee evidence/adaptive-stress.json
bash tests/run-regraphics-c03.sh
