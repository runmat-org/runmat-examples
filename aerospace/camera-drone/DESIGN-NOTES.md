# Camera drone: design notes

A dated log of the drone's engineering decisions: the requirement, what each analysis showed,
what changed and the margin that resulted. Hand checks are labelled "hand estimate". A result
from a study or simulation in this folder is labelled "solved". An entry whose study has not run
yet reads "solve pending" and is updated when the result lands.

## 2026-11-10: ESC component power for the board thermal study

- **Requirement.** A board thermal study reads each component's power from the circuit, so the
  losses land on the parts that make them. The ESC's circuit had no power on any part, so the
  board's power map was empty and `esc_thermal.fea` spread 7.8 W evenly over a plate.
- **Change.** `electrical/esc/esc.circuit`, sheet `channel`: `power` on the six bridge FETs and
  the three current shunts of each channel.
  - FETs: 0.24 W each. Per channel at 20 A, the two conducting FETs lose 20² × 1.6 mΩ × 2 =
    1.28 W in conduction, and switching adds 0.5 × 22.2 V × 20 A × (7 ns + 7 ns) × 48 kHz =
    0.15 W. Each FET conducts for a third of the electrical cycle, so the 1.43 W shares out over
    the six FETs: 0.24 W each.
  - Shunts: 0.067 W each. One shunt carrying the full 20 A loses 20² × 0.5 mΩ = 0.20 W. The
    three phases take turns, so each shunt averages a third: 0.067 W.
  - Not authored yet: the gate driver (0.10 W of gate charge), the MCU (0.03 W), the 3.3 V
    regulator, and the phase copper (0.20 W a channel, a copper loss the study does not model as
    a part). The generated study gives parts with no power 0 W, so its total is 1.64 W a channel,
    6.6 W for the board, against 7.8 W in the hand budget.
