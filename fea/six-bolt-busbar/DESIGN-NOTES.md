# Design notes: six-bolt EV busbar

## 2026-11-05: Strap section for 400 A under 85 °C

- **Problem:** the strap must carry 400 A continuously in still air at 25 °C (10 W/m²/K) and stay under 85 °C, a 60 K rise, with its terminals taken as adiabatic.
- **Change:** `busbar.part` sets the strap to 30 × 2 mm (`width`, `thickness`): 60 mm², 6.7 A/mm² past the last cell bolt.
- **Evidence (hand estimate):** the current grows 66.7 A at each bolt, so the five 27 mm spans lose I² ρ L / A = 0.03, 0.14, 0.31, 0.55 and 0.86 W, and the last 32 mm at 400 A loses 1.47 W: 3.36 W at 20 °C resistivity. The strap's 12,400 mm² at 10 W/m²/K carries 0.124 W/K, a 27 K rise; with resistivity rising 0.39 %/K the rise settles at 31 K, about 56 °C.
- **Evidence (solved):** `six-bolt-busbar.fea`, solved 2026-11-06 on 75,168 linear tetrahedra (2 mm), the captured run: 56.8 °C at the coolest point and 63.4 °C at the hottest, between cell bolt 6 and the output bolt. A 1.5 mm mesh (115,894 tetrahedra) gave the same 56.8 °C and 63.4 °C. The strap's mean runs about 4 K over the hand estimate; the hand estimate takes the strap as one temperature, while the heat is made mostly near the output end, where all 400 A flows, and spreads back along the strap.
- **Result (solved):** 63.4 °C peak against the 85 °C limit, 21.6 K of margin. The study checks it with the assessment `stays_below_85_celsius` (`maximum = 85 degC`), which passed in the 2026-11-06 capture. A 40 × 3 mm strap would run about 10 K over ambient, twice the copper for no gain against this limit.

## 2026-11-05: Material

- **Change:** Cu-ETP (C11000, EN CW004A), the standard busbar copper: 58 MS/m (100 % IACS) at 20 °C, temperature coefficient 0.0039 /K, 390 W/m/K.
- **Source:** EN 13601 (copper bar for electrical purposes); IACS conductivity standard.

## 2026-11-05: Bolt holes

- **Change:** 8.5 mm clearance holes for the M8 cell terminals (between ISO 273 fine, 8.4 mm, and medium, 9 mm) and a 10.5 mm hole for the M10 output lug (ISO 273 fine). The 30 mm strap leaves 10.75 mm of copper on each side of a cell bolt.
