# Chip cold plate power step

Warm-up of a water-cooled aluminum block after a die on it switches on. Card example for
**transient** conjugate heat transfer on `/simulation/conjugate-heat-transfer`.

## Setup

| Item | Value |
| --- | --- |
| Geometry | `geometry/chip-cold-plate.step`: `Cold plate`, 80 × 40 × 12 mm, with one straight 6 mm drilled channel along x (axis at y = 20, z = 5 mm), and `Coolant`, the water in the channel. Faces `Die footprint` (20 × 20 mm centered on the top), `Plate channel wall`, `Plate exterior`; `Inlet`, `Outlet`, `Channel wall` |
| Solid | 6061-T6 aluminum (ASM): 2700 kg/m³, 167 W/m·K, 896 J/kg·K |
| Fluid | Water at 300 K (Incropera, Table A.6): 997 kg/m³, 855e-6 Pa·s, 0.613 W/m·K, 4179 J/kg·K, Pr = 5.83 |
| Flow | Uniform 0.25 m/s at 25 °C into `Inlet` (7.05e-3 kg/s, Re = 1749); `Outlet` at 0 Pa |
| Heat | 125 kW/m² on `Die footprint` (50 W), on from t = 0; other outer faces insulated |
| Wetted wall | No slip; perfect thermal contact between `Plate channel wall` and `Channel wall` |
| Start | Block and water at the model's 25 °C reference temperature |
| Mesh | Linear tetrahedra, 2.5 mm, 0.75 mm on the channel wall |
| Analysis | `conjugate_heat_transfer transient`, 0 to 150 s in 1 s steps |

## Outputs

- `die_temperature_history`: peak temperature on the die footprint at 5, 10, 20, 35, 50, 75,
  105 and 150 s.
- `peak_die_temperature`, `outlet_temperature` (area-mean over the outlet): final values.
- `temperature`, `velocity`, `pressure`: final fields.

## Hand check

- **Outlet rise** at steady state: Q / (ṁ c) = 50 / (7.05e-3 × 4179) = **1.70 K** (mixed mean),
  so the water leaves at 26.7 °C. The area-mean on the outlet face weights the slower, warmer
  water near the wall less than the mixed mean does, so it reads a little lower.
- **Film**: the velocity profile develops in about 0.05 Re d = 525 mm and the temperature profile
  far later, so the 80 mm channel is in its thermal entrance. Shah's mean Nusselt number for a
  developed velocity profile with uniform flux is Nu = 1.953 Gz^(1/3) with Gz = Re Pr d / L =
  1749 × 5.83 × 0.006 / 0.080 = 765, so Nu = 17.9 and h = 17.9 × 0.613 / 0.006 = 1825 W/m²·K.
  Over the 1.51e-3 m² channel wall that is 50 / (1825 × 1.51e-3) = **18 K**. Fully developed flow
  (Nu = 4.36, 74 K) is an upper bound the channel never reaches.
- **Conduction** through the 4 mm of aluminum under the die: at most 0.004 / (167 × 4e-4) × 50 =
  3 K; spreading into the block makes it smaller.
- **Steady die temperature**: about 25 + 0.9 + 18 + 2 = **46 °C**. The uniform inlet profile makes
  the entrance film stronger than Shah's estimate, so a run reading a few kelvin lower is
  consistent.
- **Time constant**: the block stores ρ c V = 2700 × 896 × 3.61e-5 = 87 J/K behind about
  (46 − 25) / 50 = 0.42 K/W, so τ ≈ 35 s: about 63 % of the final rise by 35 s and 95 % by 105 s.

## Note on the start state

`runmat check` (integration 9bb447a159) refuses a `conjugate_heat_transfer transient` that
selects an `initial_conditions` entry: native execution admits only a fresh, independent step.
The study therefore starts from the default state, which it takes to be the model's 298.15 K
reference temperature.

Geometry: written with Open CASCADE by `oct-13-2026/website/physics/studies/card-examples/generate-card-fixtures.cc` (in the runmat-acc-2 workspace). The bodies are fragmented together so their shared faces line up exactly, and the study reads them with `interfaces = shared`. Studies select faces and bodies by their CAD names.
