# Exhaust muffler: transmission loss

A two-chamber exhaust muffler and the gas inside it. The study solves the acoustic field in the gas from 50 Hz to 2 kHz in one-third-octave bands and reports the transmission loss, which must reach at least 15 dB in the 500 Hz band.

## Files

| File | What it is |
| --- | --- |
| `muffler.part` | The shell and its gas in RunMat MCAD. Pipe, bore, chamber length and wall thickness are inputs at the top. |
| `geometry/muffler-air.step` | The gas of the part (configuration `air_only`) exported to STEP AP242, with the body and face names the study selects. The shell is a rigid wall to the gas, so the study meshes the gas alone. |
| `exhaust-muffler.fea` | The harmonic acoustic sweep, with its hand check in the header. |
| `DESIGN-NOTES.md` | How the area ratio and the chamber lengths were chosen, with the hand checks and solved results. |

## The part

- 50 mm inlet pipe, 100 mm long; 180 mm bore shell; a 1.5 mm baffle with a 50 mm central opening splits it into two 170 mm chambers; 50 mm tail pipe, 100 mm long. All 1.5 mm aluminized steel.
- The gas ("Air") is its own body: the inlet bore, both chambers and the tail-pipe bore. The shell is the envelope less the gas, so each wall is one surface shared by the two.

Names: the part exports bodies `Shell` and `Air`; the study's STEP carries `Air` with its faces `Inlet`, `Outlet` and `Walls` (the gas's side).

## Limits

- At least 15 dB transmission loss in the 500 Hz one-third-octave band.
- Air at 20 °C (343 m/s). Hot exhaust raises the speed of sound and moves every tuned band up in proportion.
- Rigid walls, no flow, no absorption. The plane-wave tuning holds below the chamber's first radial mode, 1,116 Hz.

## What to change

- `chamber` tunes the quarter-wave peak: f = c / (4 L). `bore` and `pipe` set the area ratio, which sets the peak loss.
- After a change to the part, export its `air_only` configuration to `geometry/muffler-air.step` and run the study again.
