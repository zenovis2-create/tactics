class_name SpotlightManager
extends Node

signal spotlight_triggered(spotlight_type: StringName, unit_ids: Array)

const TRIPLE_KILL: StringName = &"TRIPLE_KILL"
const LAST_STAND: StringName = &"LAST_STAND"
const WEATHER_MASTER: StringName = &"WEATHER_MASTER"
const SACRIFICE_PLAY: StringName = &"SACRIFICE_PLAY"

const _DEFAULT_BATTLE_ID: StringName = &"default_battle"

var _active_battle_id: StringName = _DEFAULT_BATTLE_ID
var _battle_state: Dictionary = {}

func begin_battle(battle_id: StringName) -> void:
	_active_battle_id = battle_id if battle_id != &"" else _DEFAULT_BATTLE_ID
	reset_battle(_active_battle_id)

func get_active_battle_id() -> StringName:
	return _active_battle_id

func reset_battle(battle_id: StringName = &"") -> void:
	var resolved_battle_id: StringName = battle_id if battle_id != &"" else _active_battle_id
	if resolved_battle_id == &"":
		resolved_battle_id = _DEFAULT_BATTLE_ID
	_battle_state[resolved_battle_id] = {
		"triggered": {},
		"history": []
	}

func reset_all() -> void:
	_battle_state.clear()
	_active_battle_id = _DEFAULT_BATTLE_ID

func was_triggered(spotlight_type: StringName, battle_id: StringName = &"") -> bool:
	var state: Dictionary = _ensure_battle_state(battle_id if battle_id != &"" else _active_battle_id)
	var triggered: Dictionary = state.get("triggered", {})
	return bool(triggered.get(spotlight_type, false))

func check_spotlight_conditions(turn_actions: Array) -> Array[Dictionary]:
	var battle_id: StringName = _active_battle_id if _active_battle_id != &"" else _DEFAULT_BATTLE_ID
	var triggers: Array[Dictionary] = []

	if not was_triggered(TRIPLE_KILL, battle_id) and _count_total_kills(turn_actions) >= 3:
		triggers.append(_register_trigger(battle_id, TRIPLE_KILL, _collect_kill_actor_ids(turn_actions)))

	if not was_triggered(LAST_STAND, battle_id):
		for action_variant in turn_actions:
			var action: Dictionary = action_variant
			if _extract_killed_unit_ids(action).is_empty():
				continue
			var actor_max_hp: float = float(action.get("actor_max_hp", action.get("max_hp", 0)))
			if actor_max_hp <= 0.0:
				continue
			var actor_hp_before: float = float(action.get("actor_hp_before", action.get("hp_before", 0)))
			if (actor_hp_before / actor_max_hp) <= 0.05:
				triggers.append(_register_trigger(battle_id, LAST_STAND, _collect_actor_and_targets(action)))
				break

	if not was_triggered(WEATHER_MASTER, battle_id):
		var weather_effects: Dictionary = {}
		var weather_units: Dictionary = {}
		for action_variant in turn_actions:
			var action: Dictionary = action_variant
			for effect_id in _extract_weather_effect_ids(action):
				weather_effects[effect_id] = true
			for unit_id in _extract_weather_unit_ids(action):
				weather_units[unit_id] = true
		if weather_effects.size() >= 3:
			triggers.append(_register_trigger(battle_id, WEATHER_MASTER, _dictionary_keys_to_string_name_array(weather_units)))

	if not was_triggered(SACRIFICE_PLAY, battle_id):
		for action_variant in turn_actions:
			var action: Dictionary = action_variant
			if not _is_sacrifice_action(action):
				continue
			triggers.append(_register_trigger(battle_id, SACRIFICE_PLAY, _collect_actor_and_targets(action)))
			break

	return triggers

