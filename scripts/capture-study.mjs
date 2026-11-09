#!/usr/bin/env node
/*
 * Captures FEA studies (kind "study") through the native snapshot path and publishes each as a bundle, like
 * capture.mjs does for scripts (see lib/bundle.mjs for the bundle and pin formats).
 *
 *   node scripts/capture-study.mjs --runmat <cli> [--only <id>]... [--out <dir>]
 *   node scripts/capture-study.mjs --only <id> --from-project <native snapshot project> [--out <dir>]
 *   node scripts/capture-study.mjs --only <id> --from-bundle [--out <dir>]
 *   node scripts/capture-study.mjs --only <id> --from-snapshot <snapshot dir> --store <study dir> --runmat-version <v> [--out <dir>]
 *
 * With --runmat, each study runs as `<cli> snapshot <entry> --out .snapshot/snapshot.json` in a staging copy of the
 * example. The CLI must be signed in: `runmat login --api-key "$RUNMAT_API_KEY" --server "$RUNMAT_SERVER_URL"` in CI.
 * The snapshot is then written in the app's run format, the same way the runtime's
 * scripts/docs/snapshot-project.mjs does it for the docs examples: the FEA dataset object and its sidecar under
 * .artifacts/objects/<aa>/, and a schemaVersion 2 run manifest whose figures point at the snapshot's scenes and
 * posters. The app's replay index restores the run from these files without solving.
 *
 * With --from-snapshot, the capture reuses a `runmat snapshot` output folder (snapshot.json with its scenes and posters)
 * that was solved elsewhere, for example on a build machine, and writes it in the app's run format as --runmat does.
 * --store is the folder the study was solved in; the study evidence file the snapshot names is copied from its
 * .artifacts. --runmat-version names the CLI build that solved it. The study's code must equal the example's. The pin
 * records analysisStore "omitted": the run opens with its figures and results, and paging raw field values needs a new run.
 *
 * With --from-project, the capture reuses a native snapshot project the runtime already produced (for example a docs
 * example's project/files folder). Its source files must equal the example's. With --from-bundle, it reuses the
 * example's currently pinned bundle in <out> and keeps the pin's RunMat version: use it to republish an existing
 * capture under the current bundle rules without solving again.
 *
 * Size: the bundle must fit the app's limits (EXAMPLE_RUN_LIMITS in runmat-private's
 * desktop/src/lib/examples/run-bundle.ts). By default it carries the whole native analysis store (.artifacts/meshes,
 * publications, studies and the field chunks in .artifacts/objects), which Desktop reads to page field values and
 * to reassess the saved run. When that does not fit, the bundle carries only what the replay restores: the run
 * manifest, the FEA dataset object, the snapshot's scenes and posters, the layout and the study evidence files the
 * dataset names. The run then opens with its figures and results; paging raw field values or reassessing it needs a
 * new run. The pin records which it is (analysisStore: "included" or "omitted"). A bundle that does not fit even
 * then is not published.
 *
 * Stable output: the run keeps the native, content-derived run id; the manifest is saved as
 * .artifacts/runs/run_example_<id>.json and its createdAt is the capture time pinned in runtime.json.
 */
