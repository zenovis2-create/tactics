extends Node

## Standalone CombatService unit tests (no GUT dependency)
## Run with: load("res://tests/test_combat_service.gd").new().run_tests()

const CombatService = preload("res://scripts/battle/combat_service.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const SkillData = preload("res://scripts/data/skill_data.gd")
const WeaponData = preload("res://scripts/data/weapon_data.gd")
const StatusService = preload("res://scripts/battle/status_service.gd")
const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")

var _combat: CombatService
var _status: StatusService
var _passed: int = 0
var _failed: int = 0
var _messages: Array[String] = []

func run_tests() -> Dictionary:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		tree.root.add_child(self)

	_setup()

	_test_hit_check_no_penalty()
	_test_hit_check_oblivion_penalty_miss()
	_test_guard_calc_basic()
	_test_guard_calc_minimum_one()
	_test_guard_calc_with_bond_bonus()
	_test_counterattack_in_range()
	_test_counterattack_out_of_range()
	_test_counterattack_defeated_defender()

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
	_status = StatusService.new()
	_status.name = "StatusService"
	add_child(_status)

	_combat = CombatService.new()
	_combat.name = "CombatService"
	add_child(_combat)

func _teardown() -> void:
	for child in get_children():
		if is_instance_valid(child):
			child.queue_free()

func _create_unit_data(
	unit_id: StringName = &"unit_test",
	display_name: String = "TestUnit",
	faction: String = "ally",
	max_hp: int = 50,
	attack: int = 10,
	defense: int = 5,
	movement: int = 3,
	attack_range: int = 1
) -> UnitData:
	var data := UnitData.new()
	data.unit_id = unit_id
	data.display_name = display_name
	data.faction = faction
	data.max_hp = max_hp
	data.attack = attack
	data.defense = defense
	data.movement = movement
	data.attack_range = attack_range
	return data

func _create_skill_data(
	skill_id: StringName = &"test_skill",
	power_modifier: int = 0,
	range_val: int = 1
) -> SkillData:
	var skill := SkillData.new()
	skill.skill_id = skill_id
	skill.display_name = String(skill_id)
	skill.power_modifier = power_modifier
	skill.range = range_val
	skill.status_chance = 1.0
	return skill

func _create_weapon_data(attack_bonus: int = 0, defense_bonus: int = 0) -> WeaponData:
	var weapon := WeaponData.new()
	weapon.weapon_id = &"test_weapon"
	weapon.weapon_type = &"Sword"
	weapon.display_name = "Test Weapon"
	weapon.attack_bonus = attack_bonus
	weapon.defense_bonus = defense_bonus
	weapon.tier = 0
	return weapon

func _create_unit_actor(unit_data: UnitData, grid_pos: Vector2i = Vector2i.ZERO, weapon: WeaponData = null) -> UnitActor:
	var actor := UNIT_SCENE.instantiate() as UnitActor
	actor.name = String(unit_data.unit_id)
	add_child(actor)
	actor.setup_from_data(unit_data)
	actor.set_grid_position(grid_pos)
	if weapon != null:
		actor.set_equipped_weapon(weapon)
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

# --- Hit Check Tests ---

func _test_hit_check_no_penalty() -> void:
	var attacker := _create_unit_actor(_create_unit_data())
	var defender := _create_unit_actor(_create_unit_data())
	var result: Dictionary = _combat._step_hit_check(attacker, defender, null, {})
	_assert_true(result.get("hit", false), "Hit check without penalty should hit")
	_assert_eq(result.get("hit_chance"), 100, "Hit chance without penalty should be 100")

func _test_hit_check_oblivion_penalty_miss() -> void:
	var attacker := _create_unit_actor(_create_unit_data())
	var defender := _create_unit_actor(_create_unit_data())
	var context: Dictionary = {"oblivion_accuracy_mod": -100}
	var result: Dictionary = _combat._step_hit_check(attacker, defender, null, context)
	_assert_false(result.get("hit", true), "Hit check with -100 oblivion mod should miss")
	_assert_eq(result.get("hit_chance"), 0, "Hit chance should be 0")
	_assert_eq(result.get("reason"), "oblivion_accuracy_zero", "Miss reason should be oblivion_accuracy_zero")

# --- Guard Calc Tests ---

func _test_guard_calc_basic() -> void:
	var attacker := _create_unit_actor(_create_unit_data(&"atk", "Attacker", "ally", 50, 10, 5))
	var defender := _create_unit_actor(_create_unit_data(&"def", "Defender", "enemy", 50, 4, 5))
	var result: Dictionary = _combat._step_guard_calc(attacker, defender, null, {})
	_assert_eq(result.get("damage"), 5, "Guard calc: ATK 10 - DEF 5 = 5 damage")
	_assert_eq(result.get("attack_value"), 10, "Attack value should be 10")
	_assert_eq(result.get("defense_value"), 5, "Defense value should be 5")

func _test_guard_calc_minimum_one() -> void:
	var attacker := _create_unit_actor(_create_unit_data(&"atk", "Attacker", "ally", 50, 2, 1))
	var defender := _create_unit_actor(_create_unit_data(&"def", "Defender", "enemy", 50, 10, 20))
	var result: Dictionary = _combat._step_guard_calc(attacker, defender, null, {})
	_assert_eq(result.get("damage"), 1, "Guard calc should floor damage at 1")

func _test_guard_calc_with_bond_bonus() -> void:
	var attacker := _create_unit_actor(_create_unit_data(&"atk", "Attacker", "ally", 50, 10, 5))
	var defender := _create_unit_actor(_create_unit_data(&"def", "Defender", "enemy", 50, 4, 5))
	var context: Dictionary = {"bond_attack_bonus": 3}
	var result: Dictionary = _combat._step_guard_calc(attacker, defender, null, context)
	_assert_eq(result.get("damage"), 8, "Guard calc with bond bonus 3: ATK 10 + 3 - DEF 5 = 8")

# --- Counterattack Tests ---

func _test_counterattack_in_range() -> void:
	var attacker := _create_unit_actor(_create_unit_data(&"atk", "Attacker", "ally", 50, 10, 5), Vector2i(0, 0))
	var defender := _create_unit_actor(_create_unit_data(&"def", "Defender", "enemy", 50, 8, 4, 3, 1), Vector2i(1, 0))
	var trace: Array = []
	var result: Dictionary = _combat._resolve_counterattack(attacker, defender, {}, trace)
	_assert_true(result.get("triggered", false), "Counterattack should trigger when in range")
	_assert_eq(result.get("reason"), "counterattack_resolved", "Counter reason should be resolved")
	# Counter damage: defender ATK 8 - attacker DEF 5 = 3
	_assert_eq(result.get("damage"), 3, "Counterattack damage should be 3")

func _test_counterattack_out_of_range() -> void:
	var attacker := _create_unit_actor(_create_unit_data(&"atk", "Attacker", "ally", 50, 10, 5), Vector2i(0, 0))
	var defender := _create_unit_actor(_create_unit_data(&"def", "Defender", "enemy", 50, 8, 4, 3, 1), Vector2i(5, 0))
	var trace: Array = []
	var result: Dictionary = _combat._resolve_counterattack(attacker, defender, {}, trace)
	_assert_false(result.get("triggered", true), "Counterattack should NOT trigger out of range")
	_assert_eq(result.get("reason"), "counterattack_out_of_range", "Counter reason should be out_of_range")

func _test_counterattack_defeated_defender() -> void:
	var attacker := _create_unit_actor(_create_unit_data(&"atk", "Attacker", "ally", 50, 10, 5), Vector2i(0, 0))
	var defender := _create_unit_actor(_create_unit_data(&"def", "Defender", "enemy", 50, 8, 4, 3, 1), Vector2i(1, 0))
	defender.current_hp = 0
	var trace: Array = []
	var result: Dictionary = _combat._resolve_counterattack(attacker, defender, {}, trace)
	_assert_false(result.get("triggered", true), "Counterattack should NOT trigger when defender is defeated")
	_assert_eq(result.get("reason"), "counterattack_unavailable", "Counter reason should be unavailable")
