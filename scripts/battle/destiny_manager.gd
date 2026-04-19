class_name DestinyManager
extends Node

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const CampaignShellDialogueCatalog = preload("res://scripts/campaign/campaign_shell_dialogue_catalog.gd")

const HISTORY_CHANGER_BADGE_ID := "history_changer"
const DESTINY_DECISION_HISTORY_KEY := "destiny_decision_history"
const DESTINY_REWRITTEN_CHOICE_KEYS_KEY := "destiny_rewritten_choice_keys"
const REWRITABLE_CHOICE_POINTS: Array[Dictionary] = [
	{"chapter_id": "CH05", "choice_key": "ch05_camp"},
	{"chapter_id": "CH07", "choice_key": "ch07_interlude"},
	{"chapter_id": "CH08", "choice_key": "ch08_pre_boss"},
	{"chapter_id": "CH09A", "choice_key": "ch09a_camp"},
	{"chapter_id": "CH10", "choice_key": "ch10_pre_finale"},
]
const THIRD_EYE_FLAG_KEYS: Array = [
	"third_eye",
	"third_eye_complete",
	"third_eye_completion",
	"third_eye_unlocked",
]
const DESTINY_METADATA_KEYS: Array[String] = [
	HISTORY_CHANGER_BADGE_ID,
	DESTINY_DECISION_HISTORY_KEY,
	DESTINY_REWRITTEN_CHOICE_KEYS_KEY,
]

signal decisions_changed

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
		current_world = _duplicate_world_state_dictionary(progression.world_state_bits)
		if past_world.is_empty():
			past_world = _duplicate_world_state_dictionary(progression.world_state_bits)
		_restore_history_from_progression(progression)
	else:
		_hydrate_from_progression()
	emit_signal("decisions_changed")

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
	_sync_progression_from_world(normalized_chapter_id, normalized_choice_key, choice_value, progression, false)
	_persist_progression(progression)
	emit_signal("decisions_changed")
	return true

func get_past_decisions() -> Array:
	return _duplicate_records(_past_decisions)

func request_change(chapter_id: String, choice_key: String, new_value: Variant) -> bool:
	return change_past_decision(chapter_id, choice_key, new_value)

func sync_choice_state(chapter_id: String, choice_key: String, choice_value: Variant) -> bool:
	var normalized_chapter_id := chapter_id.strip_edges().to_upper()
	var normalized_choice_key := choice_key.strip_edges()
	if normalized_chapter_id.is_empty() or normalized_choice_key.is_empty():
		return false
	var progression: ProgressionData = _resolve_progression_data()
	_apply_choice_to_world(normalized_chapter_id, normalized_choice_key, choice_value)
	_sync_progression_from_world(normalized_chapter_id, normalized_choice_key, choice_value, progression, false)
	_persist_progression(progression)
	emit_signal("decisions_changed")
	return true

func get_chronicle_rewrite_entries(chapter_filters: Array = []) -> Array[Dictionary]:
	var progression: ProgressionData = _resolve_progression_data()
	if progression == null:
		return []
	var normalized_filters := _normalize_chapter_filters(chapter_filters)
	var entries: Array[Dictionary] = []
	for choice_point in REWRITABLE_CHOICE_POINTS:
		var chapter_id := String(choice_point.get("chapter_id", "")).strip_edges().to_upper()
		var choice_key := String(choice_point.get("choice_key", "")).strip_edges()
		if chapter_id.is_empty() or choice_key.is_empty():
			continue
		if not normalized_filters.is_empty() and not normalized_filters.has(chapter_id):
			continue
		var choice_data: Dictionary = CampaignShellDialogueCatalog.get_choice_dialogue(StringName(choice_key))
		if choice_data.is_empty():
			continue
		var current_value := _get_current_choice_selection(progression, choice_key)
		if String(current_value).strip_edges().is_empty():
			continue
		var options := _build_rewrite_options(choice_data, current_value)
		if options.is_empty():
			continue
		entries.append({
			"chapter_id": chapter_id,
			"choice_key": choice_key,
			"title": String(choice_data.get("title", chapter_id)).strip_edges(),
			"prompt": String(choice_data.get("prompt", "")).strip_edges(),
			"current_value": current_value,
			"current_label": _resolve_option_label(options, current_value),
			"options": options,
		})
	return entries

