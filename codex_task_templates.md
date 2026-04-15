# Codex Task Templates v1
## Project: 잿빛의 기억

## 1. 문서 목적

이 문서는 Codex에게 작업을 맡길 때 바로 복붙해서 쓸 수 있는 **표준 프롬프트 템플릿 모음**이다.

이 문서가 고정하는 것은 아래 다섯 가지다.

1. 작업 유형별 프롬프트 형식
2. 각 작업에서 반드시 읽게 할 문서 목록
3. 작업 범위와 금지 범위를 명확히 쓰는 방식
4. 완료 기준과 테스트 기준의 표준 문구
5. 작업 크기를 과도하게 키우지 않도록 제한하는 규칙

이 문서는 `production_backlog.md`를 실제 구현 태스크로 바꾸는 브리지 역할을 한다.

---

## 2. 공통 원칙

모든 Codex 작업 프롬프트는 아래 구조를 따른다.

1. 읽을 문서
2. 현재 목표
3. 작업 범위
4. 수정 허용 범위
5. 완료 기준
6. 테스트 기준
7. 금지 사항
8. 결과 보고 형식

### 2-1. 반드시 넣을 공통 제한
아래 문장은 대부분의 작업에 공통으로 넣는다.

- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- Prefer data-driven changes over hardcoded logic
- Follow existing IDs, file structure, and schema
- Summarize changed files at the end
- List known TODOs separately

### 2-2. 한 작업에 하나의 핵심만
좋은 작업:
- 상태이상 1~2개 구현
- 스테이지 1개 구현
- UI 화면 1개 구현
- 보스 패턴 1개 구현

나쁜 작업:
- “챕터 3 전체 + 장비 + 파밍 + UI 다 구현”
- “스토리, 전투, 저장, 드롭을 한 번에 수정”

### 2-3. 완료 기준은 구체적으로 쓴다
나쁜 예:
- “Works correctly”

좋은 예:
- “A unit can move, attack once, be counterattacked once, and end turn with no script errors”
- “The stage can be started, cleared, and transitioned to camp with rewards committed”

### 2-4. 테스트 기준은 기능 단위로 쓴다
예:
- start battle
- trigger boss phase
- save and reload
- equip item and verify stat change
- open treasure chest and confirm reward persistence

---

## 3. 공통 프롬프트 헤더

아래 헤더는 대부분의 작업 앞부분에 그대로 붙인다.

```text
Read these docs first and follow them as the source of truth:

- master_campaign_outline.md
- core_combat_spec.md
- data_schema.md
- flag_progression_spec.md
- production_backlog.md

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- Prefer data-driven implementation over hardcoded behavior
- Respect existing IDs, schema fields, and file structure
- Summarize changed files at the end
- List remaining TODOs separately
```

주의:

- 현재 정본 문서 대부분은 `docs/` 아래가 아니라 프로젝트 루트에 있다.
- `equipment_system.md`, `camp_ui_spec.md` 같은 문서는 아직 없을 수 있다.
- 없는 경우에는 `data_schema.md`, `boss_loot_tables.md`, `production_backlog.md`, 관련 `phase*.md`를 우선 따른다.
- `monetization_spec.md`, `iap_entitlement_spec.md`, `store_asset_spec.md` 는 출시/수익화 문서다.
- 현재 `M0 ~ M2` 구현 레인에서는 이 세 문서를 작업 입력으로 사용하지 않는다.

## 4. 작업 유형별 템플릿

### 4-1. Foundation / Service 작업 템플릿

대상 예:

DataRegistry
SaveService
FlagService
RewardBundleResolver
StageLoader
Read these docs first and follow them as the source of truth:

- core_combat_spec.md
- data_schema.md
- flag_progression_spec.md
- production_backlog.md

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- Prefer data-driven implementation over hardcoded behavior
- Respect existing IDs, schema fields, and file structure
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement [SERVICE_NAME] for the tactics RPG project.

Scope:
- Add the service class and any minimal helper classes needed
- Wire it into the current project startup path only as needed
- Do not implement unrelated gameplay systems
- Do not redesign save/data architecture

Required behavior:
- [REQUIRED_BEHAVIOR_1]
- [REQUIRED_BEHAVIOR_2]
- [REQUIRED_BEHAVIOR_3]

