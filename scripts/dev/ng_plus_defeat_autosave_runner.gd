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

	_seed_ng_plus_source(main)
	main._show_title()
	await process_frame
	await process_frame

	main.title_screen._on_new_game_plus_confirmed()
	await process_frame
	await process_frame

	if not _assert_ng_plus_battle_state(main, "NG+ autosave recovery should start inside a playable battle state"):
		return

	var live_data: ProgressionData = main.battle_controller.progression_service.get_data()
	live_data.burden = 5
	live_data.trust = 7
	live_data.gold = 432
	live_data.flags["flag_resonance_enoch"] = true
	main.campaign_controller._autosave_progression("NG+ 통합 복귀 체크포인트")
	await process_frame

	var autosave: ProgressionData = main._save_service.load_progression(SaveService.AUTOSAVE_SLOT)
	if autosave == null:
		return _fail("NG+ autosave recovery runner expected a loadable autosave slot.")
	if not autosave.ng_plus_run:
		return _fail("NG+ autosave slot should preserve ng_plus_run.")
	if autosave.last_completed_ending != &"true_ending":
		return _fail("NG+ autosave slot should preserve the source ending.")

	main.defeat_screen.show_defeat(5)
	await process_frame
	var defeat_snapshot: Dictionary = main.defeat_screen.get_layout_snapshot()
	if not bool(defeat_snapshot.get("load_save_button_enabled", false)):
		return _fail("NG+ defeat surface should still enable autosave recovery.")
	if String(defeat_snapshot.get("autosave_reason", "")) != "NG+ 통합 복귀 체크포인트":
		return _fail("NG+ defeat surface should preserve the autosave checkpoint reason.")

	main.defeat_screen._on_load_save_pressed()
	await process_frame
	await process_frame

	if not _assert_ng_plus_battle_state(main, "NG+ autosave recovery should restore the same playable battle state"):
		return

	var recovered_data: ProgressionData = main.battle_controller.progression_service.get_data()
	if recovered_data == null:
		return _fail("NG+ autosave recovery should restore progression data into battle.")
	if not recovered_data.ng_plus_run:
		return _fail("NG+ autosave recovery should preserve ng_plus_run after restore.")
	if recovered_data.last_completed_ending != &"true_ending":
		return _fail("NG+ autosave recovery should preserve the source ending after restore.")
	if recovered_data.burden != 5 or recovered_data.trust != 7 or recovered_data.gold != 432:
		return _fail("NG+ autosave recovery should preserve saved burden/trust/gold values.")
	if not bool(recovered_data.flags.get("flag_resonance_enoch", false)):
		return _fail("NG+ autosave recovery should preserve saved flags.")

	if not await _consume_one_action(main.battle_controller):
		return

	print("[PASS] ng_plus_defeat_autosave_runner: NG+ autosave defeat recovery restores battle state and preserves NG+ runtime flags.")
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
	main._save_service.delete_slot(0)
	main._save_service.delete_slot(SaveService.AUTOSAVE_SLOT)
	main._save_service.save_progression(data, 0, {"autosave_reason": "CH10 최종 결말"})
	if main.title_screen != null:
		main.title_screen.setup_save_service(main._save_service)

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
		return _fail("Recovered NG+ battle should expose a battle controller.")
	var ready_units: Array = []
	for unit in battle.ally_units:
		if is_instance_valid(unit) and not unit.is_defeated() and battle.turn_manager.can_unit_act(unit):
			ready_units.append(unit)
	if ready_units.is_empty():
		return _fail("Recovered NG+ battle should still leave at least one ally ready to act.")
	var unit = ready_units[0]
	battle._on_world_cell_pressed(unit.grid_position)
	await process_frame
	battle._on_wait_requested()
	await process_frame
	if battle.turn_manager.can_unit_act(unit):
		return _fail("Recovered NG+ battle should still consume the selected unit's action package after Wait.")
	return true

func _fail(message: String) -> bool:
	if _failed:
		return false
	_failed = true
	push_error(message)
	quit(1)
	return false
