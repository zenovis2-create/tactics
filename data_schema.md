# Data Schema v1
## Project: 잿빛의 기억

## 1. 문서 목적

이 문서는 게임 전체의 데이터를 어떤 단위로 나누고, 어떤 형식으로 저장하고, 어떤 방식으로 서로 참조할지 고정하는 문서다.

이 문서가 고정하는 것은 아래 다섯 가지다.

1. 정적 데이터와 런타임 데이터의 경계
2. Godot Resource, JSON, Save 파일의 역할 분리
3. 주요 데이터 타입의 필수 필드
4. 참조 규칙, 버전 규칙, 검증 규칙
5. Codex가 파일을 추가/수정할 때 지켜야 할 저장 구조

이 문서는 “클래스 설계 문서”이기도 하지만, 더 정확히는 **소스 오브 트루스 분배 문서**다.  
같은 정보를 두 군데 이상에 저장하지 않게 만드는 것이 목표다.

문서 위계는 아래처럼 고정한다.

1. `docs/game_spec.md`
   - 현재 MVP 범위와 비범위를 고정한다.
2. `docs/engineering_rules.md`
   - 현재 구현 방식과 최소 데이터 계약을 고정한다.
3. `core_combat_spec.md`
   - 전투 규칙과 MVP/확장 경계를 고정한다.
4. `data_schema.md`
   - 위 문서 범위를 넘지 않는 선에서 데이터 구조와 저장 방식을 표준화한다.
5. `master_campaign_outline.md`, `phase*.md`
   - 어떤 데이터가 어느 장에서 실제로 열리는지와 서사 맥락을 고정한다.

---

## 2. 데이터 레이어

게임 데이터는 아래 세 레이어로 나눈다.

또한 현재 프로젝트는 `MVP 수직 슬라이스`, `캠페인 확장`, `포스트-MVP 메타`를 분리해 생각한다.
이 문서에 적힌 모든 스키마가 지금 당장 구현 대상이라는 뜻은 아니다.

### A. Authored Static Data
디자이너가 작성하고 저장소에 커밋되는 정적 데이터다.

예:
- 유닛 원형
- 직업
- 스킬
- 무기 베이스
- 방어구
- 악세사리
- 스테이지
- 보스 드롭 테이블
- 컷신
- 캠프 대화
- 플래그 정의

이 레이어는 기본적으로 **파일로 존재**하고, 플레이 중 변경되지 않는다.

현재 기준:

- MVP 필수
- 캠페인 확장에서도 계속 사용
- 가장 먼저 안정화해야 하는 레이어

### B. Runtime Battle State
전투 중에만 존재하는 휘발성 상태다.

예:
- 현재 위치
- 현재 HP
- 현재 상태이상
- 이번 턴 이동/행동 여부
- 쿨다운
- 이미 열린 상자
- 이미 부순 제단
- 현재 수위 / 전장 개정 상태

이 레이어는 전투 종료 시 대부분 버려진다.  
단, `battle suspend` 기능을 만들 경우에는 별도 스냅샷으로 저장 가능하다.

현재 기준:

- MVP에서 전투 중 메모리 상태는 필수
- 파일로 저장하는 `battle suspend`는 포스트-MVP 또는 후순위

### C. Persistent Profile Save
플레이어 계정/세이브 슬롯에 남는 누적 데이터다.

예:
- 스토리 진행도
- 장비 인벤토리
- 무기 인스턴스
- 보스 문장 수
- 동료 공명 인장
- 열린 회상 토벌전
- 이미 본 컷신/캠프 대화
- 네리 관련 보조 플래그
- 진엔딩 플래그

이 레이어는 저장/로드의 기준이 된다.

현재 기준:

- 풀 캠페인과 메타 시스템 기준으로는 필수
- 하지만 `docs/game_spec.md` 기준 MVP에서는 저장/로드와 장비 메타가 비범위다
- 따라서 이 레이어는 지금 단계에선 **미래 스키마 표준**으로 읽어야 한다

---

## 3. 저장 형식 원칙

### 3-1. Godot Resource (`.tres`)
아래 조건을 만족하는 데이터는 기본적으로 `.tres` Resource로 저장한다.

- 에디터에서 inspector로 만지기 좋다
- 다른 리소스를 자주 참조한다
- 전투 시스템이 자주 읽는다
- 장비/스킬/스테이지처럼 구조가 비교적 엄격하다

대표 대상:
- `UnitData`
- `SkillData`
- `StageData`
- `ClassData` (확장)
- `StatusEffectData` (확장)
- `FieldEffectData` (확장)
- `WeaponBaseData` (포스트-MVP)
- `WeaponAffixData` (포스트-MVP)
- `ArmorData` (포스트-MVP)
- `AccessoryData` (포스트-MVP)
- `ConsumableData` (확장)
- `TreasureChestData`
- `BossLootTableData` (포스트-MVP)
- `AIProfileData` (확장)
- `FlagDefinitionData` (캠페인 확장)

### 3-2. JSON (`.json`)
아래 조건을 만족하는 데이터는 JSON으로 저장한다.

- 작가/기획자가 텍스트를 자주 고친다
- 대사 줄 수가 많고 diff가 중요하다
- 구조는 명확하지만 Resource inspector보다 텍스트 편집이 편하다
- 로컬라이징이나 외부 편집을 염두에 둔다

대표 대상:
- `CutsceneData`
- `CampDialogueData`
- `MemoryFragmentData`
- 편지 / 문서 텍스트
- 튜토리얼 팝업 문안

