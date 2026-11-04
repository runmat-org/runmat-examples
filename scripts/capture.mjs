#!/usr/bin/env node
/*
 * Captures each example's finished run and publishes it as a content-addressed bundle (see lib/bundle.mjs).
 *
 *   node scripts/capture.mjs [--only <id>]... [--out <dir>] [--app <origin>] [--gap <ms>] [--accept-runtime]
 *
 * Each example runs the way the app runs it: the script is opened in the RunMat sandbox (the app's browser client,
 * driven by a headless Chromium) with run-on-open, so the run manifest (schemaVersion 2), objects and sidecars are
 * written by the app's own shared planner. The capture then reads .artifacts/runs and .artifacts/objects back out of
 * the sandbox's filesystem worker and makes the output stable:
 *
 * - the run id becomes run_example_<id>;
 * - every timestamp in the run manifest and its logs becomes the capture time pinned in runtime.json;
 * - log lines are kept in order, so a rerun on the same runtime writes the same bytes.
 *
 * It writes:
 *   <out>/<id>/<hash>/project.json and files/...   the bundle (immutable; <hash> is sha256(project.json))
 *   <example>/.artifacts/capture.json              the pin git keeps (bundle hash, RunMat version, source hash)
 *   <example>/.artifacts/thumbnail(.light).webp    re-derived from the captured figure, dark and light
 *
 * Options:
 *   --out     bundle folder. Default: ../runmat-private/website/public/examples-runs, which the dev site serves at
 *             http://localhost:1001/examples-runs (gitignored). CI writes to a staging folder and uploads it.
 *   --app     origin serving the sandbox at /sandbox. Default http://localhost:1001.
 *   --gap     pause between examples in ms (default 4000), so the dev server is not flooded.
 *   --accept-runtime  record the sandbox's runtime as the pinned runtime.json instead of refusing a mismatch.
 *   --no-thumbnails   leave thumbnails as they are.
 *
 * FEA studies (kind "study") run through the same sandbox path when the app can solve them in the browser; when it
 * cannot, the capture reports them as skipped and the CI workflow captures them with `runmat snapshot` instead.
 */
import { execFileSync } from "node:child_process";
import { createRequire } from "node:module";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";

import {
  PIN_PATH,
  ROOT,
  RUNTIME_PATH,
  listExamples,
  projectManifest,
  runIdFor,
  sha256,
  sourceFiles,
  sourceSha256,
} from "./lib/bundle.mjs";

const args = process.argv.slice(2);
const option = (name, fallback) => {
  const index = args.indexOf(name);
  return index >= 0 ? args[index + 1] : fallback;
};
const only = args.flatMap((arg, index) => (arg === "--only" ? [args[index + 1]] : []));
const PRIVATE = resolve(process.env.RUNMAT_PRIVATE_DIR ?? join(ROOT, "../runmat-private"));
const OUT = resolve(option("--out", join(PRIVATE, "website/public/examples-runs")));
const APP = option("--app", "http://localhost:1001").replace(/\/$/, "");
const GAP_MS = Number(option("--gap", "4000"));
const ACCEPT_RUNTIME = args.includes("--accept-runtime");
const THUMBNAILS = !args.includes("--no-thumbnails");
/** Sign the sandbox in first (FEA studies need it). Local development only: the dev site's local auth signs in the
 * repository's local developer account. */
const SIGN_IN = args.includes("--sign-in");
const RUN_TIMEOUT_MS = Number(option("--timeout", "240000"));

const require = createRequire(join(PRIVATE, "desktop/package.json"));
const { chromium } = require("playwright");
/**
 * Full Chromium in new headless mode with WebGPU on SwiftShader, so figures draw with the app's WebGPU renderer on a
 * machine without a GPU (a hosted CI runner). The headless shell has no WebGPU and falls back to a coarse renderer.
 */
const CHROMIUM = process.env.CHROMIUM_PATH ?? chromium.executablePath();
const CHROMIUM_ARGS = ["--enable-unsafe-webgpu", "--enable-features=Vulkan,WebGPU", "--use-webgpu-adapter=swiftshader", "--use-angle=swiftshader", "--enable-unsafe-swiftshader"];

