# AC resistance and skin effect in a round copper conductor: a harmonic electromagnetic FEA study

This study finds the AC resistance of a 20 mm copper rod at 50 Hz and 1 kHz. A 30 mm length carries
1000 A peak and returns through a coaxial, perfectly conducting shell, with air between. At each
frequency the study solves the full field with skin effect in the copper and returns the loss
density, and the run reports the power delivered at the terminals. The exact Bessel-function
solution gives Rac/Rdc = 1.027 at 50 Hz and 2.662 at 1 kHz.

## The problem

Alternating current crowds toward a conductor's surface, so the inner copper carries less of it and
the resistance rises with frequency. The depth over which the current falls by 1/e is the skin
depth, δ = √(2 / (ωμσ)): 9.35 mm at 50 Hz and 2.09 mm at 1 kHz in copper. For busbars and cables at
power frequency, and for windings and leads at kilohertz, the AC resistance sets the loss and the
temperature rise.

A round wire of radius a has an exact solution:

$$\frac{Z}{R_{dc}} = \frac{ka}{2}\,\frac{J_0(ka)}{J_1(ka)}, \qquad k = \frac{1-j}{\delta}$$

Its real part is Rac/Rdc. With copper at σ = 58 MS/m (IEC 60028), the 30 mm rod's DC resistance is
1.646 µΩ, so 1000 A peak dissipates 0.823 W at DC. The perfectly conducting return adds only
reactance, so all the loss is in the rod.

## How the study works

1. **Geometry and mesh.** `geometry/round-conductor.step` holds the rod (`Conductor`, 20 mm
   diameter, 30 mm long) and a coaxial air space out to 15 mm radius (`Air`), sharing their faces.
   The air's outer cylinder is `Return shell` and its end annuli are `End plates`. Linear tetrahedra
   at 1.2 mm, under the 2.09 mm skin depth at 1 kHz.

2. **Materials.** Copper at 58 MS/m and air with zero conductivity, both at μr = 1.

3. **Model.** 1000 A into `Terminal in`, `Terminal out` at 0 V, and the shell and end plates
   grounded, which makes them a perfectly conducting coaxial return:

   ```
   constraint return_path {
       magnetic.vector_potential_ground { target = geometry.conductor.region.return_shell }
   }
   load drive {
       electric_current on geometry.conductor.region.terminal_in = 1000 A
   }
   ```

4. **Study.** A harmonic electromagnetic analysis at both frequencies, each solved on its own, with
   the Joule loss density and its peak in the rod:

   ```
   analysis field { electromagnetic harmonic { frequencies = [50, 1000] Hz } }
   output loss_density = analysis.field.field.element.joule_power_density
   output peak_loss_density = max(analysis.field.field.element.joule_power_density, over = geometry.conductor.region.rod)
   ```

## Results

| Quantity | 50 Hz | 1 kHz |
| --- | --- | --- |
| Skin depth δ | 9.35 mm | 2.09 mm |
| a/δ | 1.07 | 4.79 |
| Rac / Rdc, exact | 1.027 | 2.662 |
| Loss at 1000 A peak | 0.845 W | 2.191 W |
| Peak loss density at the surface | 0.099 MW/m³ | 1.109 MW/m³ |

The study returns the loss density and `peak_loss_density` at each frequency, and the run reports
the terminal voltage, current and complex power. Divide the delivered power, ½Re(UĪ), by the
0.823 W DC loss to get Rac/Rdc, and compare with 1.027 and 2.662, within 2 %. `peak_loss_density`
is an element average, so it reads a few percent under the surface values. On a cross-section of
the 1 kHz loss density, compare how far in from the surface the loss reaches with the 2.09 mm skin
depth.

## What to try

1. Add 400 Hz to `frequencies`. The exact solution gives δ = 3.30 mm and Rac/Rdc = 1.782.
2. Change the list to 60 Hz for a 60 Hz grid. The exact solution gives Rac/Rdc = 1.038.
3. Coarsen `target_size` to 3 mm, coarser than the 1 kHz skin depth, and compare the 1 kHz loss
   with 2.191 W.

## Files

- `round-conductor-ac.fea`: the harmonic electromagnetic study, with the Bessel-function check in its header.
- `materials.module`: the materials the study imports: `copper` and `air`.
- `geometry/round-conductor.step`: the rod and the air space as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Electrothermal simulation in RunMat](https://runmat.com/simulation/electrothermal)
- [Electromagnetic physics reference](https://runmat.com/docs/simulation/physics/electromagnetic) and [electromagnetic loads](https://runmat.com/docs/simulation/loads/electromagnetic)
- [Copper busbar resistance with a bolt hole](../busbar-resistance) and [coaxial bushing electric field](../coaxial-bushing)
- [Download RunMat](https://runmat.com/download)
