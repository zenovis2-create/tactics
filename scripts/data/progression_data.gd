class_name ProgressionData
extends Resource

const LEGACY_UNIT_ID_MAP := {
	"ally_karl": "ally_kyle",
	"enemy_karon": "enemy_karuon",
	"enemy_karon_final": "enemy_karuon_final",
	"enemy_varten": "enemy_barten",
	"enemy_karl_1": "enemy_kyle_1",
}

const LEGACY_PAIR_ID_MAP := {
	"rian_karl": "rian_kyle",
}

const HIDDEN_RECRUIT_FLAG_BY_UNIT_ID := {
	"ally_mira": "hidden_recruit_mira",
	"ally_lete": "hidden_recruit_lete",
	"ally_melkion_ally": "hidden_recruit_melkion_ally",
}

const HIDDEN_RECRUIT_CONSUMED_FLAG_BY_UNIT_ID := {
	"ally_melkion_ally": "hidden_recruit_melkion_ally_consumed",
}

## Serializable campaign-level meta state.
## Owned by ProgressionService; persisted in save file.

# Burden: 0-9. Tracks moral cost of Rian's recovered truths.
# 0 = no weight, 9 = maximum accumulated burden.
@export var burden: int = 0

# Trust: 0-9. Tracks collective trust between Rian and his squad.
# 0 = minimal trust, 9 = full cohesion.
@export var trust: int = 0

# Gold: camp economy currency used by crafting, reforge, and selling.
@export var gold: int = 0

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

@export var flags: Dictionary = {}

@export var cleared_stage_ids: Array[StringName] = []

@export var discovered_treasure_ids: Array[String] = []

@export var unlocked_hunt_ids: Array[StringName] = []

@export var owned_weapon_counts: Dictionary = {}

@export var owned_armor_counts: Dictionary = {}

@export var owned_accessory_counts: Dictionary = {}

@export var bond_levels: Dictionary = {}

@export var support_ranks: Dictionary = {}

@export var shared_battles: Dictionary = {}

@export var narrative_axis_values: Dictionary = {}

@export var unlocked_passive_card_ids: Array[StringName] = []

@export var hint_reveal_state: Dictionary = {}

@export var bonus_exp_history: Array[Dictionary] = []

@export var ng_plus_available: bool = false

@export var ng_plus_run: bool = false

@export var last_completed_ending: StringName = &""

@export var previous_fragment_count: int = 0

@export var previous_command_count: int = 0

@export var previous_fragment_ids: Array[String] = []

@export var previous_command_ids: Array[String] = []

@export var material_entries: Array[Dictionary] = []

@export var stage_star_ratings: Dictionary = {}

@export var total_stars: int = 0

@export var stage_clear_records: Dictionary = {}

func has_fragment(fragment_id: StringName) -> bool:
	return recovered_fragments.has(fragment_id)

func has_command(command_id: StringName) -> bool:
	return unlocked_commands.has(command_id)

func has_passive_card(card_id: StringName) -> bool:
	return unlocked_passive_card_ids.has(card_id)

func unlock_passive_card(card_id: StringName) -> bool:
	if card_id == &"" or has_passive_card(card_id):
		return false
	unlocked_passive_card_ids.append(card_id)
	return true

func get_unlocked_passive_card_ids() -> Array[String]:
	var ids: Array[String] = []
	for card_id in unlocked_passive_card_ids:
		ids.append(String(card_id))
	ids.sort()
	return ids

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
	var key := _canonicalize_unit_id(String(unit_id))
	var value: Dictionary = unit_progression.get(key, {})
	return {
		"level": max(1, int(value.get("level", 1))),
		"exp": max(0, int(value.get("exp", 0)))
	}

func set_unit_progress(unit_id: StringName, level: int, exp: int) -> void:
	unit_progression[_canonicalize_unit_id(String(unit_id))] = {
		"level": max(1, level),
		"exp": max(0, exp)
	}

func get_bond_level(unit_id: StringName) -> int:
	var key := _canonicalize_unit_id(String(unit_id))
	if bond_levels.has(key):
		return clampi(int(bond_levels.get(key, 0)), 0, 5)
	var legacy_progress: Dictionary = unit_progression.get(key, {})
	return clampi(int(legacy_progress.get("bond_level", 0)), 0, 5)

func set_bond_level(unit_id: StringName, bond_level: int) -> void:
	bond_levels[_canonicalize_unit_id(String(unit_id))] = clampi(bond_level, 0, 5)

