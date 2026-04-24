# Status Motion Signature Thirteenth Pass Design

**Scope:** status motion signature 13차

## Goal

이미 있는 `status_motion_stack`이 배열 기반이므로,
QA와 로그에서 더 빠르게 읽을 수 있는 compact `status_motion_signature` 문자열을 추가한다.

## Recommended Approach

- `UnitActor.get_status_visual_snapshot()`에 `status_motion_signature`를 추가한다.
- active motion stack을 `primary|pulse|idle|...` 같은 compact string으로 join한다.
- 기존 배열형 `status_motion_stack`은 유지한다.

## Verification

- `status_visual_runner.gd`에서 charm/oblivion/mark/boss_mark signature를 확인한다.
