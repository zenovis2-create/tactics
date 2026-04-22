extends Node

## Standalone StatusService unit tests (no GUT dependency)
## Run with: load("res://tests/test_status_service.gd").new().run_tests()

const StatusService = preload("res://scripts/battle/status_service.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")

var _service: StatusService
var _passed: int = 0
var _failed: int = 0
var _messages: Array[String] = []

func run_tests() -> Dictionary:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		tree.root.add_child(self)

	_setup()

	_test_oblivion_stack_1_accuracy_mod()
	_test_oblivion_stack_2_accuracy_mod()
	_test_oblivion_stack_3_accuracy_mod()
	_test_oblivion_stack_3_seals_skills()
	_test_tick_start_of_turn_decay()
	_test_cleanse_removes_status()
	_test_remove_unit_clears_stack()
	_test_reset_clears_all_stacks()
	_test_summary_counts_applied_and_cleansed()

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
	_service = StatusService.new()
	_service.name = "StatusService"
	add_child(_service)

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
	defense: int = 5
) -> UnitData:
	var data := UnitData.new()
	data.unit_id = unit_id
	data.display_name = display_name
	data.faction = faction
	data.max_hp = max_hp
	data.attack = attack
	data.defense = defense
	data.movement = 3
	data.attack_range = 1
	return data

func _create_unit_actor(unit_data: UnitData, grid_pos: Vector2i = Vector2i.ZERO) -> UnitActor:
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

# --- Oblivion Stack Tests ---

func _test_oblivion_stack_1_accuracy_mod() -> void:
	var unit := _create_unit_actor(_create_unit_data())
	_service.apply_stack(unit, 1, "test")
	var effects: Dictionary = _service.get_effects(unit)
	_assert_eq(effects.get("accuracy_mod"), -5, "Stack 1 should give accuracy_mod -5")

func _test_oblivion_stack_2_accuracy_mod() -> void:
	var unit := _create_unit_actor(_create_unit_data())
	_service.apply_stack(unit, 2, "test")
	var effects: Dictionary = _service.get_effects(unit)
	_assert_eq(effects.get("accuracy_mod"), -10, "Stack 2 should give accuracy_mod -10")
	_assert_eq(effects.get("evasion_mod"), -5, "Stack 2 should give evasion_mod -5")

func _test_oblivion_stack_3_accuracy_mod() -> void:
	var unit := _create_unit_actor(_create_unit_data())
	_service.apply_stack(unit, 3, "test")
	var effects: Dictionary = _service.get_effects(unit)
	_assert_eq(effects.get("accuracy_mod"), -15, "Stack 3 should give accuracy_mod -15")
	_assert_eq(effects.get("evasion_mod"), -10, "Stack 3 should give evasion_mod -10")

func _test_oblivion_stack_3_seals_skills() -> void:
	var unit := _create_unit_actor(_create_unit_data())
	_service.apply_stack(unit, 3, "test")
	var effects: Dictionary = _service.get_effects(unit)
	_assert_true(effects.get("skills_sealed", false), "Stack 3 should seal skills")
	_assert_true(_service.are_skills_sealed(unit), "are_skills_sealed should be true at stack 3")

# --- Decay Test ---

func _test_tick_start_of_turn_decay() -> void:
	var unit := _create_unit_actor(_create_unit_data())
	_service.apply_stack(unit, 3, "source")
	_service.tick_start_of_turn([unit], true)
	_assert_eq(_service.get_oblivion_stack(unit), 2, "tick_start_of_turn(decay=true) should reduce oblivion by 1")

# --- Cleanse Test ---

func _test_cleanse_removes_status() -> void:
	var unit := _create_unit_actor(_create_unit_data())
	_service.apply_stack(unit, 2, "enemy_attack")
	_assert_eq(_service.get_oblivion_stack(unit), 2, "Unit should have 2 oblivion stacks before cleanse")
	_service.cleanse_stack(unit, 2, "clarity")
	_assert_eq(_service.get_oblivion_stack(unit), 0, "Oblivion stack should be 0 after cleanse")

# --- Remove / Reset / Summary Tests ---

func _test_remove_unit_clears_stack() -> void:
	var unit := _create_unit_actor(_create_unit_data())
	_service.apply_stack(unit, 2, "source")
	_service.remove_unit(unit)
	_assert_eq(_service.get_oblivion_stack(unit), 0, "remove_unit should clear tracked oblivion stacks")

func _test_reset_clears_all_stacks() -> void:
	var unit_a := _create_unit_actor(_create_unit_data(&"unit_a"))
	var unit_b := _create_unit_actor(_create_unit_data(&"unit_b"))
	_service.apply_stack(unit_a, 1, "source")
	_service.apply_stack(unit_b, 3, "source")
	_service.reset()
	_assert_eq(_service.get_oblivion_stack(unit_a), 0, "reset should clear unit_a stack")
	_assert_eq(_service.get_oblivion_stack(unit_b), 0, "reset should clear unit_b stack")

func _test_summary_counts_applied_and_cleansed() -> void:
	var unit := _create_unit_actor(_create_unit_data())
	var baseline: Dictionary = _service.get_summary()
	_service.apply_stack(unit, 3, "source")
	_service.cleanse_stack(unit, 1, "clarity")
	var summary: Dictionary = _service.get_summary()
	_assert_eq(int(summary.get("total_applied", 0)) - int(baseline.get("total_applied", 0)), 3, "summary should count total applied oblivion stacks")
	_assert_eq(int(summary.get("total_cleansed", 0)) - int(baseline.get("total_cleansed", 0)), 1, "summary should count total cleansed oblivion stacks")