### 3-3. Save JSON (`.save.json`)
개발 단계에서는 사람이 읽을 수 있게 JSON 저장을 기본으로 한다.

- `save_version` 필수
- `profile_id` 필수
- 향후 암호화/바이너리 전환 가능
- 내부 논리 스키마는 유지

현재 기준:

- 이 저장 형식은 **포스트-MVP 표준**이다.
- MVP 수직 슬라이스 단계에서는 실제 저장 구현을 강제하지 않는다.

### 3-4. Scene (`.tscn`)
맵 지형, 시각 오브젝트, 충돌, 배경 배치는 씬에 둔다.  
단, 전투 규칙과 승패 조건은 씬이 아니라 `StageData`가 가진다.

즉:
- 씬 = 시각/배치
- StageData = 규칙/목표/이벤트

---

## 4. 폴더 구조

```text
data/
  units/
  classes/
  skills/
  status_effects/
  field_effects/
  items/
    weapons/
      base/
      affixes/
      unique/
    armors/
    accessories/
    consumables/
  stages/
  treasure/
  loot/
  ai/
  flags/
  text/
    cutscenes/
    camp_dialogues/
    memory_fragments/
    letters/

saves/
  profile_001.save.json
```

권장 파일명 규칙은 lower_snake_case로 고정한다.

예:

data/units/rian.tres
data/classes/vanguard_commander.tres
data/skills/tactical_shift.tres
data/stages/ch07_05_elyor_prayer.tres
data/text/cutscenes/ch07_05_clear.json

## 5. 전역 ID 규칙

모든 데이터는 사람이 읽을 수 있는 안정 ID를 가진다.

### 5-1. ID 기본 규칙
lower_snake_case
공백 없음
언더스코어만 사용
타입 접두사는 선택이지만, 범주 안에서 일관성 유지
ID는 한 번 공개되면 변경 금지

예:

rian
serin
class_memory_priest
skill_tactical_shift
stage_ch06_05
boss_saria
acc_name_knot
loot_boss_melchion
flag_ch07_mira_saved

### 5-2. 저장 파일은 ID를 참조하고, 경로를 저장하지 않는다

세이브 데이터에는 기본적으로 id만 저장한다.

좋은 예:

{
  "unit_id": "rian",
  "equipped_weapon_instance_id": "wpn_inst_000145"
}

피해야 할 예:

{
  "weapon_path": "res://data/items/weapons/base/holy_sword.tres"
}

경로는 리팩터링에 약하고, ID는 마이그레이션하기 쉽다.

### 5-3. 텍스트 키 규칙

텍스트는 가능하면 *_key를 사용한다.

예:

name_key
desc_key
title_key
body_key

초기 프로토타입에서는 text_raw를 허용하되, 정식 전환 시 *_key 우선 구조로 간다.

## 6. 공통 스키마 규칙

모든 정적 데이터 타입은 아래 필드를 공통으로 가진다.

id: String
schema_version: int
enabled: bool
debug_note: String (optional)
tags: Array[String] (optional)
의미
id: 안정 참조 키
schema_version: 데이터 마이그레이션 기준
enabled: 테스트/비활성 데이터 분기용
debug_note: 에디터용 메모
tags: 검색/필터/가벼운 의미 부여

## 7. 정적 데이터 타입

### 7-0. 구현 단계 표기

이 섹션의 데이터 타입은 아래 세 단계로 읽는다.

- `MVP 필수`: 지금 당장 구현에 필요한 최소 타입
- `캠페인 확장`: 전투/서사 확장 시 도입하는 타입
- `포스트-MVP`: 장비 메타, 저장, 반복 콘텐츠 이후 타입

### 7-1. UnitData

상태: `MVP 필수`

용도: 플레이어 캐릭터, 적 원형, NPC 원형 정의

저장 형식: .tres

UnitData
- id: String
- schema_version: int
- enabled: bool
- name_key: String
- codename: String (optional)
- faction_default: String          # player / enemy / neutral / guest
- unique_character: bool
- recruitable: bool
- class_id: String
- portrait_id: String
- body_scene_path: String (optional)
- base_stats:
    hp: int
    atk: int
    def: int
    res: int
    hit: int
    avo: int
    crit: int
    move: int
- growths: Dictionary (optional)   # 추후 성장 시스템용
- innate_tags: Array[String]
- default_skill_ids: Array[String]
- personal_skill_ids: Array[String]
- default_weapon_template_id: String (optional)
- default_armor_id: String (optional)
- default_accessory_id: String (optional)
- ai_profile_id: String (optional)
- death_behavior: String           # normal / critical_fail / story_fall / retreat
- support_group_id: String (optional)
- description_key: String (optional)
주의
UnitData는 전투 중 위치/HP 같은 상태를 저장하지 않는다.
적/아군 모두 같은 타입을 쓰되, 진행 상태는 세이브 레이어에서 관리한다.
레벨업 결과를 UnitData에 다시 덮어쓰지 않는다.

### 7-2. ClassData

상태: `캠페인 확장`

용도: 직업 규칙, 장착 제한, 이동 특성, 직업 스킬

저장 형식: .tres

