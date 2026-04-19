extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const SaveService = preload("res://scripts/battle/save_service.gd")
const BattlefieldEvolution = preload("res://scripts/battle/battlefield_evolution.gd")
const EvolutionEvent = preload("res://scripts/battle/evolution_event.gd")
const CH06_STAGE = preload("res://data/stages/ch06_01_stage.tres")
const CH08_STAGE = preload("res://data/stages/ch08_01_stage.tres")

const SLOT_ID := 6

var _failed: bool = false
var _observed_signal_count: int = 0
var _observed_event_id: String = ""
var _observed_tiles: Array = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame
	save_service.delete_slot(SLOT_ID)

	await _assert_ch06_castle_siege(save_service)
	if _failed:
		return

	await _assert_ch08_fallen_tree(save_service)
	if _failed:
		return
	var evolution := _get_evolution()
	if evolution != null:
		evolution.clear_battlefield()
	save_service.queue_free()
	await process_frame
	await process_frame

	print("[PASS] evolving_battlefield_runner: all assertions passed.")
	quit(0)

func _assert_ch06_castle_siege(save_service: SaveService) -> void:
	var battle = await _boot_battle(CH06_STAGE, save_service)
	if _failed:
		return
	var evolution := _get_evolution()
	if evolution == null:
		_fail("Evolution autoload was not available for the CH06 check.")
		return

	evolution.reset()
	_reset_signal_capture()
	var castle_event: EvolutionEvent = null
	for event in evolution.build_predefined_events_for_stage(CH06_STAGE.stage_id):
		if event.trigger_turn == 5:
			castle_event = event
			break
	if castle_event == null:
		_fail("CH06 predefined castle siege event was not generated.")
		return

	var event_callback := Callable(self, "_on_evolution_occurred")
	if not evolution.evolution_occurred.is_connected(event_callback):
		evolution.evolution_occurred.connect(event_callback)
	evolution.register_event(castle_event)

	await _advance_turns(battle, evolution, 5)

	if evolution.evolution_occurred.is_connected(event_callback):
		evolution.evolution_occurred.disconnect(event_callback)

	_assert_true(_observed_signal_count > 0, "CH06 castle siege should emit the evolution_occurred signal by turn 5.")
	if _failed:
		return
	_assert_equal(_observed_event_id, castle_event.event_id, "CH06 castle siege should emit the registered event id.")
	if _failed:
		return
	_assert_equal(_observed_tiles.size(), castle_event.tile_positions.size(), "CH06 castle siege should report every affected wall tile.")
	for tile in castle_event.tile_positions:
		_assert_equal(StringName(battle.stage_data.get_terrain_type(tile)), &"crumbling_debris", "CH06 outer wall tile should change into crumbling debris.")
		_assert_true(not battle.stage_data.blocked_cells.has(tile), "Destroyed CH06 wall tiles should no longer be blocked.")
	if _failed:
		return

	await _teardown_battle(battle)

func _assert_ch08_fallen_tree(save_service: SaveService) -> void:
	var battle = await _boot_battle(CH08_STAGE, save_service)
	if _failed:
		return
	var evolution := _get_evolution()
	if evolution == null:
		_fail("Evolution autoload was not available for the CH08 check.")
		return

	evolution.reset()
	_reset_signal_capture()
	var turn_three_event: EvolutionEvent = null
	for event in evolution.build_predefined_events_for_stage(CH08_STAGE.stage_id):
		if event.trigger_turn == 3:
			turn_three_event = event
			break
	if turn_three_event == null:
		_fail("CH08 turn-3 forest evolution event was not generated.")
		return

	var event_callback := Callable(self, "_on_evolution_occurred")
	if not evolution.evolution_occurred.is_connected(event_callback):
		evolution.evolution_occurred.connect(event_callback)
	evolution.register_event(turn_three_event)

	await _advance_turns(battle, evolution, 3)

	if evolution.evolution_occurred.is_connected(event_callback):
		evolution.evolution_occurred.disconnect(event_callback)

	_assert_equal(_observed_signal_count, 1, "CH08 turn-3 fallen tree event should fire exactly once.")
	var affected_tile: Vector2i = turn_three_event.tile_positions[0]
	_assert_true(battle.stage_data.blocked_cells.has(affected_tile), "CH08 fallen tree tile should become blocked.")
	_assert_equal(StringName(battle.stage_data.get_terrain_type(affected_tile)), &"fallen_tree", "CH08 fallen tree tile should change terrain type.")
	if _failed:
		return

	await _teardown_battle(battle)

func _boot_battle(stage_data, save_service: SaveService):
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame
	if battle.progression_service != null:
		battle.progression_service.load_data(save_service.load_progression(SLOT_ID))
	battle.set_stage(stage_data)
	await process_frame
	await process_frame
	await process_frame
	return battle

func _advance_turns(battle, evolution: BattlefieldEvolution, target_turn: int) -> void:
	while battle.round_index < target_turn and not _failed:
		battle.round_index += 1
		if battle.hud != null:
			battle.hud.set_round(battle.round_index)
		evolution.check_evolutions(battle.round_index)
		await process_frame
	if battle.round_index != target_turn and not _failed:
		_fail("Battle did not advance to turn %d for evolution verification." % target_turn)

func _teardown_battle(battle) -> void:
	if battle == null:
		return
	if battle.get_parent() != null:
		battle.get_parent().remove_child(battle)
	battle.free()
	await process_frame
	await process_frame
	await process_frame

func _get_evolution() -> BattlefieldEvolution:
	return root.get_node_or_null("Evolution") as BattlefieldEvolution

func _reset_signal_capture() -> void:
	_observed_signal_count = 0
	_observed_event_id = ""
	_observed_tiles.clear()

func _on_evolution_occurred(event_id, affected_tiles) -> void:
	_observed_signal_count += 1
	_observed_event_id = String(event_id)
	_observed_tiles = affected_tiles.duplicate(true)

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
