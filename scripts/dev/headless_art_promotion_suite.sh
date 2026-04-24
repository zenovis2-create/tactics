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

run_step "Character visual layer" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/character_visual_layer_runner.gd

run_step "Character token art preference" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/character_token_art_runner.gd

run_step "Character animation readiness" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/character_animation_ready_runner.gd

run_step "Battle sprite roster gallery" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/battle_sprite_roster_gallery_runner.gd

run_step "Battle integration preview" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/battle_integration_preview_runner.gd

run_step "Campaign panel presentation card" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/campaign_panel_presentation_card_runner.gd

run_step "Campaign panel party support" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/campaign_panel_party_support_runner.gd

run_step "Campaign panel field sword support" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/campaign_panel_field_sword_runner.gd

run_step "Field sword preview routing" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/field_sword_preview_runner.gd

run_step "Gate-control production object slot" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/gate_control_object_slot_runner.gd

run_step "Interaction object runtime routing" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/interaction_object_routing_runner.gd

run_step "CH02 fortress preview" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch02_fortress_art_preview_runner.gd

run_step "CH03 forest trap preview" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch03_forest_trap_preview_runner.gd

run_step "CH04 sacred machinery preview" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch04_sacred_machinery_preview_runner.gd

run_step "CH05 archive pressure preview" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch05_archive_pressure_preview_runner.gd

run_step "CH07 ritual city preview" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch07_ritual_city_preview_runner.gd

run_step "CH08 split-line preview" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch08_split_line_preview_runner.gd

run_step "CH09B root archive preview" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch09b_root_archive_preview_runner.gd

run_step "CH06 iron keep preview" \
  "$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/ch06_iron_keep_preview_runner.gd

run_step "Visual QA suite" \
  "$ROOT_DIR/scripts/dev/run_visual_qa_suite.sh"

echo "[PASS] headless_art_promotion_suite completed."
