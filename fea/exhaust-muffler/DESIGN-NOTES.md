# Design notes: exhaust muffler

## 2026-11-05: Area ratio for the peak loss

- **Problem:** a single expansion chamber's peak loss is set by its area ratio m: TL max = 10 log10(1 + (m - 1/m)² / 4). The 500 Hz band needs at least 15 dB.
- **Change:** a 180 mm bore on 50 mm pipes (`bore`, `pipe`): m = (180 / 50)² = 12.96.
- **Evidence (hand estimate):** TL max = 10 log10(1 + (12.96 - 0.077)² / 4) = 16.2 dB per chamber. A 160 mm bore (m = 10.24) peaks at 14.3 dB, under the target on one chamber alone.
- **Result (hand estimate):** 16.2 dB per chamber at its tuned frequency.

## 2026-11-05: Two chambers tuned to 500 Hz

- **Problem:** one chamber reaches its peak only near k L = π/2 and falls to zero at k L = π; the 500 Hz band needs margin over 15 dB.
- **Change:** a baffle with a 50 mm opening splits the shell into two chambers of 170 mm each (`chamber`), a quarter wavelength at 500 Hz (343 / 500 / 4 = 171 mm).
- **Evidence (hand estimate):** at 500 Hz, k L = 2π × 500 / 343 × 0.170 = 1.557 rad, sin² k L = 1.00, so each chamber gives its 16.2 dB peak; two in series through the baffle's opening should give about 20 to 30 dB.
- **Evidence (solved):** `exhaust-muffler.fea`, solve pending.
- **Result (hand estimate):** about 20 to 30 dB against the 15 dB target at 500 Hz.

## 2026-11-05: Shell material and wall

- **Change:** 1.5 mm aluminized steel (EN 10346 DX51D+AS), the usual exhaust-shell sheet: it resists exhaust condensate and holds its shape at 400 °C. The study takes the walls as rigid; shell vibration is left out.
