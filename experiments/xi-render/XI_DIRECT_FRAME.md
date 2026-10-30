# Direct XI binary Frame Stream

Geometry, raster rules and occlusion remain inside the original
\`span-frame.xi\` equations. The experimental \`span-direct.xi\`
changes only their transport:
- \`xframe width height revision\`: begin a binary XFS1 frame.
- \`xspan y x0 x1 material depth\`: append one bounded span.
- \`xend\`: close with the same revision.

These are append-only XI/RXE instructions in the existing runtime. The
host does not compute any geometry; these native instructions perform
only validated binary serialization and do not add a new renderer.

The original XI and RXE instructions retain their exact prior indexes.
Mixed binary/text, invalid spans, repeated frames, incomplete commands
and out-of-range resources are rejected transactionally without
publishing a partial frame or mutating the user's Ether/RVPC2 state.

This code is experimental until CI proves byte-for-byte equivalence
with the legacy XI JSON->XFS1 output and native X Render framebuffer.

## Persistent XI Frame Stream (optional host transport)

The original \`reverse_pc\` now exposes a bounded opt-in
\`frame-serve PROGRAM.xi|APP.rxe STATE_INPUT.rvp\` command.

- Send byte \`U\` followed by exactly 18 viewport/curve/phase bytes.
  These bytes enter the original XI InverseMemory through one
  transactional XI Machine v1 \`store8\` program. The service replies
  with a four-byte little-endian zero length.
- Send byte \`F\` to execute the original XI geometry and emit a
  four-byte length followed by the validated binary XFS1 frame.
- Send byte \`Q\` or close stdin to end the service.

The runtime, RXE instruction image and state are loaded once. Render
requests never save RVPC2 to disk; a before/after canonical snapshot
check rejects any frame source that attempts to mutate state. A failed
frame cannot publish a partial output. User geometry still executes
solely in XI; C++ is the mailbox and transport adapter only.

\`frame-serve-test.cjs\` compares static and changing phase/curvature
frames with the one-shot original XI executor at 720p, 1080p and 4K;
measures both paths including the same RGB materializer, and confirms
the original RVPC2 input file remains unchanged. These are host timings
and not Android presentation FPS.
