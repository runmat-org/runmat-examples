# RC low-pass filter sized by a MATLAB function

`lowpass.circuit` is a first-order RC low-pass filter. Its resistor value comes from
`rcResistor.m` in the same folder: the component line calls the function with the corner
frequency and the capacitor,

```circuit
component R1 = { part = "R0402-10K", value = rcResistor(fc = 160 Hz, c = 100 nF) as ohm }
```

and the function returns R = 1 / (2π · fc · C), about 9.95 kΩ. The schematic, the BOM and the
simulation read that value.

## Files

- `lowpass.circuit`: the schematic (input port IN, R1 in series, C1 to ground, output port OUT) and the `corner` simulation.
- `rcResistor.m`: the sizing function. Arguments arrive in SI units (Hz, F) and the result is
  read as ohms (`as ohm`).
- `runmat.toml`: the project file.

## What to try

1. Open `lowpass.circuit` and select R1. Properties shows the computed value, the function and
   the file it came from.
2. Run the `corner` simulation. The `f3db` measure reads the -3 dB bandwidth at OUT, about
   160 Hz, and checks it against 150–170 Hz.
3. Change `fc = 160 Hz` to `fc = 1 kHz`. R1 recomputes to about 1.59 kΩ. Re-run `corner`: the
   corner moves to 1 kHz and the measure fails its 150–170 Hz spec until you widen it.
