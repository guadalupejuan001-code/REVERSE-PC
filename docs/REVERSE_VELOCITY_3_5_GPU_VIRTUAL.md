# Reverse Velocity 3.5: REgraphics + GPU-VIRTUAL

Reverse Velocity now executes GPU-VIRTUAL's shared compact triangle component
inside its live REgraphics GPU backend. XI/Ether retains authority for physics,
geometry and state. The original game, car models, material fragment shader,
four trails, controls, HD driving and native 4K photography are retained.

The shared source and exact upstream commit are pinned in
`GPU_VIRTUAL_INTEGRATION_LOCK.json`. CI compares the vendored executable source
against that pinned checkout; this is an executing dependency, not a label.

Changes:

- 24-byte GPU vertices replace the 44-byte float expansion. Signed X/Y and UVs,
  20-bit Z, flat categories, original binary32 light values and all material
  bytes preserve the exact existing shader inputs. Transparency retains its
  original sort order. Depth and color use identical position reconstruction.
- Bounded staging/VBO capacity grows with the scene. Exact comparisons produce
  dirty 256-vertex page ranges, merging adjacent ranges. Equal data remains
  resident; context restoration invalidates every live page. Camera movement
  still updates changed geometry; no invalid temporal visibility is reused.
- Palette and atlas textures upload only on actual byte changes. Completed
  scene depth is discarded after its final use on tile-based GPUs.
- The same material source also compiles specialized sky and terrain programs.
  Only contiguous opaque spans use them, retaining the original face order and
  equal-depth tie behavior. Transparency keeps the original generic program.
  The generic route remains available if specialized compilation fails or a
  scene would require more than 128 spans. This avoids removing materials,
  lowering resolution or approximating lighting to reduce shader cost.
- GPU presentation no longer has a second 30 Hz sleep limiter. Display refresh,
  scene preparation, actual GPU throughput and thermal behavior still constrain
  visible FPS. The software fallback keeps its existing pacing.
- Full-image HD/4K verification hashes all RGBA rows through 64-row scratch:
  327,680 bytes for HD and 983,040 for 4K, instead of retaining a 33,177,600-byte
  4K readback buffer. Photo quality and SHA-256 byte order are unchanged.

Validation includes the independent original float adapter, actual XI-generated
camera/effect fixtures, legacy/compact Mesa pixel comparisons at 320x180,
1280x720 and 3840x2160, and exact striped/full readback hashing. Host reference
execution is not physical-phone performance. Android CI additionally builds an
upgrade signed by the original identity, installs it, drives using real inputs,
exercises reverse/nitro/air/orbit/lifecycle/photo controls, and alternates the
3.4.2 and 3.5 APKs on the same AVD. Its report separates drawing FPS, physics
rate, wall-clock pipeline times, requested resource capacity and process PSS.

The 45.45% smaller vertex payload is a format property, not a universal FPS or
total RAM claim. Physical Mali-G68 performance must be measured on that phone.
This release integrates this game's backend; it does not intercept arbitrary
third-party games or remove hardware limits.
