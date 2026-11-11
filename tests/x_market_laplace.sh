#!/usr/bin/env bash
# Verify original XI programs on the actual REVERSE-PC runtime (no mock engine).
set -euo pipefail
cd "$(dirname "$0")/.."
bin="${1:-./build/reverse_pc}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
programs="experiments/x-market-laplace"
check() {
  if ! grep -Fq "$2" "$1"; then
    echo "FAIL: expected $2 in $1" >&2
    cat "$1" >&2
    exit 1
  fi
}
"$bin" init "$tmp/blank.rvp" > "$tmp/init.jsonl"
"$bin" run "$programs/closed_world.xi" "$tmp/blank.rvp" "$tmp/closed.rvp" > "$tmp/closed.jsonl"
check "$tmp/closed.jsonl" '"register":"r0","value":12620'
check "$tmp/closed.jsonl" '"register":"r5","value":12620'
check "$tmp/closed.jsonl" '"register":"r9","value":12620'
check "$tmp/closed.jsonl" '"register":"r15","value":1'
"$bin" run "$programs/open_world.xi" "$tmp/closed.rvp" "$tmp/open.rvp" > "$tmp/open.jsonl"
check "$tmp/open.jsonl" '"register":"r9","value":12620'
check "$tmp/open.jsonl" '"register":"r0","value":12870'
check "$tmp/open.jsonl" '"register":"r4","value":250'
check "$tmp/open.jsonl" '"register":"r5","value":12870'
check "$tmp/open.jsonl" '"register":"r15","value":1'
"$bin" run "$programs/sensitivity.xi" "$tmp/blank.rvp" "$tmp/sensitivity.rvp" > "$tmp/sensitivity.jsonl"
check "$tmp/sensitivity.jsonl" '"register":"r0","value":32768'
check "$tmp/sensitivity.jsonl" '"register":"r1","value":65536'
check "$tmp/sensitivity.jsonl" '"register":"r3","value":32768'
# The RXE executable must preserve the .xi program's observable behavior.
"$bin" compile "$programs/closed_world.xi" "$tmp/X-MARKET.rxe" "X MARKET Laplace Lab" > "$tmp/compile.json"
"$bin" run "$tmp/X-MARKET.rxe" "$tmp/blank.rvp" "$tmp/closed-rxe.rvp" > "$tmp/closed-rxe.jsonl"
cmp "$tmp/closed.jsonl" "$tmp/closed-rxe.jsonl"
cmp "$tmp/closed.rvp" "$tmp/closed-rxe.rvp"
# An invalid later instruction must not replace the existing destination.
cp "$tmp/open.rvp" "$tmp/sentinel.rvp"
if "$bin" run "$programs/rollback.xi" "$tmp/closed.rvp" "$tmp/open.rvp" > "$tmp/failure.out" 2> "$tmp/failure.err"; then
  echo "FAIL: transaction with division by zero was accepted" >&2
  exit 1
fi
test ! -s "$tmp/failure.out"
cmp "$tmp/open.rvp" "$tmp/sentinel.rvp"
echo '{"suite":"x_market_laplace","closed_exact":true,"open_error_cents":250,"informed_exact":true,"memory_persisted":true,"rxe_equivalent":true,"rollback_preserved":true}'
