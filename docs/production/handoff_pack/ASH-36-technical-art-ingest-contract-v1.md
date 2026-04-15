<!-- paperclip-fastpath:ASH-36:v1 -->
# ASH-36 Technical Art Ingest Contract

## Goal

Define how production battle art should be dropped into the runtime without touching generated fallback assets.

## Source Of Truth

- `/Volumes/AI/tactics/docs/production/handoff_pack/README.md`
- `/Volumes/AI/tactics/docs/production/handoff_pack/battle_art_manifest_v1.json`
- `/Volumes/AI/tactics/docs/production/handoff_pack/battle_art_replacement_checklist_v1.md`

## Production Override Roots

- `/Volumes/AI/tactics/assets/ui/production/button_icons`
- `/Volumes/AI/tactics/assets/ui/production/object_icons`
- `/Volumes/AI/tactics/assets/ui/production/unit_role_icons`
- `/Volumes/AI/tactics/assets/ui/production/unit_token_art`
- `/Volumes/AI/tactics/assets/ui/production/tile_icons`
- `/Volumes/AI/tactics/assets/ui/production/tile_cards`
- `/Volumes/AI/tactics/assets/ui/production/fx`

## Rules

- keep exact filenames from generated bundles
- do not modify generated folders directly
- drop final PNGs into matching production override folder
- runtime prefers production assets first, generated fallback second

## Runtime Loader

- `/Volumes/AI/tactics/scripts/battle/battle_art_catalog.gd`

## Validation

- `/Volumes/AI/tactics/scripts/dev/run_battle_art_ops.sh`
- `/Volumes/AI/tactics/scripts/dev/battle_art_drop_validator.py`

## First Sprint Replacement Matrix

### Unit Tokens
- `unit_token_art`: boss.png, knight.png, medic.png, mystic.png, ranger.png, vanguard.png
- `unit_role_icons`: boss.png, knight.png, medic.png, mystic.png, ranger.png, vanguard.png

### Object Icons
- `object_icons`: chest.png, lever.png, altar.png, gate.png

### FX
- `fx`: hit_spark.png, mark_ring.png, objective_burst.png
