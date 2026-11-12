# REgraphics Adaptive Fidelity — new GPU Virtual capability (experimental)

## Objective
Expand fidelity of screen-space effect rendering beyond the single-pixel-cell representation without losing the original benchmark. **Path 4 remains unchanged. Path 5 is opt-in** and may be slower by design.

## Actual implementation

- `native/adaptive_visual_field.hpp` projects original GPU Virtual `GraphicsInstance` effects to 20-byte `VisualTile` splats.
- Per 12-pixel cell it **only** merges nearly coincident effects with matched color, size and depth, and with a numerically bounded sampled alpha-glow deviation. Others are kept as **independent ordered splats**, not averaged into a single color or position.
- Stable far-to-near depth order (and original input order at equal depth) preserves transparent layer ordering. RGBA is quantized to 8-bit for the GLES stream.
- **Path 5 chooses full-resolution effects FBO** rather than the /4 FBO used in some path-4 scenes, preventing the incorrect enlargement of subpixel splats. This can raise GPU cost; it is an explicit quality tradeoff.
- `native/visual_damage.hpp` gains `LayeredTileCache` to compare multiple RGBA/depth elements per cell, including their order; it invalidates previous/new coverage for moving or disappearing splats, handles backbuffer age and resets on context loss. Path 4 keeps its original single-tile cache.
- `native/x_backend.cpp` preserves the same **1,024 macro anchors** on both routes 4 and 5. 369,000,000,000 is a synthetic **logical population**, not an independent-asset throughput measurement.
- `native/scene_renderer.cpp` exposes `adaptive_field_active`, `adaptive_input`, `adaptive_tiles_merged`, `adaptive_splats_preserved`, `adaptive_risky_cells`, `adaptive_effect_divisor` in renderer capabilities. This allows objective verification of how much is actually compressed.
- XGamingLab settings allow selecting **GPU Virtual · Fidelidad adaptativa** explicitly, alongside **GPU Virtual + REgraphics · Final**.

## Ground-truth gates

`bash tests/run-adaptive-fidelity.sh`:
- Replays four previously documented destructive software cases: opaque front/back color, transparent alpha order, distinct thin objects in the same cell, small particle with correct FBO pixel size. Requires foreground MAE <= 0.008 and no accidental collapse of distinct objects.
- Requires a genuinely safe weak-alpha same-location pair to compress and keep foreground MAE <= .006; verifies a moved point does **not** merge.
- Tests 2 independent splats in one cache cell: unchanged frame, one moved, alpha reorder, buffer-age 2 and context reset.
- Stress test: 100,000 independently defined sprites with distinct RGBA, positions and depth are retained as 100,000, not conflated with the 369B procedural counter. This proves data-path handling only, not physical GPU throughput.
- Re-runs previous C01, C02, C03 and fast-route checks unchanged.

`bash scripts/test-adaptive-gles.sh` (in CI with Mesa GLES2): real EGL context; compare path4 versus path5 for opaque overlap, alpha overlap and thin red/green particles with `glReadPixels`; exit nonzero on missing pixels, incorrect ordering or context errors.

## Boundaries and acceptance

- Not a general-purpose asset renderer and **not** proof of 369B distinct objects. Still only renders sprites/effects for `COMPACT_EFFECTS_FIELD`; exact geometry remains in the existing racing and mesh routes.
- The risk classifier is intentionally conservative; arbitrary silhouettes, textures, and independently animated meshes must remain on exact geometry/texture paths.
- No claim of FPS improvement or energy savings until the SM-S166V Mali-G68 measures same scene/seed/resolution, presentation FPS and internal FPS separately, P95/P99, GPU ms and screenshot parity.
- C03 is unchanged as baseline and no PR is auto-merged. CI verifies host but cannot replace physical Mali QA.

## Current validation status

- Local C++ host quality and stress tests **PASS**. Source-level field tests verify four previous failure cases, safe weak-alpha compression and multi-layer dirty-region invalidation.
- Full GLES runtime and Android/NDK build **not executed** in this container (no GLES SDK headers available). `scripts/test-adaptive-gles.sh` is prepared for an EGL/GLES CI runner.
- 100,000 independent *splats* retained; no claim they are textured meshes or rendered frames at a specific framerate.
- This source snapshot is an **experimental worktree**, not an upstream merged commit.
