# REgraphics Unified — integration contract

Objective: combine the useful algorithms of XI MeshRaster, EtherRenderSpatial, EtherSurfaceBuffer, Super Render XI, SolarAdaptiveQuality and COSMIC's material system without replacing XI or silently introducing GLES.

## Architectural rule
XI remains the geometry and scene authority. Preserve Ether state and XFB5 byte contracts. Port algorithms, not foreign rendering backends. Do not merge GLES renderers into the Android Velocity application.

## Independent capabilities to integrate
1. **Spatial candidate culling**: compare XI 32-row strip raster to conservative 2D tile bins, with brute-force pixel oracle and exact equality including tie-breaks.
2. **Lazy surfaces**: bring EtherSurfaceBuffer's visibility-only representation to XI, preserving implicit background and material/depth identity.
3. **Demand-driven output**: extend paused-frame reuse to dirty regions and camera/material dependency tracking. Never reuse stale pixels.
4. **Adaptive pacing**: adapt optional preview based on measured frame-start intervals; never alter physics timestep or silently degrade explicitly selected 4K.
5. **Materials**: extract Solar atmosphere, normal, ring, specular and COSMIC mirror rules into XI-owned, separately tested modules; no GLSL in production Velocity.
6. **Streaming**: create versioned tiled output with bounded chunks and checksums for 8K; require exact full-frame reconstruction before declaring playable 8K.
7. **Profiling**: separate physics, scene projection, binning, fragment, packet, decode and display times; record p50/p95 and RAM on the same device.

## Gates
- Preserve XI revision 2, XFG4, XFB5, existing Android controls and signer.
- Test identical car/track/camera/lighting scenes with old and new paths. Compare exact pixel buffers where contracts require it.
- Run real Android instrumentation before claiming FPS, resolution or visual quality.
- Never delete historical renderer implementations until parity and same-device performance are verified.
- One capability per tested integration; reject changes that improve synthetic timings but regress the actual game.

## Recovery sources
- mundo-X/native/include/mundo_x/ether_render_spatial.hpp
- mundo-X/native/include/mundo_x/ether_surface_buffer.hpp
- mundo-X/native/include/mundo_x/ether_renderer.hpp
- mundo-X/graphics-android/app/src/main/java/com/mundox/graphics/QuantumRenderer.java
- mundo-X/solar-android/app/src/main/java/com/mundox/solar/SolarAdaptiveQuality.java
- REVERSE-PC/experiments/xi-render/SUPER_RENDER_XI.md
- REVERSE-PC/src/integration/xi_mesh_raster.inc

This is an integration specification, not a claim that all modules are already ported.
