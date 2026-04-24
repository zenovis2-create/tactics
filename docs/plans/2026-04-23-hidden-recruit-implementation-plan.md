# Hidden Recruit Implementation Plan

> For Hermes: Use subagent-driven-development skill to implement this plan task-by-task.

Goal: CH07_05 / CH08_05 / CH09B_05의 숨은 영입 축(Mira, Lete, Melkion ally)을 실제 캠페인 해금/로스터/검증 러너까지 연결한다.

Architecture: 이미 스테이지 데이터에는 optional objective와 일부 관련 object/stage surface가 존재한다. 이번 작업은 새 전투 규칙을 크게 늘리기보다 `battle_objective_flags`와 `campaign_controller` reward commit 훅을 이용해 숨은 영입 플래그를 progression에 저장하고, `campaign_catalog`/party roster가 그 플래그를 읽어 숨은 유닛을 노출하도록 연결한다.

Tech Stack: Godot 4.6, GDScript, StageData `.tres`, BattleController objective flags, CampaignController progression commit, headless dev runners

---

## Current confirmed state

Already present:
- `data/stages/ch07_05_stage.tres`
  - optional objective `recruit_mira`
  - interactive objects: `ch07_05_prayer_dais`, `ch07_05_city_seal`
- `data/stages/ch08_05_stage.tres`
  - optional objective `lete_defects_alive`
- `data/stages/ch09b_05_stage.tres`
  - optional objective `melkion_truth_revealed`, `noah_survives`
- `scripts/battle/battle_controller.gd`
  - `battle_objective_flags`, `_resolve_interaction()` path, stage objective initialization already 존재
- `scripts/campaign/campaign_catalog.gd`
  - 현재 기본 로스터는 `ally_rian ~ ally_noah`까지만 포함

Currently missing:
- `data/units/ally_lete.tres`
- `data/units/ally_mira.tres`
- `data/units/ally_melkion_ally.tres`
- hidden recruit unlock 판단 로직
- hidden recruit 전용 runner

---

## Scope decisions

이번 슬라이스에서 구현할 것:
1. Mira hidden recruit (CH07_05)
2. Lete hidden recruit (CH08_05)
3. Melkion temporary ally recruit (CH09B_05 → CH10_01 1전투 한정)
4. campaign roster / panel 노출
5. headless runner 검증

이번 슬라이스에서 보류할 것:
- 전용 컷신 polish
- 전용 보이스/연출 강화
- 지나치게 복잡한 새 object family 추가

---

## Hidden recruit contract

### Mira
- CH07_05에서 shrine investigation 성격의 조건을 만족해야 함
- 기존 `recruit_mira` objective를 canonical unlock gate로 사용
- battle 종료 시 `flag:hidden_recruit_mira` 저장
- 캠프 로스터에 `ally_mira` 영구 추가

### Lete
- CH08_05에서 `lete_defects_alive` objective를 canonical unlock gate로 사용
- battle 종료 시 `flag:hidden_recruit_lete` 저장
- 캠프 로스터에 `ally_lete` 영구 추가

### Melkion ally
- CH09B_05에서 아래 3조건 모두 필요
  - `melkion_truth_revealed`
  - `noah_survives`
  - Rian–Noah support rank 4
- battle 종료 시 `flag:hidden_recruit_melkion_ally` 저장
- `ally_melkion_ally`는 CH10_01까지만 roster에 포함
- CH10_01 clear 후 자동 제거 플래그 저장

---

## Task 1: Add recruit unit resources

**Objective:** 실제로 로스터에 넣을 수 있는 ally unit 리소스를 만든다.

**Files:**
- Create: `data/units/ally_lete.tres`
- Create: `data/units/ally_mira.tres`
- Create: `data/units/ally_melkion_ally.tres`
- Reference: existing ally/enemy unit `.tres`

**Implementation notes:**
- Lete: `enemy_lete_ch08_05.tres`를 기준으로 ally faction/수치 보정
- Mira: support/caster 성격으로 설계, Tia/Serin 사이 포지션
- Melkion ally: 강하지만 1전투 한정, ally faction 명시

