# Six-bolt EV busbar: temperature at 400 A

A copper module busbar that collects six cells on M8 terminal bolts and hands 400 A to the module's output cable on one M10 bolt. The study solves current flow and temperature together, with copper's resistivity rising 0.39 % per kelvin, and reports the peak temperature against an 85 °C limit.

## Files

| File | What it is |
| --- | --- |
| `busbar.part` | The busbar in RunMat MCAD. Its length, width, thickness, bolt sizes and pitch are inputs at the top. |
| `geometry/busbar.step` | The part exported to STEP AP242, with the body and face names the study selects. |
| `six-bolt-busbar.fea` | The electrothermal study, with its hand check in the header. |
| `DESIGN-NOTES.md` | How the strap section and the material were chosen, with the hand checks and solved results. |

## The part

- Strap: 200 × 30 × 2 mm Cu-ETP (C11000) with R5 corners.
- Six 8.5 mm cell-bolt holes (M8 clearance) at a 27 mm pitch from 15 mm; one 10.5 mm output-bolt hole (M10 clearance) 18 mm from the far end.

Names in the STEP file: body `Busbar`; faces `Cell bolt 1` to `Cell bolt 6`, `Output bolt` and `Exterior`.

## Limits

- Peak temperature 85 °C at 400 A continuous, in still air at 25 °C (10 W/m²/K).
- The bolted joints are perfect contacts, and the cell terminals and the cable carry no heat away. Real joints add contact resistance and real terminals sink heat; this study bounds the strap's own heating.
- Each cell feeds the same 66.7 A.

## Result

Solved on 75,168 linear tetrahedra (2 mm): the strap runs from 56.8 °C at the first cell bolt to a peak of 63.4 °C between cell bolt 6 and the output bolt, 21.6 K under the 85 °C limit. The study's assessment `stays_below_85_celsius` (`maximum = 85 degC` on `peak_temperature`) passes, and the temperature legend reads in °C with the margin. The hand estimate in [DESIGN-NOTES.md](DESIGN-NOTES.md) gives about 56 °C for the strap as one temperature.

## What to change

- `width` and `thickness` set the section; `pitch`, `first_bolt` and `output_inset` move the bolts.
- The current is the six 66.667 A loads in `six-bolt-busbar.fea`; the cooling is `still_air`.
- After a change to the part, export it to `geometry/busbar.step` and run the study again.
