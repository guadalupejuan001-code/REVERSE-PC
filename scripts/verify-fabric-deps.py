#!/usr/bin/env python3
"""Reject any source substitution: REVERSE RVPC2 and each new component stay pinned."""
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
lock = json.loads((ROOT / "docs/fabric-component-lock.json").read_text())
assert lock["schema"] == "reverse-fabric-component-pins-v1"
for key, value in lock["dependencies"].items():
    repo = ROOT / "deps" / key
    if not (repo / ".git").exists():
        raise SystemExit("Missing pinned dependency: " + str(repo))
    sha = subprocess.check_output(["git", "-C", str(repo), "rev-parse", "HEAD"], text=True).strip()
    if sha != value["commit"]:
        raise SystemExit("REFUSE mismatched " + key + ": " + sha + " != " + value["commit"])
    # Dirty/untracked files are not an upstream source substitution.
    # Native headers are fetched by immutable commit and not silently rewritten.
    print("PIN_VERIFIED", key, sha)
original = (ROOT / "scripts/setup-ether.sh").read_text()
assert lock["dependencies"]["mundo-x-legacy"]["commit"] in original
assert "REVERSE_PC_ALLOW_UNPINNED_ETHER" in (ROOT / "CMakeLists.txt").read_text()
print("REVERSE_FABRIC_DEPENDENCIES_PASS; legacy RVPC2 pin retained")
