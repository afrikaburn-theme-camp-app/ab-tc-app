# Supply-chain incident response — compromised package

| Field                  | Value                                                                                          |
| ---------------------- | ---------------------------------------------------------------------------------------------- |
| **Category**           | Operational                                                                                    |
| **Doc status**         | Active                                                                                         |
| **Normative language** | RFC 2119 / RFC 8174 applies                                                                    |
| **Requirement IDs**    | N/A — operational runbook, not spec-derived                                                    |
| **Owner / Updated**    | Repo maintainers, 2026-09-20                                                                   |

What to do when a dependency in this repo (direct or transitive) is identified
as **malware**, **compromised**, or otherwise unsafe to keep installed. Complements
[`compliance-and-incident-response.md`](compliance-and-incident-response.md)
(POPIA / account incidents) and the threat matrix in
[`technical-spec/23-security-threat-model.md`](technical-spec/23-security-threat-model.md)
(row C6). Steady-state controls: Aikido Safe Chain, Dependabot cooldown,
[`SECURITY.md`](../SECURITY.md).

This product is **live** with real personal information. Treat a confirmed
malicious package that ran install scripts or had runtime access as a possible
credential and POPIA event until scoped otherwise.

---

## 0. Decide what kind of event this is

| Signal | Treat as |
| ------ | -------- |
| Aikido / Safe Chain / GHSA / vendor advisory: **malware** or **compromised maintainer** on a version we resolve | **This runbook** (full containment) |
| GHSA: vulnerability (RCE, prototype pollution, etc.) but **not** malware | Security bump — Dependabot security PR or manual pin; age-gate bypass only if the fix is &lt;48h old (see §4) |
| Dependabot / audit: outdated package, no exploit path to our data | Ordinary dependency hygiene — not an incident |

If unsure whether install scripts or runtime code could have touched secrets or
PII, escalate to the malware path until proven otherwise.

---

## 1. Contain (same hour)

1. **Do not** re-run `pnpm install` against the bad version to “confirm.” Safe
   Chain should already refuse malware; do not disable Safe Chain to reproduce.
2. **Stop shipping** that tree: pause merges that touch `pnpm-lock.yaml` /
   `package.json` until a clean lockfile is on the branch you will deploy.
3. **Identify the package**: name, version(s), whether direct or transitive,
   and every workspace that pulls it in:
   ```bash
   pnpm why <package-name>
   rg -n '"<package-name>@|"<package-name>":' pnpm-lock.yaml package.json apps/*/package.json packages/*/package.json
   ```
4. **Assume developer machines and CI caches may hold the tarball.** Anyone who
   installed while the bad version was in the lockfile SHOULD wipe
   `node_modules` and the store for that package after the lockfile is fixed
   (see §5). Production Vercel builds use a fresh install per deploy — the
   danger is a **deployed** build that already included the bad tree, plus
   any secrets that install/runtime code could have read.

---

## 2. Scope blast radius

Answer these before declaring “just a dependency bump”:

| Question | Why it matters |
| -------- | -------------- |
| Did a **production** deploy include the bad version? | Triggers secret rotation + POPIA assessment |
| Did the package run **lifecycle scripts** (`preinstall` / `postinstall` / `install`)? | Highest chance of env / token theft on CI and laptops |
| Was it reachable at **runtime** in any of the three apps? | Persistence after install |
| Which secrets exist in the environments that installed it? | `BETTER_AUTH_SECRET`, `PGCRYPTO_KEY`, `DATABASE_URL*`, `RESEND_API_KEY`, blob tokens, `GITHUB_TOKEN` in Actions, Vercel tokens |

Check deploy history (Vercel) against the commit range that introduced the
version. Check `pnpm-lock.yaml` history for when it entered `main`.

---

## 3. Remediate the lockfile

1. Prefer an advisory-known **clean version** (patched release, or last known
   good if the line is abandoned — then replace the dependent).
2. Update deliberately:
   ```bash
   # example — adjust to the real package and range
   pnpm update <package-name>@<safe-version>
   # or edit package.json / overrides, then:
   pnpm install
   ```
3. **`better-auth` / `@better-auth/passkey`**: still never Dependabot-auto.
   Follow the pin process in `SECURITY.md` / `AGENTS.md` — bump the exact
   version in `packages/auth/package.json`, re-green the auth gate and
   `pnpm e2e:local` for auth personas, then merge.
4. Commit **both** manifest and `pnpm-lock.yaml`. Do not hand-edit the lockfile.

---

## 4. Age gate vs malware gate (48h / 2-day rules)

