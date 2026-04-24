class_name EnchantService
extends Node

const enchant_types: Dictionary = {
	"fire": "화염",
	"ice": "빙결",
	"thunder": "번개",
	"dark": "암속"
}

const enchant_power_by_tier: Dictionary = {
	1: 1,
	2: 2,
	3: 3
}

# enchant_cost(gold, tier) -> int
static func enchant_cost(gold: int, tier: int) -> int:
	match tier:
		1: return 300
		2: return 800
		3: return 1500
	return 0


# enchant_failure_possible(tier) -> bool (tier 3 = 30%)
static func enchant_failure_possible(tier: int) -> bool:
	if tier < 3:
		return false
	return true


# enchant_equipment(equipment, enchant_type) -> bool
static func enchant_equipment(equipment, enchant_type: String) -> bool:
	if equipment == null:
		return false
	if not enchant_type in enchant_types:
		return false
	if not "tier" in equipment:
		return false
	if equipment.tier < 1:
		return false
	
	var tier: int = equipment.tier
	var cost: int = enchant_cost(0, tier)
	var unit = equipment.unit_owner
	if unit == null:
		return false
	if unit.gold < cost:
		return false
	
	# failure check for tier 3
	if enchant_failure_possible(tier):
		if randf() < 0.30:
			return false
	
	unit.gold -= cost
	equipment.enchant_type = enchant_type
	equipment.enchant_power = enchant_power_by_tier.get(tier, 0)
	return true
