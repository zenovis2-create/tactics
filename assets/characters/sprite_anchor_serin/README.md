# Sprite Anchor Serin

## Role

This folder is the production workspace for the first 2D battle-sprite anchor for Serin.

## Current Chosen Inputs

- `source/serin_idle_sheet_source_v02.png`
- `source/serin_cast_sheet_source_v03.png`
- `source/serin_attack_sheet_source_v03.png`

## Pipeline

1. `source/`
   Raw chosen sheets from image generation.
2. `clean/`
   Krita-cleaned sheets with whitespace reduction and frame-box preparation.
3. `runtime/idle/`
   Final idle frames or atlas for Godot.
4. `runtime/cast/`
   Final cast frames or atlas for Godot.
5. `runtime/attack/`
   Final attack frames or atlas for Godot.

## Reference Docs

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/spec.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/prompt_pack_v01.md`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/godot_import_spec_v01.md`
- `/Volumes/AI/tactics/docs/character_sprite_pipeline.md`

