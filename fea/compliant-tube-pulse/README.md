# Pressure wave speed in a compliant silicone tube: a transient fluid-structure FEA study

This study sends a 4 ms surge of inflow into a water-filled silicone tube, 10 mm bore, 1 mm wall and
200 mm long, and solves the water and the tube wall together as the pulse travels. It samples the
pressure on the axis 50 mm and 150 mm from the inlet every 0.5 ms for 15 ms. The Moens–Korteweg
wave speed of 15 to 17 m/s sets a delay of 5.9 to 6.7 ms between the two pressure peaks.

## The problem

In a rigid pipe a pressure pulse travels at the speed of sound in the liquid. In a soft tube the wall stretches as the pulse passes, and the wave slows to a speed set by
the wall's stiffness. That is the physics of the arterial pulse, and it matters for soft fluid
lines, peristaltic pumps and catheters. The Moens–Korteweg speed for a thin elastic tube full of
liquid is

$$c = \sqrt{\frac{E\,h}{\rho\,d}} = \sqrt{\frac{2.46\times10^6 \times 0.001}{997 \times 0.010}} = 15.7\ \text{m/s}$$

with E = 2.46 MPa for 50 Shore A silicone (from Gent's relation between Shore A hardness and Young's
modulus), wall thickness h = 1 mm, water density ρ = 997 kg/m³ and bore d = 10 mm. The wall is 10 %
of the bore, so using the mean diameter (11 mm) gives 15.0 m/s, and the fixed ends restrain the wall
axially, which raises c by 1/√(1 − ν²) to about 17 m/s. The hand check takes 15 to 17 m/s.

The pulse peak leaves the inlet at 2 ms, passes 50 mm at 4.9 to 5.3 ms and 150 mm at 10.8 to
12.0 ms. Its pressure is about ρcu = 997 × 15.7 × 0.05 = 0.78 kPa, which swells the bore by
Δp d / (2Eh) = 1.6 %, about 80 µm on the radius. The open end reflects the pulse inverted, and the
reflected peak gets back to 150 mm after 16.7 ms, outside the 15 ms window.

## How the study works

1. **Geometry and mesh.** `geometry/compliant-tube.step` holds the tube (`Tube`) and the water in
   its bore (`Water`) as separate bodies sharing the bore face. Linear tetrahedra at 1.5 mm, refined
   to 0.5 mm in the wall, two elements through its thickness.

2. **Materials.** Water at 300 K (997 kg/m³, 855 × 10⁻⁶ Pa·s, Incropera Table A.6) and silicone
   rubber (E = 2.46 MPa, ν = 0.49, 1,150 kg/m³).

3. **The surge.** A half-sine inflow, 4 ms long and peaking at 0.05 m/s, sampled every 0.25 ms:

   ```
   signal surge : velocity over time {
       samples = [
           { at = 0 ms, value = 0.00000 m/s },
           ...
           { at = 2 ms, value = 0.05000 m/s },
           ...
           { at = 4 ms, value = 0.00000 m/s },
       ]
   ```

4. **Model.** The outlet opens to a reservoir at 0 Pa gauge, both tube ends are fixed, and the
   water and the wall share a no-slip fluid-structure interface on the bore:

   ```
   interface wetted_wall {
       fluid_structure.no_slip {
           primary = geometry.tube.region.water_wall
           secondary = geometry.tube.region.tube_bore
       }
   }
   ```

5. **Study.** A fluid-structure transient from 0 to 15 ms in 0.2 ms steps, with the axis pressure
   at 50 mm and 150 mm and the largest wall displacement sampled every 0.5 ms:

   ```
   output pressure_50 = interpolate(output.pressure, at = [50 mm, 0 mm, 0 mm])
   output pressure_150 = interpolate(output.pressure, at = [150 mm, 0 mm, 0 mm])
   ```

## Results

| Quantity | Hand check |
| --- | --- |
| Wave speed | 15 to 17 m/s |
| Peak passes 50 mm | 4.9 to 5.3 ms |
| Peak passes 150 mm | 10.8 to 12.0 ms |
| Peak-to-peak delay | 5.9 to 6.7 ms |
| Pulse pressure | 0.78 kPa |
| Bore swelling | 1.6 %, about 80 µm on the radius |

The study returns `pressure_50_history`, `pressure_150_history` and `wall_movement_history`, plus
the final displacement, velocity and pressure fields. Plot the two pressure histories together and
read the delay between their peaks; 100 mm divided by that delay is the solved wave speed.

## What to try

1. Double `youngs_modulus` to 4.92 MPa. The wave speed rises by √2, to 22.2 m/s by the thin-wall
   formula, and the delay falls to 4.5 ms.
2. Double the surge to a 0.1 m/s peak by scaling every sample. The pulse pressure doubles to
   1.57 kPa and the wave speed stays the same.
3. Extend `end_time` to 25 ms to see the inverted reflection from the open end arrive at 150 mm.

## Files

- `compliant-tube-pulse.fea`: the transient fluid-structure study, with its Moens–Korteweg hand check in the header.
- `materials.module`: the materials the study imports: `water` and `silicone_50a`.
- `geometry/compliant-tube.step`: the tube and the water as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Fluid-structure simulation in RunMat](https://runmat.com/simulation/fluid-structure)
- [Fluid-structure interaction physics reference](https://runmat.com/docs/simulation/physics/fluid-structure-interaction) and [transient study guide](https://runmat.com/docs/simulation/language/guides/transient-study-with-generated-inputs)
- [Paddle flow switch deflection](../paddle-flow-switch) and [pipe flow start-up](../pipe-start-up)
- [Download RunMat](https://runmat.com/download)
