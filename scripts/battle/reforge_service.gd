class_name ReforgeService
extends Node

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const ForgeService = preload("res://scripts/battle/forge_service.gd")

const ACCESSORY_REFORGE_COST_OPTIONS: Array[Dictionary] = [
	{&"iron_frag": 1},
	{&"forest_essence": 1},
	{&"command_plate": 1},
	{&"memory_thread": 1}
]

static func can_correct_accessory_choice(current_id: StringName, available_ids: Array[StringName]) -> bool:
	if available_ids.size() < 2:
		return false
	if current_id == StringName():
		return not available_ids.is_empty()
	return available_ids.has(current_id)

static func get_corrected_accessory_choice(current_id: StringName, available_ids: Array[StringName]) -> StringName:
	if available_ids.is_empty():
		return StringName()
	if current_id == StringName() or not available_ids.has(current_id):
		return available_ids[0]
	var next_index: int = (available_ids.find(current_id) + 1) % available_ids.size()
	return available_ids[next_index]

static func get_accessory_reforge_cost_option(progression: ProgressionData) -> Dictionary:
	if progression == null:
		return {}
	for option in ACCESSORY_REFORGE_COST_OPTIONS:
		var affordable: bool = true
		for material_id_variant in option.keys():
			var material_id: StringName = StringName(material_id_variant)
			if progression.get_material_count(material_id) < int(option.get(material_id_variant, 0)):
				affordable = false
				break
		if affordable:
			return option.duplicate(true)
	return {}

static func can_afford_accessory_reforge(progression: ProgressionData) -> bool:
	return not get_accessory_reforge_cost_option(progression).is_empty()

static func consume_accessory_reforge_cost(progression: ProgressionData) -> bool:
	var option: Dictionary = get_accessory_reforge_cost_option(progression)
	if option.is_empty():
		return false
	for material_id_variant in option.keys():
		var material_id: StringName = StringName(material_id_variant)
		var count: int = int(option.get(material_id_variant, 0))
		if not progression.consume_material(material_id, count):
			return false
	return true

static func format_accessory_reforge_cost(progression: ProgressionData = null) -> String:
	if progression == null:
		var fallback_lines: Array[String] = []
		for option in ACCESSORY_REFORGE_COST_OPTIONS:
			for material_id_variant in option.keys():
				var material_id: StringName = StringName(material_id_variant)
				var count: int = int(option.get(material_id_variant, 0))
				fallback_lines.append("%s x%d" % [ForgeService.get_material_label(material_id), count])
		return "필요 재료: %s" % " / ".join(fallback_lines)
	var option: Dictionary = get_accessory_reforge_cost_option(progression)
	if option.is_empty():
		return format_accessory_reforge_cost(null)
	var lines: Array[String] = []
	for material_id_variant in option.keys():
		var material_id: StringName = StringName(material_id_variant)
		var count: int = int(option.get(material_id_variant, 0))
		lines.append("%s x%d" % [ForgeService.get_material_label(material_id), count])
	return "소모: %s" % ", ".join(lines)

# reforge_cost(gold) -> int (500 gold base)
static func reforge_cost(gold: int) -> int:
	return 500

# reroll_stats(equipment) — stat redistribution
static func reroll_stats(equipment) -> bool:
	if equipment == null:
		return false
	var total_points: int = 0
	if "attack_bonus" in equipment:
		total_points += equipment.attack_bonus
	if "defense_bonus" in equipment:
		total_points += equipment.defense_bonus
	if "movement_bonus" in equipment:
		total_points += equipment.movement_bonus
	var rng = RandomNumberGenerator.new()
	var a = rng.randi() % (total_points + 1)
	var d = rng.randi() % (total_points - a + 1)
	var m = total_points - a - d
	equipment.attack_bonus = max(0, a)
	equipment.defense_bonus = max(0, d)
	equipment.movement_bonus = max(0, m)
	return true

# reforge_equipment(equipment) -> bool
static func reforge_equipment(equipment) -> bool:
	if equipment == null:
		return false
	var unit = equipment.unit_owner
	if unit == null:
		return false
	if unit.gold < reforge_cost(0):
		return false
	unit.gold -= reforge_cost(0)
	if "tier" in equipment and equipment.tier < 3:
		equipment.tier += 1
	return reroll_stats(equipment)

# guaranteed_tier_up(equipment) -> bool
static func guaranteed_tier_up(equipment) -> bool:
	if equipment == null:
		return false
	if not "tier" in equipment:
		return false
	if equipment.tier >= 3:
		return false
	var unit = equipment.unit_owner
	if unit == null:
		return false
	var cost: int = 2000
	if unit.gold < cost:
		return false
	unit.gold -= cost
	equipment.tier += 1
	return true
