# Ashen Bell Artist Handoff One-Pager

## What This Is

A direct handoff sheet for replacing the current generated battle visuals with production art.

Use this together with:
- `/Volumes/AI/tactics/docs/plans/2026-04-14-art-replacement-priority.md`
- `/Volumes/AI/tactics/docs/plans/2026-04-14-art-production-briefs.md`

This page is the short version meant for actual production kickoff.

## Product Read

Ashen Bell is a tactics RPG with:
- dark battlefield boards
- symbolic tactical pieces
- solemn fantasy-military mood
- readable objectives and threat language
- chapter-specific atmosphere:
  - Tutorial: breach line / supply recovery
  - CH03: forest reconnaissance
  - CH07: ritual city / sermon threat
  - CH10: final tower / end-state pressure

## Immediate Goal

Replace the current placeholder/generated art in the battle vertical slice so the game feels authored, readable, and premium without changing the current runtime contracts.

## Art Style

### Do

- Use bold readable silhouettes
- Prefer painted-symbolic forms over realism
- Make shapes legible at small size
- Keep ally, enemy, objective, and terrain languages clearly distinct
- Make the game feel melancholic, controlled, and tactical

### Do Not

- Do not use generic glossy mobile UI style
- Do not use noisy detail that disappears at gameplay scale
- Do not make icons too thin
- Do not make every chapter look like the same board with a tint swap
- Do not overcomplicate FX

## Priority Order

### 1. Unit Tokens

Replace first.

Files currently in use:
- `/Volumes/AI/tactics/assets/ui/unit_token_art_generated/*.png`
- `/Volumes/AI/tactics/assets/ui/unit_role_icons_generated/*.png`

Needed:
- knight
- ranger
- mystic
- vanguard
- medic
- boss

Target feel:
- real tactical pieces
- readable from a distance
- boss feels categorically different

### 2. Object Icons

Replace second.

Files currently in use:
- `/Volumes/AI/tactics/assets/ui/object_icons_generated/*.png`

Needed:
- chest
- lever
- altar
- gate

Target feel:
- objective points look authored
- exploration maps feel intentional

### 3. Combat FX

Replace third.

Files currently in use:
- `/Volumes/AI/tactics/assets/ui/fx_generated/hit_spark.png`
- `/Volumes/AI/tactics/assets/ui/fx_generated/mark_ring.png`
- `/Volumes/AI/tactics/assets/ui/fx_generated/objective_burst.png`

Needed:
- hit spark
- boss mark ring
- objective burst

Target feel:
- hits feel sharp
- mark feels threatening
- objective completion feels rewarding

### 4. Terrain Overlays

Replace fourth.

Files currently in use:
- `/Volumes/AI/tactics/assets/ui/tile_icons_generated/*.png`
- `/Volumes/AI/tactics/assets/ui/tile_cards_generated/*.png`

Most important terrain:
- forest
- wall
- highground
- battery
- cathedral
- bell
- bridge

Target feel:
- terrain meaning should be readable before reading HUD

### 5. HUD Command Icons

Replace fifth.

Files currently in use:
- `/Volumes/AI/tactics/assets/ui/icons_generated/*.png`

Needed:
- bag
- back
- wait
- enemy/end-turn

Target feel:
- command rail
- not debug buttons

## File Targets

These are the main runtime integration points:
- `/Volumes/AI/tactics/scripts/battle/unit_actor.gd`
- `/Volumes/AI/tactics/scenes/battle/Unit.tscn`
- `/Volumes/AI/tactics/scripts/battle/interactive_object_actor.gd`
- `/Volumes/AI/tactics/scenes/battle/InteractiveObject.tscn`
- `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`
- `/Volumes/AI/tactics/scenes/battle/BattleScene.tscn`
- `/Volumes/AI/tactics/scripts/battle/battle_board.gd`
- `/Volumes/AI/tactics/scripts/battle/battle_hud.gd`
- `/Volumes/AI/tactics/scenes/battle/BattleHUD.tscn`

## Delivery Spec

### File Format

- PNG
- transparent background where applicable

### Suggested Sizes

- unit token art: `48x48`
- unit role icon: `28x28`
- object icon: `40x40`
- fx: `64x64`
- terrain icon: `24x24`
- terrain card/stamp: `48x48`
- hud icon: `32x32`

## Quality Bar

The replacement art passes if:
- units feel like tactical pieces, not debug blocks
- objectives are recognizable before reading labels
- hits/marks/objectives feel alive
- chapter screenshots differ in mood and shape language
- small-size readability survives

## Review Images

Use these current reference outputs as comparison targets:
- `/Volumes/AI/tactics/.codex-representative-snaps/tutorial00000001.png`
- `/Volumes/AI/tactics/.codex-representative-snaps/ch0300000001.png`
- `/Volumes/AI/tactics/.codex-representative-snaps/ch0700000001.png`
- `/Volumes/AI/tactics/.codex-representative-snaps/ch1000000001.png`
- `/Volumes/AI/tactics/.codex-representative-snaps/representative_contact_sheet.png`

## Verification After Asset Drop

After any replacement batch, run:
- `/Volumes/AI/tactics/scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m1_playtest_runner.gd`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/m3_ui_runner.gd`
- `/Volumes/AI/tactics/scripts/dev/render_representative_snapshots.sh /Volumes/AI/tactics/.codex-representative-snaps`

## Fastest Win

If the artist can only do one small sprint:

1. unit token art
2. object icons
3. combat fx

That bundle gives the largest perceived quality jump for the current demo.
