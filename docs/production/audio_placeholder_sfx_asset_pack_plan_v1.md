# Placeholder SFX Asset Pack Plan v1

## Purpose

This document turns the existing cue maps into a concrete placeholder SFX pack plan for `Memory Tactics RPG`.
It defines the minimum asset set, file naming, runtime wiring order, and placeholder synthesis direction required to keep battle feedback clear while broader audio production remains in progress.

This is a placeholder production handoff, not a final mix or soundtrack brief.

## Source Anchors

- [docs/production/audio_battle_sfx_cue_map_v1.md](/Volumes/AI/tactics/docs/production/audio_battle_sfx_cue_map_v1.md)
- [docs/production/audio_ui_camp_sfx_cue_map_v1.md](/Volumes/AI/tactics/docs/production/audio_ui_camp_sfx_cue_map_v1.md)
- [scripts/battle/battle_hud.gd](/Volumes/AI/tactics/scripts/battle/battle_hud.gd)
- [scripts/campaign/campaign_panel.gd](/Volumes/AI/tactics/scripts/campaign/campaign_panel.gd)
- [scripts/audio/audio_event_router.gd](/Volumes/AI/tactics/scripts/audio/audio_event_router.gd)
- [scripts/dev/sfx_trigger_integration_runner.gd](/Volumes/AI/tactics/scripts/dev/sfx_trigger_integration_runner.gd)

## Audio Direction Guardrails

- Battle cues must win the clarity fight over camp and utility cues.
- Placeholder assets should read the correct gameplay meaning first, even if the timbre is simple.
- Boss warnings must feel stamped, tactical, and imposed; never magical or reward-like.
- Camp and UI cues should feel dry, soft, and restorative so they never impersonate battle danger.
- Repeated cues should stay short and uncluttered; no long tonal tails on common actions.

## Emotional Beat Targets

- `battle_action` and `battle_hit` lanes: deliberate, precise, compact.
- `battle_pain` and `battle_counter` lanes: sharper, risk-forward, slightly more hostile.
- `battle_boss` and `battle_state` lanes: symbolic command pressure, not creature-horror.
- `ui_*` lanes: neutral utility and control.
- `camp_*` lanes: decompression, paper/metal tactility, low-heat ember warmth.

## Asset Root And Naming

Use one placeholder source file per cue ID so runtime, QA, and future replacement work stay one-to-one.

Recommended root:

- `assets/audio/sfx/placeholders/`

Recommended split:

- `assets/audio/sfx/placeholders/battle/`
- `assets/audio/sfx/placeholders/ui/`
- `assets/audio/sfx/placeholders/camp/`

Filename format:

- `<cue_id>.ogg`

Examples:

- `assets/audio/sfx/placeholders/battle/battle_boss_mark_warn_01.ogg`
- `assets/audio/sfx/placeholders/ui/ui_inventory_open_01.ogg`
- `assets/audio/sfx/placeholders/camp/camp_party_assign_01.ogg`

## Tier 0: Mandatory Placeholder Pack

These are the cue IDs already emitted by current runtime code and should be generated first.
If only one placeholder pass ships, it must cover this exact list.

