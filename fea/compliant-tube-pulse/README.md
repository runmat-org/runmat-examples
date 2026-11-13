# Pulse in a compliant tube

A pressure pulse traveling along a silicone tube full of water, with fluid and wall solved
together. Card example for **transient** fluid–structure interaction on
`/simulation/fluid-structure`.

## Setup

| Item | Value |
| --- | --- |
| Geometry | `geometry/compliant-tube.step`: `Tube`, 10 mm bore, 1 mm wall, 200 mm long along x, and `Water` in its bore. Faces `Inlet`, `Outlet`, `Water wall`; `Tube bore`, `Tube outside`, `Tube ends`. The bodies are fragmented together so the bore is one shared face, read with `interfaces = shared` |
| Fluid | Water at 300 K (Incropera, Table A.6): 997 kg/m³, 855e-6 Pa·s |
| Wall | Silicone rubber, 50 Shore A: E = 2.46 MPa (Gent's relation between Shore A hardness and Young's modulus), 1150 kg/m³, ν = 0.49 |
| Inflow | Half-sine surge into `Inlet`: 4 ms long, peak 0.05 m/s, then zero |
| Outlet | 0 Pa gauge (an open reservoir) |
| Supports | Both tube ends fixed |
| Coupling | No-slip fluid–structure interface between `Water wall` and `Tube bore` |
| Mesh | Linear tetrahedra, 1.5 mm, 0.5 mm in the wall (two elements through it) |
| Analysis | `fluid_structure_interaction transient`, 0 to 15 ms in 0.2 ms steps |

## Outputs

- `pressure_50_history`, `pressure_150_history`: pressure on the axis 50 mm and 150 mm from
  the inlet, every 0.5 ms from 0.5 to 15 ms.
- `wall_movement_history`: largest wall displacement at the same times.
- `pressure_50`, `pressure_150`, `wall_movement`, `displacement`, `velocity`, `pressure`:
  final values and fields.

## Hand check

Moens–Korteweg wave speed for a thin elastic tube full of liquid:

c = √(E h / (ρ d)) = √(2.46e6 × 0.001 / (997 × 0.010)) = **15.7 m/s**.

The wall is 10 % of the bore, so using the mean diameter (11 mm) gives 15.0 m/s, and the
fixed ends restrain the wall axially, which raises c by 1/√(1 − ν²) to about 17 m/s. Take
**15 to 17 m/s**.

- The pulse peak leaves the inlet at 2 ms, passes 50 mm at 4.9 to 5.3 ms and 150 mm at 10.8 to
  12.0 ms. The peak-to-peak delay between the two histories is 100 mm / c = **5.9 to 6.7 ms**.
- Pulse pressure ρ c u = 997 × 15.7 × 0.05 = **0.78 kPa**; it swells the bore by
  Δp d / (2 E h) = 1.6 %, about 80 µm on the radius.
- The open end reflects the pulse inverted. The reflected front travels 250 mm to get back to
  150 mm, arriving at 14.7 to 15.9 ms, and its peak after 16.7 ms, so the 15 ms window holds the
  whole incident pulse at both points.

Geometry: written with Open CASCADE by `oct-13-2026/website/physics/studies/card-examples/generate-card-fixtures.cc` (in the runmat-acc-2 workspace). Studies select faces and bodies by their CAD names.
