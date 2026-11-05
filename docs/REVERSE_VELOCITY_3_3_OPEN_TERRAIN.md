# Reverse Velocity 3.3 — Open Terrain

## Cycle 1 — Support and steering

The old 50 m road-corridor wall and the ford/lake clamps are removed. A terrain
patch follows the car in world coordinates, and the forest streams from stable
global cells. Driving beyond the road endpoint or off either side does not
project the car back onto the road. The authored 1.6 km road remains a landmark;
the pilot stops at its end, while Manual remains free to explore.

Visible terrain rows and XI wheel support use the same piecewise planar height
field. Support changes preserve world altitude in flight. Leaving a raised deck
starts a fall instead of snapping the car into its river bed. The bridge deck is
a separate support layer, so the ground below cannot pull a car through it.
Dirt overlays lie 1 cm above their actual terrain surface.

World-coordinate values use a 2,000,000,000 bias in packed uint32 fields. Signed
lateral coordinates use the same bias; nearest-road distances compare in local
64-bit registers before saturating the small telemetry field. This is numeric
representation, not a gameplay wall. Public observations validate coordinates
within ±1,000,000,000 cm. The finite road route and packed terrain knots remain
small. The open-terrain test covers eight poses, including ±20 km coordinates,
and independently compares the observed ground triangles with the car footprint.

The touch wheel emits proportional 0–200 input with 255 as the legacy/no-touch
sentinel. XI performs the steering integration. Low-speed manual turn response
is stronger and grip recovers more readily. Assisted steering retains its tuned
response; touch takes priority. Releasing the wheel recenters it. Existing
keyboard and brake-before-reverse behavior remain.

## Cycle 2 — Bridge

The deck, posts, rails and piers are authored in the road tangent/right basis.
Their endpoints follow the actual road elevations. Rails collide only at their
physical lateral range; piers also block a car below the deck near the ends.
Water and terrain remain continuous below and beside the structure.

## Cycle 3 — Living forest

The six squirrels now have rounded body/head meshes, ears, eyes, running legs
and a curved, tapered tail. Identical local mesh programs are shared between
instances. Nearby grass uses rooted crossed blades with world-tick wind; tree
crowns and branch geometry sway while roots stay on the shared terrain.

The global forest uses 120 nearby deterministic cells, with the same cell seed,
road-clearance mask and support query for rendering and collision. Trunk and
rock colliders fit their visible volume more closely. A distant world does not
accumulate persistent vegetation objects. Far trees omit trunk/branch detail.

## Cycle 4 — Lighting and validation

Transparent, shallow 3D lamp covers sit over the actual front/rear light geometry.
XI emits an invisible view-space lamp reference in the XFG4 packet. The GPU
adapter transports this reference; it does not create a different car camera.
Shaders light terrain and objects inside a soft cone, with distance falloff.
Night beams use transparent volume geometry, not an opaque triangular ground
patch. Transparent water, shadows and lamp covers sort back to front.

The native XFS1/XFB5 oracle and software fallback remain. Photo mode still freezes
physics and renders actual 3840×2160 pixels; GPU readback verifies all 8,294,400
pixels. The software fallback has simpler light materials than the GPU path.

The authored scene remains below 512 KiB, uses at most 4,086 conservatively
budgeted input triangles, and retains the original one-million-step VM budget.
Terrain rows split into three columns to bound software raster work. Shared prop
meshes offset the new animal/bridge detail. GPU resolution continues to adapt to
the complete posted-frame cost. These controls limit per-frame work, not driving
space. Scene/window sizes stay constant as the car travels.

Validation includes the complete eight-sector road, reverse in all assistance
modes, the raised bridge, free movement beyond the old wall/end, support/geometry
agreement, analog steering, wind, streamed trunk collision, immutable XFG4 input,
60 manual poses / 2,880 physics ticks / exact software-frame comparisons, full
Android Java compilation and actual signed-APK Android 35 execution. The APK
workflow also checks proportional touch input, GPU frames/effects, photo readback
and Activity resume. Emulator results do not measure a physical phone. The visual
style remains simplified; these meshes are not photorealistic assets.
