# Layered Character Preview Review V01

## Scope

Reviewed previews:

- `/Volumes/AI/tactics/assets/characters/sprite_anchor_rian/runtime/8dir/composite_preview/rian_composite_8dir_preview_v01.png`
- `/Volumes/AI/tactics/assets/characters/sprite_anchor_bran/runtime/8dir/composite_preview/bran_composite_8dir_preview_v01.png`

## Findings

### 1. Shield overlays currently dominate the whole read

This is most obvious on both `Rian` and `Bran`.

The shield is so large and so centered that:

- body read collapses
- outfit read collapses
- directional differences become harder to judge

This defeats the purpose of layered preview as an alignment check.

### 2. `Rian` is drifting toward a shield-bearing heavy read

The current `Rian` composite no longer reads like:

- frontline command
- light sword leadership

It reads too close to:

- a shield-first defender
- Bran's lane logic

That means `Rian shield_overlay` should not be treated as a normal active layer
in the current pilot stack.

### 3. `Bran` proves shield identity, but overstates it

`Bran` still reads as the heavier shield-wall unit, which is correct.

But the preview is still too shield-dominant to judge:

- body mass
- upper armor mass
- weapon role

The shield is proving the lane, but it is obscuring the lane at the same time.

### 4. Composite preview is useful, but the current stack is not review-balanced

The preview did its job:

- it exposed where the overlay balance is wrong

This means the problem is not the idea of composite preview.

The problem is:

- which layers are active in the preview
- how much visual weight those layers carry

## Immediate Design Corrections

### `Rian`

Use this active preview stack:

1. `base_body`
2. `base_outfit`
3. `weapon_overlay`
4. `upper_armor_overlay`

Do not include:

- `shield_overlay`

until a shield-bearing Rian variant is explicitly needed.

### `Bran`

Use this active preview stack:

1. `base_body`
2. `base_outfit`
3. `upper_armor_overlay`
4. `weapon_overlay`
5. `shield_overlay`

But the shield overlay should be regenerated or constrained so it does not erase
the body and armor read from most directions.

## Working Conclusion

The current previews are useful as failure evidence.

They show that:

- `Rian` should remain a non-shield pilot by default
- `Bran` needs shield-proofing, but not shield overload
