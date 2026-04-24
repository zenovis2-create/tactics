#!/bin/zsh
set -euo pipefail

ROOT_DIR="/Volumes/AI/tactics"
GODOT_BIN="${GODOT_BIN:-godot4}"

"$GODOT_BIN" --headless --path "$ROOT_DIR" --script res://scripts/dev/chapter_visual_capture_runner.gd >/tmp/tactics-visual-capture.log || exit $?
python3 "$ROOT_DIR/scripts/dev/chapter_visual_diff_report.py"
