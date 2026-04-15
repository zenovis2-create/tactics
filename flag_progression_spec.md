# Flag Progression Spec v1
## Project: 잿빛의 기억

## 1. 문서 목적

이 문서는 게임 전체의 진행 상태를 어떤 플래그로 기록하고, 언제 쓰고, 무엇을 기준으로 분기할지 고정하는 문서다.

이 문서가 고정하는 것은 아래 여섯 가지다.

1. 플래그와 전용 저장 컬렉션의 역할 분리
2. 영속 플래그와 전투 임시 플래그의 경계
3. 플래그 네이밍 규칙과 값 타입 규칙
4. 장 클리어 후 어떤 상태를 커밋하는지에 대한 순서
5. 진엔딩, 재등장 NPC, 시스템 해금, 캠프 대화의 판정 기준
6. Codex가 플래그를 추가할 때 지켜야 할 작성 원칙

이 문서는 `data_schema.md`의 `FlagDefinitionData`를 실제로 어떻게 운용할지 설명하는 **진행 로직 문서**다.

---

## 2. 핵심 설계 원칙

### 2-1. 플래그는 “진행과 분기”에만 쓴다
플래그는 모든 상태를 다 담는 만능 저장소가 아니다.  
아래처럼 이미 더 좋은 저장 방식이 있으면 플래그를 만들지 않는다.

- 클리어한 스테이지 → `cleared_stage_ids`
- 영입한 동료 → `unit_progress[unit_id].recruited`
- 발견한 상자 → `discovered_treasure_ids`
- 해금된 회상 토벌전 → `unlocked_hunt_ids`
- 본 컷신 / 캠프 대화 / 편지 → 전용 `viewed_*_ids`

즉, 플래그는 **내러티브 판단**, **분기 조건**, **엔딩 조건**, **UI 해금**, **반복 콘텐츠 접근 논리**에 집중한다.

### 2-2. 한 플래그는 한 의미만 가진다
한 플래그에 여러 뜻을 겹쳐 넣지 않는다.

좋은 예:
- `flag_ch07_mira_nery_rescued`
- `flag_resonance_tia`

나쁜 예:
- `flag_ch07_good_result`
- `flag_story_progress_advanced`

### 2-3. 부정형 플래그보다 긍정형 플래그를 쓴다
가능하면 `실패했다`보다 `성공했다`를 저장한다.

좋은 예:
- `flag_ch01_nery_saved`

피해야 할 예:
- `flag_ch01_nery_not_dead`
- `flag_ch01_fail_missing`

### 2-4. 전투 중에는 임시 상태만 쓴다
전투 중 발생한 구조 수, 제단 정화 수, 봉화 파괴 수는 먼저 **battle_temp**에 저장한다.  
영속 플래그는 전투 승리 후 `StageResolutionService`가 일괄 커밋한다.

즉:
- 전투 중 → `battle_temp`
- 스테이지 클리어 후 → `profile/chapter/stage` 플래그 커밋

이렇게 해야 리트라이, 중단 저장, 컷신 스킵, 크래시 복구가 안정적이다.

### 2-5. 파생 정보는 소스 오브 트루스로 쓰지 않는다
예를 들어 `flag_true_ending_ready`는 유용하지만, 이것이 진짜 기준이면 안 된다.  
진짜 기준은 아래 세 가지다.

- 동료 공명 인장 6개
- 이름 앵커 유지 수
- 6인의 `이름 부름` 발동 여부

`flag_true_ending_ready`는 **결과 캐시** 또는 **UI용 편의값**으로만 쓴다.

---

## 3. 소스 오브 트루스 분배

진행 상태는 아래처럼 나눠서 관리한다.

### 3-1. `flags`
스토리 분기와 장기 조건 판정용 영속 상태.

예:
- `flag_ch07_mira_nery_rescued`
- `flag_resonance_bran`
- `flag_system_forge_unlocked`
- `flag_memory_ch09b_final_restored`