| Cue ID | Runtime source | Role | Placeholder direction |
| --- | --- | --- | --- |
| `ui_inventory_open_01` | `BattleHUD.open_inventory_panel()` | battle utility open | dry panel reveal, low urgency |
| `ui_inventory_close_01` | `BattleHUD.close_inventory_panel()` | battle utility close | short fold-away release |
| `ui_common_cancel_01` | `BattleHUD._on_cancel_pressed()` | battle utility cancel | soft downward tick |
| `ui_common_confirm_01` | `BattleHUD._on_wait_pressed()` | utility confirm | restrained forward confirm |
| `battle_state_enemy_phase_01` | `BattleHUD._on_end_turn_pressed()` and reason routing | hostile control handoff | firmer low pulse with clipped warning edge |
| `battle_boss_mark_warn_01` | battle reason routing | boss target designation | stamped seal tick plus narrow rise |
| `battle_boss_command_warn_01` | battle reason routing | boss command pressure | clipped pulse in barred rhythm |
| `battle_boss_charge_impact_01` | battle reason routing | telegraphed threat payoff | forward thrust into compact impact |
| `battle_hit_confirm_01` | battle reason routing | landed strike confirm | compact impact with tiny bright edge |
| `battle_miss_01` | battle reason routing | failed strike | thin whoosh or scrape-through |
| `battle_counter_hit_01` | battle reason routing | reversal landed | sting-forward impact with less body |
| `battle_state_player_phase_01` | battle reason routing | player control returns | restrained upward brace |
| `camp_recommend_focus_01` | battle interaction and camp emphasis | guided attention | gentle upward glint, low heat |
| `ui_panel_tab_shift_01` | `CampaignPanel._select_section()` | lateral camp navigation | brushed tick plus soft slide |
| `camp_party_select_01` | `CampaignPanel._select_party_index()` | party focus | soft emblem tick |
| `camp_next_battle_confirm_01` | `CampaignPanel._on_advance_pressed()` in camp | recommit from safety to battle | confirm plus low pulse |
| `camp_party_assign_01` | `CampaignPanel._on_party_assignment_pressed()` | roster commitment | confirm variant plus cloth/gear settle |
| `camp_loadout_weapon_cycle_01` | `CampaignPanel._on_party_weapon_pressed()` | weapon browse/equip | metal slide plus latch |
| `camp_loadout_armor_cycle_01` | `CampaignPanel._on_party_armor_pressed()` | armor browse/equip | leather/cloth move plus clasp |
| `camp_loadout_accessory_cycle_01` | `CampaignPanel._on_party_accessory_pressed()` | accessory browse/equip | charm ring plus soft click |

## Tier 1: Reserve Placeholder Pack

These cues are defined in the cue maps and should be prepared next, but they are not currently emitted by the checked-in runtime paths above.

| Cue ID | Why reserve it now |
| --- | --- |
| `battle_action_commit_01` | attack commit should separate intent from result once combat hooks expand |
| `battle_action_wait_01` | battle wait action needs its own non-camp end-of-action read |
| `battle_hit_confirm_heavy_01` | stronger or boss-class hits need a controlled heavier confirm |
| `battle_pain_ally_01` | ally damage needs a distinct sympathetic lane |
| `battle_pain_enemy_01` | enemy damage should not share ally pain color |
| `battle_counter_ready_01` | reserve if exchange readability needs a pre-counter turnback accent |
| `battle_unit_defeat_01` | unit removal cue should exist before polish pass |
| `battle_state_round_advance_01` | round turnover is defined and should stay semantically separate |
| `battle_boss_danger_01` | highest-priority boss state must remain distinct from routine warnings |
| `battle_result_victory_01` | result popup placeholder |
| `battle_result_defeat_01` | result popup placeholder |
| `ui_common_tap_soft_01` | generic camp/UI taps should stop borrowing confirm |
| `ui_common_tap_primary_01` | primary CTA cue for non-battle contexts |
| `ui_common_invalid_01` | muted invalid feedback |
| `ui_panel_open_01` | generic non-battle open |
| `ui_panel_close_01` | generic non-battle close |
| `ui_panel_dismiss_01` | overlay/scrim dismiss |
| `camp_hub_enter_01` | key emotional reset on camp arrival |
| `camp_unlock_notice_01` | system unlock surfacing |
| `camp_dialogue_new_01` | dialogue availability |
| `camp_letter_new_01` | personal correspondence |
| `camp_memory_reveal_01` | sacred narrative reveal |
| `camp_evidence_reveal_01` | proof/discovery reveal |

## Placeholder Synthesis Recipe

Use fast, repeatable synthesis or library construction instead of bespoke sound design at this stage.

Per-cue recipe:

1. One transient layer for the read.
2. One body layer for category identity.
3. Optional tiny tail only when required by semantic weight.

