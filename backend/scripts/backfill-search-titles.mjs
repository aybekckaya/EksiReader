import { execFileSync } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { normalizeSearchText } from "../src/utils/search.ts";

const databaseName = "eksi-reader-db";
const mode = process.argv.includes("--remote") ? "--remote" : "--local";

function runWrangler(args) {
  return execFileSync("npx", ["wrangler", ...args], {
    cwd: process.cwd(),
    encoding: "utf8",
    stdio: ["ignore", "pipe", "inherit"],
  });
}

function sqlString(value) {
  return `'${value.replaceAll("'", "''")}'`;
}

const output = runWrangler([
  "d1",
  "execute",
  databaseName,
  mode,
  "--json",
  "--command",
  "SELECT id, title FROM topics WHERE search_title IS NULL;",
]);
const resultSets = JSON.parse(output);
const rows = resultSets.flatMap((result) => result.results ?? []);

if (rows.length === 0) {
  process.stdout.write("Backfill gerektiren topic yok.\n");
  process.exit(0);
}

const statements = rows.map((row) => {
  if (!Number.isSafeInteger(row.id) || typeof row.title !== "string") {
    throw new TypeError("D1 beklenmeyen topic kaydı döndürdü.");
  }
  return `UPDATE topics SET search_title = ${sqlString(normalizeSearchText(row.title))} WHERE id = ${row.id};`;
});
const directory = mkdtempSync(join(tmpdir(), "eksi-reader-backfill-"));
const sqlPath = join(directory, "backfill.sql");

try {
  writeFileSync(sqlPath, [...statements, ""].join("\n"));
  runWrangler([
    "d1",
    "execute",
    databaseName,
    mode,
    "--yes",
    "--file",
    sqlPath,
  ]);
  process.stdout.write(`${rows.length} topic için search_title dolduruldu (${mode}).\n`);
} finally {
  rmSync(directory, { recursive: true, force: true });
}
