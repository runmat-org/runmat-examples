# Fin array cell with periodic sides

Steady temperature of one 10 mm pitch cell of a straight-fin aluminum heat sink: a 5 mm base and one 2 mm fin, 30 mm tall and 50 mm deep. The base takes 5 kW/m² (2.5 W per cell) and the fin and exposed base lose heat to 25 °C air at 25 W/m²/K. The cell side faces are tied by a periodic constraint, so the cell stands for the whole array.

## Files

| File | What it is |
| --- | --- |
| `fin-array-cell.fea` | The study, with its hand check in the header. |
| `geometry/fin-array-cell.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Heat sink cell`; faces `Base underside`, `Cell side left`, `Cell side right`, `Cell ends` and `Cooled surfaces`.

## The part

- Aluminum 6061-T6 cell, 10 mm pitch and 50 mm deep: a 5 mm base and one 2 mm fin, 30 mm tall, at the cell center.

## Setup

- 5 kW/m² into the base underside, 2.5 W per cell.
- Fin faces, fin tip and the exposed base top lose heat to 25 °C air at h = 25 W/m²/K. The cell ends are insulated.
- The two cell side faces, where the cell meets its neighbors, are tied by `thermal.periodic` with a 10 mm translation.
- Aluminum 6061-T6: k = 167 W/m/K (ASM Handbook, Vol. 2).

## Hand check

Fin-array estimate for one cell:

- m = √(2h / (kt)) = √(2 × 25 / (167 × 0.002)) = 12.24 m⁻¹; corrected height Hc = H + t/2 = 31 mm; mHc = 0.379.
- Fin efficiency η = tanh(mHc) / (mHc) = **0.955**.
- Fin area 2 × 31 × 50 = 3100 mm²; exposed base 8 × 50 = 400 mm².
- Cell conductance h(A_base + ηA_fin) = 25 × (400 + 0.955 × 3100) × 10⁻⁶ = 0.0840 W/K.
- Base rise 2.5 / 0.0840 = 29.8 K, plus 0.15 K across the 5 mm base: the underside reads **54.9 °C**.

## Expected result

`base_temperature` should read about 54.9 °C, within 0.5 K.

Outputs: temperature, base_temperature.
