class_name BattleControllerBondDeath
extends RefCounted

const BondEndingRegistry = preload("res://scripts/battle/bond_ending_registry.gd")

const MIN_SUPPORT_RANK := 2
const SPECIAL_PAIR_IDS := ["rian+noah", "lete+mira", "melkion+mira"]

var _registry: BondEndingRegistry = BondEndingRegistry.new()

func get_registry() -> BondEndingRegistry:
	return _registry

func resolve_bond_death(fallen_units_this_turn: Array, bond_service: Node) -> Dictionary:
	var fallen_units := _normalize_fallen_units(fallen_units_this_turn)
	if fallen_units.size() < 2 or bond_service == null:
		return {}

	for pair_id in SPECIAL_PAIR_IDS:
		var ending := _registry.get_pair_ending(pair_id)
		if ending == null:
			continue
		if not _pair_present(fallen_units, ending.units):
			continue
		if _get_support_rank_for_units(ending.units[0], ending.units[1], bond_service) < MIN_SUPPORT_RANK:
			continue
		return {
			"pair_id": pair_id,
			"ending": ending
		}

	var reserved_units := _collect_reserved_units(fallen_units)
	for first_index in range(fallen_units.size()):
		var first_unit: StringName = fallen_units[first_index]
		if reserved_units.has(String(first_unit)):
			continue
		for second_index in range(first_index + 1, fallen_units.size()):
			var second_unit: StringName = fallen_units[second_index]
			if reserved_units.has(String(second_unit)):
				continue
			if _get_support_rank_for_units(first_unit, second_unit, bond_service) < MIN_SUPPORT_RANK:
				continue
			var random_ending := _registry.get_pair_ending(BondEndingRegistry.RANDOM_PAIR_ID)
			if random_ending == null:
				return {}
			random_ending.units = [first_unit, second_unit]
			random_ending.pair_id = _build_pair_id(first_unit, second_unit)
			return {
				"pair_id": random_ending.pair_id,
				"ending": random_ending
			}

	return {}

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

func _pair_present(fallen_units: Array[StringName], pair_units: Array[StringName]) -> bool:
	for unit_id in pair_units:
		if not fallen_units.has(unit_id):
			return false
	return true

func _collect_reserved_units(fallen_units: Array[StringName]) -> Dictionary:
	var reserved_units: Dictionary = {}
	for pair_id in SPECIAL_PAIR_IDS:
		var ending := _registry.get_pair_ending(pair_id)
		if ending == null:
			continue
		if not _pair_present(fallen_units, ending.units):
			continue
		for unit_id in ending.units:
			reserved_units[String(unit_id)] = true
	return reserved_units

func _get_support_rank_for_units(first_unit: StringName, second_unit: StringName, bond_service: Node) -> int:
	if bond_service == null or not bond_service.has_method("get_support_rank"):
		return 0
	return int(bond_service.get_support_rank(_to_support_unit_id(first_unit), _to_support_unit_id(second_unit)))

func _to_support_unit_id(unit_id: StringName) -> StringName:
	match unit_id:
		&"melkion":
			return &"ally_melkion_ally"
		&"lete":
			return &"ally_lete"
		&"mira":
			return &"ally_mira"
		_:
			return StringName("ally_%s" % String(unit_id))

func _build_pair_id(unit_a: StringName, unit_b: StringName) -> String:
	var parts := [String(unit_a), String(unit_b)]
	parts.sort()
	return "%s+%s" % [parts[0], parts[1]]
