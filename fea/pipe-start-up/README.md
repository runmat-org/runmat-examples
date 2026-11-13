# Pipe flow start-up

Laminar flow starting from rest in a hydraulic line when a pressure difference is switched on.
Card example for **transient** flow on `/simulation/fluid-flow`.

## Setup

| Item | Value |
| --- | --- |
| Geometry | `geometry/oil-line-d10x300.step`: the oil in a 10 mm bore, 300 mm long. Body `Oil`; faces `Inlet`, `Outlet`, `Wall` |
| Fluid | ISO VG 46 at 40 °C: 861 kg/m³, 46 mm²/s, μ = 0.0396 Pa·s |
| Start | Oil at rest |
| Inlet | 807 Pa gauge from t = 0 |
| Outlet | 0 Pa gauge |
| Wall | No slip |
| Mesh | Linear tetrahedra, 1.5 mm |
| Analysis | `fluid transient`, 0 to 0.6 s in 5 ms steps |

## Outputs

- `mean_speed_history`: volume-mean oil speed at 0.025, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.4,
  0.5 and 0.6 s. With the flow along the pipe, the volume-mean speed equals Q / A.
- `mean_speed`, `peak_speed`: final values.
- `velocity`, `pressure`: final cell fields.

## Hand check

Szymanski's solution for a pipe started from rest by a step pressure gradient:

U(t) / U∞ = 1 − Σ (32 / λₙ⁴) exp(−λₙ² ν t / R²), with λₙ the zeros of J₀ (2.405, 5.520, …).

- Time scale R²/ν = 0.005² / 46e-6 = 0.543 s.
- Final mean speed U∞ = ΔP d² / (32 μ L) = 807 × 1e-4 / (32 × 0.0396 × 0.300) = **0.212 m/s**
  (1 L/min), a few percent lower for the entrance loss.
- The first term dominates after a few milliseconds: U/U∞ = 1 − 0.957 exp(−5.783 t / 0.543 s).

| t (s) | 0.05 | 0.1 | 0.15 | 0.2 | 0.25 | 0.3 | 0.4 | 0.6 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| U/U∞ | 0.44 | 0.67 | 0.81 | 0.89 | 0.93 | 0.96 | 0.99 | 1.00 |

95 % of the final flow at ν t / R² = ln(0.957 / 0.05) / 5.783 = 0.510, so **t₉₅ = 0.277 s**.
Backward Euler with 5 ms steps lags the exact curve by about one percent of U∞ at its steepest.

Geometry: written with Open CASCADE by `oct-13-2026/website/physics/studies/card-examples/generate-card-fixtures.cc` (in the runmat-acc-2 workspace). Studies select faces and bodies by their CAD names.