- **Evidence.** Hand estimate, from the losses in the 2026-11-06 entry "ESC losses with the
  shunts and copper". Study: `electrical/esc/esc_thermal.fea`, made by Board » Analysis » New
  study » Thermal; solve pending (FEA's `pcb` geometry source is not in the current release).
- **Result.** The power map holds 36 parts and 6.6 W. The study puts each FET's and shunt's heat
  on its own footprint, so it can show the edge bridges' temperature, which the even plate
  spreads out.

## 2026-11-08: Flight controller: a GPS and compass port

- **Requirement.** Position hold and return to home need a GNSS receiver and a compass. The
  flight controller needs a port for a combined module: a UART for position data, I2C for the
  compass, and a supply.
- **Change.** `electrical/flight_controller/flight_controller.circuit`, sheet `connectors`: J5, a
  6-pin 1.0 mm connector on the board's right edge, under the video transmitter's J4. Pins,
  named from the board's side: 1 GPS_VCC, 2 TX, 3 RX, 4 SCL, 5 SDA, 6 GND.
  - UART3 on PB12 (TX) and PB13 (RX). UART1 carries the video transmitter and UART2 the
    receiver, so the GPS gets its own UART and the other two links keep their rates. The MCU's
    TX on pin 2 goes to the module's RX.
  - The compass joins the barometer's I2C bus (PB8, PB9) and uses its 4.7 kΩ pull-ups.
  - GPS_VCC is the module's own supply net, kept off +3V3 so the receiver's current and noise
    stay off the MCU and IMU rail. Its regulator is not on the board yet, so J5.1 is marked
    no-ERC until one is added.
  - On the board, C23 moves beside the barometer and D3 moves 0.6 mm down to clear J5.
- **Evidence.** Hand estimate: a GNSS module with a compass draws about 30–50 mA while tracking.
  A 3.3 V LDO from +5 V then dissipates (5 − 3.3) V × 50 mA = 85 mW. The rebuilt board is routed
  with DRC clean and nothing unrouted, and ERC reports no findings.
- **Result.** The board has a GPS port on UART3 and the I2C bus. Its supply waits for a regulator
  sized to the 50 mA load.

## 2026-11-08: Gimbal motors: one part number per size

- **Requirement.** Each purchased part size has its own part number, so the parts list orders
  the right quantity of each.
- **Problem.** The yaw, roll and pitch motors are three sizes (Ø20 × 6, Ø17 × 5 and
  Ø15 × 4.5 mm) but all carried CD-GB-510. The drawing's parts list counts parts by number, so
  it showed one line of three motors at the yaw size.
- **Change.** `mechanical/gimbal/gimbal_motor.part` has a configuration per axis: `yaw`
  CD-GB-510, `roll` CD-GB-511 and `pitch` CD-GB-512, each with its size and a description.
  `mechanical/gimbal/gimbal.assembly` selects each motor by its configuration.
- **Result.** The parts list in `drawings/drone.drawing` shows three motor lines, one of each
  size.

## 2026-11-07: Light pipe drawn as lines and arcs to clear the status window

- **Requirement.** The light pipe sits in the upper shell's status window with a clearance all
  round, so the clear part drops in at assembly and the drone's interference check passes.
- **Problem.** After the window became a 3 × 16 mm obround of lines and arcs, the light pipe was
  still one closed 16-point spline through points on an R1.3 obround. Like the old vents, the
  spline bowed outward along its 13 mm sides, past the window's straight edges: the interference
  check found the shell and the pipe sharing 4.441 mm³.
- **Change.** `mechanical/body/light_pipe.part`: the profile is a 2.6 × 15.6 mm obround, two
  lines at y = ±1.3 mm and two R1.3 arcs about x = 67.5 and 80.5 mm, the window's own centres.
- **Result.** The pipe clears the window by 0.2 mm on every side, a slip fit for a molded
  polycarbonate pipe. The cad_drone interference check reports no overlap between `body_top`
  and `light_pipe`, in flight or folded.

## 2026-11-07: Upper shell vents and status window drawn as lines and arcs

- **Requirement.** The vents and the status window are drawn the way the shell's drawing and
  its tooling dimension them: straight sides and full-radius ends, with the same placement and
  size as before.
- **Problem.** Each of the six vents and the status window was one closed 16-point spline
  through points on an R1.6 (window R1.5) obround. An interpolating spline through two points
  34 mm apart bows outward, so each vent cut about 1.5 times the drawn obround's area. Cutting
  spline tools through the lofted shell was also the shell's slowest step.
- **Change.** `mechanical/body/body_top.part`: `vent_s` holds six 3.2 × 34 mm obrounds, each two
  lines (x = centre ± 1.6 mm, y = ±15.4 mm) and two R1.6 arcs, at x = −7, −0.5, 6, 12.5, 19 and
  25.5 mm. `window_s` is a 3 × 16 mm obround from x = 66 to 82 mm: two lines at y = ±1.5 mm and
  two R1.5 arcs about x = 67.5 and 80.5 mm.
- **Evidence.** The CAD host's mass properties of `body_top.part`, before and after:
  - Volume 41.54 → 42.12 cm³, mass 49.8 → 50.5 g. One spline vent removed 0.28 cm³; one
    line-and-arc vent removes 0.18 cm³, its 106.6 mm² area through the 1.8 mm wall.
  - Bounding box unchanged: x −100 to 99 mm, y −46.0 to 46.0 mm, z 27.0 to 58.04 mm (within
    1.2 µm).
  - Regeneration on the browser host: 12.5 s → 10.7 s.
- **Result.** The vents and window are the drawn obrounds. The shell gains 0.6 cm³ (0.7 g), so
  the all-up mass rises by under 0.1 %. The cad_drone balance check, run after the change:
  779.8 g, CG at (−7.9, 0.1, 25.1) mm, 0.1 mm from the thrust centre (−8.0, 0.0) mm, inside its
  3 mm (x) and 1 mm (y) limits.

## 2026-11-07: ESC stack-up: four layers, 1 oz → six layers, 2 oz outside

- **Requirement.** Each channel carries 20 A through its phase copper. Its switching loop must keep
  the 40 V FETs' drain-source overshoot well under their rating on a 25.2 V (6S, full charge)
  bus. Each gate drive needs a return path under its track. The board must spread the edge
  bridges' heat to the gap pad.
- **Problem.** Each channel packs three shunts, a three-phase gate driver and an MCU into a
  quadrant of a 52 mm board. On four layers with two plane layers, the driver's 24 pins, the
  MCU's inputs and the switch-node returns had only the top and bottom to route on, so they
  crossed the phase and shunt copper. The top layer sat 0.49 mm above its ground plane, and
  1 oz outer copper put 0.5 mΩ in each square of phase copper.
- **Change.** `esc.circuit.layout`: a 1.6 mm six-layer stack-up.
  - Top (2 oz): the bridges, the phase, shunt and battery-feed pours; the free copper is
    ground, stitched to In1 and the bottom every 1.5 mm.
  - In1 (1 oz): a solid ground plane 0.11 mm under the top.
  - In2 (1 oz): signal. The MCU's bridge inputs cross from the driver's bus to the MCU, and
    phase B's switch-node return runs from the driver to its motor pad.
  - In3 (1 oz): signal, with 3V3 filling the free copper from the regulator to the four MCUs.
  - In4 (1 oz): the battery plane, 0.11 mm over the bottom.
  - Bottom (2 oz): the gate drivers, their signal routing and a ground pour on the heatsink side.
  - Through vias are 0.2 mm drill, 0.45 mm pad (8:1 in 1.6 mm). The top's ground pads drop to
    In1 through 0.1 mm laser vias in the pad: twelve in each shunt's ground pad, one or more in
    each capacitor's.
  - Each channel's high sides take the battery from In4 through 29 vias: 14 along a top pour
    at the board edge that joins bridges A and B's drain pins, 6 in bridge A's drain pad and 9
    beside bridge C.
- **Evidence.** Hand estimates:
  - Switching-loop inductance is about μ0 × h per square of loop path over its plane. With
    h = 0.11 mm that is 0.14 nH per square, against 0.61 nH at 0.49 mm. For a 4-square loop
    (capacitor, high side, low side, shunt) it is 0.55 nH, against 2.4 nH. At 20 A switched in
    7 ns (2.9 A/ns) the overshoot is 1.6 V, against 6.9 V: 26.8 V peak, against 32.1 V.
  - Battery feed: 20 vias reach bridges A and B, which conduct one at a time, so 20 A is
    1.0 A a via. Shunt return: 20 A over 12 laser vias is 1.7 A a via.
  - Phase copper: 2 oz is 0.25 mΩ per square. About one square from the FETs to each motor pad
    gives 0.1 W per conducting phase at 20 A, half the 1 oz figure.
  - Heat spreading: 278 µm of copper in 1.6 mm gives an in-plane conductivity of about 68 W/m·K,
    against 35 W/m·K for the four-layer board.
  - The board routes clean: design rule check 0, 0 unrouted, ERC 0.
- **Result.** The worst-case switching overshoot is 26.8 V against the FETs' 40 V rating, a 13 V
  margin (hand estimate). The other three channels repeat channel 0's routing turned about the
  board's center.

## 2026-11-07: Landing skid rail in a 1 m/s touchdown

- **Requirement.** Each skid must carry a 1 m/s touchdown (the descent limit) with its stress
  under 55 MPa: the conditioned strength of 30 % glass-filled nylon, about 110 MPa, over a
  factor of 2 for weld lines and repeated landings.
- **Load.** Stopped over the skids' 2 mm of compliance, 1 m/s is 250 m/s², about 25 g. The 777 g
  drone landing level puts 0.777 kg × 250 m/s² / 2 = 97 N on each skid.
- **Change.** `landing_skid.part` takes the rail's depth as an input, `rail_thickness`
  (3.5 mm), and names the struts' tops `mount` and the sole `sole`. The geometry at 3.5 mm is
  unchanged. `simulation/landing_skid.fea` holds the mounts and pushes 97 N up through the sole.
- **Evidence.**
  - Hand estimate: the 7 × 3.5 mm rail as a beam fixed at the struts, 58 mm apart, under a
    uniform 97 N: M = wL/12 = 469 N mm, Z = 14.3 mm³, about 33 MPa where the rail meets the
    struts. A 2.5 mm rail (Z = 7.3 mm³) reaches about 64 MPa.
  - Study: `landing_skid.fea`, solved at 3.5 mm (quadratic tets at 2 mm, 0.2 mm deviation;
    172,369 elements; native, about 27 min). Peak von Mises 23.9 MPa, 7.6 MPa at the sole, peak
    deflection 0.095 mm. The study now carries a 55 MPa assessment on the peak (added after
    this solve).
  - The solve sits under the hand estimate, most likely because the struts aren't rigid: they
    bend with the rail and take part of its root moment.
  - The 2.5 mm rail isn't solved yet: at 2.5 and 2.0 mm the sole fillet's tangent edge on the rail's
    rear end exports 26 µm off its surface and the mesher refuses it. Scaling the solved peak by
    section modulus gives about 47 MPa at 2.5 mm and 73 MPa at 2.0 mm.
- **Result.** 23.9 MPa against 55 MPa at 3.5 mm: a 2.3 × margin. By that scaling a 2.5 mm rail
  would still pass (about 1.2 ×) and a 2.0 mm rail would fail; both need a solve once the
  fillet edge exports cleanly.

## 2026-11-07: Arm root: a 0.3 mm shoulder at the knuckle

- **Requirement.** Where the beam leaves the hinge knuckle, the arm needs one clear step so the
  joint can be moulded and inspected, and the first flap mode must stay above 476 Hz
  (1.2 × the 397 Hz full-throttle blade pass).
- **Problem.** The beam's first two stations were 13 mm deep at x = 4 mm and 12.76 mm at x = 9 mm.
  Where the beam crossed the knuckle's R7 wall (x = 7 mm) its crown sat about 0.07 mm under the
  knuckle's 6.5 mm top face, and its keel the same distance above the bottom face: a sliver of
  cylinder wall 73 µm tall, too small to mould cleanly or to measure. Raising the crown to the
  face would leave a tangent edge, and above it the beam meets the clevis lugs.
- **Change.** `arm.part`: both root stations (`beam_s0` at x = 4 mm and `beam_sa` at x = 9 mm) are
  scaled to a 12.4 mm depth, crown at 6.2 mm and keel at −6.2 mm. The beam now meets the knuckle
  with a 0.3 mm shoulder above and below, and keeps a constant depth out past the lugs. The
  widths (16 and 15.7 mm), the stations from x = 39.7 mm outboard, the pad and the bore are
  unchanged. `simulation/geometry/arm_study.step` is re-exported from `arm_study.assembly`.
- **Evidence.**
  - Hand estimate: the station-by-station tip stiffness (fixed at the bore, load at the pad)
    falls 3.8 %, from 448 to 431 N/mm for the 90.6 mm rear arm, so the first flap mode falls
    by about 2 %: 509 → 499 Hz (rear arm), 531 → 521 Hz (the study's 88.2 mm arm). The root's
    section modulus falls about 9 %, so the landing bending stress at the root rises from
    about 3.0 to 3.3 MPa.
  - Study: `arm_modal.fea` on the re-exported geometry; solve pending.
- **Result.** First flap mode 499 Hz (hand estimate) against the 476 Hz target, 1.26 × the
  397 Hz blade pass.

## 2026-11-06: ESC current sense: one shared shunt → a shunt in each low side

- **Requirement.** Field-oriented control needs each motor phase's current in every 48 kHz PWM
  period, 10 mV at 20 A into the MCU's ADC, with no track crossing the motor-current copper.
- **Problem.** The first channel ran six-step commutation on one 0.5 mΩ 2512 shunt in the shared
  low-side return. That shunt reads only the sum of the three low sides, the DC-link current, so
  the controller can't tell the phases apart.
- **Change.**
  - `esc.circuit`, sheet `channel`: RSHA, RSHB and RSHC (0.5 mΩ, 1206, 1 W), one in each low
    side's source, each into its own 1 kΩ / 10 nF filter (RISA–C, CISA–C) at ADC inputs PA9,
    PA11 and PA12. The MCU runs field-oriented control.
  - `esc.circuit.layout`: each shunt's pad 1 sits over its low side's source pins, joined by a
    solid pour. Each gate leaves its FET at the other end of the pin row to its 10 Ω resistor.
    Track keepouts on the top copper cover the source-to-shunt and FET-to-motor-pad gaps, so no
    track crosses the motor current. The gate driver's pins face what each group drives: phase
    C's drive faces bridge C, phases A and B's face their bridges, and the logic inputs face
    the MCU. Its supply and drive capacitors sit on the top over its corner, and phase C's
    bootstrap capacitor beside its phase C side.
- **Evidence.**
  - `esc.circuit`, simulation `current_sense`, solved with phase A carrying +20 A and B and C
    returning −10 A each: ISENSE_A 10.00 mV (spec 9.5–10.5 mV), ISENSE_B and ISENSE_C −5.00 mV
    (spec −5.25 to −4.75 mV); corner 15.92 kHz (spec 14–18 kHz); rise 21.97 µs; 1 % settling
    46.6 µs.
  - Hand estimate: one shunt at the full 20 A dissipates 20² × 0.5 mΩ = 0.2 W against its 1 W
    rating.
- **Result.** Every phase reads within its spec, and each shunt runs at 20 % of its rating.

## 2026-11-06: ESC losses with the shunts and copper: 6.2 W → 7.8 W; edge bridges to the gap pad

- **Requirement.** The board stays under 85 °C, the rating of its controller, in 35 °C air.
- **Problem.** The 6.2 W budget left out the current shunts, up to 0.2 W a channel, and the phase
  copper, 0.2 W a channel (two conducting phases at 0.1 W each). Bridges A and B of each
  channel, and the gate driver under bridge B, stand at the board's edge, 4.7 mm outside the
  36 mm gap pad, so their heat reaches the pad sideways through the board's copper.
- **Change.** `esc_thermal.fea`: the board's heat is 7.8 W (1.96 W a channel), 1.81e6 W/m³ over
  the board's 4,326 mm³, and the board conducts 68 W/m·K in plane (six layers, 2 oz outside).
  The study notes that its plate spreads the losses evenly, while the board concentrates them in
  the edge bridges.
- **Evidence.**
  - Hand estimate: at 7.8 W the heatsink (2.1 K/W), gap pad (0.15 K/W) and pedestal (0.03 K/W)
    put the pad seat about 18 K over ambient, 53 °C. A bridge's 0.69 W (with its copper)
    crossing 4.7 mm of a 10 mm wide strip adds 3 K through all six copper layers, or 12 K
    through the 2 oz top layer alone: 56–65 °C at the edge bridges and the driver.
  - Study: `esc_thermal.fea`; solve pending.
- **Result.** 65 °C at worst (hand estimate) against 85 °C, a 20 K margin.

## 2026-11-06: ESC MCU reset: NRST pull-up and filter

- **Requirement.** Each channel MCU's reset pin must sit at 3.3 V in operation and must not reset
  on the bridges' switching noise.
- **Problem.** The schematic left NRST unconnected. The design review flagged it as floating on
  all four MCUs.
- **Change.** `esc.circuit`, sheet `channel`: RRST, 10 kΩ from NRST to 3V3, and CRST, 100 nF to
  ground, beside the MCU's NRST pin.
- **Evidence.** Hand estimate: 10 kΩ × 100 nF = 1 ms, so a 1 µs spike moves NRST by under 0.1 %.
  The design review passes with no reset finding.
- **Result.** NRST held at 3.3 V on all four channels.

## 2026-11-06: Arm stations follow the arm's length

- **Requirement.** A change of the arm's length in `arm.part` must move all four motors along
  their arms, in the drone and in the arm study, with no second number to edit.
- **Problem.** `drone.assembly` gave each station its own arm length (81.54 mm front, 90.607 mm
  rear), and `arm_study.assembly` placed the motor pod at a fixed 88.2 mm. Editing `length` in
  `arm.part` changed the arm's drawing and neither assembly.
- **Change.**
  - `arm.part`: `length` (88.2 mm) is the nominal pin-to-motor length. A new input,
    `length_offset` (0 mm), lengthens or shortens one station's arm from it. The part publishes
    two frames: `tip`, where the nominal motor axis crosses the hinge's mid-plane, and `seat`,
    the pad's top face on the motor axis.
  - `drone.assembly`, `arm_station.assembly`, `arm_unit.assembly`: each station passes a length
    offset, −6.66 mm front and +2.407 mm rear, in place of a length. The arm unit places its motor
    station on `tip`, offset by the station's length offset, rise and pad tilt.
  - `arm_study.assembly`: the motor pod sits on the arm's `seat` frame.
- **Evidence.** At the 88.2 mm nominal, the drone (63 occurrences) and the arm study (2) compile
  to the same placements and part geometry as before; the largest transform difference is 0. At
  78 mm, every motor moves 10.2 mm in along its arm.
- **Result.** At 88.2 mm the motors stay on the 300 mm diagonal (81.54 mm front and 90.607 mm
  rear arms), and one edit to `length` moves all four.

## 2026-11-06: Field launch stand: a welded 6061 tube frame

- **Requirement.** In the field the drone must take off from a level, rigid surface clear of
  grass and grit, with its props out of ground effect so the take-off throttle matches the hover
  figure above, and the stand must not tip with the drone on it.
- **Change.** `mechanical/ground/launch_stand.part`, a weldment of 20 × 20 × 1.5 mm 6061-T6
  square tube. Two side frames stand in the skids' planes (y = ±34 mm): a base rail, two legs
  splayed 100 mm outward and a top rail that the skid rests on, mitred at all four corners. Two
  48 mm cross members butt square between the top rails, and the side frames sit across two
  260 mm feet at x = ±150 mm.
- **Evidence.**
  - Cut list: 12 members in 5 items, 844.6 g of tube. Base rails 348.74 mm (55.2° mitres both
    ends), legs 309.25 mm (34.8° / 55.2°), feet 260 mm square, top rails 133.92 mm (34.8° both
    ends), cross members 48 mm square.
  - Hand estimate: the skid soles rest 310 mm above the ground and the prop discs about 78 mm
    above the soles, so the discs run 388 mm up, 2.3 prop diameters (166 mm). Ground effect is
    negligible above about one diameter.
  - Hand estimate: drone (746.1 g, CG 45.8 mm above the soles) plus stand (844.6 g, CG 120 mm
    up) puts the combined CG 231 mm above the ground. The feet reach ±130 mm across and
    ±160 mm fore and aft, so the loaded stand tips at 29.4° sideways and 34.7° fore and aft.
- **Result.** A 0.85 kg stand that holds the drone level 310 mm up, with the props 2.3 diameters
  clear of the ground and a 29.4° tipping angle.

## 2026-11-06: Stack screws: 2.8 mm of thread → 4.8 mm, tapped M3 standoffs

- **Requirement.** Each M3 screw that clamps the board stack must engage at least 1.5 × its
  diameter (4.5 mm) of thread in the 6061 standoff, and its tip must stop short of the thread's end.
- **Problem.** The 16 mm screws reached 2.8 mm into the standoffs (screw head at z = 23.2 mm,
  standoff top at z = 10 mm), 0.93 × D. The standoffs' holes were plain 2.5 mm drillings, 5 mm
  deep, with no thread stated.
- **Change.**
  - `drone.assembly`: `stack_screw` length 16 mm → 18 mm.
  - `electrical/esc/esc_heatsink.part`: `taps` become tapped M3 holes (`spec = { standard = iso,
    size = M3 }`, `form = { hole = tapped, thread_depth = 6 mm }`), drilled 7.5 mm deep at the
    2.5 mm tap drill.
- **Evidence.**
  - Hand estimate: the tip sits at 23.2 − 18 = 5.2 mm, so 10 − 5.2 = 4.8 mm of thread is engaged
    (1.6 × D). The tip is 0.8 mm above the thread's end (z = 4 mm) and 2.7 mm above the drill
    point; 1 mm of the 2 mm base plate stays under the drilling.
  - The assembly's interference check reads each screw's overlap with its tapped hole as the
    engaged thread: 10.4 mm³ over 2.16 mm² (the Ø3 shank in the Ø2.5 tap drill), 4.80 mm for each of the
    four screws, in flight and folded. `cad_drone` checks it against 4.5 mm.
- **Result.** 4.8 mm engaged against the 4.5 mm minimum (1.07 ×); the tip stops 0.8 mm short of
  the thread's end.

## 2026-11-06: Front props: root tab 16 → 20 mm, blades 4 mm outboard, folded 125 deg

- **Requirement.** Stowed, each front blade must lie along its arm with no contact with the hub,
  the shell or the other arm. In flight, neighbouring props must keep a tip gap of at least 10 %
  of their radius.
- **Problem.** Folded at 104 deg, the front blades' airfoil roots, 14 mm out from the pivot, swept
  into the hub's R12.6 plates (13.9 mm³ shared). Hand estimate: at 125 deg that root station sits
  √(9² + 14² + 2 · 9 · 14 · cos 125°) = 11.5 mm from the motor axis, still inside the plates.
- **Change.**
  - `mechanical/propulsion/prop_blade.part`: the root tab runs 20 mm (was 16 mm), and the five
    blade sections move 4 mm outboard, to 18, 38, 58, 74 and 78 mm from the pivot. The tip radius
    goes from 83 mm to 87 mm, a 174 mm prop (was 166 mm).
  - `mechanical/propulsion/prop_hub.part`: between the plates the boss is R3.5 (was R5), a 1 mm
    wall round the 5 mm shaft. Folded 125 deg, the tab's inner edge comes to 3.97 mm from the
    axis, which put 9.4 mm³ of tab into the R5 boss.
  - `drone_folded.assembly`: the front blades fold 125 deg (was 104 deg).
- **Evidence.**
  - Hand estimate: the root station folded 125 deg sits 14.8 mm from the axis, 2.2 mm outside
    the plates; the section's nearest edge 12.9 mm. The tab clears the boss by 0.47 mm.
  - The assembly's interference check on `drone_folded.assembly`: no common material between any two parts, in flight or folded (before the hub change, each
    front blade shared 9.4 mm³ with its hub).
  - `cad_drone` (`the_cg_sits_over_the_thrust_centre`): the closest motor axes, front and rear on
    each side, are 200.1 mm apart. Less one 174 mm diameter, the tips clear by 26.1 mm.
  - Hand estimate of the excitation: thrust goes as rpm² × diameter⁴, so the 174 mm prop holds the
    777 g drone at about 7,800 rpm (the 166 mm prop needed 8,400 rpm for 746 g), and 2:1
    thrust-to-weight needs 11,030 rpm. The full-throttle two-blade pass falls from 397 Hz to
    368 Hz, and the rear arm's 509 Hz first flap mode is 1.38 × that (target 1.2 ×).
- **Result.** Tip gap 26.1 mm in flight, 30 % of the 87 mm radius (requirement 10 %, 8.7 mm).
  Stowed, the front blades clear the hub's plates by 2.2 mm at the root station and the boss by
  0.47 mm. Measured on the assemblies' meshes, the stowed envelope grows from 211 × 176 × 105 mm
  to 211 × 179 × 108 mm, and the flying envelope from 340 × 346 × 79 mm to 346 × 351 × 79 mm
  over the props.

## 2026-11-06: ESC power FETs: pins clear of the drain tab

- **Requirement.** Each of the 24 DFN-8 (3.3 mm) power FETs' source pins (1–3) and gate pin (4)
  must keep the board's 0.15 mm copper clearance to the exposed drain pad. The drain pins (5–8)
  and the pad carry the phase current together.
- **Problem.** The first land pattern ran every pin pad into the exposed pad. The board's design
  rule check flagged pins 1–4 at 0 mm from pad 9 on all 24 FETs, which would short source and gate
  to drain.
- **Change.** `esc.circuit.layout`: the FET land pattern's pin pads stop 0.2 mm short of the exposed
  pad, and drain pins 5–8 join the pad as one copper area, as the package drawing lays them out.
- **Evidence.** The design rule check no longer reports pin-to-pad findings on any FET. The board
  now has 97 findings (40 clearance, 10 courtyard, 8 silk, 4 hole-to-hole, 35 unrouted), all
  from placement and routing. They are cleared in the next placement and routing pass.
- **Result.** 0.2 mm from each source and gate pin to the drain pad (requirement 0.15 mm).

## 2026-11-06: Balance: battery forward to the thrust centre

- **Requirement.** In a hover the CG must sit within 3 mm of the props' thrust centre (the
  centroid of the four motor axes in plan), so all four motors run within a few percent of each
  other and keep the same throttle margin.
