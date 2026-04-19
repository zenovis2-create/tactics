class_name BondEndingRegistry
extends Resource

class BondEnding extends RefCounted:
	var id: String = ""
	var pair_id: String = ""
	var units: Array[StringName] = []
	var ending_title: String = ""
	var ending_text: String = ""
	var slowmo_duration: float = 0.0
	var bgm_change: StringName = &""

	func duplicate_ending() -> BondEnding:
		var clone := BondEnding.new()
		clone.id = id
		clone.pair_id = pair_id
		clone.units = units.duplicate()
		clone.ending_title = ending_title
		clone.ending_text = ending_text
		clone.slowmo_duration = slowmo_duration
		clone.bgm_change = bgm_change
		return clone

const RANDOM_PAIR_ID := "random"
const REGISTERED_PAIR_IDS := ["rian+noah", "lete+mira", "melkion+mira", RANDOM_PAIR_ID]

var _pair_endings: Dictionary = {}

func _init() -> void:
	_register_default_endings()

func check_simultaneous_death(fallen_units: Array) -> BondEnding:
	var normalized_units := _normalize_fallen_units(fallen_units)
	if normalized_units.size() < 2:
		return null

	for pair_id in REGISTERED_PAIR_IDS:
		if pair_id == RANDOM_PAIR_ID:
			continue
		var ending: BondEnding = _pair_endings.get(pair_id, null) as BondEnding
		if ending == null:
			continue
		if _contains_all_units(normalized_units, ending.units):
			return ending.duplicate_ending()

	var random_units := _collect_random_units(normalized_units)
	if random_units.size() < 2:
		return null

	var random_ending := get_pair_ending(RANDOM_PAIR_ID)
	if random_ending == null:
		return null
	random_ending.units = [random_units[0], random_units[1]]
	random_ending.pair_id = _build_pair_id(random_units[0], random_units[1])
	return random_ending

func get_pair_ending(pair_id: String) -> BondEnding:
	var normalized_pair_id := _normalize_pair_id(pair_id)
	if not _pair_endings.has(normalized_pair_id):
		return null
	return (_pair_endings[normalized_pair_id] as BondEnding).duplicate_ending()

func _register_default_endings() -> void:
	_register_pair(
		"rian+noah",
		[&"rian", &"noah"],
		"The Bell Fell Silent",
		"Rian and Noah vanished beneath the floodlit stones together, leaving the cloister with no witness brave enough to name what was lost.",
		1.4,
		&"bgm_bond_death_rian_noah"
	)
	_register_pair(
		"lete+mira",
		[&"lete", &"mira"],
		"Ashes in the Monastery Rain",
		"Lete and Mira fell in the same breath, and the rain over Farland carried their unfinished vows into the empty monastery court.",
		1.35,
		&"bgm_bond_death_lete_mira"
	)
	_register_pair(
		"melkion+mira",
		[&"melkion", &"mira"],
		"The Truth We Buried",
		"Melkion and Mira died before the same truth could divide them again, and the battlefield kept their answer in silence.",
		1.5,
		&"bgm_bond_death_melkion_mira"
	)
	_register_pair(
		RANDOM_PAIR_ID,
		[],
		"Two Lights Lost",
		"Two comrades fell in the same turn, and the line broke so quickly that only their shared silence remained.",
		1.1,
		&"bgm_bond_death_random"
	)

func _register_pair(pair_id: String, units: Array[StringName], title: String, text: String, slowmo_duration: float, bgm_change: StringName) -> void:
	var ending := BondEnding.new()
	ending.id = "bond_death_%s" % pair_id.replace("+", "_")
	ending.pair_id = pair_id
	ending.units = units.duplicate()
	ending.ending_title = title
	ending.ending_text = text
	ending.slowmo_duration = slowmo_duration
	ending.bgm_change = bgm_change
	_pair_endings[pair_id] = ending

func _normalize_fallen_units(fallen_units: Array) -> Array[StringName]:
	var normalized_units: Array[StringName] = []
	for unit in fallen_units:
		var normalized_unit_id := _normalize_unit_id(unit)
		if normalized_unit_id == &"" or normalized_units.has(normalized_unit_id):
			continue
		normalized_units.append(normalized_unit_id)
	return normalized_units

func _normalize_unit_id(unit: Variant) -> StringName:
	var raw_id := ""
	if unit == null:
		return &""
	if unit is String:
		raw_id = unit
	elif unit is StringName:
		raw_id = String(unit)
	elif unit is Dictionary:
		raw_id = String((unit as Dictionary).get("unit_id", ""))
	elif unit.get("unit_data") != null:
		raw_id = String(unit.unit_data.unit_id)
	elif unit.get("unit_id") != null:
		raw_id = String(unit.unit_id)

	var normalized := raw_id.strip_edges().to_lower()
	if normalized.is_empty():
		return &""
	if normalized.begins_with("ally_"):
		normalized = normalized.trim_prefix("ally_")
	elif normalized.begins_with("enemy_"):
		normalized = normalized.trim_prefix("enemy_")
	if normalized.ends_with("_ally"):
		normalized = normalized.trim_suffix("_ally")
	return StringName(normalized)

func _contains_all_units(fallen_units: Array[StringName], required_units: Array[StringName]) -> bool:
	for unit_id in required_units:
		if not fallen_units.has(unit_id):
			return false
	return true

func _collect_random_units(fallen_units: Array[StringName]) -> Array[StringName]:
	var reserved_units: Dictionary = {}
	for pair_id in REGISTERED_PAIR_IDS:
		if pair_id == RANDOM_PAIR_ID:
			continue
		var ending: BondEnding = _pair_endings.get(pair_id, null) as BondEnding
		if ending == null:
			continue
		if _contains_all_units(fallen_units, ending.units):
			for unit_id in ending.units:
				reserved_units[String(unit_id)] = true

	var random_units: Array[StringName] = []
	for unit_id in fallen_units:
		if reserved_units.has(String(unit_id)):
			continue
		random_units.append(unit_id)
	return random_units

func _normalize_pair_id(pair_id: String) -> String:
	return pair_id.strip_edges().to_lower()

func _build_pair_id(unit_a: StringName, unit_b: StringName) -> String:
	var parts := [String(unit_a), String(unit_b)]
	parts.sort()
	return "%s+%s" % [parts[0], parts[1]]
