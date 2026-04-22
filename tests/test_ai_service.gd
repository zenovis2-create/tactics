extends Node

## Standalone AIService unit tests (no GUT dependency)
## Run with: load("res://tests/test_ai_service.gd").new().run_tests()

const AIService = preload("res://scripts/battle/ai_service.gd")
const PathService = preload("res://scripts/battle/path_service.gd")
const RangeService = preload("res://scripts/battle/range_service.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const ClassData = preload("res://scripts/data/class_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")

var _ai: AIService
var _path_service: PathService
var _range_service: RangeService
var _passed: int = 0
var _failed: int = 0
var _messages: Array[String] = []

func run_tests() -> Dictionary:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		tree.root.add_child(self)

	_setup()

	_test_in_range_ai_prefers_lethal_target()
	_test_move_attack_ai_prefers_better_damage_target()
	_test_threat_aware_ai_prefers_finishing_exposed_attacker()
	_test_move_wait_when_path_is_longer_than_movement()
	_test_wait_when_no_target_and_no_path()
	_test_sleep_forces_wait()
	_test_commander_support_holds_objective()
	_test_commander_support_approaches_objective()
	_test_last_seen_cell_guides_hidden_target_search()

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
	_ai = AIService.new()
	_ai.name = "AIService"
	add_child(_ai)

	_path_service = PathService.new()
	_path_service.name = "PathService"
	add_child(_path_service)

	_range_service = RangeService.new()
	_range_service.name = "RangeService"
	add_child(_range_service)

func _teardown() -> void:
	for child in get_children():
		if is_instance_valid(child):
			child.queue_free()

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

func _configure_stage(grid_size: Vector2i = Vector2i(8, 8), blocked_cells: Array = []) -> void:
	var stage := StageData.new()
	stage.grid_size = grid_size
	stage.cell_size = Vector2i(64, 64)
	stage.blocked_cells.clear()
	for cell in blocked_cells:
		stage.blocked_cells.append(cell)
	_path_service.configure_from_stage(stage)

func _make_actor(unit_id: StringName, faction: String, hp: int, attack: int, defense: int, movement: int, attack_range: int, grid_position: Vector2i, class_id: StringName = &"", class_label: String = "") -> UnitActor:
	var actor := UNIT_SCENE.instantiate() as UnitActor
	actor.setup_from_data(_make_unit_data(unit_id, faction, hp, attack, defense, movement, attack_range, class_id, class_label))
	actor.set_grid_position(grid_position)
	add_child(actor)
	return actor

func _make_unit_data(unit_id: StringName, faction: String, hp: int, attack: int, defense: int, movement: int, attack_range: int, class_id: StringName = &"", class_label: String = "") -> UnitData:
	var unit_data := UnitData.new()
	unit_data.unit_id = unit_id
	unit_data.display_name = String(unit_id)
	unit_data.faction = faction
	unit_data.max_hp = hp
	unit_data.attack = attack
	unit_data.defense = defense
	unit_data.movement = movement
	unit_data.attack_range = attack_range
	if class_id != &"" or not class_label.is_empty():
		var class_data := ClassData.new()
		class_data.class_id = class_id if class_id != &"" else &"class"
		class_data.display_name = class_label if not class_label.is_empty() else String(class_data.class_id)
		unit_data.class_data = class_data
	return unit_data

func _test_in_range_ai_prefers_lethal_target() -> void:
	_configure_stage()
	var enemy := _make_actor(&"enemy_raider", "enemy", 10, 4, 0, 3, 1, Vector2i(1, 1))
	var tank := _make_actor(&"ally_tank", "ally", 10, 1, 2, 3, 1, Vector2i(1, 2))
	var fragile := _make_actor(&"ally_fragile", "ally", 2, 1, 0, 3, 1, Vector2i(2, 1))
	var action := _ai.pick_action(enemy, [tank, fragile], _path_service, _range_service)
	_assert_eq(String(action.get("type", "")), "attack", "AI should choose an immediate attack when a target is in range")
	_assert_true(action.get("target", null) == fragile, "AI should prefer the in-range lethal target")

func _test_move_attack_ai_prefers_better_damage_target() -> void:
	_configure_stage(Vector2i(6, 6))
	var enemy := _make_actor(&"enemy_striker", "enemy", 10, 5, 0, 3, 1, Vector2i(0, 2))
	var armored := _make_actor(&"ally_armored", "ally", 10, 1, 4, 3, 1, Vector2i(3, 2))
	var exposed := _make_actor(&"ally_exposed", "ally", 5, 1, 0, 3, 1, Vector2i(3, 3))
	var action := _ai.pick_action(enemy, [armored, exposed], _path_service, _range_service)
	_assert_eq(String(action.get("type", "")), "move_attack", "AI should choose move_attack when an attack tile is reachable")
	_assert_true(action.get("target", null) == exposed, "AI should prefer the reachable higher-damage target")

func _test_threat_aware_ai_prefers_finishing_exposed_attacker() -> void:
	_configure_stage()
	var enemy := _make_actor(&"enemy_guard", "enemy", 12, 4, 0, 3, 1, Vector2i(2, 2))
	var bruiser := _make_actor(&"ally_bruiser", "ally", 8, 4, 0, 3, 1, Vector2i(2, 3))
	var support := _make_actor(&"ally_support", "ally", 6, 1, 0, 3, 1, Vector2i(3, 2))
	var action := _ai.pick_action(enemy, [bruiser, support], _path_service, _range_service)
	_assert_eq(String(action.get("type", "")), "attack", "Threat-aware AI should still take the immediate legal attack")
	_assert_true(action.get("target", null) == bruiser, "AI should prefer the higher-threat target")

func _test_move_wait_when_path_is_longer_than_movement() -> void:
	_configure_stage(Vector2i(8, 8))
	var enemy := _make_actor(&"enemy_scout", "enemy", 10, 3, 0, 2, 1, Vector2i(0, 0))
	var far_target := _make_actor(&"ally_far", "ally", 10, 2, 0, 3, 1, Vector2i(6, 0))
	var action := _ai.pick_action(enemy, [far_target], _path_service, _range_service)
	_assert_eq(String(action.get("type", "")), "move_wait", "AI should choose move_wait when the path to attack exceeds movement")
	_assert_eq(action.get("move_to", Vector2i.ZERO), Vector2i(2, 0), "AI should truncate the path to its movement budget")

func _test_wait_when_no_target_and_no_path() -> void:
	_configure_stage(Vector2i(4, 4), [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)])
	var enemy := _make_actor(&"enemy_trapped", "enemy", 10, 3, 0, 2, 1, Vector2i(0, 0))
	var target := _make_actor(&"ally_far", "ally", 10, 2, 0, 3, 1, Vector2i(3, 3))
	var action := _ai.pick_action(enemy, [target], _path_service, _range_service)
	_assert_eq(String(action.get("type", "")), "wait", "AI should wait when no legal path exists to any target")