import { execFileSync } from "node:child_process";
import { cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import { pathToFileURL } from "node:url";

import { PIN_PATH, ROOT, RUNTIME_PATH, RUN_MANIFEST, bundleLimits, bundleViolations, listExamples, projectManifest, readJsonFile, sha256, sourceFiles, sourceSha256 } from "./lib/bundle.mjs";

const args = process.argv.slice(2);
const option = (name, fallback) => {
  const index = args.indexOf(name);
  return index >= 0 ? args[index + 1] : fallback;
};
const only = args.flatMap((arg, index) => (arg === "--only" ? [args[index + 1]] : []));
const PRIVATE = resolve(process.env.RUNMAT_PRIVATE_DIR ?? join(ROOT, "../runmat-private"));
const OUT = resolve(option("--out", join(PRIVATE, "website/public/examples-runs")));
const RUNMAT = option("--runmat", process.env.RUNMAT_CLI);
const FROM_PROJECT = option("--from-project");
const FROM_BUNDLE = args.includes("--from-bundle");
const FROM_SNAPSHOT = option("--from-snapshot");
const STORE = option("--store");
const SNAPSHOT_VERSION = option("--runmat-version");
const LIMITS = bundleLimits(PRIVATE);
if (!LIMITS) throw new Error(`No runmat-private at ${PRIVATE}; the capture checks bundles against its loader's limits`);

/**
 * The native analysis store under .artifacts: everything except the app's run manifests (runs/), its sharded
 * objects (objects/<aa>/, the FEA dataset and sidecar) and the layout. Study evidence files the dataset names are
 * kept with the replay set (`keep`).
 */
function isAnalysisStore(path, keep) {
  if (!path.startsWith(".artifacts/") || keep.has(path)) return false;
  return !(path.startsWith(".artifacts/runs/") || path.startsWith(".artifacts/agent/") || /^\.artifacts\/objects\/[0-9a-f]{2}\//.test(path) || path === ".artifacts/workspace.json");
}

/** Study evidence files the run's FEA dataset names (dataset.study.evidenceArtifactPaths). */
function datasetEvidence(project, run) {
  const src = run.fea?.datasetSrc;
  if (!src || !existsSync(join(project, src))) return new Set();
  const paths = readJsonFile(join(project, src)).study?.evidenceArtifactPaths ?? [];
  return new Set(paths.filter((path) => typeof path === "string" && existsSync(join(project, path))));
}

const contracts = await import(pathToFileURL(join(PRIVATE, "desktop/node_modules/runmat/dist/index.js")).href);

function walk(root) {
  const files = [];
  const visit = (dir) => {
    for (const name of readdirSync(dir).sort()) {
      const path = join(dir, name);
      if (statSync(path).isDirectory()) visit(path);
      else files.push(relative(root, path).split("\\").join("/"));
    }
  };
  if (existsSync(root)) visit(root);
  return files;
}

function requireCompleteSnapshot(snapshot) {
  if (snapshot.schema_version !== 1 || !snapshot.publication?.numerically_acceptable || !Array.isArray(snapshot.views) || snapshot.views.length === 0) {
    throw new Error("the study's snapshot is incomplete (not numerically acceptable or no views)");
  }
}

/** The app's run format for a native snapshot (port of the runtime's scripts/docs/snapshot-project.mjs). */
function writeRunFormat(project, example, snapshot, capturedAt) {
  const fieldBindings = snapshot.results.field_descriptors.map((descriptor) => ({
    stepId: snapshot.publication.steps[0].procedure_step.step_id, runId: snapshot.run_id, descriptor,
  }));
  const dataset = {
    schemaVersion: contracts.FEA_RUN_DATASET_SCHEMA_VERSION, kind: contracts.FEA_RUN_DATASET_KIND,
    sessionId: snapshot.run_id, docPath: `/${example.entry}`,
    study: { path: `/${example.entry}`, documentKind: "study", valid: true, evidenceArtifactPaths: [snapshot.publication.evidence_artifact_path] },
    physicsFamily: snapshot.publication.steps[0].procedure_step.family, run: snapshot.publication, resultSummary: snapshot.results.summary,
    fieldBindings, fieldPaging: { mode: "paged", policy: "lazy_materialization" },
    assessments: snapshot.publication.assessments ?? [], diagnostics: snapshot.results.diagnostics ?? [],
  };
  const bytes = `${JSON.stringify(dataset, null, 2)}\n`;
  const digest = sha256(bytes);
  const object = `sha256:${digest}`;
  const directory = `.artifacts/objects/${digest.slice(0, 2)}`;
  const src = `${directory}/${digest}.fea-dataset.json`;
  mkdirSync(join(project, directory), { recursive: true });
  writeFileSync(join(project, src), bytes);
  const metadata = { schemaVersion: contracts.FEA_OBJECT_ARTIFACT_METADATA_SCHEMA_VERSION, artifactId: object, src, bytes: Buffer.byteLength(bytes), mime: "application/json", kind: contracts.FEA_DATASET_ARTIFACT_KIND };
  writeFileSync(join(project, directory, `${digest}.json`), `${JSON.stringify(metadata, null, 2)}\n`);
  const figures = (snapshot.views ?? []).map((view, index) => {
    const sceneSrc = `.snapshot/${view.scene}`;
    const previewSrc = `.snapshot/${view.poster}`;
    return { handle: index + 1, sceneSrc, previewSrc,
      sceneObject: `sha256:${sha256(readFileSync(join(project, sceneSrc)))}`,
      previewObject: `sha256:${sha256(readFileSync(join(project, previewSrc)))}` };
  });
  const manifest = {
    schemaVersion: 2, runId: snapshot.run_id, docPath: `/${example.entry}`,
    createdAt: capturedAt, status: "completed", cancelled: false, runKind: contracts.FEA_RUN_KIND,
    fea: { schemaVersion: contracts.FEA_RUN_MANIFEST_METADATA_SCHEMA_VERSION, datasetObject: object, datasetSrc: src },
    cells: { [contracts.FEA_RUN_CELL_ID]: { figures, kept: [{ id: contracts.feaRunArtifactRefId("dataset"), kind: contracts.FEA_DATASET_ARTIFACT_KIND, src, bytes: metadata.bytes, artifactId: object }] } },
  };
  mkdirSync(join(project, ".artifacts/runs"), { recursive: true });
  writeFileSync(join(project, RUN_MANIFEST(example.id)), `${JSON.stringify(manifest, null, 2)}\n`);
}

/** Reuses a native snapshot project: checks its sources, renames its run manifest and pins its createdAt. */
function adoptProject(project, from, example, sources, capturedAt) {
  for (const file of sources) {
    const theirs = join(from, file.path);
    if (existsSync(theirs) && !readFileSync(theirs).equals(file.bytes)) throw new Error(`${file.path} in ${from} differs from the example`);
  }
  for (const folder of [".artifacts", ".snapshot"]) {
    if (existsSync(join(from, folder))) cpSync(join(from, folder), join(project, folder), { recursive: true });
  }
  const runs = walk(join(project, ".artifacts/runs")).filter((path) => /^[^/]+\.json$/.test(path));
  if (runs.length !== 1) throw new Error(`expected one run manifest in ${from}, found ${runs.length}`);
  const manifest = JSON.parse(readFileSync(join(project, ".artifacts/runs", runs[0]), "utf8"));
  manifest.createdAt = capturedAt;
  rmSync(join(project, ".artifacts/runs", runs[0]));
  writeFileSync(join(project, RUN_MANIFEST(example.id)), `${JSON.stringify(manifest, null, 2)}\n`);
}

const runtimePin = existsSync(RUNTIME_PATH) ? JSON.parse(readFileSync(RUNTIME_PATH, "utf8")) : null;
const capturedAt = runtimePin?.capturedAt ?? new Date().toISOString().replace(/\.\d+Z$/, "Z");
const selected = listExamples().filter((item) => item.example.kind === "study" && (!only.length || only.includes(item.example.id) || only.includes(item.where)));
if (!selected.length) {
  console.error("No study matches --only.");
  process.exit(1);
}
if (FROM_SNAPSHOT && !(STORE && SNAPSHOT_VERSION)) {
  console.error("--from-snapshot needs --store <study dir> and --runmat-version <version of the CLI that solved it>.");
  process.exit(1);
}
if (!RUNMAT && !FROM_PROJECT && !FROM_BUNDLE && !FROM_SNAPSHOT) {
  console.error("Pass --runmat <cli> (a signed-in RunMat CLI), --from-project <native snapshot project>, --from-snapshot <snapshot dir> or --from-bundle.");
  process.exit(1);
}
// Studies run on the native CLI, so runtime.json pins its version separately (`studies.version`). A capture reusing
// a docs snapshot project cannot name the build that solved it and records "docs-snapshot".
const runmatVersion = RUNMAT ? execFileSync(RUNMAT, ["--version"], { encoding: "utf8" }).trim().replace(/^runmat\s+/, "") : FROM_SNAPSHOT ? SNAPSHOT_VERSION : "docs-snapshot";
if (RUNMAT) {
  const pinned = runtimePin ?? { schemaVersion: 1, runmat: { version: null, fingerprint: null }, device: process.env.RUNMAT_CAPTURE_DEVICE ?? "cpu_reference", capturedAt };
  if (pinned.studies?.version && pinned.studies.version !== runmatVersion && !args.includes("--accept-runtime")) {
    console.error(`runmat ${runmatVersion} differs from runtime.json studies.version ${pinned.studies.version}; rerun with --accept-runtime after a release`);
    process.exit(1);
  }
  pinned.studies = { version: runmatVersion };
  writeFileSync(RUNTIME_PATH, `${JSON.stringify(pinned, null, 2)}\n`);
}

let failed = 0;
for (const { dir, where, example } of selected) {
  const sources = sourceFiles(dir);
  const previous = existsSync(join(dir, PIN_PATH)) ? readJsonFile(join(dir, PIN_PATH)) : null;
  const from = FROM_BUNDLE ? previous && join(OUT, example.id, previous.bundle.sha256, "files") : FROM_PROJECT && resolve(FROM_PROJECT);
  const project = mkdtempSync(join(tmpdir(), `runmat-study-${example.id}-`));
  try {
    for (const file of sources) {
      mkdirSync(dirname(join(project, file.path)), { recursive: true });
      writeFileSync(join(project, file.path), file.bytes);
    }
    if (FROM_BUNDLE && !(from && existsSync(from))) throw new Error(`--from-bundle: no pinned bundle in ${OUT}`);
    if (from) adoptProject(project, from, example, sources, capturedAt);
    else if (FROM_SNAPSHOT) {
      cpSync(resolve(FROM_SNAPSHOT), join(project, ".snapshot"), { recursive: true });
      const snapshot = JSON.parse(readFileSync(join(project, ".snapshot/snapshot.json"), "utf8"));
      requireCompleteSnapshot(snapshot);
      const evidence = snapshot.publication.evidence_artifact_path;
      mkdirSync(dirname(join(project, evidence)), { recursive: true });
      cpSync(join(resolve(STORE), evidence), join(project, evidence));
      writeRunFormat(project, example, snapshot, capturedAt);
    } else {
      mkdirSync(join(project, ".snapshot"), { recursive: true });
      execFileSync(RUNMAT, ["snapshot", example.entry, "--out", ".snapshot/snapshot.json"], { cwd: project, stdio: "inherit" });
      const snapshot = JSON.parse(readFileSync(join(project, ".snapshot/snapshot.json"), "utf8"));
      requireCompleteSnapshot(snapshot);
      writeRunFormat(project, example, snapshot, capturedAt);
    }
    const sourcePaths = new Set(sources.map((file) => file.path));
    const run = JSON.parse(readFileSync(join(project, RUN_MANIFEST(example.id)), "utf8"));
    const allRunFiles = walk(project)
      .filter((path) => !sourcePaths.has(path) && (path.startsWith(".artifacts/") || path.startsWith(".snapshot/")))
      .map((path) => ({ path, bytes: readFileSync(join(project, path)) }));
    let bundleFiles = [...sources, ...allRunFiles];
    let manifestBytes = projectManifest(example.id, example.entry, bundleFiles);
    // A snapshot solved elsewhere brings only its evidence file, not the native store's meshes and field chunks.
    let analysisStore = FROM_SNAPSHOT ? "omitted" : "included";
    const full = bundleViolations(manifestBytes.length, bundleFiles, LIMITS);
    if (full.length) {
      const keep = datasetEvidence(project, run);
      const store = allRunFiles.filter((file) => isAnalysisStore(file.path, keep));
      const storeBytes = store.reduce((sum, file) => sum + file.bytes.length, 0);
      console.log(`     ${where}: the run with its analysis store does not fit (${full.join("; ")}); publishing the replay set without the store (${store.length} files, ${(storeBytes / 1024 / 1024).toFixed(1)} MB)`);
      bundleFiles = bundleFiles.filter((file) => !store.includes(file));
      manifestBytes = projectManifest(example.id, example.entry, bundleFiles);
      analysisStore = "omitted";
      const replay = bundleViolations(manifestBytes.length, bundleFiles, LIMITS);
      if (replay.length) throw new Error(`the replay set is over the app's bundle limits: ${replay.join("; ")}`);
    }
    const hash = sha256(manifestBytes);
    const bundleDir = join(OUT, example.id, hash);
    if (!existsSync(join(bundleDir, "project.json"))) {
      const staging = `${bundleDir}.partial`;
      rmSync(staging, { recursive: true, force: true });
      for (const file of bundleFiles) {
        mkdirSync(dirname(join(staging, "files", file.path)), { recursive: true });
        writeFileSync(join(staging, "files", file.path), file.bytes);
      }
      writeFileSync(join(staging, "project.json"), manifestBytes);
      rmSync(bundleDir, { recursive: true, force: true });
      execFileSync("mv", [staging, bundleDir]);
    }
    const bytes = manifestBytes.length + bundleFiles.reduce((sum, file) => sum + file.bytes.length, 0);
    const pin = {
      schemaVersion: 1,
      bundle: { sha256: hash, files: bundleFiles.length, bytes },
      sourceSha256: sourceSha256(dir),
      runmat: FROM_BUNDLE ? previous.runmat : { version: runmatVersion, fingerprint: run.runtimeFingerprint ?? null },
      device: FROM_BUNDLE ? previous.device : process.env.RUNMAT_CAPTURE_DEVICE ?? runtimePin?.device ?? "cpu_reference",
      capturedAt: FROM_BUNDLE ? previous.capturedAt : capturedAt,
      figures: Object.values(run.cells ?? {}).flatMap((cell) => cell.figures ?? []).length,
      analysisStore,
      ...(previous?.guide && bundleFiles.some((file) => file.path.startsWith(`.artifacts/agent/sessions/${previous.guide.sessionId}/`)) ? { guide: previous.guide } : {}),
    };
    writeFileSync(join(dir, PIN_PATH), `${JSON.stringify(pin, null, 2)}\n`);
    console.log(`ok   ${where} ${hash.slice(0, 12)} ${(bytes / 1024 / 1024).toFixed(1)} MB, analysis store ${analysisStore}`);
  } catch (error) {
    failed += 1;
    console.log(`fail ${where}: ${error.message}`);
  } finally {
    rmSync(project, { recursive: true, force: true });
  }
}
if (failed) process.exitCode = 1;
