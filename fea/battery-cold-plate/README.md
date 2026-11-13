# Battery module on its liquid cold plate

Module M01 of an EV battery pack (the module of `battery-module-cells`) on its liquid cold plate. The study solves the laminar coolant flow and the heat through the cells, the gap filler and the plate together, and reports the peak cell temperature against a 45 °C limit, the coolant's temperature rise and its pressure drop.

## Files

| File | What it is |
| --- | --- |
| `m01_cold_plate.part` | The cells, gap filler, plate and coolant in RunMat MCAD. Channel size, plate, land and pad thicknesses are inputs at the top; the layout comes from its generator in runmat-cad. |
| `geometry/m01-cold-plate.step` | The part exported to STEP AP242, with the body and face names the study selects. |
| `battery-cold-plate.fea` | The conjugate heat transfer study, with its hand checks in the header. |
| `DESIGN-NOTES.md` | How the channel, the plate and the gap filler were sized, with the hand checks and solved results. |

## The part

- Eight 34 × 500 × 95 mm prismatic cells at a 36 mm pitch, each on its own 3 mm gap-filler pad.
- A 296 × 520 × 8 mm brazed aluminum (3003) plate with a 1 mm land under each pad and a four-pass serpentine channel, 14 × 4 mm, under the cells' center lines. Inlet and outlet sit at the two corners of the plate's rear edge.
- The coolant is its own body; the plate is cut by it, so each channel wall is one surface with a fluid side and a plate side.

Names in the STEP file: bodies `M01 cell 1` to `M01 cell 8`, `Gap filler` (eight pads), `Cold plate` and `Coolant`; faces `Coolant inlet`, `Coolant outlet`, `Channel wall` (the coolant's side), `Plate channel wall` (the plate's side) and `M01 cell bottom`.

## Limits

- Coolant 50/50 water-glycol at 25 °C and 2 L/min: Re 1130, laminar. Above about 3.5 L/min the channel passes Re 2000, past what this study models.
- Peak cell temperature 45 °C at 20 W per cell (160 W), steady.
- Cells as isotropic blocks at 20 W/m/K; the plate's sides, the cell tops and the cell sides are adiabatic.

## What to change

- `channel_width` and `channel_depth` set the channel; the flow is the inlet velocity in `battery-cold-plate.fea` (0.595 m/s is 2 L/min in the 56 mm² channel).
- The cell load is the eight `heat_generation` loads: 12,384 W/m³ is 20 W per cell.
- After a change to the part, export it to `geometry/m01-cold-plate.step` and run the study again.