/* ------------------------------------------------------------------ sandbox driving */

/** Wraps Worker so the harness can talk to the app's filesystem worker with the app's own fs.* requests. */
function recordWorkers() {
  const Original = window.Worker;
  window.__captureWorkers = [];
  window.Worker = class extends Original {
    constructor(url, options) {
      super(url, options);
      window.__captureWorkers.push({ url: String(url), worker: this });
    }
  };
}

async function fsRequest(page, command, payload) {
  return page.evaluate(async ({ command, payload }) => {
    const entry = window.__captureWorkers.find((candidate) => /fs_worker|fs\/worker/.test(candidate.url));
    if (!entry) throw new Error("The sandbox filesystem worker is not running");
    const id = 2_000_000_000 + Math.floor(Math.random() * 100_000_000);
    const response = await new Promise((resolveResponse, rejectResponse) => {
      const timer = setTimeout(() => rejectResponse(new Error(`${command} timed out`)), 20_000);
      const onMessage = (event) => {
        if (event.data?.kind !== "response" || event.data.id !== id) return;
        clearTimeout(timer);
        entry.worker.removeEventListener("message", onMessage);
        resolveResponse(event.data);
      };
      entry.worker.addEventListener("message", onMessage);
      entry.worker.postMessage({ id, requestId: `capture_${id}`, command, payload });
    });
    if (!response.success) return { error: response.error?.message ?? "fs error" };
    const result = response.result;
    return { result: result instanceof ArrayBuffer ? Array.from(new Uint8Array(result)) : result };
  }, { command, payload });
}

async function list(page, path) {
  const { result, error } = await fsRequest(page, "fs.list", { path });
  return error ? [] : result;
}

async function walk(page, path) {
  const files = [];
  for (const entry of await list(page, path)) {
    if (entry.fileType === "dir") files.push(...(await walk(page, entry.path)));
    else files.push(entry.path);
  }
  return files;
}

async function read(page, path) {
  const { result, error } = await fsRequest(page, "fs.read", { path });
  if (error) throw new Error(`${path}: ${error}`);
  return Buffer.from(result);
}

/** Signs in through the app's own login flow and waits to land back on the app. */
async function signIn(page) {
  await page.goto(`${APP}/login?returnTo=%2Fsandbox`, { waitUntil: "domcontentloaded" });
  await page.waitForURL((url) => url.origin === new URL(APP).origin && !url.pathname.startsWith("/login"), { timeout: 90_000 });
}

/**
 * Opens the example in the sandbox the way "Open example" does, flagged to run its entry once.
 *
 * The launch payload carries text only. An example with binary source files (saved results it plays back) opens
 * without run-on-open instead: the capture writes those files through the filesystem worker, then presses Run, which
 * runs the project's `main` entry point the same way.
 */
async function openAndRun(browser, entry, files, theme, binary = []) {
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 }, deviceScaleFactor: 1, colorScheme: theme });
  await context.addInitScript(recordWorkers);
  await context.addInitScript((value) => {
    try { localStorage.setItem("theme", value); } catch { /* storage blocked */ }
  }, theme);
  const page = await context.newPage();
  if (SIGN_IN) await signIn(page);
  await page.goto(`${APP}/sandbox`, { waitUntil: "domcontentloaded" });
  const launchId = `capture-${Date.now().toString(36)}`;
  const runOnOpen = binary.length === 0;
  await page.evaluate(({ launchId, files, entry, runOnOpen }) => {
    const now = Date.now();
    localStorage.setItem(`runmat:workspace:${launchId}`, JSON.stringify({
      id: launchId,
      files,
      openPath: entry,
      metadata: { source: "examples-capture", runOnOpen },
      createdAt: now,
      expiresAt: now + 600_000,
    }));
  }, { launchId, files, entry, runOnOpen });
  await page.goto(`${APP}/sandbox?workspace=${launchId}`, { waitUntil: "domcontentloaded" });
  if (!runOnOpen) await writeBinaryAndRun(page, binary);
  return { context, page };
}