ClassData
- id: String
- schema_version: int
- enabled: bool
- name_key: String
- role_tags: Array[String]             # tank / healer / ranger / mage / commander
- weapon_types_allowed: Array[String]  # Sword / Lance / Bow / Staff / Tome
- armor_types_allowed: Array[String]   # light / heavy / robe
- base_move_override: int (optional)
- terrain_cost_profile_id: String
- class_skill_ids: Array[String]
- passive_trait_ids: Array[String]
- command_skill_ids: Array[String]     # 리안/특수 직업용
- description_key: String
원칙
이동 비용은 클래스가 직접 숫자를 들고 있지 않고, terrain_cost_profile_id를 참조한다.
장착 가능 무기군과 방어구군은 클래스가 결정한다.

### 7-3. TerrainCostProfileData

상태: `캠페인 확장`

용도: 클래스별 지형 이동 비용 정의

저장 형식: .tres

TerrainCostProfileData
- id: String
- schema_version: int
- enabled: bool
- move_costs: Dictionary[String, int]
- impassable_tags: Array[String]

예:

보병
기병
유격
성직
실험체 특수 이동

메모:

- 현재 MVP에서는 `TileMapLayer`의 타일 메타데이터(`move_cost`, `terrain_type`, `blocked`)만으로도 충분하다.
- 클래스별 지형 이동 차등은 캠페인 확장 시점에 이 타입으로 올린다.

### 7-4. SkillData

상태: `MVP 필수`

용도: 기본 공격 외 모든 능동/수동 스킬 정의

저장 형식: .tres

SkillData
- id: String
- schema_version: int
- enabled: bool
- name_key: String
- desc_key: String
- icon_id: String
- action_type: String              # basic_like / skill / support / command
- target_team: String              # ally / enemy / self / tile / object
- target_shape: String             # single / line / cone / cross / radius / global
- target_size: int
- range_min: int
- range_max: int
- damage_type: String              # physical / mystic / true / heal / status_only
- power_flat: int
- heal_base: int
- heal_ratio: float
- hit_mod: int
- crit_mod: int
- cooldown_max: int
- charges_per_battle: int
- can_counter: bool
- can_be_countered: bool
- requires_los: bool
- skill_tags: Array[String]
- applied_statuses: Array[StatusApplyRule]
- removed_status_ids: Array[String]
- movement_effect: MovementEffectData (optional)
- summon_unit_id: String (optional)
- summon_count: int (optional)
- ai_weight_hint: int
- telegraph:
    enabled: bool
    lead_turns: int
    text_key: String (optional)
    show_area_preview: bool
- vfx_id: String (optional)
- sfx_id: String (optional)
보조 구조체
StatusApplyRule
- status_id: String
- stacks: int
- duration_turns: int
- chance: int            # 0~100, 기본 100
- on_hit_only: bool
MovementEffectData
- kind: String           # push / pull / swap / reposition / dash / compel
- distance: int
- require_empty_tile: bool
- ignore_zoc: bool
원칙
스킬이 만드는 수치/상태/이동은 모두 SkillData에 정의한다.
AI의 “왜 이 스킬을 쓰는가”는 향후 별도 AI 문서로 분리 가능하다.
현재는 `docs/game_spec.md`, `docs/engineering_rules.md`, `core_combat_spec.md` 기준으로만 해석한다.

### 7-5. StatusEffectData

상태: `캠페인 확장`

용도: 상태이상 정의

저장 형식: .tres

StatusEffectData
- id: String
- schema_version: int
- enabled: bool
- name_key: String
- desc_key: String
- max_stacks: int
- default_duration_turns: int
- dispel_tags: Array[String]
- stack_behavior: String         # refresh / add / replace / ignore_if_present
- start_of_turn_effects: Array[StatOrRuleEffect]
- end_of_turn_effects: Array[StatOrRuleEffect]
- passive_modifiers: Array[StatOrRuleEffect]
- ui_priority: int
- icon_id: String
StatOrRuleEffect
- kind: String                   # stat_mod / rule_lock / damage / heal / cleanse
- stat_id: String (optional)
- value: float
- tags: Array[String]
예
forget
mark
silence
seal
fear
burn
sleep
stealth

### 7-6. FieldEffectData

상태: `캠페인 확장`

용도: 정화 타일, 오염 구역, 여백 구역, 이름 앵커 오라 등 전장 필드 효과 정의

저장 형식: .tres

FieldEffectData
- id: String
- schema_version: int
- enabled: bool
- name_key: String
- desc_key: String
- effect_tags: Array[String]
- applies_on: String             # turn_start / turn_end / while_standing / phase_start
- stat_modifiers: Array[StatOrRuleEffect]
- status_apply_rules: Array[StatusApplyRule]
- status_remove_ids: Array[String]
- damage_flat: int
- heal_flat: int
- blocks_skill_tags: Array[String]
- ui_color_hint: String (optional)
- icon_id: String (optional)

### 7-7. WeaponBaseData

상태: `포스트-MVP`

용도: 랜덤 무기 생성의 기반이 되는 베이스 무기 정의

저장 형식: .tres

WeaponBaseData
- id: String
- schema_version: int
- enabled: bool
- name_key: String
- weapon_type: String
- chapter_min: int
- chapter_max: int
- rarity_floor: String           # advanced / rare / heroic / unique_candidate
- range_min: int
- range_max: int
- mt: int
- hit: int
- crit: int
- allowed_class_tags: Array[String]
- implicit_trait_ids: Array[String]
- drop_weight: int
- icon_id: String
- model_id: String (optional)
- description_key: String
원칙
베이스 무기는 “랜덤 옵션 없는 핵심 몸통”이다.
실제 인벤토리에 들어가는 건 WeaponInstanceData다.

