#!/usr/bin/env bash
set -euo pipefail

ROOT="/Volumes/AI/tactics"
SNAP_DIR="$ROOT/.codex-representative-snaps"

echo "[1/5] battle art audit"
python3 "$ROOT/scripts/dev/battle_art_audit.py" \
  --write-json "$ROOT/docs/production/battle_art_manifest_v1.json" \
  --write-md "$ROOT/docs/reviews/2026-04-14-battle-art-audit-v1.md"

echo "[2/5] production art drop validation"
python3 "$ROOT/scripts/dev/battle_art_drop_validator.py"

echo "[3/5] runnable gate"
bash "$ROOT/scripts/dev/check_runnable_gate0.sh"

echo "[4/5] core battle ui smoke"
godot4 --headless --path "$ROOT" --script res://scripts/dev/m1_playtest_runner.gd
godot4 --headless --path "$ROOT" --script res://scripts/dev/m3_ui_runner.gd

echo "[5/5] representative snapshots"
bash "$ROOT/scripts/dev/render_representative_snapshots.sh" "$SNAP_DIR"

echo
echo "Artifacts:"
echo "- $ROOT/docs/production/battle_art_manifest_v1.json"
echo "- $ROOT/docs/reviews/2026-04-14-battle-art-audit-v1.md"
echo "- $ROOT/docs/production/battle_art_replacement_checklist_v1.md"
echo "- $ROOT/docs/production/battle_art_drop_validation_v1.json"
echo "- $ROOT/docs/reviews/2026-04-14-battle-art-drop-validation-v1.md"
echo "- $SNAP_DIR/representative_contact_sheet.png"
