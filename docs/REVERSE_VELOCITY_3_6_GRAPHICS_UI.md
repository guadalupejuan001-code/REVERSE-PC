# Reverse Velocity 3.6 — graphics presets and driving interface

The playable game no longer exposes 4K photography or the old HD/Fluid toggle.
Five immutable presets control real GPU framebuffer dimensions, material work,
texture filtering and post-processing. The default is Medio and the choice is
stored in SharedPreferences across process restarts and upgrades.

| Preset | Actual GPU target | Materials and effects | Pacing |
| --- | --- | --- | --- |
| Ahorro | 480×270 | Authored light/colors, minimal effects, no procedural PBR/post | Up to 30 FPS |
| Bajos | 640×360 | Basic lighting, nearest texture sampling, simple event effects | Display pacing |
| Medio | 960×540 | PBR car materials/reflections, linear textures, lighter sky/ground, no post blur | Display pacing |
| Alto | 1280×720 | Full procedural sky/ground/lighting and edge smoothing | Display pacing |
| Ultra | 1920×1080 | Full materials, edge smoothing and bloom | Display pacing |

All levels retain the same XI geometry, physics, input and collision rules.
Quality intentionally changes material effects; original full-fidelity
legacy/compact image comparisons run at shader quality 4. A separate host
test runs all five shader policies at the same resolution to verify actual
visual differences independently of target size. Every preset's first GPU
frame is read back in bounded 64-row stripes and hashed. The maximum live GPU
target is 1080p. The historical XFG4 projection grid and offline software
reference assets remain separate from the number of rendered pixels.

The XI software fallback remains playable at its actual bounded resolutions;
the HUD reports the real output size rather than labeling it as native GPU
1080p. Existing compact GPU-VIRTUAL vertices, dirty-page uploads, material
specialization and context restoration are retained.

The scene has a compact RV/Reverse Velocity header, live speed/route data,
mini-map and essential steering, pedal, gear, nitro, air and drift controls.
The scrolling toolbar is replaced with a custom native side drawer. Graphics,
garage, map, assistance, time, camera, audio, FPS, restart and exit live there.
Opening it releases held controls and pauses XI physics; closing or continuing
restores the correct pause state. Pages scroll vertically, and the Continue
action remains pinned above the bottom edge. Menu navigation does not expand
the scene or require another rendering engine.

Android validation must exercise all five actual target sizes during sustained
driving, selection persistence, hidden secondary tools, menu time freeze,
paused-frame reuse, touch accelerator/analog steering, garage/map, actual
nitro/air geometry, reverse motion and Activity lifecycle. The APK updates the
original package/signing identity with versionCode 38. Android emulation and
host rendering are reported separately from physical-phone performance.
