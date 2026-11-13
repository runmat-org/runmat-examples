# Heated panel frequency response

Forced vibration of a titanium heat-shield panel (200 x 200 x 6 mm) beside an engine exhaust, clamped on its four edges and running 150 K above its fitting temperature. The in-plane compression lowers its natural frequencies. A thermal step, a preload, a prestressed modal step and a modal frequency sweep from 500 Hz to 1.6 kHz return the hot modes and the response to a uniform 1 kPa of exhaust noise.

## Files

| File | What it is |
| --- | --- |
| `heated-panel-harmonic.fea` | The study, with its hand check in the header. |
| `geometry/titanium-panel.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Panel`; faces `Clamped edges`, `Exhaust side` and `Outer side`.

## The part

- Ti-6Al-4V panel, 200 × 200 × 6 mm.

## Setup

- Four edges clamped (`structural.fixed`) at 20 °C, then the panel runs at 170 °C: the edges held at 170 °C with no other heat path, so the panel is uniform.
- A uniform 1 kPa on the hot side (40 N over the face), 500 Hz to 1.6 kHz.
- Thermal steady → thermomechanical preload (no noise load) → prestressed modal, six modes → prestressed harmonic on that basis, with static correction.
- Ti-6Al-4V, annealed: E = 113.8 GPa, ν = 0.342, ρ = 4430 kg/m³, α = 8.6 × 10⁻⁶ /K (ASM Aerospace Specification Metals data sheet). Rayleigh stiffness damping 6.4 μs, about 2 % of critical at 1 kHz; this is a modeling choice.

## Hand check

- Plate stiffness D = Eh³ / (12(1 − ν²)) = 2320 N·m.
- Cold mode 1 of a clamped square plate: f = 35.99 / (2πa²) √(D / (ρh)) = **1338 Hz** (Leissa, *Vibration of Plates*).
- Uniform heating buckles the clamped panel when its thermal membrane force Eh αΔT / (1 − ν) reaches about 5.3π²D / a² (Timoshenko and Gere, *Theory of Elastic Stability*): ΔT_cr ≈ 341 K.
- At 150 K the compression is 0.44 of that, so mode 1 falls by about √(1 − 0.44) = 0.75, to **about 1000 Hz**.

## Expected result

The hot mode 1 should read about 1000 Hz, within 5 % (the ratio estimate is approximate). The response should peak near it inside the 500 Hz to 1.6 kHz sweep. Modal frequencies are published in the run's mode table.

Outputs: mode_shapes, displacement (frequency response); modal frequencies in the run's mode table.
