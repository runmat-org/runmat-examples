# Hydraulic manifold pressure drop at 20 L/min: a laminar CFD study of a drilled block

This study solves steady laminar flow of ISO VG 46 oil at 40 °C through both lines of a
90 × 80 × 50 mm crossover manifold at 20 L/min, and assesses the pressure drop from port P to work
port A against a 1 bar budget. The block is a parametric RunMat MCAD part with 12 mm galleries
drilled from the sides and 10 mm work ports from the top. A hand check puts the P-to-A drop at about
22 kPa, 0.22 bar, inside the budget by a factor of 4.5.

## The problem

Every bar a manifold loses is pump power turned into heat in the oil, so a hydraulic designer
gives each path through the block a loss budget at its rated flow. Most of the loss in a drilled
block comes from the junctions where drillings meet at right angles, which a friction formula for
straight pipe does not cover.

At 20 L/min (3.333 × 10⁻⁴ m³/s) the oil runs at 2.95 m/s in a 12 mm gallery and 4.24 m/s in a 10 mm
port. With 46 cSt oil that is Re = 768 and 922, laminar. The hand check for P to A adds three parts:

- developed laminar friction, 128μQL / (πd⁴), over 50 mm of gallery: 1.3 kPa;
- the same over 30 mm of port A: 1.6 kPa;
- the entry, the right-angle turn and the exit, about K = 2.5 on the port's ½ρU² = 7.74 kPa:
  19 kPa.

That is about 22 kPa. The 3D flow solution replaces the K-factor estimate for the junction, the
largest of the three.

## How the study works

1. **The part.** `manifold.part` builds the block with both lines and the oil in them, every size an
   input:

   ```
   input bore : length = 10 mm
   input gallery : length = 12 mm
   input p_depth : length = 60 mm
   input a_x : length = 50 mm
   ```

   The galleries are larger than the ports, so each port enters its gallery inside the gallery's
   wall, a clean junction to machine. The part's `oil_only` configuration is exported to
   `geometry/manifold-oil.step`, with faces `Port P`, `Port A`, `Port B`, `Port T` and
   `Passage wall`. The block is a rigid wall to the oil, so only the oil is meshed.

2. **Mesh and material.** Linear tetrahedra at 1.5 mm. ISO VG 46 at 40 °C: 861 kg/m³,
   μ = 0.0396 Pa·s.

3. **Flow.** 20 L/min into P along the gallery and into B down the port, 0 Pa gauge at A and T, and
   no slip on the passage walls:

   ```
   constraint supply {
       fluid.velocity { target = geometry.manifold.region.port_p; value = [2.947 m/s, 0 m/s, 0 m/s] }
   }
   load work_port_a { fluid.outlet_pressure { target = geometry.manifold.region.port_a; value = 0 Pa } }
   ```

4. **Study and assessment.** A steady fluid analysis. With port A at 0 Pa, the pressure at P is the
   P-to-A drop, assessed against 1 bar:

   ```
   analysis flow { fluid steady {} }
   assessment p_to_a_within_1_bar {
       value = output.pressure_p
       maximum = 100 kPa
       evidence = authored_samples
   }
   ```

## Results

| Quantity | Hand check | Limit |
| --- | --- | --- |
| Reynolds number in port A | 922 | 2000 (laminar) |
| Reynolds number in the P gallery | 768 | 2000 |
| Friction, gallery and port | 1.3 + 1.6 kPa | |
| Entry, turn and exit | 19 kPa | |
| Pressure drop P to A | about 22 kPa (0.22 bar) | 100 kPa (1 bar) |

The study returns the velocity and pressure fields, `peak_speed`, `pressure_p` for the P-to-A line,
`pressure_b` for the B-to-T line, and the assessment's result. Look at the velocity field at the
junction where port A leaves the gallery: the jet turning the corner is where the K-factor loss
comes from.

## What to try

1. Raise the flow to 30 L/min (P inlet 4.421 m/s, B inlet −6.366 m/s). Re in the ports rises to
   1384, still laminar, and the hand check gives about 48 kPa from P to A.
2. Change `bore` to 12 mm, export the `oil_only` configuration to `geometry/manifold-oil.step`, and
   compare `pressure_p`. Keep `gallery` larger than `bore` for a clean junction.
3. Compare `pressure_b` with `pressure_p`: the B-to-T line runs the same drillings in the opposite
   order, port into gallery.

The ports reach Re 2000, the edge of this laminar study, at about 43 L/min.

## Files

- `hydraulic-manifold.fea`: the steady flow study and its 1 bar assessment, with the hand check in the header.
- `materials.module`: the material the study imports, `iso_vg_46`.
- `manifold.part`: the block and its oil in RunMat MCAD, with every size the study depends on as an input.
- `geometry/manifold-oil.step`: the oil, exported from the part's `oil_only` configuration, with the body and face names the study selects.
- `DESIGN-NOTES.md`: how the bores, the layout, the bolt-hole ligaments and the material were chosen, with the hand checks.
- `runmat.toml`: the project file.

## Related

- [Fluid flow simulation in RunMat](https://runmat.com/simulation/fluid-flow)
- [Fluid physics reference](https://runmat.com/docs/simulation/physics/fluid) and the [model a part guide](https://runmat.com/docs/mcad/guides/model-a-part)
- [Hydraulic line pressure drop](../hydraulic-line-poiseuille) and [paddle flow switch deflection](../paddle-flow-switch)
- [Download RunMat](https://runmat.com/download)
