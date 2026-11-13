# Pipe wall shear stress

Wall shear stress on the bore of a hydraulic line in steady laminar flow. Card example for
**wall shear** on `/simulation/fluid-flow`.

## Setup

The same line and flow as `hydraulic-line-poiseuille`:

| Item | Value |
| --- | --- |
| Geometry | `geometry/oil-line-d10x300.step`: the oil in a 10 mm bore, 300 mm long. Body `Oil`; faces `Inlet`, `Outlet`, `Wall` |
| Fluid | ISO VG 46 at 40 °C: 861 kg/m³, μ = 0.0396 Pa·s |
| Inlet | Uniform 0.2122 m/s (1 L/min), Re = 46 |
| Wall | No slip |
| Outlet | 0 Pa gauge |
| Mesh | Linear tetrahedra, 1.25 mm |
| Analysis | `fluid steady` |

## Outputs

- `wall_shear`: the shear stress on every boundary face (`field.face.wall_shear_stress`).
- `peak_wall_shear`, `mean_wall_shear`: largest and area-mean magnitude over `Wall`.
- `velocity`, `pressure`: cell fields.

## Hand check

Developed Poiseuille flow:

τw = 4 μ Q / (π R³) = 8 μ U / d = 8 × 0.0396 × 0.2122 / 0.010 = **6.72 Pa**

over the developed length, beyond about 28 mm from the inlet. The flat inlet profile raises the
shear near the inlet, so `peak_wall_shear` sits there, above 6.72 Pa, and `mean_wall_shear` is a
few percent above 6.72 Pa. The wall force balances the developed pressure gradient:
τw π d L = ΔP π d² / 4 gives the same 6.72 Pa from the 807 Pa developed drop.

Geometry: written with Open CASCADE by `oct-13-2026/website/physics/studies/card-examples/generate-card-fixtures.cc` (in the runmat-acc-2 workspace). Studies select faces and bodies by their CAD names.
