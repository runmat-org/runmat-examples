#!/usr/bin/env node
/*
 * Captures the guided-setup agent's first stage for FEA study examples and ships it in the example's run bundle, so
 * opening the example shows that stage without a model request.
 *
 *   node scripts/capture-guide.mjs --only <id> [--only <id>]... [--app http://localhost:1001] [--out <dir>] [--shots <dir>]
 *   node scripts/capture-guide.mjs --only <id> --dry          opens the example with model requests blocked
 *   node scripts/capture-guide.mjs --only <id> --hold         captures and saves the session for review, without publishing
 *   node scripts/capture-guide.mjs --only <id> --from-session <shots>/<id>.guide-session
 *                                                              publishes a session an earlier capture saved, after review
 *
 * For each example it opens the pinned bundle in the sandbox the way a visitor does (signed out), lets the guide run
 * its first turn for real, and waits for the turn to finish. It then reads the guide's session folder out of the
 * sandbox's filesystem worker (.artifacts/agent/sessions/<sessionId>/) and republishes the bundle with those files
 * added next to the run. The run and the sources stay byte for byte the same; only the bundle hash in
 * .artifacts/capture.json changes, and the pin records the session under `guide`.
 *
 * The capture refuses to publish a session whose guide turn failed or was rejected (no question card). It allows one
 * model request per example and blocks any further one, so a capture never loops on paid model calls.
 *
 * The session belongs to the bundle, so the pin's source hash covers it: a source change makes the pin stale, and the
 * example needs a new run capture followed by a new guide capture. capture-study.mjs --from-bundle keeps the session.
 */
import { createRequire } from "node:module";
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { dirname, join, relative, resolve } from "node:path";

import { PIN_PATH, ROOT, bundleLimits, bundleViolations, listExamples, projectManifest, readJsonFile, sha256 } from "./lib/bundle.mjs";

const args = process.argv.slice(2);
const values = (name) => args.flatMap((arg, index) => (arg === name ? [args[index + 1]] : []));
const option = (name, fallback) => values(name)[0] ?? fallback;
const only = values("--only");
const DRY = args.includes("--dry");
const FROM_SESSION = option("--from-session");
// --hold saves the session for review without publishing; publish it afterwards with --from-session.
const HOLD = args.includes("--hold");
const PRIVATE = resolve(process.env.RUNMAT_PRIVATE_DIR ?? join(ROOT, "../runmat-private"));
const APP = option("--app", "http://localhost:1001").replace(/\/$/, "");
const OUT = resolve(option("--out", join(PRIVATE, "website/public/examples-runs")));
const SHOTS = resolve(option("--shots", join(ROOT, ".verify-shots")));
const TURN_TIMEOUT_MS = Number(option("--timeout", "180")) * 1000;
const SESSIONS = "/.artifacts/agent/sessions";
const LIMITS = bundleLimits(PRIVATE);
const require = createRequire(join(PRIVATE, "desktop/package.json"));
const { chromium } = require("playwright");
const CHROMIUM = process.env.CHROMIUM_PATH ?? chromium.executablePath();

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
    const entry = [...window.__captureWorkers].reverse().find((candidate) => /fs_worker|fs\/worker/.test(candidate.url));
    if (!entry) return { error: "The sandbox filesystem worker is not running" };
    const id = 2_200_000_000 + Math.floor(Math.random() * 10_000_000);
    const response = await new Promise((done) => {
      const timer = setTimeout(() => done(null), 20_000);
      const onMessage = (event) => {
        if (event.data?.kind !== "response" || event.data.id !== id) return;
        clearTimeout(timer);
        entry.worker.removeEventListener("message", onMessage);
        done(event.data);
      };
      entry.worker.addEventListener("message", onMessage);
      entry.worker.postMessage({ id, requestId: `guide_${id}`, command, payload });
    });
    if (!response?.success) return { error: response?.error?.message ?? "fs error" };
    const result = response.result;
    return { result: result instanceof ArrayBuffer ? Array.from(new Uint8Array(result)) : result };
  }, { command, payload });
}

