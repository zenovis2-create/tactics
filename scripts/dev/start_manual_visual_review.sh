#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/Volumes/AI/tactics"
OPEN_BATTLE="$ROOT_DIR/scripts/dev/open_representative_battle.sh"

TARGET="${1:-ch07}"

case "$TARGET" in
  ch07)
    SCENE_LABEL="CH07 representative battle"
    ;;
  ch09b)
    SCENE_LABEL="CH09B representative battle"
    ;;
  ch10)
    SCENE_LABEL="CH10 representative battle"
    ;;
  *)
    echo "[FAIL] unknown target: $TARGET"
    echo "usage: $0 {ch07|ch09b|ch10}"
    exit 1
    ;;
esac

cat <<EOF
[MANUAL REVIEW]
scene: $SCENE_LABEL

check first:
- Chapter Identity
- Movement Feel
- Attack Timing
- HUD / Framing

send feedback as:
장면: $SCENE_LABEL
항목:
문제:
EOF

exec "$OPEN_BATTLE" "$TARGET"
