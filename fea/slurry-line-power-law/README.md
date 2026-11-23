# Pressure drop of a shear-thinning slurry in a pipe: a power-law CFD study

This study solves steady laminar flow of a coal slurry through a 25 mm pipe, 400 mm long, at a mean
speed of 0.05 m/s (1.47 L/min). The slurry is shear-thinning, modeled as a power-law fluid with
n = 0.4 and K = 0.2 Pa·s⁰·⁴. The study returns the pressure drop, the peak speed and the velocity
profile. The power-law closed form gives a 44 Pa drop and a centerline speed of 0.079 m/s, against
0.100 m/s for a Newtonian fluid at the same mean speed.

## The problem

Slurries, pastes, polymer melts, foods and drilling muds get thinner as they are sheared faster. A
pressure-drop estimate made with one viscosity can be far off, because the apparent viscosity
changes across the pipe: high at the slow center, low at the fast-sheared wall. The power-law
(Ostwald–de Waele) model, τ = Kγ̇ⁿ, captures that with two constants. This slurry is the worked
example in Darby and Chhabra, *Chemical Engineering Fluid Mechanics*: n = 0.4, an apparent
viscosity of 200 cP at 1 s⁻¹ (so K = 0.2 Pa·s⁰·⁴), and a specific gravity of 1.5.

The Metzner–Reed Reynolds number is 44, so the flow is laminar and develops within about
0.05 Re_MR D = 55 mm. For developed laminar power-law flow, the wall shear rate is

$$\dot\gamma_w = \frac{3n+1}{4n}\,\frac{8V}{D} = 1.375 \times \frac{8 \times 0.05}{0.025} = 22\ \text{s}^{-1}$$

so τw = Kγ̇wⁿ = 0.2 × 22⁰·⁴ = 0.689 Pa, and

$$\Delta P = \frac{4\,\tau_w\,L}{D} = \frac{4 \times 0.689 \times 0.400}{0.025} = 44\ \text{Pa}$$

plus a small entrance loss. The profile is blunter than a parabola: the centerline speed is
V(3n + 1)/(n + 1) = 0.079 m/s.

## How the study works

1. **Geometry and mesh.** `geometry/slurry-line-d25x400.step` holds the slurry in the bore as body
   `Slurry`, with faces `Inlet`, `Outlet` and `Wall`. The pipe is a rigid wall, so it is not
   meshed. Linear tetrahedra at 2.5 mm, ten cells across the bore.

2. **Material.** The slurry as a power-law fluid, declared in `materials.module`:

   ```
   material coal_slurry = {
       mass_density = 1500 kg/m^3
       fluid = {
           law = power_law
           consistency = 0.2
           power_index = 0.4
       }
   }
   ```

3. **Boundaries.** A uniform 0.05 m/s at the inlet, no slip on the wall and 0 Pa gauge at the
   outlet.

4. **Study.** A steady fluid analysis, with the pressure drop and the peak speed:

   ```
   analysis flow { fluid steady {} }
   output pressure_drop = pressure_drop(analysis.flow, from = geometry.line.region.inlet, to = geometry.line.region.outlet)
   output peak_speed = max(magnitude(output.velocity), over = geometry.line.region.slurry)
   ```

## Results

| Quantity | Power-law closed form |
| --- | --- |
| Metzner–Reed Reynolds number | 44 |
| Wall shear rate | 22 s⁻¹ |
| Wall shear stress | 0.689 Pa |
| `pressure_drop` | 44 Pa, plus a small entrance loss |
| `peak_speed`, centerline | 0.079 m/s (Newtonian: 0.100 m/s) |

The study also returns the velocity and pressure fields. A section of the velocity field past the
first 55 mm shows the blunted profile: flatter across the middle than a parabola, with the shear
concentrated near the wall.

## What to try

1. Double the inlet speed to 0.1 m/s. The pressure drop rises only to 58 Pa, a factor of 2⁰·⁴ = 1.32,
   because the slurry thins as it is sheared harder.
2. Set `power_index` to 1 for a Newtonian fluid of 0.2 Pa·s. The drop becomes 205 Pa and the
   centerline 0.100 m/s.
3. Compare the section profile with `power_index` 0.4 and 1 to see the blunting directly.

## Files

- `slurry-line-power-law.fea`: the non-Newtonian flow study, with the power-law hand check in its header.
- `materials.module`: the material the study imports, `coal_slurry`.
- `geometry/slurry-line-d25x400.step`: the slurry in the bore as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Fluid flow simulation in RunMat](https://runmat.com/simulation/fluid-flow)
- [Fluid materials reference](https://runmat.com/docs/simulation/language/reference/fluid-materials) and [fluid physics reference](https://runmat.com/docs/simulation/physics/fluid)
- [Hydraulic line pressure drop](../hydraulic-line-poiseuille) and [pipe wall shear stress](../pipe-wall-shear)
- [Download RunMat](https://runmat.com/download)
