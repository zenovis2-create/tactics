extends SceneTree

const BattleController = preload("res://scripts/battle/battle_controller.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const FIRE_UNIT = preload("res://data/units/ally_melkion_ally.tres")
const ENEMY_UNIT = preload("res://data/units/enemy_skirmisher.tres")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle: BattleController = BATTLE_SCENE.instantiate() as BattleController
	if battle == null:
		_fail("Unable to instantiate BattleScene for flood stakes runner.")
		return
	root.add_child(battle)
	battle.set_stage(_build_stage())

	await process_frame
	await process_frame
	await process_frame

	var fire_unit = battle.ally_units[0]
	fire_unit.current_hp = 20

	var snapshot: Dictionary = battle.get_flood_state_snapshot()
	_assert_equal(int(snapshot.get("expansion_turns", -1)), 0, "Flood should start unexpanded.")
	_assert_true(_cells_has(snapshot.get("flood_zone_positions", []), Vector2i(4, 4)), "Initial water seed should be tracked as a flood zone.")
	if _failed:
		return

	await _advance_round(battle, 2)
	_assert_hp(fire_unit, 15, "Fire unit should take drowning damage after the first round.")
	snapshot = battle.get_flood_state_snapshot()
	_assert_equal(int(snapshot.get("expansion_turns", -1)), 1, "Flood should expand once after round one.")
	_assert_true(_cells_has(snapshot.get("flood_zone_positions", []), Vector2i(4, 3)), "Flood should expand one tile north on round one.")
	if _failed:
		return

	await _advance_round(battle, 3)
	_assert_hp(fire_unit, 10, "Fire unit should take drowning damage after the second round.")
	_assert_equal(StringName(battle.stage_data.get_terrain_type(Vector2i(2, 3))), &"plain", "Adjacent fire terrain should be extinguished when the flood reaches its neighbor.")
	_assert_equal(StringName(battle.stage_data.get_terrain_type(Vector2i(4, 2))), &"mountain", "Mountain terrain must remain unflooded.")
	_assert_equal(StringName(battle.stage_data.get_terrain_type(Vector2i(6, 4))), &"cave", "Cave terrain must remain unflooded.")
	if _failed:
		return

	await _advance_round(battle, 4)
	_assert_hp(fire_unit, 5, "Fire unit should take drowning damage after the third round.")
	snapshot = battle.get_flood_state_snapshot()
	_assert_equal(int(snapshot.get("expansion_turns", -1)), 3, "Flood expansion should cap at three turns.")
	_assert_true(_cells_has(snapshot.get("flood_zone_positions", []), Vector2i(1, 4)), "Flood should continue expanding outward by the third round.")
	_assert_true(_cells_has(snapshot.get("flood_margin_positions", []), Vector2i(1, 4)), "Flood margin positions should track the live flood edge.")
	if _failed:
		return

	print("[PASS] flood_stakes_runner: flood expansion, extinguish behavior, and drowning damage validated.")
	quit(0)

func _build_stage() -> StageData:
	var stage := StageData.new()
	stage.stage_id = &"RUNNER_FLOOD_STAKES"
	stage.stage_title = "Flood Stakes Runner"
	stage.weather_id = &"downpour"
	stage.grid_size = Vector2i(12, 12)
	stage.cell_size = Vector2i(64, 64)
	stage.ally_units = [FIRE_UNIT]
	stage.enemy_units = [ENEMY_UNIT]
	stage.ally_spawns = [Vector2i(4, 4)]
	stage.enemy_spawns = [Vector2i(11, 11)]
	stage.terrain_move_costs = {
		Vector2i(4, 4): 2,
		Vector2i(4, 2): 3,
		Vector2i(6, 4): 3,
		Vector2i(2, 3): 2
	}
	stage.terrain_types = {
		Vector2i(4, 4): &"water",
		Vector2i(4, 2): &"mountain",
		Vector2i(6, 4): &"cave",
		Vector2i(2, 3): &"fire"
	}
	stage.terrain_defense_bonuses = {
		Vector2i(4, 4): 1,
		Vector2i(4, 2): 1,
		Vector2i(6, 4): 1,
		Vector2i(2, 3): 1
	}
	stage.win_condition = &"defeat_all_enemies"
	stage.loss_condition = &"all_allies_defeated"
	return stage

func _advance_round(battle: BattleController, expected_round: int) -> void:
	battle._end_player_phase("runner_round_%d" % expected_round)
	var frames_waited: int = 0
	while battle.round_index < expected_round and frames_waited < 30:
		await process_frame
		frames_waited += 1
	if battle.round_index < expected_round:
		_fail("Battle did not advance to round %d in time." % expected_round)

func _assert_hp(unit, expected_hp: int, message: String) -> void:
	if unit == null or not is_instance_valid(unit):
		_fail("%s Unit is no longer valid." % message)
		return
	_assert_equal(unit.current_hp, expected_hp, message)

func _cells_has(cells: Array, target: Vector2i) -> bool:
	for cell in cells:
		if cell == target:
			return true
	return false

func _assert_true(condition: bool, message: String) -> void:
	if condition:
		return
	_fail(message)

func _assert_equal(actual, expected, message: String) -> void:
	if actual == expected:
		return
	_fail("%s Expected %s, got %s." % [message, str(expected), str(actual)])

func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	quit(1)
