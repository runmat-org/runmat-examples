# Design notes

Lengths are in millimeters. Aircraft axes: x runs aft from the nose tip, y to starboard, z up.

## Overall

- Length 38.0 m, span 34.8 m over the winglets, height 12.3 m from the tires to the fin tip.
- The skeleton part (`airliner_skeleton.part`) holds the main sizes as inputs: span 34,000, root chord 6,400, tip chord 1,550, fuselage radius 1,980, frame pitch 500 and rib pitch 650. It publishes one frame per major assembly (fuselage, wing root, tail, both main gear legs and the nose gear).

## Fuselage

- A 1,980 radius barrel in three 8,000 sections, behind a 5,200 nose. An 8,800 tail cone follows.
- Each section has frames at the 500 frame pitch, 24 stringers and 8 skin panels round the circumference, a ring of flush rivets on every frame (one per stringer), and a cabin window in each frame bay on both sides.
- The nose is lofted through elliptical sections and is tangent to the barrel. It has openings for six cockpit panes. Each pane is 15 to 20 thick and sits 1 inside the skin's outer surface, so no pane face lies on a skin face.
- The tail cone is a 5 skin, open at the barrel joint and at the APU exhaust.
- The aft pressure bulkhead is a 4 spherical dome, convex aft and 800 deep, at x = 29,900 behind the aft galleys.

## Cabin and flight deck

- The floor top is 400 below the fuselage axis. Floor beams are 150 deep, one at every frame, under 10 floor panels and four seat tracks.
- Business class has 3 rows at a 940 pitch from x = 6,000, in doubles. Economy has 9 rows forward of the overwing exits from x = 8,900 and 13 rows aft from x = 17,200, at a 790 pitch, in triples (3+3).
- Passenger doors are 820 × 1,850 at x = 5,250 and 28,100, and overwing exits are 510 × 920 at x = 16,300, on both sides. Cabin windows and bins that a door covers are left out of their patterns.
- Galleys and lavatories stand at both ends of the cabin. The flight deck has two pilot seats, control columns, the instrument panel, glareshield, pedestal and overhead panel.

## Wing

- Leading-edge sweep 27°, dihedral 5.5°, semispan 17,000. The structural root station is 1,400 from the centerline.
- Cambered NACA sections, thickness 14.5 % of chord at the root and 10.5 % at the tip.
- The wing box runs between the front spar at 15 % chord and the rear spar at 65 % chord. Its skins are 4 thick, and its spar webs are 30 thick.
- Ribs are 20 thick at the 650 rib pitch. Each rib takes its station's chord and its depth over that chord as inputs, so one rib file serves every station. The depth runs linearly between the root and tip sections, matching the straight-lofted skins.
- Rivet rows run along the four spar caps at a 150 rivet pitch.
- The slat runs from the engine to the tip. The flaps (inboard and outboard), aileron and fixed trailing edge are aft of the rear spar.
- The engine hangs from a pylon at y = 5,800.

## Empennage

- The fin uses NACA 0011 sections, swept 38°, 6,500 tall. The rudder hinges at 70 % chord.
- The stabilizers use NACA 0010 sections, swept 33° with 7° dihedral and a 5,900 span each. The elevators hinge at 70 % chord.
- The fixed fin and stabilizers are 3 skins round a hollow box with end ribs. The rudder and elevators are solid.

## Handed parts

A part with a left and a right hand is one file, built to starboard, with a `side` input of 1. With `side = -1`, every coordinate that crosses the center plane changes sign, and the file builds the port hand. A mirror about y = 0 places that hand. The ribs and the engine are symmetric in their own frames, so their mirrors reuse them as they are.

## 2026-11-10: Cockpit display unit: a case and a controller board

- **Requirement.** Each display unit needs a controller that runs from the 28 V DC aircraft bus, drives the screen's LED backlight and dims it from the panel's dimming input, and fits inside the unit.
- **Case.** `display_unit.part` keeps the 200 mm screen 8 mm proud of the panel face and adds a 6061 case behind it, 190 mm square and 110 mm deep, 2.5 mm walls, with four M3 bosses 7.5 mm tall on its back. `instrument_panel.part` has a 192 mm pocket through it for each case, 1 mm clear all round, so the avionics cooling air forward of the panel reaches the case's back.
- **Board.** `electrical/display_unit/du_controller`, 120 × 100 mm, four layers (signal, ground, 3.3 V, signal), on the bosses at x = −100 mm with its components toward the screen. `cockpit.assembly` places one in each of the six units.
- **Input protection.** A 2 A slow-blow fuse, a 60 V 2 A series Schottky against a reversed bus, and a 33 V stand-off TVS (53 V clamp) across the protected rail. The 28 V bus's normal range is 22–29 V with surges to 50 V, so everything on the protected rail is rated 60 V: a 36 V buck would not survive a surge.
- **Rails.** 5 V from a 60 V 2 A buck (feedback 52.3 k / 10 k on a 0.8 V reference: 4.98 V) for the panel's timing controller and the LDO; 3.3 V from an LDO for the MCU. The bus voltage is read through a 200 k / 10 k divider: 29.5 V reads 1.40 V at the ADC.
- **Backlight.** Six strings of eleven white LEDs at 60 mA (ISET 20 kΩ: 1,200 / 20 k = 60 mA). Eleven LEDs at 2.9–3.2 V make 31.9–35.2 V, above the bus's 29.5 V top, so the boost driver always boosts. OVP is 1.2 V × (1 + 330 k / 10 k) = 40.8 V. The output capacitors are 2.2 µF 100 V parts: at the 34 V working point they run at 34 % of rating. The strings take 12.3 W.
- **Connectors.** J1 (5-way) from the case's circular connector: 28 V, return, dimming (0–5 V, halved into the ADC), the ground/open on discrete (pulled up at the MCU, 22 kΩ in series from the pin) and signal ground. J2 (6-way) to the panel's timing controller: 5 V, ground and SPI. J3 (8-way) to the backlight: the strings' anode on two pins (0.36 A) and the six cathodes.
- **Thermal.** The components' `power` is the board's power map: 2.65 W, most of it the backlight driver (1.10 W) and the input Schottky (0.35 W) and buck (0.35 W). `simulation/du_thermal.fea` takes it to the case's back.

