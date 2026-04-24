extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH08_FINAL_STAGE = preload("res://data/stages/ch08_05_stage.tres")
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

	var live_data: ProgressionData = main.battle_controller.progression_service.get_data()
	live_data.burden = 6
	live_data.trust = 4
	live_data.gold = 543
	live_data.flags["flag_resonance_bran"] = true

	main.campaign_controller.debug_seed_chapter_camp(&"CH08", 4, CH08_FINAL_STAGE)
	await process_frame
	await process_frame

	if String(main.get_campaign_state_snapshot().get("mode", "")) != "camp":
		return _fail("Campaign save-to-title-load runner expected to start from camp mode.")

	main.campaign_panel._on_save_pressed()
	await process_frame
	if String(main.save_load_panel.get_layout_snapshot().get("mode", "")) != "save":
		return _fail("Campaign save-to-title-load runner should open SaveLoadPanel in save mode.")

	main.save_load_panel._on_save_pressed(0)
	await process_frame

	var saved_data: ProgressionData = main._save_service.load_progression(0)
	if saved_data == null:
		return _fail("Campaign save-to-title-load runner expected a loadable manual slot.")
	if saved_data.burden != 6 or saved_data.trust != 4 or saved_data.gold != 543:
		return _fail("Saved camp slot should preserve burden/trust/gold before title load.")

	main._show_title()
	await process_frame
	await process_frame

	if not bool(main.title_screen.get_layout_snapshot().get("visible", false)):
		return _fail("Campaign save-to-title-load runner expected title screen to become visible.")

	main.title_screen._on_load_pressed()
	await process_frame
	if String(main.save_load_panel.get_layout_snapshot().get("mode", "")) != "load":
		return _fail("Title load button should reopen SaveLoadPanel in load mode after a camp save.")

	main.save_load_panel._on_load_pressed(0)
	await process_frame
	await process_frame

	if not _assert_loaded_battle_state(main):
		return
	if not await _consume_one_action(main.battle_controller):
		return

	print("[PASS] campaign_save_to_title_load_runner: camp save survives title return and reloads into a playable battle state.")
	quit(0)

func _assert_loaded_battle_state(main: Node) -> bool:
	var snapshot: Dictionary = main.get_campaign_state_snapshot()
	if String(snapshot.get("mode", "")) != "battle":
		return _fail("Loading a camp save from title should return the app to battle mode.")
	if StringName(snapshot.get("current_stage_id", &"")) != &"CH01_02":
		return _fail("Loading a camp save from title should bootstrap the playable opening stage.")
	if bool(main.save_load_panel.visible):
		return _fail("SaveLoadPanel should close itself after title load.")
	var data: ProgressionData = main.battle_controller.progression_service.get_data()
	if data == null:
		return _fail("Loaded camp save should restore progression data into battle.")
	if data.burden != 6 or data.trust != 4 or data.gold != 543:
		return _fail("Loaded camp save should preserve saved burden/trust/gold values.")
	if not bool(data.flags.get("flag_resonance_bran", false)):
		return _fail("Loaded camp save should preserve saved flags.")
	return true

func _consume_one_action(battle) -> bool:
	if battle == null:
		return _fail("Loaded camp save should expose a battle controller.")
	var ready_units: Array = []
	for unit in battle.ally_units:
		if is_instance_valid(unit) and not unit.is_defeated() and battle.turn_manager.can_unit_act(unit):
			ready_units.append(unit)
	if ready_units.is_empty():
		return _fail("Loaded camp save should leave at least one ally ready to act.")
	var unit = ready_units[0]
	battle._on_world_cell_pressed(unit.grid_position)
	await process_frame
	battle._on_wait_requested()
	await process_frame
	if battle.turn_manager.can_unit_act(unit):
		return _fail("Loaded camp save should still consume the selected unit's action package after Wait.")
	return true

func _fail(message: String) -> bool:
	if _failed:
		return false
	_failed = true
	push_error(message)
	quit(1)
	return false

