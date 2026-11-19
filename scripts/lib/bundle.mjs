/*
 * Shared by capture.mjs and validate.mjs: which files make up an example's source, its source hash, and the
 * content-addressed bundle a captured run is published as.
 *
 * A bundle is one example as a complete project: its source files plus the run the app wrote under
 * .artifacts/runs/ and .artifacts/objects/. It is described by project.json, the same inventory the FEA docs
 * examples use (schema_version 1, id, entry, run_manifest, files[{path, bytes, sha256}]). An example with several
 * studies ships one captured run per study: its project.json also lists run_manifests (every run, one per study),
 * and run_manifest names the first. The bundle's hash is
 * the sha256 of project.json's bytes, and every file is published next to it under files/<path>:
 *
 *   <base>/<id>/<hash>/project.json
 *   <base>/<id>/<hash>/files/<path>
 *
 * Git keeps only the pin, .artifacts/capture.json, which names the bundle hash, the RunMat version the run came
 * from and the source hash it was captured against.
 */
import { createHash } from "node:crypto";
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";

export const ROOT = join(dirname(fileURLToPath(import.meta.url)), "../..");
export const PIN_PATH = ".artifacts/capture.json";
export const RUNTIME_PATH = join(ROOT, "runtime.json");
export const RUN_MANIFEST = (id, studySlug) => `.artifacts/runs/${runIdFor(id)}${studySlug ? `__${studySlug}` : ""}.json`;

/** A study's name in its run file: the study path without `.fea`, every other character but [A-Za-z0-9_-] as `_`. */
export function studySlug(study) {
  return study.replace(/\.fea$/, "").replace(/[^A-Za-z0-9_-]/g, "_");
}

export const sha256 = (bytes) => createHash("sha256").update(bytes).digest("hex");

/** The fixed run id an example's captured run carries, so a recapture on the same runtime changes no bytes. */
export function runIdFor(id) {
  return `run_example_${id.replace(/[^A-Za-z0-9_-]/g, "_")}`;
}

const isDir = (path) => existsSync(path) && statSync(path).isDirectory();

/** Every example folder: <group>/<example>/ holding an example.json. */
export function listExamples(root = ROOT) {
  const found = [];
  for (const group of readdirSync(root).sort()) {
    if (group.startsWith(".") || ["scripts", "node_modules"].includes(group) || !isDir(join(root, group))) continue;
    for (const name of readdirSync(join(root, group)).sort()) {
      const dir = join(root, group, name);
      if (!isDir(dir) || !existsSync(join(dir, "example.json"))) continue;
      found.push({ dir, where: `${group}/${name}`, example: JSON.parse(readFileSync(join(dir, "example.json"), "utf8")) });
    }
  }
  return found;
}

/**
 * The example's own files, which every bundle carries: everything in the folder except example.json (catalog
 * metadata) and dot-folders, plus the layout .artifacts/workspace.json, so every surface that opens the bundle opens
 * it with the same tabs, panels and agent suggestions. The rest of .artifacts (thumbnails, the pin, run output) is
 * left out. Paths are project-relative, sorted. A change to any of these files makes the pin stale.
 */
export function sourceFiles(dir) {
  const files = [];
  const walk = (current) => {
    for (const name of readdirSync(current).sort()) {
      if (name.startsWith(".")) continue;
      const path = join(current, name);
      const rel = relative(dir, path).split("\\").join("/");
      if (statSync(path).isDirectory()) walk(path);
      // The catalog record and the README describe the example; they are not run inputs.
      else if (rel !== "example.json" && rel !== "README.md") files.push({ path: rel, bytes: readFileSync(path) });
    }
  };
  walk(dir);
  const layout = join(dir, ".artifacts/workspace.json");
  if (existsSync(layout)) files.push({ path: ".artifacts/workspace.json", bytes: readFileSync(layout) });
  return files.sort((a, b) => (a.path < b.path ? -1 : a.path > b.path ? 1 : 0));
}

/** Hash of the example's source: sha256 over the sorted [{path, sha256}] list as JSON. */
export function sourceSha256(dir) {
  return sha256(JSON.stringify(sourceFiles(dir).map((file) => ({ path: file.path, sha256: sha256(file.bytes) }))));
}

/**
 * project.json bytes for a bundle, in the docs examples' inventory format. Files are sorted by path. `runManifests`
 * lists the bundle's run manifests; with more than one, project.json carries them as run_manifests and names the
 * first as run_manifest, which Desktop builds without multi-run support open alone.
 */
