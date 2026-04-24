# Late-Game Boss Third Pass Design

**Scope:** CH08 Lete, CH09B Melkion, CH10 Karuon late-game boss pattern third-pass polish

## Goal

후반부 보스 3종의 전투 체감을 "기존 phase 전환 + 기존 특수기" 수준에서 한 단계 끌어올린다.

이번 패스의 목적은 대형 시스템 추가가 아니라, 이미 있는 phase/objective/HUD contract 위에
읽기 쉬운 특수 행동 1개씩을 얹어 각 보스의 전투 정체성을 더 분명하게 만드는 것이다.

## Constraints

- 기존 save/progression/cutscene contract는 건드리지 않는다.
- 새 행동은 현재 `battle_controller.gd`의 phase AI 선택 구조 안에서 처리한다.
- objective flag와 HUD transition reason을 함께 남겨 회귀 검증이 가능해야 한다.
- 새 작업은 headless runner에서 검증 가능해야 한다.

## Recommended Approach

각 보스마다 "현재 phase 의도"를 더 직접적으로 드러내는 특수 행동 1개를 추가한다.

- Lete
  - `shadow_feint` 이후 marked target을 강하게 추격하는 execute 계열 압박을 추가한다.
  - 목적: 레테의 전투를 "연막/분산"에서 "표식 후 추격 처형"으로 읽히게 만든다.

- Melkion
  - `revision_field` 이후 marked ally 또는 전열을 묶는 sentence 계열 압박을 추가한다.
  - 목적: 멜키온 전투를 "진실 삭제"에서 "전장 규칙 개정"으로 더 명확히 체감시키게 한다.

- Karuon
  - `name_severance`와 `final_toll` 사이를 잇는 bell/edict 계열 압박을 추가한다.
  - 목적: 이름 부름과 bond suppression 축을 전투 행위로 더 직접적으로 연결한다.

## Why This Approach

- 새 시스템을 만들지 않아 회귀 리스크가 낮다.
- 기존 phase thresholds, objective flags, HUD messaging, runner infrastructure를 재사용할 수 있다.
- 플레이어 체감은 크지만 구현 범위는 `battle_controller.gd`와 runner 수준으로 제한된다.

## Behavior Targets

### Lete

- berserk_rush phase에서 marked target이 있으면 새 압박 행동을 우선 고려한다.
- 행동 실행 시 boss event / objective flag / HUD reason이 남아야 한다.
- marked ally가 실제로 더 위험한 선택지로 읽혀야 한다.

### Melkion

- archive_mode phase에서 revision 계열 선행 동작 이후, ally terrain reliance나 mark 상태를 활용하는 후속 행동이 있어야 한다.
- 행동 실행 시 rewrite-themed flag와 HUD reason이 남아야 한다.
- "field -> sentence" 연계가 runner에서 검증 가능해야 한다.

### Karuon

- name_severance 또는 final_toll 구간에서 ally bond/name-call 축을 위협하는 추가 행동이 있어야 한다.
- 행동 실행 시 final pressure objective flag와 HUD reason이 남아야 한다.
- 기존 `all_allies_name_called`, `karon_final_toll` contract와 충돌하면 안 된다.

## Non-Goals

- 신규 cutscene 추가
- 신규 resource schema 추가
- stage layout 변경
- progression/save format 변경

## Verification

- `scripts/dev/lategame_boss_pattern_runner.gd`에 새 실패 테스트를 먼저 추가한다.
- 그 다음 `scripts/battle/battle_controller.gd`를 최소 수정한다.
- 최종적으로 다음 러너를 다시 녹색으로 맞춘다.
  - `lategame_boss_pattern_runner.gd`
  - 필요 시 `ch10_shell_runner.gd`
  - 필요 시 `headless_dev_smoke.sh`
