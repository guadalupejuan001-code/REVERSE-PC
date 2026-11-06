# REVERSE VELOCITY 3.8: qSSD observation space

Version 3.8 starts from the released 3.7 CPU/GPU game, commit
`665742aa9310314242271ea51f9294d07a97b4c4`. It connects the qSSD repository's
immutable observation space to the actual XI → JNI → REgraphics → GPU-VIRTUAL
path. Original XI/Ether remains the authority for the world and physics.

## Running path

1. The physics writer validates and commits the original compact runtime.
2. The renderer retains one whole publication. Its registered XI program and
   complete view mailbox produce the original XFG4 observation.
3. `qssd::SharedProjection<std::string>` publishes that value with an identity
   and revision. Exact equality retains the same immutable value. Different
   source registrations reset its namespace. No hash authorizes equality.
4. JNI creates one explicit, VM-owned direct buffer and read-only view when
   a projection changes or its previous Java view has been collected. It copies
   the original bytes once and reports that cost as `materializedBytes`.
   Only a weak JNI reference is cached; retained Java/GPU views remain valid
   after the session closes. No native pointer outlives its allocation.
5. REgraphics validates the view. GPU-VIRTUAL reads it directly to construct
   its existing exact 24-byte vertex representation and dirty upload ranges.
   Repeated observations reuse the retained geometry and GPU data.

The production path does not encode XGD1 packets or reconstruct their complete
Java arrays. The 3.7 delta decoder remains available for regression comparison.
The physical projection, classification arrays, GPU buffers and driver memory
still consume storage. A direct buffer may use VM-managed internal storage;
this change does not imply zero heap usage or lower total process RAM.

Execution reuse additionally requires the same CPU publication, exact source,
complete mailbox and the original parser's deterministic-machine guarantee.
Quantum commands, unknown commands and programs outside the parse-cache budget
cannot bypass original XI execution. Reads do not commit RNG or world changes.

## Sources and preserved behavior

`QSSD_INTEGRATION_LOCK.json` pins the exact upstream qSSD header.
`GPU_VIRTUAL_INTEGRATION_LOCK.json` pins the shared GPU source. CI checks both
vendored files byte for byte against their published repositories.

All 20 game assets are identical to 3.7: world, physics, renderer programs,
textures, palettes and shaders. All five graphics levels, original passes and
alpha order, software fallback, camera, controls and bounded preparation queue
remain available. The package updates the same application with versionCode 40
and the established signing certificate.

## Evidence and measurement

`scripts/verify-velocity-qssd.py` builds the original 3.7 and candidate production
JNI libraries. Both replay the same 72 observations, 200 warm-up ticks, physics
updates, cameras, colors, reverse and nitro. Physics uses a dedicated thread,
as in Android. Every geometry byte, shader-state register, packed GPU vertex and
final RVPC2 checkpoint must match. It alternates three runs of each library and
records native, decode and packing costs, changed and repeated states separately.
Read-only enforcement and old-view validity after advancement, close and GC are
also checked. `velocity-qssd-guards.cpp` exercises invalidation and concurrent
publication coherence.

The Android workflow builds both ABIs, verifies 16 KB alignment, assets and
signer, upgrades the released 3.7 APK, exercises all five presets and alternates
three real driving trials per APK on the same Android 35 AVD. FPS counts completed
draws; physics rate, process PSS, projection bytes and bounded queue are recorded.
The AVD uses SwiftShader and does not establish performance on a physical phone.
Fewer reconstructions alone do not establish an FPS or RAM improvement. Reports
are published as workflow artifacts; unsuccessful results must remain visible.

This is a software state-sharing experiment. No physical quantum teleportation,
instantaneous communication, physical SSD or additional GPU hardware is claimed.
