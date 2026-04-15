# Battle SFX Cue Map v1

## Purpose

This document defines the first-pass battle SFX direction for `Memory Tactics RPG`.
It is the battle-facing counterpart to `docs/production/audio_ui_camp_sfx_cue_map_v1.md`.

Scope for this pass:

- hit and confirm-hit feedback
- pain / damage intake feedback
- miss and counterattack feedback
- boss warning and telegraph cues
- combat-state cue naming for phase-level readability

This is a concrete runtime handoff, not a soundtrack brief.

## Primary Goals

- keep battle feedback immediately legible under repeated actions
- separate `action confirmed`, `attack connected`, and `unit hurt` into different sonic meanings
- reserve the sharpest urgency for boss warnings and lethal threat states
- protect camp/UI audio from being mistaken for combat-critical information

## Source Anchors

- camp/UI audio baseline: `docs/production/audio_ui_camp_sfx_cue_map_v1.md`
- hostile telegraph visual language: `docs/production/hostile_telegraph_concept_pack_v1.md`
- battle runtime authority: `scripts/battle/battle_controller.gd`
- attack resolution semantics: `scripts/battle/combat_service.gd`
- current per-unit feedback surface: `scripts/battle/unit_actor.gd`
- CH1 boss encounter intent: `docs/production/ch1/ch1_encounter_pacing_variety_spec.md`

## Battle Audio Pillars

### 1. Read before drama

- The player must distinguish `input commit`, `attack landed`, `damage taken`, and `danger warning` without looking away from the grid.
- Do not let sweeteners blur those categories together.
- Each battle event should present one dominant read, not layered cinematic complexity.

### 2. Damage is physical, warnings are symbolic

- Hit and pain cues should feel bodily, material, and local.
- Boss telegraph and command cues should feel imposed, stamped, and tactical.
- Do not score incoming danger with the same material palette as weapon contact.

### 3. Threat hierarchy must survive repetition

- Basic hit confirms may repeat often and must stay compact.
- Pain cues may overlap with phase/UI text updates and must remain short.
- Boss-grade warnings may be longer and brighter, but only when the game is communicating a real high-priority threat.

### 4. No false urgency

- Camp-like glass sparkles, reward chimes, or mystical reveal swells are forbidden in core battle feedback.
- A miss should not sound larger than a hit.
- A routine enemy action should never sonically outrank a boss telegraph.

## Mix Guardrails

- Core battle cues should be short and transient-led:
  - commit / confirm: `80-180 ms`
  - hit / pain / miss: `90-240 ms`
  - boss warnings and combat-state accents: `220-700 ms`
- Keep low-end controlled so repeated impacts do not muddy mobile speakers.
- Keep the `2-4 kHz` band reserved for the most important read in the moment.
- Avoid stacking more than two prominent transients inside one resolution packet.
- When attack result and counterattack result occur back-to-back, the first hit must remain legible without masking the second.

Priority order:

1. boss warning / lethal threat / phase-danger state
2. unit damage intake
3. attack landed / counter landed
4. attack commit / miss / utility battle UI

## Emotional Audio Beats

### Player commits to an attack

- Goal: express deliberate tactical choice, not celebration.
- Sound: compact weapon-ready tick or dry forward push.
- Emotion: confidence and intent.

### Attack lands cleanly

- Goal: confirm contact and effectiveness.
- Sound: short impact with material body plus a tiny confirm edge.
- Emotion: precision, not spectacle.

### Unit takes damage

- Goal: communicate bodily consequence immediately.
- Sound: tighter, harsher body than confirm-hit; slight downward energy.
- Emotion: cost and vulnerability.

### Attack misses or glances off

- Goal: communicate failed conversion without annoyance.
- Sound: thin pass-by, scrape, or displaced air with low body.
- Emotion: whiff, not punishment.

### Counterattack interrupts momentum

- Goal: make the exchange feel dangerous and two-sided.
- Sound: reply impact should be slightly more alarming than a normal hit confirm, but still shorter than a boss warning.
- Emotion: retaliation and exposure.

### Boss applies mark or command pressure