| Control | Security / malware response |
| ------- | --------------------------- |
| Dependabot `cooldown.default-days: 2` | **Does not apply** to Dependabot **security** update PRs — those open immediately |
| Safe Chain **malware** check | **Never bypass.** A version flagged as malware MUST NOT be installed |
| Safe Chain **48h minimum package age** (`.aikido`) | **May** block a brand-new *clean* fix. Bypass age only — see below |

### Temporary age-gate bypass (clean fix younger than 48 hours)

**Local (one shot):**

```bash
pnpm install --safe-chain-skip-minimum-package-age
```

**Or allowlist only the fixed package(s)** in `.aikido` for that PR:

```yaml
safe-chain:
  minimumPackageAgeHours: 48
  npm:
    minimumPackageAgeExclusions:
      - "the-fixed-package"
```

**CI:** for that PR only, set on the install step (revert before or in the
follow-up commit):

```bash
# preferred: skip age, keep malware scanning
pnpm install --frozen-lockfile --safe-chain-skip-minimum-package-age
```

Alternatively `SAFE_CHAIN_MINIMUM_PACKAGE_AGE_HOURS=0` for that job — same
intent; restore `48` / remove the flag after merge.

**MUST NOT:** uninstall Safe Chain, remove the CI install step, or use a skip
flag to force through a **malware-flagged** version.

---

## 5. Clean machines and redeploy

1. On any machine that installed the bad tree:
   ```bash
   rm -rf node_modules
   pnpm store prune   # optional but recommended after malware
   pnpm install       # against the fixed lockfile, Safe Chain on
   ```
2. Merge the clean lockfile to `main` and confirm Vercel deploys all three
   apps from that commit.
3. If production ran the bad version, treat secrets as suspect (§6).

---

## 6. Rotate secrets and assess POPIA (if production or CI was exposed)

If a malicious package ran in **CI** or **production**, or on a maintainer
laptop that held production env files / `vercel env pull` output:

1. Rotate, in coordination across all three Vercel projects where shared:
   - `BETTER_AUTH_SECRET` (forces global re-login — see compliance runbook)
   - `PGCRYPTO_KEY` (severe — see compliance runbook; likely s22 territory)
   - `DATABASE_URL` / `DATABASE_URL_UNPOOLED` (Neon role passwords if applicable)
   - `RESEND_API_KEY`, blob tokens, any GitHub PATs used by humans or Actions
2. Revoke GitHub Actions caches for the repo if a poisoned tarball may sit there.
3. Run the **POPIA s22** assessment in
   [`compliance-and-incident-response.md`](compliance-and-incident-response.md)
   whenever there are reasonable grounds that personal information was
   accessed or acquired. A supply-chain compromise that could read the DB or
   decrypt fields meets that bar until scoped down.
4. Report via the private vulnerability channel only if this is an external
   researcher finding — maintainers coordinate in private; do **not** open a
   public issue with exploit detail while containment is open.

---

## 7. Close out

- [ ] Bad version absent from `pnpm-lock.yaml` on `main`
- [ ] All three apps deployed from the clean commit
- [ ] Age-gate bypass / exclusions **removed**; `.aikido` back to
      `minimumPackageAgeHours: 48`
- [ ] Secrets rotated if exposure was plausible
- [ ] POPIA decision recorded (notify / not notify) with rationale
- [ ] Short incident note for maintainers (what package, versions, commits,
      what was rotated) — private if it contains sensitive timing; public
      advisory only when safe
- [ ] If `better-auth` moved: pin + Dependabot ignore still correct

---

## Quick reference — do / don’t

| Do | Don’t |
| -- | ----- |
| Use Dependabot **security** PRs or a manual pin to a known-clean version | Wait for the 2-day version cooldown when GHSA/malware says move now |
| Skip **age** only for a verified clean young fix | Skip or disable **malware** scanning |
| Rotate shared secrets if prod/CI ran the bad tree | Assume “it was only CI” with a `GITHUB_TOKEN` or env full of production values |
| Wipe `node_modules` after the lockfile is fixed | Reinstall the malicious version to capture samples on a laptop that holds prod keys |

## Related

- Threat model C6:
  [`technical-spec/23-security-threat-model.md`](technical-spec/23-security-threat-model.md)
- Dependabot + cooldown: [`.github/dependabot.yml`](../.github/dependabot.yml)
- Safe Chain install: [`scripts/install-safe-chain.sh`](../scripts/install-safe-chain.sh),
  [`.aikido`](../.aikido)
- Safe Chain canary (CI + local): [`scripts/verify-safe-chain.sh`](../scripts/verify-safe-chain.sh)
  — `pnpm safe-chain:verify`; must stay red if the wrap or malware block dies
- Account / key incidents:
  [`compliance-and-incident-response.md`](compliance-and-incident-response.md)
- Reporting path: [`../SECURITY.md`](../SECURITY.md)
