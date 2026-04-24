class_name SigilService
extends Node

const sigil_types: Dictionary = {
	"strength": "力量",
	"defense": "防御",
	"speed": "速度",
	"wisdom": "知慧",
	"luck": "幸运"
}

const sigil_power_by_tier: Dictionary = {
	1: 5,
	2: 10,
	3: 15
}

# sigil_tuning_unlock_count(tier) -> int
static func sigil_tuning_unlock_count(tier: int) -> int:
	match tier:
		1: return 1
		2: return 3
		3: return 5
	return 0


# apply_sigil(equipment, sigil_id) -> bool
static func apply_sigil(equipment, sigil_id: String) -> bool:
	if equipment == null:
		return false
	if not sigil_id in sigil_types:
		return false
	
	if not "tier" in equipment:
		return false
	
	var tier: int = equipment.tier
	if tier < 1:
		return false
	
	var unit = equipment.unit_owner
	if unit == null:
		return false
	
	# check gold cost by tier
	var cost: int = 400 + (tier * 200)
	if unit.gold < cost:
		return false
	
	unit.gold -= cost
	
	# apply sigil bonus based on tier
	var power: int = sigil_power_by_tier.get(tier, 0)
	match sigil_id:
		"strength":
			equipment.attack_bonus += power
		"defense":
			equipment.defense_bonus += power
		"speed":
			equipment.movement_bonus += power
	
	equipment.sigil_id = sigil_id
	equipment.sigil_power = power
	return true


# sigil_cost_by_tier(tier) -> int
static func sigil_cost_by_tier(tier: int) -> int:
	return 400 + (tier * 200)
