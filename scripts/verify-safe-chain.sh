#!/usr/bin/env bash
# Canary: prove Aikido Safe Chain is wrapping pnpm and will refuse a known
# malicious package. Fails open (exit 1) if protection is missing or broken —
# that is the point (threat model C6).
#
# Uses Aikido's intentional test package `safe-chain-test` (see
# https://github.com/AikidoSec/safe-chain#verify-the-installation). Never add
# it to this repo's lockfile.
#
# Usage:
#   ./scripts/install-safe-chain.sh --ci   # or local without --ci + shell restart
#   ./scripts/verify-safe-chain.sh
#
# Break-glass check (must go RED without Safe Chain): temporarily take the
# shim off PATH and re-run — install may succeed and this script must fail.

set -euo pipefail

CANARY_PACKAGE="safe-chain-test"
# Version string Safe Chain reports for the npm security placeholder / canary.
CANARY_VERSION="0.0.1-security"

if ! command -v pnpm >/dev/null 2>&1; then
  echo "verify-safe-chain: pnpm not on PATH" >&2
  exit 1
fi

if ! pnpm safe-chain-verify; then
  echo "verify-safe-chain: pnpm is not wrapped by Safe Chain (safe-chain-verify failed)" >&2
  echo "Run ./scripts/install-safe-chain.sh (CI: --ci) and ensure shims/aliases are active." >&2
  exit 1
fi

tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/safe-chain-canary.XXXXXX")"
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT

cd "$tmpdir"
# Isolated manifest — never the monorepo. No lockfile, no workspace.
cat >package.json <<'EOF'
{
  "name": "safe-chain-canary",
  "private": true,
  "version": "0.0.0"
}
EOF

set +e
# Prefer the exact canary version Aikido publishes for this check.
output="$(pnpm add "${CANARY_PACKAGE}@${CANARY_VERSION}" --reporter=append-only 2>&1)"
status=$?
set -e

echo "$output"

if [[ "$status" -eq 0 ]]; then
  echo "verify-safe-chain: FAIL — pnpm install of ${CANARY_PACKAGE} succeeded" >&2
  echo "Safe Chain is not blocking known malware; do not merge or deploy." >&2
  exit 1
fi

# Refuse to treat a random failure (network, registry 500) as a pass.
if ! grep -qiE 'malicious|Safe-chain:.*[Ee]xit' <<<"$output"; then
  echo "verify-safe-chain: FAIL — install exited ${status} but not with a malware block" >&2
  echo "Output did not look like a Safe Chain refusal. Fix the environment; do not ignore." >&2
  exit 1
fi

if [[ -e "node_modules/${CANARY_PACKAGE}" ]]; then
  echo "verify-safe-chain: FAIL — ${CANARY_PACKAGE} is present under node_modules" >&2
  exit 1
fi

echo "verify-safe-chain: OK — Safe Chain blocked ${CANARY_PACKAGE}@${CANARY_VERSION}"
