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

func has_fragment(fragment_id: StringName) -> bool:
	return recovered_fragments.has(fragment_id)

func has_command(command_id: StringName) -> bool:
	return unlocked_commands.has(command_id)

func get_burden_band() -> int:
	return clampi(burden, 0, 9)

func get_trust_band() -> int:
	return clampi(trust, 0, 9)

func to_debug_dict() -> Dictionary:
	return {
		"burden": burden,
		"trust": trust,
		"ending_tendency": String(ending_tendency),
		"recovered_fragments": recovered_fragments.keys(),
		"unlocked_commands": unlocked_commands.keys()
	}
