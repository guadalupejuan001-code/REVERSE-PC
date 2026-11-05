# Reverse Velocity 3.2 — Wetlands / REgraphics GPU

The forest road now includes mud, twenty standing puddles, a shallow river ford
at segments 28–29, marsh shoulders and reeds, six animated squirrels and more
boulders. The original bridge is at segment 65; the lake and eight-sector finite
1.6 km route remain traversable. Mud and water affect drag and grip in XI.
Depth, wetness and spray are retained Ether observations, not cosmetic HUD flags.

The car keeps the original animated wheel and suspension rig. Additional XI
geometry follows its chassis: elevated rear wing, four circular rear jet ports,
side intakes, panel trim and corner lights. Four crossed nitro jets originate at
the rear ports. Four pneumatic jets originate beside the wheels and reach the
ground as the car rises. The model is an original mesh inspired by the supplied
views; it is not an exact reconstruction or a photorealistic licensed model.

## Rendering and authority

XI/Ether remains authoritative for driving, surfaces, collisions, animals,
geometry, projection and the camera. The REgraphics GLES 3 backend consumes the
validated XFG4 transport already provided by XI. It batches vertices into four
passes: distant environment, opaque geometry, alpha water/shadow and additive
effects. It uses reusable buffers, a small palette and atlas, procedural material
detail, specular/Fresnel reflections, water waves, distance fog, soft sky detail
and a final antialias/glow pass. No third-party game engine is introduced.

A stable render source receives at most 32 ephemeral input bytes through a
private restored observation candidate. Moving the camera therefore reuses the
interpreter's decoded scene instead of parsing a new large program every frame.
The gameplay snapshot cannot be modified by a frame observation. XFG4 dimensions,
face counts, coordinates, depth, materials and exact packet length are validated
before any GPU upload. The original one-million-instruction XI execution limit,
512 KiB scene source ceiling and 4,096 scene-triangle limit remain unchanged.
Shared prop topology reduces duplicate XI source. The conservative authoring
budget is 3,876 triangles, with at most three active sectors and 31 road samples.

Live GPU targets adapt between widths 640, 960 and 1280 to the actual view aspect.
The native XFB5 software backend remains available if GLES 3 is unsupported or
fails. Original XFS1 and native live outputs remain pixel-identical in regression
checks. GPU material shading intentionally differs from the indexed software
oracle. Software fallback still incurs its original raster cost.

Photo mode freezes driving and renders the same XI geometry to a real
3840 × 2160 framebuffer. All 8,294,400 RGBA pixels are read back and hashed for
validation. This is not an enlarged live screenshot. Photo mode is not a live
4K driving preset. The software photo fallback still executes native XI XFB5.

## Driving and camera

The chase camera smooths corner yaw, adjusts elevation with speed and jumping,
and moves to the front side of the car when reversing. A touch drag takes
priority for 2.6 seconds; it then recenters while driving. Paused/photo views
retain the chosen angle. Double tap or a long press on Camera recenters.
Vehicle physics and projection continue to execute in XI.

The 3.1 signed bridge-side fix and brake-before-shift gearbox remain. Both banks
of the new ford are checked as well. Boulders share their visual and collision
placement and stay outside the driving corridor. Reset can recover stopped
workers; Activity background/resume cancels pending GPU work and requests a new
view. Frame telemetry reports the actual backend, dimensions, physics cadence
and observed frame rate.

## Validation

Run the `REVERSE VELOCITY REgraphics` and `REVERSE VELOCITY installable APK`
workflows. They verify deterministic source generation, all eight sectors,
physical reverse in three modes, mud/river/puddle behavior, both bridge sides,
immutable GPU observations, pneumatic/nitro geometry and squirrel presence.
The manual reliability matrix covers 60 poses and 2,880 physics steps with 60
exact software-frame comparisons. Android 35 testing exercises real GPU shader
compilation, posted frames, driving/reverse, effect controls, touch orbit, native
4K readback and Activity resume. The APK requires the original pinned signer,
matching packaged source assets and aligned ARM64/x86-64 native libraries.

`scripts/velocity-gpu-preview.py` can render an XI XFG4 capture with the exact
shipped GLSL through Mesa EGL for host visual inspection. It requires numpy,
Pillow and Mesa EGL. These images and host timings do not measure phone FPS.
Android emulator results likewise do not establish performance on a physical
phone. This remains a stylized original game, not Forza/Horizon visual parity.
