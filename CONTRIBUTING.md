# Contributing to RunMat examples

This guide covers how the repository is laid out, the files each example carries, and how to add one. The website and the desktop app both bundle their examples from this repository at build time.

## Layout

```
<topic-or-industry>/<example>/
  runmat.toml              project manifest (package, sources, the entry point, artifact root)
  <entry>.m | <entry>.fea  the script or study the example opens
  ...                      every data and geometry file it reads (CSV, text, STEP)
  example.json             catalog record: title, tags, entry, origin
  .artifacts/
    thumbnail.webp         the figure RunMat drew from this source (dark theme)
    thumbnail.light.webp   the same figure in the light theme, when one exists
    workspace.json         how the app lays out the project when it opens
    capture.json           the pin of the example's captured run (bundle hash, source hash, RunMat version)
```

Topics are the website's `/math` pages (`plotting`, `statistics`, ...), its `/industries` pages (`aerospace`, `quant`, ...) and `fea` for FEA studies.

An example folder holds only files a user would keep. Generators, render scripts and website-only output files stay out. `.artifacts/` is the one dot-folder; it is also the project artifact root the app writes runs to (`[desktop.artifacts] root = ".artifacts"` in `runmat.toml`).

## example.json

| Field | Meaning |
| --- | --- |
| `id` | Stable id, unique across the repository. Analytics and the app use it. |
| `title` | The example's name. |
| `pickerTitle`, `pickerLine` | One-line title and subtitle for the example picker and onboarding tiles. |
| `line` | One short line under the name. |
| `description` | What the example does, a few sentences. |
| `topic`, `topicLabel`, `group` | Where it sits in the catalog. `group` is the gallery group, or `Page hero` for a page's lead example. |
| `kind` | `script`, `study`, or `design` for a CAD project that opens a `.part` or `.assembly`. |
| `visual` | `3d`, `study`, `image` or `2d`, detected from the source (see below). |
| `entry` | Project-relative path the app opens and runs. Matches `[entrypoints.main]` in `runmat.toml`. |
| `roles` | Role ids from onboarding ("What best describes you?"): `structural`, `aerospace`, `automotive`, `controls_signals`, `thermal_fluids`, `electrical`, `data_quant`, `research`, `teaching`, `student`, `other`. |
| `goals` | Onboarding goal ids: `build_simulations`, `analyze_visualize_data`, `migrate_matlab_code`, `learn_matlab_alternative`, `gpu_acceleration`, `share_projects`, `academic_coursework`, `other`. |
| `theme` | Examples that show the same idea share a theme; picks never show two from one theme. |
| `thumbnailAlt` | Alt text for the thumbnail. |
| `origin` | Where the example appears: `page` is its runmat.com page and `key` a stable reference the website uses to find its captured run. |

`visual` rule: a study is `study`; a script that calls `surf`, `surfc`, `surfl`, `mesh`, `meshc`, `meshz`, `plot3`, `scatter3`, `contour3`, `isosurface`, `waterfall`, `bar3`, `bar3h`, `quiver3`, `trisurf`, `trimesh`, `fill3` or `zlabel`, or sets a 3D camera with `view(3)`, `view(az, el)` or `view([az el])`, is `3d`; one that calls `imagesc`, `pcolor`, `image` or `imshow` is `image`; anything else is `2d`. Comments are ignored.

## .artifacts/workspace.json

The layout the app restores when the example opens:

```json
{
  "schemaVersion": 1,
  "editor": { "openFiles": ["/plot.m"], "activeFile": "/plot.m" },
  "panels": { "files": true, "agent": true, "runtime": { "mode": "auto", "tab": "results" }, "feaResults": false },
  "resultView": { "kind": "figure", "figure": 1 },
  "agent": { "suggestions": ["Explain how the envelope bounds the signal", "..."] }
}
```

- `editor`: the files open in tabs and the active one. Paths are project-absolute (`/` is the project root). The app keeps the same state per project as pinned tabs, active tab and selected path.
- `panels`: which panels start open. `runtime.mode` uses the app's runtime panel modes (`auto`, `pinned`, `hidden`) and `runtime.tab` its tabs (`results`, `variables`, `trace`, `log`). FEA studies pin the runtime panel and open FEA results.
- `resultView`: the result shown first: a figure handle for scripts, or a study output name for FEA studies.
- `agent.suggestions`: two or three short prompts shown in the agent panel.

## Captured runs

Every example opens in its finished run: figures drawn, results loaded, nothing running until Run. The run itself stays out of git. It is published as an immutable bundle, and the example keeps a pin, `.artifacts/capture.json`, with the bundle's hash, the source hash and the RunMat version.

RunMat maintainers capture each example's run and publish its bundle. For a new or changed example, open a pull request with the source; the run and the thumbnails are captured before it merges.

A changed source or `workspace.json` makes the pin stale, and the validator fails until the example is recaptured.

## Add an example

1. Make `<topic>/<example>/` with the source, its data files and a `runmat.toml`:

   ```toml
   [package]
   name = "<id>"
   version = "0.1.0"

   [sources]
   roots = ["."]

   [entrypoints.main]
   path = "<entry file>"

   [desktop.artifacts]
   root = ".artifacts"
   ```

2. Write `example.json` and `.artifacts/workspace.json` (copy a neighbor's and edit).
3. Open a pull request. Maintainers capture the run, which also writes `.artifacts/thumbnail.webp` and `.artifacts/thumbnail.light.webp` from the captured figure.
4. Check it:

   ```sh
   node scripts/validate.mjs
   ```

   The validator checks that every folder has `example.json` and `runmat.toml`, the entry file exists, ids are unique, the dark thumbnail and `workspace.json` are present, workspace files exist, there are two or three agent suggestions, and `.artifacts/` is the only dot-folder. A missing light thumbnail is a warning.

## The root README

The catalog in `README.md` and its header pictures are generated from each example's `example.json` and thumbnails:

```sh
node scripts/build-readme.mjs            # the catalog
node scripts/build-readme.mjs --mosaic   # the catalog and the header pictures (needs ImageMagick)
```

`node scripts/validate.mjs` fails when the catalog is out of date.
