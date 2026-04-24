# Serin Battle-State Pilot Design V01

## Scope

This document defines the second battle-state production slice built on top of
the locked layered character baseline.

Pilot target:

- `Serin`

States in scope:

- `idle`
- `cast`
- `attack`

Not in this pilot:

- `hit`
- full-party rollout
- full FX pass

## Why `Serin` Goes Second

`Serin` is the correct second pilot because:

- the lane already has a stable layered support/caster baseline
- it tests support-class readability after a frontline pilot
- it forces control over FX dependence and robe/staff separation

## Hard Rule

This pilot remains subordinate to the layered contract:

1. anchor sheet first
2. all variants derived from anchor
3. consistency beats speed

That means the new state work should derive from:

- `Serin` frozen anchor
- current preferred layered best set

and should not drift back into unrelated monolithic generation.

## Current Upstream Baseline

Use this layered best set as the current state-production baseline:

- `base_body v01`
- `base_outfit v01`
- `weapon_overlay v01`
- `upper_armor_overlay v01`

Default state composite reference:

- `serin_composite_8dir_preview_v01`

## Legacy Runtime Reference

Existing old-state sheets remain useful as motion grammar references only:

- `source/serin_idle_sheet_source_v02.png`
- `source/serin_cast_sheet_source_v03.png`
- `source/serin_attack_sheet_source_v03.png`

Current observed size:

- `1536x1024`

This implies the current legacy state format is:

- 8 frames
- `4 x 2` layout

For this pilot, compatibility wins over ideal frame-count expansion.

## State Contract

### `idle`

Read goal:

- support first
- calm sacred-field presence
- no magic required to identify the class

Allowed motion:

- subtle robe settling
- light staff-hand adjustment
- small head or torso drift

### `cast`

Read goal:

- controlled support mystic
- restrained ward-ring or sacred support action
- body still readable without heavy FX

Allowed motion:

- staff-led casting posture
- compact sacred gesture
- light support-ring implication

Must avoid:

- giant spell-circle dominance
- offensive mage spectacle
- body disappearing behind FX

### `attack`

Read goal:

- light support-lane attack
- staff-led strike or compact mystic action
- clearly weaker and calmer than a frontline melee attack

Allowed motion:

- compact staff action
- quick restrained follow-through

Must avoid:

- heroic combat flourish
- heavy melee overcommitment
- offensive-mage blast spectacle

## Output Shape

Use the existing sheet shape for pilot compatibility:

- `1536x1024`
- 8 frames
- `4 x 2` grid

Suggested file targets:

- `source/serin_idle_sheet_source_v02_layered.png`
- `source/serin_cast_sheet_source_v03_layered.png`
- `source/serin_attack_sheet_source_v03_layered.png`

- `clean/serin_idle_clean_v02_layered.png`
- `clean/serin_cast_clean_v03_layered.png`
- `clean/serin_attack_clean_v03_layered.png`

Later runtime slices can continue to:

- `runtime/idle/`
- `runtime/cast/`
- `runtime/attack/`

## Review Gate

The pilot passes only if:

- `idle` still reads support first without FX dependence
- `cast` reads sacred support rather than offensive mage spectacle
- `attack` stays lighter and quieter than `Rian`
- staff remains class-defining at gameplay scale
- layered baseline remains recognizable through the state sheets

## Working Conclusion

The second state-production slice should be:

1. design `Serin idle / cast / attack` around the current layered best set
2. keep old `v02` / `v03` state sheets as motion references only
3. produce new layered state sheets before expanding to `Tia`
