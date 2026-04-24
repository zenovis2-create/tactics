# 2026-04-24 CH06~CH10 Boss / Manual Balance / Final QA Status

## Scope
- Checked the current late-game boss runner surface against the existing release QA checklist and manual balance follow-up.
- Focused on CH06_05, CH07_05, CH08_05, CH09A_05, CH09B_05, CH10_05.
- No combat data or controller tuning was changed in this pass.

## Headless verification run this pass
Command prefix:
```bash
GODOT=/opt/homebrew/bin/godot4
ROOT=/Volumes/AI/tactics
$GODOT --headless --path $ROOT --script <runner>
```

Results:
- PASS `res://scripts/dev/ch06_ch10_boss_surface_runner.gd`
  - Validated boss-stage load for CH06_05 / CH07_05 / CH08_05 / CH09A_05 / CH09B_05 / CH10_05.
  - Validated HUD creation, start/clear cutscene references, boss spawn flags, boss pattern ids, phase thresholds, phase event logging, required late-game object ids, and victory handoff.
  - CH10_05 correctly reports that StageData clear cutscene is empty because campaign ending flow owns the final clear handoff.
- PASS `res://scripts/dev/lategame_boss_pattern_runner.gd`
  - Validated late-game custom boss patterns and relief-object contracts for CH08_05 / CH09B_05 / CH10_05.
  - Covered Lete gate latch relief, Melkion archive lectern relief, Karuon anchor/bell pressure surfaces, objective text/hint shifts, result relief entries, cooldown locks, AI shift behavior, and battlefield rewrite dampening.
- PASS `res://scripts/dev/ch06_ch10_cutscene_runner.gd`
  - Validated CH06~CH10 late-game cutscene contracts and ending cinematic references.
- PASS `res://scripts/dev/tut_ch05_surface_runner.gd`
  - Reconfirmed tutorial/early boss surface after manual-balance follow-up items.
- PASS `res://scripts/dev/ch10_shell_runner.gd`
  - Fixed the runner expectation to advance through the intentional CH10_05 briefing before asserting battle mode.
  - Validated CH10 intro, CH10_01~05 flow, final resolution, postgame return-to-title, and NG+ unlock.

## Current status read
### Boss action surface
- CH06~CH10 direct boss-stage surface is green through the dedicated boss runner.
- Late-game pattern runner is green for the high-risk CH08/CH09B/CH10 mechanics.
- The earlier 2026-04-18 blocker note about `ch06_ch10_boss_surface_runner.gd` being blocked by cutscene data is now stale for the current working tree; the runner passes.

### Stage linkage / campaign shell
- CH10 shell is now green after runner alignment with the intentional CH10_05 briefing step.
- CH10_04 → CH10_05 handoff path now validates briefing advance, CH10_05 battle entry, final resolution, title return, and NG+ unlock.
- Direct CH10_05 boss runtime remains green through the dedicated boss and late-game runners.

### Manual balance
- Tutorial readability follow-up remains covered by `tut_ch05_surface_runner.gd`.
- Late-game boss relief/control-object mechanics are covered by `lategame_boss_pattern_runner.gd`.
- Current live phase bonus hook is `_apply_boss_phase_bonuses()` in `scripts/battle/battle_controller.gd`, with late-game boss bonuses currently visible for:
  - `berserk_rush`: boss +1 ATK, +1 MOV
  - `final_toll`: boss +2 ATK, +1 MOV
  - `oblivion_resonance`: boss +2 ATK, +1 MOV
  - generic `enrage` / `despair`: boss and nearby-enemy ATK bonuses
- No minimum ATK trim was applied in this pass because automated late-game pattern coverage is passing and no fresh manual-play failure data was produced here. If manual play still reports damage spikes, trim only the top-end phase bonus values and rerun both boss runners plus CH10 shell.

## Missing / follow-up checklist
- [x] Resolve the CH10 shell expectation mismatch: `CH10_05` intentionally passes through briefing, and the runner now advances that briefing before battle assertions.
- [x] Add runner coverage for the CH10_05 briefing-to-battle handoff so final QA no longer relies on manual interpretation.
- [ ] Manual-play spot check CH08_05, CH09B_05, CH10_05 after the shell fix:
  - CH08_05: `ch08_05_transfer_gate_latch` can be reached/resolved and visibly reduces chase pressure.
  - CH09B_05: `ch09b_05_archive_lectern` can be reached/resolved and visibly stabilizes archive pressure.
  - CH10_05: `ch10_05_anchor_chain` and `ch10_05_bell_dais` can be reached/resolved and ending resolution begins after final victory.
- [ ] If manual damage-spike complaints persist, do a tiny balance-only follow-up in `_apply_boss_phase_bonuses()` and avoid changing AI/pattern scripts.
- [ ] Rerun final gate after any further CH10 shell or balance change:
  - `res://scripts/dev/ch06_ch10_boss_surface_runner.gd`
  - `res://scripts/dev/lategame_boss_pattern_runner.gd`
  - `res://scripts/dev/ch06_ch10_cutscene_runner.gd`
  - `res://scripts/dev/ch10_shell_runner.gd`
