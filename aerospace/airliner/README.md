# Narrow-body airliner

A generic 38 m twin-engine narrow-body airliner, built from `.part` and `.assembly` files: the outer structure, the cabin, the flight deck and the cargo holds. It resolves to about 3,200 part occurrences. Two circuit boards sit in it, a cockpit display unit's controller and a cabin reading-light driver, four FEA studies check a window cutout, the aft pressure bulkhead, a main gear strut and the display unit's board temperature, and four drawings document the strut, the window frame, the display unit and the whole aircraft.

## Open it

Open the folder in RunMat Desktop, or open the example in the browser sandbox. `airliner.assembly` opens first, on its saved hero view. The Outline lists the major assemblies. Each one opens to its parts, and each pattern is one row (`rivet × 23`) until you expand it.

## The tree

| Path | What it holds |
|---|---|
| `airliner.assembly` | The top assembly. It places each major assembly on a frame of the skeleton. |
| `airliner_skeleton.part` | The main sizes (span, chords, fuselage radius, frame and rib pitch), and the frames the assemblies attach to. |
| `fuselage/` | The drooped nose and its cockpit panes, three barrel sections, the tail cone, the aft pressure bulkhead and the wing-to-body fairing. Each barrel section holds frames, stringers, skin panels, rivet rings and cabin windows. |
| `wing/` | Both wings in one assembly: slat and leading edge, box skins, spars, ribs, flaps, aileron, winglet, rivet rows and the engine. |
| `empennage/` | The fin and rudder, and the stabilizers and elevators. |
| `engine/` | The nacelle: cowl, fan, spinner, core nozzle, plug and pylon. |
| `landing_gear/` | The main and nose gear legs: strut, axle, hubs and tires. |
| `cabin/` | The floor, sidewall linings, ceiling, overhead bins, seat rows, galleys, lavatories and passenger doors. |
| `cockpit/` | The flight deck: floor, bulkhead, instrument panel, glareshield, pedestal, overhead panel, pilot seats and lining. |
| `cargo/` | The forward and aft holds, their containers, liners and doors, the center wing box and the main gear bays. |
| `+hardware/` | The flush rivet. Every folder places it with `use part rivet from hardware`. |
| `electrical/display_unit/` | The cockpit display unit's controller board: schematic (`.circuit`), four-layer board (`.circuit.layout`) and lock file. `cockpit.assembly` places one in each display unit's case. |
| `electrical/reading_light/` | The cabin reading-light driver: schematic, two-layer board and lock file. `cabin.assembly` places it above the ceiling panel. |
| `simulation/` | The FEA studies and the study geometry they export their STEP files from (see below). |
| `drawings/` | Four drawings: the main gear strut and the cabin window frame (detail drawings), the installed display unit with its board (balloons and a parts list), and the airliner's general arrangement. |

Files in the same folder name each other directly (`use part frame as frame`). A file names a design in another folder with `from` (`use part seat_frame from "../cabin" as seat`).

## How the port side is built

Each part that has a left and a right hand is one file, built to starboard. Examples are the wing pieces, the stabilizer, the cockpit panes and the doors. Its `side` input set to -1 builds the port hand. A `mirror` in the assembly places that port hand as the starboard part's mirror image about the center plane. For example, `empennage.assembly` holds `stabilizer_starboard` and a mirror `stabilizer_port`.

Rows use patterns: frames at the frame pitch, stringers and skin panels round the barrel, seat rows at their pitch, windows, bins and rivet rows.

## Things to try

- Run Section view on the center plane (y = 0) to see the seat rows, galleys, holds and the wing box.
- Run Section view across the cabin, at about x = 22 m, to see a 3+3 economy row, the bins, the floor and a container in the aft hold.
- Change `frame_pitch` or `rib_pitch` on the skeleton and on the assemblies to change the frame or rib spacing.
- Ask the Agent to add two economy rows and shorten the seat pitch to 760 mm.
- Raise the pressure in `simulation/window_cutout.fea` to the safety valve's 62 kPa and re-run it.
- Change a component's `power` in `du_controller.circuit`, update the heat in `simulation/du_thermal.fea` to match, and re-run it.

## The boards

- **Display unit controller** (`du_controller`, 120 × 100 mm, four layers). It takes the 28 V aircraft bus through a fuse, a series Schottky and a 33 V TVS, makes 5 V with a 60 V buck and 3.3 V with an LDO, and drives the screen's backlight, six strings of eleven LEDs at 60 mA, with a six-channel boost driver. An MCU reads the panel dimming input and the on discrete and sets the backlight's PWM. Each component's `power` is the board's power map, which the thermal study reads.
- **Reading-light driver** (`reading_light`, 60 × 30 mm, two layers). It takes the 28 V cabin bus through the same protection and drives a seat row's three reading lights in series at 333 mA with a 60 V step-down LED driver. A 5 V PWM from the passenger service unit dims it.

Both boards pass ERC and DRC with every connection routed (`runmat-design check`). Open a board to see the schematic and the layout, and the cockpit or the cabin assembly to see it in place.

## The studies

| Study | What it shows |
|---|---|
| `simulation/window_cutout.fea` | A cabin window's skin cutout and frame at the 59.3 kPa (8.6 psi) maximum cabin pressure differential: the hoop and axial skin stress and the peak at the cutout's corners, against yield. |
| `simulation/bulkhead_dome.fea` | A 10° sector of the aft pressure bulkhead at ultimate pressure, 1.5 × 59.3 kPa = 89.0 kPa: the dome's membrane stress and the bending at its fixed rim, against the tensile strength. |
| `simulation/main_gear_landing.fea` | A main gear strut in a level landing at the 3.05 m/s limit sink rate with spin-up drag, 397 kN up and 99 kN aft at the axle: the bending at the trunnion and the axle's deflection. |
| `simulation/du_thermal.fea` | The display unit's controller board at full backlight, 2.65 W from the board's power map, cooled through the case's bosses and back: the board's and the case's peak temperatures. |

Each study's header gives its loads, their sources and a hand check. The `.assembly` and `.part` files beside them make the study geometry, and `simulation/geometry/` holds the STEP exported from them.

DESIGN-NOTES.md has the dimensions and the engineering choices behind the model.
