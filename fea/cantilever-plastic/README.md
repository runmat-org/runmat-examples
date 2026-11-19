# Steel cantilever beam loaded past first yield: an elastic-plastic FEA study

This study loads a 1,000 mm steel cantilever with a 100 × 100 mm section until its root yields. A
48 kN force on the free end takes the root past first yield, about 41.7 kN for 250 MPa steel, toward
the plastic hinge load of 62.5 kN. The study applies the load in increments with J2 plasticity and
linear hardening and returns the displacement and stress. By beam theory the root's elastic stress
would be 288 MPa; with yield, the outer 8.3 mm of each face at the root goes plastic.

## The problem

An elastic analysis says a part has failed as soon as its peak stress reaches yield. A ductile steel
part can carry more: once the outer fibers yield, the core still works, and the load can grow until
the whole section yields and forms a plastic hinge. Checking overloads, proof loads and crash cases
means following that spread of yield, which needs a plasticity model and a load applied in steps.

For a rectangular section of width b and depth h, beam theory gives the two limits:

$$F_y = \frac{\sigma_y\,b h^2}{6L} = \frac{250 \times 100 \times 100^2}{6 \times 1000} = 41.7\ \text{kN}, \qquad F_p = \frac{\sigma_y\,b h^2}{4L} = 62.5\ \text{kN}$$

The 48 kN load is 1.152 times first yield and 0.768 of the hinge load. Elastic, it would put
48 kN·m / 166,667 mm³ = 288 MPa at the root. Taking the steel as perfectly plastic, the root
section carries M/M_y = 1.5(1 − ξ²/3), where ξ is the elastic core's share of the half-depth; at
1.152, ξ = 0.834, so the outer 8.3 mm of each face yields. The bending moment exceeds the first-yield
moment over the first 132 mm from the root. The study's 2 GPa hardening slope adds a little
strength over this perfectly plastic estimate.

## How the study works

1. **Geometry and mesh.** `geometry/cantilever.step` holds the beam as body `Beam`, with faces
   `Fixed end` and `Loaded end`. Quadratic tetrahedra at a 50 mm target size.

2. **Material.** Mild steel with J2 plasticity and linear isotropic hardening:

   ```
   material mild_steel {
       mass_density = 7850 kg/m^3
       elastic {
           youngs_modulus = 200 GPa
           poisson_ratio = 0.3
       }
       plastic {
           law = "j2_isotropic_linear_hardening"
           yield_stress = 250 MPa
           isotropic_hardening_modulus = 2 GPa
       }
   }
   ```

3. **Model.** The root face fixed and 48 kN downward on the free end:

   ```
   load tip {
       force on geometry.beam.region.loaded_end = [0, 0, -48] kN
   }
   ```

4. **Study.** A nonlinear structural analysis that ramps the load from factor 0 to 1, with Newton
   iteration at each increment:

   ```
   analysis load_path {
       structural nonlinear {
           start_load_factor = 0
           end_load_factor = 1
       }
   }
   ```

## Results

| Quantity | Hand check |
| --- | --- |
| First-yield load | 41.7 kN (load factor 0.868) |
| Plastic hinge load | 62.5 kN |
| Elastic root stress at 48 kN | 288 MPa |
| Yielded depth at the root, each face | 8.3 mm, perfectly plastic |
| Length over which the root region yields | 132 mm |
| Elastic tip deflection at 48 kN, FL³/(3EI) | 9.6 mm |

The study returns the displacement and the stress tensor at full load. The top and bottom fibers at
the root should sit near the 250 MPa yield stress instead of the elastic 288 MPa, with the yielded
zone confined near the root. The tip deflection should come out somewhat above the elastic 9.6 mm,
because the yielded fibers have lost stiffness.

## What to try

1. Lower the load to 40 kN, under first yield. The beam stays elastic, and the hand checks give
   240 MPa at the root and 8.0 mm at the tip.
2. Raise the load to 60 kN, 0.96 of the hinge load, and watch the yielded zone spread through the
   root section.
3. Set `isotropic_hardening_modulus` to 0.2 GPa, closer to perfectly plastic, and compare the tip
   deflection at 48 kN.

## Files

- `cantilever-plastic.fea`: the nonlinear study, with the first-yield and hinge loads in its header.
- `geometry/cantilever.step`: the beam as STEP, with the body and end-face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Structural simulation in RunMat](https://runmat.com/simulation/structural)
- [Linear static guide](https://runmat.com/docs/simulation/guides/linear-static) and [structural loads](https://runmat.com/docs/simulation/loads/structural)
- [Restrained bar heated past yield](../clamped-bar-yield) and [cantilever beam frequency response](../cantilever-harmonic)
- [Download RunMat](https://runmat.com/download)
