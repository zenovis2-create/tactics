class_name EnemyPerspectiveManager
extends Node

const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

const MIRROR_CHAPTER_ID := "CH07"
const MIRROR_STAGE_ID: StringName = &"CH07_05"
const LEONIKA_UNIT_ID: StringName = &"enemy_saria"
const LEONIKA_NAME := "Leonika"

var mirror_mode_active: bool = false
var mirror_battles_won: int = 0
var last_perspective: StringName = &"player"
var last_mirror_stage_id: StringName = &""
var perspective_history: Array[Dictionary] = []
var last_perspective_decisions: Array[Dictionary] = []

func is_mirror_chapter(chapter_id: String) -> bool:
    return chapter_id.strip_edges().to_upper() == MIRROR_CHAPTER_ID

func enter_mirror_mode() -> void:
    mirror_mode_active = true
    last_perspective = &"enemy"
    last_perspective_decisions.clear()
    perspective_history.append({
        "mode": String(last_perspective),
        "title": get_mirror_chapter_title()
    })

func exit_mirror_mode() -> void:
    mirror_mode_active = false
    last_perspective = &"player"
    last_mirror_stage_id = &""
    last_perspective_decisions.clear()

func get_mirror_chapter_title() -> String:
    return "적의 눈으로 보기"

func prepare_stage_for_mirror_mode(stage_data: StageData) -> bool:
    if not mirror_mode_active or stage_data == null or stage_data.stage_id != MIRROR_STAGE_ID:
        return false

    var original_title := stage_data.get_display_title()
    var original_ally_units := stage_data.ally_units.duplicate()
    var original_enemy_units := stage_data.enemy_units.duplicate()
    var original_ally_spawns := stage_data.ally_spawns.duplicate()
    var original_enemy_spawns := stage_data.enemy_spawns.duplicate()

    stage_data.ally_units = _duplicate_units_for_faction(original_enemy_units, "ally")
    stage_data.enemy_units = _duplicate_units_for_faction(original_ally_units, "enemy")
    stage_data.ally_spawns = original_enemy_spawns.duplicate()
    stage_data.enemy_spawns = original_ally_spawns.duplicate()
    stage_data.stage_title = "%s — %s" % [get_mirror_chapter_title(), original_title]

    last_mirror_stage_id = stage_data.stage_id
    perspective_history.append({
        "mode": String(last_perspective),
        "stage_id": String(stage_data.stage_id),
        "title": stage_data.stage_title
    })
    return true

func record_mirror_victory(stage_id: StringName) -> void:
    if stage_id != MIRROR_STAGE_ID:
        return
    mirror_battles_won += 1
    last_mirror_stage_id = stage_id
    perspective_history.append({
        "mode": String(last_perspective),
        "stage_id": String(stage_id),
        "result": "victory",
        "wins": mirror_battles_won
    })

func record_perspective_decisions(decisions: Array[Dictionary]) -> void:
    last_perspective_decisions = decisions.duplicate(true)

func _duplicate_units_for_faction(unit_defs: Array, faction: String) -> Array[UnitData]:
    var duplicated_units: Array[UnitData] = []
    for unit_variant in unit_defs:
        var unit_data := unit_variant as UnitData
        if unit_data == null:
            continue
        duplicated_units.append(_duplicate_unit_for_faction(unit_data, faction))
    return duplicated_units

func _duplicate_unit_for_faction(unit_data: UnitData, faction: String) -> UnitData:
    var duplicated_variant: Variant = unit_data.duplicate(true)
    var duplicated := duplicated_variant as UnitData
    if duplicated == null:
        duplicated = unit_data
    duplicated.faction = faction
    if duplicated.unit_id == LEONIKA_UNIT_ID:
        duplicated.display_name = LEONIKA_NAME
    return duplicated
