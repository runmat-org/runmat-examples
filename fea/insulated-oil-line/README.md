# Insulated oil line heat loss

Hot oil in a lagged steel pipe losing heat to still air. Card example for **outer faces**
(convection and radiation outside a conjugate model) on `/simulation/conjugate-heat-transfer`.

## Setup

| Item | Value |
| --- | --- |
| Geometry | `geometry/insulated-oil-line.step`, a 150 mm length along x: `Oil` (26.64 mm bore), `Pipe` (1 in schedule 40, 33.40 mm outside) and `Jacket` (25 mm lagging, 83.40 mm outside). Faces `Inlet`, `Outlet`, `Oil wall`; `Pipe bore`, `Pipe outside`, `Pipe ends`; `Jacket inside`, `Jacket surface`, `Jacket ends` |
| Oil | Engine oil at 400 K (Incropera, Table A.5): 825.1 kg/m³, 0.00874 Pa·s, 0.134 W/m·K, 2337 J/kg·K, Pr = 152 |
| Pipe | AISI 1010 steel (Incropera, Table A.1): 7832 kg/m³, 63.9 W/m·K, 434 J/kg·K |
| Jacket | Glass-fiber blanket, 16 kg/m³ (Incropera, Table A.3): 0.046 W/m·K, 835 J/kg·K |
| Flow | Uniform 0.1 m/s at 400 K (126.85 °C) into `Inlet` (Re = 251); `Outlet` at 0 Pa |
| Wetted wall | No slip; perfect thermal contact between `Pipe bore` and `Oil wall`; pipe and jacket share their mesh at `Pipe outside` |
| Outside | `Jacket surface`: convection 3.9 W/m²·K to 25 °C and radiation with emissivity 0.90 (white acrylic paint, Incropera Table A.11) to 25 °C surroundings. The cut ends are insulated, as along a long run |
| Mesh | Linear tetrahedra, 5 mm, 1.5 mm on the oil wall, 1.7 mm in the pipe |
| Analysis | `conjugate_heat_transfer steady` |

The 3.9 W/m²·K is the Churchill–Chu natural-convection coefficient for a horizontal 83.4 mm
cylinder about 11 K above 25 °C air: Ra = 5.8e5, Nu = 12.5, h = 12.5 × 0.0264 / 0.0834.

## Outputs

- `jacket_surface_temperature` (area-mean) and `peak_jacket_surface_temperature`.
- `peak_pipe_temperature`.
- `oil_outlet_temperature`: area-mean over the outlet.
- `temperature`, `velocity`, `pressure`: fields. The run's energy closure reports the heat
  lost by convection and radiation.

## Hand check

Radial resistances per meter of line:

| Layer | Resistance (m·K/W) |
| --- | --- |
| Oil film: thermally developing over 150 mm, Gz = Re Pr d / L = 6800, Nu = 1.953 Gz^(1/3) = 37, h = 186 W/m²·K; 1 / (h π d) | 0.064 |
| Pipe wall: ln(16.70 / 13.32) / (2π × 63.9) | 0.0006 |
| Jacket: ln(41.70 / 16.70) / (2π × 0.046) | 3.166 |
| Outside: 3.9 W/m²·K convection plus 0.9σ(Ts² + Ta²)(Ts + Ta) = 5.7 W/m²·K radiation at Ts = 36 °C, over π × 0.0834 m | 0.396 |
| Total | 3.63 |

- Heat loss: (126.85 − 25) / 3.63 = **28 W/m**, 4.2 W over this 150 mm length.
- Jacket surface: 25 + 28 × 0.396 = **36 °C**.
- Pipe: within 2 K of the oil, about **125 °C**.
- The oil cools by 4.2 / (825.1 × 0.1 × 5.574e-4 × 2337) = 0.04 K, so the outlet reads within
  0.1 K of 126.85 °C.

## Note on radiation

`runmat check` accepts `thermal.radiation` here. The thermal loads reference says the
canonical thermal procedure still rejects surface radiation at run time; if the run refuses it,
the fallback is a linearized coefficient h_r = 5.7 W/m²·K added to the convection (9.6 W/m²·K
in total), which gives the same hand-check numbers.

Geometry: written with Open CASCADE by `oct-13-2026/website/physics/studies/card-examples/generate-card-fixtures.cc` (in the runmat-acc-2 workspace). The bodies are fragmented together so their shared faces line up exactly, and the study reads them with `interfaces = shared`. Studies select faces and bodies by their CAD names.
