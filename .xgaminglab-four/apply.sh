#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 2 ]]; then
  echo "Usage: bash .xgaminglab-four/apply.sh C03_source.tar.gz output_dir" >&2
  exit 2
fi
ARCHIVE="$1"
OUTPUT="$2"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXPECTED="c0b6b149eda24ff18a418608349d87669fba70f7989f15672cbdc57d0d287880"
ACTUAL="$(sha256sum "$ARCHIVE" | awk '{print $1}')"
if [[ "$ACTUAL" != "$EXPECTED" ]]; then
  echo "C03 source mismatch: $ACTUAL" >&2
  exit 3
fi
mkdir -p "$OUTPUT"
tar -xzf "$ARCHIVE" -C "$OUTPUT"
patch --dry-run --batch -d "$OUTPUT" -p1 < "$REPO_ROOT/.xgaminglab-four/adaptive-fidelity.patch"
patch --batch -d "$OUTPUT" -p1 < "$REPO_ROOT/.xgaminglab-four/adaptive-fidelity.patch"
grep -Fq '4.0.0-regraphics-adaptive' "$OUTPUT/AndroidManifest.xml"
echo "REgraphics 4.0 source materialized: $OUTPUT"
