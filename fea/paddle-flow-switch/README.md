# Paddle flow switch: paddle deflection in oil flow

A paddle flow switch in a 2-inch tee. Steady oil flow bends a thin spring-steel paddle downstream, and the switch trips at 1 mm of tip travel. The study solves the oil flow and the paddle's bending together and reports the tip deflection and the stress at the paddle's root.

## Files

| File | What it is |
| --- | --- |
| `flow_switch.part` | The tee, the oil in it and the paddle in RunMat MCAD. Run and boss bores, paddle thickness, width and length are inputs at the top. |
| `geometry/flow_switch.step` | The part exported to STEP AP242, with the body and face names the study selects. |
| `paddle-flow-switch.fea` | The fluid-structure study, with its hand check in the header. |
| `DESIGN-NOTES.md` | How the paddle was sized for the trip travel, with the hand checks and solved results. |

## The part

- Tee: a schedule 40 steel run, 52.5 mm bore, 60.3 mm outside, 240 mm long, with a 1-inch switch boss on top (27 mm bore, 42 mm outside, 70 mm tall).
- Paddle: EN 1.4310 spring steel, 0.5 × 24 mm, hanging 82 mm from its clamp at the top of the boss to 12 mm below the run's axis.
- Oil: the run's and the boss's bores less the paddle.

Names in the STEP file: bodies `Tee`, `Oil` and `Paddle`; faces `Inlet`, `Outlet`, `Pipe wall`, `Paddle wetted` (the oil's side), `Paddle surface` (the paddle's side), `Paddle root` and `Tee ends`.

## Limits

- Trip travel 1 mm at the tip, at 1 m/s of ISO VG 46 oil at 40 °C (Re 1140, laminar).
- Small deflections, linear elastic steel; steady flow.

## What to change

- `paddle`, `paddle_width` and `paddle_length` set the paddle's stiffness and the area the oil pushes on; deflection goes as length³ / thickness³.
- The flow speed is the inlet velocity in `paddle-flow-switch.fea`.
- After a change to the part, export it to `geometry/flow_switch.step` and run the study again.
