extends Node

## Standalone SkillLevelUpService unit tests (no GUT dependency)
## Run with: load("res://tests/test_skill_levelup_service.gd").new().run_tests()

const SkillLevelUpService = preload("res://scripts/battle/skill_levelup_service.gd")
const SkillData = preload("res://scripts/data/skill_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")

var _skill_service: SkillLevelUpService
var _passed: int = 0
var _failed: int = 0
var _messages: Array[String] = []

func run_tests() -> Dictionary:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		tree.root.add_child(self)

	_setup()

	_test_exp_to_next_level_lvl_1()
	_test_exp_to_next_level_lvl_2()
	_test_exp_to_next_level_lvl_3()
	_test_exp_to_next_level_lvl_4()
	_test_exp_to_next_level_max_level_returns_0()
	_test_exp_to_next_level_beyond_max_returns_0()
	_test_add_exp_increases_skill_exp()
	_test_add_exp_triggers_level_up()
	_test_add_exp_level_up_resets_exp()
	_test_add_exp_multiple_level_ups()
	_test_add_exp_caps_at_max_level()
	_test_add_exp_invalid_unit_returns_false()
	_test_add_exp_invalid_skill_id_returns_false()
	_test_add_exp_zero_amount_returns_false()
	_test_get_skill_level_returns_current()
	_test_get_skill_level_unknown_skill_returns_1()
	_test_get_skill_exp_returns_current()
	_test_get_skill_exp_unknown_skill_returns_0()
	_test_level_up_increases_level()
	_test_level_up_at_max_returns_false()
	_test_get_exp_remaining_calculation()
	_test_get_exp_remaining_at_max_level()
	_test_get_effective_power_default_modifier()
	_test_get_effective_power_override()
	_test_reset_skill_restores_initial()
	_test_skill_data_exp_curve_lvl1()
	_test_skill_data_exp_curve_lvl4()
	_test_skill_data_exp_to_next_level_method()
	_test_skill_data_exp_remaining_method()
	_test_skill_data_is_max_level()
	_test_skill_data_is_max_level_false()

	_teardown()

	if tree:
		tree.root.remove_child(self)

	return {
		"passed": _passed,
		"failed": _failed,
		"total": _passed + _failed,
		"messages": _messages
	}

func _setup() -> void:
	_skill_service = SkillLevelUpService.new()
	_skill_service.name = "SkillLevelUpService"
	add_child(_skill_service)

func _teardown() -> void:
	for child in get_children():
		if is_instance_valid(child):
			child.queue_free()

func _create_skill_data(
	skill_id: StringName = &"test_skill",
	skill_level: int = 1,
	skill_exp: int = 0
) -> SkillData:
	var skill := SkillData.new()
	skill.skill_id = skill_id
	skill.display_name = String(skill_id)
	skill.range = 1
	skill.power_modifier = 0
	skill.skill_level = skill_level
	skill.skill_exp = skill_exp
	return skill

func _create_unit_data_with_skill(unit_id: StringName, skill: SkillData) -> UnitData:
	var data := UnitData.new()
	data.unit_id = unit_id
	data.display_name = String(unit_id)
	data.faction = "ally"
	data.max_hp = 50
	data.attack = 10
	data.defense = 5
	data.movement = 3
	data.attack_range = 1
	data.default_skill = skill
	data.skills = [skill]
	return data

func _create_unit_actor_with_skill(unit_data: UnitData, grid_pos: Vector2i = Vector2i.ZERO) -> UnitActor:
	var actor := UNIT_SCENE.instantiate() as UnitActor
	actor.name = String(unit_data.unit_id)
	add_child(actor)
	actor.setup_from_data(unit_data)
	actor.set_grid_position(grid_pos)
	return actor

func _assert_eq(a, b, msg: String) -> void:
	if a == b:
		_passed += 1
	else:
		_failed += 1
		_messages.append("FAIL: %s | expected %s, got %s" % [msg, str(b), str(a)])

