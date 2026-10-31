# Phase 2: open every example in its post-run state

Goal: opening an example (website "Open in browser", Desktop Home, Start and the picker) lands on the finished run. The figures are drawn, FEA results are loaded, the right panels are open and the agent's suggestions are ready. Nothing re-runs until the user asks.

Paths below use `desktop/`, `website/`, `shared/` for `runmat-private/*` and `runtime/` for the runtime repo.

## 1. How the app persists a run today

All run output lives under the project's artifact root, `[desktop.artifacts] root = ".artifacts"` in `runmat.toml` (the default). Every example here already declares it.

```
.artifacts/
  runs/<runId>.json               run manifest (schemaVersion 2)
  runs/<runId>/logs.ndjson        log and trace channels
  objects/<aa>/<sha256>.<ext>     payloads, content-addressed
  objects/<aa>/<sha256>.json      sidecar: {schemaVersion, artifactId, src, bytes, mime, kind, handle?, ...}
```

- **Object kinds.** `figure` (.png), `figure-scene` (.scene.json), `workspace` (.workspace.json), `stdout` and `stderr`. FEA runs add `fea-dataset.json`, `fea-field-bindings.json`, `fea-diagnostics.json` and `fea-artifacts.json`.
  - Sources: `desktop/src/app/components/markdown/domain/notebook-artifacts.ts` and `desktop/src/run/fea-run-persistence.ts`.
- **Run manifest.** It holds `runId`, `docPath`, `status`, `runtimeFingerprint` and `runKind`. It also holds `cells["__script__"]`, which carries the workspace object and, per figure handle, `previewObject`/`previewSrc` and `sceneObject`/`sceneSrc`. FEA runs add `fea.datasetObject`.
  - Type: `desktop/src/run/run-history.ts`.
  - The plan comes from the shared WASM planner (`shared/runmat-runtime-artifacts`, via `planScriptRunArtifacts`). Tauri and the browser client both write through it.
- **Where runs are listed.** There is no index file.
  - Local disk projects and the browser/memory sandbox scan `runs/*.json`.
  - Cloud projects list runs from the server (`fs.listRunsIndex`) and keep the same files in project storage.
- **Reload on open already works.** `useProjectReplayIndex` (`desktop/src/replay/use-project-replay-index.ts`, mounted by the editor panel) loads `runs/` once the file provider is ready.
  - It rebuilds run sessions (figures, workspace, FEA) through the replay orchestrator.
  - The runtime panel follows the latest run.
  - FEA sessions are filled from the stored dataset (`desktop/src/replay/domain/fea-replay-artifacts.ts`). The FEA results pane renders and reassesses them without solving.
- **Precedent.** The FEA docs examples already ship this way.
  - The runtime's `scripts/docs/snapshot-project.mjs` runs a study and writes `.artifacts/` plus a `.snapshot/` folder. It publishes the bundle as `project/project.json`, a file inventory with sha256 per file, under `website/public/docs-assets/examples/<id>/<digest>/`.
  - Desktop opens it from `runmat://example?manifest=…&sha256=…` (`desktop/src-tauri/src/app/example_links.rs` → `shared/runmat-example-package`), downloads every file, and the replay index restores the run.
  - `desktop/src/replay/domain/docs-example-replay.spec.ts` is the witness test.
  - Phase 2 extends this path to every example and to the browser.

**What isn't persisted in the project:** layout. Open tabs (`runmat.editor.state.v1:<kind>:<id>`), the runtime panel mode and width, and the bottom tab live in localStorage. The sandbox persists none of it. So `.artifacts/workspace.json` is new. The app reads it once, when an example is first opened, and applies it:

- `editor` → pinned tabs, active tab and selected path;
- `panels.runtime.mode`/`tab` → the runtime panel mode and bottom tab;
- `panels.feaResults` and `resultView` → the selected session's view;
- `agent.suggestions` → the agent panel's suggested prompts, beside `buildAgentGuidanceState`'s built-in next steps.

Once the user has their own saved layout for that project, theirs wins.

## 2. Producing the results reproducibly

One command in this repo, `node scripts/capture.mjs [--only <id>]`, runs every example against a pinned released runtime and writes the results into `.artifacts/`. It is a repo tool, not part of any example.

1. **Pin the runtime.** `runtime.json` at the repo root records the release version and the sha256 of the binary. The capture refuses a different `runmat --version`.
2. **Scripts.** Run each script through the same planner the app uses, so the output is byte-compatible with what Desktop writes. The best option is a headless app host: the Tauri client with no window, or the browser client under a headless page driven by our own harness. It writes `runs/<runId>.json`, `objects/…`, the figure PNGs and scenes, and the workspace. The `runtimeFingerprint` is stamped with the runtime version.
   - The CLI's `--artifacts-dir` output (`runmat.artifacts.v1`, PNGs only) is a different format, so it can't be used as-is. See section 4.
3. **Studies.** `runmat fea snapshot <study>.fea --out …` followed by the runtime's `snapshot-project.mjs` step (dataset object, run manifest and scenes) already produces the desktop format. Capture calls the same code.
4. **Stable output.** Use a fixed `runId` per example (`run_example_<id>`) and fixed RNG seeds (the scripts already call `rng`). Strip timestamps to the capture time recorded in `runtime.json`, so a rerun on the same runtime changes no bytes. Thumbnails are re-derived from the captured figure PNGs, in both dark and light themes, which closes today's 12 missing light thumbnails.
5. **Check.** `scripts/validate.mjs` grows these checks:
   - every example has exactly one run manifest whose `runtimeFingerprint` matches `runtime.json`;
   - every object the manifest names exists and matches its sha256;
   - `resultView` names a figure handle or study output that exists in the run.
