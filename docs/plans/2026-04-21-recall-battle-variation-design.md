# Recall Battle Variation Design

**Scope:** `HUNT_BASIL`, `HUNT_SARIA`, `HUNT_LETE` stage-data variation pass

## Goal

회상 토벌전 3종이 본편 보스를 단순 재호출한 전투처럼 보이지 않도록,
각 hunt stage에 별도의 압박 리듬이 드러나는 전장 변주를 추가한다.

## Recommended Approach

시스템을 늘리지 않고 stage data만 강화한다.

- 각 hunt에 추가 적 1기
- 각 hunt에 지형/차단선 변주 1단계
- `hunt_battle_runner.gd`에서 stage boot 결과로 바로 검증

## Variants

- HUNT_BASIL
  - 침수선 중앙 압박을 더 빨리 체감하게 하도록 중앙 차단선/침수 구간을 강화
  - 보조 적 1기 추가

- HUNT_SARIA
  - hymn corridor를 더 또렷하게 읽히도록 지형 셀과 차단 셀을 강화
  - 보조 적 1기 추가

- HUNT_LETE
  - 추격 마당을 더 좁은 처형 전장처럼 읽히게 하도록 북쪽 이송문/중앙 협로 압박 강화
  - 보조 적 1기 추가

## Verification

- `scripts/dev/hunt_battle_runner.gd`에 stage-specific assertions를 먼저 추가한다.
- 각 hunt stage `.tres`만 수정한다.
- 최종적으로 `hunt_battle_runner.gd`와 `hunt_boss_variant_runner.gd`를 다시 통과시킨다.
