# Scout Runtime Recovery Lane — 2026-05-05 15:34:55 KST

## Scope

The Agency-guided continuation from the isolated pre-sync stash recovery work.

Purpose:
- Treat the current Scout dirty state as one package boundary.
- Avoid applying or popping either stash in `main`.
- Commit only explicit Scout/runtime/validation/gallery paths.

## Starting state

Main repository:
- `/Volumes/AI/tactics`
- `main == origin/main`
- dirty worktree contained Scout runtime/package paths and related dev validation/gallery updates.

Preserved recovery state:
- `stash@{0}`: protective `battle_art_catalog.gd` stash
- `stash@{1}`: pre-sync dirty worktree stash
- `stash-backup/pre-sync-20260505`
- `/Volumes/AI/tactics-stash-recovery-pre-sync-20260505`

No stash apply/pop/drop was performed for this lane.

## Included package boundary

Scout runtime assets:
- `assets/characters/sprite_anchor_scout/runtime/**`
- `assets/characters/sprite_anchor_scout/runtime_contract_v02.json`
- `assets/characters/sprite_anchor_scout/source/sheets/scout_idle_8f_sheet_v02_1_guard_imagegen.png`
- `assets/characters/sprite_anchor_scout/source/sheets/scout_idle_8f_sheet_v02_1_guard_imagegen.png.import`
- `assets/characters/sprite_anchor_scout/source/sheets/scout_idle_8f_sheet_v02_1_guard_imagegen_manifest.json`

Runtime/catalog and validation:
- `scripts/battle/battle_art_catalog.gd`
- `scripts/dev/scout_sprite_runtime_runner.gd`
- `scripts/dev/scout_sprite_runtime_runner.gd.uid`
- `scripts/dev/ally_battle_sprite_runner.gd`
- `scripts/dev/character_visual_layer_runner.gd`
- `scripts/dev/character_token_art_runner.gd`
- `scripts/dev/character_animation_ready_runner.gd`

Gallery coverage:
- `scripts/dev/ally_sprite_anchor_gallery.gd`
- `scripts/dev/battle_sprite_roster_gallery.gd`

## Counts

Scout runtime:
- total runtime files: `1009`
- PNG: `504`
- `.import`: `504`
- `.tres`: `1`

Top-level states:
- `attack`: 8 PNG + 8 `.import`
- `cast`: 8 PNG + 8 `.import`
- `defeat`: 8 PNG + 8 `.import`
- `guard`: 8 PNG + 8 `.import`
- `hit`: 8 PNG + 8 `.import`
- `idle`: 8 PNG + 8 `.import`
- `move`: 8 PNG + 8 `.import`

Facing frames:
- 448 PNG + 448 `.import`

PNG/import pairing:
- missing PNG for import: `0`
- missing import for PNG: `0`

## Validation

Focused runners executed before staging:
- `scout_sprite_runtime_runner`: PASS
- `ally_battle_sprite_runner`: PASS
- `character_visual_layer_runner`: PASS
- `character_animation_ready_runner`: PASS
- `character_token_art_runner`: PASS

Diff hygiene:
- `git diff --check`: PASS

## Notes

- `battle_art_catalog.gd` adds Scout and `ally_scout` aliases.
- `ally_battle_sprite_runner.gd` now expects Scout to resolve idle sprite frames.
- character visual/token/animation runners were updated to distinguish real Vanguard/Scout sprite-enabled units from synthetic generic fallback fixtures.
- gallery scripts now include Vanguard/Scout and Saria where applicable.
- Recovery worktree remains the source for future package-boundary review; it was not merged wholesale.

## Next recommendation

1. Commit and push this Scout runtime recovery lane after staged allowlist verification.
2. Continue recovery worktree review by next package boundary, likely UI production assets or existing actor sprite refreshes.
3. Keep both stashes until all required recovery payloads have been reviewed and preserved.
4. Keep signing/public release custody separate.
