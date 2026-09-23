// Coverage vs the latest green main summary artifact.
//
//   pnpm exec tsx scripts/coverage-baseline.ts download --slug <slug> --out <dir>
//   pnpm exec tsx scripts/coverage-baseline.ts compare --current <summary.json> --baseline <summary.json>
//   pnpm exec tsx scripts/coverage-baseline.ts clear-comment --name <report-name> --pr <n>
//
// Floors still gate the merge. This only decides whether to warn on the PR.
// Needs GH_TOKEN (or GITHUB_TOKEN) for download / clear-comment.

import { execFileSync } from "node:child_process";
import { appendFileSync, existsSync, mkdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

type CoverageMetric = {
  total: number;
  covered: number;
  skipped?: number;
  pct?: number | string;
};

type CoverageSummary = {
  total: {
    lines: CoverageMetric;
    statements: CoverageMetric;
    functions: CoverageMetric;
    branches: CoverageMetric;
  };
};

const METRICS = ["lines", "statements", "functions", "branches"] as const;
type Outcome = "ok" | "regression" | "no-baseline";

function usage(): never {
  console.error(`Usage:
  pnpm exec tsx scripts/coverage-baseline.ts download --slug <slug> --out <dir>
  pnpm exec tsx scripts/coverage-baseline.ts compare --current <summary.json> --baseline <summary.json>
  pnpm exec tsx scripts/coverage-baseline.ts clear-comment --name <report-name> --pr <n>`);
  process.exit(2);
}

function parseArgs(argv: string[]): Record<string, string> {
  const out: Record<string, string> = {};
  for (let i = 0; i < argv.length; i++) {
    const flag = argv[i];
    if (!flag?.startsWith("--")) usage();
    const key = flag.slice(2);
    const value = argv[++i];
    if (value === undefined || value.startsWith("--")) usage();
    out[key] = value;
  }
  return out;
}

function requireArg(args: Record<string, string>, key: string): string {
  const value = args[key];
  if (!value) usage();
  return value;
}

function writeOutput(key: string, value: string): void {
  const path = process.env.GITHUB_OUTPUT;
  if (!path) return;
  appendFileSync(path, `${key}=${value}\n`);
}

function annotate(kind: "notice" | "warning", message: string): void {
  console.log(`::${kind}::${message}`);
}

function requireGh(): void {
  try {
    execFileSync("gh", ["--version"], { stdio: "ignore" });
  } catch {
    console.error("coverage-baseline: gh is required");
    process.exit(1);
  }
}

function gh(args: string[], options?: { ignoreError?: boolean }): string {
  try {
    return execFileSync("gh", args, {
      encoding: "utf8",
      stdio: ["ignore", "pipe", options?.ignoreError ? "pipe" : "inherit"],
      env: process.env,
    }).trim();
  } catch (err) {
    if (options?.ignoreError) return "";
    throw err;
  }
}

function isCoverageMetric(value: unknown): value is CoverageMetric {
  if (typeof value !== "object" || value === null) return false;
  const metric = value as Record<string, unknown>;
  return (
    typeof metric.total === "number" && typeof metric.covered === "number"
  );
}

function parseSummary(raw: unknown): CoverageSummary {
  if (typeof raw !== "object" || raw === null) {
    throw new Error("summary is not an object");
  }
  const total = (raw as { total?: unknown }).total;
  if (typeof total !== "object" || total === null) {
    throw new Error("summary.total is missing");
  }
  const totals = total as Record<string, unknown>;
  const lines = totals.lines;
  const statements = totals.statements;
  const functions = totals.functions;
  const branches = totals.branches;
  if (
    !isCoverageMetric(lines) ||
    !isCoverageMetric(statements) ||
    !isCoverageMetric(functions) ||
    !isCoverageMetric(branches)
  ) {
    throw new Error("summary.total metrics are missing or invalid");
  }
  return { total: { lines, statements, functions, branches } };
}

/** True when current covered/total is strictly worse than baseline. */
export function isWorse(
  current: CoverageMetric,
  baseline: CoverageMetric,
): boolean {
  const cTotal = Number(current.total);
  const cCovered = Number(current.covered);
  const bTotal = Number(baseline.total);
  const bCovered = Number(baseline.covered);
  if (![cTotal, cCovered, bTotal, bCovered].every(Number.isFinite)) {
    throw new Error("non-numeric coverage totals");
  }
  // Empty side → vacuously 100%. Both non-empty → integer cross-multiply.
  if (cTotal === 0) return false;
  if (bTotal === 0) return cCovered < cTotal;
  return cCovered * bTotal < bCovered * cTotal;
}

export function compareSummaries(
  current: CoverageSummary,
  baseline: CoverageSummary,
): Outcome {
  for (const metric of METRICS) {
    if (isWorse(current.total[metric], baseline.total[metric])) {
      return "regression";
    }
  }
  return "ok";
}

function readSummary(path: string): CoverageSummary {
  return parseSummary(JSON.parse(readFileSync(path, "utf8")));
}

function download(slug: string, outDir: string): void {
  requireGh();
  mkdirSync(outDir, { recursive: true });
  const artifact = `coverage-baseline-${slug}`;
  const idsRaw = gh([
    "run",
    "list",
    "--branch",
    "main",
    "--workflow",
    "CI",
    "--status",
    "success",
    "--limit",
    "40",
    "--json",
    "databaseId",
    "--jq",
    ".[].databaseId",
  ]);

  if (!idsRaw) {
    console.log("coverage-baseline: no successful CI runs on main yet");
    writeOutput("found", "false");
    return;
  }

  for (const id of idsRaw.split("\n").filter(Boolean)) {
    gh(["run", "download", id, "--name", artifact, "--dir", outDir], {
      ignoreError: true,
    });
    const summaryPath = join(outDir, "coverage-summary.json");
    if (existsSync(summaryPath)) {
      console.log(`coverage-baseline: downloaded ${artifact} from run ${id}`);
      writeOutput("found", "true");
      return;
    }
  }

  console.log(
    `coverage-baseline: no ${artifact} on recent successful main runs`,
  );
  writeOutput("found", "false");
}

function compare(currentPath: string, baselinePath: string | undefined): void {
  if (!existsSync(currentPath)) {
    console.error(`coverage-baseline: current summary missing: ${currentPath}`);
    process.exit(1);
  }

  if (!baselinePath || !existsSync(baselinePath)) {
    writeOutput("outcome", "no-baseline");
    writeOutput("found", "false");
    annotate("notice", "Coverage vs main: no-baseline");
    console.log("coverage-baseline: outcome=no-baseline");
    return;
  }

  let outcome: Outcome;
  try {
    outcome = compareSummaries(
      readSummary(currentPath),
      readSummary(baselinePath),
    );
  } catch (err) {
    console.error(
      `coverage-baseline: ${err instanceof Error ? err.message : String(err)}`,
    );
    process.exit(2);
  }

  writeOutput("found", "true");
  writeOutput("outcome", outcome);
  if (outcome === "regression") {
    annotate("warning", "Coverage vs main: regression");
  } else {
    annotate("notice", "Coverage vs main: ok");
  }
  console.log(`coverage-baseline: outcome=${outcome}`);
}

function clearComment(name: string, pr: string): void {
  requireGh();
  const marker = `<!-- vitest-coverage-report-marker-start-${name} -->`;
  const idsRaw = execFileSync(
    "gh",
    [
      "api",
      `repos/{owner}/{repo}/issues/${pr}/comments`,
      "--paginate",
      "--jq",
      "map(select(.body != null and (.body | contains(env.MARKER)))) | .[].id",
    ],
    {
      encoding: "utf8",
      env: { ...process.env, MARKER: marker },
    },
  ).trim();

  if (!idsRaw) {
    console.log(`coverage-baseline: no prior comment for name=${name}`);
    return;
  }

  for (const id of idsRaw.split("\n").filter(Boolean)) {
    gh(["api", "-X", "DELETE", `repos/{owner}/{repo}/issues/comments/${id}`]);
    console.log(`coverage-baseline: deleted comment ${id}`);
  }
}

function main(): void {
  const [cmd, ...rest] = process.argv.slice(2);
  if (!cmd) usage();
  const args = parseArgs(rest);

  switch (cmd) {
    case "download":
      download(requireArg(args, "slug"), requireArg(args, "out"));
      break;
    case "compare":
      compare(requireArg(args, "current"), args.baseline);
      break;
    case "clear-comment":
      clearComment(requireArg(args, "name"), requireArg(args, "pr"));
      break;
    default:
      usage();
  }
}

void main();
