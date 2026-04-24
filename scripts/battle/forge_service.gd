class_name ForgeService
extends Node

const ProgressionData = preload("res://scripts/data/progression_data.gd")

const OUTPUT_WEAPON: StringName = &"weapon"
const OUTPUT_ARMOR: StringName = &"armor"
const OUTPUT_ACCESSORY: StringName = &"accessory"

const MATERIAL_LABELS: Dictionary = {
	&"archive_ash": "Archive Ash",
	&"coal": "Coal",
	&"command_plate": "Command Plate",
	&"fiber_bundle": "Fiber Bundle",
	&"forest_essence": "Forest Essence",
	&"iron_frag": "Iron Fragment",
	&"memory_thread": "Memory Thread",
	&"sanctified_shard": "Sanctified Shard"
}

const CRAFTING_RECIPES: Dictionary = {
	&"recipe_archive_ashblade": {
		"label": "Archive Ashblade",
		"output_type": OUTPUT_WEAPON,
		"output_id": &"wp_archive_ashblade",
		"materials": {&"iron_frag": 2, &"archive_ash": 3, &"coal": 1}
	},
	&"recipe_greenwood_cloak": {
		"label": "Greenwood Cloak",
		"output_type": OUTPUT_ARMOR,
		"output_id": &"ar_greenwood_cloak",
		"materials": {&"forest_essence": 3, &"fiber_bundle": 2}
	},
	&"recipe_militia_emblem": {
		"label": "Militia Emblem",
		"output_type": OUTPUT_ACCESSORY,
		"output_id": &"acc_militia_emblem",
		"materials": {&"iron_frag": 3, &"coal": 1}
	},
	&"recipe_sanctified_pendant": {
		"label": "Sanctified Pendant",
		"output_type": OUTPUT_ACCESSORY,
		"output_id": &"acc_sanctified_pendant",
		"materials": {&"sanctified_shard": 2, &"forest_essence": 1}
	},
	&"recipe_valtor_command_lance": {
		"label": "Valtor Command Lance",
		"output_type": OUTPUT_WEAPON,
		"output_id": &"wp_valtor_command_lance",
		"materials": {&"command_plate": 2, &"iron_frag": 2, &"coal": 1}
	},
	&"recipe_keeper_root_staff": {
		"label": "Keeper Root Staff",
		"output_type": OUTPUT_WEAPON,
		"output_id": &"wp_keeper_root_staff",
		"materials": {&"archive_ash": 2, &"memory_thread": 2}
	},
	&"recipe_eclipse_resonance_blade": {
		"label": "Eclipse Resonance Blade",
		"output_type": OUTPUT_WEAPON,
		"output_id": &"wp_eclipse_resonance_blade",
		"materials": {&"sanctified_shard": 2, &"command_plate": 2, &"memory_thread": 1}
	},
	&"recipe_revision_guard_cloak": {
		"label": "Revision Guard Cloak",
		"output_type": OUTPUT_ARMOR,
		"output_id": &"ar_revision_guard_cloak",
		"materials": {&"archive_ash": 1, &"memory_thread": 2, &"fiber_bundle": 1}
	},
	&"recipe_bellward_plate": {
		"label": "Bellward Plate",
		"output_type": OUTPUT_ARMOR,
		"output_id": &"ar_bellward_plate",
		"materials": {&"sanctified_shard": 2, &"command_plate": 2}
	},
	&"recipe_tower_ward_signet": {
		"label": "Tower Ward Signet",
		"output_type": OUTPUT_ACCESSORY,
		"output_id": &"acc_tower_ward_signet",
		"materials": {&"command_plate": 1, &"memory_thread": 1, &"sanctified_shard": 1}
	}
}

const tier_names: Dictionary = {
	0: "일반",
	1: "강화",
	2: "상급",
	3: "최상"
}

var _progression: ProgressionData = null
var _item_owned_callback: Callable = Callable()
var _item_unlock_callback: Callable = Callable()

func configure(progression: ProgressionData, item_owned_callback: Callable, item_unlock_callback: Callable) -> void:
	_progression = progression
	_item_owned_callback = item_owned_callback
	_item_unlock_callback = item_unlock_callback

func can_craft(recipe_id: StringName) -> bool:
	var recipe: Dictionary = get_recipe(recipe_id)
	if recipe.is_empty() or _progression == null:
		return false
	if _owns_output(recipe):
		return false
	return has_required_materials(_progression, recipe)

func craft(recipe_id: StringName) -> bool:
	var recipe: Dictionary = get_recipe(recipe_id)
	if recipe.is_empty() or not can_craft(recipe_id):
		return false
	var materials: Dictionary = recipe.get("materials", {})
	for material_id_variant in materials.keys():
		var material_id: StringName = StringName(material_id_variant)
		var count: int = int(materials.get(material_id_variant, 0))
		if not _progression.consume_material(material_id, count):
			return false
	if _item_unlock_callback.is_valid():
		_item_unlock_callback.call(
			StringName(recipe.get("output_type", &"")),
			StringName(recipe.get("output_id", &""))
		)
	return true

