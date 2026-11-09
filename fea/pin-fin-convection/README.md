# Pin fin convection

Steady heat flow through an aluminum pin fin, 6 mm in diameter and 50 mm long. The base is held at 80 °C and the side and tip lose heat to 25 °C air at 25 W/m²/K. The study returns the temperature along the fin, the heat flowing in through the base and the tip temperature, which the classical fin solution predicts.

## Files

| File | What it is |
| --- | --- |
| `pin-fin-convection.fea` | The study, with its hand check in the header. |
| `geometry/pin-fin.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Pin fin`; faces `Base`, `Fin side` and `Fin tip`.

## The part

- Aluminum 6061-T6 pin, 6 mm diameter, 50 mm long.

## Setup

- Base held at 80 °C.
- Side and tip lose heat to 25 °C air at h = 25 W/m²/K.
- Aluminum 6061-T6: k = 167 W/m/K (ASM Handbook, Vol. 2).

## Hand check

The radial Biot number h r / k = 4.5 × 10⁻⁴, so the fin is one-dimensional. With P = πd and A = πd²/4:

- m = √(hP / (kA)) = √(4h / (kd)) = **9.990 m⁻¹**, mL = 0.4995, h/(mk) = 0.01498.
- √(hPkA) = 0.04717 W/K, θb = 80 − 25 = 55 K.
- Heat rate with a convecting tip: q = √(hPkA) θb (sinh mL + (h/mk) cosh mL) / (cosh mL + (h/mk) sinh mL) = **1.228 W**.
- Tip excess temperature θb / (cosh mL + (h/mk) sinh mL) = 48.45 K, so the tip reads **73.5 °C**.

## Expected result

`base_heat_flow` should read 1.23 W into the fin and `tip_temperature` 73.5 °C, each within 1 %.

Outputs: temperature, base_heat_flow, tip_temperature.
