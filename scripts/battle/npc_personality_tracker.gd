extends Node

const DEFAULT_ATTITUDES := {
	"leonika": -10.0,
	"rian": 0.0,
	"noah": 5.0,
}
const PERMANENT_HOSTILITY_FLOOR := -20.0
const HOSTILE_SUFFIX := "_HOSTILE"
const NEUTRAL_SUFFIX := "_NEUTRAL"
const FRIENDLY_SUFFIX := "_FRIENDLY"
const NPC_ALIASES := {
	"leonika": "leonika",
	"saria": "leonika",
	"enemy_saria": "leonika",
	"rian": "rian",
	"ally_rian": "rian",
	"noah": "noah",
	"ally_noah": "noah",
	"melkion": "melkion",
	"enemy_melkion": "melkion",
	"ally_melkion_ally": "melkion",
}
const NPC_DISPLAY_NAMES := {
	"leonika": "Leonika",
	"rian": "Rian",
	"noah": "Noah",
	"melkion": "Melkion",
	"serin": "Serin",
	"bran": "Bran",
	"tia": "Tia",
	"enoch": "Enoch",
	"karl": "Karl",
	"lete": "Lete",
	"mira": "Mira",
}

var npc_attitudes: Dictionary = {}
var npc_personality_flags: Dictionary = {}
var pending_chronicle_reference: Dictionary = {}
var _progression_data = null

func _ready() -> void:
	if npc_attitudes.is_empty():
		_reset_defaults()
		_sync_to_progression()

func bind_progression(data) -> void:
	_progression_data = data
	if _progression_data == null:
		if npc_attitudes.is_empty():
			_reset_defaults()
		return

	var stored_attitudes: Dictionary = _progression_data.npc_attitudes.duplicate(true)
	if stored_attitudes.is_empty():
		_reset_defaults()
	else:
		npc_attitudes.clear()
		for raw_npc_id in stored_attitudes.keys():
			var normalized_npc_id := _normalize_npc_id(String(raw_npc_id))
			if normalized_npc_id.is_empty():
				continue
			npc_attitudes[normalized_npc_id] = clampf(float(stored_attitudes.get(raw_npc_id, 0.0)), -100.0, 100.0)
		_merge_default_attitudes()
	npc_personality_flags = _progression_data.npc_personality_flags.duplicate(true)
	pending_chronicle_reference = _progression_data.pending_chronicle_reference.duplicate(true)
	_sync_to_progression()

func reset(data = null) -> void:
	if data != null:
		_progression_data = data
	_reset_defaults()
	npc_personality_flags.clear()
	pending_chronicle_reference.clear()
	_sync_to_progression()

func get_attitude(npc_id: String) -> float:
	var normalized_npc_id := _normalize_npc_id(npc_id)
	if normalized_npc_id.is_empty():
		return 0.0
	if not npc_attitudes.has(normalized_npc_id):
		npc_attitudes[normalized_npc_id] = 0.0
		_sync_to_progression()
	return float(npc_attitudes.get(normalized_npc_id, 0.0))

func modify_attitude(npc_id: String, delta: float) -> float:
	var normalized_npc_id := _normalize_npc_id(npc_id)
	if normalized_npc_id.is_empty():
		return 0.0
	var adjusted := clampf(get_attitude(normalized_npc_id) + delta, -100.0, 100.0)
	if _has_permanent_hostility(normalized_npc_id):
		adjusted = minf(adjusted, PERMANENT_HOSTILITY_FLOOR)
	npc_attitudes[normalized_npc_id] = adjusted
	_sync_to_progression()
	return adjusted

func get_npc_dialogue_variant(npc_id: String, base_dialogue_key: String) -> String:
	var normalized_npc_id := _normalize_npc_id(npc_id)
	var normalized_key := base_dialogue_key.strip_edges()
	if normalized_key.is_empty():
		return ""
	if normalized_npc_id == "leonika" and normalized_key.to_lower() == "ch10_final":
		return _get_leonika_final_dialogue()

	var attitude := get_attitude(normalized_npc_id)
	if normalized_key.to_lower().begins_with("support_"):
		if attitude > 0.0:
			return "%s%s" % [normalized_key, FRIENDLY_SUFFIX]
		if attitude < 0.0:
			return "%s%s" % [normalized_key, HOSTILE_SUFFIX]
		return "%s%s" % [normalized_key, NEUTRAL_SUFFIX]

	if attitude > 30.0:
		return "%s%s" % [normalized_key, FRIENDLY_SUFFIX]
	if attitude < -30.0:
		return "%s%s" % [normalized_key, HOSTILE_SUFFIX]
	return "%s%s" % [normalized_key, NEUTRAL_SUFFIX]

func record_story_action(action_id: String, context: Dictionary = {}) -> void:
	match action_id.strip_edges().to_lower():
		"spare_enemy_in_battle":
			_modify_all_known_attitudes(3.0)
		"burn_bridge":
			_modify_all_known_attitudes(-5.0)
			modify_attitude("leonika", -15.0)
			npc_personality_flags["permanent_hostility:leonika"] = true
			_sync_to_progression()
		"recruit_hidden_unit":
			_apply_hidden_recruit_delta(context)
		"unit_dies_in_battle":
			apply_unit_death_reaction(
				_variant_to_string_array(context.get("nearby_npc_ids", [])),
				_variant_to_string_array(context.get("bonded_npc_ids", []))
			)
		_:
			return