func get_bond_levels_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	var keys: Array[String] = []
	for unit_id in bond_levels.keys():
		keys.append(String(unit_id))
	keys.sort()
	for unit_id in keys:
		snapshot[unit_id] = get_bond_level(StringName(unit_id))
	return snapshot

func get_support_rank(pair_id: String) -> int:
	var key := _canonicalize_pair_id(pair_id)
	if key.is_empty():
		return 0
	return clampi(int(support_ranks.get(key, 0)), 0, 4)

func set_support_rank(pair_id: String, support_rank: int) -> void:
	var key := _canonicalize_pair_id(pair_id)
	if key.is_empty():
		return
	support_ranks[key] = clampi(support_rank, 0, 4)

func get_support_ranks_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	var keys: Array[String] = []
	for pair_id in support_ranks.keys():
		keys.append(String(pair_id))
	keys.sort()
	for pair_id in keys:
		snapshot[pair_id] = get_support_rank(pair_id)
	return snapshot

func get_shared_battle_count(pair_id: String) -> int:
	var key := _canonicalize_pair_id(pair_id)
	if key.is_empty():
		return 0
	return max(0, int(shared_battles.get(key, 0)))

func set_shared_battle_count(pair_id: String, battle_count: int) -> void:
	var key := _canonicalize_pair_id(pair_id)
	if key.is_empty():
		return
	shared_battles[key] = max(0, battle_count)

func get_shared_battles_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	var keys: Array[String] = []
	for pair_id in shared_battles.keys():
		keys.append(String(pair_id))
	keys.sort()
	for pair_id in keys:
		snapshot[pair_id] = get_shared_battle_count(pair_id)
	return snapshot

func get_hint_reveal_level(stage_id: StringName, hint_id: StringName) -> int:
	var stage_key := String(stage_id)
	var hint_key := String(hint_id)
	if stage_key.is_empty() or hint_key.is_empty():
		return 0
	var stage_state: Dictionary = hint_reveal_state.get(stage_key, {})
	return max(0, int(stage_state.get(hint_key, 0)))

func set_hint_reveal_level(stage_id: StringName, hint_id: StringName, level: int) -> bool:
	var stage_key := String(stage_id)
	var hint_key := String(hint_id)
	if stage_key.is_empty() or hint_key.is_empty():
		return false
	var next_level: int = max(0, level)
	var stage_state: Dictionary = hint_reveal_state.get(stage_key, {}).duplicate(true)
	if int(stage_state.get(hint_key, 0)) >= next_level:
		return false
	stage_state[hint_key] = next_level
	hint_reveal_state[stage_key] = stage_state
	return true

func get_hint_reveal_snapshot(stage_id: StringName = &"") -> Dictionary:
	if stage_id == &"":
		return hint_reveal_state.duplicate(true)
	return Dictionary(hint_reveal_state.get(String(stage_id), {})).duplicate(true)

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

func add_gold(amount: int) -> int:
	if amount <= 0:
		return gold
	gold += amount
	return gold

func spend_gold(amount: int) -> bool:
	if amount <= 0:
		return false
	if gold < amount:
		return false
	gold -= amount
	return true

func get_owned_item_count(slot_kind: StringName, item_id: StringName) -> int:
	if item_id == &"":
		return 0
	var store := _get_owned_store(slot_kind)
	return max(0, int(store.get(String(item_id), 0)))

func set_owned_item_count(slot_kind: StringName, item_id: StringName, count: int) -> void:
	if item_id == &"":
		return
	var key := String(item_id)
	var store := _get_owned_store(slot_kind)
	if count <= 0:
		store.erase(key)
		return
	store[key] = count

func add_owned_item(slot_kind: StringName, item_id: StringName, count: int = 1) -> int:
	if item_id == &"" or count <= 0:
		return get_owned_item_count(slot_kind, item_id)
	var next_count := get_owned_item_count(slot_kind, item_id) + count
	set_owned_item_count(slot_kind, item_id, next_count)
	return next_count

func consume_owned_item(slot_kind: StringName, item_id: StringName, count: int = 1) -> bool:
	if item_id == &"" or count <= 0:
		return false
	var current_count := get_owned_item_count(slot_kind, item_id)
	if current_count < count:
		return false
	set_owned_item_count(slot_kind, item_id, current_count - count)
	return true

