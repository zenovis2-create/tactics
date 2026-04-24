# Save/Load Fifth Pass Design

**Scope:** 수동 저장 복귀 통합 러너 5차

## Goal

이미 고정된 `수동 로드`, `autosave defeat recovery`, `retry`, `title load panel` 사이에서
비어 있던 `수동 저장 데이터 복귀` 경로를 별도 통합 러너로 묶는다.

## Recommended Approach

- production 로직은 바꾸지 않는다.
- `manual_save_recovery_runner.gd`를 추가한다.
- 흐름은 `새 게임 -> 전투 중 수동 저장 -> live data 오염 -> defeat surface 진입 -> saved data 복귀 -> 같은 stage/core-loop 재개`로 고정한다.

## Verification

- `manual_save_recovery_runner.gd` PASS

