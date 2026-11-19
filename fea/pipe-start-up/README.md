# Laminar pipe flow starting from rest: a transient CFD check against Szymanski's solution

This study switches on an 807 Pa pressure difference across a 10 mm bore, 300 mm long, full of
ISO VG 46 oil at rest, and follows the flow as it builds up. It samples the mean oil speed ten
times through the first 0.6 s. Szymanski's solution puts the final mean speed at 0.212 m/s
(1 L/min), with 63 % of it reached at 0.090 s and 95 % at 0.277 s.

## The problem

When a valve opens on a line full of viscous fluid, the flow does not appear at once: the pressure
has to accelerate the fluid against the wall's drag, and the wall's influence spreads inward by
viscous diffusion. The time scale is set by the bore and the viscosity, R²/ν = 0.005² / 46 × 10⁻⁶ =
0.543 s. That sets how fast a lubrication circuit or a hydraulic actuator responds.

Szymanski (1932) solved the start-up of pipe flow under a step pressure gradient. The mean speed
follows

$$\frac{U(t)}{U_\infty} = 1 - \sum_n \frac{32}{\lambda_n^4}\, e^{-\lambda_n^2 \nu t / R^2}$$

with λₙ the zeros of J₀ (2.405, 5.520, …). The final mean speed is the Hagen–Poiseuille value,
U∞ = ΔPd² / (32μL) = 807 × 10⁻⁴ / (32 × 0.0396 × 0.300) = 0.212 m/s, a few percent less for the
entrance loss. After a few milliseconds the first term dominates: U/U∞ = 1 − 0.957
exp(−5.783 t / 0.543 s). 95 % of the final flow comes at νt/R² = ln(0.957 / 0.05) / 5.783 = 0.510,
so t₉₅ = 0.277 s.

## How the study works

1. **Geometry and mesh.** `geometry/oil-line-d10x300.step`, the same line as the steady
   [hydraulic line study](../hydraulic-line-poiseuille): body `Oil` with faces `Inlet`, `Outlet` and
   `Wall`. Linear tetrahedra at 1.5 mm.

2. **Material.** ISO VG 46 at 40 °C: 861 kg/m³, μ = 0.0396 Pa·s.

3. **Model.** The oil starts at rest. The pressure difference is applied in full from t = 0, as
   807 Pa on the inlet and 0 Pa on the outlet:

   ```
   constraint bore { fluid.no_slip_wall { target = geometry.line.region.wall } }
   load supply { fluid.outlet_pressure { target = geometry.line.region.inlet; value = 807 Pa } }
   load discharge { fluid.outlet_pressure { target = geometry.line.region.outlet; value = 0 Pa } }
   ```

4. **Study.** A fluid transient from 0 to 0.6 s in 5 ms steps, about 19 per 94 ms first-mode time
   constant:

   ```
   fluid transient {
       start_time = 0 s
       end_time = 0.6 s
       time_step = 5 ms
   }
   ```

5. **Outputs.** The volume-mean speed, which equals Q/A for flow along the pipe, sampled through the
   start-up:

   ```
   output mean_speed = mean(magnitude(output.velocity), over = geometry.line.region.oil)
   output mean_speed_history {
       value = sample(
           output.mean_speed,
           over = time,
           at = [0.025 s, 0.05 s, 0.1 s, 0.15 s, 0.2 s, 0.25 s, 0.3 s, 0.4 s, 0.5 s, 0.6 s],
       )
   ```

## Results

Szymanski's solution at the sample times:

| t (s) | 0.05 | 0.1 | 0.15 | 0.2 | 0.25 | 0.3 | 0.4 | 0.6 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| U/U∞ | 0.44 | 0.67 | 0.81 | 0.89 | 0.93 | 0.96 | 0.99 | 1.00 |

The study returns `mean_speed_history`, the final `mean_speed` and `peak_speed`, and the final
velocity and pressure fields. Divide the history by the final mean speed and plot it over the table;
backward Euler with 5 ms steps lags the exact curve by about one percent of U∞ at its steepest. The
final `peak_speed` on the axis should be close to twice the final mean.

## What to try

1. Double the pressure to 1,614 Pa. The final speed doubles to 0.424 m/s, and the time to 95 % stays
   0.277 s, because the time scale R²/ν does not depend on the pressure.
2. Change `time_step` to 20 ms and compare the history with the table to see the time-step lag grow.
3. Shorten `end_time` to 0.3 s for a faster run; the flow is at 96 % of its final value by then.

## Files

- `pipe-start-up.fea`: the transient flow study, with Szymanski's solution in its header.
- `geometry/oil-line-d10x300.step`: the oil in the bore as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Fluid flow simulation in RunMat](https://runmat.com/simulation/fluid-flow)
- [Fluid physics reference](https://runmat.com/docs/simulation/physics/fluid) and [fluid loads](https://runmat.com/docs/simulation/loads/fluid)
- [Hydraulic line pressure drop](../hydraulic-line-poiseuille) and [pulse in a compliant tube](../compliant-tube-pulse)
- [Download RunMat](https://runmat.com/download)
