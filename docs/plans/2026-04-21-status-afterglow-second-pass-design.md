# Status Afterglow Second Pass Design

**Scope:** status afterglow 12차

## Goal

이미 추가된 afterglow가 존재 여부만 보이는 수준을 넘어서,
motion stack에도 명시적으로 남아 QA와 디버깅에서 방금 해제된 상태를 바로 읽을 수 있게 만든다.

## Recommended Approach

- 기존 `status_afterglow`를 유지한다.
- `status_motion_stack`에 afterglow profile이 실제로 남는지 고정한다.
- 개별 snapshot field와 stack field를 함께 검증한다.

## Verification

- `status_visual_runner.gd`에서 charm/boss_mark clear 후 `afterglow:*` motion stack entry를 확인한다.