### 7-8. WeaponAffixData

상태: `포스트-MVP`

용도: 랜덤 옵션 정의

저장 형식: .tres

WeaponAffixData
- id: String
- schema_version: int
- enabled: bool
- name_key: String
- affix_slot: String              # prefix / suffix / neutral
- rarity_min: String
- chapter_min: int
- chapter_max: int
- allowed_weapon_types: Array[String]
- blocked_affix_ids: Array[String]
- stat_mods: Dictionary[String, int]
- pct_mods: Dictionary[String, float]
- passive_trait_ids: Array[String]
- weight: int
- description_key: String
예시
precise
cleansing
hunters
of_dawn
of_silence_break
inkbreak

### 7-9. UniqueWeaponTemplateData

상태: `포스트-MVP`

용도: 이름 있는 고정 유니크 무기 정의

저장 형식: .tres

UniqueWeaponTemplateData
- id: String
- schema_version: int
- enabled: bool
- name_key: String
- weapon_type: String
- range_min: int
- range_max: int
- mt: int
- hit: int
- crit: int
- passive_trait_ids: Array[String]
- unique_skill_id: String (optional)
- source_boss_id: String
- chapter_min: int
- icon_id: String
- description_key: String
원칙
유니크는 랜덤 옵션을 붙이지 않는다.
유니크가 중복 드롭되면 분해 재화 또는 문장 보상으로 대체한다.

### 7-10. ArmorData

상태: `포스트-MVP`

용도: 고정형 방어구 정의

저장 형식: .tres

ArmorData
- id: String
- schema_version: int
- enabled: bool
- name_key: String
- armor_type: String              # light / heavy / robe
- chapter_min: int
- hp_bonus: int
- def_bonus: int
- res_bonus: int
- avo_bonus: int
- passive_trait_ids: Array[String]
- upgrade_limit: int
- icon_id: String
- description_key: String
원칙
방어구는 랜덤 옵션이 없다.
강화 수치는 정적 데이터 + 세이브의 upgrade_level로 계산한다.

### 7-11. AccessoryData

상태: `포스트-MVP`

용도: 고정형 악세사리 정의

저장 형식: .tres

AccessoryData
- id: String
- schema_version: int
- enabled: bool
- name_key: String
- chapter_min: int
- stat_mods: Dictionary[String, int]
- passive_trait_ids: Array[String]
- unique_flag: bool
- source_hint_key: String (optional)
- icon_id: String
- description_key: String
원칙
악세사리는 전술을 바꾸는 고유 효과 위주다.
수집성과 탐색 보상을 담당하므로 랜덤화하지 않는다.

### 7-12. ConsumableData

상태: `캠페인 확장`

용도: 응급약, 해제약, 투척물 등 소비형 아이템

저장 형식: .tres

ConsumableData
- id: String
- schema_version: int
- enabled: bool
- name_key: String
- stack_limit: int
- use_action_id: String
- battle_only: bool
- icon_id: String
- description_key: String

### 7-13. TreasureChestData

상태: `캠페인 확장`

용도: 보물상자 정의

저장 형식: .tres

TreasureChestData
- id: String
- schema_version: int
- enabled: bool
- stage_id: String
- position: Vector2i
- reveal_type: String             # visible / cracked_wall / switch / npc_hint / side_objective
- open_condition_id: String (optional)
- reward_bundle_id: String
- missable: bool
- fallback_to_camp_shop: bool
- hint_text_key: String (optional)
- once_per_profile: bool
원칙
상자는 스테이지 씬에 직접 보상을 하드코딩하지 않는다.
어떤 보상이 나오는지는 반드시 reward_bundle_id로만 연결한다.

### 7-14. RewardBundleData

상태: `캠페인 확장`

용도: 상자, 보스 보상, 서브 목표 보상 등 묶음 보상 정의

저장 형식: .tres

RewardBundleData
- id: String
- schema_version: int
- enabled: bool
- entries: Array[RewardEntry]
RewardEntry
- reward_type: String            # gold / consumable / armor / accessory / weapon_instance / sigil / material / unlock
- target_id: String
- quantity: int
- meta: Dictionary
원칙
장별 보상은 가능한 RewardBundleData로 재사용한다.
스테이지 문서엔 “무엇을 주는가”가 아니라 reward_bundle_id만 넣는다.

### 7-15. BossLootTableData

상태: `포스트-MVP`

용도: 보스 랜덤 무기 드롭 테이블 정의

저장 형식: .tres

BossLootTableData
- id: String
- schema_version: int
- enabled: bool
- boss_id: String
- chapter: int
- philosophy_tags: Array[String]
- first_clear_min_rarity: String
- replay_min_rarity: String
- rarity_weights_first_clear: Dictionary[String, int]
- rarity_weights_replay: Dictionary[String, int]
- weapon_type_weights: Dictionary[String, int]
- base_weapon_pool_ids: Array[String]
- unique_weapon_pool_ids: Array[String]
- allowed_affix_ids: Array[String]
- banned_affix_ids: Array[String]
- bonus_drop_chance: float
- sigil_reward_count: int
- run_seed_mode: String          # per_entry / per_run
원칙
보스 철학과 드롭 키워드가 맞아야 한다.
같은 보스라도 첫 클리어와 회상 토벌전의 최소 희귀도는 다를 수 있다.

### 7-16. StageData

상태: `MVP 필수`, 일부 필드는 `캠페인 확장` 또는 `포스트-MVP`

