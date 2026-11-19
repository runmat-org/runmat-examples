# Laminar heat transfer coefficient in a heated tube: a conjugate heat transfer FEA check against Nu = 4.36

This study solves laminar water flow through a copper tube, 8 mm bore and 240 mm long, heated with
10 W on its outside, together with conduction in the copper. Water enters at 25 °C and 4.288 mm/s
(Re = 40). The study returns the wall and centerline temperatures 180 mm along, where the flow is
thermally developed, the outlet temperature and the pressure drop. Developed laminar flow with
uniform wall flux has Nu = 48/11 = 4.364, which puts the wall at 38.3 °C and the centerline at
30.2 °C at 180 mm.

## The problem

The heat transfer coefficient in laminar tube flow has an exact value once the velocity and
temperature profiles are developed: Nu = hd/k = 4.364 for a uniform wall flux. Heat exchanger,
cold plate and medical-device designers use it to size channels, and a conjugate solver should
reproduce it from first principles, with no film coefficient given.

The water carries ṁc = 997 × 0.004288 × 5.027 × 10⁻⁵ × 4179 = 0.898 W/K, so 10 W warms it 11.1 K.
At 180 mm, three quarters of the way along, the bulk temperature is 25 + 11.1 × 0.75 = 33.35 °C.
The flux at the bore is q = 10 / (π × 0.008 × 0.240) = 1,658 W/m². The thermal entry length is
about 0.05 Re Pr d = 93 mm, so the section at 180 mm is developed. Then

$$T_w - T_b = \frac{q\,d}{Nu\,k} = \frac{1658 \times 0.008}{4.364 \times 0.613} = 4.96\ \text{K}$$

and the wall reads 38.3 °C. For the developed parabolic profile the wall runs (3/4) qR/k = 8.11 K
above the centerline, which reads 30.2 °C. The copper's conduction keeps the wall temperature
uniform around the bore, the condition Nu = 4.364 assumes. The pressure drop is Hagen–Poiseuille:
32μUL/d² = 0.44 Pa.

## How the study works

1. **Geometry and mesh.** `geometry/heated-tube.step` holds the tube (`Tube`, 8 mm bore, 12 mm
   outside) and the water in its bore (`Water`) as bodies sharing the bore face. Linear tetrahedra
   at 1.5 mm, refined to 0.6 mm on the channel wall, about thirteen cells across the bore.

2. **Materials.** Copper at 300 K (8,933 kg/m³, 401 W/m·K) and water at 300 K (997 kg/m³,
   855 × 10⁻⁶ Pa·s, 0.613 W/m·K, 4,179 J/kg·K, Pr = 5.83), both from Incropera.

3. **Heat and flow.** 1,105.2 W/m² on the outer surface (10 W over 9.048 × 10⁻³ m²), the tube ends
   insulated; 4.288 mm/s at 25 °C into the inlet, 0 Pa at the outlet, no slip on the wall, and a
   perfect thermal contact across the bore:

   ```
   load heater { heat_flux on geometry.tube.region.heated_surface = 1105.2 W/m^2 }
   interface wetted_bore {
       conjugate_heat_transfer.perfect {
           primary = geometry.tube.region.tube_bore
           secondary = geometry.tube.region.channel_wall
       }
   }
   ```

4. **Study and outputs.** A steady conjugate heat transfer analysis, with point temperatures at the
   wall and on the axis 180 mm along, and the pressure drop:

   ```
   output wall_temperature_180 = interpolate(output.temperature, at = [180 mm, 4 mm, 0 mm])
   output centerline_temperature_180 = interpolate(output.temperature, at = [180 mm, 0 mm, 0 mm])
   output pressure_drop = pressure_drop(analysis.operating_point, from = geometry.tube.region.inlet, to = geometry.tube.region.outlet)
   ```

## Results

| Output | Developed-flow solution |
| --- | --- |
| `wall_temperature_180` | 38.3 °C |
| `centerline_temperature_180` | 30.2 °C |
| Bulk temperature at 180 mm | 33.35 °C |
| Outlet, mixed mean | 36.1 °C |
| `pressure_drop` | 0.44 Pa |

The study also returns the temperature, velocity and pressure fields. Its Nusselt number is
qd / (k(T_wall − 33.35 °C)), to compare with 4.364. `outlet_temperature` is an area mean over the
outlet face, which weights the slow, warm water near the wall less than the mixed mean does, so it
reads under 36.1 °C. The viscosity is held at its 25 °C value; with temperature-dependent viscosity
the warm water would lose a little less pressure.

## What to try

1. Double the heater to 2,210.4 W/m² (20 W). Every temperature rise doubles, so the wall at 180 mm
   reads 51.6 °C by the same check.
2. Move the two sample points to x = 60 mm, inside the 93 mm entry length, and compare the wall-to-
   bulk difference there with the developed 4.96 K. The bulk temperature at 60 mm is 27.8 °C.
3. Halve the inlet velocity to 2.144 mm/s (Re = 20). The water then warms 22.3 K, and the entry
   length shortens to about 47 mm.

## Files

- `heated-tube-nusselt.fea`: the conjugate heat transfer study, with its hand check in the header.
- `geometry/heated-tube.step`: the tube and the water as STEP, with the body and face names the study selects.
- `runmat.toml`: the project file.

## Related

- [Conjugate heat transfer in RunMat](https://runmat.com/simulation/conjugate-heat-transfer)
- [Conjugate heat transfer physics reference](https://runmat.com/docs/simulation/physics/conjugate-heat-transfer) and [interface conditions](https://runmat.com/docs/simulation/constraints/interfaces)
- [Insulated oil line heat loss](../insulated-oil-line) and [hydraulic line pressure drop](../hydraulic-line-poiseuille)
- [Download RunMat](https://runmat.com/download)
