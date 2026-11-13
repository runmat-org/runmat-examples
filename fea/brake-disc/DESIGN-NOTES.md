# Design notes: ventilated brake disc

## 2026-11-05: The design duty

- **Problem:** the disc must hold a steady drag stop, its hardest continuous duty, without overheating or overstressing.
- **Change:** a 1,600 kg car holding 50 km/h (13.9 m/s) down an 8 % grade, with 70 % of the braking on the front axle.
- **Evidence (hand estimate):** the grade gives m g sin(a) v = 1600 × 9.81 × 0.0798 × 13.9 = 17.4 kW; rolling resistance takes 2.6 kW and aerodynamic drag 1.4 kW, so the brakes absorb 13.4 kW and each front disc 4.7 kW: 53.3 kW/m² on each 0.0441 m² friction annulus.

## 2026-11-05: Vented disc and vane count

- **Problem:** a solid 300 mm disc cools only from its faces and edge; at 4.7 kW it would run far hotter.
- **Change:** a 28 mm disc of two 9 mm plates and 36 radial vanes (5 × 10 mm), which pumps air from the eye to the rim and adds about 0.10 m² of channel wall.
- **Evidence (hand estimate):** 0.088 m² of faces at 60, 0.10 m² of channel at 80 and 0.03 m² of hat at 30 W/m²/K is about 14.2 W/K, so the ring runs about 330 K over the 40 °C air, near 370 °C, with radiation left out.
- **Evidence (solved):** `brake-disc.fea`, solve pending.
- **Result (hand estimate):** about 370 °C at the ring, under the 450 to 500 °C where grey-iron discs start to fade and craze.

## 2026-11-05: Disc iron

- **Change:** EN-GJL-250 gray cast iron, the common disc iron: its flake graphite conducts heat (48.5 W/m/K at 100 °C) and damps vibration.
- **Source:** EN 1561: minimum tensile strength 250 MPa (Table 1), E 103 to 118 GPa, expansion 12.5 × 10⁻⁶ /K (20 to 400 °C), conductivity 48.5 W/m/K (100 °C).
- **Allowable:** 250 MPa, the minimum tensile strength.

## 2026-11-05: Hat depth against coning stress

- **Problem:** a hot ring held to a cooler hat is restrained: fully restrained, σ = E α ΔT / (1 - ν) = 110 GPa × 12.5 × 10⁻⁶ × 100 / 0.74 = 186 MPa per 100 K of ring-to-hat difference.
- **Change:** a hat 32 mm deep (outboard friction face to hub face) with a 6 mm wall, which bends to let the ring grow instead of holding it rigidly.
- **Evidence (solved):** `brake-disc.fea`, solve pending; it gives the peak stress against the 250 MPa allowable.
