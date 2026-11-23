# Random vibration of a steel bracket under a qualification PSD: a random response FEA study

This study shakes a steel wall-hook bracket, 40 × 50 × 35 mm and bolted at its three mounting holes,
with a 20 to 2,000 Hz base-acceleration PSD along the wall. The profile is shaped like the NASA GEVS
component qualification profile, with a 0.16 g²/Hz plateau from 50 to 800 Hz, and integrates to
14.2 g RMS. The study finds the bracket's first 20 modes, then combines their responses with 3 %
modal damping into RMS displacement and RMS von Mises stress fields.

## The problem

Hardware mounted on a vehicle, an aircraft or a launch vehicle sees broadband vibration, specified
as a power spectral density (PSD) of base acceleration rather than as one load. A qualification
test shakes the part with that PSD, and a random vibration analysis predicts the result first: the
statistical response of every point, as an RMS value, from the excitation's spectrum and the
structure's modes.

The input here is a one-sided acceleration PSD with 6 dB per octave slopes, so the level goes as f²
on the rise and 1/f² on the fall:

| Frequency | PSD |
| --- | --- |
| 20 Hz | 0.026 g²/Hz |
| 50 to 800 Hz | 0.16 g²/Hz |
| 2,000 Hz | 0.026 g²/Hz |

The study's breakpoints at 30, 40, 1,000, 1,250 and 1,600 Hz follow those slopes, and the profile
integrates to

$$a_{rms} = \sqrt{\int_{20}^{2000} S_a(f)\,df} = \sqrt{201.4\ \text{g}^2} = 14.2\ \text{g}$$

The modes inside the band, and how much mass each one moves along the wall, set how much of that
input the bracket picks up. Designers commonly compare three times the RMS stress, the 3σ level,
with the material's allowable.

## How the study works

1. **Geometry and mesh.** `geometry/bracket.step` is the bracket of the
   [wall-hook load study](../bracket-hook-load), with body `WallHook_30mm` and faces
   `Mounting holes`. Linear tetrahedra at 6 mm.

2. **Material and supports.** Steel (E = 200 GPa, ν = 0.3, 7,850 kg/m³), with the mounting-hole
   faces fixed where the bolts hold them.

3. **The excitation.** The base-acceleration PSD along Y:

   ```
   random_excitation qualification {
       frequencies = [20, 30, 40, 50, 800, 1000, 1250, 1600, 2000] Hz
       channels = [
           { id = "y", quantity = base_acceleration, direction = [0, 1, 0] },
       ]
       spectral_density_real = [
           [[0.026]], [[0.0585]], [[0.104]], [[0.16]], [[0.16]],
           [[0.1024]], [[0.0655]], [[0.04]], [[0.026]],
       ] g^2/Hz
       convention = one_sided_per_hertz
   ```

4. **Modes, then random response.** A modal analysis keeps its basis of 20 modes, and the random
   response runs on it with 3 % damping. It checks that the basis captures at least 80 % of the
   mass moving in the excitation direction:

   ```
   analysis random after analysis.modes {
       structural random_response {
           basis = analysis.modes.state.basis
           excitation = model.random_excitation.qualification
           modal_damping_ratio = 0.03
           minimum_cumulative_mass_ratio = 0.8
       }
   }
   ```

## Results

| Quantity | Value |
| --- | --- |
| Input level | 14.2 g RMS, 20 to 2,000 Hz |
| Plateau | 0.16 g²/Hz, 50 to 800 Hz |
| Modal damping | 3 % |
| Modes in the basis | 20 |
| Required cumulative mass ratio along Y | 80 % |

The study returns the bracket's natural frequencies in the run's mode table, with each mode's
participation, and the RMS displacement and RMS von Mises stress fields. Look for the modes that
fall inside the 50 to 800 Hz plateau and carry most of the Y mass: they produce most of the
response. Then find where the RMS von Mises field peaks and compare three times that value with the
steel's allowable.

## What to try

1. Raise the plateau to 0.32 g²/Hz, scaling every point by 2. The input rises by √2 to 20.1 g RMS,
   and since the analysis is linear, every RMS result rises by √2 too.
2. Change `modal_damping_ratio` to 0.05 and compare the RMS stress.
3. Change the channel's `direction` to [1, 0, 0] or [0, 0, 1] to shake along another axis, and
   compare which modes respond.

## Files

- `bracket-random-vibration.fea`: the modal and random response study.
- `materials.module`: the material the study imports, `steel`.
- `geometry/bracket.step`: the bracket as STEP, with the body and mounting-hole names the study selects.
- `runmat.toml`: the project file.

## Related

- [Structural simulation in RunMat](https://runmat.com/simulation/structural)
- [Modal and response spectrum study guide](https://runmat.com/docs/simulation/language/guides/modal-and-response-spectrum-study) and [modal analysis guide](https://runmat.com/docs/simulation/guides/modal-analysis)
- [Bracket shock response](../bracket-shock-spectrum) and [wall-hook bracket under load](../bracket-hook-load)
- [Random vibration response of one mode](../../aerospace/random-vibration)
- [Download RunMat](https://runmat.com/download)
