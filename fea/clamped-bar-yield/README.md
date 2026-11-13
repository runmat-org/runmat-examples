# Restrained bar heated past yield

A steel bar, 16 x 16 mm and 200 mm long, held between rigid walls and heated 150 K. The walls stop it growing, so it carries a uniform axial stress that reaches yield at 109 K. A quarter of the bar is solved in load steps with J2 plasticity, and the study returns the stress and displacement at full heating.

## Files

| File | What it is |
| --- | --- |
| `clamped-bar-yield.fea` | The study, with its hand check in the header. |
| `geometry/quarter-bar.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Bar quarter`; faces `End A`, `End B`, `Mid-plane Y` and `Mid-plane Z`.

## The part

- One quarter of a 16 × 16 mm steel bar, 200 mm long, cut on its two mid-planes.

## Setup

- Both ends on rigid walls that slide (`structural.symmetry`: no axial motion, free sideways). The two mid-planes are symmetry planes.
- A uniform temperature rise of 150 K (20 °C to 170 °C), applied over load factors 0 to 1.
- S275 steel: E = 210 GPa, ν = 0.3, α = 12 × 10⁻⁶ /K (EN 1993-1-1, 3.2.6); f_y = 275 MPa for thicknesses up to 16 mm (EN 10025-2); hardening slope E/10000 = 21 MPa (EN 1993-1-5, Annex C.6).

## Hand check

The bar cannot grow and its sides are free, so the stress is uniaxial and uniform: σ = EαΔT until yield.

- First yield at ΔT = f_y / (Eα) = 275 MPa / (210 GPa × 12 × 10⁻⁶) = **109.1 K**, a load factor of **0.727**.
- Elastic, 150 K would give 378 MPa. With yield the stress holds at **275.0 MPa** (275.01 on the hardening slope) and the plastic strain is αΔT − f_y/E = **4.9 × 10⁻⁴**.
- The modulus is held at its 20 °C value. EN 1993-1-2 reduces it by a factor of about 0.93 at 170 °C, which would move first yield to about 117 K.

## Expected result

`peak_von_mises` should read 275.0 MPa within 0.5 %, uniform along the bar.

Outputs: stress, von_mises, displacement, peak_von_mises.
