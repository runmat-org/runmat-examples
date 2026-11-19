# Heat loss from an insulated hot-oil pipe: a conjugate heat transfer FEA study with convection and radiation

This study solves engine oil at 127 °C flowing through a 1-inch schedule 40 steel pipe lagged with
25 mm of glass-fiber blanket, together with conduction in the pipe and the jacket. Outside, the
jacket loses heat to 25 °C still air by natural convection and radiation. The study returns the
jacket's surface temperature, the pipe's peak temperature and the oil outlet temperature, and its
energy closure gives the heat lost. The radial resistance network gives 28 W/m and a 36 °C surface.

## The problem

Lagging on a hot line has two jobs: hold the heat loss to an acceptable figure and keep the outer
surface cool enough to touch. Both come from the same series of thermal resistances, from the oil
through the pipe wall and the insulation to the air. The insulation dominates, but the outside
film matters too. Here radiation, at 5.7 W/m²·K, carries more heat than convection at 3.9 W/m²·K.

Per meter of line, the hand check in the study's header adds four resistances:

| Layer | Resistance (m·K/W) |
| --- | --- |
| Oil film, thermally developing over 150 mm: Gz = 6800, Nu = 1.953 Gz^(1/3) = 37, h = 186 W/m²·K | 0.064 |
| Steel pipe wall, ln(16.70 / 13.32) / (2π × 63.9) | 0.0006 |
| Glass-fiber jacket, ln(41.70 / 16.70) / (2π × 0.046) | 3.166 |
| Outer surface: 3.9 W/m²·K convection plus 5.7 W/m²·K radiation over π × 0.0834 m | 0.396 |
| Total | 3.63 |

The line loses (126.85 − 25) / 3.63 = 28 W/m, 4.2 W over the modeled 150 mm, and the jacket surface
sits at 25 + 28 × 0.396 = 36 °C. The convection coefficient is the Churchill–Chu value for a
horizontal 83.4 mm cylinder about 11 K above the air (Ra = 5.8 × 10⁵, Nu = 12.5). The radiation
term is 0.9σ(Ts² + Ta²)(Ts + Ta) at Ts = 36 °C, for white acrylic paint at emissivity 0.90.

## How the study works

1. **Geometry and mesh.** `geometry/insulated-oil-line.step` holds a 150 mm length of line as three
   bodies sharing their faces: `Oil` (26.64 mm bore), `Pipe` (33.40 mm outside) and `Jacket`
   (83.40 mm outside). Linear tetrahedra at 5 mm, refined to 1.5 mm on the oil wall and 1.7 mm in
   the pipe. The cut ends are insulated, as along a long run.

2. **Materials.** From Incropera: engine oil at 400 K (825.1 kg/m³, 0.00874 Pa·s, 0.134 W/m·K,
   Pr = 152), AISI 1010 steel (63.9 W/m·K) and a 16 kg/m³ glass-fiber blanket (0.046 W/m·K).

3. **Flow.** Oil at 0.1 m/s and 400 K into the inlet (Re = 251, laminar), 0 Pa at the outlet, no
   slip on the wall, and perfect thermal contact between the oil and the pipe bore.

4. **Outer faces.** Natural convection and radiation on the jacket surface, both to 25 °C:

   ```
   load still_air {
       thermal.convection {
           target = geometry.line.region.jacket_surface
           ambient_temperature = 298.15 K
           coefficient = 3.9 W/m^2/K
       }
   }
   load surroundings {
       thermal.radiation {
           target = geometry.line.region.jacket_surface
           ambient_temperature = 298.15 K
           emissivity = 0.9
       }
   }
   ```

5. **Study and outputs.** A steady conjugate heat transfer analysis, with surface, pipe and outlet
   temperatures:

   ```
   analysis operating_point { conjugate_heat_transfer steady {} }
   output jacket_surface_temperature = mean(output.temperature, over = geometry.line.region.jacket_surface)
   output peak_pipe_temperature = max(output.temperature, over = geometry.line.region.pipe)
   ```

## Results

| Quantity | Hand check |
| --- | --- |
| Heat loss | 28 W/m, 4.2 W over 150 mm |
| `jacket_surface_temperature` | 36 °C |
| `peak_pipe_temperature` | within 2 K of the oil, about 125 °C |
| `oil_outlet_temperature` | within 0.1 K of 126.85 °C |

The study also returns `peak_jacket_surface_temperature` and the temperature, velocity and pressure
fields; its energy closure reports the heat lost by convection and radiation, to compare with
4.2 W. The oil cools only 0.04 K over the short length, so the temperature field is almost entirely
a radial drop across the jacket.

## What to try

1. Change the jacket's `conductivity` to 0.035 W/m·K. With the same outer coefficients, the network
   gives 22 W/m and a surface at 33.7 °C.
2. Remove the `surroundings` radiation load. With convection alone at 3.9 W/m²·K, the network gives
   24 W/m and a surface near 49 °C. A hotter surface also raises the natural-convection coefficient,
   so treat that as an upper bound.
3. Raise the oil temperature to 150 °C (423.15 K) and compare the surface temperature with a
   touch-safe limit.

## Files

- `insulated-oil-line.fea`: the conjugate heat transfer study, with the radial resistance network in its header.
- `geometry/insulated-oil-line.step`: the oil, pipe and jacket as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Conjugate heat transfer in RunMat](https://runmat.com/simulation/conjugate-heat-transfer)
- [Thermal loads](https://runmat.com/docs/simulation/loads/thermal) and [steady heat transfer guide](https://runmat.com/docs/simulation/guides/steady-heat-transfer)
- [Heated tube Nusselt number](../heated-tube-nusselt) and [pin fin with a convecting tip](../pin-fin-convection)
- [Download RunMat](https://runmat.com/download)
