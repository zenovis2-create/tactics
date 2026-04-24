# Post-Sprint-7 Polish Design

## Summary

This design defines the next product pass after Sprint 7.

Design intent:

- preserve the current combat loop and polish its feel instead of rewriting it
- make progression, support payoffs, and accessory flavor more visible to the player
- keep camp and save integration compact so the game stays readable
- finish the remaining “what changed?” surfaces across battle, result, camp, and save flows

## Product Goals

- Battle pacing should feel less flat after Sprint 7.
- Support attacks should feel rewarding and readable, but not dominant.
- EXP and level gains should be visible enough to matter without turning results into a spreadsheet.
- Accessories should feel fully authored across the whole catalog, not only late-game items.
- Camp and save screens should answer “who grew?” and “which run is further along?” in one glance.

## Scope

This pass is a focused polish pass, not a new systems rewrite.

It contains four bounded tracks:

1. **Balance tuning**
   - Light-touch tuning only.
   - Adjust EXP pacing and support-attack feel through a few constants and thresholds.
   - No new combat subsystems.

2. **Content rollout**
   - Fill `flavor_text` for the remaining accessory `.tres` files.
   - Apply `unlock_condition` only to existing real skill data.
   - Do not invent a larger skill content catalog in this pass.

3. **Combat UX finish**
   - Improve readability for EXP gain, level-up moments, support/bond payoff, and boss phase state changes.
   - Reuse current HUD/result surfaces.
   - Do not reskin or replace the existing UI architecture.

4. **Camp and save integration**
   - Add compact level/EXP summaries to camp party detail.
   - Add compact unit progression summaries to save slot metadata.
   - Do not add a new progression-management screen.

## Architecture

### Balance lives in existing systems

Balance tuning stays in the existing battle and progression services. The goal is to make a few values easier to adjust and verify, not to scatter new combat rules across the phase machine.

Expected tuning surfaces:

- EXP-per-victory and EXP-per-level pacing in progression service
- support-attack payoff values in battle resolution
- optional clarity thresholds for support/boss-state emphasis if current surfacing still feels too subtle

### Content rollout stays data-first

Accessory flavor rollout should stay in the `.tres` layer, with minimal controller/panel work only where new copy must surface. Skill gating should use the existing `unlock_condition` shape and be applied only where there is already a real skill resource to gate.

### UI work stays incremental

Combat UX should extend the current HUD/result presentation instead of adding scenes. The result screen remains the primary structured feedback surface. Camp detail remains the primary out-of-battle read surface. Save slot metadata remains summary-only.

## Player-Facing Outcomes

### Battle

The player should more easily understand:

- why a support attack triggered
- how strong the bond payoff was
- when a boss shifted phase
- which units gained EXP and leveled up

### Camp

The player should be able to open camp and quickly see:

- each unit’s compact progression state
- which unit is ahead or lagging
- equipment flavor without hunting through sparse copy

### Save slots

The player should be able to tell which save is further progressed by reading a small progression snapshot, not by remembering chapter order alone.

## Data Model Rules

- Per-unit progression remains ally-only.
- Levels stay tied to EXP progression only.
- Burden/Trust/fragment progression remains separate and must not be duplicated.
- Save metadata should summarize progression, not serialize a second UI-only data shape.
- Accessory flavor text must remain distinct from summary text where possible.

## UX Rules

- Level/EXP readouts must be compact and readable on existing layouts.
- Support/bond/boss feedback should become more obvious through wording and hierarchy, not noise.
- Result screens should stay skimmable; detailed progression should not bury rewards and story carry-over.
- Camp should still feel like a short planning loop, not a management spreadsheet.

## Testing Strategy

This pass should stay runner-first.

Recommended verification structure:

- tune existing runners where the surface already exists
- add new runner coverage only when a distinct new contract is introduced
- keep full regression and Gate 0 after each bounded slice

Likely runner groups:

- AI/bond/result/camp/save regressions for tuning and visibility changes
- lategame accessory runner for full flavor rollout
- result/UI runners for EXP, support, and boss readability
- save/load runner for progression summary persistence

## Explicit Non-Goals

- no deep combat rebalance
- no new skill catalog expansion
- no new camp progression management screen
- no stat-growth rewrite tied to level-ups beyond the current lightweight progression layer
- no visual re-theme of battle or camp scenes
