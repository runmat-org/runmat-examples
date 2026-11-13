# Design notes: paddle flow switch

## 2026-11-05: Line size for laminar flow

- **Problem:** the study is laminar; the switch's rated speed is 1 m/s of ISO VG 46 oil at 40 °C (46 cSt).
- **Change:** a 2-inch schedule 40 run, 52.5 mm bore.
- **Evidence (hand estimate):** Re = U D / ν = 1 × 0.0525 / 46 × 10⁻⁶ = 1140.
- **Result:** Re 1140, 57 % of the laminar limit.

## 2026-11-05: Paddle size for 1 mm of trip travel

- **Problem:** at 1 m/s the paddle's tip must move at least 1 mm, and its root must stay well inside the spring steel's strength.
- **Change:** a 0.5 × 24 mm paddle (`paddle`, `paddle_width`), 82 mm from the clamp (`paddle_length`), so 864 mm² sits in the run and blocks 40 % of the bore.
- **Evidence (hand estimate):** with a drag coefficient of 2, F = 2 × 0.5 × 861 × 1² × 864 × 10⁻⁶ = 0.74 N at the centroid, 64 mm below the clamp. As a cantilever (I = 24 × 0.5³ / 12 = 0.25 mm⁴, E I = 46,250 N mm²) the tip moves 1.40 + 0.59 = 1.99 mm. The root stress is F a c / I = 47 MPa. A 0.8 mm paddle would move only 0.49 mm.
- **Evidence (solved):** `paddle-flow-switch.fea`, solve pending.
- **Result (hand estimate):** 2.0 mm of tip travel against the 1 mm trip, a factor of 2; 47 MPa at the root.

## 2026-11-05: Paddle material

- **Change:** EN 1.4310 (X10CrNi18-8) stainless spring steel, spring-hard: it resists the oil and keeps its spring rate over many trips.
- **Source:** EN 10151: E about 185 GPa; tensile strength of the spring-hard condition 1,300 to 1,500 MPa.
- **Result:** 47 MPa at the root against about 1,300 MPa, a factor of 27.
