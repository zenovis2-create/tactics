# Systems Design: Combat Loops, State Systems, and Theme Mechanics

## 1. Purpose

This document defines the gameplay rules players learn and master:

- combat loops
- battle and unit state systems
- progression logic across chapters
- the mechanical meaning of core themes

This is a post-vertical-slice systems layer. The MVP loop in `docs/game_spec.md` remains the foundation.

## 2. Core Theme Pillars and Mechanical Promises

Core themes from story canon are translated into player-facing rules:

- Memory is power with cost.
- Oblivion feels safe short-term but erodes agency.
- Responsibility is not removed by forgetting.
- Shared burden is stronger than solitary heroics.

Design promise:

- Every chapter boss should ask a philosophical question through mechanics, not only dialogue.
- Winning efficiently and winning ethically should sometimes diverge, then reconnect through progression rewards.

## 3. Combat Loop Stack

## 3.1 Action Loop (5-20 seconds)

Per acting unit:

1. Read threat telegraphs and objective markers.
2. Choose movement destination.
3. Choose one action: attack, support, interact, or wait.
4. Resolve status exchange.
5. End action and update local board control.

Mastery target:

- The player predicts one full enemy response cycle before ending the action.

## 3.2 Turn Loop (30-90 seconds)

Per side phase:

1. Start-of-phase effects resolve.
2. Units act once each.
3. Environmental state mutates.
4. Objective timers and rescue states tick.
5. Check phase-end trigger.

Mastery target:

- The player sequences units to reduce Oblivion pressure and preserve objective tempo in the same phase.

## 3.3 Encounter Loop (5-10 minutes)

Per battle:

1. Establish control over safe zones or cleansing tools.
2. Stabilize allies against chapter signature threat.
3. Pivot from survival to objective closure.
4. Clear with optional challenge conditions for bonus rewards.

Mastery target:

- The player transitions from defensive stabilization to proactive closure before attrition states snowball.

## 3.4 Campaign Loop (30-60 minutes per chapter block)

Per chapter:

1. New tactical rule introduced.
2. Rule is tested across 3-4 battles.
3. Boss confrontation combines current rule plus one prior rule.
4. Memory fragment recovered, unlocking command progression.

Mastery target:

- The player carries old rule literacy into new rule pressure, not just raw stat growth.

## 4. State Systems

## 4.1 Battle State Machine

High-level deterministic flow:

- `BATTLE_INIT`
- `PLAYER_PHASE_START`
- `PLAYER_SELECT`
- `PLAYER_ACTION_PREVIEW`
- `PLAYER_ACTION_COMMIT`
- `PLAYER_ACTION_RESOLVE`
- `PLAYER_PHASE_END`
- `ENEMY_PHASE_START`
- `ENEMY_DECIDE`
- `ENEMY_ACTION_RESOLVE`
- `ENEMY_PHASE_END`
- `ROUND_END`
- `VICTORY` or `DEFEAT`

Rules:

- No hidden transitions.
- Every transition emits a UI-readable reason.
- Interrupts are explicit sub-states only, never silent jumps.

## 4.2 Unit Action State

Per unit each round:

- `READY`
- `MOVED`
- `ACTED`
- `EXHAUSTED`
- `DOWNED`

Constraint:

- A unit cannot return to `READY` in the same round unless a specifically tagged command skill grants a reset.

## 4.3 Core Status Taxonomy

Required thematic statuses:

- `Oblivion` (stacking debuff, 0-3)
- `Clarity` (anti-Oblivion buffer)
- `Guard` (flat damage reduction state)
- `Mark` (focus-fire amplifier)
- `Seal` (skill restriction)

Oblivion stack effects:

- 1 stack: `-10%` status accuracy and `-10%` effect potency.
- 2 stacks: `-1` movement and reaction attacks disabled.
- 3 stacks: skill slot 1 sealed until cleansed.

Cleansing rules:

