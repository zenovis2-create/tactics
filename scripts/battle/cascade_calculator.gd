extends Node

class CascadeEffect:
	extends RefCounted

	var decision_key: String = ""
	var target_system: String = ""
	var modifier: Dictionary = {}
	var delay_chapters: int = 0
	var trigger_chapter: int = 0
	var applied: bool = false

	static func from_dict(data: Dictionary) -> CascadeEffect:
		var effect := CascadeEffect.new()
		effect.decision_key = String(data.get("decision_key", "")).strip_edges()
		effect.target_system = String(data.get("target_system", "")).strip_edges()
		effect.modifier = (data.get("modifier", {}) as Dictionary).duplicate(true)
		effect.delay_chapters = int(data.get("delay_chapters", 0))
		effect.trigger_chapter = int(data.get("trigger_chapter", 0))
		effect.applied = bool(data.get("applied", false))
		return effect

	func to_dict() -> Dictionary:
		return {
			"decision_key": decision_key,
			"target_system": target_system,
			"modifier": modifier.duplicate(true),
			"delay_chapters": delay_chapters,
			"trigger_chapter": trigger_chapter,
			"applied": applied
		}

const CASCADE_CHAINS := {
	"spared_leonika": [
		{"target_system": "enemy_faction_strength", "modifier": {"enemy_faction_strength": -20}, "delay_chapters": 3},
		{"target_system": "city_population", "modifier": {"city_population": 100}, "delay_chapters": 5}
	],
	"burned_bridge": [
		{"target_system": "battle_terrain_flood_level", "modifier": {"battle_terrain_flood_level": 1}, "delay_chapters": 2},
		{"target_system": "reinforcements_available", "modifier": {"reinforcements_available": -1}, "delay_chapters": 4}
	],
	"saved_supply_train": [
		{"target_system": "ally_unit_hp_bonus", "modifier": {"ally_unit_hp_bonus": 10}, "delay_chapters": 2},
		{"target_system": "enemy_morale", "modifier": {"enemy_morale": -15}, "delay_chapters": 3}
	],
	"ignored_warning": [
		{"target_system": "boss_attack_multiplier", "modifier": {"boss_attack_multiplier": 0.1}, "delay_chapters": 1},
		{"target_system": "ally_trust", "modifier": {"ally_trust": -1}, "delay_chapters": 3}
	]
}

var progression_service: Node = null
var _last_applied_effects: Array[Dictionary] = []

func _ready() -> void:
	connect_decision_point(get_node_or_null("/root/DecisionPoint"))

func bind_progression_service(service: Node) -> void:
	progression_service = service

func connect_decision_point(decision_point: Node) -> void:
	if decision_point == null or not decision_point.has_signal("decision_made"):
		return
	var callback := Callable(self, "_on_decision_made")
	if not decision_point.is_connected("decision_made", callback):
		decision_point.connect("decision_made", callback)

func calculate_future_effects(decision_key: String, chapter_ahead: int) -> Array[CascadeEffect]:
	var effects: Array[CascadeEffect] = []
	var progression_data = _get_progression_data()
	var normalized_key := decision_key.strip_edges()
	if progression_data == null or normalized_key.is_empty() or not _is_decision_active(progression_data, normalized_key):
		return effects
	for entry_variant in CASCADE_CHAINS.get(normalized_key, []):
		var entry := entry_variant as Dictionary
		if entry.is_empty():
			continue
		var delay := int(entry.get("delay_chapters", 0))
		if delay > max(0, chapter_ahead):
			continue
		var effect := CascadeEffect.new()
		effect.decision_key = normalized_key
		effect.target_system = String(entry.get("target_system", "")).strip_edges()
		effect.modifier = (entry.get("modifier", {}) as Dictionary).duplicate(true)
		effect.delay_chapters = delay
		effect.trigger_chapter = int(progression_data.world_state_chapters.get(normalized_key, 0))
		effects.append(effect)
	return effects

func apply_pending_cascades(current_chapter: int) -> void:
	var progression_data = _get_progression_data()
	if progression_data == null:
		return
	_ensure_registered_cascades(progression_data)
	_last_applied_effects.clear()
	for index in range(progression_data.cascade_effects.size()):
		var effect_data := progression_data.cascade_effects[index] as Dictionary
		if effect_data.is_empty() or bool(effect_data.get("applied", false)):
			continue
		if not _is_effect_ready(effect_data, current_chapter):
			continue
		_apply_modifier(progression_data, effect_data)
		effect_data["applied"] = true
		progression_data.cascade_effects[index] = effect_data
		_last_applied_effects.append(effect_data.duplicate(true))

func get_active_modifiers() -> Dictionary:
	var progression_data = _get_progression_data()
	if progression_data == null:
		return {}
	return progression_data.active_battle_condition_modifiers.duplicate(true)

func get_last_applied_effects() -> Array[Dictionary]:
	return _last_applied_effects.duplicate(true)

func _on_decision_made(chapter_id: String, choice_key: String, choice_value: Variant) -> void:
	if not _is_supported_value(choice_value):
		return
	if not _is_truthy(choice_value):
		return
	_register_decision(choice_key, _extract_chapter_number(chapter_id))