**Verification:**
- 각 `.tres`가 load 가능
- `CampaignCatalog.get_unit_data()`에 연결 전 preload 에러 없음

---

## Task 2: Extend campaign catalog for hidden recruits

**Objective:** 숨은 유닛이 catalog와 roster order에 들어갈 수 있게 만든다.

**Files:**
- Modify: `scripts/campaign/campaign_catalog.gd`

**Changes:**
- `UNIT_BY_ID`에 3개 ally 추가
- `PARTY_ROSTER_ORDER` 뒤쪽에 hidden recruit slot 추가
- helper 추가:
  - `get_hidden_recruit_ids() -> Array[StringName]`
  - 필요 시 `is_hidden_recruit(unit_id)`

**Verification:**
- `get_unit_data(&"ally_lete")` 등 null 아님
- 기존 base roster 영향 없음

---

## Task 3: Persist hidden recruit flags in progression

**Objective:** 숨은 영입 상태와 Melkion temporary lifecycle을 progression에 저장한다.

**Files:**
- Modify: `scripts/data/progression_data.gd`

**Changes:**
- helper methods only, new data model 최소화
- candidate helpers:
  - `has_hidden_recruit(unit_id: StringName) -> bool`
  - `unlock_hidden_recruit(unit_id: StringName) -> void`
  - `consume_hidden_recruit(unit_id: StringName) -> void` (temporary ally cleanup용)
- 실제 저장은 기존 `flags` dictionary 위에서 동작
  - `hidden_recruit_lete`
  - `hidden_recruit_mira`
  - `hidden_recruit_melkion_ally`
  - `hidden_recruit_melkion_ally_consumed`

**Verification:**
- save/load roundtrip 후 flag 유지
- helper가 alias 없이 deterministic

---

## Task 4: Build runtime roster filter in campaign controller

**Objective:** progression flags에 따라 숨은 유닛이 실제 캠프/전투 준비 roster에 노출되게 한다.

**Files:**
- Modify: `scripts/campaign/campaign_controller.gd`

**Changes:**
- `_is_recruit_unlocked(unit_id)` 구현 추가 또는 기존 hook 확장
- `_build_runtime_party_entries()` / `_build_runtime_deployed_party()` 계열이 hidden recruit를 포함할 수 있게 수정
- Melkion ally는 아래 규칙 적용
  - unlock flag 있고 consumed flag 없을 때만 roster 포함
  - CH10_01 clear 후 consumed 처리

**Verification:**
- Mira/Lete unlock 후 camp payload roster에 등장
- Melkion ally는 CH10_01 전까지만 등장

---

## Task 5: Hook unlock conditions at stage reward commit

**Objective:** battle objective flags와 support 조건을 읽어 hidden recruit unlock을 stage clear 시점에 기록한다.

**Files:**
- Modify: `scripts/campaign/campaign_controller.gd`
- Reference: `_commit_stage_rewards()`

**Changes:**
- `_commit_hidden_recruit_unlocks(stage: StageData)` 추가
- `_commit_stage_rewards()` 끝에서 호출
- stage별 규칙:
  - CH07_05: `battle_objective_flags["recruit_mira"] == true`
  - CH08_05: `battle_objective_flags["lete_defects_alive"] == true`
  - CH09B_05: `melkion_truth_revealed && noah_survives && support_rank(rian,noah) == 4`
- optional objective와 unlock logic이 1:1 되도록 유지

**Verification:**
- objective flag true일 때만 unlock
- false positive 없음

---

## Task 6: Make CH07 shrine path explicit in battle runtime

**Objective:** Mira unlock이 실제 상호작용 조건과 연결되도록 canonical shrine/object path를 만든다.