- **Problem.** Evaluate, mass properties on `drone.assembly`: CG at x = −19.2 mm, with the thrust
  centre at x = 0. The 297 g battery sat in the tail (x = −94 to −35.5 mm). Hand estimate, from
  moments about the CG with the motors at x = ±100 mm: the rear pair carries 59.6 % of the weight
  and the front pair 40.4 %. The rear motors need 1.48 times the front ones' thrust: 9,190 rpm
  against 7,560 rpm at hover. At the 11,900 rpm limit the rear motors' thrust is 1.68 times their
  hover thrust instead of 2.0, so they saturate first in a climb or a gust.
- **Change.**
  - `battery.part`: the pack moves 32 mm forward, to x = −62 to −3.5 mm. Its lid stays in the
    shell's surface (x = −62 to −28.5 mm), and its front third slides under the upper shell. The
    case is 141 cm³, lumped at 2,110 kg/m³ for the pack's 297 g.
  - `body_top.part`, `body_bottom.part`: the bay and lid opening move with it, and a lofted tail
    cap closes the shell behind it.
  - `drone.assembly`: the ESC, heatsink, gap pad and flight controller stack moves 15 mm forward
    (x = 25 mm), clear of the battery's front face. The belly window and pocket, and the vents
    over the boards, move with it.
  - The four hinges and arms move 8 mm aft (front hinges at x = 44 mm, rear at x = −66 mm). The
    seats in both shells move with them. Arm lengths, rises, angles and fold geometry are
    unchanged, so the arm studies and drawing still apply.
