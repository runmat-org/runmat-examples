# Thermal buckling of a steel rail fixed at both ends: a linear buckling FEA study

This study finds how much warming a steel rail can take before it buckles. The rail is 2,000 mm
long with a 20 × 10 mm section, fixed at both ends at 20 °C and then warmed 10 K, so it carries an
axial compression of EαΔT = 25.2 MPa. A thermal analysis, a thermal preload and a linear buckling
analysis return the load factor on the 10 K rise and the buckled shape. The Euler hand check gives
a load factor of 0.685: the rail buckles sideways, across its 10 mm thickness, after 6.85 K.

## The problem

Rails, pipelines, and beams built in between stiff supports cannot grow when they warm, so the
warming turns into axial compression. A long, slender member buckles under that compression at a
small temperature rise, long before the steel yields. That is why continuously welded track is laid
at a set neutral temperature and why pipelines get expansion loops.

A bar fixed at both ends buckles when its thermal force EAαΔT reaches the Euler load 4π²EI/L², so
the critical rise is independent of E:

$$\Delta T_{cr} = \frac{4\pi^2 I}{\alpha A L^2} = \frac{4\pi^2 \times 1667}{12\times10^{-6} \times 200 \times 2000^2} = 6.85\ \text{K}$$

with the weak-axis I = 20 × 10³ / 12 = 1,667 mm⁴ and A = 200 mm². About the strong axis it is
27.4 K. The study applies a 10 K rise, so the buckling load factor is the fraction of that rise at
which the rail buckles: 0.685.

## How the study works

1. **Geometry and mesh.** `geometry/rail.step` holds the rail as body `Rail`, with end faces `End A`
   and `End B`. Quadratic tetrahedra at a 5 mm target size, two elements through the 10 mm
   thickness.

2. **Material.** S275 steel (EN 1993-1-1, 3.2.6): E = 210 GPa, ν = 0.3, α = 12 × 10⁻⁶ /K.

3. **Model.** Both ends fixed, and both held at 30 °C with no other heat path, so the whole rail
   reaches 30 °C, 10 K above the 20 °C reference:

   ```
   constraint fixed_a {
       structural.fixed { target = geometry.rail.region.end_a }
   }
   constraint warm_a {
       thermal.temperature { target = geometry.rail.region.end_a; value = 303.15 K }
   }
   ```

4. **Three analyses in a chain.** The thermal state becomes the preload, and the preload's
   geometric stiffness sets up the buckling eigenproblem:

   ```
   analysis heat { thermal steady {} retain warmed }
   analysis preload after analysis.heat {
       thermomechanical preload { temperature = analysis.heat.state.warmed }
   }
   analysis buckling after analysis.preload {
       structural buckling {
           prestress = analysis.preload.state.geometric_stiffness
           modes = 1
       }
   }
   ```

## Results

| Quantity | Hand check |
| --- | --- |
| Axial stress at 10 K | 25.2 MPa |
| Critical rise, weak axis | 6.85 K |
| Critical rise, strong axis | 27.4 K |
| Buckling load factor on the 10 K rise | 0.685 |

The study returns the temperature field, the buckled shape and the load factor in the run's mode
table. Compare the load factor with 0.685, within 2 %. The buckled shape should be a single
half-wave between the clamped ends, bowing across the 10 mm thickness, the weak direction. A load
factor under 1 means the rail buckles before the full 10 K is reached.

## What to try

1. Shorten the rail to 1,000 mm in a new STEP file. ΔT_cr goes as 1/L², so it rises to 27.4 K and
   the load factor to 2.74: the rail now survives the 10 K rise.
2. Ask for `modes = 3` and compare the higher buckled shapes with the first.
3. Double `expansion_coefficient` to 24 × 10⁻⁶ /K. The hand check halves ΔT_cr to 3.43 K, a load
   factor of 0.343.

## Files

- `rail-thermal-buckling.fea`: the thermal, preload and buckling study, with the Euler hand check in its header.
- `geometry/rail.step`: the rail as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Thermomechanical simulation in RunMat](https://runmat.com/simulation/thermomechanical)
- [Thermal stress guide](https://runmat.com/docs/simulation/guides/thermal-stress) and [thermomechanical physics reference](https://runmat.com/docs/simulation/physics/thermomechanical)
- [Column buckling](../column-buckling) and [restrained bar heated past yield](../clamped-bar-yield)
- [Download RunMat](https://runmat.com/download)
