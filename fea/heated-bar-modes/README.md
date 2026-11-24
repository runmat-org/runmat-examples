# Natural frequencies of a heated, clamped steel bar: thermal prestress in a modal FEA study

This study finds how heating lowers the natural frequencies of a steel bar, 1000 × 100 × 100 mm,
clamped at both ends. The bar is clamped at 20 °C and heated to 220 °C; the clamps stop it growing,
so it carries 5,040 kN of axial compression. A thermal step, a thermomechanical preload and a
prestressed modal step return the first two modes of the hot bar. The compression is 7.3 % of the
bar's buckling load, so beam theory puts mode 1 at 0.963 of its cold value.

## The problem

Axial compression softens a structure in bending, and tension stiffens it. A guitar string rises in
pitch as it is tightened, and a column's lowest frequency falls toward zero as its load approaches
the buckling load. A part that is restrained and then heated, such as a pipe between anchors, a rail
or a turbine component, picks up that compression from thermal expansion it cannot relieve.

For a bar fully restrained at both ends, the thermal force is

$$P = E A \alpha \Delta T = 210\ \text{GPa} \times 0.01\ \text{m}^2 \times 12 \times 10^{-6} \times 200 = 5{,}040\ \text{kN}$$

Its clamped-clamped buckling load is P_cr = 4π²EI/L² = 69,087 kN, so P/P_cr = 0.0730. E cancels in
that ratio. Mode 1 falls by about

$$\frac{f_{hot}}{f_{cold}} \approx \sqrt{1 - P/P_{cr}} = 0.963$$

Euler–Bernoulli theory puts the cold mode 1 at 531.7 Hz and the hot one at about 512 Hz. The solid
model reads lower than both, because shear deformation matters on a bar this stocky (L/h = 10).
The ratio is the quantity to compare.

## How the study works

1. **Geometry and mesh.** `geometry/heated-bar.step` names the body `Bar` and the faces `End A`
   and `End B`. Quadratic tetrahedra at a 50 mm target size.

2. **Material.** S275 steel: E = 210 GPa, ν = 0.3, ρ = 7,850 kg/m³, α = 12 × 10⁻⁶ /K
   (EN 1993-1-1, 3.2.6), k = 45 W/m·K.

3. **Model.** Both ends are clamped, and both are held at 220 °C. With no other heat path, the bar
   comes to a uniform 220 °C, 200 K above the 20 °C at which it was clamped.

4. **Three steps.** A steady thermal step finds the temperature, the preload turns it into thermal
   stress and geometric stiffness, and the modal step uses that stiffness:

   ```
   analysis heat { thermal steady {} retain heated }
   analysis preload after analysis.heat {
       thermomechanical preload { temperature = analysis.heat.state.heated }
   }
   analysis modes after analysis.preload {
       structural modal {
           prestress = analysis.preload.state.geometric_stiffness
           modes = 2
   ```

## Results

The run reports the temperature field, uniform at 220 °C, and the two mode shapes, with the
frequencies in its mode table. Mode 1 is the first bending mode, symmetric about mid-span with the
largest motion at the middle. To read the thermal effect, run the same study with the ends held at
20 °C and divide the hot mode 1 frequency by the cold one; beam theory predicts 0.963.

## What to try

1. Raise the temperature to 320 °C (ΔT = 300 K). P/P_cr becomes 0.109, so beam theory predicts mode 1
   at 0.944 of its cold value.
2. Change `youngs_modulus` and compare the hot-to-cold ratio. E cancels in P/P_cr, so the ratio
   should not move, even though both frequencies do.
3. Ask for `modes = 6` and compare how much the compression lowers each mode. Higher bending modes
   have higher buckling loads, so the same force lowers them less.

## Files

- `heated-bar-modes.fea`: the study: geometry, mesh, material, clamps, end temperatures and the three analysis steps, with its hand check in the header.
- `materials.module`: the material the study imports, `steel_s275`.
- `geometry/heated-bar.step`: the bar as STEP, with the body and both ends named.
- `runmat.toml`: the project file.

## Related

- [Thermomechanical simulation in RunMat](https://runmat.com/simulation/thermomechanical)
- [Thermal stress guide](https://runmat.com/docs/simulation/guides/thermal-stress) and [modal analysis guide](https://runmat.com/docs/simulation/guides/modal-analysis)
- [Rail thermal buckling](../rail-thermal-buckling), [column buckling](../column-buckling) and [tuning fork modes](../tuning-fork-modal)
- [Download RunMat](https://runmat.com/download)
