# Lategame Inventory Objective Tenth Pass Design

**Scope:** late-game relief inventory objective line 10차

## Goal

late-game control object relief가 상단 HUD objective에만 남는 수준을 넘어서,
Inventory panel의 `Objective:` 줄에도 동일하게 반영되게 만든다.

## Recommended Approach

- 기존 `_get_objective_text()` 재사용 구조를 유지한다.
- runner에 inventory objective line 기대값을 추가한다.
- relief objective text가 inventory snapshot에도 그대로 반영되는지 고정한다.

## Verification

- `lategame_boss_pattern_runner.gd`에서 inventory objective line shift 확인
