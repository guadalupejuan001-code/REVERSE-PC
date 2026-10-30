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