- Goal: signal that the next decision space has changed.
- Sound: stamped seal, command bark translated into metal/ash symbolism, restrained tail.
- Emotion: battlefield order and hunted pressure.

### Boss charge resolves

- Goal: communicate committed threat payoff.
- Sound: heavier forward thrust followed by impact; more forceful than normal enemy hit, but still clean.
- Emotion: execution and danger fulfilled.

## Cue Map

| Event | Cue ID | Intent | Sonic direction | Dur. | Priority |
| --- | --- | --- | --- | --- | --- |
| Attack command committed | `battle_action_commit_01` | lock in a player attack | dry weapon-ready tick or hilt-settle, minimal tail | 80-130 ms | medium |
| Wait committed | `battle_action_wait_01` | end unit action cleanly | restrained downward settle, softer than attack commit | 90-140 ms | low |
| Standard hit confirm | `battle_hit_confirm_01` | confirm a landed strike | compact impact with brief bright edge | 100-170 ms | medium |
| Heavy hit confirm | `battle_hit_confirm_heavy_01` | emphasize stronger blow or boss hit | denser impact body, controlled low-mid thump | 130-220 ms | medium |
| Ally pain | `battle_pain_ally_01` | ally took damage | sharper downward snap with brief cloth/armor tear body | 110-190 ms | high |
| Enemy pain | `battle_pain_enemy_01` | enemy took damage | drier crack with less sympathetic body than ally pain | 100-170 ms | medium |
| Attack miss | `battle_miss_01` | committed attack failed to connect | thin whoosh or scrape-through with damped tail | 100-180 ms | medium |
| Counterattack ready/turnback | `battle_counter_ready_01` | exchange has reversed | short metallic deflect or recoil cue | 90-140 ms | medium |
| Counterattack land | `battle_counter_hit_01` | counterstrike connected | hit confirm variant with more sting and less body | 110-190 ms | high |
| Unit defeated | `battle_unit_defeat_01` | unit removed from field | low-energy collapse accent, no reward shape | 220-360 ms | high |
| Player phase open | `battle_state_player_phase_01` | safe tactical control returns | restrained upward brace, modest clarity accent | 220-340 ms | medium |
| Enemy phase open | `battle_state_enemy_phase_01` | cede control to hostile phase | lower, firmer pulse with clipped warning edge | 240-360 ms | high |
| Round turnover | `battle_state_round_advance_01` | mark full round transition | parchment-metal step marker, neutral and brief | 180-280 ms | low |
| Boss mark telegraphed | `battle_boss_mark_warn_01` | this unit is hunted next | stamped seal tick plus narrow rising ember edge | 260-420 ms | critical |
| Boss command buff | `battle_boss_command_warn_01` | nearby enemies were ordered forward | clipped command pulse with short barred rhythm | 240-380 ms | high |
| Boss danger state | `battle_boss_danger_01` | highest threat state is present | broad but controlled warning plate, edge-led not boomy | 320-520 ms | critical |
| Boss charge resolve | `battle_boss_charge_impact_01` | telegraphed threat pays off | forward thrust accent into heavy impact | 260-420 ms | critical |
| Victory result | `battle_result_victory_01` | encounter won | reserved for result popup; outside normal cue loop | 500-800 ms | critical |
| Defeat result | `battle_result_defeat_01` | encounter lost | reserved for result popup; heavier, flatter fall | 500-850 ms | critical |

## Semantic Rules

### Confirm-hit versus pain

- `battle_hit_confirm_*` communicates `my action connected`.
- `battle_pain_*` communicates `a unit suffered damage`.
- If one event causes both readings in sequence, the confirm should read first and the pain should read second.
- Never collapse both meanings into one oversized impact.

### Miss behavior

- `battle_miss_01` must feel like lost conversion, not comic failure.
- It should be lighter and thinner than any landed hit.
- It must not use the same upward gesture language as menu confirm cues.

### Counter behavior

- Counter cues must clearly communicate reversal.
- `battle_counter_ready_01` can be omitted if the full exchange is too dense, but `battle_counter_hit_01` must still read as distinct from the original strike.
- Counter landed should feel more dangerous than a normal hit confirm, especially when the player receives it.

### Boss warning behavior

