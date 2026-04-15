# UI and Camp SFX Cue Map v1

## Purpose

This document defines the first-pass UI and camp SFX direction for `Memory Tactics RPG`.
It covers the baseline interaction set used by the current `CampaignPanel` and `BattleHUD`
surfaces and gives implementation and QA a concrete cue map they can verify.

Primary goals:

- keep battle feedback readable by preventing camp and utility cues from sounding urgent
- make camp feel restorative, tactile, and story-aware rather than sterile
- give every repeated UI action a stable sonic meaning
- define naming and variant rules so assets can be wired without ambiguity

## Audio Pillars

### 1. Tactical clarity first

- Utility cues must sit behind combat-critical events in loudness, brightness, and transient weight.
- No camp or neutral UI cue should be confused with damage, boss warnings, phase changes, or mission failure risk.
- Urgent upper-mid stingers are reserved for battle-danger states, not menu affordances.

### 2. Rest after pressure

- Camp audio should feel like decompression after battle.
- Use softer attacks, shorter tails, warmer materials, and gentler high-frequency content than battle cues.
- The player should feel "safe to think" within 1 to 2 seconds of entering camp.

### 3. Memory and ash identity

- Core material palette:
  - muted metal ticks
  - dry parchment/fabric motion
  - soft glass harmonics
  - low ember pulses
  - restrained choral-air textures for memory/revelation moments
- Avoid glossy sci-fi bleeps or comedic cartoony pops.

### 4. Repeatable semantics

- `confirm` should always feel forward-moving.
- `cancel` should always feel controlled and non-punitive.
- `open` should imply reveal.
- `close` should imply release/fold-away.
- `new lore / memory / letter` should imply emotional significance, not system danger.

## Mix Guardrails

- Default UI utility cues target a perceived level clearly below battle hit confirms and warning cues.
- Keep most utility cues within short durations:
  - micro actions: `60-180 ms`
  - panel and transition cues: `180-450 ms`
  - emotional reveal accents: `400-900 ms`
- Do not stack more than one prominent transient per input.
- Avoid sustained tonal beds on repeated taps.
- If multiple UI cues could fire together, only the highest-priority semantic cue should play.

Priority order:

1. battle-critical warning / damage / objective state
2. battle command confirm / cancel
3. camp reveal / unlock / letter / memory cue
4. generic menu utility click/open/close

## Emotional Audio Beats

### Return to camp after battle

- Goal: signal exhale, safety, and a shift from execution to reflection.
- Sound: low ember bloom plus soft paper/cloth settle.
- Avoid triumph-brass language unless the screen is explicitly a victory result surface.

### New recommendation or next-step prompt

- Goal: orient the player without pressure.
- Sound: small upward two-note glass/metal gesture with muted tail.

### Memory / evidence / letter reveal

- Goal: mark narrative importance and curiosity.
- Sound: airy harmonic accent over a tactile page or seal movement layer.
- `memory` should feel more sacred than `evidence`.
- `letter` should feel personal and intimate, not mystical.

### Loadout and party management

- Goal: make preparation feel deliberate and clean.
- Sound: dry material ticks, slot settles, light clasps, subdued rune shimmer for equipment changes.

### Close and back out

- Goal: preserve momentum and emotional calm.
- Sound: short downward release with no shame or failure implication.

## Cue Map

