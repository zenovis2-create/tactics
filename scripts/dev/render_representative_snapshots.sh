#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-/tmp/tactics-representative-snaps}"
mkdir -p "$OUT_DIR"

run_capture() {
  local scene_path="$1"
  local out_name="$2"
  rm -f "$OUT_DIR"/${out_name}*.png 2>/dev/null || true
  godot4 --path /Volumes/AI/tactics --scene "$scene_path" --write-movie "$OUT_DIR/$out_name.png" --quit-after 2 --disable-vsync --resolution 1348x816 >/tmp/"$out_name".log 2>&1
}

run_capture "res://scenes/dev/tutorial_representative_battle.tscn" "tutorial"
run_capture "res://scenes/dev/ch03_representative_battle.tscn" "ch03"
run_capture "res://scenes/dev/ch07_representative_battle.tscn" "ch07"
run_capture "res://scenes/dev/ch10_representative_battle.tscn" "ch10"
run_capture "res://scenes/dev/ch02_04_representative_battle.tscn" "ch02_04"
run_capture "res://scenes/dev/ch09a_01_representative_battle.tscn" "ch09a_01"
run_capture "res://scenes/dev/ch04_01_representative_battle.tscn" "ch04_01"
run_capture "res://scenes/dev/ch08_01_representative_battle.tscn" "ch08_01"
python3 /Volumes/AI/tactics/scripts/dev/build_representative_contact_sheet.py "$OUT_DIR" >/tmp/representative_contact_sheet.log 2>&1

printf "%s\n" "$OUT_DIR/tutorial00000001.png" "$OUT_DIR/ch0300000001.png" "$OUT_DIR/ch0700000001.png" "$OUT_DIR/ch1000000001.png" "$OUT_DIR/ch02_0400000001.png" "$OUT_DIR/ch09a_0100000001.png" "$OUT_DIR/ch04_0100000001.png" "$OUT_DIR/ch08_0100000001.png" "$OUT_DIR/representative_contact_sheet.png"