func _register_decision(decision_key: String, trigger_chapter: int) -> void:
	var progression_data = _get_progression_data()
	var normalized_key := decision_key.strip_edges()
	if progression_data == null or normalized_key.is_empty() or not CASCADE_CHAINS.has(normalized_key):
		return
	if not _has_registered_effects_for_decision(progression_data, normalized_key):
		_append_cascade_effects(progression_data, normalized_key, trigger_chapter)
		return
	if trigger_chapter <= 0:
		return
	for index in range(progression_data.cascade_effects.size()):
		var effect_data := progression_data.cascade_effects[index] as Dictionary
		if String(effect_data.get("decision_key", "")).strip_edges() != normalized_key:
			continue
		if int(effect_data.get("trigger_chapter", 0)) > 0:
			continue
		effect_data["trigger_chapter"] = trigger_chapter
		progression_data.cascade_effects[index] = effect_data

func _ensure_registered_cascades(progression_data) -> void:
	for decision_key_variant in progression_data.world_state_bits.keys():
		var decision_key := String(decision_key_variant).strip_edges()
		if decision_key.is_empty() or not CASCADE_CHAINS.has(decision_key):
			continue
		if not _is_decision_active(progression_data, decision_key):
			continue
		if _has_registered_effects_for_decision(progression_data, decision_key):
			continue
		_append_cascade_effects(progression_data, decision_key, int(progression_data.world_state_chapters.get(decision_key, 0)))

func _append_cascade_effects(progression_data, decision_key: String, trigger_chapter: int) -> void:
	for entry_variant in CASCADE_CHAINS.get(decision_key, []):
		var entry := entry_variant as Dictionary
		if entry.is_empty():
			continue
		var effect := CascadeEffect.new()
		effect.decision_key = decision_key
		effect.target_system = String(entry.get("target_system", "")).strip_edges()
		effect.modifier = (entry.get("modifier", {}) as Dictionary).duplicate(true)
		effect.delay_chapters = int(entry.get("delay_chapters", 0))
		effect.trigger_chapter = trigger_chapter
		progression_data.cascade_effects.append(effect.to_dict())

func _has_registered_effects_for_decision(progression_data, decision_key: String) -> bool:
	for effect_variant in progression_data.cascade_effects:
		var effect_data := effect_variant as Dictionary
		if String(effect_data.get("decision_key", "")).strip_edges() == decision_key:
			return true
	return false

func _is_effect_ready(effect_data: Dictionary, current_chapter: int) -> bool:
	var delay := int(effect_data.get("delay_chapters", 0))
	var trigger_chapter := int(effect_data.get("trigger_chapter", 0))
	if trigger_chapter > 0:
		return current_chapter >= trigger_chapter + delay
	return current_chapter >= delay

func _apply_modifier(progression_data, effect_data: Dictionary) -> void:
	var modifier := (effect_data.get("modifier", {}) as Dictionary).duplicate(true)
	for modifier_key_variant in modifier.keys():
		var modifier_key := String(modifier_key_variant).strip_edges()
		if modifier_key.is_empty():
			continue
		var current_value: Variant = progression_data.active_battle_condition_modifiers.get(modifier_key, 0)
		var incoming_value: Variant = modifier[modifier_key_variant]
		if (typeof(current_value) == TYPE_INT or typeof(current_value) == TYPE_FLOAT) and (typeof(incoming_value) == TYPE_INT or typeof(incoming_value) == TYPE_FLOAT):
			progression_data.active_battle_condition_modifiers[modifier_key] = current_value + incoming_value
		else:
			progression_data.active_battle_condition_modifiers[modifier_key] = incoming_value

func _is_decision_active(progression_data, decision_key: String) -> bool:
	var world_state_value: Variant = progression_data.world_state_bits.get(decision_key, null)
	if world_state_value != null and _is_truthy(world_state_value):
		return true
	for choice_record_variant in progression_data.choices_made:
		var choice_record := String(choice_record_variant)
		if choice_record == decision_key or choice_record.contains(decision_key):
			return true
	return false

func _is_truthy(value: Variant) -> bool:
	match typeof(value):
		TYPE_BOOL:
			return bool(value)
		TYPE_INT:
			return int(value) != 0
		TYPE_STRING:
			return not String(value).strip_edges().is_empty()
		_:
			return false

func _is_supported_value(value: Variant) -> bool:
	var value_type := typeof(value)
	return value_type == TYPE_BOOL or value_type == TYPE_INT or value_type == TYPE_STRING

func _get_progression_data():
	if progression_service == null:
		progression_service = _resolve_progression_service()
	if progression_service == null or not progression_service.has_method("get_data"):
		return null
	return progression_service.get_data()

func _resolve_progression_service() -> Node:
	var battle_controller = get_node_or_null("/root/Main/BattleScene")
	if battle_controller != null:
		var service = battle_controller.get("progression_service")
		if service != null:
			return service
	for child in get_tree().root.get_children():
		var nested_battle = child.find_child("BattleScene", true, false)
		if nested_battle == null:
			continue
		var service = nested_battle.get("progression_service")
		if service != null:
			return service
	return null

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
