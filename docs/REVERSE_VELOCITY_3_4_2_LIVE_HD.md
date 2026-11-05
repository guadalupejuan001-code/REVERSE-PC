# Reverse Velocity 3.4.2: compact live XI and HD visibility

The 3.4.1 Android run failed at the physical reverse check. Its logs actually
showed reverse engaging and 86 cm of movement: slow physics and a short pedal
hold never reached the required metre. Moving frames still cost roughly
100–150 ms of XI preparation plus 400 ms of GPU presentation on SwiftShader.

The live path now retains QuantumRuntime and its original compact InverseMemory
between transactions. It stages the same XI program, validates the register
observation in Java, then commits atomically. Renderers retain a coherent native
publication and observe a private candidate. RVPC2 remains the exact checkpoint
format; no dense state, replacement physics or Java-generated geometry is used.
The generic bounded input mailbox writes view bytes within the XI transaction,
avoiding a second text snapshot/restore solely to set camera controls.

REgraphics resolves opaque depth before running its material shader. Hidden
terrain and sky pixels skip material work. Vertex position is invariant between
the depth and color programs. All car materials, triangles, transparent lights,
nitro, water and native 1280×720 driving / 3840×2160 photography are retained.

The reverse test uses a longer real touch while retaining its >1 metre threshold
and posted-frame evidence. Native tests compare 90 physical ticks, exact RVPC2
checkpoints, original XFG4 bytes, rollback, rejected candidates and 500 concurrent
observations. Same-machine host measurements: tick median 19.60→1.44 ms;
geometry median 34.60→12.95 ms. A host Mesa HD frame remained pixel-identical
with the depth prepass. These are host measurements, not physical-phone FPS.

The Android APK smoke and alternating before/after APK performance comparison
remain required before declaring the release validated. Results are stored in
CI evidence, including actual frame counts, elapsed nanoseconds, physics rate,
1280×720 pixel readback hashes, reverse movement and lifecycle checks.
