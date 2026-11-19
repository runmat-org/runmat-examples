# Ventilated brake disc temperature and thermal stress in a downhill drag stop: a thermomechanical FEA study

This study takes a 300 mm ventilated front brake disc in EN-GJL-250 gray iron through its hardest
steady duty: a 1,600 kg car holding 50 km/h down an 8 % grade, which puts 4.7 kW into each front
disc. It solves the disc's steady temperature with air cooling its faces, vanes and hat, then the
thermal stress with the hub held at its bolt holes. A hand check puts the ring near 370 °C; the
study reports the peak temperature and the peak von Mises stress against the iron's 250 MPa
tensile strength.

## The problem

On a long descent the brakes hold the car's speed, and the disc must shed the grade's power to the
air as fast as it absorbs it. The grade gives m g sin(a) v = 1600 × 9.81 × 0.0798 × 13.9 =
17.4 kW. Rolling resistance (2.6 kW) and aerodynamic drag (1.4 kW) take 4.0 kW, so the brakes
absorb 13.4 kW. The front axle takes 70 %, so each front disc takes 4.7 kW, split evenly between
its two friction faces and spread over each face's swept annulus (r = 92 to 150 mm, 0.0441 m²):
53.3 kW/m².

The study's cooling at 50 km/h, with air at 40 °C under the wheel arch, is 60 W/m²·K on the
friction faces, 80 W/m²·K in the vane channels and 30 W/m²·K on the hat and edges. The faces
(0.088 m²), vane channels (0.10 m²) and hat (0.03 m²) together give about 14.2 W/K, so the ring runs
about 330 K over the air, near 370 °C. Radiation is left out, which overstates the temperature.

The hot ring is joined to a cooler hat, which holds it back. Fully restrained, the ring would
carry

$$\sigma = \frac{E\,\alpha\,\Delta T}{1-\nu} = \frac{110\ \text{GPa} \times 12.5\times10^{-6} \times 100\ \text{K}}{0.74} = 186\ \text{MPa}$$

per 100 K of ring-to-hat difference. The hat's flexibility relieves most of that, and the study
finds how much is left.

## How the study works

1. **The part.** `disc.part` builds two 9 mm friction plates joined by 36 radial vanes (5 mm thick,
   10 mm tall), a 184 mm eye that feeds the vane channels, and a hat that carries the outboard plate
   to a hub face with five 14 mm holes on a 114.3 mm pitch circle. It is exported to
   `geometry/disc.step` with the friction faces, `Vanes`, `Bolt holes` and `Exterior` named.

2. **Mesh and material.** Quadratic tetrahedra at a 6 mm target size. EN-GJL-250 to EN 1561:
   E = 110 GPa, ν = 0.26, α = 12.5 × 10⁻⁶ /K, k = 48.5 W/m·K.

3. **Heat in and out.** 53.3 kW/m² into each friction face, and convection to 40 °C air on every
   surface:

   ```
   load pad_inboard { thermal.heat_flux { target = geometry.disc.region.friction_inboard; value = 53300 W/m^2 } }
   load vane_air {
       thermal.convection {
           target = geometry.disc.region.vanes
           ambient_temperature = 313.15 K
           coefficient = 80 W/m^2/K
       }
   }
   ```

4. **Two analyses in sequence.** A steady thermal analysis keeps its temperature state, and a
   thermomechanical analysis takes that state as its preload, with the bolt holes fixed:

   ```
   analysis heat { thermal steady {} retain hot }
   analysis stress after analysis.heat {
       thermomechanical preload { temperature = analysis.heat.state.hot }
   }
   ```

5. **Outputs.** The temperature and von Mises fields and their maxima over the rotor:

   ```
   output peak_temperature = max(analysis.heat.field.node.temperature, over = geometry.disc.region.rotor)
   output peak_stress = max(output.von_mises, over = geometry.disc.region.rotor)
   ```

## Results

| Quantity | Hand check | Criterion |
| --- | --- | --- |
| Power into each front disc | 4.7 kW | |
| Heat flux on each friction face | 53.3 kW/m² | |
| Ring temperature | about 370 °C | under 450 to 500 °C, where gray-iron discs start to fade and craze |
| Fully restrained stress | 186 MPa per 100 K | 250 MPa tensile strength |

The study returns the disc's temperature field, `peak_temperature`, the von Mises stress field and
`peak_stress`. Compare `peak_stress` with the 250 MPa minimum tensile strength of EN-GJL-250, and look
at the temperature field across the hat to see the ring-to-hat difference that drives the stress.

## What to try

1. Ease the grade to 6 %. By the same hand check each front disc takes 3.17 kW, so set both
   `heat_flux` loads to 35,980 W/m²; the ring falls to about 264 °C.
2. Change the vane coefficient in `vane_air` to see how much of the cooling the vents provide.
3. Change `hat_height` or `hat_wall` in `disc.part`, export it to `geometry/disc.step`, and compare
   `peak_stress`: a deeper or thinner hat lets the ring grow more freely.

## Files

- `brake-disc.fea`: the thermal and thermal-stress study, with the duty and hand checks in its header.
- `disc.part`: the disc in RunMat MCAD, with the plate, channel, eye, hat and bore sizes as inputs.
- `geometry/disc.step`: the part exported to STEP, with the body and face names the study selects.
- `DESIGN-NOTES.md`: how the duty, the vanes, the iron and the hat depth were chosen, with the hand checks.
- `runmat.toml`: the project file.

## Related

- [Thermomechanical simulation in RunMat](https://runmat.com/simulation/thermomechanical)
- [Thermal stress guide](https://runmat.com/docs/simulation/guides/thermal-stress) and [thermal loads](https://runmat.com/docs/simulation/loads/thermal)
- [Restrained bar heated past yield](../clamped-bar-yield) and [rail thermal buckling](../rail-thermal-buckling)
- [Download RunMat](https://runmat.com/download)
