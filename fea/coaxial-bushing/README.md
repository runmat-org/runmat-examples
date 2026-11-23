# Electric field in a coaxial high-voltage bushing: an electrostatic FEA study

This study solves the electric potential and field in the cast-epoxy insulation of a coaxial
bushing: a 20 mm conductor bore at 36 kV inside an 80 mm grounded sleeve, 100 mm long. The field
peaks at the conductor surface. The coaxial-cylinder solution gives 2.60 kV/mm there, 0.65 kV/mm at
the sleeve and exactly 18.0 kV at r = 20 mm, which the study's outputs check.

## The problem

Insulation fails where the field is strongest, so a bushing or cable designer compares the peak
field with the insulation's working stress. In a coaxial geometry the peak sits on the inner
conductor, and the field falls off as 1/r toward the grounded sleeve. Between cylinders of radii
a = 10 mm and b = 40 mm at voltage V,

$$E(r) = \frac{V}{r \ln(b/a)}, \qquad V(r) = V\,\frac{\ln(b/r)}{\ln(b/a)}$$

At the conductor that is 36 kV / (10 mm × ln 4) = 2.60 kV/mm, and at the sleeve 0.65 kV/mm. Halfway
out in log radius, at r = 20 mm, the potential is exactly 18.0 kV. The field does not depend on the
permittivity; the stored energy and the capacitance do. With εr = 4.2 the capacitance is
2πε₀εrL / ln(b/a) = 16.9 pF for the 100 mm length.

The coaxial case has an exact answer, so it checks the mesh near a curved electrode before the same
method goes on to bushings with stress cones, grading layers and sheds, where no closed form exists.

## How the study works

1. **Geometry and mesh.** `geometry/coaxial-bushing.step` holds the insulation as body `Insulation`,
   with faces `Conductor bore`, `Ground sleeve` and `Insulation ends`. Quadratic tetrahedra at a
   3 mm target size.

2. **Material.** Cast epoxy with relative permittivity 4.2, a typical value for silica-filled
   casting resin at power frequency, and a bulk conductivity of 10⁻¹⁵ S/m, small enough to carry
   no current.

3. **Model.** Electrostatics, with the conductor bore at 36 kV and the sleeve at 0 V. The end faces
   carry no condition, so no field leaves them:

   ```
   electromagnetic { equation = electrostatics }
   constraint conductor {
       electrical.potential { target = geometry.bushing.region.conductor_bore; value = 36 kV }
   }
   ```

4. **Outputs.** The peak field on each electrode and the potential at r = 20 mm, mid-length:

   ```
   output peak_field = max(magnitude(analysis.field.field.element.electric_field), over = geometry.bushing.region.conductor_bore)
   output sleeve_field = max(magnitude(analysis.field.field.element.electric_field), over = geometry.bushing.region.ground_sleeve)
   output mid_potential = interpolate(analysis.field.field.node.electric_potential, at = [20 mm, 0 mm, 50 mm])
   ```

## Results

| Output | Coaxial-cylinder solution |
| --- | --- |
| `peak_field`, at the conductor | 2.60 kV/mm |
| `sleeve_field`, at the ground sleeve | 0.65 kV/mm |
| `mid_potential`, at r = 20 mm | 18.0 kV |
| Capacitance, 100 mm length | 16.9 pF |

The study also returns the potential and field throughout the insulation. Compare `peak_field` and
`sleeve_field` with the solution within 2 %, and `mid_potential` within 0.5 %. The potential's
contours are concentric circles, packed closest at the conductor.

## What to try

1. Lower the conductor potential to 24 kV. Everything scales linearly, so the peak falls to
   1.73 kV/mm.
2. Change `relative_permittivity` and check that the field outputs do not move.
3. Halve `target_size` to 1.5 mm and compare `peak_field`: the field at a curved electrode is the
   quantity most sensitive to the mesh.

For a fixed 80 mm sleeve, a bore of 29.4 mm (a = b/e) gives the lowest peak field, 2.45 kV/mm at
36 kV. Trying that takes a new STEP file with the larger bore.

## Files

- `coaxial-bushing.fea`: the electrostatic study, with the coaxial-cylinder check in its header.
- `materials.module`: the material the study imports, `cast_epoxy`.
- `geometry/coaxial-bushing.step`: the insulation as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Electromagnetic simulation in RunMat](https://runmat.com/simulation/electromagnetic)
- [Electromagnetic physics reference](https://runmat.com/docs/simulation/physics/electromagnetic) and [electromagnetic constraints](https://runmat.com/docs/simulation/constraints/electromagnetic)
- [Hall current sensor core flux](../hall-current-sensor) and [AC resistance of a round conductor](../round-conductor-ac)
- [Download RunMat](https://runmat.com/download)
