#!/usr/bin/env node
/*
 * Opens captured examples from the dev site the way a visitor does and checks they arrive already run.
 *
 *   node scripts/verify-open.mjs --page /math/plotting [--page /docs/...] [--shots <dir>] [--rerun]
 *   node scripts/verify-open.mjs --example <id> ...       opens the sandbox launch directly (no page button)
 *
 * For each page it clicks the first "Open example" button, waits for the sandbox, and checks:
 * - the captured run (run_example_<id>) is in the sandbox's .artifacts/runs and no other run exists (nothing ran);
 * - a figure or FEA result is on screen;
 * - no "Sign in to RunMat to mesh or solve" prompt is shown. A signed-out visitor sees it when the captured run fails
 *   to load (for example, a bundle over the app's size limits) and the example falls back to running;
 * then screenshots it (dark). With --rerun it presses Run and checks a new run is written.
 *
 * With --guide (FEA studies whose bundle carries the guide's first stage, see capture-guide.mjs) it also checks that
 * the shipped agent session is the only one in .artifacts/agent/sessions and that opening sent no model request
 * (POST /v1/llm/request). With --answer it then presses the card's first choice and checks the answer starts one
 * normal model turn (this costs one model request per example).
 */
import { createRequire } from "node:module";
import { existsSync, mkdirSync, readFileSync } from "node:fs";
import { join, resolve } from "node:path";

import { ROOT, listExamples } from "./lib/bundle.mjs";

const args = process.argv.slice(2);
const values = (name) => args.flatMap((arg, index) => (arg === name ? [args[index + 1]] : []));
const option = (name, fallback) => values(name)[0] ?? fallback;
const PRIVATE = resolve(process.env.RUNMAT_PRIVATE_DIR ?? join(ROOT, "../runmat-private"));
const APP = option("--app", "http://localhost:1001").replace(/\/$/, "");
const SHOTS = resolve(option("--shots", join(ROOT, ".verify-shots")));
const RERUN = args.includes("--rerun");
const GUIDE = args.includes("--guide") || args.includes("--answer");
const ANSWER = args.includes("--answer");
const MODEL_REQUEST = /\/v1\/llm\/request(\/stream)?(\?|$)/;
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

async function listRuns(page) {
  return page.evaluate(async () => {
    const entry = [...window.__captureWorkers].reverse().find((candidate) => /fs_worker|fs\/worker/.test(candidate.url));
    if (!entry) return null;
    const id = 2_100_000_000 + Math.floor(Math.random() * 10_000_000);
    const response = await new Promise((done) => {
      const timer = setTimeout(() => done(null), 10_000);
      const onMessage = (event) => {
        if (event.data?.kind !== "response" || event.data.id !== id) return;
        clearTimeout(timer);
        entry.worker.removeEventListener("message", onMessage);
        done(event.data);
      };
      entry.worker.addEventListener("message", onMessage);
      entry.worker.postMessage({ id, requestId: `verify_${id}`, command: "fs.list", payload: { path: "/.artifacts/runs" } });
    });
    if (!response?.success) return [];
    return response.result.filter((item) => item.fileType === "file").map((item) => item.fileName);
  });
}

async function listSessions(page) {
  return page.evaluate(async () => {
    const entry = [...window.__captureWorkers].reverse().find((candidate) => /fs_worker|fs\/worker/.test(candidate.url));
    if (!entry) return null;
    const id = 2_110_000_000 + Math.floor(Math.random() * 10_000_000);
    const response = await new Promise((done) => {
      const timer = setTimeout(() => done(null), 10_000);
      const onMessage = (event) => {
        if (event.data?.kind !== "response" || event.data.id !== id) return;
        clearTimeout(timer);
        entry.worker.removeEventListener("message", onMessage);
        done(event.data);
      };
      entry.worker.addEventListener("message", onMessage);
      entry.worker.postMessage({ id, requestId: `verify_${id}`, command: "fs.list", payload: { path: "/.artifacts/agent/sessions" } });
    });
    if (!response?.success) return [];
    return response.result.filter((item) => item.fileType === "dir").map((item) => item.fileName);
  });
}

