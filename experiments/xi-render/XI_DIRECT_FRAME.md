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