- **Evidence.**
  - Evaluate, mass properties on `drone.assembly` after the change: 760.5 g, CG at
    (−8.8, 0.1, 25.4) mm. The motors sit at x = 92 mm and −108 mm, so the thrust centre is at
    x = −8.0 mm. The CG is 0.8 mm aft of it. `cad_drone` checks this (`the_cg_sits_over_the_thrust_centre`).
  - Hand estimate: the rear pair carries 50.4 % of the weight and the front pair 49.6 %; the motors
    hover at 8,530 and 8,460 rpm (equal thrust: 8,495 rpm). The boards aren't in the mass report.
    At about 35 g at x = 25 mm, they move the CG 1.2 mm forward, to 0.4 mm ahead of the thrust
    centre.
  - The interference check (`the_drone_has_no_interference_in_flight_or_folded`) passes in flight
    and folded.
- **Result.** CG within 0.8 mm of the thrust centre (requirement 3 mm). The front and rear motors
  hover within 1 % in rpm. The new weight, 760.5 g, needs 12,000 rpm for 2:1 thrust-to-weight,
  and full-throttle blade pass rises to 400 Hz. The rear arm's 509 Hz first mode is still 1.27 times
  that, above the 1.2 times target.

## 2026-11-06: All-up weight against thrust

- **Requirement.** The four props must hold the drone in a hover with throttle to spare: a 2:1
  thrust-to-weight ratio at full throttle, so the drone can climb, brake and hold station in
  gusts.
