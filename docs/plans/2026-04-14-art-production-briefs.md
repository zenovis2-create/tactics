# Ashen Bell Art Production Briefs

## Purpose

Turn the current generated placeholder asset sets into consistent production-ready art bundles without changing runtime contracts.

This document is not about new systems.
It is about replacing existing runtime-loaded assets with better art, while preserving current integration points.

## Global Direction

### Visual Tone

- Tactics SRPG with solemn fantasy-military mood
- Painted-symbolic rather than hyper-detailed
- Strong readability over decorative excess
- Dark board base, bright tactical accents, controlled gold/pale-cyan/pale-violet highlights

### What Must Always Stay True

- Every asset must remain readable at small size
- Ally/enemy/objective distinction must survive compression
- Icons and token art must support mobile-sized viewing
- Visual language must stay consistent across Tutorial, CH03, CH07, CH10

### What To Avoid

- Generic glossy mobile-game polish
- Purple-on-black everywhere
- High-frequency detail that muddies readability
- Realistic rendering style
- Thin-line icons that disappear at small sizes

## Bundle 1: Unit Token Art

### Goal

Make units feel like real tactical pieces instead of colored blocks.

### Current Runtime Targets

- `assets/ui/unit_token_art_generated/*.png`
- `assets/ui/unit_role_icons_generated/*.png`

### Runtime Integration

- `scripts/battle/unit_actor.gd`
- `scenes/battle/Unit.tscn`

### Required Art Outputs

Create a production version for:
- `knight`
- `ranger`
- `mystic`
- `vanguard`
- `medic`
- `boss`

### Size / Format

- PNG
- Transparent background
- Token art: `48x48`
- Small role icon: `28x28`

### Style Notes

- Token art should feel like a tactical crest or miniature banner icon
- Use thick interior silhouette shapes, not outline-only symbols
- Boss emblem should feel heavier and more menacing than standard roles
- Small role icons should visually match the larger token art

### Success Criteria

- Player can distinguish roles without reading text
- Enemy units feel threatening before interaction
- Boss units feel categorically stronger than generic enemies

## Bundle 2: Object Icons

### Goal

Make interactable objects immediately legible and authored.

### Current Runtime Targets

- `assets/ui/object_icons_generated/*.png`

### Runtime Integration

- `scripts/battle/interactive_object_actor.gd`
- `scenes/battle/InteractiveObject.tscn`

### Required Art Outputs

Create a production version for:
- `chest`
- `lever`
- `altar`
- `gate`

### Size / Format

- PNG
- Transparent background
- `40x40`

### Style Notes

- Chest should read as reward/supply
- Lever should read as mechanism/control
- Altar should read as ritual/inspection point
- Gate should read as barrier/access control
- All four should look like parts of the same world

### Success Criteria

- User can identify object type from shape alone
- Object importance is visible before reading label text

## Bundle 3: Combat FX

### Goal

Make battle resolution feel alive.

### Current Runtime Targets

- `assets/ui/fx_generated/hit_spark.png`
- `assets/ui/fx_generated/mark_ring.png`
- `assets/ui/fx_generated/objective_burst.png`

### Runtime Integration

- `scripts/battle/battle_controller.gd`
- `scenes/battle/BattleScene.tscn`

### Required Art Outputs

Create production variants for:
- standard hit spark
- counter-hit spark variant
- boss mark ring
- objective burst

Optional later:
- miss puff
- guard/shield hit
- heal pulse

### Size / Format

- PNG
- Transparent background
- Start at `64x64`

### Style Notes

- Hit spark: pale gold / warm white
- Counter spark: warmer and redder than normal hit
- Boss mark ring: pink-violet, ritual, dangerous
- Objective burst: gold and cleaner than attack FX
- FX should be bright but short-lived, not screen-filling noise

### Success Criteria

- Hits feel sharper immediately
- Boss mark reads as threat, not decoration
- Objective resolution feels rewarding

## Bundle 4: Terrain Overlay Set

### Goal

Make meaningful tiles feel like authored tactical terrain.

### Current Runtime Targets

- `assets/ui/tile_icons_generated/*.png`
- `assets/ui/tile_cards_generated/*.png`

### Runtime Integration

- `scripts/battle/battle_board.gd`

### Priority Terrain Families

Highest priority:
- `forest`
- `wall`
- `highground`
- `battery`
- `cathedral`
- `bell`

Second wave:
- `bridge`
- `floodgate`
- `tunnel`
- `corridor`
- `keeper`
- `archives`
- `marked`
- `market`
- `shrine`
- `hymn`

### Size / Format

- Small icon layer: `24x24`
- Card/background stamp: `48x48`
- PNG with transparency

### Style Notes

- These are not full tilesets
- They are semantic overlays
- Keep silhouettes bold and low-noise
- Small icon and larger card must clearly belong together

### Success Criteria

- Tile meaning is readable even before checking HUD
- Different chapters feel like different spaces, not recolored boards

## Bundle 5: HUD Command Icons

### Goal

Make the command bar feel like a tactical command rail, not debug buttons.

### Current Runtime Targets

- `assets/ui/icons_generated/*.png`

### Runtime Integration

- `scripts/battle/battle_hud.gd`
- `scenes/battle/BattleHUD.tscn`

### Required Art Outputs

- `bag`
- `back`
- `wait`
- `enemy/end-turn`

### Size / Format

- PNG
- Transparent background
- `32x32`

### Style Notes

- Icons should feel military-ui adjacent, not mobile-app generic
- Strong silhouette, few interior details
- Must read on dark buttons at small size

### Success Criteria

- Button purpose is legible at a glance
- Action bar feels more premium and intentional

## Bundle 6: Optional Character Pass

### Goal

Later, move from role-centric tokens to named-character tactical pieces.

### Runtime Integration

- `scenes/battle/Unit.tscn`
- `scripts/battle/unit_actor.gd`

### Future Assets

- Per-character token centers
- Portrait cut-ins for bosses and joins
- Character-specific idle accents

### Why Later

- More asset volume
- Not required to get a strong internal demo

## Handoff Rules

### Deliverable Naming

Keep current filenames until runtime replacement is verified.

That means art should replace:
- `assets/ui/unit_token_art_generated/*.png`
- `assets/ui/unit_role_icons_generated/*.png`
- `assets/ui/object_icons_generated/*.png`
- `assets/ui/fx_generated/*.png`
- `assets/ui/tile_icons_generated/*.png`
- `assets/ui/tile_cards_generated/*.png`
- `assets/ui/icons_generated/*.png`

### If New Files Are Needed

If the art team wants final-named files instead of replacing generated ones, mirror the same folder structure and note the rename plan before integration.

## Review Gate

After each bundle is replaced:

1. Run `scripts/dev/check_runnable_gate0.sh`
2. Run `scripts/dev/m1_playtest_runner.gd`
3. Run `scripts/dev/m3_ui_runner.gd`
4. Run `scripts/dev/render_representative_snapshots.sh`

Then review:
- `tutorial`
- `CH03`
- `CH07`
- `CH10`
- `representative_contact_sheet.png`

## Recommended Art Sprint Order

### Sprint 1

- Unit token art
- Object icons
- Combat FX

### Sprint 2

- Terrain overlays
- HUD command icons

### Sprint 3

- Character-specific token pass
- Backdrop motif replacement
- Full tilemap art exploration

## Fastest Path To "Looks Expensive"

If only one short art sprint is possible, do:

1. Unit token art
2. Object icons
3. Combat FX

That bundle gives the biggest visible improvement with the smallest runtime risk.
