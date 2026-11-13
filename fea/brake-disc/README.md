# Ventilated brake disc: temperature and thermal stress

A ventilated front brake disc in gray cast iron in a long downhill drag stop: a 1,600 kg car holding 50 km/h down an 8 % grade. The study solves the disc's steady temperature with the air cooling its faces, vanes and hat, then the thermal stress with the hub held at its bolt holes, and reports the peak temperature and peak stress against the iron's tensile strength.

## Files

| File | What it is |
| --- | --- |
| `disc.part` | The disc in RunMat MCAD. Plate, channel, eye, hat and bore sizes are inputs at the top; the vane sketch comes from its generator in runmat-cad. |
| `geometry/disc.step` | The part exported to STEP AP242, with the body and face names the study selects. |
| `brake-disc.fea` | The thermal and thermal-stress study, with its duty and hand check in the header. |
| `DESIGN-NOTES.md` | How the disc, its vanes and its iron were chosen, with the hand checks and solved results. |

## The part

- 300 mm outside, 28 mm thick: two 9 mm friction plates joined by 36 straight radial vanes, 5 mm thick and 10 mm tall.
- The inboard plate's 184 mm eye feeds the vane channels; the hat carries the outboard plate to a 7 mm hub face with five 14 mm holes on a 114.3 mm pitch circle and a 66 mm center bore.

Names in the STEP file: body `Rotor`; faces `Friction face inboard`, `Friction face outboard`, `Vanes` (the vanes and the plates' faces between them), `Bolt holes` and `Exterior`.

## Limits

- Duty: 4.7 kW into each front disc, steady, split evenly between the two friction faces (53.3 kW/m² on each swept annulus). Air at 40 °C: 60 W/m²/K on the faces, 80 in the vane channels, 30 on the hat. Radiation is left out, which overstates the temperature.
- Iron: EN-GJL-250, minimum tensile strength 250 MPa (EN 1561), the allowable for the peak stress.
- Linear elastic iron with properties fixed at room temperature; the hub is held rigidly at its bolt holes.

## What to change

- The duty is the two `heat_flux` loads in `brake-disc.fea`; the cooling is the four convection loads.
- `plate`, `channel` and `hat_height` resize the ring and the hat; the vane count and thickness are in the generator.
- After a change to the part, export it to `geometry/disc.step` and run the study again.
