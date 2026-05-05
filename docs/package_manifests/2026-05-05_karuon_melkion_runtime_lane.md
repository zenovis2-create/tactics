# Karuon/Melkion Runtime Sprite Lane — 2026-05-05 15:57:46 KST

## Scope

The Agency-guided current-main dirty lane processed before the next recovery-worktree package.

Purpose:
- Keep the current Karuon/Melkion runtime sprite work separate from the pre-sync recovery worktree.
- Avoid mixing Enemy Raider recovery payload into the same commit.
- Preserve unit-id-first sprite lookup behavior needed for ally/enemy Melkion display-name collision safety.

## Starting state

Main repository:
- `/Volumes/AI/tactics`
- `main == origin/main`

Dirty files before this lane:
- `scripts/battle/battle_art_catalog.gd`
- `scripts/battle/unit_actor.gd`
- `scripts/dev/battle_sprite_roster_gallery.gd`
- `scripts/dev/battle_sprite_roster_gallery_runner.gd`
- `assets/characters/sprite_anchor_enemy_karuon/**`
- `assets/characters/sprite_anchor_melkion_ally/**`
- `scripts/dev/karuon_melkion_sprite_runtime_runner.gd`
- `scripts/dev/karuon_melkion_sprite_runtime_runner.gd.uid`

## Included package boundary

Runtime assets:
- `assets/characters/sprite_anchor_enemy_karuon/**`
- `assets/characters/sprite_anchor_melkion_ally/**`

Runtime/catalog code:
- `scripts/battle/battle_art_catalog.gd`
- `scripts/battle/unit_actor.gd`

Validation/gallery:
- `scripts/dev/karuon_melkion_sprite_runtime_runner.gd`
- `scripts/dev/karuon_melkion_sprite_runtime_runner.gd.uid`
- `scripts/dev/battle_sprite_roster_gallery.gd`
- `scripts/dev/battle_sprite_roster_gallery_runner.gd`

## Counts

Karuon:
- total files: `1013`
- PNG: `505`
- `.import`: `505`
- JSON: `2`
- `.tres`: `1`

Melkion ally:
- total files: `1013`
- PNG: `505`
- `.import`: `505`
- JSON: `2`
- `.tres`: `1`

Runtime contract checks from EvidenceQA:
- states: `attack`, `cast`, `defeat`, `guard`, `hit`, `idle`, `move`
- each state: flat 8 + facing 64 refs
- missing refs: `0`

## Behavior changes

`battle_art_catalog.gd`:
- Adds Karuon aliases:
  - `Karuon`
  - `enemy_karuon`
  - `enemy_karuon_final`
  - `enemy_karon`
  - `enemy_karon_final`
- Adds Melkion ally aliases:
  - `ally_melkion_ally`
  - `melkion_ally`
- Intentionally does not map plain `Melkion`, because ally/enemy Melkion share the same display name.

`unit_actor.gd`:
- Changes character sprite lookup from display-name-only to unit-id-first with display-name fallback.
- This allows `ally_melkion_ally` to resolve the ally sprite while enemy Melkion remains on fallback until a separate enemy-specific sprite anchor exists.

## Validation

Focused runners:
- `karuon_melkion_sprite_runtime_runner`: PASS
- `battle_sprite_roster_gallery_runner`: PASS
- `character_visual_layer_runner`: PASS

Diff hygiene:
- `git diff --check`: PASS

## Stash/recovery safety

No stash was popped/applied/dropped for this lane.

Preserved recovery state remains:
- `stash@{0}`: protective `battle_art_catalog.gd` stash
- `stash@{1}`: pre-sync dirty worktree stash
- `stash-backup/pre-sync-20260505`
- `/Volumes/AI/tactics-stash-recovery-pre-sync-20260505`

## Next recommendation

1. Commit and push this lane as one atomic Karuon/Melkion runtime package.
2. Then return to recovery worktree package selection.
3. Next candidate remains either:
   - `assets/characters/sprite_anchor_enemy_raider/` runtime refresh, or
   - UI production `tile_cards` package.
4. Keep signing/public release custody separate.