func _assert_true(v, msg: String) -> void:
	if v:
		_passed += 1
	else:
		_failed += 1
		_messages.append("FAIL: %s | expected true, got %s" % [msg, str(v)])

func _assert_false(v, msg: String) -> void:
	if not v:
		_passed += 1
	else:
		_failed += 1
		_messages.append("FAIL: %s | expected false, got %s" % [msg, str(v)])

func _test_exp_to_next_level_lvl_1() -> void:
	_assert_eq(_skill_service.exp_to_next_level(1), 30, "Level 1→2 requires 30 EXP")

func _test_exp_to_next_level_lvl_2() -> void:
	_assert_eq(_skill_service.exp_to_next_level(2), 60, "Level 2→3 requires 60 EXP")

func _test_exp_to_next_level_lvl_3() -> void:
	_assert_eq(_skill_service.exp_to_next_level(3), 100, "Level 3→4 requires 100 EXP")

func _test_exp_to_next_level_lvl_4() -> void:
	_assert_eq(_skill_service.exp_to_next_level(4), 150, "Level 4→5 requires 150 EXP")

func _test_exp_to_next_level_max_level_returns_0() -> void:
	_assert_eq(_skill_service.exp_to_next_level(5), 0, "Max level should return 0 EXP needed")

func _test_exp_to_next_level_beyond_max_returns_0() -> void:
	_assert_eq(_skill_service.exp_to_next_level(10), 0, "Beyond max level should return 0")

func _test_add_exp_increases_skill_exp() -> void:
	var skill := _create_skill_data(&"slash")
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	var result: bool = _skill_service.add_exp(unit, &"slash", 10)
	_assert_eq(skill.skill_exp, 10, "Skill EXP should increase by 10")
	_assert_false(result, "Should not level up with 10 EXP")

func _test_add_exp_triggers_level_up() -> void:
	var skill := _create_skill_data(&"slash")
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	var result: bool = _skill_service.add_exp(unit, &"slash", 30)
	_assert_true(result, "Should return true when leveled up")
	_assert_eq(skill.skill_level, 2, "Skill should be level 2")

func _test_add_exp_level_up_resets_exp() -> void:
	var skill := _create_skill_data(&"slash")
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	_skill_service.add_exp(unit, &"slash", 35)
	_assert_eq(skill.skill_exp, 5, "After level up, EXP should be 5 (35 - 30 threshold)")

func _test_add_exp_multiple_level_ups() -> void:
	var skill := _create_skill_data(&"slash")
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	var result: bool = _skill_service.add_exp(unit, &"slash", 90)
	_assert_true(result, "Should level up")
	_assert_eq(skill.skill_level, 3, "Should be level 3")
	_assert_eq(skill.skill_exp, 0, "EXP should be 0 after exact level ups")

func _test_add_exp_caps_at_max_level() -> void:
	var skill := _create_skill_data(&"slash", 5)
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	var result: bool = _skill_service.add_exp(unit, &"slash", 100)
	_assert_false(result, "Should not level up at max")
	_assert_eq(skill.skill_level, 5, "Should still be level 5")

func _test_add_exp_invalid_unit_returns_false() -> void:
	var result: bool = _skill_service.add_exp(null, &"slash", 10)
	_assert_false(result, "Should return false for null unit")

func _test_add_exp_invalid_skill_id_returns_false() -> void:
	var skill := _create_skill_data(&"slash")
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	var result: bool = _skill_service.add_exp(unit, &"nonexistent", 10)
	_assert_false(result, "Should return false for non-existent skill")

func _test_add_exp_zero_amount_returns_false() -> void:
	var skill := _create_skill_data(&"slash")
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	_assert_false(_skill_service.add_exp(unit, &"slash", 0), "Zero EXP should return false")
	_assert_false(_skill_service.add_exp(unit, &"slash", -5), "Negative EXP should return false")

func _test_get_skill_level_returns_current() -> void:
	var skill := _create_skill_data(&"slash", 3)
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	_assert_eq(_skill_service.get_skill_level(unit, &"slash"), 3, "Skill level should be 3")

