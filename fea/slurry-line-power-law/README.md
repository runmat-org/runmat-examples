# Slurry line pressure drop

Steady laminar flow of a shear-thinning slurry through a straight pipe. Card example for
**non-Newtonian** flow on `/simulation/fluid-flow`.

## Setup

| Item | Value |
| --- | --- |
| Geometry | `geometry/slurry-line-d25x400.step`: the slurry in a 25 mm bore, 400 mm long, along +x. Body `Slurry`; faces `Inlet`, `Outlet`, `Wall` |
| Fluid | Coal slurry from the worked example in Darby and Chhabra, *Chemical Engineering Fluid Mechanics*: power law, n = 0.4, apparent viscosity 200 cP at 1 s⁻¹ (K = 0.2 Pa·s⁰·⁴), specific gravity 1.5 |
| Inlet | Uniform 0.05 m/s (1.47 L/min) |
| Wall | No slip |
| Outlet | 0 Pa gauge |
| Mesh | Linear tetrahedra, 2.5 mm (ten cells across the bore) |
| Analysis | `fluid steady` |

Metzner–Reed Reynolds number:
Re_MR = ρ V²⁻ⁿ Dⁿ / (K 8ⁿ⁻¹ ((3n+1)/(4n))ⁿ) = 1500 × 0.05¹·⁶ × 0.025⁰·⁴ / (0.2 × 8⁻⁰·⁶ × 1.375⁰·⁴) = 44,
laminar. The profile develops within about 0.05 Re_MR D = 55 mm.

## Outputs

- `pressure_drop`: mean inlet pressure minus mean outlet pressure, Pa.
- `peak_speed`: largest speed, on the axis.
- `velocity`, `pressure`: cell fields.

## Hand check

Developed laminar power-law flow in a pipe:

- Wall shear rate ((3n + 1) / (4n)) × 8V / D = 1.375 × 8 × 0.05 / 0.025 = 22 s⁻¹.
- Wall shear stress τw = K × 22⁰·⁴ = 0.2 × 3.44 = 0.689 Pa.
- Pressure drop ΔP = 4 τw L / D = 4 × 0.689 × 0.400 / 0.025 = **44 Pa**, plus a small entrance loss.
- Centerline speed V (3n + 1) / (n + 1) = 0.05 × 2.2 / 1.4 = **0.079 m/s**. A Newtonian fluid at
  the same mean speed peaks at 0.100 m/s.

Geometry: written with Open CASCADE by `oct-13-2026/website/physics/studies/card-examples/generate-card-fixtures.cc` (in the runmat-acc-2 workspace). Studies select faces and bodies by their CAD names.