| Event | Cue ID | Intent | Sonic direction | Dur. | Priority |
| --- | --- | --- | --- | --- | --- |
| Generic button tap | `ui_common_tap_soft_01` | acknowledge neutral press | dry wood/metal tick, low brightness | 70-120 ms | low |
| Primary CTA press | `ui_common_tap_primary_01` | heavier affirmative tap | firmer tick with soft low click body | 90-140 ms | medium |
| Confirm / continue | `ui_common_confirm_01` | commit and move forward | upward two-note metal/glass gesture, restrained tail | 180-260 ms | medium |
| Cancel / back | `ui_common_cancel_01` | reverse gracefully | short downward felt/pluck release | 120-180 ms | medium |
| Invalid action | `ui_common_invalid_01` | inform without annoyance | muted double tick with soft damped buzz | 140-220 ms | medium |
| Open panel / sheet | `ui_panel_open_01` | reveal information | light whoosh plus tactile frame settle | 220-320 ms | medium |
| Close panel / sheet | `ui_panel_close_01` | fold away information | reversed settle, shorter than open | 180-260 ms | medium |
| Tab switch | `ui_panel_tab_shift_01` | lateral navigation | thin brushed tick plus soft slide | 120-180 ms | low |
| Overlay dismiss | `ui_panel_dismiss_01` | exit via scrim / outside tap | subtle cloth-air release | 100-160 ms | low |
| Camp enter | `camp_hub_enter_01` | arrive in safe planning space | ember bloom, low breath, paper settle | 600-900 ms | high |
| Recommendation card focus | `camp_recommend_focus_01` | guide attention | gentle upward sparkle with warm body | 220-340 ms | medium |
| System unlock notice | `camp_unlock_notice_01` | meaningful new option | three-step rise, brighter than confirm but not heroic | 350-520 ms | high |
| New dialogue available | `camp_dialogue_new_01` | social content available | intimate soft chime with paper accent | 260-380 ms | medium |
| New letter available | `camp_letter_new_01` | personal correspondence | envelope/seal tactile layer plus warm bell tone | 320-480 ms | high |
| Memory entry revealed | `camp_memory_reveal_01` | sacred/story beat | airy harmonic swell with ember tail | 500-800 ms | high |
| Evidence entry revealed | `camp_evidence_reveal_01` | discovered proof | firmer parchment snap plus restrained tone | 300-460 ms | medium |
| Party member selected | `camp_party_select_01` | focus one unit | soft emblem tick with low body | 120-180 ms | low |
| Assignment changed | `camp_party_assign_01` | roster commitment | confirm variant plus subtle cloth/gear settle | 180-260 ms | medium |
| Weapon cycle | `camp_loadout_weapon_cycle_01` | weapon browse / equip | metal slide + latch | 160-240 ms | medium |
| Armor cycle | `camp_loadout_armor_cycle_01` | armor browse / equip | leather/cloth move + clasp tick | 170-260 ms | medium |
| Accessory cycle | `camp_loadout_accessory_cycle_01` | accessory browse / equip | small charm ring + soft click | 150-230 ms | medium |
| Inventory open from battle HUD | `ui_inventory_open_01` | utility inspection in battle | neutral panel-open variant, more dry than camp | 180-260 ms | medium |
| Inventory close from battle HUD | `ui_inventory_close_01` | return focus to battle | short neutral fold-away | 160-220 ms | medium |
| Next battle CTA | `camp_next_battle_confirm_01` | leave safety and recommit | confirm base plus low pulse hinting forward motion | 260-380 ms | high |

## Mapping To Current Runtime Surfaces

### `scripts/battle/battle_hud.gd`

- `inventory_button.pressed` -> `ui_inventory_open_01`
- `close_inventory_button.pressed` -> `ui_inventory_close_01`
- `cancel_button.pressed` -> `ui_common_cancel_01`
- `wait_button.pressed` -> `ui_common_confirm_01`
- `end_turn_button.pressed` -> use battle-specific cue later, not the camp set
- scrim dismiss via `dismiss_overlay_at_position()` -> `ui_panel_dismiss_01`

### `scripts/campaign/campaign_panel.gd`

- section tab buttons -> `ui_panel_tab_shift_01`
- `advance_button.pressed` in camp mode -> `camp_next_battle_confirm_01`
- party roster selection -> `camp_party_select_01`
- assignment button -> `camp_party_assign_01`
- weapon / armor / accessory buttons -> matching `camp_loadout_*`
- panel show from battle-to-camp transition -> `camp_hub_enter_01`
- recommendation card emphasis on first show -> `camp_recommend_focus_01`

## Naming Rules

Format:

`<domain>_<surface>_<action>_<variant>`

Rules:

- `domain`: `ui` or `camp`
- `surface`: `common`, `panel`, `party`, `loadout`, `memory`, `letter`, `inventory`, `hub`
- `action`: semantic verb, not button label
- `variant`: two-digit index, starting at `01`

Examples:

- `ui_common_confirm_01`
- `ui_panel_open_01`
- `camp_hub_enter_01`
- `camp_memory_reveal_01`

Do not use:

- raw implementation names such as `button_a`, `sfx12`, `menu2`
- screen-specific wording when the meaning is reusable
- mixed synonyms for the same action such as both `accept` and `confirm`

Semantic verb set:

- `tap`
- `confirm`
- `cancel`
- `invalid`
- `open`
- `close`
- `shift`
- `dismiss`
- `enter`
- `focus`
- `notice`
- `reveal`
- `select`
- `assign`
- `cycle`

## QA Verification Rules

Implementation and QA should be able to verify the following without subjective interpretation:

1. Every player-facing button in `BattleHUD` and `CampaignPanel` triggers exactly one mapped cue.
2. `confirm` and `cancel` semantics are consistent across battle utility and camp surfaces.
3. `camp_hub_enter_01` fires once on entry, not on every widget refresh.
4. Reveal cues (`memory`, `evidence`, `letter`, `unlock`) only fire when content is newly surfaced, not on ordinary tab revisits.
5. Battle inventory open/close cues stay drier and less emotional than camp entry and records cues.
6. No camp cue masks battle-critical warnings when both occur near the same moment.
7. Asset names in import tables and runtime hooks match the naming format exactly.

## Not In Scope For This Pass

- character ability SFX
- damage, heal, kill, or boss telegraph cues
- map interaction object cues
- music system layering
- victory / defeat result stingers

Those belong to later battle-facing audio passes and must preserve stronger urgency than the UI and camp set defined here.
