# Exhaust muffler transmission loss from 50 Hz to 2 kHz: a harmonic acoustic FEA study

This study sweeps a two-chamber exhaust muffler through the one-third-octave bands from 50 Hz to
2 kHz and reports its transmission loss, which must reach at least 15 dB in the 500 Hz band. The
muffler is a parametric RunMat MCAD part: 50 mm pipes into a 180 mm bore shell that a baffle splits
into two 170 mm chambers, each a quarter wavelength long at 500 Hz. By the plane-wave hand check,
each chamber alone gives 16.3 dB at 500 Hz, and the two in series should reach about 20 to 30 dB.

## The problem

A reactive muffler reduces exhaust noise by reflecting sound back toward the engine at its area
changes. A single expansion chamber of area ratio m and length L transmits less sound by

$$TL = 10 \log_{10}\left(1 + \tfrac{1}{4}\left(m - \tfrac{1}{m}\right)^2 \sin^2 kL\right)$$

The area ratio sets the peak loss and the length sets where it falls: the loss is greatest at
kL = π/2, a quarter wavelength, and falls to zero at kL = π. With a 180 mm bore on 50 mm pipes,
m = (180 / 50)² = 12.96, and the peak is 16.3 dB. A 160 mm bore (m = 10.24) peaks at 14.3 dB, under
the target with one chamber. The 170 mm chambers put the peak at 500 Hz: kL = 2π × 500 / 343 ×
0.170 = 1.557, close to π/2.

The plane-wave formula holds below the chamber's first radial mode, 1.84 c / (πD) = 1,116 Hz. Above
it, and for the coupling between the two chambers through the baffle's 50 mm opening, the 3D
acoustic solution takes over from the hand check.

## How the study works

1. **The part.** `muffler.part` builds the shell and the gas inside it as separate bodies, with the
   pipe, bore, chamber length and wall as inputs:

   ```
   input pipe : length = 50 mm
   input bore : length = 180 mm
   input chamber : length = 170 mm
   ```

   Its `air_only` configuration is exported to `geometry/muffler-air.step`, the gas body `Air` with
   faces `Inlet`, `Outlet` and `Walls`. The shell is a rigid wall to the gas, so only the gas is
   meshed.

2. **Mesh.** Quadratic tetrahedra at 15 mm: finer than the 28.6 mm that six elements per wavelength
   at 2 kHz needs, and three or more elements across the 50 mm pipes.

3. **Model.** Air at 20 °C (1.204 kg/m³, 343 m/s), rigid walls, a 1 Pa incident wave on the inlet and
   a radiation condition on the tail pipe:

   ```
   load engine_side {
       incident_pressure on geometry.muffler.region.inlet = 1 Pa
   }
   load tailpipe {
       acoustic.radiation { target = geometry.muffler.region.outlet }
   }
   ```

4. **Study.** A harmonic sweep at the one-third-octave centers, and the transmission loss between
   the inlet and the outlet:

   ```
   acoustic harmonic {
       frequencies = [50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000] Hz
   }
   output transmission_loss = transmission_loss(
       analysis.sound,
       incident = geometry.muffler.region.inlet,
       transmitted = geometry.muffler.region.outlet,
   )
   ```

## Results

Single-chamber plane-wave hand check, m = 12.96 and L = 170 mm:

| Band | Transmission loss of one chamber |
| --- | --- |
| 250 Hz | 13.3 dB |
| 400 Hz | 15.8 dB |
| 500 Hz | 16.3 dB |
| 630 Hz | 15.6 dB |
| 800 Hz | 12.1 dB |
| 1000 Hz | 0.1 dB |

The study returns the pressure field, the sound pressure level and the transmission loss in each
band. Compare the 500 Hz band with the 15 dB target and with the 20 to 30 dB that two chambers in
series should give. A single chamber passes sound near kL = π (1,009 Hz); look at the 1000 Hz band
to see how much of that pass band the second chamber and the baffle close.

## What to try

1. Change `speed_of_sound` to 500 m/s, about the speed in exhaust gas at 350 °C. Every band moves up
   by 500 / 343 = 1.46, so the tuned peak moves to 729 Hz, and one chamber gives 15.2 dB at 500 Hz.
2. Change `chamber` to 200 mm, export the `air_only` configuration to `geometry/muffler-air.step`,
   and run the sweep: the quarter-wave peak moves down to c / (4L) = 429 Hz.
3. Change `bore` to 160 mm and compare the 500 Hz band with the target.

## Files

- `exhaust-muffler.fea`: the harmonic acoustic sweep, with its plane-wave hand check in the header.
- `materials.module`: the material the study imports, `air`.
- `muffler.part`: the shell and its gas in RunMat MCAD, with pipe, bore, chamber length and wall thickness as inputs.
- `geometry/muffler-air.step`: the gas, exported from the part's `air_only` configuration, with the body and face names the study selects.
- `DESIGN-NOTES.md`: how the area ratio, the chamber lengths and the shell were chosen, with the hand checks.
- `runmat.toml`: the project file.

## Related

- [Acoustic simulation in RunMat](https://runmat.com/simulation/acoustics)
- [Acoustic physics reference](https://runmat.com/docs/simulation/physics/acoustic) and [acoustic loads](https://runmat.com/docs/simulation/loads/acoustic)
- [Sound pulse in a duct](../duct-pulse) and [listening room modes](../listening-room-modes)
- [Download RunMat](https://runmat.com/download)
