#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
upstream="${1:-$root/deps/mundo-x}"
output="${2:-$root/build/xi-learning}"
mkdir -p "$output"
python3 "$root/scripts/prepare-ether-compat.py" "$upstream" "$output/ether-compat"
for target in reverse_pc xi_session; do
  g++ -std=c++17 -O2 -Wall -Wextra -Wpedantic -pthread \
    -DREVERSE_PC_HAVE_BOUNDED_PRODUCT_IMPORT=1 \
    -I"$output/ether-compat" -I"$upstream/native/include" -I"$root/src" \
    "$root/src/$target.cpp" -o "$output/$target"
done
