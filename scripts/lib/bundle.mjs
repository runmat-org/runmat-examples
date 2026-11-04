/*
 * Shared by capture.mjs and validate.mjs: which files make up an example's source, its source hash, and the
 * content-addressed bundle a captured run is published as.
 *
 * A bundle is one example as a complete project: its source files plus the run the app wrote under
 * .artifacts/runs/ and .artifacts/objects/. It is described by project.json, the same inventory the FEA docs
 * examples use (schema_version 1, id, entry, run_manifest, files[{path, bytes, sha256}]). The bundle's hash is
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
export const RUN_MANIFEST = (id) => `.artifacts/runs/${runIdFor(id)}.json`;

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
      else if (rel !== "example.json") files.push({ path: rel, bytes: readFileSync(path) });
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

/** project.json bytes for a bundle, in the docs examples' inventory format. Files are sorted by path. */
export function projectManifest(id, entry, files) {
  const sorted = [...files].sort((a, b) => (a.path < b.path ? -1 : a.path > b.path ? 1 : 0));
  const manifest = {
    schema_version: 1,
    id,
    entry,
    run_manifest: RUN_MANIFEST(id),
    files: sorted.map((file) => ({ path: file.path, bytes: file.bytes.length, sha256: sha256(file.bytes) })),
  };
  return Buffer.from(`${JSON.stringify(manifest, null, 2)}\n`);
}

export function readJsonFile(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}
