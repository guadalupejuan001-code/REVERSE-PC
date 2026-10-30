# XI Direct Frame Stream

The new XI Machine instructions `framebegin width height revision`,
`framespan y x0 x1 material depth` and `frameend` write the XFS1
wire format directly into the program output. No JSON records or external
geometry algorithms are used in this route.

The interpreter buffers a complete frame and rejects malformed dimensions,
materials, depth, coordinates and transport overflows before publication.
State persistence follows the existing transactional execution contract.
The host still presents the resulting framebuffer; this is not yet a GPU
backend nor an Android FPS claim.

`span-direct.xi` computes the same spans as `span-frame.xi` but emits
binary XFS1 instructions. CI compares every byte of the new stream against
the former XI JSON-to-XFS1 reference at 96x48, 720p and 1080p, verifies
image equivalence and tests invalid-span rollback.
