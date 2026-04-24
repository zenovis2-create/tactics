# Recall Rule Object Design

**Scope:** `HUNT_BASIL`, `HUNT_SARIA`, `HUNT_LETE` recall hunts에 상호작용 오브젝트 기반 규칙 변주 추가

## Goal

회상 토벌전이 단순한 보스 재전투가 아니라,
플레이어가 전장 규칙을 직접 건드릴 수 있는 짧은 전술 문제로 읽히게 만든다.

## Recommended Approach

각 hunt에 상호작용 오브젝트 1개씩을 추가하고,
그 오브젝트가 pressure rule을 즉시 바꾸도록 한다.

- HUNT_BASIL
  - `sluice_wheel` 레버: flood spread 정지

- HUNT_SARIA
  - `choir_lectern` 제어점: queue pressure 지연

- HUNT_LETE
  - `gate_latch` 제어점: choke cell 해제

## Constraints

- 새 시스템을 만들지 않는다.
- `InteractiveObjectData` + `battle_controller.gd` stage-specific flag 처리만 추가한다.
- recall hunt의 기본 승리 조건은 유지한다.

## Verification

- `scripts/dev/hunt_battle_runner.gd`에 object authoring + interaction effect 실패 테스트를 먼저 추가한다.
- 최종적으로 `hunt_battle_runner.gd`와 `hunt_boss_variant_runner.gd`를 다시 통과시킨다.
