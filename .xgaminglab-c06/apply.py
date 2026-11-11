#!/usr/bin/env python3
from pathlib import Path
import sys
root=Path(sys.argv[1]).resolve()

def repl(path, old, new):
    p=root/path
    s=p.read_text()
    if old not in s:
        raise SystemExit(f'C06 expected text missing in {path}: {old[:90]!r}')
    p.write_text(s.replace(old,new))

def write(path,text):
    p=root/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text)

repl(Path('src/x/lab/gaming/RunConfig.java'),
 'static final String[] GRAPHICS={"Automática · REgraphics cuando conviene","Referencia · por objeto","Batches GLES2","Instancing preferido","GPU Virtual + REgraphics C05 · 333"};',
 'static final String[] GRAPHICS={"Automática · C06 Balance","Referencia · por objeto","Batches GLES2","Instancing preferido","GPU Virtual + REgraphics C05 · 333","GPU Virtual + REgraphics C06 · Balance"};')
repl(Path('src/x/lab/gaming/RunConfig.java'),'String mode(){return coordinated?"Coordinada":"Libre";}','String mode(){return effectiveGraphicsPath()==5?"Balance · VSync sin cola":(coordinated?"Coordinada":"Libre");}')
repl(Path('src/x/lab/gaming/RunConfig.java'),'return scene==5||scene==6?4:3;','return scene==5||scene==6?5:3;')

repl(Path('src/x/lab/gaming/FrameLoop.java'),'    private final Runnable renderTask=this::render;\n','    private final Runnable renderTask=this::render;\n    private static boolean displayPaced(RunConfig c){return c!=null&&(c.coordinated||c.effectiveGraphicsPath()==5);}\n')
repl(Path('src/x/lab/gaming/FrameLoop.java'),'            if(selected.coordinated)postClock();else requestFrame(System.nanoTime(),0);','            if(displayPaced(selected))postClock();else requestFrame(System.nanoTime(),0);')
repl(Path('src/x/lab/gaming/FrameLoop.java'),'if(!running||closing||current==null||!current.coordinated)return;','if(!running||closing||current==null||!displayPaced(current))return;')
repl(Path('src/x/lab/gaming/FrameLoop.java'),'if(running&&!closing&&current!=null&&!current.coordinated)requestFrame(System.nanoTime(),0);','if(running&&!closing&&current!=null&&!displayPaced(current))requestFrame(System.nanoTime(),0);')

repl(Path('src/x/lab/gaming/MainActivity.java'),
 'Automática usa GPU Virtual + REgraphics C05 en Carreras/Efectos. 333 FPS es objetivo interno; la presentación física sigue limitada por la pantalla.\\nMasiva / extrema mantiene la carga fija durante cada prueba.',
 'Automática usa C06 Balance en Carreras/Efectos: conserva C05, presenta una sola vez por VSync y evita acumular frames que el panel no puede mostrar.\\nC05 · 333 queda disponible como modo turbo/benchmark.')
repl(Path('src/x/lab/gaming/MainActivity.java'),'GPU Virtual + REgraphics C04 · PWR ABBA','GPU Virtual + REgraphics · PWR ABBA')
repl(Path('src/x/lab/gaming/MainActivity.java'),'PWR ABBA alterna Instancing preferido / GPU Virtual + REgraphics C04 / GPU Virtual + REgraphics C04 / Instancing preferido.','PWR ABBA alterna Instancing preferido / GPU Virtual + REgraphics C05 / GPU Virtual + REgraphics C05 / Instancing preferido.')
repl(Path('src/x/lab/gaming/MainActivity.java'),
 '"Dibujo           "+(execution.optInt("effectiveGraphicsPath",config.graphicsPath)==4?(config.graphicsPath==0?"Automática → GPU Virtual + REgraphics C04":"GPU Virtual + REgraphics C04"):execution.optLong("instancedDraws")>0?(config.graphicsPath==0?"Automática → Instancing":"Instancing"):execution.optLong("batchedDraws")>0?"Batches":"Referencia"));',
 '"Dibujo           "+(execution.optInt("effectiveGraphicsPath",config.effectiveGraphicsPath())==5?"GPU Virtual + REgraphics C06 Balance":execution.optInt("effectiveGraphicsPath",config.effectiveGraphicsPath())==4?"GPU Virtual + REgraphics C05 · 333":execution.optLong("instancedDraws")>0?(config.graphicsPath==0?"Automática → Instancing":"Instancing"):execution.optLong("batchedDraws")>0?"Batches":"Referencia"));')

