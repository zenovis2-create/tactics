# Late-Game Rule Object Fifth Pass Design

**Scope:** CH08_05, CH09B_05, CH10_05 late-game control objects affecting objective/state surface

## Goal

후반 보스전 control object가 단순 relief와 AI shift를 넘어서,
현재 objective/state surface 자체를 바꾸는 명시적 전장 판독 요소가 되게 만든다.

## Recommended Approach

- CH08_05
  - gate latch를 잡으면 `lete_hunt_collapsing` 같은 보조 objective flag를 닫아 추격 압박이 끊겼음을 즉시 읽히게 한다.

- CH09B_05
  - archive lectern을 잡으면 `melkion_truth_revealed` 흐름을 단순 유지가 아니라 “archive destabilized” surface로 직접 읽히게 한다.

- CH10_05
  - anchor chain과 bell dais를 모두 잡으면 `karon_cut_off`가 최종 objective 판독 축으로 남아, bell line이 완전히 끊겼음을 보여 준다.

## Verification

- `lategame_boss_pattern_runner.gd`에서 interaction 후 objective flags/HUD reason이 더 직접적으로 변하는지 검증
- `ch06_ch10_boss_surface_runner.gd` 회귀 확인
