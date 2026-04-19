class_name DestinyManager
extends Node

const ProgressionData = preload("res://scripts/data/progression_data.gd")

const HISTORY_CHANGER_BADGE_ID := "history_changer"
const THIRD_EYE_FLAG_KEYS: Array = [
	"third_eye",
	"third_eye_complete",
	"third_eye_completion",
	"third_eye_unlocked",
]

var current_world: Dictionary = {}
var past_world: Dictionary = {}

var _past_decisions: Array = []
var _history_changed: bool = false
var _progression_data: ProgressionData = null

func _ready() -> void:
	_hydrate_from_progression()

func is_destiny_unlocked() -> bool:
	var progression: ProgressionData = _resolve_progression_data()
	if progression == null:
		return false
	return _get_ng_plus_count(progression) >= 3 or _has_third_eye_completion(progression)

func refresh_from_progression(progression: ProgressionData = null) -> void:
	if progression != null:
		_progression_data = progression
		current_world = _duplicate_dictionary(progression.world_state_bits)
		if past_world.is_empty():
			past_world = _duplicate_dictionary(progression.world_state_bits)
	else:
		_hydrate_from_progression()

func record_decision(chapter_id: String, choice_key: String, choice_value: Variant) -> bool:
	var normalized_chapter_id := chapter_id.strip_edges().to_upper()
	var normalized_choice_key := choice_key.strip_edges()
	if normalized_choice_key.is_empty():
		return false

	var progression: ProgressionData = _resolve_progression_data()
	var old_value: Variant = current_world.get(normalized_choice_key, null)
	if old_value == null and progression != null:
		old_value = progression.world_state_bits.get(normalized_choice_key, null)

	_append_decision_record(normalized_chapter_id, normalized_choice_key, old_value, choice_value)
	_apply_choice_to_world(normalized_chapter_id, normalized_choice_key, choice_value)
	_sync_progression_from_world(normalized_chapter_id, normalized_choice_key, choice_value, progression)
	_persist_progression(progression)
	return true

func get_past_decisions() -> Array:
	return _duplicate_records(_past_decisions)

func change_past_decision(chapter_id: String, choice_key: String, new_value: Variant) -> bool:
	var normalized_chapter_id := chapter_id.strip_edges().to_upper()
	var normalized_choice_key := choice_key.strip_edges()
	if normalized_choice_key.is_empty():
		return false

	var progression: ProgressionData = _resolve_progression_data()
	var previous_value: Variant = _get_latest_choice_value(normalized_choice_key)
	if previous_value == null and progression != null:
		previous_value = progression.world_state_bits.get(normalized_choice_key, null)

	_history_changed = true
	past_world[normalized_choice_key] = _clone_variant(previous_value)
	_append_decision_record(normalized_chapter_id, normalized_choice_key, previous_value, new_value)
	_apply_choice_to_world(normalized_chapter_id, normalized_choice_key, new_value)
	resync_world_with_past_change(normalized_chapter_id, normalized_choice_key, new_value)
	return true

func resync_world_with_past_change(chapter_id: String, choice_key: String, new_value: Variant) -> void:
	var normalized_chapter_id := chapter_id.strip_edges().to_upper()
	var normalized_choice_key := choice_key.strip_edges()
	if normalized_choice_key.is_empty():
		return

	var progression: ProgressionData = _resolve_progression_data()
	if progression == null:
		return

	_history_changed = true
	_apply_choice_to_progression(progression, normalized_chapter_id, normalized_choice_key, new_value)
	_sync_related_systems(progression, normalized_chapter_id)
	_persist_progression(progression)

func is_history_changer() -> bool:
	if _history_changed:
		return true
	var progression: ProgressionData = _resolve_progression_data()
	if progression == null:
		return false
	return bool(progression.world_state_bits.get(HISTORY_CHANGER_BADGE_ID, false)) or bool(past_world.get(HISTORY_CHANGER_BADGE_ID, false))

func get_destiny_universe_state() -> Dictionary:
	return {
		"current_world": current_world.duplicate(true),
		"past_world": past_world.duplicate(true),
		"past_decisions": get_past_decisions(),
		"history_changer": is_history_changer(),
		"destiny_unlocked": is_destiny_unlocked(),
	}

func _hydrate_from_progression() -> void:
	var progression: ProgressionData = _resolve_progression_data()
	if progression == null:
		return
	current_world = _duplicate_dictionary(progression.world_state_bits)
	if past_world.is_empty():
		past_world = _duplicate_dictionary(progression.world_state_bits)

