class_name ProgressionService
extends Node

## Campaign-level meta state owner for Burden, Trust, Memory Fragments,
## and Ending Tendency. All updates are event-driven and logged.
## SYS-013, SYS-014, SYS-015, SYS-016

const ProgressionData = preload("res://scripts/data/progression_data.gd")

# Thresholds for automatic ending tendency evaluation.
const TRUE_ENDING_TRUST_MIN := 7
const TRUE_ENDING_BURDEN_MAX := 6
const BAD_ENDING_BURDEN_MIN := 7

# Burden band effect table: band -> stat modifier dictionary applied to Rian.
# Effects are additive on top of base stats; hardcapped at ±30%.
const BURDEN_BAND_EFFECTS: Array[Dictionary] = [
	{},                                          # 0: no effect
	{},                                          # 1: no effect
	{"accuracy_mod": -2},                        # 2: minor accuracy penalty
	{"accuracy_mod": -3},                        # 3
	{"accuracy_mod": -5, "evasion_mod": -2},     # 4: moderate
	{"accuracy_mod": -5, "evasion_mod": -4},     # 5
	{"accuracy_mod": -8, "evasion_mod": -5},     # 6: heavy
	{"accuracy_mod": -10, "evasion_mod": -6},    # 7
	{"accuracy_mod": -12, "evasion_mod": -8, "damage_mod": -3},   # 8: severe
	{"accuracy_mod": -15, "evasion_mod": -10, "damage_mod": -5},  # 9: maximum
]

# Trust band effect table: band -> stat modifier dictionary applied to squad.
const TRUST_BAND_EFFECTS: Array[Dictionary] = [
	{},                                          # 0: no effect
	{},                                          # 1
	{"support_range_bonus": 1},                  # 2: support range +1
	{"support_range_bonus": 1},                  # 3
	{"support_range_bonus": 1, "support_damage_bonus": 2},  # 4
	{"support_range_bonus": 1, "support_damage_bonus": 3},  # 5
	{"support_range_bonus": 2, "support_damage_bonus": 4},  # 6
	{"support_range_bonus": 2, "support_damage_bonus": 5},  # 7: true-ending range begins
	{"support_range_bonus": 2, "support_damage_bonus": 6, "status_resist_bonus": 5},  # 8
	{"support_range_bonus": 3, "support_damage_bonus": 8, "status_resist_bonus": 10}, # 9: max
]

# Fragment -> command unlock table.
# Add entries as each chapter's fragment is designed.
const FRAGMENT_COMMAND_UNLOCKS: Dictionary = {
	&"ch01_fragment": &"tactical_shift",
	&"ch02_fragment": &"cover_advance",
	&"ch03_fragment": &"rally_cry",
	&"ch04_fragment": &"forced_march",
	&"ch05_fragment": &"precision_stance",
	&"ch06_fragment": &"intercept",
	&"ch07_fragment": &"name_anchor_partial",
	&"ch08_fragment": &"vanguard_break",
	&"ch09_fragment": &"memory_shield",
	&"ch10_fragment": &"name_anchor_full",
}

var _data: ProgressionData = ProgressionData.new()
var _log: Array[Dictionary] = []

# --- Public API ---

static func get_fragment_id_for_stage(stage_id: StringName) -> StringName:
	var stage_text := String(stage_id).to_lower()
	if stage_text.is_empty():
		return &""
	if stage_text.ends_with("_fragment"):
		return StringName(stage_text)

	var chapter_prefix := _extract_chapter_prefix(stage_text)
	if not chapter_prefix.is_empty():
		return StringName("%s_fragment" % chapter_prefix)

	return StringName("%s_fragment" % stage_text)

static func get_fragment_flash_cutscene_id_for_stage(stage_id: StringName) -> StringName:
	var fragment_id := get_fragment_id_for_stage(stage_id)
	if fragment_id == &"":
		return &""
	return StringName("%s_flash" % String(fragment_id))

static func get_clear_cutscene_id_for_stage(stage_id: StringName) -> StringName:
	var stage_text := String(stage_id).to_lower()
	var chapter_prefix := _extract_chapter_prefix(stage_text)
	if chapter_prefix.is_empty():
		return &""
	return StringName("%s_clear" % chapter_prefix)

func get_data() -> ProgressionData:
	return _data

func load_data(saved_data: ProgressionData) -> void:
	_data = saved_data
	_emit_log("loaded", {})

