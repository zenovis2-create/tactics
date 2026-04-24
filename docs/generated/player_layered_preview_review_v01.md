# Player Layered Preview Review V01

## Scope

Reviewed previews:

- [rian_composite_8dir_preview_v03_lighter_armor.png](/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/runtime/8dir/composite_preview/rian_composite_8dir_preview_v03_lighter_armor.png)
- [serin_composite_8dir_preview_v01.png](/Volumes/AI/tactics/assets/characters/sprite_anchor_serin/runtime/8dir/composite_preview/serin_composite_8dir_preview_v01.png)
- [tia_composite_8dir_preview_v02_bgfix.png](/Volumes/AI/tactics/assets/characters/sprite_anchor_tia/runtime/8dir/composite_preview/tia_composite_8dir_preview_v02_bgfix.png)
- [bran_composite_8dir_preview_v02_balanced_shield.png](/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/runtime/8dir/composite_preview/bran_composite_8dir_preview_v02_balanced_shield.png)

## Global Findings

### 1. The layered approach is now readable enough to continue

The four-character board proves that:

- the lanes are separable
- the 8-direction reads are stable enough for production continuation

This is an important threshold.

The work is no longer failing at the system level.

### 2. Overlay dominance still needs active control

The main systemic risk is not direction drift anymore.

It is overlay dominance.

That means:

- weapons
- shields
- upper armor

must be judged by whether they support the lane read or replace it.

## Lane Findings

### `Rian`

Current read:

- command-forward frontline
- now distinct from Bran after shield removal and lighter armor pass

Current judgment:

- acceptable pilot baseline

Residual risk:

- upper armor can still drift too close to heavy lane if it thickens again

### `Serin`

Current read:

- support/healer first
- caster second

Current judgment:

- acceptable support baseline

Residual risk:

- staff overlay is slightly dominant
- future revisions should avoid turning the staff into the entire character read

### `Tia`

Current read:

- ranged hunter first
- lean forest skirmisher second

Current judgment:

- acceptable ranger baseline

Residual risk:

- bow remains very dominant, which is good for class read
- but future upper gear should stay subordinate so the lane does not collapse
  into `weapon + blank body`

### `Bran`

Current read:

- shield-wall heavy defender
- strongest mass and defense-first read in the board

Current judgment:

- acceptable heavy proof baseline

Residual risk:

- shield still dominates strongly
- that is acceptable for proof, but future versions should not bury body and
  armor read any further

## Confirmed Drift Rules

Use these as hard review checks going forward:

1. `Rian` must not become shield-first
2. `Serin` must not become staff-only
3. `Tia` must not become bow-only
4. `Bran` may remain shield-first, but not shield-only

## Working Conclusion

The player layered preview set is now stable enough to continue into enemy lanes.

Future corrections should be lane-specific weight tuning, not structural redesign.
