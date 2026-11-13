# Disc cam from its motion law

A dwell-rise-dwell-return disc cam modeled in `disc_cam.part`. Its base circle and its profile come from MATLAB functions in the same folder, so the cam's shape follows its motion law.

## Open it

Open the folder in RunMat Desktop, or open the example in the browser sandbox. `disc_cam.part` opens first. The Outline lists the part's inputs, then its values under Values. A value marked ƒ was computed by MATLAB code. Select one to see the function and its file in Properties.

## The files

| File | What it does |
|---|---|
| `disc_cam.part` | The cam: its inputs, the values it takes from the functions, a closed spline through the pitch points and the extrusion. |
| `camBaseRadius.m` | The smallest base-circle radius that keeps a cycloidal rise under the pressure-angle limit. |
| `camRadius.m` | The pitch radius at a cam angle: cycloidal rise, dwell at full lift, cycloidal return, then dwell on the base circle. |
| `cycloidal.m` | The normalized cycloidal motion law that `camRadius.m` calls. |

The part calls the functions by name, with no `use` line, because they sit in its folder. Arguments cross into MATLAB in SI units (m, rad), and each value states the unit of the result with `as m`.

## Things to try

- Change `lift` from 8 mm to 10 mm. The base circle grows to keep the pressure angle at 30 deg, and the profile regenerates.
- Lower `max_pressure` to 25 deg. The cam gets larger for the same lift.
- Edit `cycloidal.m` to another motion law, such as a modified sine, and watch the lobe change.

The design reasoning is in [DESIGN-NOTES.md](DESIGN-NOTES.md).