async function walk(page, path) {
  const { result, error } = await fsRequest(page, "fs.list", { path });
  if (error) return [];
  const files = [];
  for (const entry of result) {
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

/** The pinned bundle without any shipped guide session, written next to it if needed. Opening a bundle that already
 * carries a session restores that session, so a recapture starts from the run alone. */
function sessionFreeBundle(item, pin) {
  const from = join(OUT, item.example.id, pin.bundle.sha256);
  const inventory = readJsonFile(join(from, "project.json"));
  if (!inventory.files.some((file) => file.path.startsWith(".artifacts/agent/"))) return pin.bundle.sha256;
  const kept = inventory.files
    .filter((file) => !file.path.startsWith(".artifacts/agent/"))
    .map((file) => ({ path: file.path, bytes: readFileSync(join(from, "files", file.path)) }));
  return writeBundle(item, inventory, kept).hash;
}

/** Writes a bundle (once per content hash) and returns its hash and size. */
function writeBundle(item, inventory, files) {
  const manifestBytes = projectManifest(inventory.id, inventory.entry, files);
  const violations = bundleViolations(manifestBytes.length, files, LIMITS);
  if (violations.length) throw new Error(`the bundle is over the app's limits: ${violations.join("; ")}`);
  const hash = sha256(manifestBytes);
  const bundleDir = join(OUT, item.example.id, hash);
  if (!existsSync(join(bundleDir, "project.json"))) {
    const staging = `${bundleDir}.partial`;
    rmSync(staging, { recursive: true, force: true });
    for (const file of files) {
      mkdirSync(dirname(join(staging, "files", file.path)), { recursive: true });
      writeFileSync(join(staging, "files", file.path), file.bytes);
    }
    writeFileSync(join(staging, "project.json"), manifestBytes);
    rmSync(bundleDir, { recursive: true, force: true });
    execFileSync("mv", [staging, bundleDir]);
  }
  const bytes = manifestBytes.length + files.reduce((sum, file) => sum + file.bytes.length, 0);
  return { hash, bytes };
}

/** Opens the pinned bundle, minus any shipped session, in the sandbox, as verify-open.mjs --example does. */
async function launch(page, item, pin) {
  const workspace = readFileSync(join(item.dir, ".artifacts/workspace.json"), "utf8");
  await page.goto(`${APP}/sandbox`, { waitUntil: "domcontentloaded" });
  const launchId = `guide-${Date.now().toString(36)}`;
  await page.evaluate(({ launchId, id, sha256, entry, workspace }) => {
    const now = Date.now();
    localStorage.setItem(`runmat:workspace:${launchId}`, JSON.stringify({
      id: launchId,
      files: [{ path: "/.artifacts/workspace.json", content: workspace }],
      openPath: entry,
      metadata: { source: "verify", exampleId: id, runOnOpen: false, runBundle: { manifestUrl: `/examples-runs/${id}/${sha256}/project.json`, sha256 } },
      createdAt: now,
      expiresAt: now + 600_000,
    }));
  }, { launchId, id: item.example.id, sha256: sessionFreeBundle(item, pin), entry: `/${item.example.entry}`, workspace });
  await page.goto(`${APP}/sandbox?workspace=${launchId}`, { waitUntil: "domcontentloaded" });
}

/** The session files once the guide turn finished and its files stopped changing. */
async function waitForSession(page, modelCalls) {
  const deadline = Date.now() + TURN_TIMEOUT_MS;
  let previous = "";
  while (Date.now() < deadline) {
    await page.waitForTimeout(3000);
    if (modelCalls.started === 0 || modelCalls.finished < modelCalls.started) continue;
    const paths = await walk(page, SESSIONS);
    if (!paths.length) continue;
    const files = [];
    for (const path of paths) files.push({ path: path.replace(/^\//, ""), bytes: await read(page, path) });
    const signature = files.map((file) => `${file.path}:${sha256(file.bytes)}`).join("\n");
    if (signature === previous) return files;
    previous = signature;
  }
  throw new Error(`the guide turn did not finish within ${TURN_TIMEOUT_MS / 1000}s`);
}

/** The session's events, in order. */
function sessionEvents(files) {
  return files
    .filter((file) => /\/event-batches\/[^/]+\.json$/.test(file.path))
    .flatMap((file) => JSON.parse(file.bytes.toString("utf8")))
    .sort((a, b) => a.seq_no - b.seq_no);
}

/** The first stage the guide published: its explanation and the question it asks. */
function firstStage(files) {
  const presentation = sessionEvents(files).map((event) => event.payload?.FeaPresentationAvailable?.presentation).filter(Boolean).at(-1);
  return presentation ?? null;
}

/** Why a captured session cannot ship, or null. Only a completed model request that produced a first stage (a
 * question card, or a summary of a study that needs no answer) ships; a blocked stage is a defect to fix first. */
function sessionProblem(files) {
  const sessions = new Set(files.map((file) => file.path.split("/")[3]));
  if (sessions.size !== 1) return `expected one agent session, found ${sessions.size}`;
  const events = sessionEvents(files);
  const rejected = events.find((event) => /^Study setup response rejected/.test(event.payload?.ModelBlockCompleted?.text ?? ""));
  if (rejected) return `the guide's response was rejected: ${rejected.payload.ModelBlockCompleted.text.slice(0, 1200)}`;
  const requests = events.map((event) => event.payload?.ModelRequestCompleted).filter(Boolean);
  if (requests.length !== 1 || !requests[0].ok) return `the guide's model request failed (${requests.map((request) => request.error).join("; ")})`;
  const stage = firstStage(files);
  if (!stage || stage.disposition === "blocked") return `the guide published no first stage (${stage?.disposition ?? "no presentation"}: ${stage?.explanation ?? ""})`;
  return null;
}

/** Republishes the pinned bundle with the session's files added and updates the pin. */
function publish(item, pin, sessionFiles) {
  const from = join(OUT, item.example.id, pin.bundle.sha256);
  const inventory = readJsonFile(join(from, "project.json"));
  const kept = inventory.files
    .filter((file) => !file.path.startsWith(".artifacts/agent/"))
    .map((file) => ({ path: file.path, bytes: readFileSync(join(from, "files", file.path)) }));
  const files = [...kept, ...sessionFiles];
  const { hash, bytes } = writeBundle(item, inventory, files);
  const sessionId = sessionFiles[0].path.split("/")[3];
  const next = {
    ...pin,
    bundle: { sha256: hash, files: files.length, bytes },
    guide: { sessionId, capturedAt: new Date().toISOString().replace(/\.\d+Z$/, "Z") },
  };
  writeFileSync(join(item.dir, PIN_PATH), `${JSON.stringify(next, null, 2)}\n`);
  return { hash, bytes };
}

const selected = listExamples().filter((item) => item.example.kind === "study" && only.some((name) => name === item.example.id || name === item.where));
if (!selected.length) {
  console.error("Pass --only <id> for each study example to capture.");
  process.exit(1);
}
function readTree(root) {
  const files = [];
  const visit = (dir) => {
    for (const name of readdirSync(dir).sort()) {
      const path = join(dir, name);
      if (statSync(path).isDirectory()) visit(path);
      else files.push({ path: relative(root, path).split("\\").join("/"), bytes: readFileSync(path) });
    }
  };
  visit(root);
  return files;
}

if (FROM_SESSION) {
  if (selected.length !== 1) throw new Error("--from-session publishes one example; pass one --only");
  const [item] = selected;
  const files = readTree(resolve(FROM_SESSION)).filter((file) => file.path.startsWith(".artifacts/agent/sessions/"));
  const problem = sessionProblem(files);
  if (problem) throw new Error(`${item.where}: ${problem}`);
  const { hash, bytes } = publish(item, readJsonFile(join(item.dir, PIN_PATH)), files);
  console.log(`ok   ${item.where} ${hash.slice(0, 12)} ${(bytes / 1024 / 1024).toFixed(1)} MB, ${files.length} session files (from ${FROM_SESSION})`);
  process.exit(0);
}
const browser = await chromium.launch({
  headless: true,
  args: ["--enable-unsafe-webgpu", "--enable-features=Vulkan,WebGPU", "--use-webgpu-adapter=swiftshader", "--use-angle=swiftshader", "--enable-unsafe-swiftshader"],
  ...(CHROMIUM ? { executablePath: CHROMIUM } : { channel: "chromium" }),
});
let failed = 0;
try {
  for (const item of selected) {
    const pin = readJsonFile(join(item.dir, PIN_PATH));
    const context = await browser.newContext({ viewport: { width: 1440, height: 900 }, deviceScaleFactor: 1, colorScheme: "dark" });
    await context.addInitScript(recordWorkers);
    const modelCalls = { started: 0, finished: 0, blocked: 0 };
    // One model request per example; the guide's first turn needs exactly one.
    // The guide's first turn never streams; a streamed request would be a further agent turn.
    await context.route(/\/v1\/llm\/request\/stream(\?|$)/, (route) => { modelCalls.blocked += 1; return route.abort(); });
    await context.route(/\/v1\/llm\/request(\?|$)/, async (route) => {
      if (DRY || modelCalls.started >= 1) {
        modelCalls.blocked += 1;
        return route.abort();
      }
      modelCalls.started += 1;
      try {
        await route.continue();
      } finally {
        // route.continue resolves once the request is sent; the response handler below counts completion.
      }
    });
    const page = await context.newPage();
    page.on("requestfinished", (request) => { if (/\/v1\/llm\/request(\?|$)/.test(request.url())) modelCalls.finished += 1; });
    page.on("requestfailed", (request) => { if (/\/v1\/llm\/request(\?|$)/.test(request.url()) && modelCalls.started > modelCalls.finished) modelCalls.finished += 1; });
    try {
      await launch(page, item, pin);
      if (DRY) {
        await page.waitForTimeout(45_000);
        modelCalls.started = Math.max(modelCalls.started, 1);
        modelCalls.finished = modelCalls.started;
      }
      const files = await waitForSession(page, modelCalls);
      mkdirSync(SHOTS, { recursive: true });
      const shot = join(SHOTS, `${item.example.id}.guide.png`);
      await page.screenshot({ path: shot });
      const dump = join(SHOTS, `${item.example.id}.guide-session`);
      rmSync(dump, { recursive: true, force: true });
      for (const file of files) {
        mkdirSync(dirname(join(dump, file.path)), { recursive: true });
        writeFileSync(join(dump, file.path), file.bytes);
      }
      const problem = sessionProblem(files);
      writeFileSync(join(SHOTS, `${item.example.id}.guide-stage.json`), `${JSON.stringify(firstStage(files), null, 2)}\n`);
      if (DRY || HOLD || problem) {
        if (problem) failed += 1;
        console.log(`${problem ? "fail" : DRY ? "dry " : "held"} ${item.where}: ${problem ?? "not published"}; ${files.length} session files in ${dump}; model requests ${JSON.stringify(modelCalls)}; ${shot}`);
        continue;
      }
      const { hash, bytes } = publish(item, pin, files);
      console.log(`ok   ${item.where} ${hash.slice(0, 12)} ${(bytes / 1024 / 1024).toFixed(1)} MB, ${files.length} session files; model requests ${JSON.stringify(modelCalls)}; ${shot}`);
    } catch (error) {
      failed += 1;
      console.log(`fail ${item.where}: ${error.message}; model requests ${JSON.stringify(modelCalls)}`);
    } finally {
      await context.close();
    }
  }
} finally {
  await browser.close();
}
if (failed) process.exitCode = 1;