### 3-2. `cleared_stage_ids`
스테이지 클리어 여부의 정답.

예:
- `stage_ch04_05`
- `stage_ch09a_05`

이건 `flag_stage_ch04_05_cleared` 같은 중복 플래그를 만들지 않아야 한다.

### 3-3. `unit_progress`
동료 영입/이탈/장비/레벨의 정답.

예:
- `unit_progress["serin"].recruited = true`
- `unit_progress["kyle"].available = true`

이건 `flag_ch09a_kyle_recruited` 대신 1차 판정 기준으로 쓴다.  
다만 대화 조건을 단순화하고 싶다면 `has_recruited("kyle")` 헬퍼를 제공하면 된다.

### 3-4. `discovered_treasure_ids`
보물상자 발견/개방의 정답.

예:
- `chest_ch06_05_wall_wedge`
- `chest_ch08_04_black_hound_fang`

### 3-5. `unlocked_hunt_ids`
회상 토벌전 해금의 정답.

예:
- `hunt_basil`
- `hunt_saria`
- `hunt_lete`

### 3-6. `viewed_cutscene_ids`, `viewed_camp_dialogue_ids`, `viewed_letter_ids`
이미 본 텍스트 콘텐츠의 정답.

이건 `flag_seen_*`류를 남발하지 않게 하기 위한 전용 배열이다.

---

## 4. 플래그 스코프와 수명

`FlagDefinitionData.scope`는 아래 의미로 고정한다.

### 4-1. `profile`
세이브 슬롯 전체에서 유지되는 영속 플래그다.

예:
- `flag_system_forge_unlocked`
- `flag_resonance_serin`
- `flag_nery_name_restored`

### 4-2. `chapter`
한 챕터가 끝나도 유지되며, 특정 장 또는 장면 이후 상태를 요약하는 플래그다.  
실제 저장 위치는 `flags`이지만 의미상 chapter scope다.

예:
- `flag_ch07_complete`
- `flag_memory_ch05_zero_revealed`

### 4-3. `stage`
특정 스테이지 결과가 이후 분기에 영향을 줄 때만 영속 저장하는 플래그다.

예:
- `flag_ch07_mira_nery_rescued`
- `flag_ch09b_testimony_codices_preserved`

주의할 점은, 모든 스테이지 결과를 stage flag로 만들지 않는다는 것이다.  
후속 영향이 없는 건 보상만 주고 버린다.

### 4-4. `battle_temp`
전투 중에만 존재하고 세이브 커밋 전에는 영속화되지 않는 임시 값이다.

예:
- `temp_boss_phase_2_started`
- `count_battle_altars_purified`
- `count_battle_civilians_rescued`

---

## 5. 네이밍 규칙

### 5-1. Bool 플래그
접두사는 `flag_`

예:
- `flag_ch01_complete`
- `flag_system_hunt_board_unlocked`
- `flag_resonance_noa`

### 5-2. 카운터형 값
접두사는 `count_`

예:
- `count_battle_civilians_rescued`
- `count_ch10_name_anchors_kept`

### 5-3. 상태형 문자열 값
접두사는 `state_`

예:
- `state_ending_result`
- `state_ch10_bell_phase`

### 5-4. 임시 전투 플래그
접두사는 `temp_`

예:
- `temp_boss_phase_2_started`
- `temp_ch07_queue_gate_open`

### 5-5. 권장 패턴
- 챕터 요약: `flag_ch##_complete`
- 기억 조각: `flag_memory_ch##_...`
- 물증: `flag_evidence_..._obtained`
- 시스템 해금: `flag_system_..._unlocked`
- 공명 인장: `flag_resonance_<unit_id>`
- NPC 재등장: `flag_<npc>_...`

---

## 6. 값 타입 규칙

### Bool
단일 참/거짓 분기용.

예:
- `flag_ch07_mira_nery_rescued = true`

### Int
숫자 카운트가 필요한 경우.