func get_rewritten_choice_keys() -> Array[String]:
	var progression: ProgressionData = _resolve_progression_data()
	return _get_rewritten_choice_keys_from_progression(progression)

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
	if progression != null and is_destiny_unlocked():
		progression.earn_badge(HISTORY_CHANGER_BADGE_ID, 1)
	past_world[normalized_choice_key] = _clone_variant(previous_value)
	_append_decision_record(normalized_chapter_id, normalized_choice_key, previous_value, new_value)
	_apply_choice_to_world(normalized_chapter_id, normalized_choice_key, new_value)
	resync_world_with_past_change(normalized_chapter_id, normalized_choice_key, new_value)
	emit_signal("decisions_changed")
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
	_apply_choice_to_progression(progression, normalized_chapter_id, normalized_choice_key, new_value, true)
	_sync_related_systems(progression, normalized_chapter_id)
	_persist_progression(progression)

func is_history_changer() -> bool:
	if _history_changed:
		return true
	var progression: ProgressionData = _resolve_progression_data()
	if progression == null:
		return false
	return bool(progression.world_state_bits.get(HISTORY_CHANGER_BADGE_ID, false))

func get_destiny_universe_state() -> Dictionary:
	return {
		"current_world": current_world.duplicate(true),
		"past_world": past_world.duplicate(true),
		"past_decisions": get_past_decisions(),
		"change_count": get_rewritten_choice_keys().size(),
		"history_changer": is_history_changer(),
		"destiny_unlocked": is_destiny_unlocked(),
	}

func _hydrate_from_progression() -> void:
	var progression: ProgressionData = _resolve_progression_data()
	if progression == null:
		return
	current_world = _duplicate_world_state_dictionary(progression.world_state_bits)
	if past_world.is_empty():
		past_world = _duplicate_world_state_dictionary(progression.world_state_bits)
	_restore_history_from_progression(progression)

func _resolve_progression_data() -> ProgressionData:
	if _progression_data != null:
		return _progression_data
	if not is_inside_tree():
		return null
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

func _apply_choice_to_progression(progression, chapter_id: String, choice_key: String, choice_value: Variant, mark_as_rewritten: bool) -> void:
	progression.world_state_bits[choice_key] = _clone_variant(choice_value)
	var chapter_number := _extract_chapter_number(chapter_id)
	if chapter_number > 0:
		progression.world_state_chapters[choice_key] = chapter_number
	_apply_campaign_choice_effects(progression, choice_key, choice_value)
	_upsert_choice_record(progression, chapter_id, choice_key, choice_value)
	if mark_as_rewritten:
		_mark_choice_as_rewritten(progression, choice_key)
	progression.world_state_bits[HISTORY_CHANGER_BADGE_ID] = _history_changed
	progression.world_state_bits[DESTINY_DECISION_HISTORY_KEY] = _duplicate_records(_past_decisions)

func _sync_progression_from_world(chapter_id: String, choice_key: String, choice_value: Variant, progression, mark_as_rewritten: bool) -> void:
	if progression == null:
		return
	_apply_choice_to_progression(progression, chapter_id, choice_key, choice_value, mark_as_rewritten)

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
	if not is_inside_tree():
		return
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

func _upsert_choice_record(progression: ProgressionData, chapter_id: String, choice_key: String, choice_value: Variant) -> void:
	if progression == null:
		return
	var target_prefix := "%s:" % choice_key
	for index in range(progression.choices_made.size() - 1, -1, -1):
		var existing_record := String(progression.choices_made[index]).strip_edges()
		if existing_record.begins_with(target_prefix):
			progression.choices_made.remove_at(index)
	var choice_value_text := String(choice_value).strip_edges()
	if _is_rewritable_choice_point(choice_key) and not choice_value_text.is_empty():
		progression.choices_made.append("%s:%s" % [choice_key, choice_value_text])
		return
	var choice_record := _build_choice_record(chapter_id, choice_key)
	if not progression.choices_made.has(choice_record):
		progression.choices_made.append(choice_record)

func _get_latest_choice_value(choice_key: String) -> Variant:
	for index in range(_past_decisions.size() - 1, -1, -1):
		var record: Dictionary = _past_decisions[index]
		if String(record.get("choice_key", "")).strip_edges() != choice_key:
			continue
		return record.get("new_value", null)
	return past_world.get(choice_key, null)

func _normalize_chapter_filters(chapter_filters: Array) -> Array[String]:
	var normalized: Array[String] = []
	for filter_value in chapter_filters:
		var chapter_id := String(filter_value).strip_edges().to_upper()
		if chapter_id.is_empty() or normalized.has(chapter_id):
			continue
		normalized.append(chapter_id)
	return normalized

func _build_rewrite_options(choice_data: Dictionary, current_value: String) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	for raw_option in choice_data.get("options", []):
		if typeof(raw_option) != TYPE_DICTIONARY:
			continue
		var option := (raw_option as Dictionary).duplicate(true)
		var option_id := String(option.get("id", "")).strip_edges()
		if option_id == "ch10_record_the_chosen" and not is_destiny_unlocked():
			continue
		option["selected"] = option_id == current_value
		options.append(option)
	return options