func _resolve_progression_data() -> ProgressionData:
	if _progression_data != null:
		return _progression_data
	var save_service: Node = get_node_or_null("/root/SaveService")
	if save_service != null:
		var service_progression: Variant = save_service.get("progression_data")
		if service_progression is ProgressionData:
			return service_progression as ProgressionData
		if save_service.has_method("load_progression"):
			var loaded = save_service.load_progression(0)
			if loaded is ProgressionData:
				return loaded as ProgressionData

	var progression_service: Node = get_node_or_null("/root/ProgressionService")
	if progression_service != null and progression_service.has_method("get_data"):
		var resolved = progression_service.get_data()
		if resolved is ProgressionData:
			return resolved as ProgressionData
	return null

func _append_decision_record(chapter_id: String, choice_key: String, old_value: Variant, new_value: Variant) -> void:
	_past_decisions.append({
		"chapter_id": chapter_id,
		"choice_key": choice_key,
		"old_value": _clone_variant(old_value),
		"new_value": _clone_variant(new_value),
		"timestamp": int(Time.get_unix_time_from_system()),
	})

func _apply_choice_to_world(chapter_id: String, choice_key: String, choice_value: Variant) -> void:
	current_world[choice_key] = _clone_variant(choice_value)
	if not past_world.has(choice_key):
		past_world[choice_key] = _clone_variant(choice_value)

func _apply_choice_to_progression(progression, chapter_id: String, choice_key: String, choice_value: Variant) -> void:
	progression.world_state_bits[choice_key] = _clone_variant(choice_value)
	var chapter_number := _extract_chapter_number(chapter_id)
	if chapter_number > 0:
		progression.world_state_chapters[choice_key] = chapter_number
	var choice_record := _build_choice_record(chapter_id, choice_key)
	if not progression.choices_made.has(choice_record):
		progression.choices_made.append(choice_record)
	progression.world_state_bits[HISTORY_CHANGER_BADGE_ID] = _history_changed

func _sync_progression_from_world(chapter_id: String, choice_key: String, choice_value: Variant, progression) -> void:
	if progression == null:
		return
	_apply_choice_to_progression(progression, chapter_id, choice_key, choice_value)

func _sync_related_systems(progression, chapter_id: String) -> void:
	var ethics_tracker: Node = get_node_or_null("/root/Ethics")
	if ethics_tracker != null and ethics_tracker.has_method("bind_progression"):
		ethics_tracker.bind_progression(progression)

	var cascade_calculator: Node = get_node_or_null("/root/CascadeCalculator")
	if cascade_calculator != null and cascade_calculator.has_method("apply_pending_cascades"):
		var chapter_number := _extract_chapter_number(chapter_id)
		if chapter_number > 0:
			cascade_calculator.apply_pending_cascades(chapter_number)

func _persist_progression(progression) -> void:
	var save_service: Node = get_node_or_null("/root/SaveService")
	if save_service != null and save_service.has_method("save_progression") and progression != null:
		save_service.save_progression(progression, 0)

func _get_ng_plus_count(progression: ProgressionData) -> int:
	if progression == null:
		return 0
	return progression.ng_plus_purchases.size()

func _has_third_eye_completion(progression: ProgressionData) -> bool:
	if progression == null:
		return false
	for flag_key in THIRD_EYE_FLAG_KEYS:
		if progression.world_state_bits.has(flag_key):
			return true
		if progression.earned_badges.has(flag_key):
			return true
	if progression.earned_badges.has("Third Eye"):
		return true
	if progression.worldview_fragments.has("third_eye"):
		return true
	return false

func _build_choice_record(chapter_id: String, choice_key: String) -> String:
	return "%s:%s" % [chapter_id, choice_key]

func _get_latest_choice_value(choice_key: String) -> Variant:
	for index in range(_past_decisions.size() - 1, -1, -1):
		var record: Dictionary = _past_decisions[index]
		if String(record.get("choice_key", "")).strip_edges() != choice_key:
			continue
		return record.get("new_value", null)
	return past_world.get(choice_key, null)

func _extract_chapter_number(chapter_id: String) -> int:
	var normalized := chapter_id.strip_edges().to_upper()
	if not normalized.begins_with("CH"):
		return 0
	var digits := ""
	for index in range(2, normalized.length()):
		var character := normalized[index]
		if character >= "0" and character <= "9":
			digits += character
		else:
			break
	return int(digits) if not digits.is_empty() else 0

func _clone_variant(value: Variant) -> Variant:
	if typeof(value) == TYPE_DICTIONARY:
		return (value as Dictionary).duplicate(true)
	if typeof(value) == TYPE_ARRAY:
		return (value as Array).duplicate(true)
	return value

func _duplicate_dictionary(source: Dictionary) -> Dictionary:
	var copy: Dictionary = {}
	for key in source.keys():
		copy[key] = _clone_variant(source[key])
	return copy

func _duplicate_records(source: Array) -> Array:
	var copy: Array = []
	for entry in source:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		copy.append((entry as Dictionary).duplicate(true))
	return copy
