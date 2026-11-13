# Listening room modes

Natural frequencies of the air in a rigid-walled room. Card example for **modal** acoustics on
`/simulation/acoustics`.

## Setup

| Item | Value |
| --- | --- |
| Geometry | `geometry/listening-room.step`: `Air`, 5 m (x) × 4 m (y) × 2.8 m (z). Faces `Floor`, `Ceiling`, `Walls` |
| Air | 20 °C: 1.204 kg/m³, 343 m/s |
| Boundaries | Every surface rigid |
| Mesh | Quadratic tetrahedra, 400 mm (six per wavelength at 100 Hz is 570 mm) |
| Analysis | `acoustic modal`, 12 modes |

## Outputs

- `modal.frequency_hz` (published with every modal run) and `mode_shapes`, the pressure shape
  of each mode.

## Hand check

Rigid rectangular room: f = (c / 2) √((l / Lx)² + (m / Ly)² + (n / Lz)²).

| Mode | (l, m, n) | f (Hz) |
| --- | --- | --- |
| 1 | (0, 0, 0) | 0.0 (uniform pressure) |
| 2 | (1, 0, 0) | 34.3 |
| 3 | (0, 1, 0) | 42.9 |
| 4 | (1, 1, 0) | 54.9 |
| 5 | (0, 0, 1) | 61.3 |
| 6 | (2, 0, 0) | 68.6 |
| 7 | (1, 0, 1) | 70.2 |
| 8 | (0, 1, 1) | 74.8 |
| 9 | (2, 1, 0) | 80.9 |
| 10 | (1, 1, 1) | 82.3 |
| 11 | (0, 2, 0) | 85.8 |
| 12 | (2, 0, 1) | 92.0 |

Each finite-element frequency should sit at or slightly above its formula value; quadratic
elements at this size put the error well under 1 % through 92 Hz.

Geometry: written with Open CASCADE by `oct-13-2026/website/physics/studies/card-examples/generate-card-fixtures.cc` (in the runmat-acc-2 workspace). Studies select faces and bodies by their CAD names.
