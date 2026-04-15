#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  "project.godot"
  "scenes/Main.tscn"
  "scenes/battle/BattleScene.tscn"
  "scripts/battle/battle_controller.gd"
  "scripts/data/stage_data.gd"
  "data/stages/tutorial_stage.tres"
)

for required in "${required_files[@]}"; do
  if [[ ! -f "$required" ]]; then
    echo "[FAIL] Missing required file: $required"
    exit 1
  fi
done

missing_count=0
while IFS= read -r path; do
  local_path="${path#res://}"
  if [[ ! -f "$local_path" ]]; then
    echo "[FAIL] Broken reference: $path"
    missing_count=$((missing_count + 1))
  fi
done < <(rg -No --no-filename 'res://[^" )]+' -g '*.gd' -g '*.tscn' -g '*.tres' scenes scripts data | sort -u)

if [[ $missing_count -gt 0 ]]; then
  echo "[FAIL] Found $missing_count broken res:// references"
  exit 1
fi

echo "[PASS] Runnable Gate 0 integrity check passed."
