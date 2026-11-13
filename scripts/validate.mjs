#!/usr/bin/env node
/*
 * Checks every example folder: node scripts/validate.mjs
 *
 * An example is any folder <group>/<example>/ that holds an example.json. Each must have a
 * runmat.toml, an entry file that exists, a unique id, the dark thumbnail and a workspace.json
 * whose files exist. A missing light thumbnail is a warning (the app falls back to the dark one).
 * The only dot-folder allowed inside an example is .artifacts/.
 *
 * Captured runs (PHASE2.md): an example's pin, .artifacts/capture.json, must match its source (sourceSha256) and the
 * runtime pinned in runtime.json, so a changed source or a new runtime fails until the example is recaptured.
 * An example without a pin is a warning; `--require-runs` makes it an error once every example is captured.
 * With `--runs <dir>` (the local bundle folder), each pinned bundle is also checked file by file, and the
 * workspace.json resultView must name a figure the run has.
 *
 * Size: every pin must fit the app's bundle limits (EXAMPLE_RUN_LIMITS in runmat-private's
 * desktop/src/lib/examples/run-bundle.ts). The pin's file count and total are checked always; with `--runs`, each
 * file and project.json are checked too. A bundle over a limit does not open already run, so it is an error.
 */
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";

import { PIN_PATH, RUNTIME_PATH, bundleLimits, bundleViolations, sha256, sourceSha256 } from "./lib/bundle.mjs";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const KINDS = new Set(["script", "study", "design"]);
const VISUALS = new Set(["3d", "study", "image", "2d"]);
const REQUIRED = ["id", "title", "pickerTitle", "pickerLine", "description", "topic", "kind", "visual", "entry", "roles", "goals", "origin"];

const args = process.argv.slice(2);
const REQUIRE_RUNS = args.includes("--require-runs");
const RUNS_DIR = args.includes("--runs") ? args[args.indexOf("--runs") + 1] : process.env.RUNMAT_EXAMPLE_RUNS_DIR;
const runtime = existsSync(RUNTIME_PATH) ? JSON.parse(readFileSync(RUNTIME_PATH, "utf8")) : null;
const DIGEST = /^[0-9a-f]{64}$/;
let pinned = 0;
const LIMITS = bundleLimits();
const examplesWorkspace = new Map();

const errors = [];
const warnings = [];
const ids = new Map();
const counts = {};

const isDir = (path) => existsSync(path) && statSync(path).isDirectory();
const groups = readdirSync(ROOT).filter((name) => !name.startsWith(".") && !["scripts", "node_modules"].includes(name) && isDir(join(ROOT, name)));

function readJson(path, where) {
  try {
    return JSON.parse(readFileSync(path, "utf8"));
  } catch (error) {
    errors.push(`${where}: ${relative(ROOT, path)} is not valid JSON (${error.message})`);
    return null;
  }
}

function dotFolders(dir, base = dir) {
  const found = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const path = join(dir, entry.name);
    if (entry.name.startsWith(".") && !(entry.name === ".artifacts" && dir === base)) found.push(relative(base, path));
    else if (!entry.name.startsWith(".")) found.push(...dotFolders(path, base));
  }
  return found;
}

