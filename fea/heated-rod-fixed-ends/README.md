# Heater rod with fixed end temperatures

Steady temperature of a stainless steel heater rod, 10 mm in diameter and 100 mm long, generating 1 MW/m³ (7.85 W) uniformly. Both ends are held at 20 °C by the terminal blocks and the surface is insulated. The study returns the parabolic temperature profile and its peak at mid-length.

## Files

| File | What it is |
| --- | --- |
| `heated-rod-fixed-ends.fea` | The study, with its hand check in the header. |
| `geometry/heater-rod.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Heater rod`; faces `End A`, `End B` and `Rod surface`.

## The part

- AISI 304 stainless steel rod, 10 mm diameter, 100 mm long.

## Setup

- Uniform heat generation 1 MW/m³, 7.85 W in all.
- Both ends held at 20 °C. The surface is insulated.
- AISI 304: k = 16.2 W/m/K (ASM Handbook, Vol. 1).

## Hand check

Heat flows only along the rod, so the temperature is a parabola with its peak at mid-length:

- T_max = T_end + q‴L² / (8k) = 20 + 10⁶ × 0.1² / (8 × 16.2) = **97.2 °C**.
- Each end carries half the heat: q‴AL / 2 = **3.93 W**.

## Expected result

`peak_temperature` should read 97.2 °C within 0.2 K, and `end_a_heat_flow` 3.93 W out of the rod.

Outputs: temperature, peak_temperature, end_a_heat_flow.