/** Writes binary source files into the opened sandbox, then presses Run. */
async function writeBinaryAndRun(page, binary) {
  const deadline = Date.now() + 60_000;
  while ((await list(page, "/")).length === 0) {
    if (Date.now() > deadline) throw new Error("the sandbox filesystem did not open");
    await page.waitForTimeout(1000);
  }
  for (const file of binary) {
    const path = `/${file.path}`;
    await fsRequest(page, "fs.mkdir", { path: dirname(path), recursive: true });
    const written = await fsWrite(page, path, file.bytes);
    if (written.error) throw new Error(`${path}: ${written.error}`);
  }
  // Let the editor settle on the opened files before running.
  await page.waitForTimeout(5000);
  await page.getByRole("button", { name: /^Run\b/ }).first().click({ timeout: 30_000 });
}

/** fs.write with a binary payload (fsRequest passes JSON-safe payloads only). */
async function fsWrite(page, path, bytes) {
  return page.evaluate(async ({ path, data }) => {
    const entry = window.__captureWorkers.find((candidate) => /fs_worker|fs\/worker/.test(candidate.url));
    if (!entry) return { error: "The sandbox filesystem worker is not running" };
    const id = 2_000_000_000 + Math.floor(Math.random() * 100_000_000);
    const response = await new Promise((resolveResponse) => {
      const timer = setTimeout(() => resolveResponse({ success: false, error: { message: "fs.write timed out" } }), 30_000);
      const onMessage = (event) => {
        if (event.data?.kind !== "response" || event.data.id !== id) return;
        clearTimeout(timer);
        entry.worker.removeEventListener("message", onMessage);
        resolveResponse(event.data);
      };
      entry.worker.addEventListener("message", onMessage);
      entry.worker.postMessage({ id, requestId: `capture_${id}`, command: "fs.write", payload: { path, data: new Uint8Array(data).buffer } });
    });
    return response.success ? {} : { error: response.error?.message ?? "fs error" };
  }, { path, data: Array.from(bytes) });
}

