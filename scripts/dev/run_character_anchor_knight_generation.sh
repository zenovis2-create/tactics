#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROMPT_FILE="$ROOT_DIR/assets/characters/character_anchor_knight/generation_prompt_v01.txt"
OUT_DIR="$ROOT_DIR/assets/characters/character_anchor_knight/source"
OUT_FILE="$OUT_DIR/character_anchor_knight_sheet_source_v01.png"
CLI="/Users/daehan/.codex/skills/imagegen/scripts/image_gen.py"

if [[ ! -f "$CLI" ]]; then
  echo "[FAIL] image generation CLI not found: $CLI"
  exit 1
fi

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "[FAIL] OPENAI_API_KEY is not set."
  echo "Set the key, then rerun:"
  echo "  export OPENAI_API_KEY='...'"
  exit 1
fi

mkdir -p "$OUT_DIR"

python3 "$CLI" generate \
  --prompt-file "$PROMPT_FILE" \
  --out "$OUT_FILE" \
  --use-case stylized-concept \
  --subject "worn veteran knight, sword and shield turnaround" \
  --style "painterly diorama-style stylized 3D concept art" \
  --composition "front, side, 3/4 full-body turnaround on neutral studio background" \
  --lighting "soft studio lighting, readable forms" \
  --palette "muted iron gray, dark leather, deep navy cloth accent" \
  --materials "worn steel plate armor, leather straps, cloth tabard accent, large shield focal point" \
  --constraints "medium stylized proportions, broad shoulders, compact legs, large shield, minimal fine detail, tactical readability" \
  --negative "photorealism, ornate filigree, thin chains, tiny ornaments, busy background, extreme pose, decorative clutter"

echo "[PASS] Generated $OUT_FILE"
