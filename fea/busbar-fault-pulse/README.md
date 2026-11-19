# Copper busbar temperature rise in a 25 kA short-circuit: an electrothermal transient FEA study

This study follows a 100 × 40 × 5 mm copper busbar strip through a short-circuit. The strip carries
400 A, then a 25 kA fault for 0.5 s until the breaker clears it, then 400 A again. It solves the
current and the temperature together for 1 s, with copper's resistivity rising as the strip heats.
The adiabatic hand check puts the strip at 62.4 °C when the fault clears, a 42.4 K rise from 20 °C.

## The problem

A busbar must survive the fault current that flows until its breaker opens. For a fraction of a
second the current density is far above the rated value, and almost no heat leaves the copper, so
the conductor heats adiabatically. Its final temperature sets whether insulation, joints and nearby
plastics survive the fault. Short-circuit ratings of conductors rest on the same heat balance:

$$\frac{dT}{dt} = \frac{\rho_{20}\,\left(1 + \alpha\,(T - 20\ ^\circ\text{C})\right) J^2}{\rho_m\, c}$$

Here J = 25 kA / 200 mm² = 125 A/mm², ρ₂₀ = 1/58 Ω·mm²/m and α = 0.00393 /K (IEC 60028), and the
copper's density and specific heat are 8,890 kg/m³ and 385 J/kg·K (ASM Handbook, Vol. 2, C11000).
The strip starts heating at 78.7 K/s. Integrated over the current signal, ramps included, it rises
42.4 K, to 62.4 °C. At constant resistivity the rise would be 39.2 K; the other 3.2 K comes from the
resistivity rising with temperature.

During the fault the strip makes about 5.4 kW of Joule heat and loses about 4 W to still air, which
is why the adiabatic estimate holds. The study models the air cooling as well, so it also follows
the strip after the fault clears.

## How the study works

1. **Geometry and mesh.** `geometry/busbar-strip.step` holds the strip as body `Busbar`, with end
   faces `Terminal A` and `Terminal B` and the rest named `Exterior`. Quadratic tetrahedra at a
   4 mm target size.

2. **Material.** Copper with temperature-dependent resistivity:

   ```
   electrical {
       reference_temperature = 20 degC
       conductivity = 58000000 A/V/m
       resistive_heating_coefficient = 0.00393 K^-1
   ```

3. **The fault current.** A sampled signal drives `Terminal A`: 400 A, a 25 kA fault from 0.1 s to
   0.6 s with 5 ms edges, then 400 A. `Terminal B` is held at 0 V.

   ```
   signal fault_current : electric_current over time {
       samples = [
           { at = 0 s, value = 400 A },
           { at = 0.1 s, value = 400 A },
           { at = 0.105 s, value = 25000 A },
           { at = 0.6 s, value = 25000 A },
           { at = 0.605 s, value = 400 A },
           { at = 1 s, value = 400 A },
       ]
   ```

4. **Cooling and start.** Still air at 20 °C and 10 W/m²·K on the exterior, and the strip starting
   at a uniform 20 °C.

5. **Study.** An electrothermal transient from 0 to 1 s in 5 ms steps, with the peak and mean
   temperature of the strip:

   ```
   analysis pulse {
       electrothermal transient { start_time = 0 s; end_time = 1 s; time_step = 5 ms }
       initial_conditions = [model.initial.room_temperature]
   }
   output peak_temperature = max(analysis.pulse.field.node.temperature, over = geometry.busbar.region.body)
   ```

## Results

| Quantity | Hand check |
| --- | --- |
| Current density in the fault | 125 A/mm² |
| Initial heating rate | 78.7 K/s |
| Rise at the end of the fault, resistivity rising | 42.4 K, to 62.4 °C |
| Rise at constant resistivity | 39.2 K |

The study returns the temperature history and `peak_temperature` and `mean_temperature` over the
strip. Compare the peak at 0.6 s with the 62.4 °C hand check. The current density is uniform along
a straight strip, so the peak and the mean should stay close. After the fault, 400 A adds less than
0.01 K and the air takes away about 0.1 K by 1 s, so the history is almost flat after 0.6 s.

## What to try

1. Lower the fault to 20 kA in the signal. The same adiabatic integration gives about 46.4 °C at
   the end of the fault.
2. Lengthen the fault by moving the 0.6 s and 0.605 s samples later, as a slower breaker would, and
   watch the peak against the insulation's temperature limit.
3. Change `resistive_heating_coefficient` to 0 and compare the peak with the 39.2 K
   constant-resistivity rise.

## Files

- `busbar-fault-pulse.fea`: the electrothermal transient study, with its hand check in the header.
- `geometry/busbar-strip.step`: the strip as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Electrothermal simulation in RunMat](https://runmat.com/simulation/electrothermal)
- [Electrothermal physics reference](https://runmat.com/docs/simulation/physics/electrothermal) and [initial conditions](https://runmat.com/docs/simulation/constraints/initial-conditions)
- [Fuse element overload](../fuse-link-overload) and [EV battery busbar at 400 A](../six-bolt-busbar)
- [Download RunMat](https://runmat.com/download)
