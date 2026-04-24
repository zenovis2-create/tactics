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

	_seed_saves(main)
	main._show_title()
	await process_frame
	await process_frame

	if not await _assert_title_load_panel_flow(main):
		return
	if not await _assert_manual_slot_load(main):
		return

	main._show_title()
	await process_frame
	await process_frame

	if not await _assert_title_load_panel_flow(main):
		return
	if not await _assert_autosave_slot_load(main):
		return

	print("[PASS] title_load_panel_runner: title-screen load panel restores both manual and autosave selections into playable battle state.")
	quit(0)

func _seed_saves(main: Node) -> void:
	var svc: SaveService = main._save_service
	for slot in SaveService.MANUAL_SLOT_COUNT:
		svc.delete_slot(slot)
	svc.delete_slot(SaveService.AUTOSAVE_SLOT)

	var manual := ProgressionData.new()
	manual.burden = 9
	manual.trust = 2
	manual.gold = 111
	manual.flags["flag_resonance_serin"] = true
	svc.save_progression(manual, 0)

	var autosave := ProgressionData.new()
	autosave.burden = 1
	autosave.trust = 8
	autosave.gold = 999
	autosave.flags["flag_resonance_noah"] = true
	svc.save_progression(autosave, SaveService.AUTOSAVE_SLOT, {"autosave_reason": "타이틀 통합 로드 체크포인트"})

	if main.title_screen != null:
		main.title_screen.setup_save_service(svc)

func _assert_title_load_panel_flow(main: Node) -> bool:
	if main.title_screen == null or main.save_load_panel == null:
		return _fail("Main should expose title screen and save/load panel for title load integration.")
	main.title_screen._on_load_pressed()
	await process_frame
	var panel_snapshot: Dictionary = main.save_load_panel.get_layout_snapshot()
	if not bool(main.save_load_panel.visible):
		return _fail("Title load button should open the shared SaveLoadPanel.")
	if String(panel_snapshot.get("mode", "")) != "load":
		return _fail("Title load button should open SaveLoadPanel in load mode.")
	return true

func _assert_manual_slot_load(main: Node) -> bool:
	main.save_load_panel._on_load_pressed(0)
	await process_frame
	await process_frame

	if not _assert_battle_state(main, 9, 2, 111, "flag_resonance_serin"):
		return false
	if bool(main.save_load_panel.visible):
		return _fail("Load panel should close itself after manual slot load.")
	return await _consume_one_action(main.battle_controller)

func _assert_autosave_slot_load(main: Node) -> bool:
	main.save_load_panel._on_load_pressed(SaveService.AUTOSAVE_SLOT)
	await process_frame
	await process_frame

	if not _assert_battle_state(main, 1, 8, 999, "flag_resonance_noah"):
		return false
	if bool(main.save_load_panel.visible):
		return _fail("Load panel should close itself after autosave load.")
	return await _consume_one_action(main.battle_controller)

func _assert_battle_state(main: Node, burden: int, trust: int, gold: int, required_flag: String) -> bool:
	var snapshot: Dictionary = main.get_campaign_state_snapshot()
	if String(snapshot.get("mode", "")) != "battle":
		return _fail("Loaded title selection should return the app to battle mode.")
	if StringName(snapshot.get("current_stage_id", &"")) != &"CH01_02":
		return _fail("Loaded title selection should resume into the playable opening stage.")
	var data: ProgressionData = main.battle_controller.progression_service.get_data()
	if data == null:
		return _fail("Loaded title selection should restore progression data into battle.")
	if data.burden != burden or data.trust != trust or data.gold != gold:
		return _fail("Loaded title selection should restore saved burden/trust/gold values.")
	if not bool(data.flags.get(required_flag, false)):
		return _fail("Loaded title selection should preserve the distinguishing saved flag.")
	return true

func _consume_one_action(battle) -> bool:
	if battle == null:
		return _fail("Loaded battle should expose a battle controller.")
	var ready_units: Array = []
	for unit in battle.ally_units:
		if is_instance_valid(unit) and not unit.is_defeated() and battle.turn_manager.can_unit_act(unit):
			ready_units.append(unit)
	if ready_units.is_empty():
		return _fail("Loaded title selection should still leave at least one ally ready to act.")
	var unit = ready_units[0]
	battle._on_world_cell_pressed(unit.grid_position)
	await process_frame
	battle._on_wait_requested()
	await process_frame
	if battle.turn_manager.can_unit_act(unit):
		return _fail("Loaded title selection should still consume the selected unit's action package after Wait.")
	return true

func _fail(message: String) -> bool:
	if _failed:
		return false
	_failed = true
	push_error(message)
	quit(1)
	return false