- Boss warning cues use stamped, command-like symbolism instead of creature-roar or horror-drone clichés.
- `battle_boss_mark_warn_01` is about target designation.
- `battle_boss_command_warn_01` is about field-wide tactical pressure.
- `battle_boss_danger_01` is reserved for the highest-importance threat state and must not fire on routine enemy actions.

## Mapping To Current Runtime

### `scripts/battle/combat_service.gd`

- `transition_reason = attack_resolved_deterministic`
  - fire `battle_action_commit_01` on attack commit, then `battle_hit_confirm_01` or `battle_hit_confirm_heavy_01` on result
  - route pain cue based on recipient faction:
    - defender ally -> `battle_pain_ally_01`
    - defender enemy -> `battle_pain_enemy_01`
- `transition_reason = attack_missed`
  - fire `battle_action_commit_01`, then `battle_miss_01`
- `transition_reason = attack_missed_counter_resolved`
  - fire `battle_miss_01`, then `battle_counter_hit_01`, then pain cue for the counter target
- `counterattack.reason = counterattack_resolved`
  - fire `battle_counter_hit_01`, then the appropriate pain cue
- `counterattack.reason = counterattack_missed`
  - optional reuse of `battle_miss_01` at a lower level or no extra cue if the exchange already reads clearly

### `scripts/battle/battle_controller.gd`

- `hud.set_transition_reason("boss_mark_telegraphed", ...)`
  - `battle_boss_mark_warn_01`
- `hud.set_transition_reason("boss_command_buff", ...)`
  - `battle_boss_command_warn_01`
- `hud.set_transition_reason("boss_charge_resolve", ...)`
  - pre-impact accent or direct route to `battle_boss_charge_impact_01`
- `_begin_player_phase(...)`
  - `battle_state_player_phase_01`
- `_begin_enemy_phase(...)`
  - `battle_state_enemy_phase_01`
- `round_completed` / next-round handoff
  - `battle_state_round_advance_01`
- `hud.show_result("Victory!...")`
  - reserve `battle_result_victory_01`
- `hud.show_result("Defeat!...")`
  - reserve `battle_result_defeat_01`

### `scripts/battle/unit_actor.gd`

- `apply_damage(amount)`
  - pain cues belong here or in the caller immediately after damage resolution if engineering wants recipient-local routing
- `set_boss_marked(true)`
  - visual state already exists; when an audio hook is added, pair it with `battle_boss_mark_warn_01`

## Naming Rules

Format:

`battle_<category>_<action>_<variant>`

Categories:

- `action`
- `hit`
- `pain`
- `miss`
- `counter`
- `state`
- `boss`
- `result`

Action vocabulary:

- `commit`
- `wait`
- `confirm`
- `heavy`
- `ally`
- `enemy`
- `ready`
- `warn`
- `danger`
- `impact`
- `player_phase`
- `enemy_phase`
- `round_advance`
- `victory`
- `defeat`

Do not use:

- implementation-only names such as `attack1`, `hit02`, `bosssfx`
- camp/UI verbs such as `reveal`, `focus`, or `notice` for combat impacts
- inconsistent synonyms such as both `hurt` and `pain` for the same semantic lane

## QA Verification Rules

1. A landed attack reads in this order: commit -> hit confirm -> recipient pain.
2. A miss never sounds larger or brighter than a landed hit.
3. Ally pain and enemy pain are distinguishable within repeated combat loops.
4. Boss mark, command buff, and charge cues are each identifiable without reading transition text.
5. Enemy phase open reads as more dangerous than player phase open.
6. No battle cue is confused with `camp_hub_enter_01`, `camp_memory_reveal_01`, or other restorative/narrative cues.
7. The loudest or brightest cue in a combat turn corresponds to the highest gameplay urgency, not merely the most recent button press.
8. Naming in import tables follows the `battle_<category>_<action>_<variant>` format exactly.

## Not In Scope For This Pass

- adaptive music layering or boss music states
- spell-school signature design
- per-weapon-family impact sets
- terrain Foley beds
- voiced combat barks
- chapter-specific victory themes

Those can follow after the first battle feedback lane is wired and verified in runtime.
