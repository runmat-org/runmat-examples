# Vibration of a heated titanium panel under exhaust noise: a prestressed harmonic FEA study

This study finds how a titanium heat-shield panel beside an engine exhaust responds to noise once
it is hot. The 200 × 200 × 6 mm Ti-6Al-4V panel is clamped on all four edges and runs 150 K above
the temperature it was fitted at, so the frame holds it in compression. The study chains four
analyses: heat, thermal preload, prestressed modes and a modal frequency sweep from 500 Hz to
1.6 kHz under a uniform 1 kPa. By hand, mode 1 falls from 1,338 Hz cold to about 1,000 Hz hot.

## The problem

Thermal stress changes a structure's stiffness. A panel clamped in a cooler frame cannot grow as
it heats, so it carries in-plane compression, which lowers its bending frequencies, and at a high
enough temperature it buckles. A vibration check made at room temperature then puts the resonances
in the wrong place. Exhaust noise is broadband, so the question is where the hot modes fall within
the noise band and how far the panel moves at each.

For the cold panel, the plate stiffness is D = Eh³ / (12(1 − ν²)) = 2,320 N·m, and Leissa's
clamped-square-plate result gives mode 1 at

$$f_1 = \frac{35.99}{2\pi a^2}\sqrt{\frac{D}{\rho h}} = 1338\ \text{Hz}$$

Uniform heating buckles the clamped panel at

$$\Delta T_{cr} = \frac{5.31\,\pi^2 h^2}{12\,(1+\nu)\,\alpha\,a^2} = 341\ \text{K}$$

(Timoshenko and Gere). At 150 K the compression is 0.44 of the buckling level, and mode 1 falls by
about √(1 − 0.44) = 0.75, to near 1,000 Hz. The ratio estimate is approximate, so the study's mode
table is the number to use.

## How the study works

1. **Geometry and mesh.** `geometry/titanium-panel.step` holds the panel as body `Panel`, with faces
   `Clamped edges`, `Exhaust side` and `Outer side`. Quadratic tetrahedra at a 5 mm target size.

2. **Material.** Annealed Ti-6Al-4V (ASM data sheet): E = 113.8 GPa, ν = 0.342, ρ = 4,430 kg/m³,
   α = 8.6 × 10⁻⁶ /K. A Rayleigh stiffness coefficient of 6.4 µs gives about 2 % of critical
   damping at 1 kHz; that is a modeling choice.

3. **Model.** The edges are clamped and held at 170 °C with no other heat path, so the whole panel
   reaches 170 °C, 150 K above the 20 °C reference. The noise is 40 N on the exhaust side, which is
   1 kPa over the 200 × 200 mm face, flat from 500 Hz to 1.6 kHz.

4. **Four analyses in a chain.** Each one takes the previous state:

   ```
   analysis heat { thermal steady {} retain heated }
   analysis preload after analysis.heat {
       thermomechanical preload { temperature = analysis.heat.state.heated }
       load_cases = []
   }
   analysis modes after analysis.preload {
       structural prestressed_modal {
           prestress = analysis.preload.state.geometric_stiffness
           modes = 6
       }
       retain basis
   }
   ```

5. **The sweep.** A prestressed harmonic analysis on the six hot modes, with static correction for
   the modes left out, at 11 frequencies clustered around 1 kHz:

   ```
   structural prestressed_harmonic {
       prestress = analysis.preload.state.geometric_stiffness
       basis = analysis.modes.state.basis
       frequencies = [500, 700, 800, 900, 950, 1000, 1050, 1100, 1200, 1400, 1600] Hz
       static_correction = applied_loads
   }
   ```

## Results

| Quantity | Hand check |
| --- | --- |
| Plate stiffness D | 2,320 N·m |
| Cold mode 1 | 1,338 Hz |
| Buckling temperature rise | 341 K |
| Hot mode 1 at 150 K | about 1,000 Hz |
| Damping at 1 kHz | about 2 % of critical |

The study returns the six hot mode shapes, with their frequencies in the run's mode table, and the
displacement across the sweep. Compare hot mode 1 with the 1,000 Hz estimate, within about 5 %. The
response should peak near it, inside the 500 Hz to 1.6 kHz band; the sweep points between 900 and
1,100 Hz are there to resolve that peak.

## What to try

1. Lower the running temperature to 120 °C (`hot_edges` 393.15 K), a 100 K rise. The same estimate
   puts hot mode 1 near 1,124 Hz.
2. Raise it to 220 °C (493.15 K), a 200 K rise and 0.59 of the buckling level. Mode 1 falls near
   859 Hz; add sweep points around it.
3. Change `stiffness_coefficient` to 3.2 µs, about 1 % of critical at 1 kHz, and compare the
   resonant peak's height.

## Files

- `heated-panel-harmonic.fea`: the four-analysis study, with its hand check in the header.
- `materials.module`: the material the study imports, `ti_6al_4v`.
- `geometry/titanium-panel.step`: the panel as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Thermomechanical simulation in RunMat](https://runmat.com/simulation/thermomechanical)
- [Modal analysis guide](https://runmat.com/docs/simulation/guides/modal-analysis) and [thermal stress guide](https://runmat.com/docs/simulation/guides/thermal-stress)
- [Heated bar natural frequencies](../heated-bar-modes) and [cantilever beam frequency response](../cantilever-harmonic)
- [Download RunMat](https://runmat.com/download)
