# Character 8Dir Generation Queue V01

## Purpose

This queue lists the six currently prepared character lanes for 8-direction image generation.

It is the handoff surface for actual image creation.

## Queue Order

1. `Rian`
2. `Serin`
3. `Tia`
4. `Bran`
5. `Enemy Raider`
6. `Enemy Skirmisher`

## Lane Targets

### `Rian`

- brief: [sprite_anchor_rian/8dir_production_brief_v01.md](/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/8dir_production_brief_v01.md)
- prompt pack: [sprite_anchor_rian/8dir_prompt_pack_v01.md](/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/8dir_prompt_pack_v01.md)
- output root: `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian`

### `Serin`

- brief: [sprite_anchor_serin/8dir_production_brief_v01.md](/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/8dir_production_brief_v01.md)
- prompt pack: [sprite_anchor_serin/8dir_prompt_pack_v01.md](/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/8dir_prompt_pack_v01.md)
- output root: `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin`

### `Tia`

- brief: [sprite_anchor_tia/8dir_production_brief_v01.md](/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/8dir_production_brief_v01.md)
- prompt pack: [sprite_anchor_tia/8dir_prompt_pack_v01.md](/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/8dir_prompt_pack_v01.md)
- output root: `/Volumes/AI/tactics/assets/characters/sprite_anchor_tia`

### `Bran`

- brief: [sprite_anchor_bran/8dir_production_brief_v01.md](/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/8dir_production_brief_v01.md)
- prompt pack: [sprite_anchor_bran/8dir_prompt_pack_v01.md](/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/8dir_prompt_pack_v01.md)
- output root: `/Volumes/AI/tactics/assets/characters/sprite_anchor_bran`

### `Enemy Raider`

- brief: [sprite_anchor_enemy_raider/8dir_production_brief_v01.md](/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/8dir_production_brief_v01.md)
- prompt pack: [sprite_anchor_enemy_raider/8dir_prompt_pack_v01.md](/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider/8dir_prompt_pack_v01.md)
- output root: `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_raider`

### `Enemy Skirmisher`

- brief: [sprite_anchor_enemy_skirmisher/8dir_production_brief_v01.md](/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/8dir_production_brief_v01.md)
- prompt pack: [sprite_anchor_enemy_skirmisher/8dir_prompt_pack_v01.md](/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/8dir_prompt_pack_v01.md)
- output root: `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher`

## Required Outputs Per Lane

For each lane:

- `source/8dir/*_front_source_v01.png`
- `source/8dir/*_front_right_source_v01.png`
- `source/8dir/*_right_source_v01.png`
- `source/8dir/*_back_right_source_v01.png`
- `source/8dir/*_back_source_v01.png`
- `source/8dir/*_back_left_source_v01.png`
- `source/8dir/*_left_source_v01.png`
- `source/8dir/*_front_left_source_v01.png`

Then:

- `clean/8dir/*_<view>_clean_v01.png`
- `runtime/8dir/*_<view>_runtime_v01.png`

## Working Conclusion

All six lanes are now prompt-ready and folder-ready for eight-direction generation.

The remaining step is actual image generation.
