#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$ROOT/app/src/main/assets/earth_1024.png"
URL='https://svs.gsfc.nasa.gov/vis/a000000/a002900/a002915/bluemarble-1024.png'
mkdir -p "$(dirname "$TARGET")"
if [[ ! -s "$TARGET" ]]; then
  TEMP="$TARGET.partial"
  trap 'rm -f "$TEMP"' EXIT
  curl --fail --location --show-error --silent --retry 3 --retry-delay 2 \
       --connect-timeout 15 --max-time 120 "$URL" -o "$TEMP"
  mv "$TEMP" "$TARGET"
fi
python3 - "$TARGET" <<'PY'
import hashlib,struct,sys
from pathlib import Path
p=Path(sys.argv[1]);b=p.read_bytes()
assert len(b)>50000 and b[:8]==b'\x89PNG\r\n\x1a\n','invalid NASA texture'
w,h=struct.unpack_from('>II',b,16)
assert (w,h)==(1024,512),(w,h)
print('NASA_BLUE_MARBLE_OK width=1024 height=512 bytes='+str(len(b))+
      ' sha256='+hashlib.sha256(b).hexdigest())
PY
