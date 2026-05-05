# Core Ally Runtime Sprite Lane — 2026-05-05 16:39 KST

## Decision

The Agency specialists recommended closing the current main dirty character runtime lane before importing UI/recovery worktree assets.

This lane packages the v02.1 runtime sprite refresh for the four core allies: Rian, Serin, Tia, and Bran.

## Included boundary

- `assets/characters/sprite_anchor_rian/runtime/**`
- `assets/characters/sprite_anchor_rian/runtime_contract_v02.json`
- `assets/characters/sprite_anchor_rian/source/sheets/**`
- `assets/characters/sprite_anchor_serin/runtime/**`
- `assets/characters/sprite_anchor_serin/runtime_contract_v02.json`
- `assets/characters/sprite_anchor_serin/source/sheets/**`
- `assets/characters/sprite_anchor_tia/runtime/**`
- `assets/characters/sprite_anchor_tia/runtime_contract_v02.json`
- `assets/characters/sprite_anchor_tia/source/sheets/**`
- `assets/characters/sprite_anchor_bran/runtime/**`
- `assets/characters/sprite_anchor_bran/runtime_contract_v02.json`
- `assets/characters/sprite_anchor_bran/source/sheets/**`
- `scripts/battle/battle_art_catalog.gd`
- `scripts/dev/ally_core_sprite_runtime_runner.gd`
- `scripts/dev/ally_core_sprite_runtime_runner.gd.uid`
- `docs/package_manifests/2026-05-05_core_ally_runtime_lane.md`

## Excluded from this lane

- UI production/tile card recovery
- environment surface assets
- broad recovery worktree contents
- signing/codesign/notarization custody
- stash cleanup

## Static evidence

The current dirty state is a coherent four-character runtime lane:

- Rian: 24 tracked PNG updates + 971 untracked v02 runtime/source/contract files
- Serin: 24 tracked PNG updates + 971 untracked v02 runtime/source/contract files
- Tia: 24 tracked PNG updates + 971 untracked v02 runtime/source/contract files
- Bran: 24 tracked PNG updates + 971 untracked v02 runtime/source/contract files

Runtime contract pattern:

- `direction_set`: `diagonal_4`
- states: `idle`, `move`, `attack`, `cast`, `hit`, `guard`, `defeat`
- flat state frames: 8 PNG per state
- facing frames: 4 facings x 16 frames per state
- PNG/import pairing: no missing pair reported by EvidenceQA

## Validation

Executed before staging with current worktree content:

```bash
godot --headless --path . --script scripts/dev/ally_core_sprite_runtime_runner.gd
godot --headless --path . --script scripts/dev/ally_battle_sprite_runner.gd
godot --headless --path . --script scripts/dev/battle_sprite_roster_gallery_runner.gd
git diff --check
```

Results:

```text
core_exit=0
[PASS] ally_core_sprite_runtime_runner validated Rian/Serin/Tia/Bran v02.1 sprite runtimes.

ally_exit=0
[PASS] ally_battle_sprite_runner validated ally sprite-first frame resolution.

roster_exit=0
[PASS] battle_sprite_roster_gallery_runner validated ally/enemy roster gallery loading.
```

## Risk note

The package contains a large number of PNG and `.png.import` files. Staging must remain explicit and allowlisted. Do not use broad `git add .`, `git add -A`, or `git add assets/`.
