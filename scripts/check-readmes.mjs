#!/usr/bin/env node
/*
 * Checks every example README against the template: node scripts/check-readmes.mjs [--require]
 *
 * For each example folder with a README.md:
 *   - the first line is the "# " title;
 *   - when the example has a dark thumbnail, the next nonblank line is the Open in RunMat badge linking to
 *     https://runmat.com/sandbox?example=<its id>, with &run=0 for an FEA study;
 *   - it has "## Files" and "## Related" sections, Related is last, and Related's last item is Download RunMat;
 *   - every relative link and image points at a file or folder that exists.
 * With --require, an example without a README.md is an error too. validate.mjs runs this check.
 */
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const BADGE = "https://runmat.com/badges/open-in-runmat.svg";
const DOWNLOAD = "- [Download RunMat](https://runmat.com/download)";
const REQUIRE = process.argv.includes("--require");

const isDir = (path) => existsSync(path) && statSync(path).isDirectory();
const errors = [];

for (const group of readdirSync(ROOT).sort()) {
  if (group.startsWith(".") || ["scripts", "node_modules"].includes(group) || !isDir(join(ROOT, group))) continue;
  for (const name of readdirSync(join(ROOT, group)).sort()) {
    const dir = join(ROOT, group, name);
    if (!existsSync(join(dir, "example.json"))) continue;
    const where = `${group}/${name}`;
    const readmePath = join(dir, "README.md");
    if (!existsSync(readmePath)) {
      if (REQUIRE) errors.push(`${where}: no README.md`);
      continue;
    }
    const record = JSON.parse(readFileSync(join(dir, "example.json"), "utf8"));
    const text = readFileSync(readmePath, "utf8");
    const lines = text.split("\n");
    if (!lines[0].startsWith("# ")) errors.push(`${where}: README.md must start with its "# " title`);
    const next = lines.slice(1).find((line) => line.trim() !== "") ?? "";
    if (existsSync(join(dir, ".artifacts", "thumbnail.webp"))) {
      const query = `example=${record.id}${record.kind === "study" ? "&run=0" : ""}`;
      const expected = `[![Open in RunMat](${BADGE})](https://runmat.com/sandbox?${query})`;
      if (next.trim() !== expected) errors.push(`${where}: the line under the title must be ${expected}`);
    } else if (next.includes(BADGE)) {
      errors.push(`${where}: no thumbnail, so the app catalog skips it; leave the Open in RunMat badge out until it is captured`);
    }
    const headings = lines.filter((line) => line.startsWith("## ")).map((line) => line.slice(3).trim());
    for (const required of ["Files", "Related"]) {
      if (!headings.includes(required)) errors.push(`${where}: README.md has no "## ${required}" section`);
    }
    if (headings.length && headings[headings.length - 1] !== "Related") errors.push(`${where}: "## Related" must be the last section`);
    const related = text.split("\n## Related\n")[1];
    if (related !== undefined) {
      const items = related.split("\n").filter((line) => line.startsWith("- "));
      if (items[items.length - 1] !== DOWNLOAD) errors.push(`${where}: Related must end with ${DOWNLOAD}`);
    }
    // Relative links and images: [text](path), ![alt](path), src="path", srcset="path". Code is skipped.
    const prose = text.replace(/```[\s\S]*?```/g, "").replace(/`[^`\n]*`/g, "");
    const targets = [
      ...[...prose.matchAll(/\]\(([^)\s]+)\)/g)].map((m) => m[1]),
      ...[...prose.matchAll(/\b(?:src|srcset|href)="([^"]+)"/g)].map((m) => m[1]),
    ];
    for (const target of targets) {
      if (/^(https?:|mailto:|#)/.test(target)) continue;
      const path = resolve(dir, decodeURI(target.split("#")[0]));
      if (!existsSync(path)) errors.push(`${where}: link target ${target} does not exist`);
    }
  }
}

for (const error of errors) console.error(`error: ${error}`);
if (errors.length) {
  console.error(`${errors.length} README error(s)`);
  process.exit(1);
}
console.log("example READMEs follow the template");
