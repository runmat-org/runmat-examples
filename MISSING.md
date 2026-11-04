# Examples the picker still needs

The example picker (desktop `src/lib/examples/catalog.ts`) gives engineering roles both a 3D figure and a
simulation study. Where a role has no example of its own, it borrows a general one, so the same two repeat
across roles:
- the tuning fork modal study (`fea/tuning-fork-modal`), the only simulation study today;
- the `plotting-mesh` surface.

Each role below needs its own 3D example and its own study. Every new example has to:
- be tagged with the role in its website source, so `desktop/scripts/build-example-catalog.mjs` picks up
  `fields` and `visual`;
- open in its post-run state (see the run-on-open flow);
- stay short.

| Role | Needs a 3D figure | Needs a simulation study (`.fea` or FEA from `.m`) |
|---|---|---|
| Structural | has `linear-algebra-plate-mode` | bracket under load (static stress, safety factor) |
| Aerospace | wing or panel mode shape surface | thin panel buckling or modal |
| Automotive | suspension or road-profile surface | control arm stress |
| Thermal and fluids | temperature field over a plate (`surf`) | heat sink or board steady-state thermal |
| Controls and signals | Bode or step-response surface over a parameter sweep | thermal or structural plant model for a controller |
| Electrical | potential or field magnitude surface | busbar or PCB trace Joule heating (electrothermal) |

Not urgent (these roles get a 3D figure or a study, not both):
- **Data and quant:** has a 3D figure (call price surface). A study is optional.
- **Research, teaching, student:** each has a 3D figure or a study. A second visual is optional.

Also regenerate the call price surface thumbnail once the runtime camera fix lands. The current one shows only
ticks and the colorbar; see `/tmp/sister-comms/2026-11-02-replay-figure-3d-missing.md`.
