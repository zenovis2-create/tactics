#!/usr/bin/env bash
set -uo pipefail

ROOT="/Volumes/AI/tactics"
LOG_DIR="$ROOT/logs"
PID_FILE="${PID_FILE:-$LOG_DIR/paperclip_overnight.pid}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/paperclip_overnight.log}"
SCRIPT_PATH="/Volumes/AI/tactics/scripts/dev/paperclip_overnight_runner.sh"
HB_MAX_SECS="${HB_MAX_SECS:-45}"
CYCLE_SLEEP_SECS="${CYCLE_SLEEP_SECS:-900}"

mkdir -p "$LOG_DIR"

is_runner_pid() {
  local pid="$1"
  ps -p "$pid" -o command= 2>/dev/null | grep -F "$SCRIPT_PATH" >/dev/null 2>&1
}

if [[ -f "$PID_FILE" ]]; then
  OLD_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ -n "${OLD_PID:-}" ]] && kill -0 "$OLD_PID" 2>/dev/null && is_runner_pid "$OLD_PID"; then
    echo "paperclip overnight runner already active: $OLD_PID"
    exit 0
  fi
fi

echo $$ > "$PID_FILE"
trap 'rm -f "$PID_FILE"' EXIT

run_hb() {
  local agent_id="$1"
  local label="$2"
  local tmp_file
  local hb_pid
  local start_ts
  local timed_out=0
  local rc=0

  tmp_file="$(mktemp)"

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] heartbeat:start $label" >>"$LOG_FILE"
  (
    paperclipai heartbeat run \
      -a "$agent_id" \
      --source automation \
      --trigger system \
      --timeout-ms 120000
  ) >"$tmp_file" 2>&1 &
  hb_pid=$!
  start_ts="$(date +%s)"

  while kill -0 "$hb_pid" 2>/dev/null; do
    if (( $(date +%s) - start_ts >= HB_MAX_SECS )); then
      timed_out=1
      kill "$hb_pid" 2>/dev/null || true
      break
    fi
    sleep 5
  done

  if ! wait "$hb_pid" 2>/dev/null; then
    rc=$?
  fi

  cat "$tmp_file" >>"$LOG_FILE"
  rm -f "$tmp_file"

  if (( timed_out == 1 )); then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] heartbeat:end $label timed_out_after=${HB_MAX_SECS}s (continuing)" >>"$LOG_FILE"
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] heartbeat:end $label rc=$rc" >>"$LOG_FILE"
  fi
}

FAST_IDS=(
  "cb69b385-4185-4c4f-b30f-af01ce0ba00e:chief_of_staff"
  "ddb2c413-5241-4aab-b088-fab18c75f9cc:godot_lead_engineer"
  "fbcdb7dd-b54c-4092-8697-33c9d85e6f8e:gameplay_engineer"
  "3f2e56e2-1a0b-4f9f-8a8c-bf9c6510c441:ui_engineer"
  "cc214efd-6bb4-4cdc-9e85-0727f8d6175d:qa_director"
  "7c160e1b-7dec-472a-b372-6f5e33cdc26a:content_designer"
  "218f303b-6b35-4569-a9b9-ca71a247b8e4:narrative_director"
  "40092bfb-eeb5-4b29-9679-6fb329611922:art_director"
  "28e02dd5-346c-4bcc-b836-b61910419c19:audio_director"
  "0e61bb22-03b7-4fb1-b9e6-4b6159e87b78:uiux_designer"
  "ea59e69c-5120-4033-95a0-7a0a83bd808a:technical_artist"
)

SLOW_IDS=(
  "c5abf74e-ed80-4df2-910f-f22202036157:systems_designer"
  "dd223d85-841a-487d-a072-9f5349ab1478:game_director"
  "a25d45b9-5fca-44ba-946b-e26ef9a8ce54:technical_director"
)

cycle=0
echo "[$(date '+%Y-%m-%d %H:%M:%S')] overnight runner boot" >>"$LOG_FILE"

while true; do
  cycle=$((cycle + 1))
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] cycle:$cycle begin" >>"$LOG_FILE"

  for item in "${FAST_IDS[@]}"; do
    run_hb "${item%%:*}" "${item##*:}"
  done

  if (( cycle % 2 == 0 )); then
    for item in "${SLOW_IDS[@]}"; do
      run_hb "${item%%:*}" "${item##*:}"
    done
  fi

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] cycle:$cycle sleep" >>"$LOG_FILE"
  sleep "$CYCLE_SLEEP_SECS"
done
