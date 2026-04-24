# Late-Game Battlefield Rule Design

**Scope:** CH08_05, CH09B_05, CH10_05 late-game battlefield rule revision pass

## Goal

후반 보스의 phase/action이 단순 수치 변화나 특수기 선택에만 머물지 않고,
실제로 전장의 이동/지형 판독을 바꾸는 규칙 변화를 남기게 만든다.

## Recommended Approach

세 스테이지에 phase-linked battlefield rewrite를 1개씩 추가한다.

- CH08_05
  - `berserk_rush` 진입 시 추격선을 더 직접적으로 읽히게 하도록 shadow lane을 확장하고 일부 막힌 길을 연다.

- CH09B_05
  - `archive_mode` 진입 시 abyss 주변 셀을 `revision` terrain으로 재기록해 “전장 규칙 개정”을 실제 보드 상태로 보여 준다.

- CH10_05
  - `name_severance` 또는 `final_toll` 구간에서 bell pressure lane을 추가해 중앙 성채 진입선이 더 좁게 읽히도록 만든다.

## Constraints

- 새 시스템을 만들지 않는다.
- `battle_controller.gd`에서 stage_data mutation과 redraw만 추가한다.
- existing boss pattern / HUD / objective contract와 충돌하면 안 된다.

## Verification

- `scripts/dev/lategame_boss_pattern_runner.gd`에 terrain/blocked-cell 기반 실패 테스트를 먼저 추가한다.
- 최종적으로 `lategame_boss_pattern_runner.gd`와 `ch06_ch10_boss_surface_runner.gd`를 다시 통과시킨다.