func _test_get_skill_level_unknown_skill_returns_1() -> void:
	var skill := _create_skill_data(&"slash")
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	_assert_eq(_skill_service.get_skill_level(unit, &"nonexistent"), 1, "Unknown skill should return level 1")

func _test_get_skill_exp_returns_current() -> void:
	var skill := _create_skill_data(&"slash", 2, 25)
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	_assert_eq(_skill_service.get_skill_exp(unit, &"slash"), 25, "Skill EXP should be 25")

func _test_get_skill_exp_unknown_skill_returns_0() -> void:
	var skill := _create_skill_data(&"slash")
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	_assert_eq(_skill_service.get_skill_exp(unit, &"nonexistent"), 0, "Unknown skill should return 0 EXP")

func _test_level_up_increases_level() -> void:
	var skill := _create_skill_data(&"slash", 1)
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	var result: bool = _skill_service.level_up(unit, &"slash")
	_assert_true(result, "Level up should succeed")
	_assert_eq(skill.skill_level, 2, "Skill should be level 2")

func _test_level_up_at_max_returns_false() -> void:
	var skill := _create_skill_data(&"slash", 5)
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	var result: bool = _skill_service.level_up(unit, &"slash")
	_assert_false(result, "Level up at max should fail")
	_assert_eq(skill.skill_level, 5, "Should still be level 5")

func _test_get_exp_remaining_calculation() -> void:
	var skill := _create_skill_data(&"slash", 1, 10)
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	_assert_eq(_skill_service.get_exp_remaining(unit, &"slash"), 20, "Should need 20 more EXP to level up")

func _test_get_exp_remaining_at_max_level() -> void:
	var skill := _create_skill_data(&"slash", 5, 100)
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	_assert_eq(_skill_service.get_exp_remaining(unit, &"slash"), 0, "Max level should return 0 remaining EXP")

func _test_get_effective_power_default_modifier() -> void:
	var skill := _create_skill_data(&"slash", 3)
	skill.power_modifier = 5
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	_assert_eq(_skill_service.get_effective_power(unit, &"slash"), 5, "Effective power should be base modifier when no per-level override exists")

func _test_get_effective_power_override() -> void:
	var skill := _create_skill_data(&"slash", 3)
	skill.power_modifier = 5
	skill.power_modifier_by_level = {1: 0, 2: 1, 3: 2, 4: 3, 5: 5}
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	_assert_eq(_skill_service.get_effective_power(unit, &"slash"), 7, "Should add the level override to the base modifier for level 3")

func _test_reset_skill_restores_initial() -> void:
	var skill := _create_skill_data(&"slash", 3, 50)
	var unit := _create_unit_actor_with_skill(_create_unit_data_with_skill(&"ally_serin", skill))
	_skill_service.reset_skill(unit, &"slash")
	_assert_eq(skill.skill_level, 1, "Level should reset to 1")
	_assert_eq(skill.skill_exp, 0, "EXP should reset to 0")

func _test_skill_data_exp_curve_lvl1() -> void:
	_assert_eq(SkillData.EXP_CURVE.get(1), 30, "EXP curve at 1 should be 30")

func _test_skill_data_exp_curve_lvl4() -> void:
	_assert_eq(SkillData.EXP_CURVE.get(4), 150, "EXP curve at 4 should be 150")

func _test_skill_data_exp_to_next_level_method() -> void:
	var skill := _create_skill_data(&"slash", 1)
	_assert_eq(skill.exp_to_next_level(1), 30, "exp_to_next_level(1) should return 30")

func _test_skill_data_exp_remaining_method() -> void:
	var skill := _create_skill_data(&"slash", 2, 30)
	_assert_eq(skill.exp_remaining(), 30, "exp_remaining should be 30")

func _test_skill_data_is_max_level() -> void:
	var skill := _create_skill_data(&"slash", 5)
	_assert_true(skill.is_max_level(), "Level 5 should be max")

func _test_skill_data_is_max_level_false() -> void:
	var skill := _create_skill_data(&"slash", 4)
	_assert_false(skill.is_max_level(), "Level 4 should not be max")
