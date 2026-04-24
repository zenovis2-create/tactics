# Turn RPG Upgrade Wave A Master Execution Plan

> For Hermes: use subagent-driven-development skill to execute this plan task-by-task, but keep shared-file collisions under control by batching independent tasks only.

**Goal:** Wave A(A1~A8)를 현재 잿빛의 기억 코드베이스에 충돌 최소 순서로 구현한다.

**Architecture:** 먼저 데이터 계약을 고정한 뒤, battle HUD/preview 공용 surface를 정리하고, 그 다음 progression/save-load, campaign summary, narrative hooks, telemetry/report, secret/hint를 붙인다. `battle_controller.gd`와 `campaign_controller.gd`가 공용 허브이므로 같은 배치에서 중복 수정하지 않는다.

**Tech Stack:** Godot 4.6, GDScript, dev runner 기반 회귀 검증, save/load progression pipeline

---

## Shared-file Risk Rules

- `scripts/battle/battle_controller.gd`는 한 배치에 한 축만 수정한다.
- `scripts/campaign/campaign_controller.gd`와 `scripts/campaign/campaign_panel.gd`는 summary/UI 배치에서만 수정한다.
- `scripts/data/stage_data.gd`와 `scripts/data/progression_data.gd`는 가장 먼저 schema 확정 후 후속 배치에서 재사용만 한다.
- `data/stages/*.tres` authoring은 schema 고정 뒤 별도 배치로 미룬다.

## Batch 0 — Schema Freeze

### Task 0.1: Stage metadata schema 확정
**Files:**
- Modify: `scripts/data/stage_data.gd`
- Reference: `data/stages/*.tres`

**Objective:** A1/A6/A8이 공용으로 쓰는 stage-level contract를 먼저 확정한다.

**Add fields (target):**
- `risk_forecast_cards: Array[Dictionary]`
- `rule_template_id: StringName`
- `rule_template_modifiers: Dictionary`
- `secret_hint_contract: Dictionary`

**Verification:**
- 기존 stage resource load가 깨지지 않아야 한다.
- fallback path가 빈 배열/빈 dictionary로 안전해야 한다.

### Task 0.2: Progression schema 확정
**Files:**
- Modify: `scripts/data/progression_data.gd`

**Objective:** A3/A4/A5/A8 영속 데이터를 먼저 확보한다.

**Add fields (target):**
- `narrative_axis_values: Dictionary`
- `unlocked_passive_card_ids: Array[StringName]`
- `hint_reveal_state: Dictionary`
- 필요 시 `bonus_exp_history: Array[Dictionary]` 또는 summary key only

**Verification:**
- save/load roundtrip에서 새 필드가 기본값 유지
- 기존 NG+/autosave runner가 깨지지 않음

## Batch 1 — Battle-start / Preview Surface

### Task 1.1: A1 Risk Forecast extraction helper
**Files:**
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/data/stage_data.gd`

**Objective:** stage metadata -> battle-start risk payload 변환 helper를 만든다.

**Runner:**
- `scripts/dev/briefing_runner.gd`
- `scripts/dev/battle_telegraph_runtime_runner.gd`

### Task 1.2: A1 HUD surface 연결
**Files:**
- Modify: `scripts/battle/battle_hud.gd`
- Modify: `scenes/battle/BattleHUD.tscn`

**Objective:** battle-start 전용 risk cards 3장을 렌더링한다.

**Verification:**
- compact/mobile layout 유지
- telegraph card와 역할 충돌 없음

### Task 1.3: A2 preview schema 정의
**Files:**
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/battle/battle_hud.gd`

**Objective:** damage/range 외 `state_labels`, `objective_delta_labels`, `pressure_delta_labels`를 preview payload에 추가한다.

**Runner:**
- `scripts/dev/status_visual_runner.gd`
- `scripts/dev/battle_telegraph_runtime_runner.gd`
- `scripts/dev/ch04_flood_route_runner.gd`

## Batch 2 — Progression / Reward Core

### Task 2.1: A3 bonus EXP formula + auto distribute helper
**Files:**
- Modify: `scripts/battle/progression_service.gd`
- Modify: `scripts/battle/battle_controller.gd`

**Objective:** 전투 종료 후 bonus EXP pool 계산과 저기여/저레벨 우선 자동 분배를 추가한다.

**Runner:**
- `scripts/dev/battle_result_runner.gd`
- `scripts/dev/s7_unit_progression_runner.gd`

### Task 2.2: A3 result/persistence 연결
**Files:**
- Modify: `scripts/battle/battle_result_screen.gd`
- Modify: `scripts/campaign/campaign_controller.gd`
- Modify: `scripts/battle/save_service.gd` (필요 시 summary metadata only)

**Objective:** result summary, camp handoff, save/load roundtrip까지 bonus EXP를 보이게 한다.

**Runner:**
- `scripts/dev/campaign_save_load_core_loop_runner.gd`
- `scripts/dev/ng_plus_save_load_runner.gd`

## Batch 3 — Camp / Campaign Summary

### Task 3.1: A4 narrative axis delta helper
**Files:**
- Modify: `scripts/battle/progression_service.gd`
- Modify: `scripts/data/progression_data.gd`