예:
- `count_ch10_name_anchors_kept = 3`

### String
상태가 3개 이상이고 bool 여러 개로 풀면 더 복잡해질 때만 사용.

예:
- `state_ending_result = "normal"` / `"true"`

규칙은 단순하다.  
가능하면 `bool`, 불가피하면 `int`, 정말 필요할 때만 `string`.

---

## 7. 쓰기 주체(Ownership)

플래그는 아무 시스템이나 쓰면 안 된다.  
쓰는 주체를 고정해야 한다.

### 7-1. `BattleRuntime`
쓸 수 있는 것:
- `battle_temp`
- 전투 카운터
- 임시 이벤트 상태

쓰면 안 되는 것:
- 영속 플래그
- 챕터 완료 플래그
- 진엔딩 준비 플래그

### 7-2. `StageResolutionService`
쓸 수 있는 것:
- 장 클리어 후 영속 플래그
- 공명 인장 플래그
- 기억 조각 획득 플래그
- 물증 획득 플래그
- 시스템 해금 플래그

이 서비스가 **스토리 진행 플래그의 주 작성자**다.

### 7-3. `RecruitmentService`
쓸 수 있는 것:
- `unit_progress[unit_id].recruited`
- `unit_progress[unit_id].available`

필요하면 보조용 플래그를 생성할 수 있지만, 정답은 항상 `unit_progress`다.

### 7-4. `UnlockService`
쓸 수 있는 것:
- `flag_system_*_unlocked`
- `unlocked_hunt_ids`

### 7-5. `EndingResolver`
쓸 수 있는 것:
- `count_ch10_name_anchors_kept`
- `flag_ch10_name_call_*`
- `flag_true_ending_ready`
- `state_ending_result`
- `flag_ch10_complete`

### 7-6. `DialogueService`
쓸 수 있는 것:
- `viewed_cutscene_ids`
- `viewed_camp_dialogue_ids`
- `viewed_letter_ids`

기본적으로 스토리 플래그는 직접 쓰지 않는다.  
예외적으로 대화가 실제 분기 선택지라면 `StageResolutionService`가 넘긴 허가 목록 안에서만 쓴다.

---

## 8. 진행 커밋 순서

스테이지 승리 후 커밋 순서는 아래로 고정한다.

### 8-1. 전투 종료 직후
`BattleRuntime`가 `StageClearReport`를 만든다.

