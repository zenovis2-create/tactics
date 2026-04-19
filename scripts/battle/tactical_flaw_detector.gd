class_name TacticalFlawDetector
extends Node

const CommanderProfile = preload("res://scripts/battle/commander_profile.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

const MAX_DECISION_HISTORY := 48
const ACTIVATION_SEVERITY := 0.6
const ENGRAVING_SEVERITY := 1.0
const WARNING_TEXT := "당신의 指官官 결함이 드러난다!"

signal profile_changed(profile: CommanderProfile)
signal flaw_warning_requested(message: String, flaw_type: int)
signal flaw_engraved(flaw_type: int, event_id: String)

var current_profile: CommanderProfile = CommanderProfile.new()
var decision_history: Array[Dictionary] = []

var _progression_data: ProgressionData
var _battle_triggered: bool = false
var _battle_engraving_triggered: bool = false

func _ready() -> void:
	_reset_battle_flags()
	_try_bind_progression_from_tree()
	_emit_profile_changed()

func begin_battle(progression_data: ProgressionData = null) -> void:
	if progression_data != null:
		bind_progression(progression_data)
	decision_history.clear()
	_reset_battle_flags()
	_emit_profile_changed()

func end_battle() -> void:
	decision_history.clear()
	_reset_battle_flags()

func bind_progression(progression_data: ProgressionData) -> void:
	_progression_data = progression_data
	if _progression_data == null:
		current_profile = CommanderProfile.new()
	else:
		current_profile = _progression_data.ensure_commander_profile()
	_emit_profile_changed()

func detect_flaw_pattern(latest_action: Dictionary, all_actions_this_chapter: Array = []) -> int:
	_push_decision(latest_action)
	var actions := _build_action_window(latest_action, all_actions_this_chapter)
	if _count_backline_streak(actions) >= 3:
		return CommanderProfile.FlawType.PERSISTENT_BACKLINE
	if _count_ignored_flank_attacks(actions) >= 3:
		return CommanderProfile.FlawType.IGNORED_FLANKS
	if _count_weather_ignore_turns(actions) >= 2:
		return CommanderProfile.FlawType.WEATHER_IGNORE
	if _count_unit_skip_turns(actions, latest_action) >= 5:
		return CommanderProfile.FlawType.UNIT_SKIP
	return CommanderProfile.FlawType.NONE

func apply_flaw_to_profile(detected_flaw: int) -> void:
	_ensure_profile()
	var previous_severity := current_profile.severity
	if detected_flaw == CommanderProfile.FlawType.NONE:
		_decay_current_flaw()
		_finalize_profile_update(previous_severity)
		return

	var repetition_seed: int = max(1, _count_repetitions_for_flaw(detected_flaw))
	if current_profile.flaw_type == CommanderProfile.FlawType.NONE:
		_seed_profile(detected_flaw, repetition_seed)
	elif current_profile.flaw_type == detected_flaw:
		var increment: int = max(1, repetition_seed - current_profile.repetition_count)
		current_profile.repetition_count += increment
		current_profile.severity = clampf(current_profile.severity + 0.2 * float(increment), 0.0, 1.0)
		current_profile.sync_description()
	else:
		current_profile.severity = maxf(0.0, current_profile.severity - 0.1)
		if current_profile.severity <= 0.0:
			_seed_profile(detected_flaw, repetition_seed)

	_finalize_profile_update(previous_severity)

func get_active_penalty() -> Dictionary:
	_ensure_profile()
	return current_profile.active_penalty.duplicate(true)

func has_active_flaw() -> bool:
	_ensure_profile()
	return current_profile.flaw_type != CommanderProfile.FlawType.NONE and current_profile.has_active_penalty()

func get_active_flaw_label() -> String:
	_ensure_profile()
	return CommanderProfile.get_flaw_name(current_profile.flaw_type)

func _try_bind_progression_from_tree() -> void:
	var progression_service := get_node_or_null("/root/ProgressionService")
	if progression_service != null and progression_service.has_method("get_data"):
		bind_progression(progression_service.get_data())
		return

func _reset_battle_flags() -> void:
	_battle_triggered = false
	_battle_engraving_triggered = false

func _ensure_profile() -> void:
	if current_profile != null:
		return
	if _progression_data != null:
		current_profile = _progression_data.ensure_commander_profile()
	else:
		current_profile = CommanderProfile.new()

func _push_decision(action: Dictionary) -> void:
	if action.is_empty():
		return
	decision_history.append(action.duplicate(true))
	if decision_history.size() > MAX_DECISION_HISTORY:
		decision_history.remove_at(0)

func _build_action_window(latest_action: Dictionary, all_actions_this_chapter: Array) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	for action_variant in all_actions_this_chapter:
		if action_variant is Dictionary:
			actions.append((action_variant as Dictionary).duplicate(true))
	if actions.is_empty():
		for action in decision_history:
			actions.append(action.duplicate(true))
	if not latest_action.is_empty() and (actions.is_empty() or actions[actions.size() - 1].hash() != latest_action.hash()):
		actions.append(latest_action.duplicate(true))
	return actions

func _seed_profile(flaw_type: int, repetition_seed: int) -> void:
	current_profile.flaw_type = flaw_type
	current_profile.repetition_count = repetition_seed
	current_profile.severity = clampf(float(repetition_seed) * 0.2, 0.0, 1.0)
	current_profile.sync_description()
	current_profile.clear_penalty()

func _decay_current_flaw() -> void:
	if current_profile.flaw_type == CommanderProfile.FlawType.NONE:
		return
	current_profile.severity = maxf(0.0, current_profile.severity - 0.1)
	if current_profile.severity <= 0.0:
		current_profile.reset()
		return
	current_profile.clear_penalty()
	current_profile.sync_description()

func _finalize_profile_update(previous_severity: float) -> void:
	if current_profile.flaw_type == CommanderProfile.FlawType.NONE or current_profile.severity < ACTIVATION_SEVERITY:
		current_profile.clear_penalty()
	else:
		current_profile.activate_penalty()
		if not _battle_triggered and previous_severity < ACTIVATION_SEVERITY:
			_battle_triggered = true
			flaw_warning_requested.emit(WARNING_TEXT, current_profile.flaw_type)
	if current_profile.severity >= ENGRAVING_SEVERITY and not _battle_engraving_triggered:
		_battle_engraving_triggered = true
		flaw_engraved.emit(current_profile.flaw_type, "결함 각인")
	_sync_progression_profile()
	_emit_profile_changed()

func _sync_progression_profile() -> void:
	if _progression_data == null:
		return
	_progression_data.commander_profile = current_profile

func _emit_profile_changed() -> void:
	_ensure_profile()
	profile_changed.emit(current_profile)

func _count_repetitions_for_flaw(flaw_type: int) -> int:
	match flaw_type:
		CommanderProfile.FlawType.PERSISTENT_BACKLINE:
			return _count_backline_streak(decision_history)
		CommanderProfile.FlawType.IGNORED_FLANKS:
			return _count_ignored_flank_attacks(decision_history)
		CommanderProfile.FlawType.WEATHER_IGNORE:
			return _count_weather_ignore_turns(decision_history)
		CommanderProfile.FlawType.UNIT_SKIP:
			if decision_history.is_empty():
				return 0
			return _count_unit_skip_turns(decision_history, decision_history[decision_history.size() - 1])
		_:
			return 0

func _count_backline_streak(actions: Array[Dictionary]) -> int:
	var streak := 0
	for index in range(actions.size() - 1, -1, -1):
		var action := actions[index]
		if _is_backline_move(action):
			streak += 1
		else:
			break
	return streak

func _count_ignored_flank_attacks(actions: Array[Dictionary]) -> int:
	var streak := 0
	for index in range(actions.size() - 1, -1, -1):
		var action := actions[index]
		if not _is_attack_action(action):
			continue
		if bool(action.get("used_flanking_bonus", false)):
			break
		streak += 1
	return streak

func _count_weather_ignore_turns(actions: Array[Dictionary]) -> int:
	var turn_ids: Array[int] = []
	var turn_summaries: Dictionary = {}
	for action in actions:
		var turn_id := int(action.get("turn_index", action.get("turn", -1)))
		if turn_id < 0:
			continue
		if not turn_summaries.has(turn_id):
			turn_ids.append(turn_id)
			turn_summaries[turn_id] = {
				"weather_active": false,
				"weather_synergy_used": false
			}
		var summary: Dictionary = (turn_summaries[turn_id] as Dictionary).duplicate(true)
		summary["weather_active"] = bool(summary.get("weather_active", false)) or bool(action.get("weather_active", false))
		summary["weather_synergy_used"] = bool(summary.get("weather_synergy_used", false)) or bool(action.get("weather_synergy_action", false)) or bool(action.get("weather_synergy_used", false))
		turn_summaries[turn_id] = summary
	turn_ids.sort()
	var streak := 0
	for index in range(turn_ids.size() - 1, -1, -1):
		var summary: Dictionary = turn_summaries.get(turn_ids[index], {})
		if bool(summary.get("weather_active", false)) and not bool(summary.get("weather_synergy_used", false)):
			streak += 1
		else:
			break
	return streak

func _count_unit_skip_turns(actions: Array[Dictionary], latest_action: Dictionary) -> int:
	var unit_id := String(latest_action.get("unit_id", "")).strip_edges()
	if unit_id.is_empty():
		return 0
	var target_position = latest_action.get("position", null)
	if target_position == null:
		return 0
	var streak := 0
	for index in range(actions.size() - 1, -1, -1):
		var action := actions[index]
		if String(action.get("unit_id", "")).strip_edges() != unit_id:
			continue
		if not action.has("position") or action.get("position") != target_position:
			break
		if bool(action.get("acted", true)):
			break
		streak += 1
	return streak

func _is_backline_move(action: Dictionary) -> bool:
	var action_type := String(action.get("action_type", action.get("type", ""))).strip_edges().to_lower()
	if action_type not in ["move", "reposition"]:
		return false
	if bool(action.get("backline_only", false)):
		return true
	return String(action.get("lane", "")).strip_edges().to_lower() == "backline"

func _is_attack_action(action: Dictionary) -> bool:
	var action_type := String(action.get("action_type", action.get("type", ""))).strip_edges().to_lower()
	return action_type in ["attack", "combat", "strike"]
