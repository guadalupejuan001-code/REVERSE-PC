# C04: rework using the original QSSD component

Base C03 cb7903bd596f1f0c382d3ba880e47086dfc37014 is preserved, not merged.
QSSD original component plus additive C07 API is pinned to
376b1334dd2dde6093a2988ee12325590941573d (QSSD PR #5, not main).
GPU-VIRTUAL C12 4cdd47f487cfadbca559dd8c2f5abc0448cd77a7 is unchanged.

REgraphics/XI -> original native SharedProjection and StateBus scene graph
-> GraphicsPort in the QSSD component -> JNI projection -> original XFG4
compact vertex transport -> OpenGL ES -> physical GPU.

VelocityQssdGraphicsBridge is now a thin JNI adapter, not an independent Java
resource manager. Native QSSD owns resource revisions, atlas layout, delta
plans and device-upload receipts. Geometry source data stays in the original
XI state graph; the component retains the complete native lease identity.
Explicit host API projections remain necessary and are not claimed as zero IO.

CPU-produced material descriptors -> original Space::publish_field -> original
bind/route/acquire CPU/SSD/GPU ports -> existing C12Window -> original C12 output
-> GLSL uniforms. Exact source-pointer sharing is checked. The QSSD controller
and material kernel persist per host worker; identical inputs reuse validated
output. Changed inputs still run C12's host CPU interpreter. No physical GPU
compute or Bell transfer is implied.

An unchanged atlas is not allocated/reordered just because geometry moved.
An unchanged palette no longer causes a 512-int scratch allocation. Derived
palette output is cached by exact phase. Adjacent atlas rows share one API
upload. Failed transfers invalidate both native physical residency and compact
vertex staging. API acceptance is not GPU execution completion.

Local retained-source CTest: 7/7 passed, including original StateBus,
SharedProjection, Space, C12 integration, native graphics, imported fields and
240 real material cases plus cache checks. JNI/JVM testing executes the actual
native QSSD library. Full CI and installed-Android results remain separate gates.
No FPS improvement is claimed without controlled physical-device measurement.

The reviewed one-time migration persists tested source edits on this isolated
branch. It does not merge either PR or change historical checkpoints.
C04 uses com.reversepc.velocity.c04, version 46 / 4.0.0-c04-native-qssd. It does
not impersonate the private signing identity of C03 or the original app.
