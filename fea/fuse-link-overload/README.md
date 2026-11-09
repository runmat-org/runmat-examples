# Fuse element overload

A copper fuse element (10 mm long, 1 x 0.25 mm section) carrying a 120 A overload, its ends held at 20 °C by the terminals. Resistivity rises with temperature, so the middle heats faster than the ends. The study solves current and temperature together and returns the peak temperature, against the closed-form solution for resistivity linear in temperature.

## Files

| File | What it is |
| --- | --- |
| `fuse-link-overload.fea` | The study, with its hand check in the header. |
| `geometry/fuse-element.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Fuse element`; faces `Terminal A` and `Terminal B`.

## The part

- Copper fuse element, 10 mm long, 1 × 0.25 mm section.

## Setup

- 120 A into `Terminal A`; `Terminal B` at 0 V.
- Both terminal faces held at 20 °C. The element is packed in filler and its surface is taken as insulated.
- Copper: 1/58 Ω·mm²/m at 20 °C and 0.00393 /K (IEC 60028); k = 388 W/m/K (ASM Handbook, Vol. 2, C11000).
- Electrothermal steady: current and temperature iterated to a fixed point.

## Hand check

With ρ(T) = ρ₂₀(1 + αθ) and both ends at the reference temperature, the steady profile is

θ(x) = (cos(m(x − L/2)) / cos(mL/2) − 1) / α,  m² = αJ²ρ₂₀ / k.

- J = 120 A / 0.25 mm² = 480 A/mm²; m = 200.6 m⁻¹; mL/2 = 1.003.
- θ_max = (1 / cos(1.003) − 1) / 0.00393 = **218.7 K**, so the middle reads **238.7 °C**.
- At constant resistivity the rise would be ρJ²L² / (8k) = 128.0 K.
- Power at the operating point: 15.52 W, a voltage of 129.3 mV across the element.

## Expected result

`peak_temperature` should read 238.7 °C within 2 K.

Outputs: temperature, peak_temperature, current_density.
