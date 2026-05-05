# Signing/Public Preflight Rerun — 2026-05-05 14:44:39 KST

## Scope

The Agency-guided follow-up after package push.

Purpose:
- Avoid full `stash pop`.
- Restore only the credential-safe preflight helper scripts from `stash@{0}^3`.
- Re-run signing/public release readiness preflights.
- Keep signing/codesign/notarization custody as a separate blocker lane.

## Repository state at start

- Repository: `/Volumes/AI/tactics`
- Branch: `main`
- Remote divergence: `0 0` against `origin/main`
- Existing worktree was not clean at rerun time:
  - 27 `git status --short` entries were present before script restore.
  - Existing dirty work included `scripts/battle/battle_art_catalog.gd`, `scripts/dev/campaign_panel_dialogue_history_runner.gd`, Mira/Rian asset/import work, one review doc, and runner uid/script files.

## The Agency specialist recommendation

Specialists recommended:
- Do not run `git stash pop` or broad `git stash apply`.
- The stash is large and overlaps with current dirty worktree paths.
- Restore only the two missing preflight helpers from the untracked stash parent:
  - `stash@{0}^3:scripts/dev/signing_readiness_report.py`
  - `stash@{0}^3:scripts/dev/public_distribution_preflight.py`

## Action taken

Selected restore only:

```bash
git restore --source='stash@{0}^3' -- \
  scripts/dev/signing_readiness_report.py \
  scripts/dev/public_distribution_preflight.py
```

Validation:

```bash
python3 -m py_compile \
  scripts/dev/signing_readiness_report.py \
  scripts/dev/public_distribution_preflight.py
```

Result:
- `py_compile=PASS`
- No full stash pop/apply was performed.
- `stash@{0}` remains preserved.

## Preflight commands

```bash
python3 scripts/dev/signing_readiness_report.py --root /Volumes/AI/tactics --strict
python3 scripts/dev/public_distribution_preflight.py --root /Volumes/AI/tactics --strict
```

## Results

### Signing readiness

Exit:
- `signing_exit=1`

Counts:
- `BLOCKER=3`
- `WARN=2`
- `INFO=20`
- `PASS=7`

Blockers:
- Android `package/signed` is disabled or unset.
- macOS `codesign/codesign` is disabled or unset.
- macOS `notarization/notarization` is disabled or unset.

Warnings:
- Android SDK `apksigner` not found.
- macOS `notarytool` not found on PATH.

Credential-safety note:
- The helper reports that it does not print secret values, read keystores, query/mutate keychains, create credentials, export builds, or run signing commands.

### Public distribution preflight

Exit:
- `public_exit=1`

Counts:
- `BLOCKER=6`
- `WARN=1`
- `INFO=4`
- `PASS=1`

Blockers:
- Android `package/signed=false`; unsigned APK/AAB is internal-QA only.
- Android `launcher_icons/main_192x192` is empty.
- Android `launcher_icons/adaptive_foreground_432x432` is empty.
- Android `launcher_icons/adaptive_background_432x432` is empty.
- macOS `codesign/codesign=false`; public macOS builds require signing.
- macOS `notarization/notarization=false`; public macOS builds require notarization.

Warning:
- Android `screen/support_small=false`; device exclusion or small-screen validation must be documented before public release.

Pass:
- Godot 4.6.2.stable export templates found.

## Interpretation

- Earlier `exit=2` was an invocation failure caused by missing helper scripts.
- After selected restore, both helpers executed normally.
- Current `exit=1` means the preflight lane is valid and found real release blockers.
- This does not invalidate internal package evidence or the prior package push.
- Public release readiness remains blocked.

## Next lane recommendation

1. Keep `stash@{0}` intact; do not full-pop it into the current dirty worktree.
2. If the two helper scripts should become permanent repo tools, review and commit them as a small separate tooling commit.
3. Resolve public distribution blockers in a dedicated custody lane:
   - Android release signing approval/custody.
   - Android launcher icon assets.
   - Android small-screen support decision or documented exclusion.
   - macOS codesign certificate custody.
   - macOS notarization credential custody.
   - `apksigner` and `notarytool` host setup.
4. Treat actual signing, notarization, keychain/keystore access, and credential handling as operator-approved actions only.
