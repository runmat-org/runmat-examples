# Heat spreader on a cooled block

Steady temperatures through a copper heat spreader (30 x 30 x 3 mm) mounted on an aluminum block of the same footprint, 10 mm thick. A component puts 30 W into the spreader; the block underside is held at 40 °C. The joint is written as a contact conductance of 19048 W/m²/K, a silicone-oil-filled metal contact. The study returns the temperature jump at the joint and the temperatures on each face.

## Files

| File | What it is |
| --- | --- |
| `tim-stack.fea` | The study, with its hand check in the header. |
| `geometry/tim-stack.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: bodies `Copper spreader` and `Aluminum block`; faces `Heat input`, `Spreader underside`, `Block top` and `Cold face`.

## The part

- Copper C11000 spreader, 30 × 30 × 3 mm.
- Aluminum 6061-T6 block, 30 × 30 × 10 mm, under the spreader. The two bodies keep their own faces at the joint.

## Setup

- 30 W into the spreader's top face (33.3 kW/m²).
- The block's underside is held at 40 °C by the cold plate. The side faces are insulated.
- Joint: contact resistance R″ = 0.525 × 10⁻⁴ m²·K/W for a silicone-oil-filled metal contact (Incropera et al., *Fundamentals of Heat and Mass Transfer*, Table 3.1), written as a conductance of 19048 W/m²/K.
- Copper C11000 k = 388 W/m/K; aluminum 6061-T6 k = 167 W/m/K (ASM Handbook, Vol. 2).

## Hand check

The footprints match and the sides are insulated, so heat flows straight down at q″ = 30 / 900 mm² = 33.3 kW/m² through three resistances in series:

| Layer | Drop | Temperature above it |
| --- | --- | --- |
| Block, 10 mm / 167 W/m/K | 2.00 K | block top **42.00 °C** |
| Joint, 0.525 × 10⁻⁴ m²·K/W | 1.75 K | spreader underside **43.75 °C** |
| Copper, 3 mm / 388 W/m/K | 0.26 K | heated face **44.00 °C** |

## Expected result

`block_top_temperature`, `spreader_underside_temperature` and `heated_face_temperature` should read 42.00, 43.75 and 44.00 °C within 0.05 K. The 1.75 K jump between the first two is the joint.

Outputs: temperature, heated_face_temperature, spreader_underside_temperature, block_top_temperature.