func _resolve_option_label(options: Array[Dictionary], current_value: String) -> String:
	for option in options:
		if String(option.get("id", "")).strip_edges() == current_value:
			return String(option.get("label", current_value)).strip_edges()
	return current_value

func _get_current_choice_selection(progression: ProgressionData, choice_key: String) -> String:
	if progression == null:
		return ""
	var current_value := String(progression.world_state_bits.get(choice_key, "")).strip_edges()
	if not current_value.is_empty():
		return current_value
	var prefix := "%s:" % choice_key
	for index in range(progression.choices_made.size() - 1, -1, -1):
		var record := String(progression.choices_made[index]).strip_edges()
		if not record.begins_with(prefix):
			continue
		return record.trim_prefix(prefix)
	return ""

func _apply_campaign_choice_effects(progression: ProgressionData, choice_key: String, choice_value: Variant) -> void:
	if progression == null:
		return
	var normalized_choice_key := choice_key.strip_edges()
	var option_id := String(choice_value).strip_edges()
	match normalized_choice_key:
		"ch05_camp":
			if option_id == "ch05_save_ledgers":
				progression.enoch_wounded = true
				progression.ledger_count = 5
				progression.world_timeline_id = "A"
			else:
				progression.enoch_wounded = false
				progression.ledger_count = 2
				progression.world_timeline_id = "B"
		"ch07_interlude":
			if option_id == "ch07_believe_mira":
				progression.mira_trust_level = 2
				progression.neri_disposition = "hostile"
			else:
				progression.mira_trust_level = -1
				progression.neri_disposition = "neutral"
		"ch08_pre_boss":
			progression.lete_early_alliance = option_id == "ch08_accept_lete"
		"ch09a_camp":
			if option_id == "ch09a_public_testimony":
				progression.noah_phase2_multiplier = 2.0
				progression.melkion_awareness = true
			else:
				progression.noah_phase2_multiplier = 1.0
				progression.melkion_awareness = false
		"ch10_pre_finale":
			match option_id:
				"ch10_name_the_fallen":
					progression.ch10_attack_bonus = 1
					progression.ch10_defense_bonus = 0
				"ch10_name_the_principle":
					progression.ch10_attack_bonus = 0
					progression.ch10_defense_bonus = 1
				"ch10_record_the_chosen":
					progression.ch10_attack_bonus = 1
					progression.ch10_defense_bonus = 1
				_:
					pass
		_:
			pass

func _mark_choice_as_rewritten(progression: ProgressionData, choice_key: String) -> void:
	if progression == null:
		return
	var rewritten_keys := _get_rewritten_choice_keys_from_progression(progression)
	if not rewritten_keys.has(choice_key):
		rewritten_keys.append(choice_key)
		progression.world_state_bits[DESTINY_REWRITTEN_CHOICE_KEYS_KEY] = rewritten_keys.duplicate()

func _get_rewritten_choice_keys_from_progression(progression: ProgressionData) -> Array[String]:
	var keys: Array[String] = []
	if progression == null:
		return keys
	var raw_keys: Variant = progression.world_state_bits.get(DESTINY_REWRITTEN_CHOICE_KEYS_KEY, [])
	if typeof(raw_keys) != TYPE_ARRAY:
		return keys
	for raw_key in raw_keys:
		var choice_key := String(raw_key).strip_edges()
		if choice_key.is_empty() or keys.has(choice_key):
			continue
		keys.append(choice_key)
	return keys

func _restore_history_from_progression(progression: ProgressionData) -> void:
	if progression == null:
		return
	_past_decisions.clear()
	var raw_history: Variant = progression.world_state_bits.get(DESTINY_DECISION_HISTORY_KEY, [])
	if typeof(raw_history) == TYPE_ARRAY:
		for raw_entry in raw_history:
			if typeof(raw_entry) != TYPE_DICTIONARY:
				continue
			_past_decisions.append((raw_entry as Dictionary).duplicate(true))
	_history_changed = bool(progression.world_state_bits.get(HISTORY_CHANGER_BADGE_ID, false)) or not _get_rewritten_choice_keys_from_progression(progression).is_empty()

func _duplicate_world_state_dictionary(source: Dictionary) -> Dictionary:
	var copy: Dictionary = {}
	for key in source.keys():
		var key_text := String(key).strip_edges()
		if DESTINY_METADATA_KEYS.has(key_text):
			continue
		copy[key] = _clone_variant(source[key])
	return copy

func _is_rewritable_choice_point(choice_key: String) -> bool:
	for choice_point in REWRITABLE_CHOICE_POINTS:
		if String(choice_point.get("choice_key", "")).strip_edges() == choice_key:
			return true
	return false

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