repl(Path('native/x_backend.cpp'),'const bool compact_graphics = config.graphics_path == 4 && compact_relation;','const bool compact_graphics = config.graphics_path >= 4 && compact_relation;')
repl(Path('native/android_bridge.cpp'),'next.graphics_path<0||next.graphics_path>4','next.graphics_path<0||next.graphics_path>5')
repl(Path('native/scene_renderer.cpp'),'config.graphics_path<0||config.graphics_path>4','config.graphics_path<0||config.graphics_path>5')
repl(Path('native/scene_renderer.cpp'),'Graphics path must be auto, reference, batches, preferred instancing or GPU Virtual compact delta','Graphics path must be auto, reference, batches, preferred instancing, GPU Virtual C05 or balanced C06')
repl(Path('native/scene_renderer.cpp'),'if(p.config.graphics_path==4){','if(p.config.graphics_path>=4){')
repl(Path('native/scene_renderer.cpp'),'const std::string route=p.config.graphics_path==4?"gpu_virtual_resolved_stream":p.config.graphics_path==1?', 'const std::string route=p.config.graphics_path==5?"gpu_virtual_regraphics_balanced":p.config.graphics_path==4?"gpu_virtual_resolved_stream":p.config.graphics_path==1?')
repl(Path('native/scene_renderer.cpp'),
 '   <<",\\"regraphics_c05_effect_points\\":true,\\"effect_point_payload_bytes\\":"<<sizeof(c05::EffectPoint)<<",\\"effect_depth_bins\\":16,\\"effect_full_sort\\":false,\\"effect_virtual_cluster_threshold\\":4096,\\"effect_virtual_grid_height\\":48,\\"fused_scene_effect_composite\\":true,\\"virtual_target_hz\\":333,\\"virtual_frame_budget_ms\\":3.003003"\n',
 '   <<",\\"regraphics_c05_effect_points\\":true,\\"effect_point_payload_bytes\\":"<<sizeof(c05::EffectPoint)<<",\\"effect_depth_bins\\":16,\\"effect_full_sort\\":false,\\"effect_virtual_cluster_threshold\\":4096,\\"effect_virtual_grid_height\\":48,\\"fused_scene_effect_composite\\":true,\\"virtual_target_hz\\":333,\\"virtual_frame_budget_ms\\":3.003003"\n   <<",\\"regraphics_c06_balanced\\":"<<(p.config.graphics_path==5?"true":"false")<<",\\"balanced_display_pacing\\":"<<(p.config.graphics_path==5?"true":"false")<<",\\"balanced_max_pending_render\\":1,\\"balanced_policy\\":\\"latest-vsync-no-free-run\\""\n')

repl(Path('AndroidManifest.xml'),'android:versionCode="34" android:versionName="3.3.0-c05-333"','android:versionCode="35" android:versionName="3.4.0-c06-balanced"')
repl(Path('scripts/build_apk.py'),'VERSION="3.2.1-c04-final"','VERSION="3.4.0-c06-balanced"')
repl(Path('scripts/build_apk.py'),"'version':'3.2.1-c04-final'","'version':'3.4.0-c06-balanced'")
repl(Path('scripts/build_apk.py'),"'graphics':'GPU Virtual resolved stream -> REgraphics C04 retained opaque base + adaptive effect FBO -> physical GLES; three async physical pass timers'","'graphics':'GPU Virtual + REgraphics C06 Balanced: C05 clustered points plus one-frame VSync pacing; free-run C05 333 retained for stress tests'")
repl(Path('scripts/build_apk.py'),"apk=dist/'X-Gaming-Lab-C05-333.apk'","apk=dist/'X-Gaming-Lab-C06-Balanced.apk'")

write(Path('docs/REGRAPHICS_C06_BALANCED.md'),'''# REgraphics C06 — Balanced project profile

C06 keeps the C05 pre-GPU reduction and adds a production-oriented pacing policy.

- **C05 333 (route 4)**: free-run stress/benchmark.
- **C06 Balance (route 5)**: same clustered GPU Virtual stream, at most one render request per display VSync.
- **Auto**: Racing and Effects select C06 Balance; other scenes keep preferred instancing.

The one-frame pending admission gate prevents a physical render queue from building behind the display. C06 targets stable presentation, bounded queue depth and thermal/power margin; it does not claim zero latency.
''')
write(Path('tests/run-regraphics-c06.sh'),'''#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
grep -q 'GPU Virtual + REgraphics C06 · Balance' "$ROOT/src/x/lab/gaming/RunConfig.java"
grep -q 'scene==5||scene==6?5:3' "$ROOT/src/x/lab/gaming/RunConfig.java"
grep -q 'displayPaced(selected)' "$ROOT/src/x/lab/gaming/FrameLoop.java"
grep -q '!displayPaced(current)' "$ROOT/src/x/lab/gaming/FrameLoop.java"
grep -q 'config.graphics_path >= 4 && compact_relation' "$ROOT/native/x_backend.cpp"
grep -q 'gpu_virtual_regraphics_balanced' "$ROOT/native/scene_renderer.cpp"
grep -q 'balanced_max_pending_render' "$ROOT/native/scene_renderer.cpp"
grep -q '3.4.0-c06-balanced' "$ROOT/AndroidManifest.xml"
grep -q 'VERSION="3.4.0-c06-balanced"' "$ROOT/scripts/build_apk.py"
echo '{"suite":"regraphics_c06_balance","checks":9,"auto_route":5,"max_pending_render":1,"policy":"latest-vsync-no-free-run"}'
''')
(root/'tests/run-regraphics-c06.sh').chmod(0o755)
print('C06 applied to',root)
