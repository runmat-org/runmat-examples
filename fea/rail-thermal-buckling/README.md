# Rail thermal buckling

Thermal buckling of a steel rail, 2000 mm long with a 20 x 10 mm section, fixed at both ends and warmed 10 K. The ends stop it growing, so the warming becomes axial compression. A thermal step, a preload and a buckling step return the load factor on the 10 K rise at which the rail buckles, and the buckled shape.

## Files

| File | What it is |
| --- | --- |
| `rail-thermal-buckling.fea` | The study, with its hand check in the header. |
| `geometry/rail.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Rail`; faces `End A` and `End B`.

## The part

- Steel rail, 2000 mm long, 20 × 10 mm section.

## Setup

- Both ends fixed (`structural.fixed`) at 20 °C, then the rail warms to 30 °C: both ends held at 30 °C with no other heat path, so the rail is uniform.
- Thermal steady → thermomechanical preload → linear buckling, one mode.
- S275 steel: E = 210 GPa, ν = 0.3, α = 12 × 10⁻⁶ /K (EN 1993-1-1, 3.2.6).

## Hand check

A bar fixed at both ends buckles when its thermal force EAαΔT reaches 4π²EI/L², so

- ΔT_cr = 4π²I / (αAL²). About the weak axis, I = 20 × 10³ / 12 = 1667 mm⁴ and A = 200 mm²:
- ΔT_cr = 4π² × 1667 / (12 × 10⁻⁶ × 200 × 2000²) = **6.85 K** (27.4 K about the strong axis).
- The load factor on the 10 K rise is **0.685**: the rail buckles sideways, across its 10 mm thickness, after 6.85 K of warming.

## Expected result

The buckling load factor should read 0.685 within 2 %, with a single half-wave between the fixed ends in the 10 mm direction.

Outputs: temperature, buckled_shape; the load factor in the run's mode table.