## 2026-11-11: Display unit board layout: panel select and enable moved to the MCU's top side

- **Problem.** With the panel header J2 on the board's top edge, 45 mm above the MCU, the panel's chip select and enable left the MCU from pins 14 (PA4) and 18 (PB0) on its bottom side. Both had to cross the SPI pair and the decoupling around the MCU, and two layout tries left them unrouted.
- **Change.** In `du_controller.circuit`, PANEL_CS moved to PB4 (pin 40) and PANEL_EN to PB3 (pin 39), on the MCU's top side, in the same left-to-right order as J2.5 and J2.6. Both are plain outputs, so any free GPIO serves. PB3 and PB4 are free because the MCU is programmed over the two-wire debug port (PA13, PA14), which stays free.
- **Evidence.** `du_controller.circuit.layout`: every net routed on four layers, with 0.1 mm track and clearance and 0.45 / 0.2 mm vias. The schematic check reports no errors (ERC 0) and the board check no violations (DRC 0).
- **Result.** The board is complete: J1 and the protection on the left, the regulators along the top left, the MCU in the middle, the backlight driver by J3 on the right and J2 on the top edge.

## 2026-11-10: Cabin reading-light driver

- **Requirement.** Each seat row's three reading lights need a constant current from the 28 V DC cabin bus, so their brightness doesn't change over the bus's 22–29 V, and a dimming input from the passenger service unit.
- **Board.** `electrical/reading_light/reading_light`, 60 × 30 mm, two layers. `cabin.assembly` places it above the ceiling panel at the crown, in the frame bay over the second economy row (x = 9,450 mm), 7 mm above the panel's top and clear of the stringer above it.
- **Current.** The row's three lights run as one series string, 3 × 3.1 V = 9.3 V at 333 mA, about 3.1 W. A 60 V hysteretic step-down driver holds the 100 mV across a 0.30 Ω high-side sense resistor: 0.1 / 0.30 = 333 mA, dissipating 33 mW in the 0.25 W resistor. One string per row needs one driver and one sense resistor, where three parallel lights would need one each to share the current.
- **Protection.** As on the display unit: a fuse (0.5 A here: the board draws 0.16 A at 22 V), a 60 V series Schottky and a 33 V TVS, with every part on the protected rail rated 60 V.
- **Dimming.** The unit's 5 V PWM drives the ADJ pin through 1 kΩ; 100 kΩ to ground holds the light off when the line is open.
- **Thermal.** The board dissipates about 0.4 W (driver 0.15 W, catch diode 0.10 W, series diode 0.08 W, inductor and sense resistor). Spread over the 60 × 30 mm board in the ceiling's still air (about 10 W/m²/K both sides), that is roughly 11 K over the cabin air, so no thermal study was made for it.
- **Connectors.** J1 (4-way): 28 V, return, dimming PWM, signal ground. J2 (2-way): the string's anode and cathode.

## 2026-11-10: Drawings

- `drawings/gear_strut.drawing` (A3, 1:15): the strut's elevation with its 2,500 length and the bore's 2,300 depth, the plan with the outside diameter (datum A), section A-A across the tube with the bore's diameter and its position to A from the part's PMI, and an isometric.
- `drawings/window_frame.drawing` (A3, 1:2): the frame's 310 × 330 outside and 230 × 250 opening, the R80 corner, the 12 fastener holes, section A-A through the lower hole row with the 8 thickness, and an isometric.
- `drawings/display_unit.drawing` (A3, 1:2): the installed display unit's side elevation, section A-A through the case on the center plane (`origin.xy`) showing the bosses and the board, an isometric, balloons and the parts list.
- `drawings/airliner.drawing` (A2, 1:200): the general arrangement: the side elevation, the plan and the front view, balloons on the top-level assemblies and a top-level parts list (the skeleton, the fuselage, wing and empennage, two main gear legs and the nose gear). The overall sizes are in the notes.

## 2026-11-10: Study results

| Study | Hand check | Solved |
|---|---|---|
| `main_gear_landing.fea` | 330 MPa at the tube's root, 29 mm at the axle | 325.5 MPa peak von Mises, 27.6 mm peak displacement; below the 1,586 MPa yield |
| `window_cutout.fea` | 39.1 MPa hoop away from the window, about 100 MPa at the corners | Hand estimate; solve pending |
| `bulkhead_dome.fea` | 30.9 MPa membrane, about 50 MPa at the rim | Hand estimate; solve pending |
| `du_thermal.fea` | Board peak about 48 °C | 56.4 °C peak on the board, 40.8 °C at the screen's face (solved 2026-11-11, 6 mm mesh); 28.6 K below the parts' 85 °C rating. The hand check's single spreading path to the bosses reads 8 K low. |

The study geometry selects the exported product names. A configured part carries its values in its name, as `gear_strut (bore 90 mm, length 2500 mm, radius 115 mm)`.