용도: 스테이지의 규칙 전체 정의
맵 씬은 map_scene_path로 연결하고, 승패 조건과 이벤트는 StageData가 가진다.

저장 형식: .tres

StageData
- id: String
- schema_version: int
- enabled: bool
- chapter: int
- part: String (optional)        # main / 9a / 9b / finale
- subchapter: String
- title_key: String
- map_scene_path: String
- recommended_level: int
- turn_limit: int
- allow_suspend_save: bool
- deployment_slots: int
- fixed_party_unit_ids: Array[String]
- guest_unit_ids: Array[String]
- npc_unit_ids: Array[String]
- objective_ids: Array[String]
- failure_rule_ids: Array[String] (optional)
- spawn_ids: Array[String]
- field_zone_ids: Array[String]
- interactive_object_ids: Array[String]
- treasure_chest_ids: Array[String]
- stage_event_ids: Array[String]
- reward_bundle_clear_id: String
- reward_bundle_bonus_id: String (optional)
- start_cutscene_id: String (optional)
- clear_cutscene_id: String (optional)
- fail_cutscene_id: String (optional)
- memory_fragment_id: String (optional)
- next_evidence_ids: Array[String]
- boss_unit_id: String (optional)
- boss_loot_table_id: String (optional)
- unlocks_hunt_id: String (optional)
하위 타입
ObjectiveData
- id: String
- objective_type: String     # defeat_boss / survive_turns / escort / hold / destroy_targets / escape
- target_ids: Array[String]
- required_count: int
- text_key: String
- is_primary: bool
UnitSpawnData
- id: String
- unit_id: String
- faction: String
- position: Vector2i
- ai_profile_id: String (optional)
- level_override: int (optional)
- equipment_override_ids: Dictionary
- starts_hidden: bool
- spawn_group: String (optional)
- event_spawn_only: bool
FieldZoneData
- id: String
- field_effect_id: String
- shape: String              # rect / list / ring / line
- cells: Array[Vector2i]
- active_from_turn: int
- active_until_turn: int
- enabled_by_default: bool
InteractiveObjectData
- id: String
- object_type: String        # lever / gate / chest / tower / altar / turret / anchor
- position: Vector2i
- hp: int
- def: int
- res: int
- interact_condition_id: String (optional)
- linked_stage_event_ids: Array[String]
- tags: Array[String]
StageEventData
- id: String
- trigger_type: String       # turn_start / turn_end / hp_below / object_destroyed / area_entered / all_targets_done / custom_flag
- trigger_value: Dictionary
- once_only: bool
- actions: Array[StageEventAction]
StageEventAction
- kind: String               # spawn / dialogue / field_toggle / move_object / objective_update / reward / cutscene / phase_change / ai_swap
- payload: Dictionary
원칙
스테이지 씬 안에는 승리 조건, 드롭, 연출 순서 같은 설계 정보를 넣지 않는다.
StageData는 로직, 씬은 배치다.

MVP 최소 필드 메모:

- `id`
- `schema_version`
- `enabled`
- `chapter`
- `subchapter`
- `title_key` 또는 임시 `text_raw`
- `map_scene_path`
- `deployment_slots`
- `objective_ids`
- `spawn_ids`
- `failure_rule_ids` 또는 기본 전멸 규칙
- `boss_unit_id` (필요 시)

나머지 컷신, 기억 조각, 보스 드롭, 회상 해금, 보너스 보상은 단계적으로 추가한다.

### 7-17. AIProfileData

상태: `캠페인 확장`

용도: 적 행동 우선순위 프로필 정의

저장 형식: .tres

AIProfileData
- id: String
- schema_version: int
- enabled: bool
- role: String                  # melee / archer / healer / assassin / commander / boss
- target_priority_tags: Array[String]
- avoid_tags: Array[String]
- preferred_skill_ids: Array[String]
- aggression: int               # 0~100
- retreat_threshold_hp_pct: int
- objective_bias: String        # attack / defend / escort / hold / chase
- notes_key: String (optional)
원칙
AIProfileData는 “행동 코드”가 아니라 “행동 성향 데이터”다.
실제 해석 규칙은 향후 별도 AI 문서로 분리 가능하다.
현재는 `docs/game_spec.md`의 MVP AI와 `core_combat_spec.md`의 공정성 원칙을 따른다.

### 7-18. FlagDefinitionData

상태: `캠페인 확장`

용도: 영속 플래그 정의

저장 형식: .tres

FlagDefinitionData
- id: String
- schema_version: int
- enabled: bool
- scope: String               # profile / stage / chapter / battle_temp
- value_type: String          # bool / int / string
- default_value: Variant
- category: String            # story / reward / npc / ending / hunt / tutorial
- description_key: String
예
flag_ch01_nery_saved
flag_ch05_records_collected_2plus
flag_ch09a_kyle_recruited
flag_true_ending_ready

### 7-19. CutsceneData

상태: `캠페인 확장`

용도: 전투 전/후 컷신, 장면 전환 대사

저장 형식: .json

CutsceneData
- id: String
- schema_version: int
- title_key: String (optional)
- scene_context: String           # battle_intro / battle_clear / camp / interlude / ending
- lines: Array[CutsceneLine]
- auto_set_flags: Array[FlagWrite] (optional)
- next_cutscene_id: String (optional)
CutsceneLine
- speaker_id: String
- portrait_id: String (optional)
- body_key: String
- emotion: String (optional)
- camera: String (optional)
- sfx_id: String (optional)
- vfx_id: String (optional)
- pause_ms: int (optional)
FlagWrite
- flag_id: String
- op: String                     # set / add / clear
- value: Variant
원칙
컷신은 텍스트와 연출 메타만 가진다.
전투 로직 분기는 StageEvent나 Flag 조건으로 처리한다.