**Objective:** 기억/희생/진실/신뢰 등 narrative axis 값을 저장하고 band helper를 만든다.

### Task 3.2: A4 camp summary surface
**Files:**
- Modify: `scripts/camp/camp_controller.gd`
- Modify: `scripts/campaign/campaign_controller.gd`
- Modify: `scripts/campaign/campaign_panel.gd`
- Modify: `scenes/campaign/CampaignPanel.tscn` (필요 시)

**Objective:** camp summary/presentation card에 narrative axis gauges를 노출한다.

**Runner:**
- `scripts/dev/camp_runner.gd`
- `scripts/dev/m3_ui_runner.gd`
- `scripts/dev/campaign_panel_presentation_card_runner.gd`

## Batch 4 — Narrative Reward Hooks

### Task 4.1: A5 passive card unlock schema
**Files:**
- Modify: `scripts/data/progression_data.gd`
- Modify: `scripts/battle/progression_service.gd`
- Modify: `scripts/battle/bond_service.gd`

**Objective:** story milestone / bond / name-call -> passive card unlock contract를 만든다.

### Task 4.2: A5 battle resolver hook + camp display
**Files:**
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/battle/combat_service.gd`
- Modify: `scripts/campaign/campaign_controller.gd`
- Modify: `scripts/campaign/campaign_panel.gd`

**Runner:**
- `scripts/dev/support_namecall_pipeline_runner.gd`
- `scripts/dev/bond_runner.gd`
- 신규: `scripts/dev/narrative_translation_card_runner.gd`

## Batch 5 — Rule Templates / Metrics / Secret Layer

### Task 5.1: A6 battlefield rule template taxonomy
**Files:**
- Modify: `scripts/data/stage_data.gd`
- Modify: `scripts/battle/battle_controller.gd`
- Optionally create: `scripts/battle/stage_rule_template_service.gd`

**Objective:** stage_id 하드코딩 규칙을 `template + modifier`로 추상화한다.

**Runner:**
- `scripts/dev/ch04_flood_route_runner.gd`
- `scripts/dev/ch06_line_control_runner.gd`
- `scripts/dev/lategame_boss_pattern_runner.gd`

### Task 5.2: A7 telemetry schema 확장
**Files:**
- Modify: `scripts/battle/telemetry_service.gd`
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/battle/battle_result_screen.gd`
- Modify: `scripts/campaign/campaign_controller.gd`

**Objective:** average turns, objective rate, boss phase timing, status counts, failure causes를 report-friendly shape로 추가한다.

**Runner:**
- `scripts/dev/m6_telemetry_runner.gd`
- `scripts/dev/battle_result_runner.gd`

### Task 5.3: A8 secret/hint reveal contract
**Files:**
- Modify: `scripts/data/stage_data.gd`
- Modify: `scripts/data/interactive_object_data.gd`
- Modify: `scripts/battle/interactive_object_actor.gd`
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/battle/battle_hud.gd`
- Modify: `scripts/battle/stage_resolution_service.gd`
- Modify: `scripts/data/progression_data.gd`

**Objective:** reveal state와 실제 획득 상태를 분리하고, scout/proximity/turn cadence 기반 progressive hint를 구현한다.

**Runner:**
- `scripts/dev/ch01_ruined_well_runner.gd`
- `scripts/dev/interaction_object_routing_runner.gd`
- 신규: `scripts/dev/secret_hint_layer_runner.gd`

## Recommended Parallelization

### Parallel Batch A
- Task 0.1 Stage schema
- Task 0.2 Progression schema
서로 다른 파일이라 동시 진행 가능

### Parallel Batch B
- Task 1.2 HUD risk cards
- Task 3.2 camp summary gauge UI 스파이크
공용 파일이 달라 prototype 수준 병렬 가능. 최종 merge는 schema freeze 뒤.

### Parallel Batch C
- Task 2.2 result/persistence surface
- Task 5.2 telemetry report surface
둘 다 summary/report 계열이지만 `battle_result_screen.gd` 충돌 가능성이 있으므로 같은 사람이 묶어 처리 권장.

### Do Not Parallelize
- `battle_controller.gd` touching tasks across A1/A2/A3/A5/A6/A7/A8
- `campaign_controller.gd` touching tasks across A3/A4/A5/A7
- `progression_data.gd` touching tasks before schema freeze complete

## First Execution Recommendation

1. Batch 0 완료
2. Batch 1의 A1/A2 구현
3. Batch 2의 A3 구현
4. Batch 3의 A4 구현
5. 이후 A5/A6/A7/A8 순

이 순서가 가장 안전한 이유:
- stage/progression schema를 먼저 고정
- player-facing clarity(A1/A2)를 가장 먼저 확보
- reward/persistence(A3)를 그 다음에 잠금
- camp summary(A4)는 A3 결과를 흡수
- 나머지 구조개편(A5~A8)은 기반 위에 올림

## Immediate Next Step

다음 실제 구현 배치는 `Batch 0 + Batch 1.1 설계 확인`이다.
구체적으로는:
- `scripts/data/stage_data.gd`
- `scripts/data/progression_data.gd`
- `scripts/battle/battle_controller.gd`
의 schema/helper부터 시작한다.
