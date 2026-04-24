# Sprite Anchor Serin Krita Slicing Guide V01

## Purpose

This guide explains how to convert the chosen Serin source sheets into clean runtime-ready frames.

Use with:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/source/serin_idle_sheet_source_v02.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/source/serin_cast_sheet_source_v03.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/source/serin_attack_sheet_source_v03.png`

## Goal

Produce:

- clean, consistent body frames
- stable foot pivot
- standardized frame box
- optional future separation of large FX

The result should be usable in Godot without per-frame manual offset corrections.

## Working Folders

- input: `source/`
- cleanup stage: `clean/`
- final frame export: `runtime/idle/`, `runtime/cast/`, `runtime/attack/`

## Step 1. Open The Chosen Source Sheet

Open one source sheet in Krita.

Start with:

- idle: `serin_idle_sheet_source_v02.png`
- cast: `serin_cast_sheet_source_v03.png`
- attack: `serin_attack_sheet_source_v03.png`

## Step 2. Build A Uniform Frame Box

Create a guide box and keep it identical across every frame in every state.

Recommended starting box:

- `256 x 256`

If the current source frames need tighter trimming, you may reduce the box later,
but all states must share the same final box size.

## Step 3. Lock The Foot Pivot

Before exporting anything:

- identify the standing contact point near the middle of the boots
- keep that point vertically aligned in every frame
- keep horizontal drift minimal

Rule:

- body motion is allowed
- foot planting drift is not

If a frame looks prettier when shifted but breaks the pivot, keep the pivot.

## Step 4. Remove Excess Whitespace

Do not crop each frame independently.

Instead:

- trim the source visually
- keep the body centered inside the shared frame box
- remove only dead space that does not affect consistency

## Step 5. Clean The Body Silhouette

Prioritize:

- staff shape clarity
- robe edge consistency
- hair outline consistency
- face size consistency

Fix:

- wobbling hand size
- staff head drifting too far between frames
- robe hem changing length unintentionally
- head scale drift

## Step 6. Control The FX

For current Serin sheets:

- idle: keep body only, no extra FX needed
- cast: keep only the smallest amount of support magic needed to explain the pose
- attack: keep only a compact bolt or release spark

If possible, prepare a second cleanup version later with FX separated.

For now:

- body readability is more important than magic spectacle
- if a glow overlaps the face, shrink it
- if a ring hides the robe outline, shrink or remove it

## Step 7. Export Clean Sheets

Recommended cleaned sheet names:

- `clean/serin_idle_clean_v01.png`
- `clean/serin_cast_clean_v01.png`
- `clean/serin_attack_clean_v01.png`

These are still sheet-level assets, not final frame exports.

## Step 8. Slice Into Runtime Frames

Export per-frame PNGs using zero-padded naming.

### Idle

- `runtime/idle/serin_idle_00.png`
- `runtime/idle/serin_idle_01.png`
- `runtime/idle/serin_idle_02.png`
- `runtime/idle/serin_idle_03.png`
- ...

### Cast

- `runtime/cast/serin_cast_00.png`
- `runtime/cast/serin_cast_01.png`
- `runtime/cast/serin_cast_02.png`
- ...

### Attack

- `runtime/attack/serin_attack_00.png`
- `runtime/attack/serin_attack_01.png`
- `runtime/attack/serin_attack_02.png`
- ...

## Step 9. Recommended Frame Count

Do not force all visible panels into runtime.

Use only the strongest ones.

Recommended initial selection:

- idle: `6 to 8` frames
- cast: `8 to 10` frames
- attack: `6 to 8` frames

Cut frames that:

- repeat the same pose
- add only noise
- enlarge FX without improving the action read

## Step 10. In-Engine Check

After exporting:

- place frames in Godot
- test against plain, forest, and sacred tiles
- compare next to a knight-class ally

If any frame becomes unreadable next to the board:

- reduce FX
- simplify silhouette
- do not compensate by increasing glow

## Acceptance Checklist

- same frame box across all states
- same foot pivot across all states
- no accidental per-frame scale drift
- no oversized cast ring swallowing the body
- no attack projectile reading like artillery
- body remains readable before FX