for (const group of groups) {
  for (const name of readdirSync(join(ROOT, group))) {
    const dir = join(ROOT, group, name);
    if (!isDir(dir)) continue;
    const where = `${group}/${name}`;
    const manifestPath = join(dir, "example.json");
    if (!existsSync(manifestPath)) {
      errors.push(`${where}: no example.json`);
      continue;
    }
    const example = readJson(manifestPath, where);
    if (!example) continue;
    counts[group] = (counts[group] ?? 0) + 1;

    for (const key of REQUIRED) if (example[key] === undefined || example[key] === "") errors.push(`${where}: example.json has no ${key}`);
    if (example.id) {
      if (ids.has(example.id)) errors.push(`${where}: id ${example.id} is also used by ${ids.get(example.id)}`);
      ids.set(example.id, where);
    }
    if (example.kind && !KINDS.has(example.kind)) errors.push(`${where}: kind must be script or study, not ${example.kind}`);
    if (example.visual && !VISUALS.has(example.visual)) errors.push(`${where}: visual must be 3d, study, image or 2d, not ${example.visual}`);
    if (example.entry && !existsSync(join(dir, example.entry))) errors.push(`${where}: entry ${example.entry} does not exist`);
    if (!Array.isArray(example.roles) || !Array.isArray(example.goals)) errors.push(`${where}: roles and goals must be arrays`);

    const toml = join(dir, "runmat.toml");
    if (!existsSync(toml)) errors.push(`${where}: no runmat.toml`);
    else {
      const text = readFileSync(toml, "utf8");
      if (!/^\[package\]/m.test(text)) errors.push(`${where}: runmat.toml has no [package]`);
      if (example.entry && !text.includes(`path = "${example.entry}"`)) errors.push(`${where}: runmat.toml entry point is not ${example.entry}`);
    }

    if (!existsSync(join(dir, ".artifacts/thumbnail.webp"))) errors.push(`${where}: no .artifacts/thumbnail.webp`);
    if (!existsSync(join(dir, ".artifacts/thumbnail.light.webp"))) warnings.push(`${where}: no .artifacts/thumbnail.light.webp`);

    const workspacePath = join(dir, ".artifacts/workspace.json");
    if (!existsSync(workspacePath)) errors.push(`${where}: no .artifacts/workspace.json`);
    else {
      const workspace = readJson(workspacePath, where);
      if (workspace) examplesWorkspace.set(where, workspace);
      if (workspace) {
        // The app reads editor.openFiles and editor.activeFile (PHASE2.md section 1).
        const editor = workspace.editor ?? {};
        const files = editor.openFiles ?? [];
        if (!Array.isArray(files) || files.length === 0) errors.push(`${where}: workspace editor.openFiles is empty`);
        for (const file of files) if (!existsSync(join(dir, file))) errors.push(`${where}: workspace opens ${file}, which does not exist`);
        if (!editor.activeFile) errors.push(`${where}: workspace has no editor.activeFile`);
        else if (!files.includes(editor.activeFile)) errors.push(`${where}: activeFile ${editor.activeFile} is not in openFiles`);
        const panels = workspace.panels ?? {};
        for (const key of ["files", "agent", "feaResults"]) {
          if (panels[key] !== undefined && typeof panels[key] !== "boolean") errors.push(`${where}: workspace panels.${key} must be true or false`);
        }
        const runtimeMode = panels.runtime?.mode;
        if (runtimeMode !== undefined && !["auto", "pinned", "hidden"].includes(runtimeMode)) errors.push(`${where}: workspace panels.runtime.mode ${runtimeMode} is not auto, pinned or hidden`);
        const runtimeTab = panels.runtime?.tab;
        if (runtimeTab !== undefined && !["results", "variables", "trace", "log"].includes(runtimeTab)) errors.push(`${where}: workspace panels.runtime.tab ${runtimeTab} is not results, variables, trace or log`);
        const suggestions = workspace.agent?.suggestions ?? [];
        if (suggestions.length < 2 || suggestions.length > 3) errors.push(`${where}: workspace needs 2-3 agent suggestions, has ${suggestions.length}`);
      }
    }

    checkPin(dir, where, example);

    for (const folder of dotFolders(dir)) errors.push(`${where}: dot-folder ${folder} (only .artifacts/ is allowed)`);
  }
}