- **Evidence.**
  - Evaluate, mass properties on `drone.assembly`: 746.1 g, CG at (-19.2, 0.1, 24.8) mm. The
    battery is one lumped body at 2,050 kg/m³ (a 6S 2,000 mAh pack, 297 g); every other part
    takes its material's density.
  - Hand estimate: the 166 mm, 115 mm-pitch two-blade prop has a static thrust coefficient of
    about 0.10, so T = C_T ρ n² D⁴. Each motor carries 746.1 g × 9.81 / 4 = 1.83 N in a hover,
    at 8,400 rpm. A 2:1 ratio needs 3.66 N a motor, at 11,900 rpm.
- **Problem.** The arm-stiffness entry below assumed 6,500 rpm at hover and 10,000 rpm at full
  throttle. At 746 g, 10,000 rpm gives only 1.41:1, and the hover sits at 8,400 rpm.
- **Change.** The motors are specified to 11,900 rpm loaded at full throttle (about 700 rpm/V on
  the 6S pack's 22.2 V, allowing for voltage sag). The blade pass now runs 280–397 Hz, and the
  arm's first-mode target rises to 1.2 × 397 Hz = 476 Hz (see the next entry).
- **Result.** 2:1 thrust-to-weight at 11,900 rpm, hovering at 8,400 rpm (71 % of full speed).

## 2026-11-06: Arm stiffness: 0/90 prepreg → 0-dominated prepreg

- **Requirement.** The arm's first flap mode must sit above 1.2 × the full-throttle blade pass:
  1.2 × 397 Hz = 476 Hz (see the all-up-weight entry above).
- **Problem.** The 0/90 carbon prepreg arm (E = 65 GPa along the arm) gives the 90.6 mm rear arm,
  the longest, a first flap mode of about 433 Hz, 9 % under the target. The earlier estimate of
  425 Hz on an 88 mm arm met the old 400 Hz target, which came from 10,000 rpm.
- **Change.** The arm (`arm.part`) is laid up [0/0/90/0]s, with three quarters of the plies along
  the arm: E = 90 GPa along the arm, 1,550 kg/m³. The geometry and mass are unchanged.
  `arm.drawing` calls out the layup, and `arm_modal.fea` and `arm_landing.fea` use 90 GPa.
- **Evidence.**
  - Hand estimate: the lofted elliptic beam (16 × 13 mm at the root, 11 × 7 mm at the tip),
    fixed at the pin bore and loaded at the pad, integrated station by station, gives
    k = 448 N/mm at 90 GPa for the rear arm. With the 40 g pod and the arm's effective 3.8 g,
    f₁ = √(k/m) / 2π = 509 Hz. The front arm (81.5 mm) reaches about 600 Hz.
  - Study: `arm_modal.fea` on `arm_study.assembly`; solve pending (the study's arm is the 88.2 mm
    default, which the same estimate puts at 531 Hz).
- **Result.** First flap mode 509 Hz (hand estimate) against the 476 Hz target, 1.28 × the
  397 Hz blade pass.

## 2026-11-05: ESC cooling: polycarbonate bosses → aluminium belly heatsink

- **Requirement.** The 4-in-1 ESC loses 6.2 W at full throttle (20 A a channel: 1.28 W conduction,
  0.15 W switching, 0.10 W gate drive and 0.03 W logic, times four). The board must stay under
  85 °C, the rating of its controller, in 35 °C air.
- **Problem.** The first layout stood the ESC on four polycarbonate bosses moulded into the lower
  shell. Their conduction path is about 258 K/W, so 6.2 W would put the board some 1,600 K over
  ambient. The closed shell gives the board no other way out.
- **Change.**
  - `esc_heatsink.part`: a 6061-T6 heatsink fills a 56 × 56 mm window in the belly. A 38 × 38 mm
    pedestal rises to the ESC's underside, four standoffs carry the board stack on the 30.5 mm
    pattern, and fourteen 0.8 mm fins, 10 mm deep, run fore and aft in the propellers' downwash.
  - `thermal_pad.part`: a 0.5 mm, 3 W/m·K gap pad between the pedestal and the board, die-cut
    with an 8 mm relief round each standoff.
  - `body_bottom.part`: the bosses are gone; the shell has the belly window and a pocket for
    the pedestal.
- **Evidence.**
  - Hand estimate: 19,260 mm² of fins and plate below the belly at 25 W/m²·K and 99 % fin
    efficiency is 2.1 K/W (13 K); the gap pad adds 0.15 K/W (0.9 K) and the pedestal 0.025 K/W
    (0.2 K). The board's pad sits about 14 K over ambient, about 49 °C.
  - Study: `esc_thermal.fea` on `esc_thermal.assembly` (the heatsink, the pad and the board as a
    plate carrying its losses); solve pending.
- **Result.** About 49 °C at the board's pad (hand estimate) against the 85 °C limit, a 36 K
  margin. The heatsink weighs 60 g.

## 2026-11-05: Motor pod to arm: a located, slotted fit

- **Requirement.** The pod's cowl must seat square on the arm's motor pad, so the four props stay
  in one plane, and must go on and come off with the arm assembled. The motor axis must stay
  vertical on the rear arms, whose hinges lean 28 deg, and on the front arms, which lean 20 deg.
- **Change.**
  - `motor_pod.part` is pocketed R9.2 and 7 mm deep over the arm's R9 pad: 0.2 mm radial
    clearance, with the pocket's ceiling seating on the pad's top face (datum A on the arm
    drawing). A slot in the skirt, 0.5 mm clear of the beam on each side, lets the cowl drop
    over the pad with the beam running in under it. The four M2 motor screws pass up through the
    pad and the pod's floor on a 12 mm bolt circle.
  - `arm.part` turns its pad and bolt pattern by `pad_tilt` about the arm's axis, so the pad
    stays square to the motor on a leaning hinge. The beam's tip section ends 3 mm under the
    pad's top face, so the leaning beam stays under the pocket's ceiling. A station 9 mm out
    keeps the knuckle's section until the beam has cleared the clevis lugs.
  - `motor_pod.part` rolls the skirt's slot by `arm_roll` to meet the leaning beam.
- **Evidence.** The assembly's interference check over every part pair, in flight and folded:
  no common material between arm and pod. Before the change the rear pods shared 421 mm³ with
  their arms.
- **Result.** The pod seats on the pad face with clearance everywhere else, and all four motor
  axes are vertical in flight.

## 2026-11-05: Folding: rear arms under, front arms over, props along the arms

- **Requirement.** The drone stows for carrying with no part touching another, with the props
  folded along their arms, and with nothing below the skids' soles.
- **Problem.** The first fold, on vertical front pins at y = ±44 mm, swept each front arm's root
  through both shells (338 mm³ each). The rear props, standing on the rear motors, rose into the
  front arms (up to 315 mm³). The props' blades swung through their own hubs (150 mm³).
- **Change.**
  - `drone.assembly`: the front pins move out to (52, ±52, 24) mm and lean 20 deg, so each front
    arm rises as it swings back and clears the rear props folded under it. The arms are re-solved
    to keep the motors in place: 81.54 mm long, 5.79 mm rise, yaw 56.32 deg. The rear pins keep
    their 28 deg lean, so the rear arms drop as they swing forward.
  - `drone_folded.assembly`: front and rear arms fold 114 deg. The front blades splay 14 deg and
    the rear blades 12 deg outboard of their arms, so they clear the shell and the other arm.
  - `prop_hub.part`, `prop_blade.part`, `motor_station.assembly`: each blade's root is a flat tab
    that turns on a 2 mm pin between the hub's two plates (R12.6), with 0.1 mm clearance above and
    below. The airfoil starts 14 mm out, outside the plates. The pivots sit across the arm, so
    each blade folds back along one side of it.
  - `body_bottom.part`: a fold relief beside each rear hinge takes the rear arm's root.
- **Evidence.** The assembly's interference check in `drone_folded.assembly`: no common
  material between any two parts (the M3 screws in their tapped holes are left out). The lowest
  folded part is a rear pod, 0.8 mm above the skids' soles.
- **Result.** Stowed envelope 211 × 176 × 105 mm (flying: 340 × 346 × 79 mm over the props).

## 2026-11-05: Landing skids under the belly

- **Requirement.** The drone must stand on its skids with the gimbal camera clear of the ground,
  and the skids must carry a 1 m/s touchdown.
- **Change.** `landing_skid.part`: a glass-filled nylon rail on two lofted struts at x = 28 and
  −30 mm, trimmed by the body's own loft so each seats flush on the lower shell. The skids stand
  at y = ±34 mm, either side of the heatsink's fins. The front strut sits 8 mm further aft than
  first drawn, clear of the front hinge mount's lower lug. The pod legs on the arms are gone.
- **Evidence.** Soles at z = −21 mm, 3 mm under the gimbal camera at its −12 deg rest pitch. The
  arm's touchdown case moves to the pod's own inertia: 1 m/s stopped over 2 mm is 25 g, 10 N on
  the 40 g pod (`arm_landing.fea`; solve pending).
- **Result.** 3 mm ground clearance under the camera.

## 2026-11-05: Battery lid in the shell's own surface

- **Requirement.** The battery's top must close the body flush, with a split line the user can
  find, and the case must clear the rear hinge mounts that reach into the bay.
- **Change.** `battery.part`: the case is the body's loft clipped to the bay less 0.5 mm, so the
  lid carries the shell's curvature from the tail to a split line at x = −60 mm. The case's front
  corners are notched round the rear hinge mounts' back blocks with 0.5 mm clearance. Before the
  notches they shared 435 mm³ with each mount. `body_top.part` opens the bay's top rear for the lid.
- **Evidence.** The assembly's interference check: no common material between the battery and
  any part, in flight or folded.
- **Result.** A flush lid with 0.5 mm split lines all round.

## 2026-11-05: Hinge mounts seated in the shell

- **Requirement.** Each aluminium hinge mount must seat in the shell's wall and take the arm's
  thrust and landing loads into it.
- **Change.** `body_top.part`, `body_bottom.part`: a recess for each mount, cut as the mount's
  envelope in its own frame (pin axis z), clears the clevis by 0.05 mm all round. The back block
  takes two M2 screws into the shell.
- **Evidence.** The assembly's interference check: no common material between any mount and
  either shell.
- **Result.** Four mounts in their seats, 0.05 mm clear.

## 2026-11-05: Sensor windows, gimbal opening and gimbal travel

- **Requirement.** The vision sensors need a clear view through the shell. The gimbal's yaw motor
  needs a way through the belly. The camera must clear its yoke over its whole pitch travel.
- **Change.**
  - `body_top.part`: R4.1 bores in the nose for the forward pair's R4 bezels.
  - `body_bottom.part`: R4.1 bores for the downward pair, and a 21 mm opening under the nose
    where the yaw motor (R10) stands through the belly, 0.5 mm clear.
  - `gimbal.assembly`, `gimbal_yoke.part`: the pitch axis moves 3.5 mm forward, to 19.5 mm ahead
    of the yoke's back plate, and the yoke's sides grow to 28 mm. The camera's back swings on a
    15.3 mm radius and now clears the plate at every pitch. At the −12 deg rest pitch the camera
    had shared 14 mm³ with the plate. The pitch motor seats on the yoke's side face.
- **Evidence.** The assembly's interference check: no common material between the sensors, the
  gimbal and the shells.
- **Result.** Every sensor and the gimbal sit in their own openings, 0.1–0.5 mm clear.

## 2026-11-05: 5 V rail power sequencing

- **Requirement.** The flight controller's 5 V rail comes from the 6S battery (22.2 V nominal)
  through a 36 V, 2 A synchronous buck at 500 kHz, into 1.5 A. At power-up it must reach
  5 V ± 3 % without overshoot that could reset or damage the 3.3 V LDO and the MCU, with the
  inductor under its 3 A saturation rating.
- **Change.** The buck (`flight_controller.circuit`, part BUCK-36V-2A) holds off under 4.5 V of
  input and until its enable is up: the low side keeps the switch node at ground and the error
  amplifier's output stays at zero, so a load on the dead output cannot wind it up. Its
  reference then ramps over a 1 ms soft start. The feedback divider uses 1 % resistors.
- **Evidence.** `flight_controller.circuit`, simulations `buck_startup` (transient, 1.6 ms) and
  `buck_tolerance` (2,000-run Monte Carlo), solved:
  - output 4.982 V (spec 4.85–5.15 V); ripple 9.2 mV peak to peak (spec ≤ 50 mV);
  - overshoot 0.09 %; inductor peak 2.14 A (spec ≤ 3 A); 3.3 V rail 3.300 V (spec 3.25–3.35 V);
  - over the resistors' 1 % tolerance: mean 4.982 V, σ 19.4 mV, 100 % of runs in 4.9–5.1 V.
- **Result.** Every measure inside its spec; the inductor peak has a 0.86 A margin to saturation.

## 2026-11-05: ESC current-sense filter

- **Requirement.** The MCU samples each phase's low-side current. The sense path must pass the
  current loop's band and reject the 48 kHz switching ripple: a corner of 14–18 kHz over every
  part tolerance, with 10 mV at 20 A into the ADC.
- **Change.** `esc.circuit`, sheet `channel`: a 0.5 mΩ shunt (RSH) into a 1 kΩ / 10 nF RC
  (RIS, CIS) at the MCU's ISENSE pin. The corner is 1 / (2π × 1 kΩ × 10 nF) = 15.92 kHz, centred
  in the band, so the capacitor's 10 % tolerance stays inside it.
- **Evidence.** `esc.circuit`, simulation `current_sense`, solved:
  - corner 15.92 kHz (spec 14–18 kHz); 10 mV at 20 A (spec 9.5–10.5 mV);
  - 10–90 % rise 21.97 µs (spec ≤ 30 µs); 1 % settling 46.6 µs (spec ≤ 60 µs);
  - over 1 % resistors and 10 % capacitors, 1,000 Monte Carlo runs: 100 % in 14–18 kHz.
- **Result.** Every measure inside its spec; the nominal corner sits 1.9 kHz from either edge of
  the band.

## 2026-11-05: Flight controller reset: NRST pull-up and filter

- **Requirement.** The MCU's reset pin (U1 NRST) must sit at 3.3 V in operation and must not
  reset on the ESC's switching noise coupled into the stack.
- **Problem.** The first schematic left NRST on its 100 nF capacitor (C11) alone. The board's
  design review flagged the pin as floating: with no defined level, noise can hold the MCU in
  reset or trip it in flight.
- **Change.** `flight_controller.circuit`, sheet `main`: R13, 10 kΩ from NRST to 3V3, with C11
  (100 nF to ground) as the filter, per the MCU's reference design. R13 sits beside C11 next to
  the MCU (`flight_controller.circuit.layout`).
- **Evidence.** Hand estimate: the RC is 10 kΩ × 100 nF = 1 ms, so NRST rises past the 0.7 × VDD
  threshold about 1.2 ms after 3V3 is up, and a 1 µs noise spike moves it by under 0.1 %. The
  board's design review passes with no reset finding.
- **Result.** NRST held at 3.3 V through a 1 ms filter.

