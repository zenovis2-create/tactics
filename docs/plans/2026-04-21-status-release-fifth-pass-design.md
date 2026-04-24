# Status Release Fifth Pass Design

**Scope:** 상태 해제 release animation 5차

## Goal

status surface가 `activate -> sustain`까지만 있는 상태에서,
해제 순간에도 어떤 상태가 막 사라졌는지 읽히는 `release profile`을 추가한다.

## Recommended Approach

- `UnitActor`에 `status_release` tween/profile을 추가한다.
- primary status가 비워질 때 직전 상태 기준 release profile을 실행한다.
- snapshot에 `status_release_active`, `status_release_profile`을 노출한다.

## Verification

- `status_visual_runner.gd`에서 charm clear / boss_mark clear 시 release profile을 확인한다.
