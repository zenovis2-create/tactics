extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")

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
	live_data.burden = 7
	live_data.trust = 1
	live_data.gold = 321
	live_data.flags["flag_resonance_bran"] = true

	main.campaign_controller._autosave_progression("통합 복귀 체크포인트")
	await process_frame

	var autosave: ProgressionData = main._save_service.load_progression(SaveService.AUTOSAVE_SLOT)
	if autosave == null:
		return _fail("Autosave recovery runner expected a loadable autosave slot.")
	if autosave.burden != 7 or autosave.trust != 1 or autosave.gold != 321:
		return _fail("Autosave slot should preserve live progression values before defeat recovery.")

	main.defeat_screen.show_defeat(4)
	await process_frame
	var defeat_snapshot: Dictionary = main.defeat_screen.get_layout_snapshot()
	if not bool(defeat_snapshot.get("load_save_button_enabled", false)):
		return _fail("Defeat screen should enable autosave recovery when an autosave exists.")
	if String(defeat_snapshot.get("autosave_reason", "")) != "통합 복귀 체크포인트":
		return _fail("Defeat screen should surface the current autosave checkpoint reason.")

	main.defeat_screen._on_load_save_pressed()
	await process_frame
	await process_frame

	if not _assert_stage_loaded(main, &"CH01_02", "defeat autosave recovery should restore the same active stage"):
		return
	var recovered_data: ProgressionData = main.battle_controller.progression_service.get_data()
	if recovered_data == null:
		return _fail("Recovered autosave should restore live progression data into battle.")
	if recovered_data.burden != 7 or recovered_data.trust != 1 or recovered_data.gold != 321:
		return _fail("Recovered autosave should preserve saved burden/trust/gold values.")
	if not bool(recovered_data.flags.get("flag_resonance_bran", false)):
		return _fail("Recovered autosave should preserve saved flags.")

	if not await _consume_one_loaded_action(main.battle_controller):
		return

	print("[PASS] defeat_autosave_recovery_runner: autosave defeat recovery restores battle state and remains playable.")
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
		return _fail("Recovered autosave battle should expose at least one ready ally.")
	var unit = ready_units[0]
	battle._on_world_cell_pressed(unit.grid_position)
	await process_frame
	battle._on_wait_requested()
	await process_frame
	if battle.turn_manager.can_unit_act(unit):
		return _fail("Recovered autosave battle should still consume the selected unit's action package after Wait.")
	return true

func _fail(message: String) -> bool:
	if _failed:
		return false
	_failed = true
	push_error(message)
	quit(1)
	return false
