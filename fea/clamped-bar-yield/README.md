# Thermal stress in a restrained steel bar heated past yield: an elastic-plastic FEA study

This study heats an S275 steel bar, 16 × 16 mm and 200 mm long, by 150 K while rigid walls stop it
from growing. The restraint turns the thermal expansion into axial compression, which reaches the
275 MPa yield strength at a 109.1 K rise. The study applies the heating in load steps with J2
plasticity and returns the stress and displacement at full heating. By hand, the stress holds at
275.0 MPa with a plastic strain of 4.9 × 10⁻⁴, where an elastic model would give 378 MPa.

## The problem

Pipes between anchors, rails, and beams built into stiff supports all carry thermal stress when they
heat up and cannot grow. An elastic analysis overstates that stress once the material yields,
because the steel stops taking more stress and takes the extra strain plastically. This bar is the
simplest such case, with a closed-form answer to check the plastic solver against.

The bar's ends cannot move axially and its sides are free, so the stress is uniaxial and uniform:
σ = EαΔT until yield. With S275 steel (E = 210 GPa, α = 12 × 10⁻⁶ /K, EN 1993-1-1;
f_y = 275 MPa for thicknesses up to 16 mm, EN 10025-2), first yield comes at

$$\Delta T_y = \frac{f_y}{E\,\alpha} = \frac{275\ \text{MPa}}{210\ \text{GPa} \times 12\times10^{-6}\ \text{K}^{-1}} = 109.1\ \text{K}$$

a load factor of 0.727 of the full 150 K. Past that, the stress follows the E/10000 = 21 MPa
hardening slope that EN 1993-1-5 Annex C.6 allows in finite-element models, and the plastic strain
at 150 K is

$$\varepsilon_p = \alpha\,\Delta T - \frac{f_y}{E} = 1.8\times10^{-3} - 1.31\times10^{-3} = 4.9\times10^{-4}$$

The modulus is held at its 20 °C value. EN 1993-1-2 reduces it by a factor of about 0.93 at 170 °C,
which would move first yield to about 117 K.

## How the study works

1. **Geometry.** `geometry/quarter-bar.step` holds one quarter of the bar, cut on its two
   mid-planes, with faces `End A`, `End B`, `Mid-plane Y` and `Mid-plane Z`.

2. **Mesh.** Quadratic tetrahedra at a 2 mm target size.

3. **Material.** S275 with a J2 plasticity law:

   ```
   plastic {
       law = "j2_isotropic_linear_hardening"
       yield_stress = 275 MPa
       isotropic_hardening_modulus = 21 MPa
   }
   ```

4. **Model.** Symmetry conditions on all four cut and end faces: the ends act as rigid walls the bar
   can slide along, and the mid-planes stand in for the missing three quarters. The whole bar is
   heated from 20 °C to 170 °C:

   ```
   constraint wall_a {
       structural.symmetry { target = geometry.bar.region.end_a }
   }
   load heating {
       temperature_field on geometry.bar.region.body = 443.15 K
   }
   ```

5. **Study.** A nonlinear thermomechanical analysis that ramps the heating from load factor 0 to 1:

   ```
   analysis heating {
       thermomechanical nonlinear {
           start_load_factor = 0
           end_load_factor = 1
       }
   }
   ```

## Results

| Quantity | Hand check |
| --- | --- |
| Temperature rise at first yield | 109.1 K (load factor 0.727) |
| Elastic stress at 150 K, for comparison | 378 MPa |
| Stress at 150 K, with yield | 275.0 MPa (275.01 MPa on the hardening slope) |
| Plastic strain at 150 K | 4.9 × 10⁻⁴ |

The study returns the stress tensor, the von Mises stress, the displacement and `peak_von_mises`.
Compare `peak_von_mises` with 275.0 MPa, and check that the von Mises stress is uniform along the
bar, as the uniaxial hand check expects.

## What to try

1. Heat by 100 K instead (`temperature_field` 393.15 K). The bar stays elastic, and the hand check
   gives 252 MPa.
2. Change `yield_stress` to 355 MPa for S355 steel. First yield moves to 140.9 K, and the plastic
   strain at 150 K falls to 1.1 × 10⁻⁴.
3. Lower `youngs_modulus` to 195 GPa, about 0.93 of its room-temperature value at 170 °C. First
   yield moves to 117.5 K, and the plastic strain at 150 K falls to 3.9 × 10⁻⁴.

## Files

- `clamped-bar-yield.fea`: the elastic-plastic thermal stress study, with its hand check in the header.
- `materials.module`: the material the study imports, `steel_s275`.
- `geometry/quarter-bar.step`: a quarter of the bar as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Thermomechanical simulation in RunMat](https://runmat.com/simulation/thermomechanical)
- [Thermal stress guide](https://runmat.com/docs/simulation/guides/thermal-stress) and [structural constraints](https://runmat.com/docs/simulation/constraints/structural)
- [Cantilever beam plastic bending](../cantilever-plastic) and [rail thermal buckling](../rail-thermal-buckling)
- [Download RunMat](https://runmat.com/download)