func apply_burden_delta(delta: int, reason: String) -> void:
	var before := _data.burden
	_data.burden = clampi(_data.burden + delta, 0, 9)
	_emit_log("burden_changed", {
		"before": before,
		"after": _data.burden,
		"delta": delta,
		"reason": reason
	})
	_evaluate_ending_tendency()

func apply_trust_delta(delta: int, reason: String) -> void:
	var before := _data.trust
	_data.trust = clampi(_data.trust + delta, 0, 9)
	_emit_log("trust_changed", {
		"before": before,
		"after": _data.trust,
		"delta": delta,
		"reason": reason
	})
	_evaluate_ending_tendency()

func recover_stage_fragment(stage_id: StringName) -> Dictionary:
	var fragment_id := get_fragment_id_for_stage(stage_id)
	if fragment_id == &"":
		return {"fragment_id": "", "already_known": true, "command_unlocked": null}
	return recover_fragment(fragment_id)

func recover_fragment(fragment_id: StringName) -> Dictionary:
	if _data.has_fragment(fragment_id):
		return {"fragment_id": String(fragment_id), "already_known": true, "command_unlocked": null}

	_data.recovered_fragments[fragment_id] = true
	_emit_log("fragment_recovered", {
		"fragment_id": String(fragment_id),
		"recovered_fragment_count": _data.recovered_fragments.size(),
		"recovered_fragment_ids": _data.get_recovered_fragment_ids()
	})

	var unlocked_command: StringName = FRAGMENT_COMMAND_UNLOCKS.get(fragment_id, &"")
	if unlocked_command != &"" and not _data.has_command(unlocked_command):
		_data.unlocked_commands[unlocked_command] = true
		_emit_log("command_unlocked", {
			"command_id": String(unlocked_command),
			"source_fragment": String(fragment_id),
			"unlocked_command_count": _data.unlocked_commands.size(),
			"unlocked_command_ids": _data.get_unlocked_command_ids()
		})

	_evaluate_ending_tendency()

	return {
		"fragment_id": String(fragment_id),
		"already_known": false,
		"command_unlocked": String(unlocked_command) if unlocked_command != &"" else null
	}

func get_burden_effect() -> Dictionary:
	var band := _data.get_burden_band()
	return BURDEN_BAND_EFFECTS[band].duplicate()

func get_trust_effect() -> Dictionary:
	var band := _data.get_trust_band()
	return TRUST_BAND_EFFECTS[band].duplicate()

func get_event_log() -> Array[Dictionary]:
	return _log.duplicate()

func get_unlockable_skills(all_skills: Array) -> Array:
	var unlockable: Array = []
	for skill in all_skills:
		if skill != null and skill.has_method("is_unlocked") and skill.is_unlocked(_data):
			unlockable.append(skill)
	return unlockable

func get_locked_skills(all_skills: Array) -> Array:
	var locked: Array = []
	for skill in all_skills:
		if skill != null and skill.has_method("is_unlocked") and not skill.is_unlocked(_data):
			locked.append(skill)
	return locked

# --- Internal ---

func _evaluate_ending_tendency() -> void:
	var prev: StringName = _data.ending_tendency
	var new_tendency: StringName

	if _data.trust >= TRUE_ENDING_TRUST_MIN and _data.burden <= TRUE_ENDING_BURDEN_MAX:
		new_tendency = &"true_ending"
	elif _data.burden >= BAD_ENDING_BURDEN_MIN:
		new_tendency = &"bad_ending"
	else:
		new_tendency = &"undetermined"

	if new_tendency != prev:
		_data.ending_tendency = new_tendency
		_emit_log("ending_tendency_changed", {
			"before": String(prev),
			"after": String(new_tendency),
			"burden": _data.burden,
			"trust": _data.trust
		})

func _emit_log(event: String, payload: Dictionary) -> void:
	var entry := {"event": event, "tick": Time.get_ticks_msec()}
	entry.merge(payload)
	_log.append(entry)
	print("[ProgressionService] ", event, " | ", payload)

static func _extract_chapter_prefix(stage_text: String) -> String:
	if not stage_text.begins_with("ch"):
		return ""

	var digits := ""
	for index in range(2, stage_text.length()):
		var char := stage_text[index]
		if char >= "0" and char <= "9":
			digits += char
		else:
			break

	if digits.is_empty():
		return ""
	if digits.length() == 1:
		digits = "0%s" % digits
	return "ch%s" % digits
