# Hall current sensor core flux at 500 A: a magnetostatic FEA study of a gapped ferrite core

This study solves the magnetic field of an open-loop Hall current sensor carrying 500 A: a
44 × 44 × 12 mm N87 ferrite C-core with a 3 mm gap, a 16 mm copper primary rod through its window,
and the air around both. It reports the peak flux density in the core, checked against the
ferrite's 390 mT saturation at 100 °C, and the field in the gap where the Hall element sits. By
Ampère's law the gap carries 0.205 T, 53 % of saturation. The sensor is a parametric RunMat MCAD
part.

## The problem

An open-loop Hall sensor measures a current without contact: the ferrite core gathers the primary's
magnetic field into a gap, and a Hall element in the gap reads it. The reading stays proportional to
the current only while the core stays linear, so the designer sizes the gap to keep the core under
saturation at the rated current and hottest operating temperature. A wider gap lowers the flux and
the sensitivity together.

With one primary turn, a gap g and a mean core path l = 4 × 35 mm − 3 mm = 137 mm,

$$B = \frac{\mu_0 I}{g + l/\mu_r} = \frac{4\pi\times10^{-7} \times 500}{3\ \text{mm} + 137\ \text{mm}/2200} = 0.205\ \text{T}$$

across the gap and, less the gap's fringing, in the legs. TDK N87 has an initial permeability of
2200 and saturates at 490 mT at 25 °C and 390 mT at 100 °C, so the core runs at 53 % of its 100 °C
saturation. The 3D study adds what the hand check leaves out: fringing at the gap and flux crowding
at the window's inner corners, where the peak sits.

## How the study works

1. **The part.** `sensor.part` builds the core with a 26 mm window and 9 mm legs, the gap in its
   right leg, the rod and a 120 mm cube of air, with the sizes as inputs:

   ```
   input outer : length = 44 mm
   input window : length = 26 mm
   input depth : length = 12 mm
   input gap : length = 3 mm
   input primary : length = 16 mm
   ```

   It is exported to `geometry/sensor.step`, where the core, rod and air share their faces.

2. **Mesh.** Linear tetrahedra at 6 mm, refined to 1.5 mm in the core.

3. **Materials.** N87 ferrite as a linear material at its initial permeability, 2200. Copper and air
   at μr = 1. The study does not model the B–H curve's knee.

4. **Model.** Magnetostatics with 500 A along the rod, as a current density of
   500 / (π × 8² mm²) = 2.487 × 10⁶ A/m², and the vector potential grounded on the air's outer
   boundary and the rod's ends:

   ```
   electromagnetic { equation = magnetostatics }
   load primary_current {
       magnetic_volume_current_density on geometry.sensor.region.primary = [0, 0, 2487000] A/m^2
   }
   ```

5. **Outputs.** The peak flux density in the core, and the peak in the air, which sits in the gap:

   ```
   output peak_core_flux = max(magnitude(output.flux_density), over = geometry.sensor.region.core)
   output gap_flux = max(magnitude(output.flux_density), over = geometry.sensor.region.air)
   ```

## Results

| Quantity | Hand check | Limit |
| --- | --- | --- |
| Flux density across the gap | 0.205 T | |
| Core flux density, away from corners | 0.205 T, less fringing | 0.390 T at 100 °C |
| Rod's own surface field, μ0I / (2πr) | 12.5 mT | |

The study returns the flux density field and `peak_core_flux` and `gap_flux`. Compare
`peak_core_flux` with 390 mT; it sits at the window's inner corners and runs above the uniform
0.205 T. `gap_flux` is read in the air: the rod's own surface field is only 12.5 mT, so the air's
peak is in the gap. Fringing at the pole corners puts it a little over the field at the gap's
middle, where the Hall element sits.

## What to try

1. Change `gap` to 1.5 mm and export the part again. The hand check gives 0.40 T, over the 100 °C
   saturation.
2. Raise the current to 800 A (3,979,000 A/m²). The hand check gives 0.328 T in the gap; compare
   `peak_core_flux` with 390 mT.
3. Change `relative_permeability` of the ferrite to 1,000. The hand check moves only from 0.205 T to
   0.200 T, because with a 3 mm gap the core's l/μr term is a small part of the total.

## Files

- `hall-current-sensor.fea`: the magnetostatic study, with the Ampère's-law hand check in its header.
- `sensor.part`: the core, the primary rod and the air in RunMat MCAD, with core size, window, depth, gap and rod diameter as inputs.
- `geometry/sensor.step`: the part exported to STEP, with the body and face names the study selects.
- `DESIGN-NOTES.md`: how the ferrite grade, the gap and the window were chosen, with the hand checks.
- `runmat.toml`: the project file.

## Related

- [Electromagnetic simulation in RunMat](https://runmat.com/simulation/electromagnetic)
- [Electromagnetic physics reference](https://runmat.com/docs/simulation/physics/electromagnetic) and [electromagnetic loads](https://runmat.com/docs/simulation/loads/electromagnetic)
- [Coaxial bushing electric field](../coaxial-bushing) and [AC resistance of a round conductor](../round-conductor-ac)
- [Download RunMat](https://runmat.com/download)
