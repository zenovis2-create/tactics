# Battle-Camp-Meta UX Design

## Summary

This document defines the interaction feel for the mobile-first tactics RPG interface across battle, camp, and meta screens.

Design intent:

- fast tactical control in battle
- low-friction preparation in camp
- clear long-term progression in meta
- minimal cognitive carry-over cost between screens

## Product-Level UX Goals

- Battle decisions should feel immediate, not menu-driven.
- Camp should support planning in short loops (30 to 90 seconds).
- Meta should answer "what changed" and "what should I do next" in one glance.
- Movement between battle, camp, and meta should preserve player context (rewards, pending upgrades, next objective).

## Input And Tap Target System

### Touch target sizing

- Primary combat actions: `56x56 dp` minimum interactive area.
- Primary CTA buttons (Sortie, Confirm, Start Battle): `64 dp` height minimum.
- Standard controls and list-row actions: `48x48 dp` minimum.
- Dense utility actions (filter chips, sorting, small toggles): `44x44 dp` minimum, only inside non-combat screens.

### Spacing and hit safety

- Minimum gap between adjacent tap targets: `8 dp`.
- Preferred gap for destructive vs non-destructive adjacent actions: `12 dp`.
- Bottom-edge controls reserve `16 dp` safe margin from screen edge and gesture bar.
- Do not place critical controls inside top notch/cutout zones.

### Touch feedback

- Tap response visual within `80 ms`.
- Pressed-state scale/brightness feedback on all actionable buttons.
- Invalid tap feedback (subtle shake + toast) instead of silent failure.

## Information Density Model

Use three density tiers by screen purpose.

### Tier A: Tactical density (Battle)

- Show only battle-critical information by default.
- Always visible: phase, objective, selected unit stats, action rail.
- Contextual only: target forecast, terrain detail, skill details.
- Keep max concurrent always-visible text blocks to `4`.

### Tier B: Planning density (Camp)

- Show roster readiness and resource deltas first.
- Keep deep equipment details in bottom sheet/detail panel.
- Use progressive disclosure for inventory and crafting complexity.

### Tier C: Strategic density (Meta)

- Show chapter node state, unlocks, and account-level progression.
- Collapse secondary lore/detail until explicit tap.
- Meta screen should prioritize orientation over micromanagement.

## Visual Hierarchy Rules

### Hierarchy levels

- Level 1 (World): map/units/environment.
- Level 2 (Tactical overlays): move range, targetable cells, danger zones.
- Level 3 (Command UI): action rail, unit card, confirm/cancel controls.
- Level 4 (Interruptive): result popups, warnings, tutorials, defeat/victory.

### Priority conventions

- Never let Level 3 obscure selected unit and target forecast simultaneously.
- Level 2 overlays use low-alpha fills and strong edge lines, not opaque blocks.
- Critical state changes (phase change, lethal prediction, mission failure risk) must use both color and iconography.

### Typography and readability

- Minimum body text: `16 sp`.
- Combat numeric labels (HP, damage forecast): `18 sp` minimum.
- Section headers: `22-26 sp`.
- Use short labels (1 to 2 words) for combat buttons.

## Screen Architecture

### Battle Screen

### Layout

- Top strip: phase indicator, turn count, objective pill.
- Left/upper-left: selected unit card (HP, status, move/attack availability).
- Bottom action rail: Move, Attack, Skill, Item, Wait, Cancel.
- Context panel appears above action rail only when targeting.

### Interaction flow

1. Tap unit to select.
2. Tap destination tile.
3. Tap action (Attack/Skill/Wait).
4. Confirm only when outcome is irreversible.

### Battle-specific UX rules

- Default button order: `Move > Attack > Skill > Item > Wait > Cancel`.
- Disable unavailable actions with clear reason tooltip.
- End-turn control remains visible but visually secondary to per-unit actions.
- Avoid modal stacks during player phase; one overlay at a time.

### Camp Screen

### Layout

- Header: chapter status, pending alerts (new loot, unlocked dialogue, upgrade available).
- Primary modules in first fold:
  - Party Loadout
  - Inventory
  - Hunt/Replay Board
  - Forge/Upgrade (when unlocked)
- Persistent footer CTA: `Next Battle` (enabled when minimum requirements met).

### Interaction flow

1. Land in Camp Hub after battle rewards.
2. Review delta summary (new items, injuries/status, unlocked content).
3. Optional loadout/upgrade pass.
4. Tap `Next Battle` to move to meta mission selection.

### Camp-specific UX rules

