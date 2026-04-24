# Lategame Result Relief Eleventh Pass Design

**Scope:** late-game control relief result summary 11차

## Goal

late-game control object relief가 전투 중 HUD에만 남는 수준을 넘어서,
전투 승리 후 `battle result summary`에도 어떤 control relief가 확보됐는지 남기게 만든다.

## Recommended Approach

- `BattleController` victory summary에 `control_relief_entries`를 추가한다.
- 레테 gate latch, 멜키온 archive lectern, 카르온 anchor chain 상태를 각각 result entry로 변환한다.
- `lategame_boss_pattern_runner.gd`에서 forced victory 후 summary payload를 검증한다.

## Verification

- `lategame_boss_pattern_runner.gd` PASS