func get_owned_item_ids(slot_kind: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	var keys: Array[String] = []
	var store := _get_owned_store(slot_kind)
	for raw_key in store.keys():
		if max(0, int(store.get(raw_key, 0))) > 0:
			keys.append(String(raw_key))
	keys.sort()
	for key in keys:
		ids.append(StringName(key))
	return ids

func get_material_count(material_id: StringName) -> int:
	for entry in material_entries:
		if StringName(entry.get("material_id", &"")) == material_id:
			return max(0, int(entry.get("count", 0)))
	return 0

func get_material_snapshot() -> Array[Dictionary]:
	var snapshot: Array[Dictionary] = []
	for entry in material_entries:
		snapshot.append({
			"material_id": StringName(entry.get("material_id", &"")),
			"count": max(0, int(entry.get("count", 0)))
		})
	return snapshot

func set_stage_clear_record(stage_id: StringName, record: Dictionary) -> void:
	if stage_id == &"":
		return
	stage_clear_records[String(stage_id)] = record.duplicate(true)

func get_stage_clear_record(stage_id: StringName) -> Dictionary:
	if stage_id == &"":
		return {}
	return Dictionary(stage_clear_records.get(String(stage_id), {})).duplicate(true)

func has_hidden_recruit(unit_id: StringName) -> bool:
	var key := _canonicalize_unit_id(String(unit_id))
	if key.is_empty():
		return false
	var flag_id: String = String(HIDDEN_RECRUIT_FLAG_BY_UNIT_ID.get(key, ""))
	if flag_id.is_empty():
		return false
	if bool(flags.get(flag_id, false)) == false:
		return false
	var consumed_flag_id: String = String(HIDDEN_RECRUIT_CONSUMED_FLAG_BY_UNIT_ID.get(key, ""))
	if not consumed_flag_id.is_empty() and bool(flags.get(consumed_flag_id, false)):
		return false
	return true

func unlock_hidden_recruit(unit_id: StringName) -> bool:
	var key := _canonicalize_unit_id(String(unit_id))
	if key.is_empty():
		return false
	var flag_id: String = String(HIDDEN_RECRUIT_FLAG_BY_UNIT_ID.get(key, ""))
	if flag_id.is_empty() or bool(flags.get(flag_id, false)):
		return false
	flags[flag_id] = true
	var consumed_flag_id: String = String(HIDDEN_RECRUIT_CONSUMED_FLAG_BY_UNIT_ID.get(key, ""))
	if not consumed_flag_id.is_empty():
		flags.erase(consumed_flag_id)
	return true

func consume_hidden_recruit(unit_id: StringName) -> bool:
	var key := _canonicalize_unit_id(String(unit_id))
	if key.is_empty():
		return false
	var consumed_flag_id: String = String(HIDDEN_RECRUIT_CONSUMED_FLAG_BY_UNIT_ID.get(key, ""))
	if consumed_flag_id.is_empty() or bool(flags.get(consumed_flag_id, false)):
		return false
	flags[consumed_flag_id] = true
	return true

func add_material(material_id: StringName, count: int) -> int:
	if material_id == &"" or count <= 0:
		return get_material_count(material_id)
	for index in range(material_entries.size()):
		var entry: Dictionary = material_entries[index]
		if StringName(entry.get("material_id", &"")) != material_id:
			continue
		var next_count: int = max(0, int(entry.get("count", 0))) + count
		material_entries[index] = {"material_id": material_id, "count": next_count}
		return next_count
	material_entries.append({"material_id": material_id, "count": count})
	return count

func consume_material(material_id: StringName, count: int) -> bool:
	if material_id == &"" or count <= 0:
		return false
	for index in range(material_entries.size()):
		var entry: Dictionary = material_entries[index]
		if StringName(entry.get("material_id", &"")) != material_id:
			continue
		var current_count: int = max(0, int(entry.get("count", 0)))
		if current_count < count:
			return false
		var next_count: int = current_count - count
		if next_count <= 0:
			material_entries.remove_at(index)
		else:
			material_entries[index] = {"material_id": material_id, "count": next_count}
		return true
	return false

func to_debug_dict() -> Dictionary:
	return {
		"burden": burden,
		"trust": trust,
		"gold": gold,
		"ending_tendency": String(ending_tendency),
		"last_completed_ending": String(last_completed_ending),
		"ng_plus_available": ng_plus_available,
		"ng_plus_run": ng_plus_run,
		"previous_fragment_count": previous_fragment_count,
		"previous_command_count": previous_command_count,
		"previous_fragment_ids": previous_fragment_ids.duplicate(),
		"previous_command_ids": previous_command_ids.duplicate(),
		"recovered_fragments": get_recovered_fragment_ids(),
		"unlocked_commands": get_unlocked_command_ids(),
		"unit_progression": get_unit_progress_snapshot(),
		"flags": flags.duplicate(true),
		"cleared_stage_ids": cleared_stage_ids.duplicate(),
		"discovered_treasure_ids": discovered_treasure_ids.duplicate(),
		"unlocked_hunt_ids": unlocked_hunt_ids.duplicate(),
		"owned_weapon_counts": owned_weapon_counts.duplicate(true),
		"owned_armor_counts": owned_armor_counts.duplicate(true),
		"owned_accessory_counts": owned_accessory_counts.duplicate(true),
		"bond_levels": get_bond_levels_snapshot(),
		"support_ranks": get_support_ranks_snapshot(),
		"shared_battles": get_shared_battles_snapshot(),
		"narrative_axis_values": narrative_axis_values.duplicate(true),
		"unlocked_passive_card_ids": unlocked_passive_card_ids.duplicate(),
		"hint_reveal_state": hint_reveal_state.duplicate(true),
		"bonus_exp_history": bonus_exp_history.duplicate(true),
		"material_entries": get_material_snapshot(),
		"stage_star_ratings": stage_star_ratings.duplicate(true),
		"total_stars": total_stars,
		"stage_clear_records": stage_clear_records.duplicate(true)
	}

func migrate_legacy_ids() -> void:
	unit_progression = _migrate_unit_progression_keys(unit_progression)
	bond_levels = _migrate_numeric_unit_key_dict(bond_levels, 0, 5)
	support_ranks = _migrate_pair_key_dict(support_ranks, 0, 4)
	shared_battles = _migrate_pair_key_dict(shared_battles, 0, -1)

func _get_owned_store(slot_kind: StringName) -> Dictionary:
	match String(slot_kind):
		"weapon":
			return owned_weapon_counts
		"armor":
			return owned_armor_counts
		"accessory":
			return owned_accessory_counts
		_:
			return {}

func _canonicalize_unit_id(unit_id: String) -> String:
	var key := unit_id.strip_edges().to_lower()
	return String(LEGACY_UNIT_ID_MAP.get(key, key))

func _canonicalize_pair_id(pair_id: String) -> String:
	var key := pair_id.strip_edges().to_lower()
	return String(LEGACY_PAIR_ID_MAP.get(key, key))

func _migrate_unit_progression_keys(source: Dictionary) -> Dictionary:
	var migrated: Dictionary = {}
	for raw_key in source.keys():
		var canonical_key := _canonicalize_unit_id(String(raw_key))
		var value: Dictionary = source.get(raw_key, {})
		if not migrated.has(canonical_key):
			migrated[canonical_key] = value.duplicate(true)
			continue
		var existing: Dictionary = migrated.get(canonical_key, {})
		var merged := existing.duplicate(true)
		merged["level"] = max(int(existing.get("level", 1)), int(value.get("level", 1)))
		merged["exp"] = max(int(existing.get("exp", 0)), int(value.get("exp", 0)))
		if value.has("bond_level"):
			merged["bond_level"] = max(int(existing.get("bond_level", 0)), int(value.get("bond_level", 0)))
		merged["recruited"] = bool(existing.get("recruited", false)) or bool(value.get("recruited", false))
		migrated[canonical_key] = merged
	return migrated

func _migrate_numeric_unit_key_dict(source: Dictionary, min_value: int, max_value: int) -> Dictionary:
	var migrated: Dictionary = {}
	for raw_key in source.keys():
		var canonical_key := _canonicalize_unit_id(String(raw_key))
		var value: int = int(source.get(raw_key, 0))
		if max_value >= min_value:
			value = clampi(value, min_value, max_value)
		else:
			value = max(min_value, value)
		migrated[canonical_key] = max(int(migrated.get(canonical_key, min_value)), value)
	return migrated

func _migrate_pair_key_dict(source: Dictionary, min_value: int, max_value: int) -> Dictionary:
	var migrated: Dictionary = {}
	for raw_key in source.keys():
		var canonical_key := _canonicalize_pair_id(String(raw_key))
		var value: int = int(source.get(raw_key, 0))
		if max_value >= min_value:
			value = clampi(value, min_value, max_value)
		else:
			value = max(min_value, value)
		migrated[canonical_key] = max(int(migrated.get(canonical_key, min_value)), value)
	return migrated
