# Save/Load Sixth Pass Design

**Scope:** NG+ start/save/load integration 6차

## Goal

기존 통합 러너들이 일반 저장/복귀 축을 덮고 있으므로,
이번 패스는 `타이틀 NG+ 시작 -> 전투 진입 -> 저장/로드 후 NG+ 상태 유지` 경로를 고정한다.

## Recommended Approach

- production 로직은 바꾸지 않는다.
- `ng_plus_save_load_runner.gd`를 추가한다.
- 흐름은 `NG+ source save seed -> title NG+ surface 확인 -> NG+ 시작 -> manual save -> slot load -> same stage/core-loop 재개`로 검증한다.

## Verification

- `ng_plus_save_load_runner.gd` PASS
