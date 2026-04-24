class_name SkillLevelUpService
extends Node

## Manages skill EXP accumulation, level-up, and progression persistence.
## Operates on SkillData resources attached to UnitActor instances.
## All level/EXP state is stored in the unit's SkillData resource.

const SkillData = preload("res://scripts/data/skill_data.gd")
const MAX_SKILL_LEVEL: int = 5

## EXP granted per action type.
const EXP_KILL: int = 10
const EXP_ASSIST: int = 5
const EXP_USE_SKILL: int = 3
const EXP_COMPLETE_STAGE: int = 20

## Add EXP to a unit's skill and handle level-up.
## Returns true if the skill leveled up.
func add_exp(unit: Node, skill_id: StringName, exp_amount: int) -> bool:
	if unit == null or exp_amount <= 0:
		return false

	var skill: SkillData = _get_skill_by_id(unit, skill_id)
	if skill == null:
		return false

	if skill.skill_level >= MAX_SKILL_LEVEL:
		return false

	var old_level: int = skill.skill_level
	skill.skill_exp += exp_amount

	# Check for level-up (may be multiple levels if EXP overflows)
	while skill.skill_exp >= skill.exp_to_next_level(skill.skill_level) and skill.skill_level < MAX_SKILL_LEVEL:
		_do_level_up(skill)

	_save_skill_progress(unit, skill_id, skill)
	return skill.skill_level > old_level

## Force level-up a skill (used when manually leveling up or from battle rewards).
## Returns true if level-up occurred.
func level_up(unit: Node, skill_id: StringName) -> bool:
	var skill: SkillData = _get_skill_by_id(unit, skill_id)
	if skill == null or skill.skill_level >= MAX_SKILL_LEVEL:
		return false

	var old_level: int = skill.skill_level
	_do_level_up(skill)
	_save_skill_progress(unit, skill_id, skill)
	return skill.skill_level > old_level

## Get the current level of a skill.
func get_skill_level(unit: Node, skill_id: StringName) -> int:
	var skill: SkillData = _get_skill_by_id(unit, skill_id)
	if skill == null:
		return 1
	return skill.skill_level

## Get the current EXP of a skill.
func get_skill_exp(unit: Node, skill_id: StringName) -> int:
	var skill: SkillData = _get_skill_by_id(unit, skill_id)
	if skill == null:
		return 0
	return skill.skill_exp

## Get the EXP required to go from current_level to current_level+1.
## Returns 0 if already at max level.
func exp_to_next_level(current_level: int) -> int:
	if current_level >= MAX_SKILL_LEVEL:
		return 0
	var curve: Dictionary = {
		1: 30,
		2: 60,
		3: 100,
		4: 150,
	}
	return int(curve.get(current_level, 0))

## Get the remaining EXP needed to reach next level from current skill state.
func get_exp_remaining(unit: Node, skill_id: StringName) -> int:
	var skill: SkillData = _get_skill_by_id(unit, skill_id)
	if skill == null:
		return 0
	return skill.exp_remaining()

## Get the effective power modifier for the current skill level.
func get_effective_power(unit: Node, skill_id: StringName) -> int:
	var skill: SkillData = _get_skill_by_id(unit, skill_id)
	if skill == null:
		return 0
	return skill.get_effective_power_modifier()

## Returns all skill EXP data for a unit as dict {skill_id: {level, exp, exp_to_next, exp_remaining, is_max, effective_power}}.
func get_all_skill_data(unit: Node) -> Dictionary:
	var result: Dictionary = {}
	if unit == null:
		return result

	var unit_data = unit.get("unit_data")
	if unit_data == null:
		return result

	var all_skills = unit_data.call("get_all_skills") if unit_data.has_method("get_all_skills") else unit_data.get("skills")
	if all_skills == null or all_skills.is_empty():
		all_skills = unit_data.get("default_skill")
		if all_skills != null:
			all_skills = [all_skills]

	if all_skills == null:
		return result

	for skill in all_skills:
		if skill != null and skill is SkillData:
			result[skill.skill_id] = {
				"level": skill.skill_level,
				"exp": skill.skill_exp,
				"exp_to_next": exp_to_next_level(skill.skill_level),
				"exp_remaining": skill.exp_remaining(),
				"is_max": skill.is_max_level(),
				"effective_power": skill.get_effective_power_modifier(),
			}
	return result

