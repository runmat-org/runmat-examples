# Design notes: Hall current sensor

## 2026-11-05: Core material

- **Change:** TDK N87, a MnZn power ferrite: initial permeability 2200, saturation flux density 490 mT at 25 °C and 390 mT at 100 °C, Curie temperature above 210 °C.
- **Source:** TDK, "SIFERRIT material N87" datasheet.
- **Why:** a high-saturation power grade keeps the core linear over the sensor's range, and its Curie point sits far above the 100 °C rating.

## 2026-11-05: Gap for 500 A

- **Problem:** at 500 A on one primary turn the gap sets the flux: B = μ0 I / (g + l / μr). The core must stay under 390 mT at 100 °C with margin, and the gap must be wide enough to hold a Hall element package.
- **Change:** a 3 mm gap (`gap`) in a 44 × 44 mm core with a 137 mm mean path.
- **Evidence (hand estimate):** B = 4π×10⁻⁷ × 500 / (3 mm + 137 mm / 2200) = 0.205 T across the gap. A 1.5 mm gap would give 0.41 T, over the 100 °C saturation.
- **Evidence (solved):** `hall-current-sensor.fea`, solve pending. The solve also finds the peak at the window's inner corners, where flux crowds.
- **Result (hand estimate):** 205 mT against 390 mT, 53 % of saturation at 100 °C.

## 2026-11-05: Window and primary

- **Change:** a 26 mm window round a 16 mm copper rod: 500 A at 2.5 A/mm², with 5 mm of clearance to the core all round for insulation.
