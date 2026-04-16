class_name ProgressionData
extends Resource

## Serializable campaign-level meta state.
## Owned by ProgressionService; persisted in save file.

# Burden: 0-9. Tracks moral cost of Rian's recovered truths.
# 0 = no weight, 9 = maximum accumulated burden.
@export var burden: int = 0

# Trust: 0-9. Tracks collective trust between Rian and his squad.
# 0 = minimal trust, 9 = full cohesion.
@export var trust: int = 0

# Fragment set: which memory fragments have been recovered.
# Keys are fragment IDs (StringName); value is always true.
@export var recovered_fragments: Dictionary = {}

# Ending tendency: updated automatically from burden/trust thresholds.
# Values: "true_ending", "bad_ending", "undetermined"
@export var ending_tendency: StringName = &"undetermined"

# Command unlock set: fragment-gated commands that are now available.
# Keys are command IDs (StringName); value is always true.
@export var unlocked_commands: Dictionary = {}

# Per-unit progression snapshot keyed by unit_id string.
# Value shape: {"level": int, "exp": int}
@export var unit_progression: Dictionary = {}

@export var previous_fragment_count: int = 0

@export var previous_command_count: int = 0

@export var previous_fragment_ids: Array[String] = []

@export var previous_command_ids: Array[String] = []

func has_fragment(fragment_id: StringName) -> bool:
	return recovered_fragments.has(fragment_id)

func has_command(command_id: StringName) -> bool:
	return unlocked_commands.has(command_id)

func get_recovered_fragment_ids() -> Array[String]:
	var ids: Array[String] = []
	for fragment_id in recovered_fragments.keys():
		ids.append(String(fragment_id))
	ids.sort()
	return ids

func get_unlocked_command_ids() -> Array[String]:
	var ids: Array[String] = []
	for command_id in unlocked_commands.keys():
		ids.append(String(command_id))
	ids.sort()
	return ids

func get_newly_unlocked_commands() -> Array[String]:
	var ids: Array[String] = get_unlocked_command_ids()
	var recent: Array[String] = []
	for command_id in ids:
		if not previous_command_ids.has(command_id):
			recent.append(command_id)
	return recent

func get_recently_recovered_fragments() -> Array[String]:
	var ids: Array[String] = get_recovered_fragment_ids()
	var recent: Array[String] = []
	for fragment_id in ids:
		if not previous_fragment_ids.has(fragment_id):
			recent.append(fragment_id)
	return recent

func snapshot_unlock_state() -> void:
	previous_fragment_count = recovered_fragments.size()
	previous_command_count = unlocked_commands.size()
	previous_fragment_ids = get_recovered_fragment_ids()
	previous_command_ids = get_unlocked_command_ids()

func get_unit_progress(unit_id: StringName) -> Dictionary:
	var key := String(unit_id)
	var value: Dictionary = unit_progression.get(key, {})
	return {
		"level": max(1, int(value.get("level", 1))),
		"exp": max(0, int(value.get("exp", 0)))
	}

func set_unit_progress(unit_id: StringName, level: int, exp: int) -> void:
	unit_progression[String(unit_id)] = {
		"level": max(1, level),
		"exp": max(0, exp)
	}

func get_unit_progress_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	var keys: Array[String] = []
	for unit_id in unit_progression.keys():
		keys.append(String(unit_id))
	keys.sort()
	for unit_id in keys:
		snapshot[unit_id] = get_unit_progress(StringName(unit_id))
	return snapshot

func get_burden_band() -> int:
	return clampi(burden, 0, 9)

func get_trust_band() -> int:
	return clampi(trust, 0, 9)

func to_debug_dict() -> Dictionary:
	return {
		"burden": burden,
		"trust": trust,
		"ending_tendency": String(ending_tendency),
		"previous_fragment_count": previous_fragment_count,
		"previous_command_count": previous_command_count,
		"previous_fragment_ids": previous_fragment_ids.duplicate(),
		"previous_command_ids": previous_command_ids.duplicate(),
		"recovered_fragments": get_recovered_fragment_ids(),
		"unlocked_commands": get_unlocked_command_ids(),
		"unit_progression": get_unit_progress_snapshot()
	}
