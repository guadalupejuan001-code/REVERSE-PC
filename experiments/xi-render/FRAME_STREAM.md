# XI Frame Stream v1

XFS1 is an experimental, bounded binary command stream. XI Machine v1
computes visibility and per-row spans. The host adapter expands spans and
resolves depth; it does not calculate triangles or the world itself.

Wire format: 16-byte header (XFS1, version, width, height, revision);
14-byte SPAN commands (material, y, x0, x1, depth, revision);
8-byte END command (revision). Validate all bytes before publishing pixels.

Limits in this reference: 8192 pixels per dimension, 16,777,216 pixels,
1,000,000 commands, 32 MiB stream. Configurable budgets, not infinite RAM.
The next step is native XI block output to eliminate JSON intermediates.

The test runs real XI, validates three resolutions including HD and Full HD,
compares every pixel with the original EtherRenderEngine and rejects
out-of-range coordinates or inconsistent revisions.

## Optimized XFS1 compositor (experiment)

The XI geometry output is unchanged. The host now validates all spans,
groups them by scanline, paints far-to-near using contiguous Buffer.fill,
and preserves the first submitted span on an exact depth tie.
Depth 65535 remains the untouched background sentinel and is never painted.
Full-frame 16-bit depth allocation is avoided: a 720p framebuffer uses
921600 bytes of main pixel storage instead of 2764800 pixel+depth bytes,
excluding transient span descriptors. A single-pass XI-to-XFS1 encoder
also avoids the intermediate command list.

The frame-stream-profile.cjs test checks 200 overlapping scenes including
ties and sentinels, then measures pre/post composition and XI serialization
separately using warm Node processes. These are NOT end-to-end frame FPS.
