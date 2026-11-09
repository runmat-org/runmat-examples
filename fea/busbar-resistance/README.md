# Busbar resistance with a bolt hole

DC current flow in a copper busbar strip, 200 x 30 x 3 mm, with a 9 mm bolt hole at its middle. 100 A flows end to end. The study returns the potential, the current density, the voltage across the strip, which gives its resistance, and the current crowding beside the hole.

## Files

| File | What it is |
| --- | --- |
| `busbar-resistance.fea` | The study, with its hand check in the header. |
| `geometry/busbar-bolt-hole.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Busbar`; faces `Terminal A`, `Terminal B` and `Bolt hole`.

## The part

- Copper strip, 200 × 30 × 3 mm, with a 9 mm hole (M8 medium clearance, ISO 273) at its middle.

## Setup

- 100 A into `Terminal A`; `Terminal B` at 0 V.
- Copper σ = 58 MS/m at 20 °C (IEC 60028).
- Steady current flow.

## Hand check

- Plain strip: R = ρL / (Wt) = (1/58 × 10⁶) × 0.2 / (0.03 × 0.003) = **38.31 μΩ**.
- A small round hole of radius a in a sheet of width W adds about 2πa²/W² squares of sheet resistance (ρ/t = 5.75 μΩ): 0.81 μΩ here.
- Total about **39.1 μΩ**, so `Terminal A` sits at **3.91 mV** at 100 A.
- The mean current density is 1.11 A/mm² in the strip and 1.59 A/mm² over the net section at the hole. In a wide sheet, current at the sides of a round hole reaches twice the far-field density, 2.22 A/mm²; the strip's finite width adds a little to that.

## Expected result

`terminal_voltage` should read 3.91 mV within 1 %. `hole_edge_current_density` should read about 2.2 to 2.5 A/mm².

Outputs: potential, current_density, terminal_voltage, peak_current_density, hole_edge_current_density.
