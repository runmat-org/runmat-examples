# Heated tube Nusselt number

Laminar water in a copper tube heated uniformly from outside. Card example for **pressure drop and
heat transfer coefficient** on `/simulation/conjugate-heat-transfer`.

## Setup

| Item | Value |
| --- | --- |
| Geometry | `geometry/heated-tube.step`: `Tube`, copper, 8 mm bore, 12 mm outside, 240 mm long along x, and `Water` in its bore. Faces `Tube bore`, `Heated surface`, `Tube ends`; `Inlet`, `Outlet`, `Channel wall` |
| Solid | Copper at 300 K (Incropera, Table A.1): 8933 kg/m³, 401 W/m·K, 385 J/kg·K |
| Fluid | Water at 300 K (Incropera, Table A.6): 997 kg/m³, 855e-6 Pa·s, 0.613 W/m·K, 4179 J/kg·K, Pr = 5.83 |
| Flow | Uniform 4.288 mm/s at 25 °C into `Inlet` (Re = 40); `Outlet` at 0 Pa |
| Heat | 1105.2 W/m² on `Heated surface` (10 W); tube ends insulated |
| Wetted wall | No slip; perfect thermal contact between `Tube bore` and `Channel wall` |
| Mesh | Linear tetrahedra, 1.5 mm, 0.6 mm on the channel wall |
| Analysis | `conjugate_heat_transfer steady` |

## Outputs

- `wall_temperature_180`: temperature on the bore wall at x = 180 mm (point (180, 4, 0) mm).
- `centerline_temperature_180`: temperature on the axis at x = 180 mm.
- `outlet_temperature`: area-mean temperature over the outlet.
- `pressure_drop`: mean inlet pressure minus mean outlet pressure.
- `temperature`, `velocity`, `pressure`: fields.

## Hand check

Developed laminar flow with uniform wall flux has Nu = 48/11 = 4.364.

- ṁ c = 997 × 0.004288 × 5.027e-5 × 4179 = 0.898 W/K, so the water warms 10 / 0.898 = 11.1 K.
  The bulk temperature at 180 mm is 25 + 11.1 × 0.75 = **33.35 °C**; the mixed-mean outlet is
  36.1 °C.
- Flux at the bore: q = 10 / (π × 0.008 × 0.240) = 1658 W/m². The thermal entry length is about
  0.05 Re Pr d = 93 mm, so the section at 180 mm is developed. The copper's conduction makes the
  wall temperature uniform around the bore, the condition Nu = 4.364 assumes.
- Wall minus bulk: q d / (4.364 k) = 1658 × 0.008 / (4.364 × 0.613) = 4.96 K, so
  `wall_temperature_180` should read **38.3 °C**.
- Wall minus centerline for the developed profile: (3/4) q R / k = 0.75 × 1658 × 0.004 / 0.613 =
  8.11 K, so `centerline_temperature_180` should read **30.2 °C**.
- The run's Nusselt number is q d / (k (T_wall − 33.35 °C)), to compare with 4.364.
- Pressure drop, Hagen–Poiseuille: 32 μ U L / d² = 32 × 855e-6 × 0.004288 × 0.240 / 0.008² =
  **0.44 Pa**. The viscosity is held at its 25 °C value; with temperature-dependent viscosity
  the warm water would lose a little less.

Geometry: written with Open CASCADE by `oct-13-2026/website/physics/studies/card-examples/generate-card-fixtures.cc` (in the runmat-acc-2 workspace). The bodies are fragmented together so their shared faces line up exactly, and the study reads them with `interfaces = shared`. Studies select faces and bodies by their CAD names.