func get_effect_payload(spotlight_type: StringName, unit_ids: Array[StringName]) -> Dictionary:
	match spotlight_type:
		TRIPLE_KILL:
			return {
				"reason": "spotlight_triple_kill",
				"headline": "Carnage",
				"slow_mo_duration": 5.0,
				"slow_mo_scale": 0.35,
				"flash_color": Color(0.88, 0.12, 0.16, 0.24),
				"flash_duration": 0.35,
				"bgm_cue": "bgm_battle_boss",
				"sfx_cue": "battle_hit_confirm_01",
				"unit_ids": unit_ids.duplicate()
			}
		LAST_STAND:
			return {
				"reason": "spotlight_last_stand",
				"headline": "Stubborn Heart",
				"flash_color": Color(0.95, 0.42, 0.14, 0.22),
				"flash_duration": 0.42,
				"portrait_unit_id": unit_ids[0] if not unit_ids.is_empty() else &"",
				"sfx_cue": "battle_counter_hit_01",
				"unit_ids": unit_ids.duplicate()
			}
		WEATHER_MASTER:
			return {
				"reason": "spotlight_weather_master",
				"headline": "Harmony with Nature",
				"flash_color": Color(0.27, 0.72, 0.48, 0.18),
				"flash_duration": 0.28,
				"particle_fx": "nature_particle_burst",
				"sfx_cue": "camp_recommend_focus_01",
				"unit_ids": unit_ids.duplicate()
			}
		SACRIFICE_PLAY:
			return {
				"reason": "spotlight_sacrifice_play",
				"headline": "Last Words",
				"slow_mo_duration": 10.0,
				"slow_mo_scale": 0.25,
				"flash_color": Color(0.58, 0.58, 0.62, 0.24),
				"flash_duration": 0.5,
				"desaturate": true,
				"last_words": _build_last_words(unit_ids),
				"sfx_cue": "battle_boss_command_warn_01",
				"unit_ids": unit_ids.duplicate()
			}
		_:
			return {
				"reason": "spotlight_unknown",
				"headline": String(spotlight_type),
				"unit_ids": unit_ids.duplicate()
			}

func apply_spotlight_effects(battle_controller: Node, spotlight_type: StringName, unit_ids: Array[StringName]) -> Dictionary:
	var payload: Dictionary = get_effect_payload(spotlight_type, unit_ids)
	if battle_controller == null:
		return payload

	battle_controller.set("last_spotlight_effect", payload.duplicate(true))

	var flash_color: Color = payload.get("flash_color", Color(1.0, 1.0, 1.0, 0.0))
	var flash_duration: float = float(payload.get("flash_duration", 0.0))
	if flash_duration > 0.0 and battle_controller.has_method("_play_battle_flash"):
		battle_controller.call("_play_battle_flash", flash_color, flash_duration)

	var slow_mo_duration: float = float(payload.get("slow_mo_duration", 0.0))
	if slow_mo_duration > 0.0 and battle_controller.has_method("_queue_spotlight_slow_mo"):
		battle_controller.call("_queue_spotlight_slow_mo", slow_mo_duration, float(payload.get("slow_mo_scale", 0.35)))

	var hud: Node = battle_controller.get("hud")
	if hud != null and is_instance_valid(hud):
		hud.call("set_transition_reason", String(payload.get("reason", "")), payload)
		var sfx_cue := String(payload.get("sfx_cue", ""))
		if not sfx_cue.is_empty() and hud.has_signal("ui_cue_requested"):
			hud.ui_cue_requested.emit(sfx_cue)

	var bgm_cue := String(payload.get("bgm_cue", ""))
	if not bgm_cue.is_empty():
		var bgm_router: Node = _resolve_bgm_router(battle_controller)
		if bgm_router != null and is_instance_valid(bgm_router) and bgm_router.has_method("play_cue"):
			bgm_router.call("play_cue", bgm_cue, true)

	return payload

func _register_trigger(battle_id: StringName, spotlight_type: StringName, raw_unit_ids: Array[StringName]) -> Dictionary:
	var state: Dictionary = _ensure_battle_state(battle_id)
	var triggered: Dictionary = state.get("triggered", {})
	triggered[spotlight_type] = true
	state["triggered"] = triggered
	var unit_ids: Array[StringName] = _unique_string_name_array(raw_unit_ids)
	var entry := {
		"spotlight_type": spotlight_type,
		"unit_ids": unit_ids.duplicate(),
		"battle_id": battle_id
	}
	var history: Array = state.get("history", [])
	history.append(entry)
	state["history"] = history
	_battle_state[battle_id] = state
	spotlight_triggered.emit(spotlight_type, unit_ids)
	return entry

func _ensure_battle_state(battle_id: StringName) -> Dictionary:
	var resolved_battle_id: StringName = battle_id if battle_id != &"" else _DEFAULT_BATTLE_ID
	if not _battle_state.has(resolved_battle_id):
		reset_battle(resolved_battle_id)
	return _battle_state.get(resolved_battle_id, {})

func _count_total_kills(turn_actions: Array) -> int:
	var total: int = 0
	for action_variant in turn_actions:
		var action: Dictionary = action_variant
		total += _extract_killed_unit_ids(action).size()
	return total