function checkPin(dir, where, example) {
  const pinPath = join(dir, PIN_PATH);
  if (!existsSync(pinPath)) {
    (REQUIRE_RUNS ? errors : warnings).push(`${where}: no captured run (${PIN_PATH}); run node scripts/capture.mjs --only ${example.id}`);
    return;
  }
  const pin = readJson(pinPath, where);
  if (!pin) return;
  pinned += 1;
  if (pin.schemaVersion !== 1 || !DIGEST.test(pin.bundle?.sha256 ?? "") || !DIGEST.test(pin.sourceSha256 ?? "")) {
    errors.push(`${where}: ${PIN_PATH} is malformed`);
    return;
  }
  if (pin.sourceSha256 !== sourceSha256(dir)) errors.push(`${where}: stale pin, the source changed since the run was captured; recapture it`);
  const pinnedVersion = example.kind === "study" ? runtime?.studies?.version : runtime?.runmat?.version;
  if (!runtime) errors.push(`${where}: pinned, but runtime.json is missing`);
  else if (pinnedVersion && pin.runmat?.version !== pinnedVersion) errors.push(`${where}: stale pin, captured on RunMat ${pin.runmat?.version}, runtime.json pins ${pinnedVersion}; recapture it`);
  else if (!pinnedVersion) warnings.push(`${where}: runtime.json pins no ${example.kind === "study" ? "studies.version" : "runmat.version"}`);
  if (!["cpu_reference", "gpu"].includes(pin.device)) errors.push(`${where}: pin device must be cpu_reference or gpu, not ${pin.device}`);
  if (LIMITS && (pin.bundle.files > LIMITS.files || pin.bundle.bytes > LIMITS.totalBytes)) {
    errors.push(`${where}: captured run is ${pin.bundle.files} files, ${(pin.bundle.bytes / 1024 / 1024).toFixed(1)} MB, over the app's bundle limits (${LIMITS.files} files, ${LIMITS.totalBytes / 1024 / 1024} MB); it would not open already run`);
  }
  if (RUNS_DIR) checkBundle(where, example, pin);
}

/** The local bundle: project.json hashes to the pin, every file matches, and resultView exists in the run. */
function checkBundle(where, example, pin) {
  const base = join(RUNS_DIR, example.id, pin.bundle.sha256);
  if (!existsSync(join(base, "project.json"))) {
    warnings.push(`${where}: bundle ${pin.bundle.sha256.slice(0, 12)} is not in ${RUNS_DIR}`);
    return;
  }
  const manifestBytes = readFileSync(join(base, "project.json"));
  if (sha256(manifestBytes) !== pin.bundle.sha256) {
    errors.push(`${where}: bundle project.json does not hash to the pin`);
    return;
  }
  const manifest = JSON.parse(manifestBytes.toString("utf8"));
  if (LIMITS) for (const problem of bundleViolations(manifestBytes.length, manifest.files, LIMITS)) errors.push(`${where}: bundle too large to open already run: ${problem}`);
  for (const file of manifest.files) {
    const path = join(base, "files", file.path);
    if (!existsSync(path)) errors.push(`${where}: bundle file ${file.path} is missing`);
    else if (sha256(readFileSync(path)) !== file.sha256) errors.push(`${where}: bundle file ${file.path} does not match its sha256`);
  }
  const run = JSON.parse(readFileSync(join(base, "files", manifest.run_manifest), "utf8"));
  const handles = Object.values(run.cells ?? {}).flatMap((cell) => (cell.figures ?? []).map((figure) => figure.handle));
  const view = examplesWorkspace.get(where)?.resultView;
  if (view?.kind === "figure" && !handles.includes(view.figure)) errors.push(`${where}: resultView names figure ${view.figure}, which the captured run does not have (${handles.join(", ") || "none"})`);
}

if (!LIMITS) warnings.push("bundle size limits not checked: runmat-private is not next to this repository (set RUNMAT_PRIVATE_DIR)");
const total = Object.values(counts).reduce((sum, count) => sum + count, 0);
console.log(`${total} examples`);
for (const [group, count] of Object.entries(counts)) console.log(`  ${group}: ${count}`);
for (const warning of warnings) console.warn(`warning: ${warning}`);
for (const error of errors) console.error(`error: ${error}`);
if (errors.length > 0) {
  console.error(`${errors.length} error(s)`);
  process.exit(1);
}
console.log(`ok (${warnings.length} warning(s), ${pinned} captured run(s))`);
