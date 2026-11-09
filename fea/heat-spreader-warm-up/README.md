# Heat spreader warm-up

Transient temperature of an aluminum heat spreader (100 x 100 x 10 mm) after a 20 W component on a 20 x 20 mm pad switches on. The other faces lose heat to 25 °C air at 10 W/m²/K. The study follows the plate for 6000 s, about six time constants, and returns the temperature history, the peak and the mean.

## Files

| File | What it is |
| --- | --- |
| `heat-spreader-warm-up.fea` | The study, with its hand check in the header. |
| `geometry/heat-spreader.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Spreader`; faces `Heater pad` and `Cooled surfaces`.

## The part

- Aluminum 6061-T6 plate, 100 × 100 × 10 mm.
- A 20 × 20 mm heater pad at the center of the underside, split out as its own face.

## Setup

- 20 W on the heater pad (50 kW/m²), switched on at t = 0.
- Every other face, 0.0236 m² in all, loses heat to 25 °C air at h = 10 W/m²/K.
- The plate starts at 25 °C. Backward Euler from 0 to 6000 s in 30 s steps.
- Aluminum 6061-T6: k = 167 W/m/K, ρ = 2700 kg/m³, c = 896 J/kg/K (ASM Handbook, Vol. 2).

## Hand check

The Biot number h(t/2)/k = 10 × 0.005 / 167 = 3 × 10⁻⁴, so the plate warms as one lump:

- Time constant τ = ρcV / (hA) = 2700 × 896 × 1.0 × 10⁻⁴ / (10 × 0.0236) = **1025 s**.
- Steady mean rise P / (hA) = 20 / 0.236 = **84.7 K**, a mean of 109.7 °C.
- Mean temperature T(t) = 25 + 84.7 (1 − e^(−t/τ)) °C:

| t (s) | 600 | 1200 | 1800 | 3600 | 6000 |
| --- | --- | --- | --- | --- | --- |
| mean (°C) | 62.6 | 83.5 | 95.1 | 107.2 | 109.5 |

## Expected result

`mean_temperature` should follow the table within about 1 K and reach 109.5 °C at 6000 s. `peak_temperature` sits a few kelvin above the mean, over the pad.

Outputs: temperature (history), peak_temperature, mean_temperature.
