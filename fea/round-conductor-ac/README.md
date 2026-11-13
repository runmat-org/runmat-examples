# AC resistance of a round conductor

AC resistance of a round copper conductor, 20 mm in diameter, at 50 Hz and 1 kHz. A 30 mm length carries 1000 A and returns through a coaxial, perfectly conducting shell; the space between is air. The study solves the full field with skin effect at each frequency and reports the power delivered, which gives Rac/Rdc against the Bessel-function solution for a round wire.

## Files

| File | What it is |
| --- | --- |
| `round-conductor-ac.fea` | The study, with its hand check in the header. |
| `geometry/round-conductor.step` | The part as STEP, written with Open CASCADE, with the body and face names the study selects. |

Names in the STEP file: bodies `Conductor` and `Air`; faces `Terminal in`, `Terminal out`, `Return shell` and `End plates`.

## The part

- Copper rod, 20 mm diameter, 30 mm long.
- Coaxial air space out to 15 mm radius. Its outer cylinder (`Return shell`) and end annuli (`End plates`) are the return path.

## Setup

- 1000 A (peak) into `Terminal in`; `Terminal out` at 0 V.
- `Return shell` and `End plates` grounded (tangential E = 0), a perfectly conducting coaxial return.
- Frequencies 50 Hz and 1 kHz, each solved on its own.
- Copper σ = 58 MS/m (IEC 60028), μr = 1. Air σ = 0.

## Hand check

For a round wire of radius a, Z/Rdc = (ka/2) J₀(ka) / J₁(ka) with k = (1 − j)/δ and δ = √(2 / (ωμσ)). The perfectly conducting return adds only reactance.

| | 50 Hz | 1 kHz |
| --- | --- | --- |
| Skin depth δ | 9.35 mm | 2.09 mm |
| a/δ | 1.07 | 4.79 |
| Rac / Rdc | **1.027** | **2.662** |
| Loss at 1000 A peak (Rdc = 1.646 μΩ, DC loss 0.823 W) | 0.845 W | 2.191 W |
| Peak loss density at the surface, ½ρ\|J(a)\|² | 0.099 MW/m³ | 1.109 MW/m³ |

## Expected result

The run's terminal report gives the delivered power, ½Re(U Ī), at each frequency. Dividing by the DC loss of 0.823 W should give Rac/Rdc = 1.027 at 50 Hz and 2.662 at 1 kHz, within 2 %. `peak_loss_density` is an element average and reads a few percent under the surface values above.

Outputs: loss_density, peak_loss_density (per frequency); terminal voltage, current and complex power in the run report.