### 7-20. CampDialogueData

상태: `캠페인 확장`

용도: 장 종료 후 캠프 공명 대화 정의

저장 형식: .json

CampDialogueData
- id: String
- schema_version: int
- category: String             # evidence / memory / npc / item / forge / letter
- trigger_conditions: Array[ConditionRule]
- priority: int
- one_time: bool
- lines: Array[CutsceneLine]
- grants_flag_id: String (optional)
ConditionRule
- kind: String                 # flag / item_owned / chapter_reached / stage_cleared / unit_recruited
- key: String
- op: String
- value: Variant
원칙
캠프 대화는 “서사 분량”이 아니라 “조건 + 짧은 반응”으로 운영한다.
조건 판정은 데이터로 하고, 대화 UI는 하나의 공통 씬을 쓴다.

### 7-21. MemoryFragmentData

상태: `캠페인 확장`

용도: 기억 조각 연출과 해석 구조 정의

저장 형식: .json

MemoryFragmentData
- id: String
- schema_version: int
- chapter: int
- source_stage_id: String
- scene_summary_key: String
- interpretation_now_key: String
- reinterpretation_later_keys: Array[String]
- final_interpretation_key: String (optional)
- cutscene_id: String
- related_evidence_ids: Array[String]
- related_flag_ids: Array[String]
원칙
기억 조각은 단독 진실이 아니다.
interpretation_now_key와 final_interpretation_key를 분리해 둔다.

### 7-22. EvidenceData

상태: `캠페인 확장`

용도: 다음 목적지 물증, 문서, 명령서, 인장, 증언 기록 정의

저장 형식: .json 또는 .tres
초기에는 .json 권장

EvidenceData
- id: String
- schema_version: int
- evidence_type: String        # document / order / testimony / coordinate / token / seal
- name_key: String
- body_key: String
- chapter_obtained: int
- source_stage_id: String
- unlocks_next_target_hint_key: String
- icon_id: String
- related_flag_id: String (optional)
원칙
“왜 다음 지역으로 가는가”를 문서화하는 핵심 타입이다.
인벤토리의 Story / Evidence 탭에서 확인 가능하게 설계한다.

## 8. 영속 저장 데이터 타입

이 섹션은 기본적으로 `포스트-MVP` 표준이다.
현재 MVP 수직 슬라이스 단계에서는 실제 구현을 강제하지 않는다.

### 8-1. ProfileSaveData

용도: 세이브 슬롯 전체

저장 형식: .save.json

ProfileSaveData
- save_version: int
- profile_id: String
- created_at: String
- updated_at: String
- playtime_seconds: int
- current_chapter_id: String
- current_stage_id: String
- cleared_stage_ids: Array[String]
- unlocked_hunt_ids: Array[String]
- flags: Dictionary[String, Variant]
- unit_progress: Dictionary[String, UnitProgressRecord]
- weapon_instances: Array[WeaponInstanceData]
- fixed_inventory_entries: Array[InventoryEntryData]
- sigils_by_boss: Dictionary[String, int]
- hunt_run_index_by_boss: Dictionary[String, int]
- discovered_treasure_ids: Array[String]
- viewed_cutscene_ids: Array[String]
- viewed_camp_dialogue_ids: Array[String]
- viewed_letter_ids: Array[String]
- options: Dictionary
- suspended_battle: BattleSnapshotData (optional)

### 8-2. UnitProgressRecord

용도: 플레이어가 영속적으로 보유하는 캐릭터 상태

UnitProgressRecord
- unit_id: String
- recruited: bool
- available: bool
- level: int
- exp: int
- current_class_id: String
- bonus_stats: Dictionary[String, int]
- learned_skill_ids: Array[String]
- equipped_weapon_instance_id: String (optional)
- equipped_armor_entry_id: String (optional)
- equipped_accessory_entry_id: String (optional)
- bond_points: Dictionary[String, int]
- last_deployed_stage_id: String (optional)
원칙
레벨업으로 오른 수치는 bonus_stats에만 저장하고, 원본 UnitData는 수정하지 않는다.
장착 정보는 유닛 기록에 저장한다.

### 8-3. WeaponInstanceData

용도: 랜덤으로 생성된 개별 무기 인스턴스

WeaponInstanceData
- instance_id: String
- base_id: String
- rarity: String
- affix_ids: Array[String]
- rolled_stat_mods: Dictionary[String, int]
- passive_trait_ids: Array[String]
- source_boss_id: String
- source_stage_id: String
- seed: int
- locked: bool
- favorite: bool
- is_new: bool
원칙
랜덤 무기는 “베이스 + 옵션 조합”을 인스턴스로 영속 저장한다.
같은 이름의 무기라도 instance_id가 다르면 다른 아이템이다.

### 8-4. InventoryEntryData

용도: 고정형 아이템 소유 상태

InventoryEntryData
- entry_id: String
- item_kind: String            # armor / accessory / consumable / material
- item_id: String
- quantity: int
- upgrade_level: int
- locked: bool
- favorite: bool
- is_new: bool
원칙
방어구/악세사리는 랜덤이 아니므로 item_id + upgrade_level만 저장하면 충분하다.
소모품과 재료는 수량 스택을 가진다.

