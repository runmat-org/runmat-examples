#!/usr/bin/env node
/*
 * Records the source checker's output for every captured FEA study example, as the Desktop guide sees it, into
 * checked-in fixtures that the Desktop readiness spec runs over.
 *
 *   node scripts/capture-source-checks.mjs [--only <id>]... [--app http://localhost:1001] [--out <dir>]
 *
 * For each fea/<id>/ with a captured run (.artifacts/capture.json) it opens the pinned bundle in the sandbox the way
 * a visitor does (signed out, model requests blocked), then asks the sandbox's runtime worker for the same working
 * check the guide uses (feaWorkingCheck on the entry .fea, no editor overlays) and writes the result to
 * <out>/<id>.json. The default <out> is runmat-private/desktop/src/app/components/agent/fixtures/example-source-checks.
 * Geometry previews are dropped; the guide's readiness path does not read them.
 *
 * Rerun it after a runtime update or an example source change, then run the Desktop spec
 * (fea-example-readiness.spec.ts). A solved example whose fixture reports blockers is a guide or checker defect.
 * The script spends no model requests.
 */
import { createRequire } from "node:module";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

import { PIN_PATH, ROOT, listExamples } from "./lib/bundle.mjs";

const args = process.argv.slice(2);
const values = (name) => args.flatMap((arg, index) => (arg === name ? [args[index + 1]] : []));
const option = (name, fallback) => values(name)[0] ?? fallback;
const only = values("--only");
const PRIVATE = resolve(process.env.RUNMAT_PRIVATE_DIR ?? join(ROOT, "../runmat-private"));
const APP = option("--app", "http://localhost:1001").replace(/\/$/, "");
const OUT = resolve(option("--out", join(PRIVATE, "desktop/src/app/components/agent/fixtures/example-source-checks")));
const CHECK_TIMEOUT_MS = 120_000;
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

/** Opens the pinned bundle in the sandbox, as verify-open.mjs --example does. */
async function launch(page, item, pin) {
  const workspace = readFileSync(join(item.dir, ".artifacts/workspace.json"), "utf8");
  await page.goto(`${APP}/sandbox`, { waitUntil: "domcontentloaded" });
  const launchId = `checks-${Date.now().toString(36)}`;
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
  }, { launchId, id: item.example.id, sha256: pin.bundle.sha256, entry: `/${item.example.entry}`, workspace });
  await page.goto(`${APP}/sandbox?workspace=${launchId}`, { waitUntil: "domcontentloaded" });
}

/** One working check through the newest runtime worker, or an error message. */
async function workingCheck(page, root) {
  return page.evaluate(async (root) => {
    const entry = [...window.__captureWorkers].reverse().find((candidate) => /runtime_clients_browser_worker|runtime\/clients\/browser\/worker/.test(candidate.url));
    if (!entry) return { error: "The sandbox runtime worker is not running" };
    const id = 2_400_000_000 + Math.floor(Math.random() * 10_000_000);
    const response = await new Promise((done) => {
      const timer = setTimeout(() => done(null), 30_000);
      const onMessage = (event) => {
        if (event.data?.id !== id || !("success" in event.data)) return;
        clearTimeout(timer);
        entry.worker.removeEventListener("message", onMessage);
        done(event.data);
      };
      entry.worker.addEventListener("message", onMessage);
      entry.worker.postMessage({ kind: "request", id, command: "feaWorkingCheck", payload: { request: { root, overlays: [] } } });
    });
    if (!response) return { error: "the working check timed out" };
    if (!response.success) return { error: response.error?.message ?? "the working check failed" };
    return { result: response.result };
  }, root);
}

/** Retries until the sandbox has installed the bundle and the runtime answers for the entry file. */
async function checkWhenReady(page, root) {
  const deadline = Date.now() + CHECK_TIMEOUT_MS;
  let last = "no answer";
  let previous = null;
  while (Date.now() < deadline) {
    await page.waitForTimeout(3000);
    const { result, error } = await workingCheck(page, root);
    if (result && result.program?.studies?.length + result.program?.sweeps?.length > 0) return result;
    // A file with no runnable root is still an answer once two checks agree after the bundle settled.
    const signature = result ? JSON.stringify(result.diagnostics) : null;
    if (signature && signature === previous) return result;
    previous = signature;
    last = error ?? `status ${result?.status} with no runnable root`;
  }
  throw new Error(`no source check for ${root}: ${last}`);
}

const items = listExamples()
  .filter((item) => item.where.startsWith("fea/") && existsSync(join(item.dir, PIN_PATH)))
  .filter((item) => !only.length || only.includes(item.example.id));
if (!items.length) throw new Error("no captured FEA examples match");
mkdirSync(OUT, { recursive: true });
const browser = await chromium.launch({ executablePath: CHROMIUM });
let failures = 0;
try {
  for (const item of items) {
    const page = await browser.newPage();
    await page.route(/\/v1\/llm\/request/, (route) => route.abort());
    await page.addInitScript(recordWorkers);
    try {
      const pin = JSON.parse(readFileSync(join(item.dir, PIN_PATH), "utf8"));
      await launch(page, item, pin);
      const result = await checkWhenReady(page, item.example.entry);
      const { geometryPreviews: _previews, ...fixture } = result;
      writeFileSync(join(OUT, `${item.example.id}.json`), `${JSON.stringify({ example: item.example.id, entry: item.example.entry, check: fixture }, null, 1)}\n`);
      const errors = result.diagnostics.filter((diagnostic) => diagnostic.severity === "Error").length;
      console.log(`${item.example.id}: ${result.status}${errors ? ` (${errors} error diagnostic${errors === 1 ? "" : "s"})` : ""}`);
    } catch (error) {
      failures += 1;
      console.error(`${item.example.id}: ${error instanceof Error ? error.message : String(error)}`);
    } finally {
      await page.close();
    }
  }
} finally {
  await browser.close();
}
process.exitCode = failures ? 1 : 0;
