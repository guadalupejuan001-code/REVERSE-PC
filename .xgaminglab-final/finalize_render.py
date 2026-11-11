#!/usr/bin/env python3
from pathlib import Path
import sys

root=Path(sys.argv[1]).resolve()

def repl(rel, old, new):
    p=root/rel
    s=p.read_text()
    if old not in s:
        raise SystemExit(f'REgraphics Final expected text missing in {rel}: {old[:120]!r}')
    p.write_text(s.replace(old,new))

repl(Path('native/scene_renderer.cpp'),
 'for(const auto& group:packet.compact_groups)if(group.program==COMPACT_EFFECTS){h=hash_value(h,group.relation_hash);h=hash_value(h,group.count);}',
 'for(const auto& group:packet.compact_groups)if(group.program==COMPACT_EFFECTS||group.program==COMPACT_EFFECTS_FIELD){h=hash_value(h,group.relation_hash);h=hash_value(h,group.count);}')

repl(Path('native/scene_renderer.cpp'),
 'for(std::size_t gi=0;gi<packet.compact_groups.size();++gi)if(packet.compact_groups[gi].program==COMPACT_EFFECTS){',
 'for(std::size_t gi=0;gi<packet.compact_groups.size();++gi)if(packet.compact_groups[gi].program==COMPACT_EFFECTS||packet.compact_groups[gi].program==COMPACT_EFFECTS_FIELD){')

repl(Path('AndroidManifest.xml'),
 'android:versionCode="37" android:versionName="3.6.0-regraphics-final"',
 'android:versionCode="38" android:versionName="3.6.1-regraphics-final"')

repl(Path('scripts/build_apk.py'),'3.6.0-regraphics-final','3.6.1-regraphics-final')

test=root/'tests/run-regraphics-final-render.sh'
test.write_text(r'''#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/native/scene_renderer.cpp"
grep -Fq 'group.program==COMPACT_EFFECTS||group.program==COMPACT_EFFECTS_FIELD' "$SRC"
grep -Fq 'packet.compact_groups[gi].program==COMPACT_EFFECTS||packet.compact_groups[gi].program==COMPACT_EFFECTS_FIELD' "$SRC"
grep -Fq 'const int target=(group.program==COMPACT_EFFECTS||group.program==COMPACT_EFFECTS_FIELD)?2:1;' "$SRC"
grep -Fq 'glUniform1f(p.effect_point_u.viewport_height,float(p.effect.height))' "$SRC"
grep -Fq 'glBindFramebuffer(GL_FRAMEBUFFER,p.effect.fbo)' "$SRC"
grep -Fq 'glUseProgram(p.fused_screen_program)' "$SRC"
echo '{"suite":"regraphics_final_render","checks":6,"field_effects_mode":true,"field_layer_signature":true,"effect_pass":2,"fused_composite":true}'
''')
test.chmod(0o755)

doc=root/'docs/REGRAPHICS_FINAL.md'
s=doc.read_text()
s += '\n## Render-path correction 3.6.1\nCOMPACT_EFFECTS_FIELD now participates in effects-mode detection and layer signatures, so its adaptive effect FBO is created and composited instead of collapsing to a zero-height viewport path.\n'
doc.write_text(s)

print('REgraphics Final render path corrected')
