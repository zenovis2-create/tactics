extends SceneTree

const AIService = preload("res://scripts/battle/ai_service.gd")
const PathService = preload("res://scripts/battle/path_service.gd")
const RangeService = preload("res://scripts/battle/range_service.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ai := AIService.new()
	root.add_child(ai)
	var path_service := PathService.new()
	root.add_child(path_service)
	var range_service := RangeService.new()
	root.add_child(range_service)
	await process_frame

	if not _assert_in_range_ai_prefers_lethal_target(ai, path_service, range_service):
		return
	if not _assert_move_attack_ai_prefers_better_damage_target(ai, path_service, range_service):
		return

	print("[PASS] ai_depth_runner: AI scoring prefers stronger attack targets without breaking legality.")
	quit(0)

func _assert_in_range_ai_prefers_lethal_target(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var enemy := _make_actor(&"enemy_raider", "enemy", 10, 4, 0, 3, 1, Vector2i(1, 1))
	var tank := _make_actor(&"ally_tank", "ally", 10, 1, 2, 3, 1, Vector2i(1, 2))
	var fragile := _make_actor(&"ally_fragile", "ally", 2, 1, 0, 3, 1, Vector2i(2, 1))
	var action := ai.pick_action(enemy, [tank, fragile], path_service, range_service)
	enemy.queue_free()
	tank.queue_free()
	fragile.queue_free()
	if String(action.get("type", "")) != "attack":
		return _fail("AI should choose an immediate attack when targets are already in range.")
	var target = action.get("target", null)
	if target != fragile:
		return _fail("AI should prefer the in-range lethal target over the merely nearest durable target.")
	return true

func _assert_move_attack_ai_prefers_better_damage_target(ai: AIService, path_service: PathService, range_service: RangeService) -> bool:
	var stage := StageData.new()
	stage.grid_size = Vector2i(6, 6)
	stage.cell_size = Vector2i(64, 64)
	path_service.configure_from_stage(stage)
	var enemy := _make_actor(&"enemy_striker", "enemy", 10, 5, 0, 3, 1, Vector2i(0, 2))
	var armored := _make_actor(&"ally_armored", "ally", 10, 1, 4, 3, 1, Vector2i(3, 2))
	var exposed := _make_actor(&"ally_exposed", "ally", 5, 1, 0, 3, 1, Vector2i(3, 3))
	var action := ai.pick_action(enemy, [armored, exposed], path_service, range_service)
	enemy.queue_free()
	armored.queue_free()
	exposed.queue_free()
	if String(action.get("type", "")) != "move_attack":
		return _fail("AI should choose a move-attack plan when an attack tile is reachable this turn.")
	var target = action.get("target", null)
	if target != exposed:
		return _fail("AI should prefer the reachable higher-damage target when choosing a move-attack plan.")
	return true

func _make_actor(unit_id: StringName, faction: String, hp: int, attack: int, defense: int, movement: int, attack_range: int, grid_position: Vector2i) -> UnitActor:
	var actor := UnitActor.new()
	actor.unit_data = _make_unit_data(unit_id, faction, hp, attack, defense, movement, attack_range)
	actor.faction = faction
	actor.current_hp = hp
	actor.grid_position = grid_position
	return actor

func _make_unit_data(unit_id: StringName, faction: String, hp: int, attack: int, defense: int, movement: int, attack_range: int) -> UnitData:
	var unit_data := UnitData.new()
	unit_data.unit_id = unit_id
	unit_data.display_name = String(unit_id)
	unit_data.faction = faction
	unit_data.max_hp = hp
	unit_data.attack = attack
	unit_data.defense = defense
	unit_data.movement = movement
	unit_data.attack_range = attack_range
	return unit_data

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
