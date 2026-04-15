extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH01_FINAL_STAGE = preload("res://data/stages/ch01_05_stage.tres")
const ProgressionService = preload("res://scripts/battle/progression_service.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await process_frame
	if not _assert_progression_debug_snapshot():
		return
	await _assert_battle_result_unlock_surface()
	await _assert_player_visible_unlock_surfaces()

func _assert_progression_debug_snapshot() -> bool:
	var svc := ProgressionService.new()
	root.add_child(svc)
	var result := svc.recover_fragment(&"ch01_fragment")
	if result.get("command_unlocked") != "tactical_shift":
		return _fail("ch01_fragment should unlock tactical_shift in the command unlock runner.")
	var debug_snapshot := svc.get_data().to_debug_dict()
	var fragment_ids: Array = debug_snapshot.get("recovered_fragments", [])
	var command_ids: Array = debug_snapshot.get("unlocked_commands", [])
	if fragment_ids.is_empty() or String(fragment_ids[0]) != "ch01_fragment":
		return _fail("Progression debug snapshot should expose recovered fragment ids.")
	if command_ids.is_empty() or String(command_ids[0]) != "tactical_shift":
		return _fail("Progression debug snapshot should expose unlocked command ids.")
	svc.queue_free()
	return true

func _assert_player_visible_unlock_surfaces() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.battle_controller.progression_service.recover_fragment(&"ch01_fragment")
	main.campaign_controller._current_stage = CH01_FINAL_STAGE
	main.campaign_controller._active_chapter_id = &"ch01"
	main.campaign_controller._enter_camp_state()
	await process_frame
	await process_frame
	var mode := String(main.get_campaign_state_snapshot().get("mode", ""))
	if mode != "camp":
		return _fail("Command unlock runner should enter camp mode for campaign visibility checks.")

	var body_text := String(main.campaign_panel.get_snapshot().get("body", ""))
	if body_text.find("Recovered fragment ids: ch01_fragment") == -1:
		return _fail("Campaign camp body should expose recovered fragment ids.")
	if body_text.find("Unlocked command ids: tactical_shift") == -1:
		return _fail("Campaign camp body should expose unlocked command ids.")

	print("[PASS] command_unlock_runner: progression debug, battle result, and camp surfaces expose unlock visibility.")
	quit(0)

func _assert_battle_result_unlock_surface() -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame
	battle.set_stage(CH01_FINAL_STAGE)
	await process_frame
	await process_frame
	battle.enemy_units.clear()
	if not battle._check_battle_end():
		_fail("Command unlock runner failed to force CH01_05 victory for result visibility.")
		return
	await process_frame
	var result_summary: Dictionary = battle.get_last_result_summary()
	var result_fragments: Array = result_summary.get("recovered_fragment_ids", [])
	var result_commands: Array = result_summary.get("unlocked_command_ids", [])
	if result_fragments.is_empty() or String(result_fragments[0]) != "ch01_fragment":
		_fail("Battle result summary should expose recovered fragment ids.")
		return
	if result_commands.is_empty() or String(result_commands[0]) != "tactical_shift":
		_fail("Battle result summary should expose unlocked command ids.")
		return
	battle.queue_free()

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
