#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/Volumes/AI/tactics"
GODOT_BIN="${GODOT_BIN:-godot4}"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
  echo "[FAIL] godot binary not found: $GODOT_BIN"
  exit 1
fi

TARGET="${1:-ch07}"

case "$TARGET" in
  ch07)
    SCENE="res://scenes/dev/ch07_representative_battle.tscn"
    ;;
  ch09b)
    SCENE="res://scenes/dev/ch09b_representative_battle.tscn"
    ;;
  ch10)
    SCENE="res://scenes/dev/ch10_representative_battle.tscn"
    ;;
  *)
    echo "[FAIL] unknown target: $TARGET"
    echo "usage: $0 {ch07|ch09b|ch10}"
    exit 1
    ;;
esac

exec "$GODOT_BIN" --path "$ROOT_DIR" "$SCENE"
