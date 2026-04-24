extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

var _failed: bool = false

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	main.start_game_direct()
	await process_frame
	await process_frame

	if not _assert_stage_loaded(main, &"CH01_02", "fresh new game should start on CH01_02"):
		return

	var live_data: ProgressionData = main.battle_controller.progression_service.get_data()
	live_data.burden = 2
	live_data.trust = 3
	live_data.gold = 444
	live_data.flags["flag_resonance_serin"] = true
	live_data.snapshot_unlock_state()

	main._on_save_requested(0)
	await process_frame

	var saved_data: ProgressionData = main._save_service.load_progression(0)
	if saved_data == null:
		return _fail("Main save flow should persist a loadable progression slot.")
	if saved_data.burden != 2 or saved_data.trust != 3 or saved_data.gold != 444:
		return _fail("Saved progression slot should preserve burden/trust/gold from the live battle state.")

	main._on_save_load_requested(0, saved_data)
	await process_frame
	await process_frame

	if not _assert_stage_loaded(main, &"CH01_02", "loading the saved slot should restore the same active stage"):
		return
	var loaded_data: ProgressionData = main.battle_controller.progression_service.get_data()
	if loaded_data == null:
		return _fail("Loaded game should restore live progression data into the battle controller.")
	if loaded_data.burden != 2 or loaded_data.trust != 3 or loaded_data.gold != 444:
		return _fail("Loaded progression should preserve saved burden/trust/gold values.")
	if not bool(loaded_data.flags.get("flag_resonance_serin", false)):
		return _fail("Loaded progression should preserve saved flags.")

	if not await _consume_one_loaded_action(main.battle_controller):
		return

	print("[PASS] save_load_core_loop_runner: main save/load restores battle state and the loaded battle can continue consuming player actions.")
	quit(0)

func _assert_stage_loaded(main: Node, expected_stage_id: StringName, context: String) -> bool:
	var snapshot: Dictionary = main.get_campaign_state_snapshot()
	if String(snapshot.get("mode", "")) != "battle":
		return _fail("%s: expected battle mode, got %s." % [context, String(snapshot.get("mode", ""))])
	if StringName(snapshot.get("current_stage_id", &"")) != expected_stage_id:
		return _fail("%s: expected stage %s, got %s." % [context, String(expected_stage_id), String(snapshot.get("current_stage_id", &""))])
	return true

func _consume_one_loaded_action(battle) -> bool:
	var ready_units: Array = _get_ready_ally_units(battle)
	if ready_units.is_empty():
		return _fail("Loaded battle should expose at least one ready ally for the player phase.")
	var unit = ready_units[0]
	battle._on_world_cell_pressed(unit.grid_position)
	await process_frame
	battle._on_wait_requested()
	await process_frame
	if battle.turn_manager.can_unit_act(unit):
		return _fail("Loaded battle should consume the selected unit's action package after Wait.")
	var snapshot_phase: int = int(battle.current_phase)
	if snapshot_phase != int(battle.BattlePhase.PLAYER_SELECT) and snapshot_phase != int(battle.BattlePhase.PLAYER_ACTION_PREVIEW) and snapshot_phase != int(battle.BattlePhase.PLAYER_PHASE_END):
		return _fail("Loaded battle should remain inside the live player-turn flow after consuming an action.")
	return true

func _get_ready_ally_units(battle) -> Array:
	var ready_units: Array = []
	for unit in battle.ally_units:
		if is_instance_valid(unit) and not unit.is_defeated() and battle.turn_manager.can_unit_act(unit):
			ready_units.append(unit)
	return ready_units

func _is_battle_finished(battle) -> bool:
	var phase: int = int(battle.current_phase)
	return phase == int(battle.BattlePhase.VICTORY) or phase == int(battle.BattlePhase.DEFEAT)

func _fail(message: String) -> bool:
	if _failed:
		return false
	_failed = true
	push_error(message)
	quit(1)
	return false
