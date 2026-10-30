# Super road Frame Stream directly from XI

\`super-road-direct.xi\` executes the original SUPER RENDER XI curved-road
equations and emits one binary XFS1 frame for the full viewport. It
preserves horizon, road center, curve, shoulders, lane stripes, center
dashes, and 12-band lighting/fog as XI-authored material codes.

Material codes are transport IDs, not additional geometry calculated
by the presenter:
- 0..12: sky plus the XI-owned shade.
- 16..28: terrain plus the XI-owned distance shade.
- 32: shoulder, 48: road, 64: roadside lines, 80: centerline.

The only host job is applying the same pre-existing material palette
and painting the visible spans in depth order. The XFS1 materializer
accepts bounded material IDs 0..95 for this profile; original binary
triangle scenes and legacy ABI tests continue unchanged.

\`super-road-direct-test.cjs\` compares RGB bytes against the original
\`super-render.xi\` output, running the legacy path in the same
row-window transactions used by the previous SUPER RENDER tests.
It measures 360p, HD, Full HD and 4K; the new path uses one
transaction when the full frame fits the bounded XFS1 budget.

This is still a procedural road/landscape demonstration and host
materializer, not a Forza-scale AAA renderer or Android GPU benchmark.
Larger logical worlds and resolutions remain possible through
smaller frame windows, but not unbounded RAM or output size.
