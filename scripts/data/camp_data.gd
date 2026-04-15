class_name CampData
extends Resource

## 캠프 상태 리소스 — CampController가 생성, CampaignPanel이 소비
## 직렬화 가능 (save_service 연동 용이)

@export var current_chapter: StringName = &""
@export var burden: int = 0
@export var trust: int = 0
@export var ending_tendency: StringName = &"undetermined"
@export var recovered_fragment_count: int = 0
@export var unlocked_command_count: int = 0
@export var recovered_fragment_ids: Array[String] = []
@export var unlocked_command_ids: Array[String] = []

## 해금된 허브 축 (sortie/equipment/records/storage/dismantle/forge/recall)
@export var unlocked_axes: Array[StringName] = []

## 이번 캠프에서 새로 나타난 항목들
@export var pending_memory_entries: Array[String] = []
@export var pending_evidence_entries: Array[String] = []
@export var pending_letter_entries: Array[String] = []

## 직전 전투 결과 원본 (전달용)
@export var stage_clear_result: Dictionary = {}

func has_pending_notifications() -> bool:
    return (
        not pending_memory_entries.is_empty()
        or not pending_evidence_entries.is_empty()
        or not pending_letter_entries.is_empty()
    )

func get_notification_count() -> int:
    return (
        pending_memory_entries.size()
        + pending_evidence_entries.size()
        + pending_letter_entries.size()
    )

func to_debug_dict() -> Dictionary:
    return {
        "chapter": current_chapter,
        "burden": burden,
        "trust": trust,
        "ending_tendency": ending_tendency,
        "recovered_fragments": recovered_fragment_count,
        "unlocked_commands": unlocked_command_count,
        "recovered_fragment_ids": recovered_fragment_ids.duplicate(),
        "unlocked_command_ids": unlocked_command_ids.duplicate(),
        "unlocked_axes": unlocked_axes,
        "pending_memory": pending_memory_entries.size(),
        "pending_evidence": pending_evidence_entries.size(),
        "pending_letters": pending_letter_entries.size(),
        "has_notifications": has_pending_notifications()
    }
