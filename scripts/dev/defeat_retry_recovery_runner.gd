extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")

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

	var battle = main.battle_controller
	var stage_id: StringName = battle.stage_data.stage_id if battle != null and battle.stage_data != null else &""
	if stage_id == &"":
		return _fail("Retry recovery runner expected an active stage before defeat.")

	# Dirty runtime state so retry must really rebuild the battle scene state.
	var acted_unit = battle.ally_units[0]
	battle._on_world_cell_pressed(acted_unit.grid_position)
	await process_frame
	battle._on_wait_requested()
	await process_frame
	if battle.turn_manager.can_unit_act(acted_unit):
		return _fail("Setup step should consume one ally action before retry.")

	main.defeat_screen.show_defeat(2)
	await process_frame
	var defeat_snapshot: Dictionary = main.defeat_screen.get_layout_snapshot()
	if not bool(defeat_snapshot.get("visible", false)):
		return _fail("Defeat screen should become visible before retry.")

	main.defeat_screen._on_retry_pressed()
	await process_frame
	await process_frame

	if not _assert_stage_loaded(main, stage_id, "retry recovery should restore the same active stage"):
		return
	if bool(main.defeat_screen.get_layout_snapshot().get("visible", true)):
		return _fail("Defeat screen should hide itself after retry.")

	battle = main.battle_controller
	if battle == null:
		return _fail("Retry recovery should keep the main battle controller available.")
	var ready_units: Array = _get_ready_ally_units(battle)
	if ready_units.size() < 2:
		return _fail("Retry should rebuild the battle so both ally units are ready again.")
	if not await _consume_one_retried_action(battle):
		return

	print("[PASS] defeat_retry_recovery_runner: defeat retry restores the same stage and resets the battle to a playable state.")
	quit(0)

func _assert_stage_loaded(main: Node, expected_stage_id: StringName, context: String) -> bool:
	var snapshot: Dictionary = main.get_campaign_state_snapshot()
	if String(snapshot.get("mode", "")) != "battle":
		return _fail("%s: expected battle mode, got %s." % [context, String(snapshot.get("mode", ""))])
	if StringName(snapshot.get("current_stage_id", &"")) != expected_stage_id:
		return _fail("%s: expected stage %s, got %s." % [context, String(expected_stage_id), String(snapshot.get("current_stage_id", &""))])
	return true

func _get_ready_ally_units(battle) -> Array:
	var ready_units: Array = []
	for unit in battle.ally_units:
		if is_instance_valid(unit) and not unit.is_defeated() and battle.turn_manager.can_unit_act(unit):
			ready_units.append(unit)
	return ready_units

func _consume_one_retried_action(battle) -> bool:
	var ready_units: Array = _get_ready_ally_units(battle)
	if ready_units.is_empty():
		return _fail("Retried battle should expose at least one ready ally.")
	var unit = ready_units[0]
	battle._on_world_cell_pressed(unit.grid_position)
	await process_frame
	battle._on_wait_requested()
	await process_frame
	if battle.turn_manager.can_unit_act(unit):
		return _fail("Retried battle should still consume the selected unit's action package after Wait.")
	return true

func _fail(message: String) -> bool:
	if _failed:
		return false
	_failed = true
	push_error(message)
	quit(1)
	return false