func _test_sleep_forces_wait() -> void:
	_configure_stage()
	var enemy := _make_actor(&"enemy_raider", "enemy", 10, 4, 0, 3, 1, Vector2i(1, 1), &"cls_vanguard", "Vanguard")
	enemy.set_status_visual_state({"sleep_turns": 1})
	var target := _make_actor(&"ally_front", "ally", 8, 2, 0, 3, 1, Vector2i(1, 2), &"cls_vanguard", "Vanguard")
	var action := _ai.pick_action(enemy, [target], _path_service, _range_service)
	_assert_eq(String(action.get("type", "")), "wait", "Sleeping AI should always wait")

func _test_commander_support_holds_objective() -> void:
	_configure_stage(Vector2i(6, 6))
	var enemy := _make_actor(&"enemy_commander", "enemy", 12, 4, 0, 3, 1, Vector2i(2, 2), &"cls_knight", "Knight")
	var target := _make_actor(&"ally_front", "ally", 8, 3, 0, 3, 1, Vector2i(4, 2), &"cls_vanguard", "Vanguard")
	var action := _ai.pick_action(enemy, [target], _path_service, _range_service, {}, {"objective_cell": Vector2i(2, 2)})
	_assert_eq(String(action.get("type", "")), "wait", "Commander-support should hold a claimed objective")

func _test_commander_support_approaches_objective() -> void:
	_configure_stage(Vector2i(8, 6))
	var enemy := _make_actor(&"enemy_commander", "enemy", 12, 4, 0, 3, 1, Vector2i(0, 2), &"cls_knight", "Knight")
	var target := _make_actor(&"ally_backline", "ally", 8, 2, 0, 3, 2, Vector2i(7, 2), &"cls_ranger", "Ranger")
	var action := _ai.pick_action(enemy, [target], _path_service, _range_service, {}, {"objective_cell": Vector2i(3, 2)})
	_assert_eq(String(action.get("type", "")), "move_wait", "Commander-support should approach an unclaimed objective before chasing")
	_assert_eq(action.get("move_to", Vector2i(-1, -1)), Vector2i(3, 2), "Commander-support should bias movement toward the objective cell")

func _test_last_seen_cell_guides_hidden_target_search() -> void:
	_configure_stage(Vector2i(7, 5))
	var enemy := _make_actor(&"enemy_raider", "enemy", 12, 4, 0, 4, 1, Vector2i(0, 2), &"cls_vanguard", "Vanguard")
	var hidden := _make_actor(&"ally_stealth", "ally", 8, 3, 0, 3, 1, Vector2i(5, 2), &"cls_ranger", "Ranger")
	hidden.set_status_visual_state({"stealth_turns": 2})
	var action := _ai.pick_action(enemy, [hidden], _path_service, _range_service, {}, {"last_seen_cells": {String(hidden.unit_data.unit_id): Vector2i(4, 2)}})
	_assert_eq(String(action.get("type", "")), "move_wait", "AI should use last-seen data when stealth hides the target")
	_assert_eq(action.get("move_to", Vector2i(-1, -1)), Vector2i(3, 2), "AI should move toward the last-seen attack approach tile")