6. **Refresh.** Recapture after each runtime release. The diff shows which examples' results moved, which doubles as a regression check.

## 3. Bundling and hydrating

**Build step (both consumers).** `node scripts/bundle.mjs --out <dir>` writes:

- `catalog.json`: every `example.json` plus its thumbnail URLs and `workspace.json`, small enough to ship in the app and the site;
- `objects/<sha256>`: every file of every example (sources, data, geometry, thumbnails, `.artifacts/` objects), stored once by content hash;
- `examples/<id>.json`: a `project.json`-style inventory of `{path, sha256, bytes}`, with its own sha256 recorded in the catalog.

Identical files across examples (shared CSVs, cycle files, geometry) are stored once. A changed example changes only its inventory and the objects that moved.

**Desktop (Home, Start, picker).** The catalog replaces `desktop/src/lib/examples/generated/*` and `scripts/build-example-catalog.mjs` becomes a reader of this repo.

- On open, the app fetches the inventory, verifies each object's sha256, and writes the files into the new project: a local folder, a cloud project upload, or the memory sandbox.
- Then it applies `workspace.json`, and the replay index restores the run.
- The 4–6 featured examples per role are bundled in the installer, so the first run works offline. The rest load from the site's static hosting by hash, the same way the `runmat://example` link works today.

**Website ("Open in browser").** Today the launch writes source text only, to localStorage (`runmat:workspace:<id>`), so the sandbox has to run again. Phase 2 passes the inventory instead:

- Change the launch payload to `{ exampleId, inventoryUrl, inventorySha256 }`.
- The sandbox fetches the objects, including the binary PNGs, scenes and cbor, which the text-only seed path can't carry. It writes them into the memory filesystem and lets the same replay index restore the run.
- No size cap applies through localStorage.

**Size budget** (today: 9.6 MB for all 167 sources and thumbnails):

| Item | Budget |
| --- | --- |
| Catalog (all examples, no file contents) | ≤ 400 KB |
| Script example, run artifacts | ≤ 1.5 MB each, scenes gzip-encoded; most are 0.1–0.5 MB |
| FEA study, run artifacts | ≤ 12 MB each (the tuning fork bundle is 11 MB). Scene exports stay under the 16 MB scene limit by mesh choice. |
| Desktop installer (featured examples, all roles) | ≤ 40 MB |
| Whole bundle on the site | ≤ 400 MB |

Over-budget examples fail `bundle.mjs`.

## 4. What the runtime team is asked for

1. **Headless capture in the app's format.** We need either of these:
   - `runmat run <entry> --artifacts-dir <root> --artifacts-format desktop`, writing the same `runs/` + `objects/<aa>/<sha>` layout, sidecars and figure scenes the shared planner writes;
   - or a stable library entry point the capture tool can call with the planner.
   Today `--artifacts-dir` writes `runmat.artifacts.v1` with PNGs only, and no scenes or workspace.
2. **Deterministic runs.** We need a flag or environment variable that fixes run ids and timestamps and turns off nondeterministic ordering in figure and workspace export, so captures are byte-stable.
3. **Version in the manifest.** `runtimeFingerprint` should carry the release version and build hash (`runmat version --detailed`), so the app can mark captured results from an older runtime as stale.
4. **One FEA artifact layout.** The runtime's analysis store writes flat `.artifacts/objects/<hex>`, while the app writes `objects/<aa>/<sha>.<ext>` with sidecars. The producer should write one layout, so captures don't need the translation `snapshot-project.mjs` does today.

## 5. New 3D examples

Today 21 of 167 examples are 3D, most of them in plotting. Proposals for the roles that have none or a weak one (proposals only):

- **Aerospace (none):**
  - a launch-to-orbit or reentry trajectory in 3D with `plot3`, colored by Mach number, with the ground track below;
  - a wing's lift distribution over span and angle of attack as a `surf`.
- **Automotive (one, the battery module):**
  - a motor torque-speed-efficiency map as a `surf` with contour lines and the drive-cycle operating points overlaid;
  - a suspension kinematics envelope (wheel center path over travel and steer) with `plot3`.
- **Controls or DSP (none that fit):**
  - root locus over gain as a surface: closed-loop pole damping over the gain and one design parameter;
  - a filter's magnitude response over frequency and a swept parameter as a `waterfall`.
- **Electrical (none that fit):**
  - the electric field magnitude around two charged conductors as a `surf` with field lines;
  - an antenna array's radiation pattern in 3D from `sph2cart` and `surf`.
- **Thermal or fluids (three, all patch renders):**
  - steady temperature over a plate with a heat source, as a `surf` from a finite-difference solve;
  - pipe-flow velocity profiles along a developing duct, with `waterfall`.
- **Mechanical (structural) (three):**
  - a cantilever plate's first modes as `surf` subplots;
  - a stress-strain-temperature surface for a material model.
- **Something else (`other`, no examples tagged):** tag the general showcase examples (`plotting-damped-radial-wave`, `differential-equations-lorenz-attractor`, `quant-heston-surface`) with `other` rather than adding new ones.

**Visual rule.** A study is `study`. A script is `3d` if it calls `surf`, `surfc`, `surfl`, `mesh`, `meshc`, `meshz`, `plot3`, `scatter3`, `contour3`, `isosurface`, `waterfall`, `bar3`, `bar3h`, `quiver3`, `trisurf`, `trimesh`, `fill3` or `zlabel`, or sets a 3D camera with `view(3)`, `view(az, el)` or `view([az el])`. Otherwise it is `image` if it calls `imagesc`, `pcolor`, `image` or `imshow`, and `2d` if it calls none of them. Comments are ignored. The `zlabel`/`view` cue catches the 3D `patch` renders: turbine, rotor, battery module and heat sink.