- Show "recommended action" card at top when user returns from battle.
- Equipment compare is side-by-side and always shows net stat delta.
- Inventory filtering is one-tap chip based, no nested filter modals.

### Meta Screen

### Layout

- Chapter progression map/timeline as primary canvas.
- Secondary panels:
  - mission brief
  - expected enemy tags
  - reward preview
  - stamina/resource cost (if used later)
- Top-right quick access: codex/lore and global progression summaries.

### Interaction flow

1. Enter from Camp via `Next Battle`.
2. Choose node/mission.
3. Review mission brief and rewards.
4. Tap `Deploy` to enter battle intro.

### Meta-specific UX rules

- One primary CTA per node (`Deploy` or `Locked Requirement`).
- Locked node states must explain exactly what is missing.
- Preserve last selected node when user backs out to camp.

## Cross-Screen Flow Design

### Canonical loop

1. `Battle`
2. `Battle Result Popup`
3. `Reward + Delta Summary`
4. `Camp Hub`
5. `Meta Mission Select`
6. `Battle Deploy`

### Transition behavior

- After battle clear, auto-route to rewards before camp.
- Camp opens with contextual highlights based on new rewards/unlocks.
- Meta opens with suggested next mission preselected.
- Back navigation:
  - from Meta back goes to Camp Hub
  - from Camp back goes to latest summary panel, not to battle

### Flow latency budgets

- Battle clear to actionable Camp state: under `6 seconds` (excluding reward animations).
- Camp to mission deploy-ready state: `3 taps` target.
- Equip one unit with recommended loadout: `4 taps` target.

## Notification And Alert Priority

Use priority lanes to prevent noise.

- Critical: mission failure risk, unit incapacitation, irreversible action confirmation.
- Important: new gear, unlocks, upgrade opportunities, mission gating reasons.
- Informational: lore additions, collection updates, optional hints.

Only one critical alert may block interaction at a time.

## Error Prevention And Recovery

- All destructive actions (salvage, overwrite loadout) require explicit confirm.
- In battle, irreversible actions show forecast panel before confirm.
- In camp/meta, provide undo for non-combat actions where feasible (loadout swap, sort/filter reset).

## Accessibility And Comfort Baseline

- Color is never the only state signal; pair with icons/patterns.
- Keep contrast high for HUD text over map backgrounds.
- Animation should communicate state change, not delay interaction.
- Provide reduced-motion option for phase transitions and reward animations.

## Implementation Handoff Targets

Recommended scene/script alignment for future implementation:

- `scenes/ui/battle/BattleHUD.tscn`
- `scenes/ui/battle/ResultSummary.tscn`
- `scenes/ui/camp/CampHub.tscn`
- `scenes/ui/meta/MissionMap.tscn`
- `scripts/ui/battle/battle_hud.gd`
- `scripts/ui/camp/camp_hub.gd`
- `scripts/ui/meta/mission_map.gd`

## UX Acceptance Criteria

- Core battle actions are comfortably tappable on common mobile screens without accidental mis-taps.
- Player can identify current phase, selected unit state, and next required objective within 2 seconds.
- Player can move from battle clear to next deploy in under 60 seconds without opening more than one deep panel.
- Camp and meta each communicate exactly one clear next action at top priority.

## Current Slice Implementation Notes

These notes map the target UX onto the current vertical-slice shell instead of assuming a future-only rebuild.

### Battle HUD now

- `BattleHUD` should read in this order: world state, selected-unit state, available actions.
- The bottom panel should behave like a command rail, not a debug log.
- A small eyebrow above the selected-unit card is acceptable because it reduces scan cost on mobile when the card content changes every tap.
- The action area should always present one stable heading so players do not parse a floating button cluster as map content.

### Camp shell now

- The current `CampaignPanel` is the live camp hub and should answer three questions above the fold:
  - where am I in the loop
  - what changed since the last battle
  - what should I do next
- Use a loop-status line near the header for `Battle -> Camp -> Next Battle` context.
- Use compact overview cards for `Party`, `Loot`, and `Records` counts so players can decide whether to drill down.
- Each tab should include a one-line guidance string to keep dense camp content from feeling like a flat index.

### Meta handoff next

- The current `Next Battle` CTA is a placeholder for the future meta/mission brief screen.
- When the meta screen lands, camp should not absorb node selection, mission rewards, or deployment briefing details.
- The future meta screen should preserve the same loop framing:
  - header explains the current chapter/node
  - center explains mission risk and rewards
  - footer gives one deployment action
