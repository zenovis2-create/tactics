# Ashen Bell Art Replacement Priority

## Goal

Replace generated placeholder visuals in the current battle vertical slice with production art in the order that creates the largest player-facing quality jump for the least integration risk.

This list is ordered by visual impact first, implementation safety second.

## Tier 1: Highest Impact

### 1. Unit Token Art

Replace the generated role/token symbols first.

Current generated assets:
- `assets/ui/unit_token_art_generated/*.png`
- `assets/ui/unit_role_icons_generated/*.png`

Current integration points:
- `scripts/battle/unit_actor.gd`
- `scenes/battle/Unit.tscn`

Why first:
- Units are always on screen.
- Replacing token art changes every battle immediately.
- Better faction/readability/character feel improves the game more than polishing any one map.

Production target:
- One clean emblem per role/class family
- One stronger boss token family
- Optional per-character face/token layer later

### 2. Object Icons

Replace generated chest/lever/altar/gate icons.

Current generated assets:
- `assets/ui/object_icons_generated/*.png`

Current integration points:
- `scripts/battle/interactive_object_actor.gd`
- `scenes/battle/InteractiveObject.tscn`

Why second:
- Objectives and interactables drive the player's eye.
- Better object art makes exploration and gimmick maps feel authored instead of systemic.

Production target:
- Chest icon family
- Lever/control-wheel icon family
- Altar/ritual anchor icon family
- Gate/door icon family

### 3. Hit / Mark / Objective FX

Replace generated burst/ring/spark FX.

Current generated assets:
- `assets/ui/fx_generated/hit_spark.png`
- `assets/ui/fx_generated/mark_ring.png`
- `assets/ui/fx_generated/objective_burst.png`

Current integration points:
- `scripts/battle/battle_controller.gd`
- `scenes/battle/BattleScene.tscn`

Why third:
- These are the first "alive" elements beyond static layout.
- Stronger FX will increase combat feel more than any additional static polish.

Production target:
- Bright melee hit spark
- Pink/purple boss mark ring
- Gold objective resolve burst
- Optional miss/guard variants later

## Tier 2: Very High Impact

### 4. Special Terrain Tile Overlays

Replace generated terrain cards/icons for meaningful tiles.

Current generated assets:
- `assets/ui/tile_icons_generated/*.png`
- `assets/ui/tile_cards_generated/*.png`

Current integration points:
- `scripts/battle/battle_board.gd`

Priority terrain families:
1. `forest`, `wall`, `highground`
2. `cathedral`, `hymn`, `bell`
3. `battery`, `floodgate`, `bridge`
4. `corridor`, `keeper`, `archives`, `tunnel`, `marked`

Why fourth:
- These add map personality and tactical clarity.
- The map already reads better than before, but real tile motifs will remove the last "generated overlay" feeling.

Production target:
- Small top-left terrain pictogram
- Softer larger background terrain stamp
- Keep them low-noise and readable

### 5. Battle HUD Icon Pass

Replace generated action bar icons.

Current generated assets:
- `assets/ui/icons_generated/*.png`

Current integration points:
- `scripts/battle/battle_hud.gd`
- `scenes/battle/BattleHUD.tscn`

Why fifth:
- Helpful, but lower leverage than units/objects/fx.
- The command bar already reads well enough to ship internally.

Production target:
- Bag
- Back
- Wait
- Enemy/end-turn

## Tier 3: Medium Impact

### 6. Board Frame / Border / Ornament Set

Current integration points:
- `scripts/battle/battle_board.gd`

Why:
- Can improve premium feel.
- Lower impact than replacing token/object/fx art.

Production target:
- Better corners
- Better edge filigree
- Better objective ring language

### 7. Ambient Backdrop Motifs

Current integration points:
- `scripts/battle/battle_board.gd`

Why:
- Helps mood, but the current procedural backdrop is already serviceable.
- This should follow tile/object/token replacement, not precede it.

Production target:
- CH03 forest silhouettes
- CH07 ritual arches / icons
- CH10 tower rings / eclipse geometry

## Tier 4: Later

### 8. Character-Specific Tokens / Portrait Cut-ins

Current integration points:
- `scenes/battle/Unit.tscn`
- `scripts/battle/unit_actor.gd`
- `scripts/battle/battle_hud.gd`
- campaign/cutscene UI files later

Why later:
- High payoff, but much more art volume.
- Role-based token art is enough for the next stage.

### 9. Full Tileset Replacement

Current integration points:
- mostly `scripts/battle/battle_board.gd`, or future tilemap-driven art path

Why later:
- Biggest art workload
- Might imply moving from procedural board rendering to mixed/procedural+tilemap rendering
- Better done after the visual language is locked

## Recommended Replacement Order

1. Unit token art set
2. Object icon set
3. Combat FX set
4. Terrain overlay set
5. HUD icon set
6. Frame/ornament polish
7. Ambient backdrop polish
8. Character-specific token pass
9. Full tileset pass

## Fastest "Looks Much Better" Package

If only one short art sprint is possible, do this bundle:

1. Replace `unit_token_art_generated`
2. Replace `object_icons_generated`
3. Replace `fx_generated`

That package will give the biggest visible jump with the least code risk.

## File Map

### Replace These Assets First

- `assets/ui/unit_token_art_generated/*.png`
- `assets/ui/unit_role_icons_generated/*.png`
- `assets/ui/object_icons_generated/*.png`
- `assets/ui/fx_generated/*.png`

### Then Replace

- `assets/ui/tile_icons_generated/*.png`
- `assets/ui/tile_cards_generated/*.png`
- `assets/ui/icons_generated/*.png`

### Runtime Integration Files To Watch

- `scripts/battle/unit_actor.gd`
- `scenes/battle/Unit.tscn`
- `scripts/battle/interactive_object_actor.gd`
- `scenes/battle/InteractiveObject.tscn`
- `scripts/battle/battle_controller.gd`
- `scenes/battle/BattleScene.tscn`
- `scripts/battle/battle_board.gd`
- `scripts/battle/battle_hud.gd`
- `scenes/battle/BattleHUD.tscn`

## Gate

After any art replacement batch, rerun:

- `scripts/dev/check_runnable_gate0.sh`
- `scripts/dev/m1_playtest_runner.gd`
- `scripts/dev/m3_ui_runner.gd`
- `scripts/dev/render_representative_snapshots.sh`

The representative snapshots remain the visual regression gate:
- `tutorial`
- `CH03`
- `CH07`
- `CH10`
