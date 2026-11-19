# Temperature jump across a bolted joint: thermal contact resistance in an FEA study

This study finds the steady temperatures through a copper heat spreader, 30 × 30 × 3 mm, mounted on
an aluminum block of the same footprint, 10 mm thick. A component puts 30 W into the spreader and
the block's underside sits on a 40 °C cold plate. The joint between the two parts is a contact
conductance of 19,048 W/m²·K, and the hand check puts the temperature jump across it at 1.75 K, the
largest single drop in the stack after the block itself.

## The problem

Two metal parts pressed together touch only at the peaks of their surface roughness. Heat crossing
the joint has to squeeze through those spots or through whatever fills the gaps, so the joint adds a
resistance of its own and the temperature jumps across it. In electronics cooling this joint, often
filled with a thermal interface material (TIM), is frequently a large share of the path from
component to coolant.

The footprints match and the sides are insulated, so heat flows straight down at
q″ = 30 W / 900 mm² = 33.3 kW/m² through three resistances in series. The joint uses the contact
resistance of a silicone-oil-filled metal contact, R″ = 0.525 × 10⁻⁴ m²·K/W (Incropera et al.,
*Fundamentals of Heat and Mass Transfer*, Table 3.1), written as a conductance h = 1/R″:

| Layer | Drop | Temperature above it |
| --- | --- | --- |
| Aluminum block, 10 mm / 167 W/m·K | 2.00 K | block top 42.00 °C |
| Joint, 0.525 × 10⁻⁴ m²·K/W | 1.75 K | spreader underside 43.75 °C |
| Copper spreader, 3 mm / 388 W/m·K | 0.26 K | heated face 44.00 °C |

## How the study works

1. **Geometry.** `geometry/tim-stack.step` holds two bodies, `Copper spreader` and
   `Aluminum block`, each keeping its own face at the joint, so the study can put a condition
   between them:

   ```
   region spreader_underside : face { select name "Spreader underside"; expect exactly_one }
   region block_top : face { select name "Block top"; expect exactly_one }
   ```

2. **Mesh and materials.** Quadratic tetrahedra at a 2 mm target size. Copper C11000, k =
   388 W/m·K, and aluminum 6061-T6, k = 167 W/m·K (ASM Handbook, Vol. 2).

3. **Loads.** 33,333.33 W/m² (30 W) into the spreader's top face, and the block's underside held at
   40 °C. The side faces get no condition, so they are insulated.

4. **The joint.** A contact conductance ties the spreader's underside to the block's top:

   ```
   primary = geometry.stack.region.spreader_underside
   secondary = geometry.stack.region.block_top
   coefficient = 19048 W/m^2/K
   ```

5. **Study.** A steady thermal analysis, reporting the temperature field and the mean temperature of
   the heated face, the spreader's underside and the block's top.

## Results

The study reports the three face temperatures. The block top and the spreader underside sit on
either side of the joint, so their difference is the jump the contact conductance makes. Compare
`block_top_temperature`, `spreader_underside_temperature` and `heated_face_temperature` with
42.00, 43.75 and 44.00 °C from the table above. The temperature field shows a smooth gradient
through each part and a step at the joint.

## What to try

1. Halve the contact conductance to 9,524 W/m²·K, a drier joint. The jump doubles to 3.50 K and the
   heated face rises to 45.76 °C.
2. Raise it to a large value, such as 10⁷ W/m²·K, to model a near-perfect joint, and compare the
   heated face with 42.26 °C, the two layers' drops alone.
3. Put the 30 W on a smaller pad of the spreader's top face and see how the copper spreads the heat
   before it reaches the joint.

## Files

- `tim-stack.fea`: the study, with its hand check in the header.
- `geometry/tim-stack.step`: the spreader and block as STEP, with both bodies, the heated face, both joint faces and the cold face named.
- `runmat.toml`: the project file.

## Related

- [Thermal simulation in RunMat](https://runmat.com/simulation/thermal)
- [Steady heat transfer guide](https://runmat.com/docs/simulation/guides/steady-heat-transfer)
- [Heat spreader warm-up](../heat-spreader-warm-up) and [chip cold plate power step](../chip-cold-plate-power-step)
- [Download RunMat](https://runmat.com/download)
