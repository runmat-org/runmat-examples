# House

A two-story, wood-framed single-family house on a 40 x 30 ft footprint with a 6:12 gable roof,
modeled as RunMat parts and assemblies in feet and inches.

This version holds the structure, the envelope, the interior and the MEP systems:

- `house_skeleton.part`: grid lines A-D and 1-5, the levels from the top of the footing to the ridge,
  the two roof planes, and a frame for every assembly and every window and door opening.
- `foundation/`: the perimeter footing and six pad footings with their reinforcement, the 8 in stem
  wall, and the slab on grade with its vapor retarder, sub-slab and edge insulation and gravel base.
- `framing/`: the exterior walls of both floors (2x6 studs at 16 in o.c., insulated headers), their
  OSB shear-wall sheathing, the second floor (I-joists, LVL beams, posts, the stair opening), and the
  roof trusses at 24 in o.c. with gable-end trusses.
- `+hardware/`: anchor bolts, hold-downs, joist hangers, truss ties and post bases.
- `envelope/`: the wall layers outside and inside the framing (three-coat stucco on metal lath, two
  layers of building paper, R-21 batts, a vapor retarder and gypsum), with a weep screed at the base
  and flashing at every opening; the gable cladding; the roof (shingles, underlayment, sheathing,
  ridge vent, fascia, vented soffits) with the second-floor ceiling, R-38 attic insulation and eave
  baffles; and the windows (W1 to W5) and doors (D1, D2) of the opening schedule at their openings.
- `interior/`: the partitions and stair guards, interior doors, the stair, the floor finishes and the
  first-floor ceiling, the kitchen cabinets and vanities (plywood carcasses with toe kicks), and the
  bath fixtures: a living room, dining area, kitchen, den and utility room downstairs, and three
  bedrooms and two baths upstairs.
- `mep/`: the electrical, plumbing and HVAC systems. `electrical/service.circuit` is the one-line
  from the meter to the 200 A panel with the panel schedule; `electrical/branch_circuits.circuit`
  draws each branch circuit's wiring (schematic only, from the device library in
  `electrical/library/devices.circuit`); `electrical/electrical.assembly` places the meter, panel,
  boxes, devices and luminaires and routes cables through bored joists, beams and plates. Every run
  is swept along its centerline, with the profile following the path through the bends.
  `plumbing/supply.assembly` holds the water heater, PEX manifold and the hot and cold runs to the
  kitchen, the laundry and every second-floor bath fixture; `plumbing/dwv.assembly` the bath drain
  branches, the 3 in stack in its first-floor chase, the building drain under the slab, the kitchen
  sink drain and the vents through the roof; `hvac/hvac.assembly` the air handler, plenum, soffit
  trunk, the riser and attic trunk to the second-floor registers, the first-floor return, the condenser and the
  line set.
- `simulation/`: the FEA studies. `wall_thermal.fea` is a steady heat-conduction study of the
  exterior wall in winter (21 °C inside, -10 °C outside). It gives the heat flux and U-factor
  through a stud bay and shows the stud as a thermal bridge. Its geometry is a section through
  the wall's layers, `wall_section.part`, placed by `wall_thermal.assembly` and exported to
  `geometry/wall_thermal.step`.
- `house.assembly`: the entry; it places the foundation, framing, envelope, interior and MEP on the skeleton.

`DESIGN-NOTES.md` gives the design loads, the load path, the sizing of the footings, framing,
headers and shear walls, and the opening schedule. It also gives the reason for each envelope layer,
the wall and ceiling R-values, the window U-factors, the floor plan room by room, the stair
geometry, and the MEP sizing: the service load calculation, the panel schedule with wire gauges,
pipe sizes and fixture units, and the duct sizes.

Open `house.assembly` and use Section to cut through a wall, the roof or the foundation. Open
`mep/electrical/branch_circuits.circuit` for the wiring diagrams. Plumbing is routed to every
fixture. The HVAC supply reaches the utility room, the den and the second-floor bedrooms, baths and
closet; the first-floor living, dining and kitchen branches and the second-floor return are not
routed yet. The routed cables cover the utility room, the den and the kitchen's north
wall so far; the other branch circuits are drawn in the circuit file but not yet routed. The
drawings are not built yet.

## Run the wall study

Open `simulation/wall_thermal.fea` from the Files tree and run the study `wall_heat_loss`. It
plots the temperature through the wall, with the cold line over the stud, and reports the heat
through the room face and the temperature at each layer boundary. From a terminal, run
`runmat run simulation/wall_thermal.fea` in the project folder. To compare other layer choices,
edit a material's conductivity, or change `wall_section.part` and re-export
`wall_thermal.assembly` to `simulation/geometry/wall_thermal.step`. `DESIGN-NOTES.md`, "Studies",
gives the results and the hand check.