func apply_unit_death_reaction(nearby_npc_ids: Array[String], bonded_npc_ids: Array[String]) -> void:
	var bonded_lookup: Dictionary = {}
	for raw_npc_id in bonded_npc_ids:
		var normalized_npc_id := _normalize_npc_id(raw_npc_id)
		if normalized_npc_id.is_empty() or bonded_lookup.has(normalized_npc_id):
			continue
		bonded_lookup[normalized_npc_id] = true
		modify_attitude(normalized_npc_id, -15.0)
	for raw_npc_id in nearby_npc_ids:
		var normalized_npc_id := _normalize_npc_id(raw_npc_id)
		if normalized_npc_id.is_empty() or bonded_lookup.has(normalized_npc_id):
			continue
		modify_attitude(normalized_npc_id, -8.0)

func queue_chronicle_reference(entry) -> void:
	if entry == null:
		return
	var style_name := _extract_style_name(entry)
	if style_name != "POETIC" and style_name != "BATTLE":
		return
	pending_chronicle_reference = {
		"chapter_id": String(entry.chapter_id).strip_edges(),
		"chapter_title": String(entry.chapter_title).strip_edges(),
		"narrative_text": String(entry.narrative_text).strip_edges(),
		"style": style_name,
	}
	_sync_to_progression()

func has_pending_chronicle_reference() -> bool:
	return not pending_chronicle_reference.is_empty()

func peek_pending_chronicle_reference() -> Dictionary:
	return pending_chronicle_reference.duplicate(true)

func consume_pending_chronicle_reference() -> Dictionary:
	var reference := pending_chronicle_reference.duplicate(true)
	pending_chronicle_reference.clear()
	_sync_to_progression()
	return reference

func get_display_name(npc_id: String) -> String:
	var normalized_npc_id := _normalize_npc_id(npc_id)
	if NPC_DISPLAY_NAMES.has(normalized_npc_id):
		return String(NPC_DISPLAY_NAMES.get(normalized_npc_id, normalized_npc_id.capitalize()))
	if normalized_npc_id.is_empty():
		return "NPC"
	return normalized_npc_id.capitalize()

func _apply_hidden_recruit_delta(context: Dictionary) -> void:
	var recruited_npc_id := _normalize_npc_id(String(context.get("recruited_npc_id", context.get("npc_id", ""))))
	for known_npc_id in _get_known_npc_ids():
		if known_npc_id == recruited_npc_id:
			continue
		var delta := 5.0
		if known_npc_id == "leonika" and recruited_npc_id == "melkion":
			delta = 15.0
		modify_attitude(known_npc_id, delta)
	if not recruited_npc_id.is_empty():
		modify_attitude(recruited_npc_id, 20.0)

func _modify_all_known_attitudes(delta: float) -> void:
	for npc_id in _get_known_npc_ids():
		modify_attitude(npc_id, delta)

func _get_known_npc_ids() -> Array[String]:
	var ids: Array[String] = []
	for default_id in DEFAULT_ATTITUDES.keys():
		ids.append(String(default_id))
	for npc_id in npc_attitudes.keys():
		var normalized_npc_id := String(npc_id)
		if ids.has(normalized_npc_id):
			continue
		ids.append(normalized_npc_id)
	return ids

func _normalize_npc_id(npc_id: String) -> String:
	var normalized := npc_id.strip_edges().to_lower()
	if normalized.is_empty():
		return ""
	normalized = normalized.replace("-", "_")
	return String(NPC_ALIASES.get(normalized, normalized))

func _has_permanent_hostility(npc_id: String) -> bool:
	return bool(npc_personality_flags.get("permanent_hostility:%s" % _normalize_npc_id(npc_id), false))

func _get_leonika_final_dialogue() -> String:
	var leonika_attitude := get_attitude("leonika")
	var effective_attitude := leonika_attitude - float(DEFAULT_ATTITUDES.get("leonika", -10.0))
	if effective_attitude > 20.0:
		return "당신은 진정한 지도자였다"
	if effective_attitude < -20.0:
		return "당신의 손에 피가 너무 많다"
	return "우리는 서로를 이해할 수 없었다"

func _extract_style_name(entry) -> String:
	if entry == null:
		return ""
	if entry is Dictionary:
		return String((entry as Dictionary).get("style", "")).strip_edges().to_upper()
	if entry.has_method("get_style_name"):
		return String(entry.get_style_name()).strip_edges().to_upper()
	return String(entry.style).strip_edges().to_upper()

func _variant_to_string_array(value: Variant) -> Array[String]:
	var values: Array[String] = []
	if typeof(value) != TYPE_ARRAY:
		return values
	for raw_value in value:
		var normalized := String(raw_value).strip_edges()
		if normalized.is_empty():
			continue
		values.append(normalized)
	return values

func _reset_defaults() -> void:
	npc_attitudes = DEFAULT_ATTITUDES.duplicate(true)

func _merge_default_attitudes() -> void:
	for npc_id in DEFAULT_ATTITUDES.keys():
		if npc_attitudes.has(npc_id):
			continue
		npc_attitudes[npc_id] = DEFAULT_ATTITUDES[npc_id]

func _sync_to_progression() -> void:
	if _progression_data == null:
		return
	_progression_data.npc_attitudes = npc_attitudes.duplicate(true)
	_progression_data.npc_personality_flags = npc_personality_flags.duplicate(true)
	_progression_data.pending_chronicle_reference = pending_chronicle_reference.duplicate(true)
