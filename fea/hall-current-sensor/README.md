# Hall current sensor: core flux at 500 A

An open-loop Hall current sensor: a gapped ferrite C-core round a copper primary, with the Hall element in the gap. The magnetostatic study solves the field of 500 A in the primary and reports the peak flux density in the core against the ferrite's saturation, and the field across the gap that the Hall element reads.

## Files

| File | What it is |
| --- | --- |
| `sensor.part` | The core, the primary rod and the air round them in RunMat MCAD. Core size, window, depth, gap and rod diameter are inputs at the top. |
| `geometry/sensor.step` | The part exported to STEP AP242, with the body and face names the study selects. |
| `hall-current-sensor.fea` | The magnetostatic study, with its hand check in the header. |
| `DESIGN-NOTES.md` | How the ferrite grade and the gap were chosen, with the hand checks and solved results. |

## The part

- Core: TDK N87 MnZn ferrite, 44 × 44 × 12 mm, a 26 mm square window, 9 mm legs, a 3 mm gap in the right leg.
- Primary: a 16 mm copper rod through the window's center, 120 mm long.
- Air: a 120 mm cube round both, less the core and the rod, so their faces are shared with the air.

Names in the STEP file: bodies `Core`, `Primary` and `Air`; faces `Primary in`, `Primary out`, `Gap` (the core's two pole faces) and `Outer boundary`.

## Limits

- N87 saturates at 490 mT at 25 °C and 390 mT at 100 °C (TDK N87 datasheet). The core is checked against 390 mT, its value at the sensor's 100 °C rating.
- Linear ferrite at its initial permeability, 2200; the study does not model the B–H curve's knee.
- DC primary current; no eddy currents.

## What to change

- `gap` sets the gap field and the core flux: B ≈ μ0 I / g. `outer`, `window` and `depth` size the core; `primary` the rod.
- The current density is the load in `hall-current-sensor.fea`: I / (π r²) for the rod's radius.
- After a change to the part, export it to `geometry/sensor.step` and run the study again.