export function projectManifest(id, entry, files, runManifests = [RUN_MANIFEST(id)]) {
  const sorted = [...files].sort((a, b) => (a.path < b.path ? -1 : a.path > b.path ? 1 : 0));
  const manifest = {
    schema_version: 1,
    id,
    entry,
    run_manifest: runManifests[0],
    ...(runManifests.length > 1 ? { run_manifests: runManifests } : {}),
    files: sorted.map((file) => ({ path: file.path, bytes: file.bytes.length, sha256: sha256(file.bytes) })),
  };
  return Buffer.from(`${JSON.stringify(manifest, null, 2)}\n`);
}

export function readJsonFile(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

/**
 * The bounds a bundle must fit, read from the app's loader (desktop/src/lib/examples/run-bundle.ts,
 * EXAMPLE_RUN_LIMITS, which matches the desktop importer in shared/runmat-example-package). A bundle over any of them
 * does not open already run: the app falls back to running the example. Returns null when runmat-private is not
 * checked out next to this repository (set RUNMAT_PRIVATE_DIR).
 */
export function bundleLimits(privateDir = process.env.RUNMAT_PRIVATE_DIR ?? join(ROOT, "../runmat-private")) {
  const path = join(privateDir, "desktop/src/lib/examples/run-bundle.ts");
  if (!existsSync(path)) return null;
  const block = /EXAMPLE_RUN_LIMITS\s*=\s*\{([^}]*)\}/.exec(readFileSync(path, "utf8"))?.[1];
  if (!block) throw new Error(`${path}: EXAMPLE_RUN_LIMITS not found`);
  const value = (key) => {
    const expression = new RegExp(`${key}:\\s*([0-9*\\s]+),`).exec(block)?.[1];
    if (!expression) throw new Error(`${path}: EXAMPLE_RUN_LIMITS.${key} not found`);
    return expression.split("*").reduce((product, factor) => product * Number(factor.trim()), 1);
  };
  return { manifestBytes: value("manifestBytes"), fileBytes: value("fileBytes"), totalBytes: value("totalBytes"), files: value("files") };
}

const mb = (bytes) => `${(bytes / 1024 / 1024).toFixed(1)} MB`;

/**
 * Where a bundle breaks the limits: one line per broken bound, naming the largest files. `files` holds
 * {path, bytes} with bytes a Buffer or a byte count; `manifestBytes` is project.json's size.
 */
export function bundleViolations(manifestBytes, files, limits) {
  const sized = files.map((file) => ({ path: file.path, bytes: typeof file.bytes === "number" ? file.bytes : file.bytes.length }));
  const total = sized.reduce((sum, file) => sum + file.bytes, 0);
  const largest = [...sized].sort((a, b) => b.bytes - a.bytes).slice(0, 3).map((file) => `${file.path} ${mb(file.bytes)}`).join(", ");
  const found = [];
  if (manifestBytes > limits.manifestBytes) found.push(`project.json is ${mb(manifestBytes)}, over the ${mb(limits.manifestBytes)} limit`);
  if (sized.length > limits.files) found.push(`${sized.length} files, over the ${limits.files}-file limit`);
  for (const file of sized) if (file.bytes > limits.fileBytes) found.push(`${file.path} is ${mb(file.bytes)}, over the ${mb(limits.fileBytes)} per-file limit`);
  if (total > limits.totalBytes) found.push(`${mb(total)} in all, over the ${mb(limits.totalBytes)} limit (largest: ${largest})`);
  return found;
}

/**
 * The FEA dataset's field bindings for a snapshot's run, each with the render topology the bundle's own analysis
 * store holds (`renderTopology`, as the runtime writes it on a binding). A bundle that carries the native store
 * (`storeIncluded`) keeps what the run's published step records. A partial or omitted store carries no render
 * tiles, so its bindings say "absent": Desktop then shows the run's saved figures and doesn't draw a field scene
 * from tiles the bundle left out (the reader reports "render LOD object is missing" otherwise).
 */
export function snapshotFieldBindings(snapshot, storeIncluded) {
  const step = snapshot.publication.steps[0];
  const renderTopology = storeIncluded ? step.render_topology : "absent";
  return snapshot.results.field_descriptors.map((descriptor) => ({
    stepId: step.procedure_step.step_id, runId: snapshot.run_id, descriptor,
    ...(renderTopology ? { renderTopology } : {}),
  }));
}