/** Waits for the run manifest and every object it names. Returns the manifest path. */
async function waitForRun(page) {
  const deadline = Date.now() + RUN_TIMEOUT_MS;
  while (Date.now() < deadline) {
    await page.waitForTimeout(2000);
    const runs = (await list(page, "/.artifacts/runs")).filter((entry) => entry.fileType === "file" && entry.path.endsWith(".json"));
    if (runs.length === 0) continue;
    if (runs.length > 1) throw new Error(`expected one run, found ${runs.length}`);
    const manifest = JSON.parse((await read(page, runs[0].path)).toString("utf8"));
    const named = JSON.stringify(manifest).match(/\.artifacts\/objects\/[0-9a-f]{2}\/[0-9a-f]{64}[^"]*/g) ?? [];
    const present = new Set(await walk(page, "/.artifacts/objects"));
    if (named.every((src) => present.has(`/${src}`))) {
      await page.waitForTimeout(1500);
      return runs[0].path;
    }
  }
  throw new Error(`no finished run after ${RUN_TIMEOUT_MS / 1000}s`);
}

/* ------------------------------------------------------------------ stable output */

const TIMESTAMP = /(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})(\.\d+)?(Z|[+-]\d{2}:\d{2})/g;
const OBJECT = /^\.artifacts\/objects\/([0-9a-f]{2})\/([0-9a-f]{64})(\..+)$/;
const SIDECAR = /^\.artifacts\/objects\/[0-9a-f]{2}\/[0-9a-f]{64}\.json$/;

/** Every timestamp becomes the capture time, in the same format and length, so byte counts stay valid. */
function pinTimestamps(text, capturedAt) {
  const base = capturedAt.replace(/(\.\d+)?Z$/, "");
  return text.replace(TIMESTAMP, (_match, _time, fraction, zone) => `${base}${fraction ? `.${"0".repeat(fraction.length - 1)}` : ""}${zone}`);
}

/**
 * Makes a capture byte-stable: the run id becomes run_example_<id>, and every timestamp in the run manifest, its logs
 * and the JSON objects (workspace and figure scenes carry a createdAt) becomes the capture time. A rewritten object
 * gets its new content address: the file and its sidecar are renamed and every reference in the run is updated.
 */
function stabilize(files, originalRunId, runId, capturedAt) {
  const capturedMs = Date.parse(capturedAt);
  const renames = new Map();
  const objects = [];
  const rest = [];
  for (const file of files) {
    const match = OBJECT.exec(file.path);
    if (match && !SIDECAR.test(file.path)) objects.push({ file, hash: match[2], ext: match[3] });
    else rest.push(file);
  }
  const out = [];
  for (const { file, hash, ext } of objects) {
    let bytes = file.bytes;
    if (ext.endsWith(".json")) {
      const text = bytes.toString("utf8");
      const pinned = pinTimestamps(text, capturedAt);
      if (pinned !== text) bytes = Buffer.from(pinned);
    }
    const next = sha256(bytes);
    if (next !== hash) renames.set(hash, next);
    out.push({ path: `.artifacts/objects/${next.slice(0, 2)}/${next}${ext}`, bytes });
  }
  const rename = (text) => {
    let value = text;
    for (const [from, to] of renames) value = value.split(`objects/${from.slice(0, 2)}/${from}`).join(`objects/${to.slice(0, 2)}/${to}`).split(from).join(to);
    return value;
  };
  for (const file of rest) {
    let path = file.path.replace(`/runs/${originalRunId}`, `/runs/${runId}`);
    const sidecar = SIDECAR.test(path) ? /([0-9a-f]{64})\.json$/.exec(path)[1] : null;
    if (sidecar && renames.has(sidecar)) path = `.artifacts/objects/${renames.get(sidecar).slice(0, 2)}/${renames.get(sidecar)}.json`;
    let bytes = file.bytes;
    if (path.startsWith(".artifacts/runs/") || sidecar) {
      let text = rename(pinTimestamps(bytes.toString("utf8").split(originalRunId).join(runId), capturedAt));
      text = text.replace(/("(?:startedAt|endedAt|createdAt|updatedAt|timestampMs|timestamp_ms|startedAtMs|endedAtMs)"\s*:\s*)\d{12,}/g, `$1${capturedMs}`);
      text = text.replace(/("(?:durationMs|duration_ms|elapsedMs|elapsed_ms)"\s*:\s*)\d+(?:\.\d+)?/g, "$10");
      bytes = Buffer.from(text);
    }
    out.push({ path, bytes, before: file.bytes.length });
  }
  // The log channel holds the browser renderer's diagnostics (canvas attach, resize, figure events). Their number
  // and order depend on frame timing, so the same run never writes the same bytes twice, and they tell a reader
  // nothing about the example. The captured run leaves the channel out; output the script prints is kept in its
  // stdout/stderr objects.
  const manifestFile = out.find((file) => file.path.endsWith(`/runs/${runId}.json`));
  const original = manifestFile.bytes.toString("utf8");
  const manifest = JSON.parse(original);
  const dropped = new Set();
  for (const [name, channel] of Object.entries(manifest.channels ?? {})) {
    if (channel?.encoding !== "ndjson") continue;
    dropped.add(channel.src);
    if (manifest.stats && typeof manifest.stats.totalBytes === "number" && typeof channel.bytes === "number") manifest.stats.totalBytes -= channel.bytes;
    delete manifest.channels[name];
  }
  if (manifest.channels && Object.keys(manifest.channels).length === 0) delete manifest.channels;
  if (dropped.size) {
    const indent = /^\{\n( +)"/.exec(original)?.[1]?.length ?? 0;
    manifestFile.bytes = Buffer.from(JSON.stringify(manifest, null, indent || undefined) + (original.endsWith("\n") ? "\n" : ""));
  }
  return out.filter((file) => !dropped.has(file.path)).map(({ path, bytes }) => ({ path, bytes }));
}

/* ------------------------------------------------------------------ thumbnails */

function writeThumbnail(png, destination) {
  const dir = mkdtempSync(join(tmpdir(), "runmat-thumb-"));
  try {
    const source = join(dir, "figure.png");
    writeFileSync(source, png);
    execFileSync("cwebp", ["-quiet", "-q", "85", "-resize", "960", "0", source, "-o", destination]);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

/** The figure the example opens on: workspace.json's resultView figure, else handle 1, else the first. */
function figurePng(files, manifest, workspace) {
  const cells = Object.values(manifest.cells ?? {});
  const figures = cells.flatMap((cell) => cell.figures ?? []);
  const wanted = workspace?.resultView?.kind === "figure" ? workspace.resultView.figure : 1;
  const figure = figures.find((candidate) => candidate.handle === wanted) ?? figures[0];
  const src = figure?.previewSrc;
  return src ? files.find((file) => file.path === src)?.bytes ?? null : null;
}

/* ------------------------------------------------------------------ main */

/** The runtime the sandbox runs: the `runmat` package the app is built with. */
function sandboxRuntimeVersion() {
  try {
    return JSON.parse(readFileSync(join(PRIVATE, "desktop/node_modules/runmat/package.json"), "utf8")).version;
  } catch {
    return "unknown";
  }
}

function readRuntimePin() {
  return existsSync(RUNTIME_PATH) ? JSON.parse(readFileSync(RUNTIME_PATH, "utf8")) : null;
}

async function captureOne(browser, { dir, where, example }, runtime) {
  const sources = sourceFiles(dir);
  const isText = (file) => Buffer.from(file.bytes.toString("utf8"), "utf8").equals(file.bytes);
  const seed = sources.filter(isText).map((file) => ({ path: `/${file.path}`, content: file.bytes.toString("utf8") }));
  const binary = sources.filter((file) => !isText(file));
  const entry = `/${example.entry}`;
  const runId = runIdFor(example.id);

  const runs = {};
  for (const theme of THUMBNAILS ? ["dark", "light"] : ["dark"]) {
    const { context, page } = await openAndRun(browser, entry, seed, theme, binary);
    try {
      const manifestPath = await waitForRun(page);
      const paths = [...(await walk(page, "/.artifacts/runs")), ...(await walk(page, "/.artifacts/objects"))];
      const files = [];
      for (const path of paths) files.push({ path: path.replace(/^\//, ""), bytes: await read(page, path) });
      const manifest = JSON.parse(files.find((file) => `/${file.path}` === manifestPath).bytes.toString("utf8"));
      runs[theme] = { files, manifest, originalRunId: manifest.runId };
    } finally {
      await context.close();
    }
    if (theme === "dark" && THUMBNAILS) await new Promise((done) => setTimeout(done, Math.min(GAP_MS, 2000)));
  }

  const dark = runs.dark;
  const fingerprint = dark.manifest.runtimeFingerprint ?? null;
  if (runtime.runmat.fingerprint && fingerprint !== runtime.runmat.fingerprint) {
    throw new Error(`runtime ${fingerprint} differs from runtime.json (${runtime.runmat.fingerprint}); rerun with --accept-runtime after a release`);
  }
  if (!["completed", "complete", "succeeded", "success"].includes(String(dark.manifest.status))) {
    throw new Error(`run ended ${dark.manifest.status}${dark.manifest.failureMessage ? `: ${dark.manifest.failureMessage}` : ""}`);
  }

  const runFiles = stabilize(dark.files, dark.originalRunId, runId, runtime.capturedAt);
  const bundleFiles = [...sources, ...runFiles];
  const project = projectManifest(example.id, example.entry, bundleFiles);
  const hash = sha256(project);
  const bundleDir = join(OUT, example.id, hash);
  if (!existsSync(join(bundleDir, "project.json"))) {
    const staging = `${bundleDir}.partial`;
    rmSync(staging, { recursive: true, force: true });
    for (const file of bundleFiles) {
      const destination = join(staging, "files", file.path);
      mkdirSync(dirname(destination), { recursive: true });
      writeFileSync(destination, file.bytes);
    }
    writeFileSync(join(staging, "project.json"), project);
    rmSync(bundleDir, { recursive: true, force: true });
    execFileSync("mv", [staging, bundleDir]);
  }

  const bytes = project.length + bundleFiles.reduce((sum, file) => sum + file.bytes.length, 0);
  const figures = Object.values(dark.manifest.cells ?? {}).flatMap((cell) => cell.figures ?? []).length;
  const pin = {
    schemaVersion: 1,
    bundle: { sha256: hash, files: bundleFiles.length, bytes },
    sourceSha256: sourceSha256(dir),
    runmat: { version: runtime.runmat.version, fingerprint },
    device: runtime.device,
    capturedAt: runtime.capturedAt,
    figures,
  };
  writeFileSync(join(dir, PIN_PATH), `${JSON.stringify(pin, null, 2)}\n`);

  if (THUMBNAILS) {
    const workspacePath = join(dir, ".artifacts/workspace.json");
    const workspace = existsSync(workspacePath) ? JSON.parse(readFileSync(workspacePath, "utf8")) : null;
    for (const [theme, name] of [["dark", "thumbnail.webp"], ["light", "thumbnail.light.webp"]]) {
      const png = runs[theme] && figurePng(runs[theme].files.map((file) => ({ ...file, path: file.path })), runs[theme].manifest, workspace);
      if (png) writeThumbnail(png, join(dir, ".artifacts", name));
    }
  }
  return { where, hash, bytes, figures };
}

async function main() {
  let runtime = readRuntimePin();
  const all = listExamples();
  const selected = only.length ? all.filter((item) => only.includes(item.example.id) || only.includes(item.where)) : all;
  if (only.length && selected.length !== only.length) {
    console.error(`Unknown example in --only: ${only.filter((id) => !all.some((item) => item.example.id === id || item.where === id)).join(", ")}`);
    process.exit(1);
  }
  mkdirSync(OUT, { recursive: true });
  const browser = await chromium.launch({ headless: true, args: CHROMIUM_ARGS, ...(CHROMIUM ? { executablePath: CHROMIUM } : { channel: "chromium" }) });
  const results = [];
  try {
    for (const [index, item] of selected.entries()) {
      if (index > 0) await new Promise((done) => setTimeout(done, GAP_MS));
      if (item.example.kind === "study" && process.env.RUNMAT_CAPTURE_STUDIES !== "sandbox") {
        results.push({ where: item.where, skipped: "study: captured with capture-study.mjs (runmat snapshot)" });
        console.log(`skip ${item.where} (study)`);
        continue;
      }
      if (!runtime || !runtime.runmat?.version || (ACCEPT_RUNTIME && !runtime.accepted)) {
        // The first run of a new runtime records it; later examples must match it.
        runtime = {
          ...(runtime?.studies ? { studies: runtime.studies } : {}),
          accepted: true,
          schemaVersion: 1,
          runmat: { version: process.env.RUNMAT_VERSION ?? sandboxRuntimeVersion(), fingerprint: null },
          device: process.env.RUNMAT_CAPTURE_DEVICE ?? "cpu_reference",
          capturedAt: new Date(Math.floor(Date.now() / 1000) * 1000).toISOString().replace(".000Z", "Z"),
          app: APP,
        };
      }
      try {
        const result = await captureOne(browser, item, runtime);
        if (!runtime.runmat.fingerprint) {
          runtime.runmat.fingerprint = JSON.parse(readFileSync(join(item.dir, PIN_PATH), "utf8")).runmat.fingerprint;
          const { accepted, ...pinned } = runtime;
          writeFileSync(RUNTIME_PATH, `${JSON.stringify(pinned, null, 2)}\n`);
        }
        results.push(result);
        console.log(`ok   ${item.where} ${result.hash.slice(0, 12)} ${(result.bytes / 1024).toFixed(0)} KB, ${result.figures} figure(s)`);
      } catch (error) {
        results.push({ where: item.where, error: error.message });
        console.log(`fail ${item.where}: ${error.message}`);
      }
    }
  } finally {
    await browser.close();
  }
  const failed = results.filter((result) => result.error);
  console.log(`${results.filter((result) => result.hash).length} captured, ${results.filter((result) => result.skipped).length} skipped, ${failed.length} failed`);
  if (failed.length) process.exitCode = 1;
}

await main();
