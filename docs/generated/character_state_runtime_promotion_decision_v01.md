# Character State Runtime Promotion Decision V01

## Scope

Reviewed lanes:

- `Rian`
- `Serin`
- `Tia`
- `Bran`
- `Enemy Raider`
- `Enemy Skirmisher`

Reference reviews:

- [rian_battle_state_pilot_review_v01.md](/Volumes/AI/tactics/docs/generated/rian_battle_state_pilot_review_v01.md)
- [serin_battle_state_pilot_review_v01.md](/Volumes/AI/tactics/docs/generated/serin_battle_state_pilot_review_v01.md)
- [tia_battle_state_pilot_review_v01.md](/Volumes/AI/tactics/docs/generated/tia_battle_state_pilot_review_v01.md)
- [bran_battle_state_pilot_review_v01.md](/Volumes/AI/tactics/docs/generated/bran_battle_state_pilot_review_v01.md)
- [enemy_raider_battle_state_pilot_review_v01.md](/Volumes/AI/tactics/docs/generated/enemy_raider_battle_state_pilot_review_v01.md)
- [enemy_skirmisher_battle_state_pilot_review_v01.md](/Volumes/AI/tactics/docs/generated/enemy_skirmisher_battle_state_pilot_review_v01.md)

## Decision Grid

### Promote Now

- `Serin`
- `Tia`
- `Enemy Skirmisher`

Reason:

- no structural caution remains in the current reviews
- class read is stronger than legacy
- no known issue is strong enough to justify another art pass before promotion

### Keep Candidate

- `Rian`
- `Bran`
- `Enemy Raider`

Reason:

- all three are usable
- but each still carries a light effect-trace caution in attack
- that is small enough to keep as candidate status, but not clean enough to
  auto-promote without a final runtime judgment pass

### One More Fix

- none

Reason:

- no lane currently requires a mandatory blocking correction before it can move
  forward

## Per-Lane Notes

### `Rian`

Status:

- `keep candidate`

Why:

- `idle` and `move` are clearly stronger than legacy
- `attack` still shows a light slash-trace artifact

### `Serin`

Status:

- `promote now`

Why:

- `idle`, `cast`, and `attack` all improve class readability
- no blocking caution remains

### `Tia`

Status:

- `promote now`

Why:

- the ranged-hunter read is clearer than legacy
- no blocking caution remains

### `Bran`

Status:

- `keep candidate`

Why:

- heavy/shield read is materially stronger
- `attack` still carries a light arc/impact caution

### `Enemy Raider`

Status:

- `keep candidate`

Why:

- state lane is now usable
- `attack` still carries a light arc trace

### `Enemy Skirmisher`

Status:

- `promote now`

Why:

- hostile agile read is stable across the three pilot states
- no blocking caution remains

## Working Conclusion

The next correct move is not another broad art pass.

It is:

1. promote `Serin`, `Tia`, and `Enemy Skirmisher` into main runtime
2. leave `Rian`, `Bran`, and `Enemy Raider` in candidate status
3. only then decide whether the remaining three need a tiny cleanup pass
