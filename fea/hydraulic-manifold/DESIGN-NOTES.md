# Design notes: hydraulic manifold

## 2026-11-05: Port and gallery bores for laminar flow at 20 L/min

- **Problem:** the study is laminar, so the flow must stay under Re 2000 at the rated 20 L/min (3.333e-4 m^3/s) of ISO VG 46 oil at 40 °C (861 kg/m^3, 46 cSt).
- **Change:** `manifold.part` sets the work ports A and B to 10 mm (`bore`) and the galleries from P and T to 12 mm (`gallery`).
- **Evidence (hand estimate):** U = Q / A gives 4.24 m/s in a 10 mm port and 2.95 m/s in a 12 mm gallery; Re = U d / nu = 922 and 768.
- **Result:** Re 922 at the highest-speed section, 46 % of the laminar limit. The ports reach Re 2000 at about 43 L/min.

## 2026-11-05: Gallery larger than the port it meets

- **Problem:** two equal 10 mm drillings that cross meet along a curve with sharp cusps where the bores are tangent. A machinist avoids that junction because it leaves a burr ridge, and it gives a poor flow corner.
- **Change:** the galleries are 12 mm and the ports 10 mm, so each port enters its gallery inside the gallery's wall. The galleries are flat-bottomed, 60 mm deep, and each port stops on its gallery's axis.
- **Result:** clean junctions; the larger gallery also lowers the gallery's share of the loss (next entry).

## 2026-11-05: Loss from P to A against the 1 bar budget

- **Problem:** the loss from P to A must stay under 1 bar at 20 L/min.
- **Evidence (hand estimate):** developed laminar friction, 128 mu Q L / (pi d^4), over 50 mm of 12 mm gallery (1.3 kPa) and 30 mm of 10 mm port (1.6 kPa), plus the entry, the right-angle turn and the exit at about K = 2.5 on the port's 0.5 rho U^2 = 7.74 kPa (19 kPa): about 22 kPa, 0.22 bar.
- **Evidence (solved):** `hydraulic-manifold.fea`, solve pending.
- **Result (hand estimate):** 0.22 bar against the 1 bar budget, a margin of 4.5 times.

## 2026-11-05: Wall between the bolt holes and the galleries

- **Problem:** the M8 bolt holes at the corners must clear the galleries with a wall that holds the system pressure.
- **Change:** the block is 80 mm wide with the galleries on y = 25 and 55 mm and the bolt holes on 10 mm insets, so each bolt hole clears its nearest gallery by 4.5 mm of aluminum.
- **Evidence (hand estimate):** a 4.5 mm ligament between a 9 mm hole and a 12 mm bore at 210 bar carries about p d / (2 t) = 21 MPa x 12 / 9 = 28 MPa, against 6061-T6's 240 MPa minimum yield (ASTM B221).
- **Result:** a margin of about 8 on yield at 210 bar.

## 2026-11-05: Block material

- **Change:** 6061-T6 aluminum, the common choice for manifolds up to about 210 bar: it machines and drills cleanly and anodizes well.
- **Source:** 6061-T6 yield 276 MPa typical, 240 MPa minimum (ASM Handbook, Vol. 2; ASTM B221).
