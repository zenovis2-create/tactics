# Status Motion Stack Tenth Pass Design

**Scope:** status motion stack snapshot 10차

## Goal

상태 표면 animation layer가 많아졌으므로,
QA와 runner가 전체 active motion stack을 한 번에 읽을 수 있는 snapshot summary를 추가한다.

## Recommended Approach

- `UnitActor.get_status_visual_snapshot()`에 `status_motion_stack` 배열을 추가한다.
- active tween/profile 쌍을 `pulse:mark`, `icon:oblivion` 같은 compact string으로 노출한다.
- 기존 개별 snapshot field는 유지한다.

## Verification

- `status_visual_runner.gd`에서 charm/oblivion/mark/boss_mark motion stack 요약을 확인한다.
