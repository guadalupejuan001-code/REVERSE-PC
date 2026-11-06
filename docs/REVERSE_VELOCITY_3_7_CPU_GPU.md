# Reverse Velocity 3.7 — coordinated compact CPU/GPU work

The five 3.6 graphics levels and all scene assets/shaders are retained. This
change reduces preparation, transport and repeated geometry work at the same
quality, rather than lowering the render target to manufacture a speedup.

## Ownership and publication

XI/Ether remains the sole world/physics/geometry authority. A read-only observer
forks the original compact authorities once and never publishes its temporary
work. Physics still commits its own validated transactions at 50 Hz. Register
destinations use the existing immutable decoded operands; lazy errors, bounds,
overflow and instruction budgets remain enforced.

One bounded XI program is registered natively once per game session. Subsequent
frames send the nine view/input bytes and addresses, not the entire roughly
486 KB program again. The native interpreter and source checks remain intact.

The geometry channel retains one original XFG4 frame. XGD1 carries its coherent
state output/publication plus a strict serial and base serial, then either the
full frame, an exact 32-bit-word change mask/payload, or a retained-frame marker.
No approximate hashes, quantization or equality tolerances decide reuse.

CPU execution itself is reused only for the same immutable publication, exact
source and full input mailbox, and only when the decoded program contains the
known deterministic machine subset. Unknown commands, gates/batches and quantum
observations cannot authorize this shortcut. A view/source/publication change
invalidates it. The original RVPC2 checkpoint format is unchanged.

Java reconstructs and validates original XFG4 bytes. No-change frames retain
the same immutable array/geometry metadata. The GPU keeps the shared exact
CompactTriangleStream and its resident VBO; the same geometry object does not
need reconversion or another vertex upload. Context loss invalidates GPU
residency and forces a full upload. Shader uniforms/palette/profile filtering
continue to update independently of geometry residency.

## Bounded overlap

One worker can prepare one immutable next observation while the GPU presents
the current frame. There is at most one pending CPU job; there is no growing
GPU queue. View/profile/pause/backend changes discard the prepared view. Lifecycle
replacement workers serialize the native delta + Java base without blocking
the independent physics writer. The idle old renderer's parsed scratch is
released when work moves to the preparation worker.

Known CPU rasterizers (SwiftShader, llvmpipe and softpipe) use the serial path:
their presentation and XI preparation compete for CPU resources. Physical GPU
drivers keep bounded overlap. Both paths use the same retained program, exact
delta protocol and geometry residency. Delta reconstruction copies contiguous
changed-word runs instead of making a separate array-copy call for every word.
Registration preserves the original 16 MiB source budget; the smaller parsed
instruction cache is an optional optimization, never a new program-size limit.

FPS still counts only requests acknowledged after the actual GLSurfaceView
swap. Preparation timings overlap presentation and are marked `cpuOverlap`;
they must not be added as if they were sequential. One future observation,
one retained native frame and a bounded native program are the memory tradeoff.

## Validation and limits

The host comparison pins the original 3.6 source at
`8389252a9014bdf2e46c7230289ead7a3d672984`, executes the same moving/view/car/effect
trace, and checks 72 complete geometry packets, every shader-state observation
and the final RVPC2 checkpoint byte for byte. Changed and unchanged publication
timings are reported separately. Native-encoded deltas are decoded by production
Java, including malformed/stale/missing-base rejection and immutable old frames.
Worker tests check overlap, one-frame bounds, invalidation and error propagation.
Existing physics, geometry, material/image and all-five-level UI tests remain.

Android A/B uses the signed 3.6 and 3.7 APKs on the same emulator, three rounds
in alternating order, with the same Medio effects and actual 960×540 target,
real manual acceleration and completed swaps. It records FPS, stage timings,
physics Hz, transport and process PSS. These free-running trials are not an
identical-pose replay or a physical Mali-G68/thermal/battery certification.
Energy use and phone FPS need measurements on the physical device.
