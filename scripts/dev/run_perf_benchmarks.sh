#!/usr/bin/env bash
set -euo pipefail

ROOT="/Volumes/AI/tactics"

run_and_verify() {
  local label="$1"
  local script_path="$2"
  local output

  echo "[perf] running ${label}: ${script_path}"
  output="$(godot4 --headless --path "$ROOT" --script "$script_path")"
  printf '%s
' "$output"

  PERF_OUTPUT="$output" python3 - "$label" <<'PY'
import json
import os
import sys

label = sys.argv[1]
lines = [line.strip() for line in os.environ['PERF_OUTPUT'].splitlines() if line.strip()]
perf_lines = [line for line in lines if line.startswith('PERF_RESULT=')]
if not perf_lines:
    raise SystemExit(f"{label}: missing PERF_RESULT output")
payload = json.loads(perf_lines[-1].split('=', 1)[1])
if 'benchmark' not in payload:
    raise SystemExit(f"{label}: PERF_RESULT missing benchmark field")
print(f"[perf] verified {label}: {payload['benchmark']}")
PY
}

run_and_verify "core_loop" "res://scripts/dev/core_loop_perf_runner.gd"
run_and_verify "ai_decision" "res://scripts/dev/ai_decision_perf_runner.gd"
