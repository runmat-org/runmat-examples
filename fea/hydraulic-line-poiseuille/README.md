# Pressure drop in a hydraulic oil line: a laminar CFD check against Hagen–Poiseuille

This study solves steady laminar flow of ISO VG 46 hydraulic oil at 40 °C through a straight
10 mm bore, 300 mm long, at 1 L/min (Re = 46). It returns the pressure drop from inlet to outlet,
the peak speed on the axis, and the velocity and pressure fields. Hagen–Poiseuille gives 807 Pa
for the developed flow; with the entrance loss of the flat inlet profile, the line should drop
about 830 Pa, with the centerline at 0.424 m/s.

## The problem

Hydraulic lines, lubrication feeds and instrument tubing run laminar at low flow, and their pressure
drop sets the pump pressure or tells you how much flow a given pressure delivers. For developed
laminar flow in a round pipe the drop has an exact form:

$$\Delta P = \frac{128\,\mu\,Q\,L}{\pi\,d^4} = \frac{128 \times 0.0396 \times 1.667\times10^{-5} \times 0.300}{\pi \times 10^{-8}} = 807\ \text{Pa}$$

The oil is ISO VG 46 at 40 °C: 46 mm²/s (the ISO 3448 grade midpoint) and 861 kg/m³, so
μ = 0.0396 Pa·s. 1 L/min through the 78.54 mm² bore is a mean speed of 0.2122 m/s, and
Re = Ud/ν = 46, well inside the laminar range. The flow enters with a flat profile and develops
within about 0.06 Re d = 28 mm. That entrance adds about 1.25 × ½ρU² = 24 Pa.

## How the study works

1. **Geometry and mesh.** `geometry/oil-line-d10x300.step` holds only the oil, as body `Oil`, with
   faces `Inlet`, `Outlet` and `Wall`. The pipe is a rigid wall to the oil, so it is not meshed.
   Linear tetrahedra at 1.25 mm, about eight cells across the bore.

2. **Material.** The oil as an incompressible Newtonian fluid, declared in `materials.module`:

   ```
   material iso_vg_46 = {
       mass_density = 861 kg/m^3
       fluid = {
           law = incompressible_newtonian
           dynamic_viscosity = 0.0396 Pa*s
       }
   }
   ```

3. **Boundaries.** A uniform 0.2122 m/s at the inlet, no slip on the wall and 0 Pa gauge at the
   outlet:

   ```
   constraint supply {
       fluid.velocity { target = geometry.line.region.inlet; value = [0.2122 m/s, 0 m/s, 0 m/s] }
   }
   constraint bore { fluid.no_slip_wall { target = geometry.line.region.wall } }
   ```

4. **Study.** A steady fluid analysis, with the pressure drop and the peak speed:

   ```
   analysis flow { fluid steady {} }
   output pressure_drop = pressure_drop(analysis.flow, from = geometry.line.region.inlet, to = geometry.line.region.outlet)
   output peak_speed = max(magnitude(output.velocity), over = geometry.line.region.oil)
   ```

## Results

| Output | Hand check |
| --- | --- |
| Reynolds number | 46 |
| Developed-flow pressure drop | 807 Pa |
| Entrance loss | 24 Pa |
| `pressure_drop` | about 830 Pa |
| `peak_speed`, developed centerline | 0.424 m/s, twice the mean |

The study also returns the velocity and pressure fields. Along the line, the pressure should fall
steeply over the first 28 mm, where the profile develops, and then linearly. A section of the
velocity field past the entrance shows the parabolic Poiseuille profile.

## What to try

1. Double the flow to 2 L/min (inlet 0.4244 m/s). The developed drop doubles to 1,613 Pa, the
   entrance loss quadruples to 97 Pa, and Re rises to 92.
2. Switch to ISO VG 32 oil at 40 °C (32 mm²/s, `dynamic_viscosity` 0.0276 Pa·s). The developed drop
   falls to 561 Pa.
3. Coarsen `target_size` to 2.5 mm and compare `pressure_drop` and `peak_speed`; four cells across
   the bore under-resolve the parabola.

## Files

- `hydraulic-line-poiseuille.fea`: the steady laminar flow study, with its hand check in the header.
- `materials.module`: the material the study imports, `iso_vg_46`.
- `geometry/oil-line-d10x300.step`: the oil in the bore as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Fluid flow simulation in RunMat](https://runmat.com/simulation/fluid-flow)
- [Fluid physics reference](https://runmat.com/docs/simulation/physics/fluid) and [fluid materials](https://runmat.com/docs/simulation/language/reference/fluid-materials)
- [Pipe wall shear stress](../pipe-wall-shear), [pipe flow start-up](../pipe-start-up) and [slurry line pressure drop](../slurry-line-power-law)
- [Download RunMat](https://runmat.com/download)
