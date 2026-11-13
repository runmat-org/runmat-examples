# Busbar fault pulse

A copper busbar strip (100 x 40 x 5 mm) carrying 400 A sees a 25 kA fault for 0.5 s. Resistivity rises with temperature, so the loss grows as the strip heats. The study solves current and temperature together for 1 s and returns the temperature history and its peak, against the adiabatic short-circuit estimate.

## Files

| File | What it is |
| --- | --- |
| `busbar-fault-pulse.fea` | The study, with its hand check in the header. |
| `geometry/busbar-strip.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Busbar`; faces `Terminal A`, `Terminal B` and `Exterior`.

## The part

- Copper strip, 100 × 40 × 5 mm (200 mm²), terminals on its end faces.

## Setup

- Current into `Terminal A`: 400 A, then 25 kA from 0.105 s to 0.6 s with 5 ms edges, then 400 A to 1 s. `Terminal B` is held at 0 V.
- Still air on the other faces: 10 W/m²/K at 20 °C. The strip starts at 20 °C.
- Copper: 1/58 Ω·mm²/m at 20 °C and 0.00393 /K (IEC 60028); k = 388 W/m/K, c = 385 J/kg/K, ρ = 8890 kg/m³ (ASM Handbook, Vol. 2, C11000).
- Electrothermal transient, 0 to 1 s in 5 ms steps.

## Hand check

During the fault the strip loses about 4 W to the air against 5.4 kW of Joule loss, so it heats adiabatically:

- J = 25 kA / 200 mm² = 125 A/mm².
- dT/dt = ρ₂₀(1 + α(T − 20 °C)) J² / (ρ_m c), starting at **78.7 K/s**.
- Integrated over the current signal (ramps included): **42.4 K**, to **62.4 °C** at the end of the fault. At constant resistivity the rise would be 39.2 K; the 3.2 K difference is the resistivity rise.
- After the fault, 400 A adds less than 0.01 K and the air takes away about 0.1 K by 1 s.

## Expected result

`peak_temperature` should reach 62.4 °C at 0.6 s, within 0.5 K, and the strip should stay uniform to within 0.1 K.

Outputs: temperature (history), peak_temperature, mean_temperature.