**Files:**
- Modify: `data/stages/ch07_05_stage.tres`
- Create or modify: `data/objects/ch07_05_shrine_investigation.tres` (if needed)
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/battle/interactive_object_actor.gd` only if object type handling needs explicit branch

**Changes:**
- 가장 작은 변경 우선:
  - 기존 `prayer_dais` 또는 새 shrine object 하나를 Mira unlock trigger로 canonicalize
  - interaction 후 `battle_objective_flags["recruit_mira"] = true`가 되도록 보장
- 이미 `recruit_mira` objective가 있으므로, 새 복잡 규칙보다 `interaction -> flag set`으로 끝낸다

**Verification:**
- CH07_05 interaction 후 objective flag 설정
- result summary / star objective와 충돌 없음

---

## Task 7: Make CH08 Lete defection explicit in battle runtime

**Objective:** Lete recruit가 단순 optional objective 문구가 아니라 runtime flag로 귀결되게 한다.

**Files:**
- Modify: `scripts/battle/battle_controller.gd`
- Reference: CH08_05 boss handling / enemy defeat handling

**Changes:**
- CH08_05에서 Lete 관련 defeat/retreat path에 `lete_defects_alive` flag를 명시적으로 세팅
- 최소 구현은 battle test flags / boss-specific resolution path를 이용
- “죽이지 않고 전향”이 현재 HP threshold로 표현 가능하면 그 로직 연결
- 지금 복잡하면 우선 canonical runtime path를 하나로 고정하고 runner로 잠근다

**Verification:**
- CH08_05 clear 시 Lete objective true/false가 deterministic
- hidden recruit unlock과 일치

---

## Task 8: Make CH09B Melkion flip explicit in battle/campaign runtime

**Objective:** Melkion ally unlock을 support rank 4 + stage objective 조건과 연결한다.

**Files:**
- Modify: `scripts/campaign/campaign_controller.gd`
- Modify: `scripts/battle/battle_controller.gd` if phase-2 trigger snapshot needed

**Changes:**
- battle 쪽은 `melkion_truth_revealed`, `noah_survives` flag가 이미 canonical objective
- campaign commit에서 support rank 4를 함께 확인
- CH10_01 clear 후 consumed flag 기록 helper 추가

**Verification:**
- support rank 부족 시 unlock 안 됨
- support rank 4이면 unlock 됨
- CH10_01 clear 후 roster에서 사라짐

---

## Task 9: Add headless runner for hidden recruits

**Objective:** 세 hidden recruit path를 하나의 runner로 고정한다.

**Files:**
- Create: `scripts/dev/hidden_recruit_runner.gd`

**Assertions:**
- CH07_05 canonical interaction -> `hidden_recruit_mira` unlock -> camp roster contains `ally_mira`
- CH08_05 canonical defection path -> `hidden_recruit_lete` unlock -> camp roster contains `ally_lete`
- CH09B_05 with Noah S-rank + objectives -> `hidden_recruit_melkion_ally` unlock -> roster contains ally before CH10_01
- after CH10_01 clear -> Melkion ally removed

**Command:**
- `/opt/homebrew/bin/godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hidden_recruit_runner.gd`

---

## Task 10: Re-run regression slice

**Objective:** hidden recruit changes가 existing shell/save/campaign 흐름을 깨지 않았는지 확인한다.

**Files / commands:**
- Run: `hidden_recruit_runner.gd`
- Run: `support_namecall_pipeline_runner.gd`
- Run: `ch07_shell_runner.gd` if exists, else related gimmick runner
- Run: `ch08_shell_runner.gd` if exists, else related route runner
- Run: `headless_dev_smoke.sh` if slice is stable enough

**Done when:**
- 신규 runner PASS
- 관련 chapter regression PASS
- smoke 추가분이 기존 범위를 깨지 않음

---

## Recommended execution order

1. Task 1
2. Task 2
3. Task 3
4. Task 4
5. Task 5
6. Task 6
7. Task 7
8. Task 8
9. Task 9
10. Task 10

---

## Commit strategy

- Commit 1: add hidden recruit unit resources and catalog wiring
- Commit 2: add progression + campaign unlock plumbing
- Commit 3: add CH07/08/09B runtime unlock hooks
- Commit 4: add hidden recruit runner and regression coverage

---

## Finish condition

- Mira, Lete, Melkion ally가 각자 deterministic unlock path를 가짐
- unlock state가 save/load와 캠프 roster에 반영됨
- Melkion ally temporary lifecycle이 CH10_01에서 정리됨
- `hidden_recruit_runner.gd` PASS
- 관련 regression PASS
