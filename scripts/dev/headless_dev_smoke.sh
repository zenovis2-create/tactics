#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

GODOT_BIN="${GODOT_BIN:-godot4}"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
  echo "[FAIL] godot binary not found: $GODOT_BIN"
  exit 1
fi

run_step() {
  local label="$1"
  shift
  echo "[RUN] $label"
  "$@"
  echo "[PASS] $label"
}

run_step "Headless boot" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --quit

run_step "Runnable Gate 0" \
  "$ROOT_DIR/scripts/dev/check_runnable_gate0.sh"

run_step "M1 playtest" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/m1_playtest_runner.gd

run_step "M2 campaign flow" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/m2_campaign_flow_runner.gd

run_step "M3 UI" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/m3_ui_runner.gd

run_step "Status visuals" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/status_visual_runner.gd

run_step "AI service contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ai_service_runner.gd

run_step "Status service contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/status_service_runner.gd

run_step "Combat service contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/combat_service_runner.gd

run_step "Skill levelup service contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/skill_levelup_service_runner.gd

run_step "Meta progression" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/meta_progression_runner.gd

run_step "Save/load UI contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/save_load_runner.gd

run_step "Save/load core loop" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/save_load_core_loop_runner.gd

run_step "Camp hub contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/camp_runner.gd

run_step "UI screens contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ui_screens_runner.gd

run_step "Hunt reward contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/hunt_reward_runner.gd

run_step "Stage resolution contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/stage_resolution_runner.gd

run_step "Bonus EXP pool contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/bonus_exp_pool_runner.gd

run_step "Battle result contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/battle_result_runner.gd

run_step "Hunt battle contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/hunt_battle_runner.gd

run_step "Defeat retry recovery" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/defeat_retry_recovery_runner.gd

run_step "Defeat autosave recovery" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/defeat_autosave_recovery_runner.gd

run_step "Title load panel recovery" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/title_load_panel_runner.gd

run_step "Campaign save panel roundtrip" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/campaign_save_panel_roundtrip_runner.gd

run_step "Manual save recovery" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/manual_save_recovery_runner.gd

run_step "Campaign save to title load" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/campaign_save_to_title_load_runner.gd

run_step "NG+ save/load" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ng_plus_save_load_runner.gd

run_step "NG+ title load panel" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ng_plus_title_load_panel_runner.gd

run_step "NG+ defeat to title load" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ng_plus_defeat_to_title_load_runner.gd

run_step "NG+ campaign save to title load" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ng_plus_campaign_save_to_title_load_runner.gd

run_step "NG+ recommended load" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ng_plus_recommended_load_runner.gd

run_step "NG+ defeat autosave" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ng_plus_defeat_autosave_runner.gd

run_step "Campaign save/load core loop" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/campaign_save_load_core_loop_runner.gd

run_step "Defeat to title load" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/defeat_to_title_load_runner.gd

run_step "Campaign save defeat title load" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/campaign_save_defeat_title_load_runner.gd

run_step "Camp save tab" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/s3_camp_save_tab_runner.gd

run_step "S1 battle feedback" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/s1_battle_feedback_runner.gd

run_step "S2 result and bond" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/s2_result_and_bond_runner.gd

run_step "S3 boss phase" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/s3_boss_phase_runner.gd

run_step "Command unlock visibility" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/command_unlock_runner.gd

run_step "Bond contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/bond_runner.gd

run_step "S4A unlock visibility" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/s4a_unlock_visibility_runner.gd

run_step "S4B skill unlock" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/s4b_skill_unlock_runner.gd

run_step "S7 unit progression" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/s7_unit_progression_runner.gd

run_step "Three-star progression" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/three_star_runner.gd

run_step "CH02 shell flow" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch02_shell_runner.gd

run_step "CH03 shell flow" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch03_shell_runner.gd

run_step "CH04 shell flow" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch04_shell_runner.gd

run_step "CH05 shell flow" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch05_shell_runner.gd

run_step "CH06 shell flow" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch06_shell_runner.gd

run_step "M4 progression" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/m4_progression_runner.gd

run_step "M5 reward" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/m5_reward_runner.gd

run_step "M6 telemetry" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/m6_telemetry_runner.gd

run_step "Core loop contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/m1_core_loop_contract_runner.gd

run_step "Battle integration asset load" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/battle_integration_preview_runner.gd

echo "[PASS] headless_dev_smoke completed."