- Purify effects remove 1 stack by default.
- Strong cleanse can remove all stacks but has encounter cooldown limits.

## 4.4 Resolution Order

At unit turn start:

1. Terrain and hazard effects.
2. Duration decrement for buffs and debuffs.
3. Oblivion and Clarity interaction.
4. Passive start-of-turn effects.
5. Control returns to player or AI.

At action resolve:

1. Hit and evade check.
2. Damage and guard calculation.
3. Status application.
4. Defeat check.
5. On-defeat and on-assist triggers.

Determinism rule:

- One fixed order across all chapters.
- Chapter gimmicks may add effects, but cannot reorder global resolution.

## 4.5 Canonical State Data Contract

Canonical battle-state fields:

- `round_index`
- `phase_owner` (`player` or `enemy`)
- `active_unit_id`
- `objective_state`
- `hazard_state`
- `oblivion_global_pressure`
- `rescue_state`

Canonical per-unit runtime fields:

- `action_state`
- `hp_current`
- `status_stacks` (`oblivion`, `clarity`, `mark`, `guard`)
- `cooldown_map`
- `support_links`
- `downed_flag`

State-authority rule:

- Battle-critical fields are runtime authority in battle services.
- Narrative progression fields are authority in progression services.
- UI mirrors state, but never owns rule outcomes.

## 5. Progression Logic

## 5.1 Chapter-Based Rule Growth

Progression is rule unlock first, stat growth second.

- Chapter 1: baseline positioning, guard, escort, interaction.
- Chapter 2: rescue pressure and route-risk reward.
- Chapter 3: concealment, traps, and anti-ambush responses.
- Chapter 4: water-level shifts, purification timing, Oblivion control.
- Chapter 5: seal and rule-alteration counterplay.
- Chapter 6: artillery zones, fortification breakpoints, lane defense.
- Chapter 7: city-wide rescue triage and expanding Oblivion zones.
- Chapter 8: infiltration, memory identity checks, and truth-verification objectives.
- Chapter 9: multi-front final operations, resonance towers, and end-state commitment tests.

Each chapter must:

- introduce one signature system
- reinforce one prior system
- award one signature counter-tool

Chapter-to-theme intent:

- 1: awakening under uncertainty
- 2: doubt and responsibility
- 3: first true loss
- 4: faith versus truth
- 5: identity fracture
- 6: grievance versus trust
- 7: "is oblivion mercy?" pressure test
- 8: mourning and chosen responsibility
- 9: courage to carry memory forward

## 5.2 Memory Fragment Command Track

Memory fragments unlock command-tier abilities tied to responsibility choices.

Track rules:

- 1 fragment unlocks one command active.
- 2 fragments unlock one passive branch choice.
- 3+ fragments unlock upgrades but require burden management thresholds.

Command design rule:

- A command should change turn sequencing, not only add raw damage.

## 5.3 Burden and Trust Meta States

Two campaign meta states shape long-term outcomes:

- `Burden`: rises when collateral harm, failed rescues, or suppression tactics are used.
- `Trust`: rises when civilians and allies are protected under pressure.

Mechanical effects:

- High Burden increases command potency but raises Oblivion pressure in later maps.
- High Trust reduces Oblivion spread rates and improves support skill efficiency.

Ending alignment:

- Final ending branch uses Burden + Trust bands, not only binary story flags.

## 5.4 Equipment and Reward Progression

Reward logic should reinforce chapter learning goals.

Rules:

- Story clear grants deterministic baseline upgrades.
- Optional objectives grant build-defining accessories.
- Boss drops reinforce chapter philosophy and counterplay.
- Reroll abuse is blocked by run-seeded drop generation per full re-entry only.

Anti-snowball guardrails:

- Early over-optimization cannot bypass chapter signature mechanics.
- Key encounters include mechanic checks that raw stats alone cannot ignore.

## 5.5 Progression Economy Bounds