### 8-5. BattleSnapshotData

용도: 전투 중단 저장 / 앱 종료 복구용
P1 또는 P2에서 사용

BattleSnapshotData
- stage_id: String
- round_index: int
- active_phase: String
- active_unit_runtime_id: String (optional)
- runtime_units: Array[BattleUnitStateData]
- opened_chest_ids: Array[String]
- destroyed_object_ids: Array[String]
- stage_runtime_flags: Dictionary[String, Variant]
- pending_event_ids: Array[String]
- random_state:
    battle_seed: int
    loot_seed: int
    ai_seed: int
BattleUnitStateData
- runtime_id: String
- source_unit_id: String
- faction: String
- position: Vector2i
- current_hp: int
- active_statuses: Array[RuntimeStatusEntry]
- cooldowns: Dictionary[String, int]
- charges_left: Dictionary[String, int]
- has_moved: bool
- has_acted: bool
- spawned_this_battle: bool
- temporary_mods: Dictionary
RuntimeStatusEntry
- status_id: String
- stacks: int
- turns_left: int
원칙
중단 저장은 “정적 데이터 참조 + 런타임 델타”만 저장한다.
정적 StageData 전체를 BattleSnapshot에 복사하지 않는다.

## 9. 드롭과 RNG 관련 저장 규칙

이 섹션은 `포스트-MVP` 장비/반복 콘텐츠 루프 기준이다.

### 9-1. 보스 드롭 시드

같은 전투 시도 안에서는 결과가 고정되어야 한다.

loot_seed = hash(profile_id + boss_id + stage_id + run_index)
run_index는 회상 토벌전에 새로 입장할 때만 증가
턴 저장 / 체크포인트 로드로는 드롭이 바뀌지 않음

이 때문에 아래 데이터가 세이브에 반드시 있어야 한다.

hunt_run_index_by_boss: Dictionary[String, int]

### 9-2. 문장 저장

보스 문장은 보스별 누적량으로 저장한다.

sigils_by_boss: Dictionary[String, int]

예:

{
  "boss_saria": 4,
  "boss_lete": 7,
  "boss_melchion": 10
}

### 9-3. 선택 제작 기록

희귀 무기 제작/교정은 인스턴스를 만든 뒤 WeaponInstanceData로 저장한다.
“제작됐음” 자체를 따로 저장할 필요는 없다.
재료와 문장만 차감하면 된다.

## 10. 참조 해석 규칙

### 10-1. 정적 데이터 참조는 ID 기반

예:

unit.class_id -> ClassData.id
skill.applied_statuses[].status_id -> StatusEffectData.id
stage.treasure_chest_ids[] -> TreasureChestData.id
boss_loot_table.base_weapon_pool_ids[] -> WeaponBaseData.id

### 10-2. 로딩 시에는 레지스트리 캐시를 만든다

게임 시작 또는 로비 진입 시 아래 캐시를 구성한다.

DataRegistry
- units_by_id
- classes_by_id
- skills_by_id
- statuses_by_id
- field_effects_by_id
- weapons_by_id
- affixes_by_id
- armors_by_id
- accessories_by_id
- consumables_by_id
- stages_by_id
- chests_by_id
- rewards_by_id
- loot_tables_by_id
- ai_profiles_by_id
- flags_by_id

JSON 계열은 별도 텍스트 레지스트리로 캐시한다.

### 10-3. 세이브 로드는 ID 검증을 먼저 한다

세이브에서 참조하는 item_id, unit_id, stage_id가 없는 경우:

개발 빌드: 경고 + fallback
배포 빌드: 마이그레이션 또는 안전 차단

## 11. 검증 규칙

게임 실행 전 또는 빌드 전 자동 검증해야 하는 규칙이다.

### 11-1. 전역 검증
모든 id는 중복되면 안 됨
schema_version 누락 금지
비활성 데이터(enabled=false)는 참조 금지
정적 데이터는 존재하지 않는 참조를 가지면 안 됨

### 11-2. StageData 검증
주요 목표(is_primary=true)가 최소 1개 있어야 함
패배 조건은 `failure_rule_ids` 또는 기본 전멸 규칙으로 해석 가능해야 함
map_scene_path가 실제로 존재해야 함
boss_loot_table_id가 있으면 boss_unit_id도 있어야 함
memory_fragment_id가 있으면 실제 데이터가 있어야 함
next_evidence_ids는 최소 1개 이상 권장

### 11-3. 장비 검증
WeaponBaseData.weapon_type는 허용 enum이어야 함
WeaponAffixData는 허용되지 않은 무기군에 붙으면 안 됨
ArmorData.armor_type는 허용 enum이어야 함
유니크 무기는 유니크 풀에만 존재해야 함

### 11-4. 보스 드롭 검증
첫 클리어 최소 희귀도 < 재플레이 최소 희귀도 같은 모순 금지
유니크 무기군과 첫 클리어 가중치가 완전히 충돌하면 안 됨
철학 태그와 드롭 키워드의 설명이 문서와 어긋나지 않아야 함

### 11-5. 플래그 검증
진엔딩 필수 플래그는 모두 FlagDefinitionData에 정의돼 있어야 함
캠프 대화의 조건 플래그는 실제로 존재해야 함
장 문서에 언급된 물증은 EvidenceData로 존재해야 함

## 12. 마이그레이션 규칙

