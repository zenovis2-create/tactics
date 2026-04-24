# Save/Load Ninth Pass Design

**Scope:** NG+ visible recommended-load selection 9차

## Goal

NG+ source save가 보이는 타이틀 상태에서도,
`SaveLoadPanel`의 추천 이어하기가 실제 freshest slot을 정확히 고르는지 별도 러너로 고정한다.

## Recommended Approach

- production 로직은 바꾸지 않는다.
- `ng_plus_recommended_load_runner.gd`를 추가한다.
- manual NG+ source와 autosave의 `saved_at`을 의도적으로 갈라서
  - autosave가 더 최신인 경우
  - manual source가 더 최신인 경우
두 케이스를 모두 검증한다.

## Verification

- `ng_plus_recommended_load_runner.gd` PASS
