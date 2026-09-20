#!/usr/bin/env bash
# Install Aikido Safe Chain (malware + minimum-package-age gate on pnpm/npm).
#
# Pins a versioned release of the upstream installer and verifies its SHA-256
# before running it. Upstream release URLs are immutable; the checksum is the
# bootstrap trust root for this script.
#
# Usage:
#   ./scripts/install-safe-chain.sh          # local shell aliases (restart terminal after)
#   ./scripts/install-safe-chain.sh --ci     # PATH shims for CI (and writes GITHUB_PATH)
#
# Threat model: docs/technical-spec/23-security-threat-model.md row C6.
# Upstream: https://github.com/AikidoSec/safe-chain

set -euo pipefail

# Bump these two together when moving Safe Chain. Source of truth for the
# checksum: the install command on the matching release's README.
SAFE_CHAIN_RELEASE="1.5.20"
INSTALLER_SHA256="0ad25efe15d1fa56105157a454d647223e78eb0c53d1f85e3d10afcd722e7bfd"

INSTALLER_URL="https://github.com/AikidoSec/safe-chain/releases/download/${SAFE_CHAIN_RELEASE}/install-safe-chain.sh"

ci=0
for arg in "$@"; do
  case "$arg" in
    --ci) ci=1 ;;
    -h | --help)
      sed -n '2,14p' "$0"
      exit 0
      ;;
    *)
      echo "unknown argument: $arg (try --ci)" >&2
      exit 2
      ;;
  esac
done

# Auto-CI when GitHub Actions (or similar) sets CI=true and the caller forgot --ci.
if [[ "${CI:-}" == "true" && "$ci" -eq 0 ]]; then
  ci=1
fi

tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/safe-chain-install.XXXXXX")"
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT

installer="$tmpdir/install-safe-chain.sh"

echo "Downloading Aikido Safe Chain installer ${SAFE_CHAIN_RELEASE}…"
curl -fsSL "$INSTALLER_URL" -o "$installer"

echo "Verifying installer checksum…"
if command -v sha256sum >/dev/null 2>&1; then
  echo "${INSTALLER_SHA256}  ${installer}" | sha256sum -c -
elif command -v shasum >/dev/null 2>&1; then
  echo "${INSTALLER_SHA256}  ${installer}" | shasum -a 256 -c -
else
  echo "neither sha256sum nor shasum found; cannot verify installer" >&2
  exit 1
fi

if [[ "$ci" -eq 1 ]]; then
  sh "$installer" --ci
else
  sh "$installer"
fi

safe_chain_bin="${HOME}/.safe-chain/bin/safe-chain"
if [[ ! -x "$safe_chain_bin" ]]; then
  echo "safe-chain binary missing after install: $safe_chain_bin" >&2
  exit 1
fi

# The upstream installer exits early when the version is already present, which
# skips setup-ci / GITHUB_PATH. Always re-run setup so PATH is correct.
if [[ "$ci" -eq 1 ]]; then
  "$safe_chain_bin" setup-ci
else
  "$safe_chain_bin" setup
fi

export PATH="${HOME}/.safe-chain/shims:${HOME}/.safe-chain/bin:${PATH}"

"$safe_chain_bin" --version

# Verify the wrap only when a real package manager is reachable underneath the
# shim/alias. Fresh machines may install Safe Chain before pnpm — that is fine;
# CONTRIBUTING.md has them install pnpm first, then re-verify.
if command -v pnpm >/dev/null 2>&1; then
  if pnpm safe-chain-verify; then
    :
  else
    echo "pnpm safe-chain-verify failed — is a real pnpm on PATH under the shim?" >&2
    echo "Install pnpm first (see CONTRIBUTING.md), then re-run this script." >&2
    exit 1
  fi
else
  echo "pnpm not on PATH yet; skip wrap verify (install pnpm, then: pnpm safe-chain-verify)"
fi

if [[ "$ci" -eq 0 ]]; then
  cat <<'EOF'

Safe Chain is installed for this machine.
Restart your terminal (or open a new shell) so the pnpm/npm aliases load, then:

  pnpm safe-chain-verify

EOF
fi
