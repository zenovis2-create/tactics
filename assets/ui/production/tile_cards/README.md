# Tile Cards

Runtime tile card size: `48x48`

The folder is a flat runtime directory consumed by `BattleArtCatalog.load_tile_card()`. Source sheets and previews live under `sources/`.

New story-runtime cards from the 2026-05-03 pass:

- `gate_control.png`
- `floodgate.png`
- `flooded.png`
- `hymn.png`
- `shrine.png`
- `market.png`
- `marked.png`
- `thicket.png`
- `archives.png`
- `keeper.png`
- `shadow.png`
- `revision.png`
- `memory_abyss.png`
- `ash.png`
- `keep.png`
- `corridor.png`
- `tunnel.png`

Source archive:

- `sources/battle_terrain_tiles_v02_story_runtime_a_source.png`
- `sources/battle_terrain_tiles_v02_story_runtime_b_source.png`
- `sources/battle_terrain_tiles_v02_story_runtime_c_source.png`
- `sources/battle_terrain_tiles_v02_story_runtime_d_source.png`
- `sources/battle_terrain_tiles_v02_story_runtime_tunnel_source.png`
- `sources/battle_terrain_tiles_v02_story_runtime_preview.png`

Consumers:

- `scripts/battle/battle_board.gd`
- `scripts/battle/battle_art_catalog.gd`
- `scripts/dev/battle_board_surface_runner.gd`
- `scripts/dev/battle_art_drop_validator.py`

Do not rename runtime PNGs without updating `TERRAIN_OVERLAY_CONTRACTS`, validators, and runners.
