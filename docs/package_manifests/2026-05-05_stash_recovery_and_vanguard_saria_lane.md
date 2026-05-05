# Stash Recovery and Vanguard/Saria Lane — 2026-05-05 15:12:43 KST

## Scope

The Agency-guided continuation after `main` and `origin/main` were synchronized at `89d5015`.

Goals:
- Inspect repository maintenance warning without destructive cleanup.
- Preserve the current `battle_art_catalog.gd` partial recovery change.
- Create an isolated worktree for the large pre-sync stash instead of applying it in main.
- Package the current Vanguard/Saria runtime sprite lane separately.

## Starting state

Repository:
- `/Volumes/AI/tactics`

Remote state:
- `main == origin/main`
- divergence before this lane: `0 0`

Initial dirty state:
- `M scripts/battle/battle_art_catalog.gd`

The diff only added these four mappings:
- `Vanguard -> sprite_anchor_vanguard`
- `ally_vanguard -> sprite_anchor_vanguard`
- `Saria -> sprite_anchor_enemy_saria`
- `enemy_saria -> sprite_anchor_enemy_saria`

The Agency EvidenceQA classified this as substantive runtime sprite routing, not a Godot import side effect.

## Maintenance inspection

`.git/gc.log` contained:

```text
warning: There are too many unreachable loose objects; run 'git prune' to remove them.
```

Read-only maintenance checks:
- loose objects: `64,563`
- loose object size: `2.91 GiB`
- packs: `3`
- pack size: `443.75 MiB`
- garbage files: `7`
- garbage size: `404.62 KiB`
- `git prune --dry-run` count: `34,113`

No destructive prune/gc was run in this lane.

## Stash preservation

Before stash recovery, the one-file `battle_art_catalog.gd` change was protected:

```bash
git diff -- scripts/battle/battle_art_catalog.gd > /tmp/tactics-recovery-safety/battle_art_catalog.pre-stash-recovery.20260505-150848.patch
git stash push -m "protect current battle_art_catalog before pre-sync stash recovery 2026-05-05" -- scripts/battle/battle_art_catalog.gd
```

Result:
- protective stash created at `stash@{0}`
- original pre-sync stash shifted to `stash@{1}`

Current stash stack after protection:
- `stash@{0}`: protect current battle_art_catalog before pre-sync stash recovery 2026-05-05
- `stash@{1}`: pre-sync dirty worktree before origin-main integration 2026-05-05 13:50:02 KST

## Pre-sync stash backup and isolated worktree

Original pre-sync stash identity:
- ref during this lane: `stash@{1}`
- commit: `c0daa9e2f189b9bf97d58e5c932bc8c6cc7ea2b8`
- base parent: `d40a67b package(bark): add f61 f62 post-battle payload boundary`
- untracked parent: `21e2ee4036663a78c5a65a936919460cb18254bd`

Backup branch created:
- `stash-backup/pre-sync-20260505`

Isolated recovery worktree created:
- `/Volumes/AI/tactics-stash-recovery-pre-sync-20260505`
- branch: `stash-recovery/pre-sync-20260505`
- base: `stash@{1}^1`

Apply command:

```bash
git -C /Volumes/AI/tactics-stash-recovery-pre-sync-20260505 stash apply --index 'stash@{1}'
```

Result:
- `apply_exit=0`
- no apply/pop was performed in main
- original pre-sync stash was preserved

Recovery worktree summary after apply:
- modified tracked status entries: `378`
- status lines after short aggregation: `1905`
- untracked files: `34,086`
- large binary/art/script/data/doc payload recovered in isolation

## Vanguard/Saria lane

After isolating stash recovery, the protective `battle_art_catalog.gd` stash was applied back to main and paired with the local Vanguard/Saria runtime assets.

Included lane files:
- `scripts/battle/battle_art_catalog.gd`
- `assets/characters/sprite_anchor_vanguard/**`
- `assets/characters/sprite_anchor_enemy_saria/**`
- `scripts/dev/vanguard_saria_sprite_runtime_runner.gd`
- `scripts/dev/vanguard_saria_sprite_runtime_runner.gd.uid`

Asset counts:
- Vanguard: `505` PNG, `505` `.import`
- Saria: `505` PNG, `505` `.import`

Runner note:
- Initial runner assertion required the first idle sprite frame exactly.
- Saria could advance to another idle frame by the time the assertion ran.
- The runner was tightened to assert the rendered texture is one of the resolved idle sprite frames, while still rejecting token-art fallback.

Validation:
- `godot --headless --path . --script scripts/dev/vanguard_saria_sprite_runtime_runner.gd`: PASS
- `git diff --cached --check`: PASS
- staged allowlist: PASS

Created commit:
- `5b8271c package(asset): add vanguard saria runtime sprites`

## Current state after lane

Main worktree:
- clean after removing a temporary untracked debug runner
- branch: `main`
- remote: `origin/main`
- current local state before push: ahead by `1`

Important preserved refs:
- `stash-backup/pre-sync-20260505`
- `stash-recovery/pre-sync-20260505`
- `/Volumes/AI/tactics-stash-recovery-pre-sync-20260505`
- original pre-sync stash remains preserved as `stash@{1}` while protective stash remains `stash@{0}`

## Next recommendation

1. Push `5b8271c` after final gate.
2. Do not drop either stash until the recovery branch/worktree is reviewed.
3. Continue stash recovery from the isolated worktree by package boundary, not by full merge.
4. Run destructive repository maintenance only after recovery refs are confirmed:
   - `git prune`
   - remove `.git/gc.log`
   - `git gc`
5. Keep signing/public release custody separate.
