# Room modes of a listening room: an acoustic modal FEA study

This study finds the twelve lowest natural frequencies of the air in a 5 × 4 × 2.8 m room with
rigid walls, and the pressure shape of each mode. The rectangular-room formula puts them from the
uniform 0 Hz state and the 34.3 Hz length mode up to 92.0 Hz. Each solved frequency should sit at
or slightly above its formula value.

## The problem

Below a few hundred hertz, the sound in a small room is dominated by its standing waves, the room
modes. At each mode's frequency, bass builds up at the pressure maxima and vanishes at the nodes, so
a listener's seat or a loudspeaker's position can boost or cancel a note. Studio and home-theater
designers choose room proportions and positions so the low modes are spread evenly in frequency.

For a rigid rectangular room of sides Lx, Ly and Lz, the modes are

$$f_{lmn} = \frac{c}{2}\sqrt{\left(\frac{l}{L_x}\right)^2 + \left(\frac{m}{L_y}\right)^2 + \left(\frac{n}{L_z}\right)^2}$$

with c = 343 m/s for air at 20 °C. A rectangular box has this closed form, which makes it the check
case; the same study then applies to rooms with alcoves, sloped ceilings or furniture, where no
formula exists. Every surface is rigid, so the first mode is the uniform 0 Hz pressure state.

## How the study works

1. **Geometry.** `geometry/listening-room.step` holds the room air as body `Air`, 5 m along x, 4 m
   along y and 2.8 m high, with faces `Floor`, `Ceiling` and `Walls`.

2. **Mesh.** Quadratic tetrahedra at 400 mm, under the 0.57 m that six elements per wavelength at
   100 Hz would allow.

3. **Material.** Air at 20 °C with no damping:

   ```
   material air {
       mass_density = 1.204 kg/m^3
       acoustic {
           speed_of_sound = 343 m/s
           damping_ratio = 0.0
       }
   }
   ```

4. **Model.** Rigid walls on every surface:

   ```
   load floor { acoustic.rigid_wall { target = geometry.room.region.floor } }
   load ceiling { acoustic.rigid_wall { target = geometry.room.region.ceiling } }
   load walls { acoustic.rigid_wall { target = geometry.room.region.walls } }
   ```

5. **Study.** An acoustic modal analysis for twelve modes, returning each mode's pressure shape:

   ```
   analysis modes { acoustic modal { modes = 12 } }
   output mode_shapes = analysis.modes.field.node.acoustic_pressure
   ```

## Results

The rectangular-room formula:

| Mode | (l, m, n) | Frequency |
| --- | --- | --- |
| 1 | (0, 0, 0) | 0.0 Hz, uniform pressure |
| 2 | (1, 0, 0) | 34.3 Hz |
| 3 | (0, 1, 0) | 42.9 Hz |
| 4 | (1, 1, 0) | 54.9 Hz |
| 5 | (0, 0, 1) | 61.3 Hz |
| 6 | (2, 0, 0) | 68.6 Hz |
| 7 | (1, 0, 1) | 70.2 Hz |
| 8 | (0, 1, 1) | 74.8 Hz |
| 9 | (2, 1, 0) | 80.9 Hz |
| 10 | (1, 1, 1) | 82.3 Hz |
| 11 | (0, 2, 0) | 85.8 Hz |
| 12 | (2, 0, 1) | 92.0 Hz |

The study returns the modal frequencies in the run's mode table and the twelve pressure shapes.
Compare each frequency with the table; quadratic elements at this size put the error well under
1 % through 92 Hz. The next mode, (1, 2, 0), is at 92.4 Hz, only 0.4 Hz above mode 12, so check the
twelfth shape against the indices rather than the order. Each shape has l, m and n pressure nodes
along x, y and z.

## What to try

1. Lengthen the room to 6 m in a new STEP file. The length mode falls to 28.6 Hz, and (2, 0, 0) falls
   to 57.2 Hz, close to the 61.3 Hz height mode.
2. Ask for `modes = 20`. The formula puts modes 13 to 20 at 92.4, 101.5, 102.9, 105.4, 109.8, 110.8,
   111.5 and 119.7 Hz, more closely spaced than the low modes. Above 100 Hz the 400 mm mesh has fewer
   than six elements per wavelength, so expect the error to grow.
3. Coarsen `target_size` to 800 mm and compare the 92.0 Hz mode with the table to see the mesh error
   grow.

## Files

- `listening-room-modes.fea`: the acoustic modal study, with the rectangular-room table in its header.
- `geometry/listening-room.step`: the room air as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Acoustic simulation in RunMat](https://runmat.com/simulation/acoustics)
- [Acoustic physics reference](https://runmat.com/docs/simulation/physics/acoustic) and [modal analysis guide](https://runmat.com/docs/simulation/guides/modal-analysis)
- [Exhaust muffler transmission loss](../exhaust-muffler) and [natural frequencies of a tuning fork](../tuning-fork-modal)
- [Download RunMat](https://runmat.com/download)