func _collect_kill_actor_ids(turn_actions: Array) -> Array[StringName]:
	var unit_ids: Array[StringName] = []
	for action_variant in turn_actions:
		var action: Dictionary = action_variant
		if _extract_killed_unit_ids(action).is_empty():
			continue
		var actor_id: StringName = _extract_actor_id(action)
		if actor_id != &"":
			unit_ids.append(actor_id)
	return _unique_string_name_array(unit_ids)

func _collect_actor_and_targets(action: Dictionary) -> Array[StringName]:
	var unit_ids: Array[StringName] = []
	var actor_id: StringName = _extract_actor_id(action)
	if actor_id != &"":
		unit_ids.append(actor_id)
	unit_ids.append_array(_extract_killed_unit_ids(action))
	unit_ids.append_array(_extract_unit_ids(action.get("saved_unit_id", action.get("protected_unit_id", []))))
	return _unique_string_name_array(unit_ids)

func _extract_actor_id(action: Dictionary) -> StringName:
	var candidates: Array[StringName] = [
		StringName(action.get("actor_id", &"")),
		StringName(action.get("unit_id", &"")),
		StringName(action.get("source_unit_id", &"")),
		StringName(action.get("sacrificed_unit_id", &""))
	]
	for candidate in candidates:
		if candidate != &"":
			return candidate
	return &""

func _extract_killed_unit_ids(action: Dictionary) -> Array[StringName]:
	var unit_ids: Array[StringName] = _extract_unit_ids(action.get("killed_unit_ids", []))
	if unit_ids.is_empty() and bool(action.get("defender_defeated", false)):
		var defender_id: StringName = StringName(action.get("target_id", action.get("defender_id", &"")))
		if defender_id != &"":
			unit_ids.append(defender_id)
	return _unique_string_name_array(unit_ids)

func _extract_weather_effect_ids(action: Dictionary) -> Array[StringName]:
	if String(action.get("type", "")) != "weather":
		return []
	var result: Array[StringName] = _extract_unit_ids(action.get("weather_effect_ids", []))
	var single_effect: StringName = StringName(action.get("weather_effect_id", action.get("effect_id", &"")))
	if single_effect != &"":
		result.append(single_effect)
	return _unique_string_name_array(result)

func _extract_weather_unit_ids(action: Dictionary) -> Array[StringName]:
	var unit_ids: Array[StringName] = []
	var actor_id: StringName = _extract_actor_id(action)
	if actor_id != &"":
		unit_ids.append(actor_id)
	unit_ids.append_array(_extract_unit_ids(action.get("affected_unit_ids", [])))
	return _unique_string_name_array(unit_ids)

func _is_sacrifice_action(action: Dictionary) -> bool:
	if String(action.get("type", "")) != "sacrifice_play":
		return false
	if not bool(action.get("actor_died", false)):
		return false
	return not _extract_unit_ids(action.get("saved_unit_id", action.get("protected_unit_id", []))).is_empty()

func _extract_unit_ids(value: Variant) -> Array[StringName]:
	var result: Array[StringName] = []
	if value is Array:
		for entry in value:
			var unit_id: StringName = StringName(entry)
			if unit_id != &"":
				result.append(unit_id)
	else:
		var unit_id_single: StringName = StringName(value)
		if unit_id_single != &"":
			result.append(unit_id_single)
	return result

func _unique_string_name_array(values: Array[StringName]) -> Array[StringName]:
	var seen: Dictionary = {}
	var result: Array[StringName] = []
	for value in values:
		if value == &"" or seen.has(value):
			continue
		seen[value] = true
		result.append(value)
	return result

func _dictionary_keys_to_string_name_array(values: Dictionary) -> Array[StringName]:
	var result: Array[StringName] = []
	for key_variant in values.keys():
		var key: StringName = StringName(key_variant)
		if key != &"":
			result.append(key)
	return _unique_string_name_array(result)

func _build_last_words(unit_ids: Array[StringName]) -> String:
	var speaker: String = String(unit_ids[0]) if not unit_ids.is_empty() else "Fallen Ally"
	return "%s: Hold the line. I can buy you this one chance." % speaker

func _resolve_bgm_router(battle_controller: Node) -> Node:
	if battle_controller == null or battle_controller.get_tree() == null:
		return null
	var current_scene: Node = battle_controller.get_tree().current_scene
	if current_scene != null:
		var scene_router: Variant = current_scene.get("bgm_router")
		if scene_router != null:
			return scene_router
	var main := battle_controller.get_tree().root.get_node_or_null("Main")
	if main != null:
		var main_router: Variant = main.get("bgm_router")
		if main_router != null:
			return main_router
	return null
