#!/usr/bin/env node
/*
 * Captures FEA studies (kind "study") through the native snapshot path and publishes each as a bundle, like
 * capture.mjs does for scripts (see lib/bundle.mjs for the bundle and pin formats).
 *
 *   node scripts/capture-study.mjs --runmat <cli> [--only <id>]... [--out <dir>]
 *   node scripts/capture-study.mjs --only <id> --from-project <native snapshot project> [--out <dir>]
 *   node scripts/capture-study.mjs --only <id> --from-bundle [--out <dir>]
 *   node scripts/capture-study.mjs --only <id> --from-snapshot <snapshot dir> --store <study dir> --runmat-version <v> [--out <dir>]
 *   node scripts/capture-study.mjs --only <id> --runmat-version <v> [--out <dir>] \
 *       --study <path.fea> --from-snapshot <snapshot dir> --store <study dir> [--study ... --from-snapshot ... --store ...]
 *   node scripts/capture-study.mjs --only <id> --plan <plan.json> [--out <dir>]
 *   node scripts/capture-study.mjs --only <id> --runmat <cli> --study <path.fea> [--study <path.fea>]...
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
 * .artifacts. --runmat-version names the CLI build that solved it. The study's code must equal the example's.
 * The bundle also carries the part of the store that pages the study's one-value outputs (see partialStore): the
 * run's publication binding, the publication's commit, manifest and run records, and the chunks of each authored
 * output that holds one value (`output peak_temperature = max(...)`). Meshes, observations and every other field's
 * chunks stay out. The pin records analysisStore "partial": the run opens with its figures and results, Desktop and
 * the guide read the one-value outputs, and paging other fields or reassessing needs a new run. A store without a
 * publication binding records "omitted".
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
 *
 * Several studies: an example of any kind (a design project with arm and board studies, say) can ship one captured
 * run per study it contains. Name each study with --study <path.fea> followed by its --from-snapshot and --store (or,
 * with --runmat, the study alone), or list them in a plan file:
 *
 *   { "runmatVersion": "0.7.1", "studies": [
 *       { "study": "simulation/arm_modal.fea", "snapshot": "arm_modal/snap", "store": "arm_modal/store",
 *         "sourceSha256": "<optional sha256 of the .fea that was solved>" } ] }
 *
 * Plan paths are relative to the plan file. Each study's run is saved as .artifacts/runs/run_example_<id>__<slug>.json
 * (slug: the study path without .fea, other characters as "_") with docPath /<study path>, and its snapshot under
 * .snapshot/<slug>/. Each study is checked against its own file: the plan's sourceSha256 when given, and the copy of
 * the study in its --store when the store holds one. The one-value outputs' parts of every store merge into one
 * partial analysis store. project.json lists every run as run_manifests (run_manifest names the first, so list the
 * study the example opens on first); the pin lists them as runs[{study, runId, sourceSha256, figures, analysisStore}].
 * When the bundle is over the limits, studies' stores are left out one at a time, largest first, until it fits.
 */
