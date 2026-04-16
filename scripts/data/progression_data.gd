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

@export var previous_fragment_count: int = 0

@export var previous_command_count: int = 0

var _previous_fragment_ids: Array[String] = []

var _previous_command_ids: Array[String] = []

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
		if not _previous_command_ids.has(command_id):
			recent.append(command_id)
	return recent

func get_recently_recovered_fragments() -> Array[String]:
	var ids: Array[String] = get_recovered_fragment_ids()
	var recent: Array[String] = []
	for fragment_id in ids:
		if not _previous_fragment_ids.has(fragment_id):
			recent.append(fragment_id)
	return recent

func snapshot_unlock_state() -> void:
	previous_fragment_count = recovered_fragments.size()
	previous_command_count = unlocked_commands.size()
	_previous_fragment_ids = get_recovered_fragment_ids()
	_previous_command_ids = get_unlocked_command_ids()

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
		"recovered_fragments": get_recovered_fragment_ids(),
		"unlocked_commands": get_unlocked_command_ids()
	}