Allowed files to change:
- scripts/systems/**
- autoload/**
- data/** only if schema glue is required
- minimal scene wiring only if necessary

Completion criteria:
- The service can be instantiated and used in-game
- No script errors on project load
- Existing scenes still open and run
- The implementation follows data_schema.md and flag_progression_spec.md

Test criteria:
- [TEST_CASE_1]
- [TEST_CASE_2]
- [TEST_CASE_3]

Do not:
- Build unrelated UI
- Add placeholder gameplay hacks
- Hardcode story progression values into scenes

At the end:
1. Summarize changed files
2. Explain how to verify the feature manually
3. List known TODOs
사용 예시
[SERVICE_NAME] = FlagService
[REQUIRED_BEHAVIOR_1] = Support profile/chapter/stage/battle_temp scopes
[REQUIRED_BEHAVIOR_2] = Commit pending stage results on clear and discard on failure
[REQUIRED_BEHAVIOR_3] = Provide helper getters like has(), get_int(), clear()
4-2. 전투 코어 메커닉 작업 템플릿

대상 예:

이동
기본 공격
반격
상태이상
지형 효과
오브젝트 파괴
Read these docs first and follow them as the source of truth:

- core_combat_spec.md
- data_schema.md
- production_backlog.md

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- Prefer data-driven implementation over hardcoded behavior
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement the combat mechanic: [MECHANIC_NAME].

Scope:
- Add the runtime logic for this mechanic
- Add only the minimum UI feedback needed to make it testable
- Integrate with existing turn flow and unit state
- Do not implement unrelated future mechanics

Rules to follow:
- [RULE_1]
- [RULE_2]
- [RULE_3]

Allowed files to change:
- scripts/battle/**
- scripts/systems/**
- scenes/ui/battle/** if minimal feedback is required
- data/** only if new definitions are needed

Completion criteria:
- The mechanic works in a playable battle scene
- It follows core_combat_spec.md exactly
- It does not break move/act/end-turn flow
- It is represented in battle state and save/suspend state if required

Test criteria:
- [TEST_CASE_1]
- [TEST_CASE_2]
- [TEST_CASE_3]
- [EDGE_CASE]

Do not:
- Change unrelated combat formulas
- Add undocumented balance tweaks
- Hide critical state with no UI feedback

At the end:
1. Summarize changed files
2. Describe manual test steps
3. List known TODOs
사용 예시
[MECHANIC_NAME] = Forget status
[RULE_1] = Max 3 stacks
[RULE_2] = At 3 stacks, signature and command skills are unusable
[RULE_3] = No natural recovery unless explicitly cleansed
4-3. AI 구현 작업 템플릿

대상 예:

기본 melee AI
healer AI
black hound AI
boss script AI
Read these docs first and follow them as the source of truth:

- core_combat_spec.md
- data_schema.md
- flag_progression_spec.md
- ai_behavior_spec.md
- production_backlog.md

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- Prefer profile-driven AI over hardcoded special cases
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement AI behavior for [AI_PROFILE_OR_BOSS_NAME].

Scope:
- Implement the logic needed for this AI profile or boss script
- Use existing AI profile data where possible
- Keep the behavior deterministic for identical battle states
- Add minimal debug logging in development builds if practical

Behavior requirements:
- [BEHAVIOR_1]
- [BEHAVIOR_2]
- [BEHAVIOR_3]
- [BEHAVIOR_4]

Allowed files to change:
- scripts/ai/**
- scripts/battle/**
- data/ai/**
- boss-specific battle scripts only if needed

Completion criteria:
- The AI follows ai_behavior_spec.md
- It does not use hidden information that the player has not revealed
- It can complete at least one full battle loop without deadlocking
- It produces understandable, role-consistent actions

Test criteria:
- [TEST_CASE_1]
- [TEST_CASE_2]
- [TEST_CASE_3]
- Confirm deterministic behavior with the same battle setup

Do not:
- Give the AI knowledge of unrevealed stealth units
- Hardcode player-specific counters outside documented behavior
- Add undocumented bonus stats to compensate for weak logic

At the end:
1. Summarize changed files
2. Explain manual verification steps
3. Mention any temporary simplifications
사용 예시
[AI_PROFILE_OR_BOSS_NAME] = boss_lete
[BEHAVIOR_1] = Prefer isolated and marked targets
[BEHAVIOR_2] = Avoid revealing from stealth unless kill or very high-value pressure is possible
[BEHAVIOR_3] = Reposition after attacking if stealth recovery path exists
[BEHAVIOR_4] = Respect anti-frustration rules from ai_behavior_spec.md
4-4. 스테이지 구현 작업 템플릿

대상 예:

1-1 불타는 사당
6-5 철성의 맹세
9B-4 개정된 전장
Read these docs first and follow them as the source of truth:

- master_campaign_outline.md
- core_combat_spec.md
- data_schema.md
- flag_progression_spec.md
- [STAGE_SPEC_DOC]
- production_backlog.md

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- Prefer StageData/EventData over scene-hardcoded logic
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement the stage [STAGE_ID] ([STAGE_TITLE]).

Scope:
- Create or wire the stage scene
- Implement stage objectives, spawns, scripted events, and rewards
- Add only the cutscene hooks required for this stage
- Do not implement future chapter content

Stage requirements:
- [REQ_1]
- [REQ_2]
- [REQ_3]
- [REQ_4]

Allowed files to change:
- scenes/battle/**
- scripts/battle/**
- data/stages/**
- data/text/cutscenes/**
- data/text/camp_dialogues/** only if this stage unlocks one immediately

Completion criteria:
- The stage can be launched from a debug entry point or campaign flow
- Objectives, failure conditions, and scripted events work
- Rewards and progression flags commit on clear
- The stage matches [STAGE_SPEC_DOC] in goals and flow

Test criteria:
- [TEST_CASE_1]
- [TEST_CASE_2]
- [TEST_CASE_3]
- [OPTIONAL_OBJECTIVE_TEST]

Do not:
- Hardcode rewards inside the map scene
- Skip required evidence/memory/flag updates
- Add placeholder rules that conflict with core_combat_spec.md

At the end:
1. Summarize changed files
2. Explain how to launch and test the stage
3. List known TODOs
사용 예시
[STAGE_SPEC_DOC] = ch06_spec
[STAGE_ID] = stage_ch06_05
[STAGE_TITLE] = 철성의 맹세
4-5. 보스전 / 페이즈 구현 템플릿

대상 예:

바실 2페이즈
레테 봉화 기믹
멜키온 전장 개정
카르온 1/2페이즈
Read these docs first and follow them as the source of truth:

- core_combat_spec.md
- data_schema.md
- ai_behavior_spec.md
- [STAGE_SPEC_DOC]
- production_backlog.md

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- Boss patterns must be readable and telegraphed
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement the boss behavior for [BOSS_NAME] in [STAGE_ID].

Scope:
- Add boss-specific logic, phase transitions, and stage interactions
- Add only the minimal telegraph UI needed
- Do not rebalance unrelated bosses

Boss behavior requirements:
- [REQ_1]
- [REQ_2]
- [REQ_3]
- [REQ_4]

Allowed files to change:
- scripts/battle/boss/**
- scripts/ai/**
- data/skills/**
- data/stages/**
- scenes/ui/battle/** only for telegraph feedback

Completion criteria:
- The boss performs the required phases and transitions correctly
- Telegraphs appear before major threat actions
- The fight is winnable and follows core_combat_spec.md and ai_behavior_spec.md
- Optional objective logic works if applicable

Test criteria:
- [TEST_CASE_1]
- [TEST_CASE_2]
- [TEST_CASE_3]
- [PHASE_TRANSITION_TEST]

Do not:
- Use hidden information not available to the player
- Skip telegraphs for major attacks
- Solve weak AI by inflating stats without documentation

At the end:
1. Summarize changed files
2. Explain how to test the full boss fight
3. Note any balance assumptions
4-6. 장비 / 인벤토리 UI 작업 템플릿

대상 예:

장비 화면
인벤토리 필터
보상 팝업
분해 화면
문장 조율 화면
Read these docs first and follow them as the source of truth:

- data_schema.md
- flag_progression_spec.md
- equipment_system.md
- camp_ui_spec.md
- production_backlog.md

If `equipment_system.md` or `camp_ui_spec.md` does not exist yet, use:

- data_schema.md
- boss_loot_tables.md
- relevant `phase*.md`

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- UI should be mobile-first and tap-driven
- Do not use drag-and-drop unless explicitly required
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement the UI flow for [UI_FEATURE_NAME].

Scope:
- Add the required screen/panel/sheet
- Connect it to existing inventory/equipment/save systems
- Use minimal polish, functional first
- Do not implement unrelated menus

Required behavior:
- [REQ_1]
- [REQ_2]
- [REQ_3]

Allowed files to change:
- scenes/ui/camp/**
- scripts/ui/camp/**
- scripts/systems/**
- data/** only if metadata is required

Completion criteria:
- The UI is navigable by tap/click only
- It reflects real saved data
- It updates immediately after equipment/inventory changes
- It follows camp_ui_spec.md

Test criteria:
- [TEST_CASE_1]
- [TEST_CASE_2]
- [TEST_CASE_3]

Do not:
- Hardcode item stats in UI
- Duplicate logic that belongs in services
- Hide invalid actions without any feedback

At the end:
1. Summarize changed files
2. Explain manual test steps
3. List known TODOs
4-7. 랜덤 드롭 / 보스 룻 작업 템플릿

대상 예:

바실 드롭
멜키온 드롭
최종 보스 드롭
hunt seed logic
Read these docs first and follow them as the source of truth:

- data_schema.md
- flag_progression_spec.md
- equipment_system.md
- boss_loot_tables.md
- production_backlog.md

If `equipment_system.md` does not exist yet, use:

- data_schema.md
- boss_loot_tables.md
- relevant `phase*.md`

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- Randomness applies to weapons only unless documented otherwise
- Boss drops must be deterministic within a single run and rerolled on a fresh run
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement the loot flow for [BOSS_OR_FEATURE_NAME].

Scope:
- Add or update boss loot generation
- Respect first-clear vs replay rules
- Respect allowed/banned affix pools
- Connect rewards to inventory and sigil gain

Required behavior:
- [REQ_1]
- [REQ_2]
- [REQ_3]
- [REQ_4]

Allowed files to change:
- scripts/systems/loot/**
- scripts/systems/save/**
- data/items/**
- data/loot/**
- scenes/ui/battle/** only for reward presentation

Completion criteria:
- The boss grants the correct minimum rarity and loot weights
- Replaying the same fresh hunt can reroll loot, but loading within the same run cannot
- Sigils are granted correctly
- Duplicate unique handling works as documented

Test criteria:
- [TEST_CASE_1]
- [TEST_CASE_2]
- [TEST_CASE_3]
- [DUPLICATE_UNIQUE_TEST]

Do not:
- Add armor/accessory randomness
- Ignore banned affix lists
- Use scene-local hardcoded loot

At the end:
1. Summarize changed files
2. Explain manual verification steps
3. List known TODOs
사용 예시
[BOSS_OR_FEATURE_NAME] = boss_saria first clear and hunt loot
[REQ_1] = First clear minimum rarity is rare
[REQ_2] = Hunt minimum rarity is advanced
[REQ_3] = Staff and tome are weighted higher
[REQ_4] = Duplicate uniques convert to sigils and memory dust
4-8. 플래그 / 진행 로직 작업 템플릿

대상 예:

세린 공명 인장
네리 구조 결과
진엔딩 판정
시스템 해금
Read these docs first and follow them as the source of truth:

- data_schema.md
- flag_progression_spec.md
- production_backlog.md
- [STAGE_SPEC_DOC] (if stage-related)

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- Do not duplicate state that already has a source of truth elsewhere
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement progression logic for [PROGRESSION_FEATURE_NAME].

Scope:
- Add or update flag writes, stage result aggregation, and unlock logic
- Use StageResolutionService or the project’s equivalent progression resolver
- Do not hardcode progression inside battle scenes

Required behavior:
- [REQ_1]
- [REQ_2]
- [REQ_3]

Allowed files to change:
- scripts/systems/progression/**
- scripts/systems/save/**
- data/flags/**
- data/stages/**
- minimal cutscene or camp dialogue glue only if needed

Completion criteria:
- The correct progression state is written only on clear
- Failure or retry does not incorrectly commit results
- The implementation respects flag_progression_spec.md

Test criteria:
- [TEST_CASE_1]
- [TEST_CASE_2]
- [FAIL_AND_RETRY_TEST]
- [SAVE_LOAD_TEST]

Do not:
- Write profile flags during battle before clear
- Duplicate stage clear state into custom flags
- Hardcode one-off exceptions in unrelated services

At the end:
1. Summarize changed files
2. Explain manual verification steps
3. List known TODOs
4-9. 컷신 / 캠프 대화 작업 템플릿

대상 예:

1장 인터루드
브란/리안 공명 대화
네리 편지
최종 기억 복원 컷신
Read these docs first and follow them as the source of truth:

- master_campaign_outline.md
- flag_progression_spec.md
- docs/memory_fragments.md
- docs/[CHAPTER_SPEC_DOC].md
- production_backlog.md

General constraints:
- Use the existing dialogue/cutscene format
- Keep the project runnable after changes
- Do not refactor unrelated files
- Do not change story canon outside the referenced docs
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement the text and hookup for [CUTSCENE_OR_DIALOGUE_NAME].

Scope:
- Add or update the dialogue/cutscene data
- Wire it to the correct trigger condition
- Keep direction concise and production-ready
- Do not invent new lore outside the approved docs

Required content beats:
- [BEAT_1]
- [BEAT_2]
- [BEAT_3]

Allowed files to change:
- data/text/cutscenes/**
- data/text/camp_dialogues/**
- data/text/letters/**
- minimal trigger wiring in progression/camp systems

Completion criteria:
- The scene/dialogue triggers at the correct time
- It respects the current interpretation vs final interpretation rules
- It does not conflict with docs/memory_fragments.md or the campaign outline

Test criteria:
- [TEST_CASE_1]
- [TEST_CASE_2]
- [SKIP_TEST if applicable]

Do not:
- Overexplain twists before their intended reveal
- Add new facts that contradict the fixed outline
- Turn current interpretation text into final interpretation text too early

At the end:
1. Summarize changed files
2. Explain how to trigger the scene
3. List known TODOs
4-10. 엔딩 / 포스트게임 작업 템플릿

대상 예:

일반 엔딩
진엔딩
포스트 클리어 hunt
에필로그 편지
Read these docs first and follow them as the source of truth:

- master_campaign_outline.md
- flag_progression_spec.md
- docs/memory_fragments.md
- docs/ch10_spec.md
- production_backlog.md

General constraints:
- Keep the project runnable after changes
- Do not refactor unrelated files
- Respect the fixed ending conditions and themes
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement [ENDING_OR_POSTGAME_FEATURE].

Scope:
- Add the progression resolution, cutscene hookup, and post-clear unlocks needed
- Do not redesign the ending conditions
- Keep narrative logic aligned with the approved outline

Required behavior:
- [REQ_1]
- [REQ_2]
- [REQ_3]

Allowed files to change:
- scripts/systems/progression/**
- data/text/cutscenes/**
- data/text/letters/**
- data/stages/**
- hunt/postgame registration data

Completion criteria:
- The correct ending triggers from the correct conditions
- Post-clear unlocks are saved and visible
- The result persists across save/load

Test criteria:
- [NORMAL_END_TEST]
- [TRUE_END_TEST]
- [POSTGAME_UNLOCK_TEST]

Do not:
- Replace calculated ending conditions with a shortcut flag
- Add new ending branches not in the campaign outline
- Skip persistence for post-clear content

At the end:
1. Summarize changed files
2. Explain manual verification steps
3. List known TODOs
5. 빠른 복붙 템플릿 모음

아래는 가장 자주 쓸 축약 버전이다.

5-1. 시스템 구현용 축약본
Read:
- core_combat_spec.md
- data_schema.md
- flag_progression_spec.md
- production_backlog.md

Task:
Implement [FEATURE_NAME].

Scope:
- [SCOPE_1]
- [SCOPE_2]

Constraints:
- Godot 4.x
- GDScript only
- Keep project runnable
- No unrelated refactors
- Data-driven implementation preferred

Completion criteria:
- [CRITERIA_1]
- [CRITERIA_2]
- [CRITERIA_3]

Tests:
- [TEST_1]
- [TEST_2]
- [TEST_3]

At the end:
- changed files
- manual verification steps
- remaining TODOs
5-2. 스테이지 구현용 축약본
Read:
- master_campaign_outline.md
- core_combat_spec.md
- data_schema.md
- flag_progression_spec.md
- [STAGE_SPEC_DOC]
- production_backlog.md

Task:
Implement [STAGE_ID] ([STAGE_TITLE]).

Scope:
- stage scene
- StageData
- scripted events
- reward/flag commit
- required cutscene hooks

Constraints:
- Godot 4.x
- GDScript only
- Keep project runnable
- No unrelated refactors
- Use StageData/EventData, not scene-hardcoded progression

Completion criteria:
- stage launches and clears correctly
- objectives and scripted events work
- rewards/flags commit on clear
- stage matches the approved spec

Tests:
- clear path
- fail path
- optional objective path

At the end:
- changed files
- how to test
- remaining TODOs
5-3. 보스 구현용 축약본
Read:
- core_combat_spec.md
- ai_behavior_spec.md
- [STAGE_SPEC_DOC]
- production_backlog.md

Task:
Implement [BOSS_NAME] behavior for [STAGE_ID].

Scope:
- boss skills
- telegraphs
- phase transitions
- stage interactions

Constraints:
- Godot 4.x
- GDScript only
- Keep project runnable
- No unrelated refactors
- Boss actions must be readable and telegraphed

Completion criteria:
- boss phases work
- telegraphs appear correctly
- fight is winnable and matches the spec

Tests:
- phase transition
- optional objective
- clear/fail flow

At the end:
- changed files
- how to test
- remaining TODOs
6. 실전용 예시 프롬프트
6-1. TASK-01 예시

DataRegistry / SaveService / FlagService

Read these docs first and follow them as the source of truth:

- core_combat_spec.md
- data_schema.md
- flag_progression_spec.md
- production_backlog.md

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- Prefer data-driven implementation over hardcoded behavior
- Respect existing IDs, schema fields, and file structure
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement the initial foundation services:
- DataRegistry
- SaveService
- FlagService

Scope:
- Load authored data by ID
- Create/save/load a profile save file
- Support profile/chapter/stage/battle_temp flag scopes
- Do not implement battle logic yet
- Do not implement UI beyond minimal debug hooks

Allowed files to change:
- scripts/systems/**
- autoload/**
- data/** only if glue metadata is required

Completion criteria:
- The project can boot with the new services loaded
- A new save profile can be created and loaded
- Flags can be written and read in all four scopes
- No script errors on project load

Test criteria:
- Create a new profile save
- Write/read a profile flag
- Write/read and reset a stage flag
- Save and reload the profile and confirm persistence

Do not:
- Build full menus
- Hardcode chapter progression into services
- Duplicate state that belongs in structured save data

At the end:
1. Summarize changed files
2. Explain manual verification steps
3. List known TODOs
6-2. TASK-06 예시

1-1 불타는 사당

Read these docs first and follow them as the source of truth:

- master_campaign_outline.md
- core_combat_spec.md
- data_schema.md
- flag_progression_spec.md
- docs/ch01_spec.md
- production_backlog.md

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- Prefer StageData/EventData over scene-hardcoded progression
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement stage_ch01_01 (불타는 사당).

Scope:
- Create the stage scene and StageData
- Implement the objective, failure conditions, and reinforcement timing
- Add the required start and clear cutscene hooks
- Add the first tutorial prompts only if minimal UI hooks already exist
- Do not implement unrelated chapter 1 stages

Stage requirements:
- Survive until the defense objective is complete
- Protect at least one civilian
- Use fire tiles and shrine defense ground
- Trigger the first name fragment/identity hint on clear

Allowed files to change:
- scenes/battle/**
- scripts/battle/**
- data/stages/**
- data/text/cutscenes/**
- minimal tutorial text data if needed

Completion criteria:
- The stage can be launched and cleared from a debug entry point
- Reinforcements spawn on the correct turns
- Fire tile damage works
- The stage transitions to the correct clear flow

Test criteria:
- Clear with one civilian alive
- Fail if both civilians die
- Confirm turn-based reinforcements
- Confirm clear cutscene hook fires

Do not:
- Hardcode rewards inside the scene
- Add chapter 2 progression
- Skip the evidence/identity hook on clear

At the end:
1. Summarize changed files
2. Explain how to launch and test the stage
3. List known TODOs
6-3. TASK-10 예시

인벤토리 + 악세사리 슬롯 + 상자 시스템

Read these docs first and follow them as the source of truth:

- data_schema.md
- flag_progression_spec.md
- equipment_system.md
- camp_ui_spec.md
- production_backlog.md

If `equipment_system.md` or `camp_ui_spec.md` does not exist yet, use:

- data_schema.md
- boss_loot_tables.md
- production_backlog.md

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- UI should be mobile-first and tap-driven
- Do not use drag-and-drop unless explicitly required
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement:
- inventory v1
- accessory slot support
- treasure chest opening and reward commit

Scope:
- Add fixed inventory entries to save data
- Support equipping one accessory per unit
- Add a minimal camp equipment screen for accessories
- Make treasure chests resolve reward bundles and persist opened state

Allowed files to change:
- scripts/systems/**
- scenes/ui/camp/**
- scripts/ui/camp/**
- data/** if reward bundle glue is needed

Completion criteria:
- Accessory items can be stored, equipped, and unequipped
- Stats/passives update correctly from accessories
- Chests grant the correct rewards and do not reopen after clear
- Inventory persists across save/load

Test criteria:
- Open a chest and receive an accessory
- Equip the accessory to a valid unit
- Save/load and confirm persistence
- Retry a failed battle and confirm chest state rolls back correctly

Do not:
- Implement armor or random weapons yet
- Hardcode chest rewards inside map scenes
- Duplicate item ownership state in custom flags

At the end:
1. Summarize changed files
2. Explain manual verification steps
3. List known TODOs
6-4. TASK-11 예시

2장 + 브란 합류

Read these docs first and follow them as the source of truth:

- master_campaign_outline.md
- core_combat_spec.md
- data_schema.md
- flag_progression_spec.md
- docs/ch02_spec.md
- production_backlog.md

General constraints:
- Use Godot 4.x
- Use GDScript only
- Keep the project runnable after changes
- Do not refactor unrelated files
- Prefer StageData/EventData over scene-hardcoded progression
- Summarize changed files at the end
- List remaining TODOs separately

Task:
Implement chapter 2 content:
- stage_ch02_01 through stage_ch02_05
- Bran recruitment
- treasure chest rewards defined in the chapter 2 spec

Scope:
- Implement only chapter 2 content and required progression hooks
- Use the existing inventory/accessory system
- Do not add armor, random boss loot, or hunt board features here

Completion criteria:
- All five chapter 2 stages can be played in sequence
- Bran becomes recruited after chapter clear
- Treasure rewards commit correctly
- The chapter transitions into the next evidence/camp flow

Test criteria:
- Clear chapter 2 main path
- Verify Bran is recruited
- Verify chapter-specific treasure rewards
- Verify next destination evidence is logged

Do not:
- Move system unlocks earlier than documented
- Add random weapon drops to chapter 2
- Skip camp dialogue hooks
7. 작업 요청 체크리스트

Codex에 작업을 보내기 전에 아래를 직접 체크한다.

필수 체크
읽을 문서가 최신인가
작업 범위가 하나의 핵심으로 좁혀졌는가
완료 기준이 테스트 가능하게 적혔는가
금지 사항이 충분히 적혔는가
changed files summary를 요청했는가
강력 권장
“현재 프로젝트에서 이미 있는 파일을 우선 활용하라” 문구 넣기
“관련 없는 리팩터링 금지” 문구 넣기
“남은 TODO를 따로 적어라” 문구 넣기
8. 템플릿 사용 금지 패턴

아래처럼 쓰면 Codex가 흔들리기 쉽다.

금지 1

“위 문서들 참고해서 알아서 다 구현해줘”

이건 범위가 너무 넓다.

금지 2

“최대한 예쁘고 완벽하게 만들어줘”

완료 기준이 없다.

금지 3

“나중에 필요한 것도 생각해서 확장 가능하게”
라는 문구만 있고 범위 제한이 없음

확장 가능성은 좋지만, 작업 범위를 넓히는 방식으로 쓰면 안 된다.

금지 4

스토리, UI, 저장, 전투, 드롭을 한 번에 요청

9. 추천 사용 순서

실전에서는 아래 순서대로 템플릿을 가장 많이 쓰게 된다.

Foundation / Service 템플릿
전투 코어 메커닉 템플릿
스테이지 구현 템플릿
장비/UI 템플릿
드롭 템플릿
플래그/진행 로직 템플릿
보스 구현 템플릿
엔딩/포스트게임 템플릿
10. 최종 메모

이 문서의 목적은 프롬프트를 길게 쓰는 게 아니다.
목적은 애매함을 없애는 것이다.

좋은 Codex 작업 요청은 보통 아래 특징을 가진다.

읽을 문서가 명확하다
범위가 좁다
끝났는지 아닌지가 분명하다
테스트 방법이 있다
건드리면 안 되는 부분이 적혀 있다

즉, 이 템플릿은 “더 많은 걸 시키기 위한 문서”가 아니라
덜 흔들리고 더 정확하게 시키기 위한 문서다.
