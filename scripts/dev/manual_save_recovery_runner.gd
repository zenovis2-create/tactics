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
	live_data.burden = 6
	live_data.trust = 5
	live_data.gold = 777
	live_data.flags["flag_resonance_tia"] = true
	main._on_save_requested(0)
	await process_frame

	var saved_data: ProgressionData = main._save_service.load_progression(0)
	if saved_data == null:
		return _fail("Manual save recovery runner expected a loadable manual slot.")
	if saved_data.burden != 6 or saved_data.trust != 5 or saved_data.gold != 777:
		return _fail("Manual save slot should preserve burden/trust/gold before recovery.")

	live_data.burden = 0
	live_data.trust = 0
	live_data.gold = 1
	live_data.flags.erase("flag_resonance_tia")

	main.defeat_screen.show_defeat(3)
	await process_frame
	if not bool(main.defeat_screen.get_layout_snapshot().get("visible", false)):
		return _fail("Manual save recovery runner should enter the defeat surface before restoring a manual save.")

	main._on_load_last_save_requested(saved_data)
	await process_frame
	await process_frame

	if not _assert_stage_loaded(main, &"CH01_02", "manual save recovery should restore the same active stage"):
		return
	var recovered_data: ProgressionData = main.battle_controller.progression_service.get_data()
	if recovered_data == null:
		return _fail("Manual save recovery should restore live progression data into battle.")
	if recovered_data.burden != 6 or recovered_data.trust != 5 or recovered_data.gold != 777:
		return _fail("Manual save recovery should restore the persisted burden/trust/gold values.")
	if not bool(recovered_data.flags.get("flag_resonance_tia", false)):
		return _fail("Manual save recovery should preserve the saved distinguishing flag.")
	if bool(main.defeat_screen.get_layout_snapshot().get("visible", true)):
		return _fail("Manual save recovery should hide the defeat screen after restoring the saved state.")

	if not await _consume_one_loaded_action(main.battle_controller):
		return

	print("[PASS] manual_save_recovery_runner: manual save recovery restores battle state and remains playable.")
	quit(0)

func _assert_stage_loaded(main: Node, expected_stage_id: StringName, context: String) -> bool:
	var snapshot: Dictionary = main.get_campaign_state_snapshot()
	if String(snapshot.get("mode", "")) != "battle":
		return _fail("%s: expected battle mode, got %s." % [context, String(snapshot.get("mode", ""))])
	if StringName(snapshot.get("current_stage_id", &"")) != expected_stage_id:
		return _fail("%s: expected stage %s, got %s." % [context, String(expected_stage_id), String(snapshot.get("current_stage_id", &""))])
	return true

func _consume_one_loaded_action(battle) -> bool:
	var ready_units: Array = []
	for unit in battle.ally_units:
		if is_instance_valid(unit) and not unit.is_defeated() and battle.turn_manager.can_unit_act(unit):
			ready_units.append(unit)
	if ready_units.is_empty():
		return _fail("Recovered manual save battle should expose at least one ready ally.")
	var unit = ready_units[0]
	battle._on_world_cell_pressed(unit.grid_position)
	await process_frame
	battle._on_wait_requested()
	await process_frame
	if battle.turn_manager.can_unit_act(unit):
		return _fail("Recovered manual save battle should still consume the selected unit's action package after Wait.")
	return true

func _fail(message: String) -> bool:
	if _failed:
		return false
	_failed = true
	push_error(message)
	quit(1)
	return false