## Reset a skill's level and EXP to initial values.
func reset_skill(unit: Node, skill_id: StringName) -> void:
	var skill: SkillData = _get_skill_by_id(unit, skill_id)
	if skill == null:
		return
	skill.skill_level = 1
	skill.skill_exp = 0
	_save_skill_progress(unit, skill_id, skill)

## Internal: Perform one level-up step on the skill resource.
func _do_level_up(skill: SkillData) -> void:
	if skill.skill_level >= MAX_SKILL_LEVEL:
		return
	var exp_needed: int = skill.exp_to_next_level(skill.skill_level)
	skill.skill_exp -= exp_needed
	skill.skill_level += 1

## Internal: Retrieve a skill resource from a unit by skill_id.
func _get_skill_by_id(unit: Node, skill_id: StringName) -> SkillData:
	if unit == null:
		return null

	var unit_data = unit.get("unit_data")
	if unit_data != null:
		var skills: Array = unit_data.call("get_all_skills") if unit_data.has_method("get_all_skills") else unit_data.get("skills")
		if skills != null:
			for skill in skills:
				if skill != null and skill is SkillData and skill.skill_id == skill_id:
					return skill
		var default: SkillData = unit_data.get("default_skill")
		if default != null and default.skill_id == skill_id:
			return default

	return null

## Internal: Persist skill progress to ProgressionData.unit_progress.
func _save_skill_progress(unit: Node, skill_id: StringName, skill: SkillData) -> void:
	var unit_id_str: String = _get_unit_id_string(unit)
	if unit_id_str.is_empty():
		return

	var battle_controller: Node = _find_battle_controller(unit)
	if battle_controller == null:
		return

	var progression: Node = battle_controller.get("progression_service")
	if progression == null or not progression.has_method("get_data"):
		return

	var progression_data = progression.get_data()
	if progression_data == null:
		return

	progression_data.set_skill_progress(StringName(unit_id_str), skill_id, skill.skill_level, skill.skill_exp)

## Internal: Load skill progress from ProgressionData into a unit's SkillData.
func load_skill_progress(unit: Node, skill_id: StringName) -> void:
	var unit_id_str: String = _get_unit_id_string(unit)
	if unit_id_str.is_empty():
		return

	var battle_controller: Node = _find_battle_controller(unit)
	if battle_controller == null:
		return

	var progression: Node = battle_controller.get("progression_service")
	if progression == null or not progression.has_method("get_data"):
		return

	var progression_data = progression.get_data()
	if progression_data == null:
		return

	var skill: SkillData = _get_skill_by_id(unit, skill_id)
	if skill == null:
		return

	var level: int = progression_data.get_skill_level(StringName(unit_id_str), skill_id)
	var exp: int = progression_data.get_skill_exp(StringName(unit_id_str), skill_id)
	skill.skill_level = level
	skill.skill_exp = exp

## Internal: Walk up the scene tree to find BattleController.
func _find_battle_controller(node: Node) -> Node:
	var current: Node = node
	for i in range(8):
		if current == null:
			break
		if current.get("ally_units") != null and current.get("enemy_units") != null:
			return current
		current = current.get_parent()
	return null

## Internal: Get the unit's ID as a string.
func _get_unit_id_string(unit: Node) -> String:
	if unit == null:
		return ""
	var unit_data = unit.get("unit_data")
	if unit_data != null:
		var uid = unit_data.get("unit_id")
		if uid != null:
			return String(uid)
	return ""
