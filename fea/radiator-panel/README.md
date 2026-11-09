# Spacecraft radiator panel

Steady temperature of an aluminum spacecraft radiator panel (300 x 300 x 2 mm). Electronics on its back face dissipate 40 W into it, and its painted front face radiates to deep space at 3 K with an emissivity of 0.92. The study returns the panel temperature, which settles where radiated power equals the input.

## Files

| File | What it is |
| --- | --- |
| `radiator-panel.fea` | The study, with its hand check in the header. |
| `geometry/radiator-panel.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Radiator panel`; faces `Mounting face`, `Radiating face` and `Panel edges`.

## The part

- Aluminum 6061-T6 panel, 300 × 300 × 2 mm.

## Setup

- 40 W into the back face (444.4 W/m² over 0.09 m²).
- The front face radiates to a 3 K sink with ε = 0.92, white zinc-oxide silicate paint (Gilmore, *Spacecraft Thermal Control Handbook*, Vol. 1).
- The back face and edges are insulated by the spacecraft's multilayer blankets.
- Aluminum 6061-T6: k = 167 W/m/K (ASM Handbook, Vol. 2).

## Hand check

The temperature drop through 2 mm of aluminum at 444 W/m² is 0.005 K, so the panel is one temperature. It settles where it radiates what it receives:

- q″ = 40 / 0.09 = 444.4 W/m².
- T = (q″ / (εσ) + T_space⁴)^(1/4) = (444.4 / (0.92 × 5.670 × 10⁻⁸) + 3⁴)^(1/4) = **303.8 K (30.7 °C)**.

## Expected result

`radiating_face_temperature` should read 303.8 K within 0.5 K, and the whole panel should sit within 0.1 K of it.

Outputs: temperature, radiating_face_temperature.
