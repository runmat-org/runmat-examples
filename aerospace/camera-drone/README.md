# Camera drone

A foldable camera quadcopter in one project: lofted upper and lower shells, four folding arms on
hinge pins, motor pods with folding props, a 3-axis gimbal, landing skids, a flush rear battery,
the 4-in-1 ESC on an aluminum belly heatsink, and the flight controller above it. The boards have
schematics, routed four-layer layouts and circuit simulations; the arm and the ESC have FEA
studies.

## Open it

Open the folder in RunMat Desktop, or open the example in the browser sandbox. `drone.assembly`
opens first, with the arms out. `drone_folded.assembly` is the same drone stowed: it sets the fold
and blade inputs of `drone.assembly`. The assembly's `service` exploded view lifts the shell,
slides the battery out and separates the board stack.

## The tree

| Path | What it holds |
|---|---|
| `drone.assembly` | The top assembly. It places the body, the four arm stations, the gimbal, the heatsink and the board stack. |
| `drone_folded.assembly` | The drone at its folded inputs. |
| `mechanical/body/` | The upper and lower shells, the battery, the status light pipe, the landing skids, the antennas and the vision sensors. |
| `mechanical/arm/` | The arm, its hinge mount, and the arm unit and arm station assemblies that turn it about the hinge pin. `NOTES.md` has the arm's sizing. |
| `mechanical/propulsion/` | The motor pod, the motor, the prop hub and the folding prop blade, placed together by `motor_station.assembly`. |
| `mechanical/gimbal/` | The 3-axis gimbal: three motors, the yaw arm, the yoke, the camera head and the lens. |
| `mechanical/ground/` | The field launch stand: a welded aluminum tube frame with its cut list. |
| `mechanical/+hardware/` | The M3 screw, the hinge pin and the nylon spacer. Folders under `mechanical/` place them with `use part screw from hardware`. |
| `electrical/flight_controller/` | The flight controller's schematic (`.circuit`), board (`.circuit.layout`), lock file and its SPICE models. |
| `electrical/esc/` | The 4-in-1 ESC's schematic, board, lock file and SPICE models, with the heatsink and the gap pad it sits on. |
| `simulation/` | The FEA studies `arm_modal.fea`, `arm_landing.fea` and `esc_thermal.fea`, with the study assemblies they export their geometry from. |
| `drawings/` | Production drawings of the arm and the hinge mount, and the drone's general arrangement. |

Files in the same folder name each other directly (`use part motor as motor`). A file names a
design in another folder with `from` (`use part arm from "../mechanical/arm" as arm`), and a
drawing view names its model the same way (`model = { part = arm, from = "../mechanical/arm" }`).

## Things to try

- Change the arm laminate in `simulation/arm_modal.fea` (its modulus and density) and re-run the
  study. The first flap mode has to stay above 476 Hz, 1.2 × the two-blade pass at full throttle.
- Change the ESC current-sense filter (`RF` and `CF` in `electrical/esc/esc.circuit`) and re-run its
  `current_sense` simulation. The measures check the filter's corner, rise and settling time
  against their specs.
- Run the flight controller's `buck_startup` simulation and read the 5 V rail's start-up and
  ripple.
- Run Interference on `drone_folded.assembly` to check the stowed arms and blades.
- Ask the Agent to explode the board stack and make an assembly drawing of it.

[DESIGN-NOTES.md](DESIGN-NOTES.md) records the design decisions: each requirement, the analysis
behind it and the margin it reached.
