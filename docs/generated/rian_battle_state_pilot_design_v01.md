# Rian Battle-State Pilot Design V01

## Scope

This document defines the first battle-state production slice built on top of
the locked layered character baseline.

Pilot target:

- `Rian`

States in scope:

- `idle`
- `move`
- `attack`

Not in this pilot:

- `hit`
- `cast`
- full-party rollout

## Why `Rian` Goes First

`Rian` is the cleanest first state pilot because:

- his layered baseline is already the most stable ally baseline
- his class read is body-plus-sword, not FX-led
- his current runtime state sheets already exist as a useful legacy reference

## Hard Rule

This pilot remains subordinate to the layered contract:

1. anchor sheet first
2. all variants derived from anchor
3. consistency beats speed

That means the new state work should derive from:

- `Rian` frozen anchor
- current preferred layered best set

and should not drift back into unrelated monolithic generation.

## Current Upstream Baseline

Use this layered best set as the current state-production baseline:

- `base_body v02_anchor_derived`
- `base_outfit v02_anchor_derived`
- `weapon_overlay v02_anchor_derived`
- `upper_armor_overlay v03_lighter`

Default state composite reference:

- `rian_composite_8dir_preview_v03_lighter_armor`

## Legacy Runtime Reference

Existing old-state sheets remain useful as motion grammar references only:

- `source/rian_idle_sheet_source_v01.png`
- `source/rian_move_sheet_source_v01.png`
- `source/rian_attack_sheet_source_v01.png`
- `clean/rian_idle_clean_v01.png`
- `clean/rian_move_clean_v01.png`
- `clean/rian_attack_clean_v01.png`

Current observed size:

- `1536x1024`

This implies the current legacy state format is:

- 8 frames
- `4 x 2` layout

## State Contract

### `idle`

Read goal:

- controlled frontline command
- stable stance
- no poster-like overacting

Allowed motion:

- subtle cloak or shoulder drift
- minor sword-arm settling
- minimal head or torso shift

### `move`

Read goal:

- tactical grounded locomotion
- mobile frontline swordsman
- not acrobatic

Allowed motion:

- compact stride
- stable sword carry
- readable mantle split movement

### `attack`

Read goal:

- efficient melee action
- quick command-line sword strike
- not heavy knight cleave

Allowed motion:

- body-first attack preparation
- readable sword arc
- restrained follow-through

Must avoid:

- giant slash FX dependence
- anime hero flourish
- heavy-class overcommitment

## Output Shape

Use the existing sheet shape for pilot compatibility:

- `1536x1024`
- 8 frames
- `4 x 2` grid

Suggested file targets:

- `source/rian_idle_sheet_source_v02_layered.png`
- `source/rian_move_sheet_source_v02_layered.png`
- `source/rian_attack_sheet_source_v02_layered.png`

- `clean/rian_idle_clean_v02_layered.png`
- `clean/rian_move_clean_v02_layered.png`
- `clean/rian_attack_clean_v02_layered.png`

Later runtime slices can continue to:

- `runtime/idle/`
- `runtime/move/`
- `runtime/attack/`

## Review Gate

The pilot passes only if:

- `idle` still reads `frontline command`, not generic villager swordsman
- `move` stays grounded and readable at gameplay scale
- `attack` reads lighter and faster than `Bran`
- the sword remains readable without becoming oversized
- the layered baseline remains recognizable through the states

## Working Conclusion

The first state-production slice should be:

1. design `Rian idle / move / attack` around the current layered best set
2. keep old `v01` state sheets as motion references only
3. produce new `v02_layered` state sheets before expanding to other lanes
