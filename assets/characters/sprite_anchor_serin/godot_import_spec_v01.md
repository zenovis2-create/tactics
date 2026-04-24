# Sprite Anchor Serin Godot Import Spec V01

## Chosen Source Set

Use this combination as the current implementation candidate:

- Idle: `/Volumes/AI/tactics/output/imagegen/sprite_anchor_serin/v02/serin_idle_sheet_v02.png`
- Cast: `/Volumes/AI/tactics/output/imagegen/sprite_anchor_serin/v03/serin_cast_sheet_v03.png`
- Attack: `/Volumes/AI/tactics/output/imagegen/sprite_anchor_serin/v03/serin_attack_sheet_v03.png`

This is the current best balance between:

- gameplay-scale readability
- support-class identity
- restrained FX use
- compatibility with the broader project tone

## Runtime Role

- Character: Serin
- Class lane: healer / support mystic
- Surface: battle sprite animation
- Pipeline: AI concept sheet -> cleanup/slicing -> Godot animation setup

## Recommended Import Strategy

Do not use the full generated sheet image as a runtime sprite directly.
First split the sheet into clean per-frame PNGs or a tightly packed uniform atlas.

Recommended workflow:

1. Clean the chosen source sheets in Krita.
2. Remove excess whitespace.
3. Standardize frame box size across all states.
4. Export per-frame PNGs or one trimmed atlas per state.
5. Import into Godot as animated frames.

## Frame Box Rule

Use a fixed frame size for all Serin battle states.

Recommended initial frame box:

- Width: `256`
- Height: `256`

If the cleaned source requires a tighter box, keep all states identical after trimming.
Do not let each animation use a different logical frame size.

## Pivot Rule

Set the pivot consistently near foot center.

- Horizontal pivot: center of the standing stance
- Vertical pivot: contact point just above the lowest boot edge

The body may sway, but the character must not appear to teleport between frames.

## Animation Names

Use these Godot animation names:

- `idle`
- `cast`
- `attack`
- `hit`

For now only `idle`, `cast`, and `attack` are defined by source sheets.

## Animation Behavior

### `idle`

- Loop: yes
- Target feel: soft breathing + slight hair/sleeve motion
- Recommended playback speed: `6 fps`
- Frame source count target: `6 to 8`

### `cast`

- Loop: no
- Target feel: controlled support spell buildup
- Recommended playback speed: `8 fps`
- Frame source count target: `8 to 10`
- End state: either hold on final cast frame briefly or transition into spell-release logic

### `attack`

- Loop: no
- Target feel: short sacred bolt release, not a heavy spell cannon
- Recommended playback speed: `8 fps`
- Frame source count target: `6 to 8`
- End state: return to idle after projectile spawn

## FX Separation Rule

If possible, separate the following from the body sprite:

- major ward ring
- projectile bolt
- impact burst

Keep only the minimal glow that is necessary to sell the pose inside the body frames.

If separated:

- body animation remains readable alone
- recolor and balancing become easier
- other support units can reuse part of the FX lane

## Directory Proposal

Recommended runtime source structure:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/source/`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/clean/`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/runtime/idle/`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/runtime/cast/`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/runtime/attack/`

## File Naming Rule

Use stable per-frame naming.

Examples:

- `serin_idle_00.png`
- `serin_idle_01.png`
- `serin_cast_00.png`
- `serin_cast_01.png`
- `serin_attack_00.png`
- `serin_attack_01.png`

Use zero-padded indexes.

## Godot Setup Recommendation

Prefer:

- `AnimatedSprite2D` for fast integration

Or:

- `AnimationPlayer` + sprite frame swapping if later logic needs more control

Initial recommendation is `AnimatedSprite2D` because it is the fastest way to validate readability in-engine.

## In-Engine Validation

Check Serin in these conditions:

1. plain tile
2. forest tile
3. cathedral or sacred tile
4. next to knight-class ally
5. next to enemy unit

Success conditions:

- support class reads instantly
- body remains readable over map art
- cast does not become pure FX noise
- attack does not feel heavier than the knight or ranger damage lane

## Next Cleanup Targets

- tighten cast FX even further if it competes with the body
- ensure attack projectile is short and compact after slicing
- reduce sheet whitespace before final atlas export

