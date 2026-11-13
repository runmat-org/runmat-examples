# Coaxial bushing electric field

Electric field in the cast-epoxy insulation of a coaxial high-voltage bushing: a 20 mm conductor bore at 36 kV inside an 80 mm grounded sleeve, 100 mm long. The study returns the potential and the field, which peaks at the conductor surface, against the coaxial-cylinder solution.

## Files

| File | What it is |
| --- | --- |
| `coaxial-bushing.fea` | The study, with its hand check in the header. |
| `geometry/coaxial-bushing.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: body `Insulation`; faces `Conductor bore`, `Ground sleeve` and `Insulation ends`.

## The part

- Cast-epoxy insulation, bore 20 mm, outside 80 mm, 100 mm long.

## Setup

- `Conductor bore` at 36 kV, `Ground sleeve` at 0 V. The end faces carry no condition, so no field leaves them.
- Cast epoxy, relative permittivity 4.2, a typical value for silica-filled casting resin. The field does not depend on it.
- Electrostatics.

## Hand check

Between coaxial cylinders of radii a and b, E(r) = V / (r ln(b/a)):

- At the conductor (r = 10 mm): 36 kV / (10 mm × ln 4) = **2.60 kV/mm**.
- At the sleeve (r = 40 mm): **0.65 kV/mm**.
- Potential V(r) = V ln(b/r) / ln(b/a); at r = 20 mm it is exactly **18.0 kV**.
- Capacitance 2πε₀εr L / ln(b/a) = 16.9 pF for this 100 mm length.

## Expected result

`peak_field` should read 2.60 kV/mm and `sleeve_field` 0.65 kV/mm, within 2 %; `mid_potential` should read 18.0 kV within 0.5 %.

Outputs: potential, electric_field, peak_field, sleeve_field, mid_potential.