import { execFileSync } from "node:child_process";
import { cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import { pathToFileURL } from "node:url";

import { PIN_PATH, ROOT, RUNTIME_PATH, RUN_MANIFEST, bundleLimits, bundleViolations, listExamples, projectManifest, readJsonFile, sha256, sourceFiles, sourceSha256, studySlug } from "./lib/bundle.mjs";

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
const PLAN_PATH = option("--plan");
const PLAN = PLAN_PATH ? readJsonFile(resolve(PLAN_PATH)) : null;
const SNAPSHOT_VERSION = option("--runmat-version", PLAN?.runmatVersion);
/** The studies of a multi-study capture, in order: from --plan, or each --study with the options that follow it. */
const STUDIES = PLAN
  ? (PLAN.studies ?? []).map((entry) => ({
      study: entry.study,
      snapshot: entry.snapshot && resolve(dirname(resolve(PLAN_PATH)), entry.snapshot),
      store: entry.store && resolve(dirname(resolve(PLAN_PATH)), entry.store),
      sourceSha256: entry.sourceSha256 ?? null,
    }))
  : args.reduce((studies, arg, index) => {
      if (arg === "--study") studies.push({ study: args[index + 1], snapshot: null, store: null, sourceSha256: null });
      else if (studies.length && arg === "--from-snapshot") studies.at(-1).snapshot = resolve(args[index + 1]);
      else if (studies.length && arg === "--store") studies.at(-1).store = resolve(args[index + 1]);
      return studies;
    }, []);
const MULTI = STUDIES.length > 0;
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

/**
 * Copies from a solved study folder the files the runtime reads to page one field by run id
 * (runmat-runtime analysis/storage: publication binding -> publication commit -> committed run record -> chunks),
 * with the chunks of the study's one-value authored outputs only. Authored output names are identifiers; fields the
 * solver adds are namespaced by family (structural.residual_norm) and stay out, as in Desktop's
 * feaAuthoredScalarOutputFields. Returns the paths copied, or null when the store has no binding.
 */
function partialStore(store, project) {
  const bindings = join(store, ".artifacts/publication-bindings");
  if (!existsSync(bindings)) return null;
  const copied = new Set();
  const copy = (path) => {
    const target = join(project, path);
    // Studies of one example share the project: a file another study's store already put there must be the same.
    if (existsSync(target) && !readFileSync(target).equals(readFileSync(join(store, path)))) throw new Error(`${path} differs between the studies' stores`);
    mkdirSync(dirname(target), { recursive: true });
    cpSync(join(store, path), target);
    copied.add(path);
  };
  const chunks = new Set();
  for (const name of readdirSync(bindings).filter((entry) => entry.endsWith(".json"))) {
    const runId = name.slice(0, -".json".length);
    const binding = readJsonFile(join(bindings, name));
    const publication = binding.Study?.publication?.replace(/^sha256:/, "");
    if (!publication) throw new Error(`${name}: only study publications are supported`);
    const directory = `.artifacts/publications/${publication}`;
    copy(`.artifacts/publication-bindings/${name}`);
    for (const file of ["commit.json", "manifest.json", `runs/${runId}.json`]) copy(`${directory}/${file}`);
    for (const field of readJsonFile(join(store, directory, "runs", `${runId}.json`)).fields ?? []) {
      const values = (field.shape ?? []).reduce((product, size) => product * size, 1);
      if (values !== 1 || field.field_id.includes(".")) continue;
      for (const chunk of field.manifest?.chunks ?? []) chunks.add(chunk.digest.replace(/^sha256:/, ""));
    }
  }
  for (const digest of chunks) copy(`.artifacts/objects/${digest}`);
  return copied;
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

/**
 * The app's run format for a native snapshot (port of the runtime's scripts/docs/snapshot-project.mjs). `run` names
 * the study (`docPath`), where its manifest goes and the folder holding the snapshot's scenes and posters.
 */
function writeRunFormat(project, run, snapshot, capturedAt) {
  const fieldBindings = snapshot.results.field_descriptors.map((descriptor) => ({
    stepId: snapshot.publication.steps[0].procedure_step.step_id, runId: snapshot.run_id, descriptor,
  }));
  const dataset = {
    schemaVersion: contracts.FEA_RUN_DATASET_SCHEMA_VERSION, kind: contracts.FEA_RUN_DATASET_KIND,
    sessionId: snapshot.run_id, docPath: run.docPath,
    study: { path: run.docPath, documentKind: "study", valid: true, evidenceArtifactPaths: [snapshot.publication.evidence_artifact_path] },
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
    const sceneSrc = `${run.snapshotDir}/${view.scene}`;
    const previewSrc = `${run.snapshotDir}/${view.poster}`;
    return { handle: index + 1, sceneSrc, previewSrc,
      sceneObject: `sha256:${sha256(readFileSync(join(project, sceneSrc)))}`,
      previewObject: `sha256:${sha256(readFileSync(join(project, previewSrc)))}` };
  });
  const manifest = {
    schemaVersion: 2, runId: snapshot.run_id, docPath: run.docPath,
    createdAt: capturedAt, status: "completed", cancelled: false, runKind: contracts.FEA_RUN_KIND,
    fea: { schemaVersion: contracts.FEA_RUN_MANIFEST_METADATA_SCHEMA_VERSION, datasetObject: object, datasetSrc: src },
    cells: { [contracts.FEA_RUN_CELL_ID]: { figures, kept: [{ id: contracts.feaRunArtifactRefId("dataset"), kind: contracts.FEA_DATASET_ARTIFACT_KIND, src, bytes: metadata.bytes, artifactId: object }] } },
  };
  mkdirSync(join(project, ".artifacts/runs"), { recursive: true });
  writeFileSync(join(project, run.manifestPath), `${JSON.stringify(manifest, null, 2)}\n`);
}

/** The single-study run of an example: its entry, .artifacts/runs/run_example_<id>.json, .snapshot/. */
const entryRun = (example) => ({ docPath: `/${example.entry}`, manifestPath: RUN_MANIFEST(example.id), snapshotDir: ".snapshot" });

/** Writes a bundle once per content hash under <OUT>/<id>/<hash>. */
function publishBundle(example, hash, manifestBytes, bundleFiles) {
  const bundleDir = join(OUT, example.id, hash);
  if (existsSync(join(bundleDir, "project.json"))) return;
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
// A multi-study capture names its studies, so it takes one example of any kind; otherwise each example is one study.
const selected = listExamples().filter((item) => (MULTI || item.example.kind === "study") && (!only.length || only.includes(item.example.id) || only.includes(item.where)));
if (!selected.length) {
  console.error("No study matches --only.");
  process.exit(1);
}
if (MULTI && (selected.length !== 1 || !only.length)) {
  console.error("--study and --plan capture the studies of one example: pass exactly one --only <id>.");
  process.exit(1);
}
if (MULTI && (FROM_PROJECT || FROM_BUNDLE)) {
  console.error("--study and --plan take --from-snapshot and --store per study, or --runmat.");
  process.exit(1);
}
if (MULTI && !RUNMAT && !(SNAPSHOT_VERSION && STUDIES.every((entry) => entry.study && entry.snapshot && entry.store))) {
  console.error("Each --study needs its --from-snapshot <snapshot dir> and --store <study dir>, and the capture needs --runmat-version.");
  process.exit(1);
}
if (!MULTI && FROM_SNAPSHOT && !(STORE && SNAPSHOT_VERSION)) {
  console.error("--from-snapshot needs --store <study dir> and --runmat-version <version of the CLI that solved it>.");
  process.exit(1);
}
if (!MULTI && !RUNMAT && !FROM_PROJECT && !FROM_BUNDLE && !FROM_SNAPSHOT) {
  console.error("Pass --runmat <cli> (a signed-in RunMat CLI), --from-project <native snapshot project>, --from-snapshot <snapshot dir> or --from-bundle.");
  process.exit(1);
}
// Studies run on the native CLI, so runtime.json pins its version separately (`studies.version`). A capture reusing
// a docs snapshot project cannot name the build that solved it and records "docs-snapshot".
const runmatVersion = RUNMAT ? execFileSync(RUNMAT, ["--version"], { encoding: "utf8" }).trim().replace(/^runmat\s+/, "") : FROM_SNAPSHOT || MULTI ? SNAPSHOT_VERSION : "docs-snapshot";
if (RUNMAT) {
  const pinned = runtimePin ?? { schemaVersion: 1, runmat: { version: null, fingerprint: null }, device: process.env.RUNMAT_CAPTURE_DEVICE ?? "cpu_reference", capturedAt };
  if (pinned.studies?.version && pinned.studies.version !== runmatVersion && !args.includes("--accept-runtime")) {
    console.error(`runmat ${runmatVersion} differs from runtime.json studies.version ${pinned.studies.version}; rerun with --accept-runtime after a release`);
    process.exit(1);
  }
  pinned.studies = { version: runmatVersion };
  writeFileSync(RUNTIME_PATH, `${JSON.stringify(pinned, null, 2)}\n`);
}

/**
 * Captures every study STUDIES names into one bundle for the example: one run per study, each under its own run
 * file, snapshot folder and docPath (see "Several studies" above).
 */
function captureStudies({ dir, where, example }) {
  const sources = sourceFiles(dir);
  const byPath = new Map(sources.map((file) => [file.path, file]));
  const previous = existsSync(join(dir, PIN_PATH)) ? readJsonFile(join(dir, PIN_PATH)) : null;
  const project = mkdtempSync(join(tmpdir(), `runmat-study-${example.id}-`));
  try {
    for (const file of sources) {
      mkdirSync(dirname(join(project, file.path)), { recursive: true });
      writeFileSync(join(project, file.path), file.bytes);
    }
    const runs = [];
    for (const entry of STUDIES) {
      const study = entry.study.replace(/^\/+/, "");
      const file = byPath.get(study);
      if (!study.endsWith(".fea") || !file) throw new Error(`${entry.study} is not a study in ${where}`);
      const digest = sha256(file.bytes);
      if (entry.sourceSha256 && entry.sourceSha256.replace(/^sha256:/, "") !== digest) throw new Error(`${study} differs from the study that was solved (sourceSha256)`);
      for (const solved of entry.store ? [join(entry.store, study), join(entry.store, study.split("/").pop())] : []) {
        if (existsSync(solved) && !readFileSync(solved).equals(file.bytes)) throw new Error(`${study} differs from the copy in its store (${solved})`);
      }
      const slug = studySlug(study);
      if (runs.some((run) => run.slug === slug)) throw new Error(`${study} is listed twice`);
      const run = { study, slug, docPath: `/${study}`, manifestPath: RUN_MANIFEST(example.id, slug), snapshotDir: `.snapshot/${slug}`, sourceSha256: digest, storePaths: null };
      let snapshot;
      if (RUNMAT) {
        mkdirSync(join(project, run.snapshotDir), { recursive: true });
        execFileSync(RUNMAT, ["snapshot", study, "--out", `${run.snapshotDir}/snapshot.json`], { cwd: project, stdio: "inherit" });
        snapshot = JSON.parse(readFileSync(join(project, run.snapshotDir, "snapshot.json"), "utf8"));
        requireCompleteSnapshot(snapshot);
      } else {
        cpSync(entry.snapshot, join(project, run.snapshotDir), { recursive: true });
        snapshot = JSON.parse(readFileSync(join(project, run.snapshotDir, "snapshot.json"), "utf8"));
        requireCompleteSnapshot(snapshot);
        const evidence = snapshot.publication.evidence_artifact_path;
        const target = join(project, evidence);
        if (existsSync(target) && !readFileSync(target).equals(readFileSync(join(entry.store, evidence)))) throw new Error(`${evidence} differs between the studies' stores`);
        mkdirSync(dirname(target), { recursive: true });
        cpSync(join(entry.store, evidence), target);
        run.storePaths = partialStore(entry.store, project);
      }
      writeRunFormat(project, run, snapshot, capturedAt);
      run.runId = snapshot.run_id;
      run.figures = snapshot.views.length;
      run.analysisStore = RUNMAT ? "included" : run.storePaths === null ? "omitted" : "partial";
      runs.push(run);
    }
    const sourcePaths = new Set(sources.map((file) => file.path));
    const allRunFiles = walk(project)
      .filter((path) => !sourcePaths.has(path) && (path.startsWith(".artifacts/") || path.startsWith(".snapshot/")))
      .map((path) => ({ path, bytes: readFileSync(join(project, path)) }));
    const runManifests = runs.map((run) => run.manifestPath);
    let bundleFiles = [...sources, ...allRunFiles];
    let manifestBytes = projectManifest(example.id, example.entry, bundleFiles, runManifests);
    const full = bundleViolations(manifestBytes.length, bundleFiles, LIMITS);
    if (full.length) {
      // Each study's own part of the store: the paths its store brought (a snapshot solved elsewhere), or, with
      // --runmat, the one native store every study wrote into. Evidence files the datasets name stay in the replay set.
      const keep = new Set(runs.flatMap((run) => [...datasetEvidence(project, readJsonFile(join(project, run.manifestPath)))]));
      const groups = RUNMAT
        ? [{ runs, paths: new Set(allRunFiles.map((file) => file.path).filter((path) => isAnalysisStore(path, keep))) }]
        : runs.filter((run) => run.storePaths).map((run) => ({ runs: [run], paths: new Set([...run.storePaths].filter((path) => !keep.has(path))) }));
      const size = (group) => bundleFiles.filter((file) => group.paths.has(file.path)).reduce((sum, file) => sum + file.bytes.length, 0);
      groups.sort((a, b) => size(b) - size(a));
      let violations = full;
      for (const group of groups) {
        if (!violations.length) break;
        const shared = new Set(runs.filter((run) => !group.runs.includes(run) && run.analysisStore !== "omitted").flatMap((run) => [...(run.storePaths ?? [])]));
        console.log(`     ${where}: the bundle with ${group.runs.map((run) => run.study).join(", ")}'s analysis store does not fit (${violations.join("; ")}); leaving that store out (${(size(group) / 1024 / 1024).toFixed(1)} MB)`);
        bundleFiles = bundleFiles.filter((file) => !group.paths.has(file.path) || shared.has(file.path));
        for (const run of group.runs) run.analysisStore = "omitted";
        manifestBytes = projectManifest(example.id, example.entry, bundleFiles, runManifests);
        violations = bundleViolations(manifestBytes.length, bundleFiles, LIMITS);
      }
      if (violations.length) throw new Error(`the replay set is over the app's bundle limits: ${violations.join("; ")}`);
    }
    const hash = sha256(manifestBytes);
    publishBundle(example, hash, manifestBytes, bundleFiles);
    const bytes = manifestBytes.length + bundleFiles.reduce((sum, file) => sum + file.bytes.length, 0);
    const stores = new Set(runs.map((run) => run.analysisStore));
    const pin = {
      schemaVersion: 1,
      bundle: { sha256: hash, files: bundleFiles.length, bytes },
      sourceSha256: sourceSha256(dir),
      runmat: { version: runmatVersion, fingerprint: null },
      device: process.env.RUNMAT_CAPTURE_DEVICE ?? runtimePin?.device ?? "cpu_reference",
      capturedAt,
      figures: runs.reduce((sum, run) => sum + run.figures, 0),
      analysisStore: stores.size === 1 ? [...stores][0] : "mixed",
      runs: runs.map((run) => ({ study: run.study, runId: run.runId, sourceSha256: run.sourceSha256, figures: run.figures, analysisStore: run.analysisStore })),
      ...(previous?.guide && bundleFiles.some((file) => file.path.startsWith(`.artifacts/agent/sessions/${previous.guide.sessionId}/`)) ? { guide: previous.guide } : {}),
    };
    writeFileSync(join(dir, PIN_PATH), `${JSON.stringify(pin, null, 2)}\n`);
    console.log(`ok   ${where} ${hash.slice(0, 12)} ${(bytes / 1024 / 1024).toFixed(1)} MB, ${runs.length} studies: ${runs.map((run) => `${run.study} (store ${run.analysisStore})`).join(", ")}`);
    return true;
  } catch (error) {
    console.log(`fail ${where}: ${error.message}`);
    return false;
  } finally {
    rmSync(project, { recursive: true, force: true });
  }
}

let failed = 0;
if (MULTI) failed += captureStudies(selected[0]) ? 0 : 1;
for (const { dir, where, example } of MULTI ? [] : selected) {
  const sources = sourceFiles(dir);
  const previous = existsSync(join(dir, PIN_PATH)) ? readJsonFile(join(dir, PIN_PATH)) : null;
  const from = FROM_BUNDLE ? previous && join(OUT, example.id, previous.bundle.sha256, "files") : FROM_PROJECT && resolve(FROM_PROJECT);
  const project = mkdtempSync(join(tmpdir(), `runmat-study-${example.id}-`));
  let partial = null;
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
      partial = partialStore(resolve(STORE), project);
      writeRunFormat(project, entryRun(example), snapshot, capturedAt);
    } else {
      mkdirSync(join(project, ".snapshot"), { recursive: true });
      execFileSync(RUNMAT, ["snapshot", example.entry, "--out", ".snapshot/snapshot.json"], { cwd: project, stdio: "inherit" });
      const snapshot = JSON.parse(readFileSync(join(project, ".snapshot/snapshot.json"), "utf8"));
      requireCompleteSnapshot(snapshot);
      writeRunFormat(project, entryRun(example), snapshot, capturedAt);
    }
    const sourcePaths = new Set(sources.map((file) => file.path));
    const run = JSON.parse(readFileSync(join(project, RUN_MANIFEST(example.id)), "utf8"));
    const allRunFiles = walk(project)
      .filter((path) => !sourcePaths.has(path) && (path.startsWith(".artifacts/") || path.startsWith(".snapshot/")))
      .map((path) => ({ path, bytes: readFileSync(join(project, path)) }));
    let bundleFiles = [...sources, ...allRunFiles];
    let manifestBytes = projectManifest(example.id, example.entry, bundleFiles);
    // A snapshot solved elsewhere brings its evidence file and the one-value outputs' part of the store, not the
    // native store's meshes and other field chunks.
    let analysisStore = FROM_SNAPSHOT ? (partial === null ? "omitted" : "partial") : "included";
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
    publishBundle(example, hash, manifestBytes, bundleFiles);
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
