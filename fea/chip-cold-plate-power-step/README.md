# Chip cold plate warm-up after a 50 W power step: a transient conjugate heat transfer FEA study

This study follows a water-cooled aluminum cold plate from the moment a 20 × 20 mm die on it
switches on at 50 W. The 80 × 40 × 12 mm 6061-T6 block carries one straight 6 mm channel with water
at 0.25 m/s entering at 25 °C. The study solves the water flow and the heat in the block and the
water together for 150 s, and samples the die temperature as it climbs. Hand checks put the die
near 46 °C at steady state, with a time constant of about 35 s, and the water 1.70 K warmer at the
outlet.

## The problem

When a processor or power device switches on, its cold plate takes time to warm up. The transient
sets how hot the die runs through a short burst of load and how long the plate takes to settle, so
it matters for duty cycles and for control loops that read the die temperature.

The flow is laminar: 0.25 m/s in the 6 mm bore is 7.05 × 10⁻³ kg/s with Re = 1749. The hand checks
in the study's header estimate the steady state in three parts:

- **Water rise.** Q / (ṁc) = 50 / (7.05 × 10⁻³ × 4179) = 1.70 K mixed mean, so the water leaves at
  26.7 °C.
- **Film.** The 80 mm channel is in its thermal entrance. Shah's mean Nusselt number for uniform
  flux, with Gz = Re Pr d / L = 765, is

  $$Nu = 1.953\,Gz^{1/3} = 17.9, \qquad h = \frac{17.9 \times 0.613}{0.006} = 1825\ \text{W/m}^2\text{K}$$

  Over 1.51 × 10⁻³ m² of channel wall, that is an 18 K drop. Fully developed flow (Nu = 4.36) would
  give 74 K, an upper bound the short channel never reaches.
- **Conduction** through the 4 mm of aluminum under the die adds at most 3 K.

Together the die settles near 25 + 0.9 + 18 + 2 = 46 °C. The block stores ρcV = 2700 × 896 ×
3.61 × 10⁻⁵ = 87 J/K behind about 0.4 K/W, so τ ≈ 35 s: about 63 % of the final rise by 35 s and
95 % by 105 s.

## How the study works

1. **Geometry and mesh.** `geometry/chip-cold-plate.step` holds the block (`Cold plate`) and the
   water in its channel (`Coolant`) as separate bodies that share the channel wall. Linear
   tetrahedra at 2.5 mm, refined to 0.75 mm on the channel wall.

2. **Materials.** 6061-T6 aluminum (2,700 kg/m³, 167 W/m·K, 896 J/kg·K, ASM) and water at 300 K
   (997 kg/m³, 855 × 10⁻⁶ Pa·s, 0.613 W/m·K, 4,179 J/kg·K, Incropera Table A.6).

3. **Loads and flow.** 125 kW/m² on the die footprint (50 W on 400 mm²) from t = 0, 0.25 m/s at
   25 °C into the inlet, 0 Pa at the outlet, no slip on the wall and perfect thermal contact across
   it. The other outer faces are insulated.

   ```
   load die_power { heat_flux on geometry.plate.region.die = 125000 W/m^2 }
   ```

4. **Transient analysis.** 0 to 150 s in 1 s steps, starting the block and the water at 25 °C:

   ```
   analysis warm_up {
       conjugate_heat_transfer transient {
           start_time = 0 s
           end_time = 150 s
           time_step = 1 s
       }
       initial_conditions = [model.initial.block_start, model.initial.coolant_start]
   }
   ```

5. **Outputs.** The peak die temperature, the mean water temperature on the outlet face, and the
   die temperature sampled at eight times:

   ```
   output die_temperature_history {
       value = sample(
           output.peak_die_temperature,
           over = time,
           at = [5 s, 10 s, 20 s, 35 s, 50 s, 75 s, 105 s, 150 s],
       )
   ```

## Results

| Quantity | Hand check |
| --- | --- |
| Reynolds number | 1749 |
| Water outlet rise, mixed mean | 1.70 K |
| Film drop at the channel wall | 18 K |
| Steady die temperature | about 46 °C |
| Time constant | about 35 s |

The study returns the die temperature history, the final `peak_die_temperature` and
`outlet_temperature`, and the final temperature, velocity and pressure fields. Plot the history
against 1 − e^(−t/τ) with τ = 35 s to compare it with the lumped hand check. The outlet value is an
area mean over the face, which weights the slower, warmer water near the wall less than the mixed
mean does, so it reads a little under 26.7 °C. The uniform inlet profile makes the entrance film
stronger than Shah's estimate, so a steady die temperature a few kelvin under 46 °C is consistent.

## What to try

1. Raise the inlet velocity to 0.28 m/s, which keeps the flow laminar at Re 1959. The hand check
   gives a water rise of 1.52 K; look at how much the die temperature falls with it.
2. Raise the die load to 100 W (`heat_flux` 250,000 W/m²). All the hand-check drops double, so the
   die settles near 67 °C.
3. Extend `end_time` to 300 s and check that the die history has flattened.

## Files

- `chip-cold-plate-power-step.fea`: the transient conjugate heat transfer study, with its hand checks in the header.
- `geometry/chip-cold-plate.step`: the block and the water as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Conjugate heat transfer in RunMat](https://runmat.com/simulation/conjugate-heat-transfer)
- [Conjugate heat transfer physics reference](https://runmat.com/docs/simulation/physics/conjugate-heat-transfer) and [transient study guide](https://runmat.com/docs/simulation/language/guides/transient-study-with-generated-inputs)
- [EV battery module on a liquid cold plate](../battery-cold-plate) and [heated tube Nusselt number](../heated-tube-nusselt)
- [Download RunMat](https://runmat.com/download)
