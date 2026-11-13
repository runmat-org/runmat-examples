# Hydraulic line pressure drop

Steady laminar flow of hydraulic oil through a straight line. Card example for **steady** flow on
`/simulation/fluid-flow`.

## Setup

| Item | Value |
| --- | --- |
| Geometry | `geometry/oil-line-d10x300.step`: the oil in a 10 mm bore, 300 mm long, along +x. Body `Oil`; faces `Inlet` (x = 0), `Outlet` (x = 300 mm), `Wall` |
| Fluid | ISO VG 46 at 40 °C: 46 mm²/s (ISO 3448 grade midpoint), 861 kg/m³, so μ = 0.0396 Pa·s |
| Inlet | Uniform 0.2122 m/s (1 L/min) |
| Wall | No slip; the pipe is rigid, so only the oil is meshed |
| Outlet | 0 Pa gauge |
| Mesh | Linear tetrahedra, 1.25 mm (about eight cells across the bore) |
| Analysis | `fluid steady` |

Re = 0.2122 × 0.010 / 46e-6 = 46, so the flow is laminar and develops within about
0.06 Re d = 28 mm of the inlet.

## Outputs

- `pressure_drop`: mean inlet pressure minus mean outlet pressure, Pa.
- `peak_speed`: largest speed in the oil, on the axis.
- `velocity`, `pressure`: cell fields.

## Hand check

Hagen–Poiseuille for the developed flow:

ΔP = 128 μ Q L / (π d⁴) = 128 × 0.0396 × 1.667e-5 × 0.300 / (π × 1e-8) = **807 Pa**.

The uniform inlet profile adds an entrance loss of about 1.25 × ½ρU² = 1.25 × 0.5 × 861 ×
0.2122² = 24 Pa, so `pressure_drop` should read about **830 Pa**. The developed centerline speed
is twice the mean, so `peak_speed` should read about **0.424 m/s**.

Geometry: written with Open CASCADE by `oct-13-2026/website/physics/studies/card-examples/generate-card-fixtures.cc` (in the runmat-acc-2 workspace). Studies select faces and bodies by their CAD names.