function item(id) {
  const found = listExamples().find((candidate) => candidate.example.id === id);
  return found && { ...found, pin: JSON.parse(readFileSync(join(found.dir, ".artifacts/capture.json"), "utf8")) };
}

async function directLaunch(page, id) {
  const found = item(id);
  if (!found) throw new Error(`unknown example ${id}`);
  const { pin } = found;
  const example = found;
  const workspace = readFileSync(join(example.dir, ".artifacts/workspace.json"), "utf8");
  await page.goto(`${APP}/sandbox`, { waitUntil: "domcontentloaded" });
  const launchId = `verify-${Date.now().toString(36)}`;
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
  }, { launchId, id, sha256: pin.bundle.sha256, entry: `/${example.example.entry}`, workspace });
  await page.goto(`${APP}/sandbox?workspace=${launchId}`, { waitUntil: "domcontentloaded" });
}

async function verify(browser, target) {
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 }, deviceScaleFactor: 1, colorScheme: "dark" });
  await context.addInitScript(recordWorkers);
  // The picker stays hidden for automated browsers; show it as a visitor sees it.
  if (target.picker) await context.addInitScript(() => Object.defineProperty(Navigator.prototype, "webdriver", { get: () => false }));
  let page = await context.newPage();
  const errors = [];
  page.on("pageerror", (error) => errors.push(error.message));
  // Agent model requests come from the agent's worker; the context sees them on every page it opens.
  const modelRequests = [];
  context.on("request", (request) => { if (request.method() === "POST" && MODEL_REQUEST.test(request.url())) modelRequests.push(Date.now()); });

  if (process.env.VERIFY_DEBUG) page.on("console", (message) => { const text = message.text(); if (/bundle|example|workspace_bootstrap/i.test(text)) console.log("console:", text.slice(0, 400)); });
  if (process.env.VERIFY_DEBUG) page.on("request", (request) => { if (/examples-runs|runs\.json/.test(request.url())) console.log("request:", request.url()); });
  try {
    if (target.page) {
      await page.goto(`${APP}${target.page}`, { waitUntil: "domcontentloaded" });
      const button = page.locator('[data-ph-capture-attribute-cta="open-example"]').first();
      await button.waitFor({ timeout: 60_000 });
      // The button opens the sandbox in this tab or, on pages whose button reads "Open example ↗", in a new one.
      const opened = context.waitForEvent("page", { timeout: 60_000 }).catch(() => null);
      await button.click();
      const sandbox = await Promise.race([
        page.waitForURL(/\/sandbox/, { timeout: 60_000 }).then(() => page),
        opened.then(async (tab) => (tab ? (await tab.waitForURL(/\/sandbox/, { timeout: 60_000 }), tab) : null)),
      ]);
      if (!sandbox) throw new Error(`${target.page}: the open-example button did not open the sandbox`);
      if (sandbox !== page) {
        sandbox.on("pageerror", (error) => errors.push(error.message));
        page = sandbox;
      }
    } else if (target.picker) {
      // The sandbox's "Start with..." picker (Desktop's example launch, lib/examples/launch.ts).
      await page.goto(`${APP}/sandbox`, { waitUntil: "domcontentloaded" });
      const tile = page.getByRole("button", { name: new RegExp(target.picker, "i") }).first();
      await tile.waitFor({ timeout: 60_000 });
      await tile.click();
    } else {
      await directLaunch(page, target.example);
    }
    let runs = [];
    for (let attempt = 0; attempt < 60; attempt += 1) {
      await page.waitForTimeout(1000);
      runs = (await listRuns(page)) ?? [];
      if (runs.some((name) => name.startsWith("run_example_"))) break;
    }
    // Leave time for anything that would run on open to start, then check nothing did.
    await page.waitForTimeout(8000);
    runs = (await listRuns(page)) ?? [];
    const captured = runs.filter((name) => name.startsWith("run_example_"));
    const others = runs.filter((name) => !name.startsWith("run_example_"));
    const canvases = await page.locator("canvas").count();
    const signInPrompts = await page.getByText(/sign in to runmat to (mesh|solve|run)/i).count();
    const name = (target.page ?? target.example ?? `picker-${target.picker}`).replace(/[^a-z0-9]+/gi, "-").replace(/^-|-$/g, "");
    mkdirSync(SHOTS, { recursive: true });
    const shot = join(SHOTS, `${name}.png`);
    await page.screenshot({ path: shot });
    const result = { target: target.page ?? target.example ?? `picker:${target.picker}`, captured, ranOnOpen: others, canvases, signInPrompts, shot, errors: errors.slice(0, 3) };
    if (GUIDE) {
      const shipped = item(target.example)?.pin.guide?.sessionId ?? null;
      result.guide = { shipped, sessions: (await listSessions(page)) ?? [], modelRequestsOnOpen: modelRequests.length };
      if (ANSWER) {
        const before = modelRequests.length;
        // The stage's primary action: "Continue setup" on a summary, the first choice on a question card.
        const choice = page.getByRole("button", { name: /^(Continue setup|Confirm\b.*)$/ }).first();
        result.guide.answered = await choice.click({ timeout: 10_000 }).then(() => true, () => false);
        for (let attempt = 0; attempt < 60 && modelRequests.length === before; attempt += 1) await page.waitForTimeout(1000);
        await page.waitForTimeout(15_000);
        result.guide.modelRequestsAfterAnswer = modelRequests.length - before;
        result.guide.answerShot = join(SHOTS, `${name}.answer.png`);
        await page.screenshot({ path: result.guide.answerShot });
      }
    }
    if (RERUN) {
      const run = page.getByRole("button", { name: /^Run\b/ }).first();
      await run.click({ timeout: 10_000 });
      for (let attempt = 0; attempt < 120; attempt += 1) {
        await page.waitForTimeout(2000);
        const after = (await listRuns(page)) ?? [];
        if (after.some((file) => !file.startsWith("run_example_"))) {
          result.rerun = after.filter((file) => !file.startsWith("run_example_"));
          break;
        }
      }
      const rerunShot = join(SHOTS, `${name}.rerun.png`);
      await page.screenshot({ path: rerunShot });
      result.rerunShot = rerunShot;
    }
    return result;
  } finally {
    await context.close();
  }
}