Lane palette:

- `battle_hit_*`: wood/metal impact, muted click, light grit.
- `battle_pain_*`: harsher snap, cloth tear, downward tilt.
- `battle_miss_*`: filtered whoosh, scrape-through, low body.
- `battle_counter_*`: deflect or recoil transient, more sting than hit confirm.
- `battle_boss_*`: seal stamp, barred pulse, ember edge, no roar.
- `battle_state_*`: broad but clipped pulse markers.
- `ui_*`: dry ticks, slides, restrained glass/metal.
- `camp_*`: parchment, cloth, clasp, low ember warmth, intimate soft harmonics.

## Loudness And Duration Targets

- `ui_*`: `60-220 ms`, softest lane
- `camp_*`: `120-380 ms`, except reveals up to `800 ms`
- `battle_hit/miss/counter/pain`: `90-220 ms`
- `battle_state`: `220-360 ms`
- `battle_boss`: `260-520 ms`

Relative priority:

1. `battle_boss_*`
2. `battle_pain_*`
3. `battle_hit_*` and `battle_counter_*`
4. `battle_action_*` and `battle_state_*`
5. `camp_*`
6. `ui_*`

## Runtime Mapping Order

Engineering should wire placeholders in this order so the highest gameplay risk is covered first.

1. Battle threat and outcome readability:
- `battle_boss_mark_warn_01`
- `battle_boss_command_warn_01`
- `battle_boss_charge_impact_01`
- `battle_hit_confirm_01`
- `battle_miss_01`
- `battle_counter_hit_01`
- `battle_state_enemy_phase_01`
- `battle_state_player_phase_01`

2. Battle utility and non-danger surfaces:
- `ui_inventory_open_01`
- `ui_inventory_close_01`
- `ui_common_cancel_01`
- `ui_common_confirm_01`

3. Camp recommit and loadout loop:
- `camp_next_battle_confirm_01`
- `camp_party_assign_01`
- `camp_party_select_01`
- `camp_loadout_weapon_cycle_01`
- `camp_loadout_armor_cycle_01`
- `camp_loadout_accessory_cycle_01`
- `ui_panel_tab_shift_01`
- `camp_recommend_focus_01`

## Import Table Recommendation

Use a single cue manifest keyed by cue ID.
Do not create alias names during the placeholder pass.

Suggested columns:

| cue_id | asset_path | lane | priority | duration_ms | notes |
| --- | --- | --- | --- | --- | --- |

Example rows:

| `battle_boss_mark_warn_01` | `res://assets/audio/sfx/placeholders/battle/battle_boss_mark_warn_01.ogg` | `battle_boss` | `critical` | `360` | `seal stamp plus ember rise` |
| `ui_inventory_open_01` | `res://assets/audio/sfx/placeholders/ui/ui_inventory_open_01.ogg` | `ui_panel` | `medium` | `220` | `dry open, no camp warmth` |
| `camp_party_assign_01` | `res://assets/audio/sfx/placeholders/camp/camp_party_assign_01.ogg` | `camp_party` | `medium` | `220` | `confirm plus cloth settle` |

## QA Acceptance

The placeholder pack is acceptable when:

1. Every Tier 0 cue resolves to a unique file path.
2. No camp or UI placeholder is brighter or more urgent than `battle_hit_confirm_01`.
3. `battle_boss_mark_warn_01` and `battle_boss_charge_impact_01` are unmistakably stronger than routine utility cues.
4. `battle_miss_01` reads lighter than `battle_hit_confirm_01`.
5. `battle_counter_hit_01` reads more dangerous than a normal hit confirm without becoming boss-grade.
6. Repeated loadout actions remain tolerable under rapid cycling.
7. The existing integration runner can be extended to verify cue IDs against manifest entries without name translation.

## Out Of Scope

- full soundtrack direction and adaptive music layering
- final Foley, VO, or environmental ambience
- monetization-facing audio
- bespoke chapter-specific one-off stingers
- final mastering and platform loudness compliance
