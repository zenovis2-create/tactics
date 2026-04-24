# Lategame Transition Seventh Pass Design

**Scope:** late-game control object transition surface 7차

## Goal

late-game control object가 flag만 남기는 수준을 넘어서,
해결 직후 HUD에 `route cut / archive stabilized / bell line broken`을 전용 transition reason으로 남긴다.

## Recommended Approach

- `battle_controller.gd` interaction flag 처리에서 전용 reason을 발화한다.
- `battle_hud.gd` telegraph surface에 각 reason 전용 label/detail을 추가한다.
- `lategame_boss_pattern_runner.gd`에서 transition_reason_label + telegraph_label을 함께 확인한다.

## Verification

- `lategame_boss_pattern_runner.gd` PASS
