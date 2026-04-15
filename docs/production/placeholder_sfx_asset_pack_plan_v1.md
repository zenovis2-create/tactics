# Placeholder SFX Asset Pack Plan v1

## Purpose

This document turns the existing UI/camp and battle cue maps into an actionable placeholder asset pack plan.
It is intended for practical implementation sequencing, not soundtrack direction.

## Minimum Placeholder Pack

### UI / Camp

- `ui_inventory_open_01`
- `ui_inventory_close_01`
- `ui_common_cancel_01`
- `ui_common_confirm_01`
- `ui_panel_tab_shift_01`
- `camp_party_select_01`
- `camp_party_assign_01`
- `camp_loadout_weapon_cycle_01`
- `camp_loadout_armor_cycle_01`
- `camp_loadout_accessory_cycle_01`
- `camp_next_battle_confirm_01`
- `camp_recommend_focus_01`

### Battle

- `battle_state_player_phase_01`
- `battle_state_enemy_phase_01`
- `battle_hit_confirm_01`
- `battle_miss_01`
- `battle_counter_hit_01`
- `battle_boss_mark_warn_01`
- `battle_boss_command_warn_01`
- `battle_boss_charge_impact_01`

## Naming Rule

- Store placeholder files under `res://audio/sfx/`
- Use exact cue id as filename stem
- Preferred runtime-safe placeholder form:
  - `res://audio/sfx/<cue_id>.ogg`

## Integration Order

1. Battle-critical warning cues
2. Attack / miss / counter cues
3. Inventory open / close
4. Camp selection / assignment / loadout cycles
5. Recommendation / next-battle confirm cues

## Runtime Hook Targets

- `scripts/battle/battle_hud.gd`
- `scripts/campaign/campaign_panel.gd`
- `scripts/audio/audio_event_router.gd`

## Acceptance Criteria

- Every emitted cue id has a planned placeholder filename
- No placeholder set includes soundtrack/BGM work
- The order above is sufficient to wire meaningful audible feedback without reopening architecture
