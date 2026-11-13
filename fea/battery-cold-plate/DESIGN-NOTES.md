# Design notes: battery module cold plate

## 2026-11-05: Channel size for laminar flow

- **Problem:** the study is laminar, so the coolant must stay under Re 2000 at the design flow of 2 L/min (3.333 × 10⁻⁵ m³/s) of 50/50 water-glycol at 25 °C (1070 kg/m³, 3.5 mPa s).
- **Change:** one serpentine channel, 14 × 4 mm (`channel_width`, `channel_depth`): A = 56 mm², hydraulic diameter 4A/P = 6.22 mm.
- **Evidence (hand estimate):** U = Q / A = 0.595 m/s; Re = ρ U Dh / μ = 1130.
- **Result:** Re 1130, 57 % of the laminar limit.

## 2026-11-05: Four passes under the cell center lines

- **Problem:** each cell must see the same cooling, and the coolant's rise along its path must stay small against the 20 K between the 25 °C inlet and the 45 °C limit.
- **Change:** four 500 mm passes at x = 35.75, 107.25, 178.75 and 250.25 mm, one under each pair of cells, joined by three 14 mm turns; in and out on the rear edge.
- **Evidence (hand estimate):** coolant rise 160 W / (ρ Q cp) = 160 / (1070 × 3.333 × 10⁻⁵ × 3300) = 1.36 K. Pressure drop over the 2,215 mm path at a Darcy f Re of 66: 66 / 1130 × 2.215 / 6.22 × 10⁻³ × 0.5 × 1070 × 0.595² = 3.9 kPa, plus about 1.1 kPa in the six bends: about 5 kPa.
- **Evidence (solved):** `battery-cold-plate.fea`, solve pending.
- **Result (hand estimate):** 1.4 K coolant rise and about 5 kPa, both small against a pack pump's 30 to 50 kPa.

## 2026-11-05: Peak cell temperature

- **Problem:** the hottest cell top must stay under 45 °C.
- **Evidence (hand estimate):** per cell (20 W through its 0.017 m² bottom): gap filler 0.003 m / 3 W/m/K = 1.2 K; land and plate 0.05 K; the channel's laminar film, Nu = 4.4 (h = 269 W/m²/K) over 0.0165 m² of channel under each cell, 4.5 K; the cell's own height, Q H² / (2k) = 2.8 K. With the 1.4 K coolant rise: 25 + 1.4 + 1.2 + 4.5 + 2.8 = 35 °C.
- **Evidence (solved):** `battery-cold-plate.fea`, solve pending.
- **Result (hand estimate):** about 35 °C against the 45 °C limit, 10 K of margin.

## 2026-11-05: Gap filler and lands

- **Change:** a 3 mm pad of 3 W/m/K gap filler under each cell, on a 1 mm aluminum land the same size as the pad. The pads take up the cells' height tolerance; the lands keep the filler's footprint to the cell and leave a 2 mm relief between cells.
- **Plate:** 8 mm of brazed 3003 aluminum (160 W/m/K): a 2 mm floor and a 2 mm lid round the 4 mm channel.
