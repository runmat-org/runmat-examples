# Heated bar natural frequencies

Natural frequencies of a steel bar (1000 x 100 x 100 mm) clamped at both ends and heated 200 K. The clamps stop it growing, so it carries 5040 kN of axial compression that softens its bending modes. A thermal step, a preload and a prestressed modal step return the first two modes of the hot bar.

## Files

| File | What it is |
| --- | --- |
| `heated-bar-modes.fea` | The study, with its hand check in the header. |
| `geometry/heated-bar.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Bar`; faces `End A` and `End B`.

## The part

- Steel bar, 1000 × 100 × 100 mm.

## Setup

- Both ends clamped (`structural.fixed`) at 20 °C, then the bar is heated to 220 °C: both ends held at 220 °C with no other heat path, so the bar is uniform.
- Thermal steady → thermomechanical preload → prestressed modal, two modes.
- S275 steel: E = 210 GPa, ν = 0.3, ρ = 7850 kg/m³, α = 12 × 10⁻⁶ /K (EN 1993-1-1, 3.2.6).

## Hand check

- Thermal force P = EAαΔT = 210 GPa × 0.01 m² × 12 × 10⁻⁶ × 200 = 5040 kN.
- Clamped-clamped buckling load Pcr = 4π²EI / L² = 69 087 kN, so P/Pcr = αΔT A L² / (4π² I) = **0.0730**. E cancels.
- Mode 1 falls by about √(1 − P/Pcr) = **0.963**.
- Euler–Bernoulli puts the cold mode 1 at 4.730² / (2πL²) √(EI / (ρA)) = 531.7 Hz; the solid model reads lower, because shear deformation matters on a bar this stocky (L/h = 10). Hot, about 512 Hz by the same theory.

## Expected result

Mode 1 of the hot bar should be about 0.96 of the cold bar's mode 1. The earlier run of this bar on the thermal-stress page measured 0.959. Modal frequencies are published in the run's mode table.

Outputs: temperature, mode_shapes; modal frequencies in the run's mode table.
