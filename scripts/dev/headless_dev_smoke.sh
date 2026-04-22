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

run_step "Core loop contracts" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/m1_core_loop_contract_runner.gd

run_step "Battle integration asset load" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/battle_integration_preview_runner.gd

echo "[PASS] headless_dev_smoke completed."