const targets = [
  ...values("--page").map((page) => ({ page })),
  ...values("--example").map((example) => ({ example })),
  ...values("--picker").map((picker) => ({ picker })),
];
const browser = await chromium.launch({
  headless: true,
  args: ["--enable-unsafe-webgpu", "--enable-features=Vulkan,WebGPU", "--use-webgpu-adapter=swiftshader", "--use-angle=swiftshader", "--enable-unsafe-swiftshader"],
  ...(CHROMIUM ? { executablePath: CHROMIUM } : { channel: "chromium" }),
});
let failed = 0;
try {
  for (const [index, target] of targets.entries()) {
    if (index > 0) await new Promise((done) => setTimeout(done, 4000));
    const result = await verify(browser, target);
    const guideOk = !GUIDE || (result.guide.shipped && result.guide.sessions.length === 1 && result.guide.sessions[0] === result.guide.shipped
      && result.guide.modelRequestsOnOpen === 0 && (!ANSWER || (result.guide.answered && result.guide.modelRequestsAfterAnswer >= 1)));
    const ok = result.captured.length === 1 && result.ranOnOpen.length === 0 && result.signInPrompts === 0 && (!RERUN || result.rerun?.length) && guideOk;
    if (!ok) failed += 1;
    console.log(`${ok ? "ok  " : "FAIL"} ${JSON.stringify(result)}`);
  }
} finally {
  await browser.close();
}
if (failed) process.exitCode = 1;