Burden and Trust ranges:

- `Burden`: `0-9`
- `Trust`: `0-9`

Band effects:

- Burden `0-2`: no penalty, command growth normal.
- Burden `3-5`: command potency `+5%`, enemy Oblivion apply rate `+5%`.
- Burden `6-9`: command potency `+10%`, enemy Oblivion apply rate `+12%`, rescue objective timers tighten by `1` round.
- Trust `0-2`: no bonus.
- Trust `3-5`: support potency `+8%`, cleanse efficiency `+1` stack per battle once.
- Trust `6-9`: support potency `+12%`, global Oblivion spread events reduced by one trigger in long encounters.

Ending gate logic:

- Normal ending tendency: high Burden and low Trust.
- Shared-memory ending tendency: Burden `<=5` and Trust `>=6`.
- Hidden ending gate: complete chapter memory objectives plus Trust `>=8`.

## 6. Mechanical Meaning of Core Themes

Theme-to-rule mapping:

- Memory as responsibility: command unlocks are strong but tied to Burden consequences.
- Oblivion as false mercy: immediate safety tools exist but increase long-term control loss.
- Shared memory as hope: adjacency, escort, and support chains outperform lone carry patterns.
- Truth as reconstruction: fragmented information appears as partial tactical hints, then resolves into stronger command clarity over chapters.

## 6.1 Theme-to-Mechanic Matrix

Memory as responsibility:

- Question to player: "Will you use power that saves this turn but burdens later turns?"
- Primary mechanic: command-tier skills with Burden gain.
- Success expression: selective command use around objective inflection points.

Oblivion as false mercy:

- Question to player: "Will you trade agency for temporary safety?"
- Primary mechanic: Oblivion stack suppression tools with finite charges.
- Success expression: proactive cleansing and positioning instead of panic purges.

Shared burden as strength:

- Question to player: "Do you distribute risk or funnel everything into one unit?"
- Primary mechanic: support links, escort chains, adjacency bonuses.
- Success expression: rotating frontline and multi-unit solve patterns.

Truth as reconstruction:

- Question to player: "Can you act on incomplete information without overcommitting?"
- Primary mechanic: staged objective reveal, identity checks, and chapter-specific intel interactions.
- Success expression: flexible plans that preserve optionality.

Boss philosophy expression:

- Each major antagonist must impose one board rule that reflects their belief.
- The intended counterplay should represent the story's rebuttal through player action.

Chapter boss philosophy examples:

- Purification zealot boss: map-wide cleanse that also strips ally buffs.
- Censorship boss: skill seal zones and delayed rule revision pulses.
- Fortress boss: positional suppression with artillery prediction.
- Final bell boss: resonance towers that reward coordinated team presence.

## 7. Balance and Telemetry Requirements

Track these metrics per chapter:

- average turns to clear
- Oblivion stacks applied and cleansed
- rescue success rate
- command skill usage rate
- failure cause distribution by system type

Tuning targets:

- failure should mostly come from rule misreads, not hidden numbers
- optional objectives should be risky but legible
- cleanse tools should feel scarce but sufficient with good sequencing

## 8. Implementation Handoff Notes

Recommended system ownership:

- `battle_controller.gd`: high-level state machine and transition reasons
- `turn_manager.gd`: unit activation and phase completion
- `combat_service.gd`: deterministic resolve order and status exchange
- new `status_service.gd`: stack logic, cleanse, and duration handling
- new `progression_service.gd`: memory command unlocks, Burden/Trust progression

Data additions:

- extend UnitData with status resistance and support affinity tags
- extend StageData with chapter signature mechanic config and Oblivion spread parameters
- add progression resources for command trees and chapter rule unlocks

Delivery order:

1. Implement deterministic status and resolution order.
2. Implement chapter mechanic config hooks.
3. Implement Burden/Trust tracking and command unlock gates.
4. Tune chapter reward tables to match mechanic intent.
