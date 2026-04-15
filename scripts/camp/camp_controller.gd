class_name CampController
extends Node

## 캠프 진입 흐름 오케스트레이터
## - enter_camp(): 전투 결과 → CampData 빌드 → 허브 준비
## - get_camp_summary(): 현재 캠프 상태 스냅샷 반환

const CampData = preload("res://scripts/data/camp_data.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

const AXIS_SORTIE: StringName = &"sortie"
const AXIS_EQUIPMENT: StringName = &"equipment"
const AXIS_RECORDS: StringName = &"records"
const AXIS_STORAGE: StringName = &"storage"
const AXIS_DISMANTLE: StringName = &"dismantle"
const AXIS_FORGE: StringName = &"forge"
const AXIS_RECALL: StringName = &"recall"

## 항상 해금: 편성 / 장비 / 기록
const BASE_AXES: Array[StringName] = [AXIS_SORTIE, AXIS_EQUIPMENT, AXIS_RECORDS]

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
var _event_log: Array[Dictionary] = []

func enter_camp(
    chapter: StringName,
    stage_clear_result: Dictionary,
    progression: ProgressionData = null
) -> CampData:
    _camp_data = CampData.new()
    _camp_data.current_chapter = chapter
    _camp_data.stage_clear_result = stage_clear_result
    _camp_data.burden = progression.burden if progression != null else 0
    _camp_data.trust = progression.trust if progression != null else 0
    _camp_data.ending_tendency = progression.ending_tendency if progression != null else &"undetermined"
    _camp_data.recovered_fragment_count = progression.recovered_fragments.size() if progression != null else 0
    _camp_data.unlocked_command_count = progression.unlocked_commands.size() if progression != null else 0
    _camp_data.recovered_fragment_ids = progression.get_recovered_fragment_ids() if progression != null else []
    _camp_data.unlocked_command_ids = progression.get_unlocked_command_ids() if progression != null else []
    _camp_data.unlocked_axes = _compute_unlocked_axes(chapter)
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
        "burden": _camp_data.burden,
        "trust": _camp_data.trust,
        "ending_tendency": _camp_data.ending_tendency,
        "recovered_fragments": _camp_data.recovered_fragment_count,
        "unlocked_commands": _camp_data.unlocked_command_count,
        "recovered_fragment_ids": _camp_data.recovered_fragment_ids.duplicate(),
        "unlocked_command_ids": _camp_data.unlocked_command_ids.duplicate(),
        "unlocked_axes": _camp_data.unlocked_axes.duplicate(),
        "pending_notifications": _camp_data.get_notification_count(),
        "has_new_records": _camp_data.has_pending_notifications(),
        "memory_entries": _camp_data.pending_memory_entries.duplicate(),
        "evidence_entries": _camp_data.pending_evidence_entries.duplicate(),
        "letter_entries": _camp_data.pending_letter_entries.duplicate()
    }

func get_camp_data() -> CampData:
    return _camp_data

func get_event_log() -> Array[Dictionary]:
    return _event_log.duplicate()

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

func _build_pending_notifications(result: Dictionary) -> void:
    _camp_data.pending_memory_entries.clear()
    _camp_data.pending_evidence_entries.clear()
    _camp_data.pending_letter_entries.clear()

    var memories: Array = result.get("memory_entries", [])
    for item in memories:
        _camp_data.pending_memory_entries.append(String(item))

    var evidence: Array = result.get("evidence_entries", [])
    for item in evidence:
        _camp_data.pending_evidence_entries.append(String(item))

    var letters: Array = result.get("letter_entries", [])
    for item in letters:
        _camp_data.pending_letter_entries.append(String(item))
