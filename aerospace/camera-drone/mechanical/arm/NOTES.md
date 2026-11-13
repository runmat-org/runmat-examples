# Arm: sizing notes

The arm is one carbon prepreg part, `arm.part`, used four times. `arm_unit.assembly` puts the
motor station on its pad, and `arm_station.assembly` turns the unit about the hinge pin by its
`fold` input. Each station sets `length_offset` from the arm's nominal `length`, and the motor
station sits on the arm's published `tip` frame, so a change of `length` moves all four motors.
The decisions behind these numbers are in the root
[DESIGN-NOTES.md](../../DESIGN-NOTES.md).

| Quantity | Value | Criterion |
|---|---|---|
| Length, pin to motor axis | 88.2 mm nominal (`length`); stations offset −6.66 mm front (81.54 mm) and +2.407 mm rear (90.607 mm) | motors on the 300 mm diagonal |
| Section | elliptic, 16 × 12.4 mm at the root (a 0.3 mm shoulder under the knuckle's faces) to 11 × 7 mm at the tip | |
| Layup | [0/0/90/0]s, E = 90 GPa along the arm, 1,550 kg/m³ | |
| First flap mode, rear arm with its 40 g pod | 499 Hz (hand estimate) | above 476 Hz, 1.2 × the 397 Hz full-throttle blade pass |
| Hinge pin | Ø4 mm in a Ø4.1 mm +0.018/0 reamed bore | |
| Hinge lean | 20 deg front, 28 deg rear | front arms fold over the rear arms |
| Fold angle, stowed | 114 deg front and rear | no contact in `drone_folded.assembly` |

- **Studies:** `simulation/arm_modal.fea` (natural frequencies) and `simulation/arm_landing.fea`
  (hinge load on a landing), both on `simulation/arm_study.assembly`.
- **Drawing:** `drawings/arm.drawing` gives the pin bore to motor axis at 88.2 ±0.1 mm, the
  motor bolt circle at 12 ±0.05 mm and the layup callout.
