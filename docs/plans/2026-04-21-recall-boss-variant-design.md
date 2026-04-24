# Recall Boss Variant Design

**Scope:** `HUNT_BASIL`, `HUNT_SARIA`, `HUNT_LETE` recall hunt boss variant deepening

## Goal

회상 토벌전 전용 보스가 본편 보스의 축소판처럼 보이지 않게 만들고,
회상 전투의 optional objective가 무너지거나 유지되었을 때 보스 행동이 분명하게 갈라지도록 한다.

## Recommended Approach

각 hunt에 objective-driven follow-up action을 1개씩 추가한다.

- HUNT_BASIL
  - 침수선 생존이 이미 확보된 뒤에는 단순 `banner_betrayal` 대신 `backwash_surge` 계열 압박으로 전열을 다시 흔든다.

- HUNT_SARIA
  - 기도 행렬 보존이 깨진 뒤에는 단순 `memory_burn` 대신 `choir_break` 계열 압박으로 mark/fear/bond suppression을 한 번에 건다.

- HUNT_LETE
  - 흑견 보존이 깨지고 marked ally가 생기면 기존 reckless charge보다 더 직접적인 execute pressure를 우선한다.

## Why This Approach

- 기존 stage/objective/HUD contract를 유지한다.
- `battle_controller.gd`와 `hunt_boss_variant_runner.gd`만 만지면 된다.
- 회상 전투의 replay value가 “같은 보스 재탕”이 아니라 “다른 전투 템포”로 읽히게 된다.

## Verification

- `scripts/dev/hunt_boss_variant_runner.gd`에 새 실패 테스트를 먼저 추가한다.
- 각 새 액션은 objective flag + HUD transition reason을 남겨야 한다.
- 최종적으로 `hunt_boss_variant_runner.gd`와 `hunt_battle_runner.gd`를 다시 통과시킨다.