### 12-1. Save Version

세이브 파일은 반드시 save_version을 가진다.

save_version = 1

버전이 바뀌면 SaveMigrationService가 아래를 담당한다.

필드 추가 기본값 채우기
이름이 바뀐 ID 변환
삭제된 데이터 fallback 처리
더 이상 유효하지 않은 장비/플래그 제거 또는 치환

### 12-2. Schema Version

각 정적 데이터에도 schema_version이 있지만, 초기에는 대부분 1로 시작한다.
이 값은 “파일 포맷의 변화”를 추적하는 용도다.
밸런스 숫자 조정만으로는 올리지 않는다.

## 13. 실제 사용 예시

### 13-1. SkillData 예시
id: skill_tactical_shift
schema_version: 1
enabled: true
name_key: skill.tactical_shift.name
desc_key: skill.tactical_shift.desc
icon_id: icon_tactical_shift
action_type: command
target_team: ally
target_shape: single
target_size: 1
range_min: 1
range_max: 1
damage_type: status_only
power_flat: 0
heal_base: 0
heal_ratio: 0
hit_mod: 0
crit_mod: 0
cooldown_max: 0
charges_per_battle: 2
can_counter: false
can_be_countered: false
requires_los: false
skill_tags: [command, reposition]
applied_statuses: []
removed_status_ids: []
movement_effect:
  kind: swap
  distance: 1
  require_empty_tile: false
  ignore_zoc: true
telegraph:
  enabled: false
  lead_turns: 0
  text_key: ""
  show_area_preview: false

### 13-2. TreasureChestData 예시
id: chest_ch06_05_wall_wedge
schema_version: 1
enabled: true
stage_id: stage_ch06_05
position: (14, 3)
reveal_type: side_objective
open_condition_id: cond_ch06_restore_counterweights
reward_bundle_id: reward_ch06_hidden_wall_wedge
missable: false
fallback_to_camp_shop: true
hint_text_key: stage.ch06.hidden_wall_wedge_hint
once_per_profile: true

### 13-3. WeaponInstanceData 예시
instance_id: wpn_inst_000145
base_id: base_bow_night_hunter
rarity: rare
affix_ids: [affix_precise, affix_of_shadows]
rolled_stat_mods:
  hit: 10
  atk: 2
passive_trait_ids: [trait_bonus_vs_marked]
source_boss_id: boss_lete
source_stage_id: hunt_lete
seed: 92834115
locked: false
favorite: false
is_new: true

### 13-4. ProfileSaveData 예시
save_version: 1
profile_id: profile_001
created_at: 2026-04-12T10:25:00Z
updated_at: 2026-04-12T13:51:00Z
playtime_seconds: 18420
current_chapter_id: ch07
current_stage_id: stage_ch07_04
cleared_stage_ids:
  - stage_ch01_01
  - stage_ch01_02
  - stage_ch01_03
flags:
  flag_ch01_nery_saved: true
  flag_ch05_enok_recruited: true
  flag_ch06_forge_unlocked: true
sigils_by_boss:
  boss_saria: 2
  boss_lete: 1
hunt_run_index_by_boss:
  boss_saria: 4
  boss_lete: 1
discovered_treasure_ids:
  - chest_ch02_01_militia_badge
  - chest_ch03_02_trap_pin

## 14. Codex 작업 규칙

Codex가 이 프로젝트를 수정할 때는 아래 원칙을 지킨다.

### 14-1. 새 데이터 타입을 만들기 전에 기존 타입 재사용 가능성을 먼저 본다

예:

보스 서브 보상은 새 타입을 만들지 말고 RewardBundleData를 재사용
캠프 편지는 새 UI 타입을 만들지 말고 CampDialogueData 또는 CutsceneData의 변형으로 처리 가능 여부 검토

### 14-2. 저장용 인스턴스와 정적 템플릿을 혼동하지 않는다

WeaponBaseData는 설계 데이터
WeaponInstanceData는 세이브에 남는 개별 아이템

둘을 섞으면 장비 저장이 금방 무너진다.

### 14-3. Stage 씬에 설계 정보를 하드코딩하지 않는다

보상
승리 조건
보스 드롭
다음 목적지 물증
기억 조각 ID
는 반드시 StageData 쪽에 둔다.

### 14-4. 저장 가능한 모든 값은 “복원 가능 여부”를 기준으로 판단한다

복원 가능한 값은 저장하지 않는다.

예:

WeaponBaseData.name_key는 저장할 필요 없음
UnitData.base_stats도 저장할 필요 없음
하지만 WeaponInstanceData.seed, affix_ids, upgrade_level은 저장해야 함

## 15. 다음 문서와의 연결

이 문서를 만든 뒤에는 아래 문서가 이어져야 한다.

- `flag_progression_spec.md` 또는 동등한 플래그 문서
- `ai_behavior_spec.md` 또는 동등한 AI 문서
- `memory_fragments.md`
- `boss_loot_tables.md`

단, 이 문서들은 현재 실제 파일이 없을 수 있다.
없는 경우에는 아래 정본 문서를 먼저 따른다.

- `docs/game_spec.md`
- `docs/engineering_rules.md`
- `core_combat_spec.md`
- `master_campaign_outline.md`

그중 다음 우선순위는 **플래그 진행 문서**다.
지금 구조는 재등장 NPC, 장 종료 물증, 진엔딩 플래그가 많아서 저장 플래그 체계를 먼저 고정하는 편이 가장 안전하다.
