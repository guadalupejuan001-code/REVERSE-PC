# Reverse Velocity 3.4 — Trails & Horizons HD

## World and navigation

Four joined dirt routes add 1,597.7 m beyond the original 1.6 km asphalt road:
Mirador del Alba, Sendero del Río, Pinar de las Rocas and Ribera de los Cedros.
Each rejoins the asphalt. Six places appear on a local minimap and the larger
atlas. The larger map rotates north to the right to fit a landscape phone;
the minimap stays north up and follows the actual XI car position and heading.
Place buttons select a destination with straight-line bearing and distance.
This is a landmark waypoint, not turn-by-turn route planning or teleportation.

The atlas and XI physical trail footprint come from the same authoring graph.
The graph uses 146 packed segments; terrain-conforming display geometry uses
586 triangles clipped to the ground cells. Mitered joins close the gaps at
corners. Independent barycentric checks cover the interiors and edges, keeping
the road decal 2.3–5.7 cm over the physical ground. The render window includes
all nearby pieces (102 at the densest tested sample, with capacity for 112).
The finite vegetation-clearance mask is shared by rendering and collision.

## Landscape and vehicle support

The road runs through a valley with traversable side slopes rising up to 18 m.
Ground support and visible ground use the same piecewise planar surface.
Global forest cells and grass root on that surface. Two continuous mountain
ridge layers replace the old isolated skyline cones; six physical signposts
help mark the places. Open terrain continues outside the authored route area.

XI samples the field on both sides and ahead/behind the car. The resulting
support frame tilts wheels, chassis, lights and effect ports with the slopes,
while the existing load-transfer springs remain. Raised bridge support retains
its own road gradient. Full 16-bit skid elevations use sidecar slots 960–967;
the previous single-byte field could not represent the new hills safely.

## Real HD and render cost

HD 720p is the default GPU profile: an actual 1280×720 framebuffer, with aspect
preserved during display. One complete 921,600-pixel readback and SHA-256 prove
the target on Android. It does not upscale a 320×160 image and call it HD.
The optional Fluido mode adjusts resolution using GPU presentation cost, rather
than reacting to the CPU time needed to prepare XI geometry. Photo 4K remains
an optional frozen frame. The software fallback retains its smaller raster.

The shader uses a cheaper spatial hash and gentler edge filtering. Dirt has
paired tire ruts and softened grass margins. Binary dispatch replaces repeated
linear scans for world objects and material groups. Generated internal symbols
are shortened without changing the XI instructions they branch to.
100 forest cells, 36 close grass clumps and distance LOD keep work bounded.
The conservative maximum remains 4,078 input triangles, inside the existing
4,096 bound, and the one-million-step VM budget is unchanged. These are render
budgets; they do not create a wall around the player.

## Driving and evidence

The new driver executes Manual mode using proportional steering, accelerator
and brake inputs. It starts each route at its entrance and never writes the
car position again. All four exits were reached in 12,043 physical ticks with
zero collisions. Hill routes reached 11.97 m and 15.70 m of support elevation.
CSV input/position traces and real XI GPU packets are retained as evidence.
This is automated driving of the real engine, not subjective human play.

The Android workflow additionally operates the installed APK with real keyboard
and touch input, turns the car in Manual, opens the atlas and chooses a place,
records driving, checks HD pixels, nitro, air, reverse, 4K readback and lifecycle.
The complete road, independent terrain-footprint tests, native/reference raster
equivalence, wildlife visibility and immutable geometry checks are retained.
Device FPS must be read from the resulting report; emulator values do not
establish Samsung Galaxy A16 performance.

## Reference comparison

Official references used to compare design goals:

- Forza Horizon 5, Explore the Horizon: marked exploration trails, destinations
  and scenic photo opportunities. https://forza.net/news/forza-horizon-5-explore-the-horizon
- Expeditions: A MudRunner Game, gameplay overview: terrain obstacles and route
  decisions give the landscape a driving purpose. https://www.focus-entmt.com/en/news/expeditions-a-mudrunner-game-gets-a-gameplay-overview-trailer-with-extensive-details-about-its-new-take-on-off-road-adventure

This release applies connected trails, an atlas, a lookout and surface-aware
vehicle presentation. It does not claim the commercial games' vegetation
assets, tire/soil deformation, simulation fidelity, visual density or measured
performance. Those games were not executed in this environment. The geometry
remains stylized; the next large visual gain requires richer vegetation meshes,
better terrain material blending and more distinct authored landmarks.