static func get_recipe(recipe_id: StringName) -> Dictionary:
	if not CRAFTING_RECIPES.has(recipe_id):
		return {}
	return Dictionary(CRAFTING_RECIPES.get(recipe_id, {}))

static func get_material_label(material_id: StringName) -> String:
	return String(MATERIAL_LABELS.get(material_id, String(material_id).replace("_", " ").capitalize()))

static func has_required_materials(progression: ProgressionData, recipe: Dictionary) -> bool:
	if progression == null:
		return false
	var materials: Dictionary = recipe.get("materials", {})
	for material_id_variant in materials.keys():
		var material_id: StringName = StringName(material_id_variant)
		if progression.get_material_count(material_id) < int(materials.get(material_id_variant, 0)):
			return false
	return true

static func get_material_entries(progression: ProgressionData) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	if progression == null:
		return entries
	for entry in progression.get_material_snapshot():
		var material_id: StringName = StringName(entry.get("material_id", &""))
		entries.append({
			"material_id": material_id,
			"label": get_material_label(material_id),
			"count": int(entry.get("count", 0))
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a.get("label", "")) < String(b.get("label", ""))
	)
	return entries

static func build_recipe_entries(progression: ProgressionData, owned_item_ids: Array[StringName]) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for recipe_id_variant in CRAFTING_RECIPES.keys():
		var recipe_id: StringName = StringName(recipe_id_variant)
		var recipe: Dictionary = get_recipe(recipe_id)
		var output_id: StringName = StringName(recipe.get("output_id", &""))
		entries.append({
			"recipe_id": recipe_id,
			"label": String(recipe.get("label", String(recipe_id))),
			"output_type": StringName(recipe.get("output_type", &"")),
			"output_id": output_id,
			"materials": format_material_requirements(recipe.get("materials", {}), progression),
			"can_craft": has_required_materials(progression, recipe) and not owned_item_ids.has(output_id),
			"owned": owned_item_ids.has(output_id)
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a.get("label", "")) < String(b.get("label", ""))
	)
	return entries

static func format_material_requirements(materials: Dictionary, progression: ProgressionData = null) -> Array[String]:
	var lines: Array[String] = []
	var keys: Array[String] = []
	for material_id_variant in materials.keys():
		keys.append(String(material_id_variant))
	keys.sort()
	for material_id_text in keys:
		var material_id: StringName = StringName(material_id_text)
		var required_count: int = int(materials.get(material_id, 0))
		if progression == null:
			lines.append("%s x%d" % [get_material_label(material_id), required_count])
			continue
		lines.append("%s %d/%d" % [
			get_material_label(material_id),
			progression.get_material_count(material_id),
			required_count
		])
	return lines

func _owns_output(recipe: Dictionary) -> bool:
	if not _item_owned_callback.is_valid():
		return false
	return bool(_item_owned_callback.call(
		StringName(recipe.get("output_type", &"")),
		StringName(recipe.get("output_id", &""))
	))

# upgrade_cost(gold, from_tier, to_tier) -> int
static func upgrade_cost(gold: int, from_tier: int, to_tier: int) -> int:
	if to_tier <= from_tier:
		return 0
	var base: int = 200
	var tier_cost: int = 0
	for t in range(from_tier, to_tier):
		tier_cost += base + (t * 100)
	return tier_cost

# material_required(to_tier) -> int
static func material_required(to_tier: int) -> int:
	match to_tier:
		1: return 5
		2: return 15
		3: return 30
	return 0

# stat_bonus_for_tier(tier) -> int (tier * 2)
static func stat_bonus_for_tier(tier: int) -> int:
	return tier * 2

# upgrade_equipment(unit, slot, tier) -> bool
static func upgrade_equipment(unit, slot: String, to_tier: int) -> bool:
	if unit == null:
		return false
	if not slot in ["weapon", "armor", "accessory"]:
		return false
	var equip = unit.equipment.get(slot)
	if equip == null:
		return false
	var from_tier: int = equip.tier if "tier" in equip else 0
	if from_tier >= to_tier:
		return false
	if to_tier > 3:
		return false
	var gold_cost: int = upgrade_cost(0, from_tier, to_tier)
	if unit.gold < gold_cost:
		return false
	var mats: int = material_required(to_tier)
	if unit.inventory.get("forge_materials", 0) < mats:
		return false
	unit.gold -= gold_cost
	unit.inventory["forge_materials"] -= mats
	equip.tier = to_tier
	return true
