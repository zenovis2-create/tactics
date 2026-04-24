# Layered Enemy Preview Review V03

## Scope

Review targets:

- `Enemy Raider`
- `Enemy Skirmisher`

Reference board:

- `/Volumes/AI/tactics/docs/generated/roster_layered_preview_board_v03_raider_sword_led.png`

## Verdict

The `Raider` weapon-only correction improved the lane enough to stop the
worst `crossbow-wall` failure mode.

Current state:

- `Enemy Skirmisher` remains the stronger enemy baseline
- `Enemy Raider` is now closer to a usable hostile melee baseline, but still
  carries more chest-heavy front mass than ideal

## Findings

### 1. `Enemy Raider` improved materially

The new sword-led overlay fixed the largest prior failure:

- the lane no longer reads primarily as a ranged-machine barricade

Improved:

- front read is more clearly melee-coded
- weapon mass is less dominant
- the lane is closer to `hostile melee pressure`

Remaining issue:

- armor front still feels a bit too dense and plate-heavy relative to the ally
  set
- the lane is usable, but not yet as clean as `Rian` or `Skirmisher`

### 2. `Enemy Skirmisher` remains acceptable

The corrected skirmisher set still holds.

Current best read:

- hostile agile pursuit hunter
- disciplined hostile cloth coverage
- distinct from `Tia`

No further correction is required right now.

## Current Promotion Guidance

### `Enemy Raider`

Current best set:

- `base_body v01`
- `base_outfit v01`
- `weapon_overlay v03_sword_led`
- `upper_armor_overlay v02_compact`

Judgment:

- usable provisional hostile melee baseline
- may still benefit from one later armor-lightening pass
- does not block moving forward anymore

### `Enemy Skirmisher`

Current best set:

- `base_body v01`
- `base_outfit v02_disciplined`
- `weapon_overlay v02_clean`
- `upper_armor_overlay v02_light`

Judgment:

- acceptable current hostile agile baseline

## Working Conclusion

The enemy correction pass is now sufficient to move forward.

Next correct move:

1. keep current enemy best-set files as active preview candidates
2. update handoff/summary with the current enemy preview status
3. move on to the next production slice instead of over-polishing enemy lanes
