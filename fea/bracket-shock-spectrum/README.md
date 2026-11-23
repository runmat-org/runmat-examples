# Pyroshock response of a steel bracket: a shock response spectrum FEA study

This study checks a steel wall-hook bracket, 40 × 50 × 35 mm and bolted at its three mounting holes,
against a pyrotechnic shock along the wall. The shock is given as a 5 % damped shock response
spectrum (SRS) that rises from 20 g at 100 Hz to a 1,000 g plateau from 2 kHz. The study finds the
bracket's first 30 modes, reads each mode's response off the spectrum, and combines them by CQC
into peak displacement and von Mises stress fields.

## The problem

Separation bolts, pyrotechnic valves and stage separations send a short, very high-frequency shock
through a structure. The shock is too short and too complex to specify as a time history, so test
and design specifications give it as a shock response spectrum: the peak acceleration that a
single-degree-of-freedom oscillator with 5 % damping would reach, plotted against the oscillator's
natural frequency.

A response spectrum analysis uses that curve directly. Each mode of the bracket acts as one such
oscillator: its peak response is the spectrum's value at the mode's frequency, scaled by how much
mass the mode moves in the shock direction. The modes peak at different instants, so their peaks
are combined statistically. The complete quadratic combination (CQC) accounts for the correlation
between modes whose frequencies lie close together, where a plain square root of the sum of squares
would not.

The spectrum here, along the wall (Y):

| Frequency | SRS, 5 % damping |
| --- | --- |
| 100 Hz | 20 g |
| 2,000 Hz and above | 1,000 g |

## How the study works

1. **Geometry and mesh.** `geometry/bracket.step` is the bracket of the
   [wall-hook load study](../bracket-hook-load), with body `WallHook_30mm` and faces
   `Mounting holes`. Linear tetrahedra at 6 mm.

2. **Material and supports.** Steel (E = 200 GPa, ν = 0.3, 7,850 kg/m³), with the mounting-hole
   faces fixed where the bolts hold them.

3. **The spectrum.** The SRS as pseudo-acceleration along Y, with the modal and directional
   combination rules and a 90 % mass check:

   ```
   response_spectrum pyroshock_y {
       frequencies = [100, 2000, 100000] Hz
       ordinates = [20, 1000, 1000] g
       damping_ratio = 0.05
       response = pseudo_acceleration
       direction = [0, 1, 0]
       modal_combination = cqc
       directional_combination = srss
       minimum_cumulative_mass_ratio = 0.9
   ```

4. **Modes, then the spectrum response.** A modal analysis keeps a basis of 30 modes, and the
   response spectrum analysis runs on it:

   ```
   analysis modes {
       structural modal { modes = 30 }
       retain basis
   }
   analysis shock after analysis.modes {
       structural modal_response_spectrum {
           basis = analysis.modes.state.basis
           spectra = [model.response_spectrum.pyroshock_y]
       }
   }
   ```

## Results

| Quantity | Value |
| --- | --- |
| Spectrum | 20 g at 100 Hz to 1,000 g from 2 kHz, 5 % damping |
| Modes in the basis | 30 |
| Modal combination | CQC |
| Required cumulative mass ratio along Y | 90 % |

The study returns the bracket's natural frequencies and participations in the run's mode table, and
the combined peak displacement and von Mises stress fields. Read each mode's frequency against the
spectrum: a mode at or above 2 kHz sees the full 1,000 g, and one well below it sees much less.
Compare the peak von Mises stress with the steel's yield strength. The combination estimates the
peak of each quantity separately, so the fields do not show the bracket at one instant.

## What to try

1. Halve the ordinates to [10, 500, 500] g. The analysis is linear, so every response halves.
2. Change `modal_combination` to `srss` and compare the peak stress with CQC; the difference shows
   how strongly the closely spaced modes interact.
3. Reduce the basis to `modes = 10` and see whether it still reaches the 90 % mass ratio the
   spectrum requires.

## Files

- `bracket-shock-spectrum.fea`: the modal and response spectrum study.
- `materials.module`: the material the study imports, `steel`.
- `geometry/bracket.step`: the bracket as STEP, with the body and mounting-hole names the study selects.
- `runmat.toml`: the project file.

## Related

- [Structural simulation in RunMat](https://runmat.com/simulation/structural)
- [Modal and response spectrum study guide](https://runmat.com/docs/simulation/language/guides/modal-and-response-spectrum-study) and [modal analysis guide](https://runmat.com/docs/simulation/guides/modal-analysis)
- [Bracket random vibration](../bracket-random-vibration) and [wall-hook bracket under load](../bracket-hook-load)
- [Shock response spectrum of a pyroshock-like transient](../../aerospace/shock-response-spectrum)
- [Download RunMat](https://runmat.com/download)
