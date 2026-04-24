class_name CampController
extends Node

## 캠프 진입 흐름 오케스트레이터
## - enter_camp(): 전투 결과 → CampData 빌드 → 허브 준비
## - get_camp_summary(): 현재 캠프 상태 스냅샷 반환

const CampData = preload("res://scripts/data/camp_data.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const ProgressionService = preload("res://scripts/battle/progression_service.gd")
const ForgeService = preload("res://scripts/battle/forge_service.gd")
const HuntBoard = preload("res://scripts/battle/hunt_board.gd")
const HuntStageRegistry = preload("res://scripts/battle/hunt_stage_registry.gd")
const BattleController = preload("res://scripts/battle/battle_controller.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")

const MODE_CAMP: String = "camp"

const AXIS_SORTIE: StringName = &"sortie"
const AXIS_EQUIPMENT: StringName = &"equipment"
const AXIS_RECORDS: StringName = &"records"
const AXIS_SAVE: StringName = &"save"
const AXIS_STORAGE: StringName = &"storage"
const AXIS_DISMANTLE: StringName = &"dismantle"
const AXIS_FORGE: StringName = &"forge"
const AXIS_RECALL: StringName = &"recall"

## 항상 해금: 편성 / 장비 / 기록 / 보관
const BASE_AXES: Array[StringName] = [AXIS_SORTIE, AXIS_EQUIPMENT, AXIS_RECORDS, AXIS_SAVE]

## ch04+ 이후 추가 해금
const STORAGE_UNLOCK_CHAPTERS: Array[StringName] = [
    &"ch04", &"ch05", &"ch06", &"ch07", &"ch08", &"ch09a", &"ch09b", &"ch10"
]
const FORGE_UNLOCK_CHAPTERS: Array[StringName] = [
    &"ch06", &"ch07", &"ch08", &"ch09a", &"ch09b", &"ch10"
]
const RECALL_UNLOCK_CHAPTERS: Array[StringName] = [
    &"ch08", &"ch09a", &"ch09b", &"ch10"
]

signal camp_entered(camp_data: CampData)
signal camp_exited

var _camp_data: CampData = null
var _save_service: SaveService = null
var _event_log: Array[Dictionary] = []
var _newly_unlocked_commands: Array[String] = []
var _recently_recovered_fragments: Array[String] = []
var _hunt_board: HuntBoard = null

func enter_camp(
    chapter: StringName,
    stage_clear_result: Dictionary,
    progression: ProgressionData = null
) -> CampData:
    _camp_data = CampData.new()
    if _hunt_board == null:
        _hunt_board = HuntBoard.new()
        add_child(_hunt_board)
    _hunt_board.set_progression_data(progression)
    _camp_data.current_chapter = chapter
    _camp_data.stage_clear_result = stage_clear_result
    _camp_data.last_hunt_result = stage_clear_result.duplicate(true)
    _camp_data.burden = progression.burden if progression != null else 0
    _camp_data.trust = progression.trust if progression != null else 0
    _camp_data.gold = progression.gold if progression != null else 0
    _camp_data.ending_tendency = progression.ending_tendency if progression != null else &"undetermined"
    _camp_data.narrative_axis_entries = _build_narrative_axis_entries(progression)
    _camp_data.recovered_fragment_count = progression.recovered_fragments.size() if progression != null else 0
    _camp_data.unlocked_command_count = progression.unlocked_commands.size() if progression != null else 0
    if progression != null:
        _camp_data.recovered_fragment_ids = progression.get_recovered_fragment_ids()
        _camp_data.unlocked_command_ids = progression.get_unlocked_command_ids()
        _newly_unlocked_commands = progression.get_newly_unlocked_commands()
        _recently_recovered_fragments = progression.get_recently_recovered_fragments()
        progression.snapshot_unlock_state()
    else:
        var empty_ids: Array[String] = []
        _camp_data.recovered_fragment_ids = empty_ids
        _camp_data.unlocked_command_ids = empty_ids
        _newly_unlocked_commands = []
        _recently_recovered_fragments = []
    _camp_data.unlocked_axes = _compute_unlocked_axes(chapter)
    _refresh_forge_snapshot(progression)
    _refresh_recall_snapshot()
    _enter_default_state()
    _build_pending_notifications(stage_clear_result)
    _event_log.append({"event": "camp_entered", "chapter": chapter})
    camp_entered.emit(_camp_data)
    return _camp_data

func exit_camp() -> void:
    if _camp_data != null:
        _event_log.append({"event": "camp_exited", "chapter": _camp_data.current_chapter})
    camp_exited.emit()
    _camp_data = null

func get_camp_summary() -> Dictionary:
    if _camp_data == null:
        return {}
    return {
        "chapter": _camp_data.current_chapter,
        "mode": _camp_data.current_mode,
        "active_axis": _camp_data.active_axis,
        "burden": _camp_data.burden,
        "trust": _camp_data.trust,
        "gold": _camp_data.gold,
        "ending_tendency": _camp_data.ending_tendency,
        "narrative_axis_entries": _camp_data.narrative_axis_entries.duplicate(true),
        "recovered_fragments": _camp_data.recovered_fragment_count,
        "unlocked_commands": _camp_data.unlocked_command_count,
        "recovered_fragment_ids": _camp_data.recovered_fragment_ids.duplicate(),
        "unlocked_command_ids": _camp_data.unlocked_command_ids.duplicate(),
        "newly_unlocked_commands": _newly_unlocked_commands.duplicate(),
        "recently_recovered_fragments": _recently_recovered_fragments.duplicate(),
        "unlocked_axes": _camp_data.unlocked_axes.duplicate(),
        "pending_notifications": _camp_data.get_notification_count(),
        "has_new_records": _camp_data.has_pending_notifications(),
        "memory_entries": _camp_data.pending_memory_entries.duplicate(),
        "evidence_entries": _camp_data.pending_evidence_entries.duplicate(),
        "letter_entries": _camp_data.pending_letter_entries.duplicate(),
        "reward_entries": _camp_data.pending_reward_entries.duplicate(),
        "material_entries": _camp_data.material_entries.duplicate(true),
        "forge_recipe_entries": _camp_data.forge_recipe_entries.duplicate(true),
        "recall_hunt_entries": _camp_data.recall_hunt_entries.duplicate(true),
        "selected_hunt_id": _camp_data.selected_hunt_id,
        "last_hunt_result": _camp_data.last_hunt_result.duplicate(true)
    }

func get_camp_data() -> CampData:
    return _camp_data

func set_save_service(service: SaveService) -> void:
    _save_service = service

func get_save_service() -> SaveService:
    return _save_service

func get_event_log() -> Array[Dictionary]:
    return _event_log.duplicate()

func open_forge_tab() -> void:
    _enter_forge_state()

func open_recall_tab() -> void:
    _enter_recall_state()

func select_hunt(hunt_id: StringName) -> bool:
    if _camp_data == null or _hunt_board == null or not _hunt_board.is_unlocked(hunt_id):
        return false
    _camp_data.selected_hunt_id = hunt_id
    _camp_data.active_axis = AXIS_RECALL
    return true

func get_selected_hunt_stage_id() -> StringName:
    if _camp_data == null or _hunt_board == null or _camp_data.selected_hunt_id == &"":
        return &""
    var hunt = _hunt_board.get_hunt_data(_camp_data.selected_hunt_id)
    return hunt.stage_id if hunt != null else &""

func get_selected_hunt_stage() -> StageData:
    return HuntStageRegistry.get_stage(get_selected_hunt_stage_id())

func _build_narrative_axis_entries(progression: ProgressionData) -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    var axis_specs: Array[Dictionary] = [
        {"axis_id": &"memory", "label": "기억"},
        {"axis_id": &"sacrifice", "label": "희생"},
        {"axis_id": &"truth", "label": "진실"},
        {"axis_id": &"trust", "label": "신뢰"},
    ]
    for spec in axis_specs:
        var axis_id: StringName = spec.get("axis_id", &"")
        var value: int = _resolve_narrative_axis_value(progression, axis_id)
        entries.append({
            "axis_id": axis_id,
            "label": String(spec.get("label", String(axis_id))),
            "value": value,
            "band": _get_narrative_axis_band(value)
        })
    return entries

func _resolve_narrative_axis_value(progression: ProgressionData, axis_id: StringName) -> int:
    if progression == null:
        return 0
    if progression.narrative_axis_values.has(String(axis_id)):
        return clampi(int(progression.narrative_axis_values.get(String(axis_id), 0)), 0, 9)
    if progression.narrative_axis_values.has(axis_id):
        return clampi(int(progression.narrative_axis_values.get(axis_id, 0)), 0, 9)
    match axis_id:
        &"memory":
            return clampi(progression.recovered_fragments.size(), 0, 9)
        &"sacrifice":
            return clampi(progression.burden, 0, 9)
        &"truth":
            return clampi(progression.recovered_fragments.size(), 0, 9)
        &"trust":
            return clampi(progression.trust, 0, 9)
        _:
            return 0

func _get_narrative_axis_band(value: int) -> String:
    if value >= 8:
        return "peak"
    if value >= 6:
        return "strong"
    if value >= 3:
        return "rising"
    return "faint"

func launch_selected_hunt_battle(battle_controller: BattleController) -> bool:
    if battle_controller == null:
        return false
    var stage: StageData = get_selected_hunt_stage()
    if stage == null:
        return false
    battle_controller.set_stage(stage)
    return battle_controller.stage_data != null and battle_controller.stage_data.stage_id == stage.stage_id

func resolve_hunt_victory(hunt_id: StringName, progression: ProgressionData, battle_result: Dictionary = {}) -> Dictionary:
    if _hunt_board == null:
        _hunt_board = HuntBoard.new()
        add_child(_hunt_board)
    _hunt_board.set_progression_data(progression)
    var hunt = _hunt_board.get_hunt_data(hunt_id)
    if hunt == null:
        return {}

    var result: Dictionary = {
        "memory_entries": [],
        "evidence_entries": [],
        "letter_entries": [],
        "reward_entries": [],
        "hunt_id": hunt.hunt_id,
        "hunt_display_name": hunt.display_name,
        "hunt_description": hunt.description,
        "hunt_stage_id": hunt.stage_id,
        "hunt_difficulty": hunt.difficulty,
        "hunt_recommended_level": hunt.recommended_level,
        "return_cutscene_override": "",
        "branch_card": {}
    }

    var completed_objectives: Array[String] = []
    for entry in battle_result.get("optional_objectives_completed", []):
        completed_objectives.append(String(entry))
    var battle_flags: Dictionary = Dictionary(battle_result.get("battle_temp_flags", {}))

    var reward_fragment: String = String(hunt.reward_memory_fragment).strip_edges()
    if not reward_fragment.is_empty() and progression != null:
        var fragment_id: StringName = StringName(reward_fragment)
        if not progression.recovered_fragments.has(fragment_id):
            progression.recovered_fragments[fragment_id] = true
        result["memory_entries"] = ["회상 파편 복원: %s" % reward_fragment]

    var evidence_entries: Array[String] = []
    for evidence_variant in hunt.reward_evidence:
        var evidence_id: String = String(evidence_variant).strip_edges()
        if evidence_id.is_empty():
            continue
        if progression != null:
            progression.flags[evidence_id] = true
        evidence_entries.append(evidence_id)
    result["evidence_entries"] = evidence_entries

    var reward_entries: Array[String] = []
    for reward_variant in hunt.reward_materials:
        if typeof(reward_variant) != TYPE_DICTIONARY:
            continue
        var reward_entry: Dictionary = reward_variant
        var material_id: StringName = StringName(reward_entry.get("material_id", &""))
        var count: int = max(0, int(reward_entry.get("count", 0)))
        if material_id == &"" or count <= 0:
            continue
        if progression != null:
            progression.add_material(material_id, count)
        reward_entries.append("재료 보상 %s x%d" % [ForgeService.get_material_label(material_id), count])

    if progression != null:
        progression.flags["flag_%s_cleared" % String(hunt.hunt_id)] = true

    if int(hunt.reward_gold) > 0:
        if progression != null:
            progression.add_gold(int(hunt.reward_gold))
        reward_entries.append("금화 보상 +%dG" % int(hunt.reward_gold))

    result["reward_entries"] = reward_entries
    _apply_hunt_result_branching(hunt.hunt_id, completed_objectives, battle_flags, progression, result)

    result["return_summary"] = "%s 귀환 완료 / 난이도 %d / 권장 레벨 %d" % [
        hunt.display_name,
        hunt.difficulty,
        hunt.recommended_level
    ]

    var branch_summary: String = String(result.get("branch_summary", "")).strip_edges()
    if not branch_summary.is_empty():
        result["return_summary"] += " / %s" % branch_summary

    return result

func _apply_hunt_result_branching(hunt_id: StringName, completed_objectives: Array[String], battle_flags: Dictionary, progression: ProgressionData, result: Dictionary) -> void:
    var reward_entries: Array[String] = []
    for entry in result.get("reward_entries", []):
        reward_entries.append(String(entry))
    var letter_entries: Array[String] = []
    for entry in result.get("letter_entries", []):
        letter_entries.append(String(entry))
    match String(hunt_id):
        "hunt_basil":
            if completed_objectives.has("hunt_basil_flood_rise_survived"):
                if progression != null:
                    progression.add_material(&"mat_basil_reliquary_ash", 1)
                reward_entries.append("완전 제어 보너스 재료 +1")
                result["branch_summary"] = "침수선 유지 성공"
                result["branch_card"] = {
                    "eyebrow": "회상 분기",
                    "title": "침수선 유지",
                    "body": "바실 회상전에서 침수선이 끝내 전열을 밀어내지 못했다. 제단 중심을 붙든 덕분에 추가 재료가 회수되었다.",
                    "memory_stamp": "HUNT_BASIL / Optional Objective"
                }
            if bool(battle_flags.get("hunt_basil_sluice_open", false)):
                result["return_cutscene_override"] = "수문 고리가 끝내 잠기고, 침수선은 더 이상 회상 전장을 밀어내지 못한다."
                result["return_control_stamp"] = "Sluice Wheel / Controlled"
        "hunt_saria":
            if completed_objectives.has("hunt_saria_queue_preserved"):
                letter_entries.append("기도 행렬 보존 기록: 마지막 줄은 끝내 무너지지 않았다.")
                result["branch_summary"] = "기도 행렬 보존 성공"
                result["branch_card"] = {
                    "eyebrow": "회상 분기",
                    "title": "기도 행렬 보존",
                    "body": "사리아 회상전에서 마지막 줄이 끝내 무너지지 않았다. 질서가 남은 만큼 귀환 기록도 더 또렷해졌다.",
                    "memory_stamp": "HUNT_SARIA / Optional Objective"
                }
            if bool(battle_flags.get("hunt_saria_choir_lectern", false)):
                reward_entries.append("성가대 정렬 보너스 +150G")
                if progression != null:
                    progression.add_gold(150)
                result["return_cutscene_override"] = "성가대 독본이 다시 닫히고, 남은 이름들은 더 이상 줄 속에서 흔들리지 않는다."
                result["return_control_stamp"] = "Choir Lectern / Controlled"
        "hunt_lete":
            if completed_objectives.has("hunt_lete_black_hounds_preserved"):
                reward_entries.append("흑견 보존 보너스 +200G")
                if progression != null:
                    progression.add_gold(200)
                result["branch_summary"] = "흑견 추격대 보존 성공"
                result["branch_card"] = {
                    "eyebrow": "회상 분기",
                    "title": "흑견 추격대 보존",
                    "body": "레테 회상전에서 추격대가 끝내 무너지지 않았다. 마당을 통제한 덕분에 귀환 정산도 더 크게 남는다.",
                    "memory_stamp": "HUNT_LETE / Optional Objective"
                }
            if bool(battle_flags.get("hunt_lete_gate_latch", false)):
                result["return_cutscene_override"] = "이송문 걸쇠가 끝내 풀리고, 흑견 마당은 더 이상 누구의 발자국도 재촉하지 못한다."
                result["return_control_stamp"] = "Gate Latch / Controlled"
    result["reward_entries"] = reward_entries
    result["letter_entries"] = letter_entries

# --- Private ---

func _compute_unlocked_axes(chapter: StringName) -> Array[StringName]:
    var axes: Array[StringName] = []
    for axis: StringName in BASE_AXES:
        axes.append(axis)
    if chapter in STORAGE_UNLOCK_CHAPTERS:
        axes.append(AXIS_STORAGE)
        axes.append(AXIS_DISMANTLE)
    if chapter in FORGE_UNLOCK_CHAPTERS:
        axes.append(AXIS_FORGE)
    if chapter in RECALL_UNLOCK_CHAPTERS:
        axes.append(AXIS_RECALL)
    return axes

func _enter_default_state() -> void:
    if _camp_data == null:
        return
    _camp_data.current_mode = MODE_CAMP
    _camp_data.active_axis = AXIS_SORTIE

func _enter_forge_state() -> void:
    if _camp_data == null:
        return
    _camp_data.current_mode = MODE_CAMP
    _camp_data.active_axis = AXIS_FORGE if _camp_data.unlocked_axes.has(AXIS_FORGE) else AXIS_SORTIE

func _enter_recall_state() -> void:
    if _camp_data == null:
        return
    _camp_data.current_mode = MODE_CAMP
    _camp_data.active_axis = AXIS_RECALL if _camp_data.unlocked_axes.has(AXIS_RECALL) else AXIS_SORTIE

func _refresh_forge_snapshot(progression: ProgressionData) -> void:
    _camp_data.material_entries.clear()
    _camp_data.forge_recipe_entries.clear()
    if progression == null:
        return
    _camp_data.material_entries = ForgeService.get_material_entries(progression)
    _camp_data.forge_recipe_entries = ForgeService.build_recipe_entries(progression, [])

func _refresh_recall_snapshot() -> void:
    _camp_data.recall_hunt_entries.clear()
    _camp_data.selected_hunt_id = &""
    if _hunt_board == null:
        return
    var first_unlocked: StringName = &""
    for hunt in _hunt_board.get_all_hunts():
        var unlocked: bool = _hunt_board.is_unlocked(hunt.hunt_id)
        if unlocked and first_unlocked == &"":
            first_unlocked = hunt.hunt_id
        _camp_data.recall_hunt_entries.append({
            "hunt_id": hunt.hunt_id,
            "display_name": hunt.display_name,
            "description": hunt.description,
            "difficulty": hunt.difficulty,
            "recommended_level": hunt.recommended_level,
            "reward_memory_fragment": hunt.reward_memory_fragment,
            "reward_evidence": hunt.reward_evidence.duplicate(),
            "reward_gold": hunt.reward_gold,
            "stage_id": hunt.stage_id,
            "unlocked": unlocked
        })
    _camp_data.selected_hunt_id = first_unlocked

func _build_pending_notifications(result: Dictionary) -> void:
    _camp_data.pending_memory_entries.clear()
    _camp_data.pending_evidence_entries.clear()
    _camp_data.pending_letter_entries.clear()
    _camp_data.pending_reward_entries.clear()

    var memories: Array = result.get("memory_entries", [])
    for item in memories:
        _camp_data.pending_memory_entries.append(String(item))

    var evidence: Array = result.get("evidence_entries", [])
    for item in evidence:
        _camp_data.pending_evidence_entries.append(String(item))

    var letters: Array = result.get("letter_entries", [])
    for item in letters:
        _camp_data.pending_letter_entries.append(String(item))

    var rewards: Array = result.get("reward_entries", [])
    for item in rewards:
        _camp_data.pending_reward_entries.append(String(item))
