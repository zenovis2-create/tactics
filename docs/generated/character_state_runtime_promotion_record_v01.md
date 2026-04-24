# Character State Runtime Promotion Record V01

## Scope

This records the runtime promotion follow-through for:

- `Serin`
- `Tia`
- `Enemy Skirmisher`

Source decision:

- [character_state_runtime_promotion_decision_v01.md](/Volumes/AI/tactics/docs/generated/character_state_runtime_promotion_decision_v01.md)

## Promotion Result

Promoted now:

- `Serin`
- `Tia`
- `Enemy Skirmisher`

Kept as candidate:

- `Rian`
- `Bran`
- `Enemy Raider`

One more fix:

- none

## Runtime Copy Contract

The promoted frames were copied from:

- `runtime_v02_layered_candidate/<state>/`

into:

- `runtime/<state>/`

The candidate folders are retained as the review source and rollback reference.

## Promoted State Sets

### `Serin`

Promoted states:

- `idle`
- `cast`
- `attack`

Runtime target:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/runtime/`

### `Tia`

Promoted states:

- `idle`
- `move`
- `attack`

Runtime target:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/runtime/`

### `Enemy Skirmisher`

Promoted states:

- `idle`
- `move`
- `attack`

Runtime target:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_enemy_skirmisher/runtime/`

## Verification

Post-copy verification checked:

- each promoted state has 8 candidate PNG frames
- each promoted state has 8 matching runtime PNG frames by filename
- SHA-256 hashes match between candidate and promoted runtime frames

Verification result:

- `Serin`: pass
- `Tia`: pass
- `Enemy Skirmisher`: pass

## Working Conclusion

The promotion decision has now been applied for the three safe lanes.

`Rian`, `Bran`, and `Enemy Raider` remain candidate lanes and should not be
promoted automatically without a focused follow-up judgment or micro-fix pass.
