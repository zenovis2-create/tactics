# Story Tile Cards Recovery Lane — 2026-05-05 20:11 KST

## Decision

The Agency specialists recommended splitting recovery UI tile cards instead of importing the whole recovery directory.

This lane imports only additive story tile card files from the recovery worktree:

- 17 new 48x48 runtime cards
- matching `.png.import` files
- recovery tile card README
- 6 source/preview PNGs and their `.png.import` files

Existing main cards are intentionally not overwritten.

## Included boundary

Runtime cards:

- `archives.png`
- `ash.png`
- `corridor.png`
- `flooded.png`
- `floodgate.png`
- `gate_control.png`
- `hymn.png`
- `keep.png`
- `keeper.png`
- `marked.png`
- `market.png`
- `memory_abyss.png`
- `revision.png`
- `shadow.png`
- `shrine.png`
- `thicket.png`
- `tunnel.png`

Plus:

- each matching `.png.import`
- `assets/ui/production/tile_cards/README.md`
- `assets/ui/production/tile_cards/sources/**`
- `docs/package_manifests/2026-05-05_story_tile_cards_recovery_lane.md`

## Excluded from this lane

- Existing card overwrites: `bridge.png`, `forest.png`, `highground.png`, `plain.png`, `wall.png`
- `assets/ui/production/tile_icons/**`
- `assets/ui/production/object_icons/**`
- recovery worktree broad imports
- battle_board/runtime contract code changes
- signing/codesign/notarization custody

## Rationale

Main recently promoted forest/wall tile surfaces. Recovery versions differ from current main for several existing cards, so importing the whole directory would risk reverting recent UI asset work.

This first UI recovery slice is additive and inert until future contract/code mapping connects the new story tile cards.

## Validation

Executed before staging:

```bash
rsync -avn --ignore-existing --files-from=/tmp/tile_cards_story_allowlist.txt "$REC/assets/ui/production/tile_cards/" "$MAIN/assets/ui/production/tile_cards/"
rsync -av --ignore-existing --files-from=/tmp/tile_cards_story_allowlist.txt "$REC/assets/ui/production/tile_cards/" "$MAIN/assets/ui/production/tile_cards/"
python3 hash/dimension/import-pair validation
python3 -m py_compile scripts/dev/battle_art_drop_validator.py scripts/dev/build_tile_surface_runtime_package.py
godot --headless --path . --script scripts/dev/imagegen_tile_surface_runtime_runner.gd
git diff --check -- assets/ui/production/tile_cards
```

Results:

```text
allow_count 47
runtime_png_count 17
source_png_count 6
story_tile_cards_validation=PASS
[PASS] imagegen_tile_surface_runtime_runner validated production tile surface texture sizes.
git diff --check=PASS
```

## Follow-up

Recommended next UI recovery lanes:

1. Add/port explicit runtime contract/runner checks for the 17 story cards.
2. Review existing-card replacement candidates separately: `bridge`, `forest`, `highground`, `plain`, `wall`.
3. Review recovery `tile_icons` and `object_icons` separately.
