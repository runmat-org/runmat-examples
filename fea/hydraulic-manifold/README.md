# Hydraulic manifold: pressure drop P to A

A crossover manifold block in 6061-T6 aluminum with two drilled lines, and the oil that fills
them. The study solves laminar flow of ISO VG 46 oil at 40 °C through both lines at 20 L/min and
reports the pressure drop from P to A against a 1 bar budget.

## Files

| File | What it is |
| --- | --- |
| `manifold.part` | The block and its oil in RunMat MCAD. Every size the study depends on is an input at the top. |
| `geometry/manifold-oil.step` | The oil of the part (configuration `oil_only`) exported to STEP AP242, with the body and face names the study selects. The block is a rigid wall to the oil, so the study meshes the oil alone. |
| `hydraulic-manifold.fea` | The flow study, with its hand check in the header. |

## The part

- Block: 90 × 80 × 50 mm, 1 mm breaks on the vertical edges, four M8 counterbored bolt holes.
- P to A: a 12 mm supply gallery drilled 60 mm from the left face (port P) to a flat bottom; the 10 mm work port A drops into it from the top face.
- B to T: the 10 mm work port B drops from the top face into a 12 mm return gallery drilled from the right face (port T).
- Oil: its own body in each line, named `Oil`. The block is cut by the same bodies, so each passage wall is one surface shared by the block and the oil.

Names: the part exports bodies `Block` and `Oil`; the study's STEP carries `Oil` with its faces `Port P`, `Port T`, `Port A`, `Port B` and `Passage wall` (the oil's side).

## Design notes

[DESIGN-NOTES.md](DESIGN-NOTES.md) records how the bore sizes, the layout and the material were chosen, with the hand checks and the solved results.

## Limits

- Loss budget: 1 bar from P to A at 20 L/min.
- Laminar flow only: Re = 922 in the 10 mm ports and 768 in the 12 mm galleries at 20 L/min. Above about 40 L/min the ports pass Re 2000, past what this study models.
- The oil is isothermal at 40 °C (46 cSt). Cold oil is thicker and raises the drop in proportion to its viscosity.

## What to change

- `bore` and `gallery` set the port and gallery diameters; `p_depth`, `a_x`, `t_depth` and `b_x` move the drillings.
- The flow rate is the inlet velocity in `hydraulic-manifold.fea` (2.947 m/s in the 12 mm gallery is 20 L/min).
- After a change to the part, export its `oil_only` configuration to `geometry/manifold-oil.step` and run the study again.
