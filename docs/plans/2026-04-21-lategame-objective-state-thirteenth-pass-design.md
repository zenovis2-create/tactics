# Lategame Objective State Thirteenth Pass Design

**Scope:** late-game relief objective_state id 13차

## Goal

late-game control relief가 flag/text/result까지 반영된 상태에서,
`objective_state.state_id` 자체도 dedicated relief id로 바뀌게 만들어 downstream surface가 더 정확히 읽히게 만든다.

## Recommended Approach

- `BattleController.get_objective_state_snapshot()`가 late-game relief flags를 우선 반영하게 만든다.
- 레테/멜키온/카르온에 각각 dedicated relief state id를 반환한다.
- runner에서 objective_state.state_id를 직접 확인한다.

## Verification

- `lategame_boss_pattern_runner.gd` PASS