```text
StageClearReport
- stage_id
- cleared: bool
- failed: bool
- optional_objective_ids_completed[]
- rescued_npc_ids[]
- defeated_boss_id
- obtained_memory_fragment_id (optional)
- obtained_evidence_ids[]
- opened_treasure_ids[]
- battle_temp_counters{}
- battle_temp_flags{}
8-2. 스테이지 해석 단계

StageResolutionService가 StageClearReport + StageData + SaveData를 읽고 아래를 계산한다.

어떤 영속 플래그를 set할지
어떤 시스템을 해금할지
어떤 물증을 기록할지
어떤 동료를 영입할지
어떤 캠프 대화를 큐잉할지
어떤 회상 토벌전을 열지
진엔딩 관련 플래그가 충족됐는지
8-3. 클리어 컷신 준비

클리어 컷신에는 pending progression state를 반영할 수 있어야 한다.
즉, 세린이 방금 합류했다면 클리어 컷신에서 이미 동료처럼 말할 수 있어야 한다.

8-4. 컷신 완료 또는 스킵

컷신을 끝까지 보든 스킵하든, 아래는 반드시 커밋된다.

클리어 스테이지 등록
시스템 해금
물증 획득
기억 조각 획득
영입
영속 플래그 기록
캠프 진입 준비
8-5. 캠프 진입 시

캠프 대화 후보를 계산한다.

조건 충족
아직 보지 않았음
우선순위 정렬

이후 1~N개의 대화를 보여 준다.

9. 플래그를 만들기 전에 먼저 확인할 것

아래 질문에 답하고 나서 플래그를 만든다.

질문 1

이미 전용 저장 컬렉션이 있는가?

있다면 플래그 대신 그걸 써라.

스테이지 클리어 → cleared_stage_ids
영입 → unit_progress
상자 발견 → discovered_treasure_ids
토벌전 해금 → unlocked_hunt_ids
질문 2

이 정보가 전투가 끝난 뒤에도 필요한가?

아니면 battle_temp
맞으면 영속 플래그 검토
질문 3

후속 분기, 대화, 엔딩에 영향을 주는가?

아니면 보상만 지급하고 저장하지 않아도 됨
맞으면 영속 플래그 필요
질문 4

값이 숫자인가?

단순 성공/실패면 flag_
누적 수량이면 count_
10. 반드시 존재해야 하는 영속 플래그 군
10-1. 챕터 완료 플래그

이건 세계맵, 챕터 셀렉트, 에필로그, QA 검증에 유용하므로 유지한다.

flag_ch01_complete
flag_ch02_complete
flag_ch03_complete
flag_ch04_complete
flag_ch05_complete
flag_ch06_complete
flag_ch07_complete
flag_ch08_complete
flag_ch09a_complete
flag_ch09b_complete
flag_ch10_complete

주의:

cleared_stage_ids가 1차 진실이어도, 챕터 완료 플래그는 상위 요약 상태로 남겨도 된다.
단, 수동으로 찍지 말고 StageResolutionService가 마지막 스테이지 클리어 시 자동 set한다.
10-2. 시스템 해금 플래그
flag_system_inventory_unlocked
flag_system_accessory_unlocked
flag_system_armor_unlocked
flag_system_hunt_board_unlocked
flag_system_salvage_unlocked
flag_system_sigil_ledger_unlocked
flag_system_forge_unlocked
flag_system_sigil_tuning_unlocked
flag_system_select_craft_unlocked
flag_system_affix_calibration_unlocked
권장 해금 시점
2장: inventory, accessory
3장: armor
4장: hunt_board
5장: salvage, sigil_ledger
6장: forge
7장: sigil_tuning
9B: select_craft, affix_calibration
10-3. 기억 조각 플래그

기억 조각은 전용 배열 대신 영속 플래그로 관리한다.

flag_memory_ch01_first_order_seen
flag_memory_ch02_hardren_blueprint_seen
flag_memory_ch03_forest_fire_order_seen
flag_memory_ch04_ark_research_seen
flag_memory_ch05_zero_revealed
flag_memory_ch06_fortress_breach_context_seen
flag_memory_ch07_zero_named_by_karon_seen
flag_memory_ch08_north_corridor_context_seen
flag_memory_ch09a_returning_names_seen
flag_memory_ch09b_final_restored
규칙
기억 컷신을 끝까지 보지 않아도, 스킵 시점에 획득 처리한다.
현재 해석과 최종 해석은 같은 플래그로 관리하지 않는다.
현재 해석은 텍스트 문서/컷신 쪽에서 처리하고, 플래그는 “봤는가”만 기록한다.
10-4. 물증 플래그

물증은 다음 목적지의 이유를 강제하므로 명시적으로 저장한다.

flag_evidence_hardren_seal_obtained
flag_evidence_greenwood_orders_obtained
flag_evidence_monastery_manifest_obtained
flag_evidence_archive_transfer_obtained
flag_evidence_fortress_ledger_obtained
flag_evidence_elyor_edict_obtained
flag_evidence_black_hound_orders_obtained
flag_evidence_outer_gate_writ_obtained
flag_evidence_root_archive_pass_obtained
flag_evidence_eclipse_coords_obtained
규칙
각 챕터 종료 시 최소 1개 이상 set
해당 물증이 없으면 다음 장 선택 UI에 “목적지 미확정” 상태를 보여 줄 수 있음
실제 선형 진행에서는 이전 챕터 클리어만으로 다음 장에 갈 수 있어도, UI와 내러티브 로그는 이 물증 플래그를 기준으로 표시한다
10-5. 공명 인장 플래그

진엔딩의 핵심이다.

flag_resonance_serin
flag_resonance_bran
flag_resonance_tia
flag_resonance_enok
flag_resonance_kyle
flag_resonance_noa
획득 조건
flag_resonance_serin
4-5에서 오염 제단 3개 전부 정화
flag_resonance_bran
6-5에서 동서 카운터웨이트 모두 복구
flag_resonance_tia
8-5에서 검은 봉화 3개 전부 소등
flag_resonance_enok
5-5에서 봉인 기록통 2개 이상 회수
flag_resonance_kyle
9A-5에서 감찰 봉인주 3개 모두 파괴
flag_resonance_noa
9B-5에서 증언 코덱스 2권 이상 보존
규칙
각 인장은 해당 스테이지 클리어 시 1회만 set
놓쳤다면 해당 회차에선 복구 불가로 두는 편이 진엔딩 선택의 무게가 생긴다
다만 디자인 변경으로 회상 토벌전에서 복구 가능하게 만들고 싶다면 별도 플래그 설계를 추가해야 한다
10-6. 네리 / 미라 라인 플래그

이 라인은 에필로그 감정 밀도를 높이는 핵심이므로 별도로 고정한다.

flag_ch01_nery_saved
flag_nery_registry_partial_found
flag_nery_transfer_trace_found
flag_ch07_mira_nery_rescued
flag_nery_name_partial_restored
flag_nery_name_restored
의미
flag_ch01_nery_saved
1장에서 네리를 직접 보호하고 탈출 성공
flag_nery_registry_partial_found
5장에서 난민 명부 흔적 발견
flag_nery_transfer_trace_found
6장에서 N—ri 이송 흔적 발견
flag_ch07_mira_nery_rescued
7장에서 미라와 네리를 실제로 구출
flag_nery_name_partial_restored
8~9A 사이 편지에서 이름 일부 회복
flag_nery_name_restored
9B 이후 편지 또는 에필로그 조건 달성
규칙
이 라인은 진엔딩 필수는 아니다
하지만 10장 에필로그 텍스트와 편지 내용에 직접 영향을 준다
10-7. 최종전 플래그
count_ch10_name_anchors_kept
flag_ch10_name_call_serin
flag_ch10_name_call_bran
flag_ch10_name_call_tia
flag_ch10_name_call_enok
flag_ch10_name_call_kyle
flag_ch10_name_call_noa
flag_true_ending_ready
state_ending_result
의미
count_ch10_name_anchors_kept
10-5 종료 시점에 살아 있는 이름 앵커 수
flag_ch10_name_call_*
최종전에서 각 동료의 이름 부름이 실제 발동했는지
flag_true_ending_ready
아래 조건을 모두 만족하면 set
공명 인장 6개 완성
count_ch10_name_anchors_kept >= 2
6개의 flag_ch10_name_call_* 전부 true
state_ending_result
"normal"
"true"
규칙
flag_true_ending_ready는 편의 캐시지만, 가능하면 로드 시 재계산 가능해야 한다
엔딩 컷신 분기는 최종적으로 state_ending_result를 본다
11. 장별 커밋 매트릭스
11-1. 1장 종료 시

필수 커밋:

flag_ch01_complete
flag_memory_ch01_first_order_seen
flag_evidence_hardren_seal_obtained
unit_progress["serin"].recruited = true

조건부 커밋:

flag_ch01_nery_saved
11-2. 2장 종료 시

필수 커밋:

flag_ch02_complete
flag_system_inventory_unlocked
flag_system_accessory_unlocked
flag_evidence_greenwood_orders_obtained
unit_progress["bran"].recruited = true
11-3. 3장 종료 시

필수 커밋:

flag_ch03_complete
flag_system_armor_unlocked
flag_memory_ch03_forest_fire_order_seen
flag_evidence_monastery_manifest_obtained
unit_progress["tia"].recruited = true
11-4. 4장 종료 시

필수 커밋:

flag_ch04_complete
flag_system_hunt_board_unlocked
flag_memory_ch04_ark_research_seen
flag_evidence_archive_transfer_obtained
unlocked_hunt_ids += hunt_basil

조건부 커밋:

flag_resonance_serin
11-5. 5장 종료 시

필수 커밋:

flag_ch05_complete
flag_system_salvage_unlocked
flag_system_sigil_ledger_unlocked
flag_memory_ch05_zero_revealed
flag_evidence_fortress_ledger_obtained
unit_progress["enok"].recruited = true
unlocked_hunt_ids += hunt_hes

조건부 커밋:

flag_resonance_enok
flag_nery_registry_partial_found
11-6. 6장 종료 시

필수 커밋:

flag_ch06_complete
flag_system_forge_unlocked
flag_memory_ch06_fortress_breach_context_seen
flag_evidence_elyor_edict_obtained
flag_nery_transfer_trace_found
unlocked_hunt_ids += hunt_valgar

조건부 커밋:

flag_resonance_bran
11-7. 7장 종료 시

필수 커밋:

flag_ch07_complete
flag_system_sigil_tuning_unlocked
flag_memory_ch07_zero_named_by_karon_seen
flag_evidence_black_hound_orders_obtained
unlocked_hunt_ids += hunt_saria

조건부 커밋:

flag_ch07_mira_nery_rescued
flag_nery_name_partial_restored
11-8. 8장 종료 시

필수 커밋:

flag_ch08_complete
flag_memory_ch08_north_corridor_context_seen
flag_evidence_outer_gate_writ_obtained
unlocked_hunt_ids += hunt_lete

조건부 커밋:

flag_resonance_tia
11-9. 9A 종료 시

필수 커밋:

flag_ch09a_complete
flag_memory_ch09a_returning_names_seen
flag_evidence_root_archive_pass_obtained
unit_progress["kyle"].recruited = true

조건부 커밋:

flag_resonance_kyle
11-10. 9B 종료 시

필수 커밋:

flag_ch09b_complete
flag_memory_ch09b_final_restored
flag_evidence_eclipse_coords_obtained
unit_progress["noa"].recruited = true
flag_system_select_craft_unlocked
flag_system_affix_calibration_unlocked
flag_nery_name_restored
unlocked_hunt_ids += hunt_melchion

조건부 커밋:

flag_resonance_noa
11-11. 10장 종료 시

필수 커밋:

flag_ch10_complete
count_ch10_name_anchors_kept = <resolved int>
flag_ch10_name_call_serin = <bool>
flag_ch10_name_call_bran = <bool>
flag_ch10_name_call_tia = <bool>
flag_ch10_name_call_enok = <bool>
flag_ch10_name_call_kyle = <bool>
flag_ch10_name_call_noa = <bool>
flag_true_ending_ready = <derived bool>
state_ending_result = "normal" | "true"
unlocked_hunt_ids += hunt_karon
12. 전투 임시 플래그 패턴

전투 중에는 아래 패턴으로만 임시 플래그를 만든다.

12-1. 임시 bool
temp_boss_phase_2_started
temp_ch07_queue_gate_open
temp_ch10_bell_room_opened
12-2. 임시 count
count_battle_civilians_rescued
count_battle_altars_purified
count_battle_black_beacons_extinguished
count_battle_testimony_codices_saved
12-3. 임시 state
state_battle_water_level = "low" | "mid" | "high"
state_battle_current_decree = "none" | "stop" | "silence" | "blank"
규칙
battle_temp는 전투 종료 후 바로 폐기하거나 StageClearReport에만 전달한다
세이브에 직접 영속 저장하지 않는다
단, suspend_battle를 구현한다면 BattleSnapshotData 안에만 저장한다
13. 캠프 대화와 편지 조건 규칙

캠프 콘텐츠 조건은 가능한 한 전용 컬렉션 + 플래그 조합으로 읽는다.

13-1. 좋은 조건 예
flag_evidence_elyor_edict_obtained == true
has_recruited("bran")
flag_resonance_tia == true
viewed_camp_dialogue_ids에 현재 대화 없음
flag_ch07_mira_nery_rescued == true
13-2. 편지 조건 예

네리 편지는 아래 순서로 열리게 하면 된다.

편지 1: flag_ch07_mira_nery_rescued
편지 2: flag_ch08_complete
편지 3: flag_ch09a_complete
편지 4: flag_nery_name_restored
13-3. 금지 패턴
“현재 챕터 번호 >= 7이면 편지 노출”처럼 넓은 조건
분기에 민감한 대화를 chapter_complete만으로 여는 것
이미 전용 배열이 있는데도 flag_seen_letter_...를 또 만드는 것
14. 진엔딩 판정 순서

진엔딩은 아래 순서로 판정한다.

14-1. 1차 판정 — 공명 인장

아래 여섯 플래그가 모두 true여야 한다.

flag_resonance_serin
flag_resonance_bran
flag_resonance_tia
flag_resonance_enok
flag_resonance_kyle
flag_resonance_noa
14-2. 2차 판정 — 이름 앵커
count_ch10_name_anchors_kept >= 2
14-3. 3차 판정 — 이름 부름

아래 여섯 플래그가 모두 true여야 한다.

flag_ch10_name_call_serin
flag_ch10_name_call_bran
flag_ch10_name_call_tia
flag_ch10_name_call_enok
flag_ch10_name_call_kyle
flag_ch10_name_call_noa
14-4. 최종 캐시

위 3개 조건을 모두 만족하면

flag_true_ending_ready = true
state_ending_result = "true"

그 외에는

flag_true_ending_ready = false
state_ending_result = "normal"
주의
flag_true_ending_ready는 최종전 결과를 저장할 때만 기록
10장 이전에 미리 세팅하지 않는다
15. 파생 헬퍼 규칙

조건식을 단순하게 만들기 위해 아래 헬퍼는 허용한다.
다만 이들은 플래그가 아니라 쿼리 함수다.

has_stage_cleared(stage_id)
has_recruited(unit_id)
has_treasure(chest_id)
has_hunt(hunt_id)
has_flag(flag_id)
get_count(flag_id)
get_state(flag_id)
권장
대화 조건이나 UI 노출은 헬퍼로 감춘다
세이브 데이터에 중복 bool을 추가하지 않는다

예:

has_recruited("kyle")는 unit_progress["kyle"].recruited를 읽는다
has_hunt("hunt_saria")는 unlocked_hunt_ids를 읽는다
16. 검증 규칙

진행 플래그는 자동 검증 대상이다.

16-1. 정의 누락 금지

문서에 등장하는 모든 영속 플래그는 FlagDefinitionData가 있어야 한다.

16-2. 중복 의미 금지

아래처럼 같은 뜻의 상태를 두 군데에 저장하면 안 된다.

나쁜 예:

flag_ch09a_kyle_recruited
unit_progress["kyle"].recruited

둘 중 하나를 정답으로 삼아야 한다.
이 프로젝트에서는 unit_progress가 정답이다.

16-3. 챕터 완료와 시스템 해금 충돌 금지

예:

flag_system_forge_unlocked = true
flag_ch06_complete = false

이런 상태가 가능하면 안 된다.
대장간은 6장 종료 해금이므로, 해금 플래그가 켜지면 최소 6장 완료가 전제돼야 한다.

16-4. 진엔딩 캐시 검증

flag_true_ending_ready == true이면 아래도 참이어야 한다.

state_ending_result == "true"
count_ch10_name_anchors_kept >= 2
공명 인장 6개 true
이름 부름 6개 true
17. 세이브 마이그레이션 규칙

플래그 체계는 중간에 늘어날 가능성이 크므로 마이그레이션 규칙을 명확히 둔다.

17-1. 새 bool 플래그 추가
FlagDefinitionData.default_value = false
로드 시 없는 경우 자동 false로 채움
17-2. 새 count 플래그 추가
기본값 0
17-3. 새 state 플래그 추가
기본값 "none" 또는 명시적 초기 상태
17-4. 파생 캐시 재계산

다음 값은 세이브 로드 후 재계산 가능하도록 둔다.

flag_true_ending_ready
state_ending_result (필요 시)
일부 UI helper 캐시
18. 예시 플래그 정의
18-1. bool 플래그
id: flag_resonance_serin
schema_version: 1
enabled: true
scope: profile
value_type: bool
default_value: false
category: ending
description_key: flag.resonance_serin.desc
18-2. count 플래그
id: count_ch10_name_anchors_kept
schema_version: 1
enabled: true
scope: chapter
value_type: int
default_value: 0
category: ending
description_key: flag.count_ch10_name_anchors_kept.desc
18-3. state 플래그
id: state_ending_result
schema_version: 1
enabled: true
scope: profile
value_type: string
default_value: "none"
category: ending
description_key: flag.state_ending_result.desc
19. 예시 세이브 조각
{
  "flags": {
    "flag_ch06_complete": true,
    "flag_system_forge_unlocked": true,
    "flag_resonance_serin": true,
    "flag_ch07_mira_nery_rescued": false,
    "flag_nery_transfer_trace_found": true,
    "flag_memory_ch05_zero_revealed": true,
    "flag_evidence_elyor_edict_obtained": true,
    "count_ch10_name_anchors_kept": 0,
    "state_ending_result": "none"
  },
  "cleared_stage_ids": [
    "stage_ch01_01",
    "stage_ch01_02",
    "stage_ch01_03",
    "stage_ch01_04",
    "stage_ch01_05",
    "stage_ch06_05"
  ],
  "unit_progress": {
    "serin": {
      "recruited": true
    },
    "bran": {
      "recruited": true
    },
    "tia": {
      "recruited": true
    }
  },
  "unlocked_hunt_ids": [
    "hunt_basil",
    "hunt_hes",
    "hunt_valgar"
  ],
  "discovered_treasure_ids": [
    "chest_ch02_01_militia_badge",
    "chest_ch06_05_wall_wedge"
  ]
}
20. Codex 작업 규칙

Codex가 플래그를 추가하거나 수정할 때는 아래 원칙을 따른다.

20-1. 먼저 전용 컬렉션이 있는지 확인한다

새 플래그를 만들기 전에 아래를 먼저 본다.

클리어 여부 → cleared_stage_ids
영입 여부 → unit_progress
상자 발견 → discovered_treasure_ids
토벌전 해금 → unlocked_hunt_ids
본 대화/편지 → viewed_*_ids
20-2. battle_temp와 영속 플래그를 섞지 않는다

전투 중엔 temp_, count_battle_만 쓴다.
스토리 플래그는 전투 승리 후 StageResolutionService가 커밋한다.

20-3. “좋은 결과” 같은 뭉뚱그린 플래그를 만들지 않는다

나쁜 예:

flag_ch08_good_clear

좋은 예:

flag_resonance_tia
flag_ch08_complete
20-4. ending helper는 캐시일 뿐 정답이 아니다

flag_true_ending_ready를 직접 참조해도 되지만,
가능하면 최종 판정은 원본 조건으로 다시 계산할 수 있어야 한다.

21. 다음 문서와의 연결

이 문서가 생기면 다음 문서들이 훨씬 쉬워진다.

`ai_behavior_spec.md`
`memory_fragments.md`
`boss_loot_tables.md`
`production_backlog.md`

그중 다음 우선순위는 **ai_behavior_spec.md**다.
전투 규칙과 데이터 스키마, 진행 플래그가 고정됐으니 이제 적이 어떻게 판단하고 움직일지를 문서로 잠가야 실제 구현이 흔들리지 않는다.
