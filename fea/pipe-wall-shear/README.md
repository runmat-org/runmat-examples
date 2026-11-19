# Wall shear stress in laminar pipe flow: a CFD check against Poiseuille

This study solves steady laminar flow of ISO VG 46 oil at 40 °C through a 10 mm bore, 300 mm long,
at 1 L/min, and returns the shear stress the oil puts on the bore wall. Poiseuille flow gives
τw = 6.72 Pa over the developed length. The flat inlet profile raises the shear in the entrance, so
the peak sits near the inlet and the area mean runs a few percent above 6.72 Pa.

## The problem

Wall shear stress is the drag the fluid puts on the wall per unit area. It drives erosion and
deposit removal in process lines, sets the shear on cells in bioreactors and blood-contacting
devices, and is the quantity behind every friction factor. For developed laminar flow in a round
pipe,

$$\tau_w = \frac{4\,\mu\,Q}{\pi R^3} = \frac{8\,\mu\,U}{d} = \frac{8 \times 0.0396 \times 0.2122}{0.010} = 6.72\ \text{Pa}$$

with the oil at μ = 0.0396 Pa·s and a mean speed of 0.2122 m/s (Re = 46). That holds beyond about
28 mm from the inlet, where the profile has developed. A force balance on the developed length
gives the same value from the pressure drop: τw πdL = ΔP πd²/4, so 807 Pa over 300 mm gives
6.72 Pa.

## How the study works

1. **Geometry and mesh.** `geometry/oil-line-d10x300.step`, the same line and flow as the
   [hydraulic line study](../hydraulic-line-poiseuille): body `Oil` with faces `Inlet`, `Outlet`
   and `Wall`. Linear tetrahedra at 1.25 mm.

2. **Material.** ISO VG 46 at 40 °C: 861 kg/m³, μ = 0.0396 Pa·s.

3. **Boundaries.** A uniform 0.2122 m/s (1 L/min) at the inlet, no slip on the wall and 0 Pa gauge at
   the outlet.

4. **Study and outputs.** A steady fluid analysis. The wall shear stress is a face field, reduced to
   its peak and area mean over the bore:

   ```
   analysis flow { fluid steady {} }
   output wall_shear = analysis.flow.field.face.wall_shear_stress
   output peak_wall_shear = max(magnitude(output.wall_shear), over = geometry.line.region.wall)
   output mean_wall_shear = mean(magnitude(output.wall_shear), over = geometry.line.region.wall)
   ```

## Results

| Quantity | Hand check |
| --- | --- |
| Wall shear, developed length | 6.72 Pa |
| From the developed pressure drop, 807 Pa | 6.72 Pa |
| `peak_wall_shear` | above 6.72 Pa, near the inlet |
| `mean_wall_shear` | a few percent above 6.72 Pa |

The study also returns the shear on every boundary face and the velocity and pressure fields.
Color the wall by `wall_shear`: it should be uniform past the first 28 mm and rise toward the inlet,
where the flat profile meets the wall.

## What to try

1. Double the inlet speed to 0.4244 m/s (2 L/min). The developed shear doubles to 13.4 Pa.
2. Switch to ISO VG 32 oil at 40 °C (`dynamic_viscosity` 0.0276 Pa·s). The developed shear falls in
   proportion to 4.68 Pa.
3. Refine `target_size` to 0.8 mm and compare `peak_wall_shear`: the entrance peak depends on how
   well the mesh resolves the thin boundary layer there.

## Files

- `pipe-wall-shear.fea`: the steady flow study with the wall shear outputs and the Poiseuille hand check in its header.
- `geometry/oil-line-d10x300.step`: the oil in the bore as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Fluid flow simulation in RunMat](https://runmat.com/simulation/fluid-flow)
- [Fluid physics reference](https://runmat.com/docs/simulation/physics/fluid) and [outputs and field queries](https://runmat.com/docs/simulation/language/outputs-fields-and-observations)
- [Hydraulic line pressure drop](../hydraulic-line-poiseuille) and [slurry line pressure drop](../slurry-line-power-law)
- [Download RunMat](https://runmat.com/download)
