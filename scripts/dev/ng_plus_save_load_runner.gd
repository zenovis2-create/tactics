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

	_seed_ng_plus_source(main)
	main._show_title()
	await process_frame
	await process_frame

	if not _assert_ng_plus_title_surface(main):
		return

	main.title_screen._on_new_game_plus_confirmed()
	await process_frame
	await process_frame

	if not _assert_ng_plus_battle_state(main, "NG+ start should boot into a playable battle state"):
		return

	var live_data: ProgressionData = main.battle_controller.progression_service.get_data()
	live_data.burden = 3
	live_data.trust = 6
	live_data.gold = 888
	live_data.flags["flag_resonance_noah"] = true
	main._on_save_requested(0)
	await process_frame

	var saved_data: ProgressionData = main._save_service.load_progression(0)
	if saved_data == null:
		return _fail("NG+ save/load runner expected a loadable manual slot.")
	if not saved_data.ng_plus_run:
		return _fail("NG+ save/load runner should persist ng_plus_run in the saved slot.")
	if saved_data.last_completed_ending != &"true_ending":
		return _fail("NG+ save/load runner should preserve the completed ending source in the saved slot.")

	main._on_save_load_requested(0, saved_data)
	await process_frame
	await process_frame

	if not _assert_ng_plus_battle_state(main, "NG+ load should restore a playable battle state"):
		return

	var loaded_data: ProgressionData = main.battle_controller.progression_service.get_data()
	if loaded_data == null:
		return _fail("NG+ load should restore progression data into battle.")
	if not loaded_data.ng_plus_run:
		return _fail("NG+ load should preserve ng_plus_run after restoring the saved slot.")
	if loaded_data.last_completed_ending != &"true_ending":
		return _fail("NG+ load should preserve the source ending after restoring the saved slot.")
	if loaded_data.burden != 3 or loaded_data.trust != 6 or loaded_data.gold != 888:
		return _fail("NG+ load should preserve saved burden/trust/gold values.")
	if not bool(loaded_data.flags.get("flag_resonance_noah", false)):
		return _fail("NG+ load should preserve distinguishing saved flags.")

	if not await _consume_one_action(main.battle_controller):
		return

	print("[PASS] ng_plus_save_load_runner: title NG+ start and subsequent save/load restore a playable NG+ battle state.")
	quit(0)

func _seed_ng_plus_source(main: Node) -> void:
	var data := ProgressionData.new()
	data.ng_plus_available = true
	data.last_completed_ending = &"true_ending"
	data.flags["flag_resonance_serin"] = true
	data.flags["flag_resonance_bran"] = true
	data.flags["flag_resonance_tia"] = true
	data.flags["flag_resonance_enoch"] = true
	data.flags["flag_resonance_karl"] = true
	data.flags["flag_resonance_noah"] = true
	data.flags["flag_name_anchors_held_2plus"] = true
	data.flags["all_allies_name_called"] = true
	data.bond_levels["rian_serin"] = 3
	main._save_service.delete_slot(0)
	main._save_service.save_progression(data, 0, {"autosave_reason": "CH10 최종 결말"})
	if main.title_screen != null:
		main.title_screen.setup_save_service(main._save_service)

func _assert_ng_plus_title_surface(main: Node) -> bool:
	var snapshot: Dictionary = main.title_screen.get_layout_snapshot()
	if not bool(snapshot.get("ng_plus_available", false)):
		return _fail("NG+ save/load runner expected the title surface to expose NG+ availability.")
	if not bool(snapshot.get("ng_plus_button_visible", false)):
		return _fail("NG+ save/load runner expected the title surface to expose the NG+ button.")
	if String(snapshot.get("last_completed_ending", "")) != "true_ending":
		return _fail("NG+ title surface should preserve the source ending label.")
	return true

func _assert_ng_plus_battle_state(main: Node, context: String) -> bool:
	if not bool(main.is_ng_plus()):
		return _fail("%s: main should stay in NG+ mode." % context)
	var snapshot: Dictionary = main.get_campaign_state_snapshot()
	if String(snapshot.get("mode", "")) != "battle":
		return _fail("%s: expected battle mode, got %s." % [context, String(snapshot.get("mode", ""))])
	if StringName(snapshot.get("current_stage_id", &"")) != &"CH01_02":
		return _fail("%s: expected stage CH01_02, got %s." % [context, String(snapshot.get("current_stage_id", &""))])
	var data: ProgressionData = main.battle_controller.progression_service.get_data()
	if data == null:
		return _fail("%s: expected progression data in battle." % context)
	if not data.ng_plus_run:
		return _fail("%s: progression data should remain in NG+ run mode." % context)
	return true

func _consume_one_action(battle) -> bool:
	if battle == null:
		return _fail("NG+ battle should expose a battle controller.")
	var ready_units: Array = []
	for unit in battle.ally_units:
		if is_instance_valid(unit) and not unit.is_defeated() and battle.turn_manager.can_unit_act(unit):
			ready_units.append(unit)
	if ready_units.is_empty():
		return _fail("NG+ loaded battle should leave at least one ally ready to act.")
	var unit = ready_units[0]
	battle._on_world_cell_pressed(unit.grid_position)
	await process_frame
	battle._on_wait_requested()
	await process_frame
	if battle.turn_manager.can_unit_act(unit):
		return _fail("NG+ loaded battle should still consume the selected unit's action package after Wait.")
	return true

func _fail(message: String) -> bool:
	if _failed:
		return false
	_failed = true
	push_error(message)
	quit(1)
	return false
