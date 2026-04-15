extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH01_FINAL_STAGE = preload("res://data/stages/ch01_05_stage.tres")
const CH01_OPEN_STAGE = preload("res://data/stages/ch01_02_stage.tres")

var _failed: bool = false
var _main_instance: Node = null


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	_main_instance = main
	root.add_child(main)

	await process_frame
	await process_frame

	if main.bgm_router == null:
		_fail("Main should expose BgmRouter.")
		return

	_assert_current_cue(main, "bgm_title")
	_assert_current_asset(main, "bgm_title.wav")
	if _failed:
		return

	main.open_load_panel()
	await process_frame
	await process_frame
	_assert_current_cue(main, "bgm_title")
	_assert_current_asset(main, "bgm_title.wav")
	if _failed:
		return
	if main.save_load_panel == null or not main.save_load_panel.visible:
		_fail("Expected SaveLoadPanel to be visible in title flow.")
		return
	main.save_load_panel.close()
	await process_frame

	if main.has_method("start_game_direct"):
		main.start_game_direct()
		await process_frame
		await process_frame

	_assert_current_cue(main, "bgm_battle_default")
	_assert_current_asset(main, "bgm_battle_default.wav")
	if _failed:
		return

	main.open_save_panel()
	await process_frame
	await process_frame
	_assert_current_cue(main, "bgm_battle_default")
	_assert_current_asset(main, "bgm_battle_default.wav")
	if _failed:
		return
	if main.save_load_panel == null or not main.save_load_panel.visible:
		_fail("Expected SaveLoadPanel to be visible in battle flow.")
		return
	main.save_load_panel.close()
	await process_frame

	main.campaign_controller._active_mode = "cutscene"
	main.campaign_controller.mode_changed.emit("cutscene")
	await process_frame
	_assert_current_cue(main, "bgm_cutscene_ch01")
	_assert_current_asset(main, "bgm_cutscene_ch01.wav")
	if _failed:
		return

	main.campaign_controller._active_chapter_id = &"CH01"
	main.campaign_controller._active_stage_index = 3
	main.campaign_controller._current_stage = CH01_FINAL_STAGE
	main.campaign_controller._enter_camp_state()
	await process_frame
	await process_frame
	_assert_current_cue(main, "bgm_camp")
	_assert_current_asset(main, "bgm_camp.wav")
	if _failed:
		return

	main.open_save_panel()
	await process_frame
	await process_frame
	_assert_current_cue(main, "bgm_camp")
	_assert_current_asset(main, "bgm_camp.wav")
	if _failed:
		return
	if main.save_load_panel == null or not main.save_load_panel.visible:
		_fail("Expected SaveLoadPanel to be visible in camp flow.")
		return
	main.save_load_panel.close()
	await process_frame

	main.campaign_controller._current_stage = CH01_FINAL_STAGE
	main.campaign_controller._battle_controller.set_stage(CH01_FINAL_STAGE)
	main.campaign_controller.mode_changed.emit("battle")
	await process_frame
	await process_frame
	_assert_current_cue(main, "bgm_battle_boss")
	_assert_current_asset(main, "bgm_battle_boss.wav")
	if _failed:
		return

	main.campaign_controller._current_stage = CH01_OPEN_STAGE
	main.campaign_controller._enter_stage(0)
	await process_frame
	await process_frame
	_assert_current_cue(main, "bgm_battle_default")
	_assert_current_asset(main, "bgm_battle_default.wav")
	if _failed:
		return

	main._on_battle_finished_main(&"defeat", &"CH01_02")
	await process_frame
	await process_frame
	_assert_current_cue(main, "bgm_cutscene_ch01")
	_assert_current_asset(main, "bgm_cutscene_ch01.wav")
	if _failed:
		return

	main._on_title_requested()
	await process_frame
	await process_frame
	_assert_current_cue(main, "bgm_title")
	_assert_current_asset(main, "bgm_title.wav")
	if _failed:
		return

	main._on_retry_requested()
	await process_frame
	await process_frame
	_assert_current_cue(main, "bgm_battle_default")
	_assert_current_asset(main, "bgm_battle_default.wav")
	if _failed:
		return

	print("[PASS] BGM transition runner validated title, battle, boss battle, cutscene, camp, defeat, retry, and save/load panel cue persistence.")
	await _cleanup_and_quit(0)


func _assert_current_cue(main: Node, expected_cue: String) -> void:
	var actual_cue: String = main.bgm_router.get_current_cue_id()
	if actual_cue != expected_cue:
		_fail("Expected BGM cue %s, got %s." % [expected_cue, actual_cue])


func _assert_current_asset(main: Node, expected_suffix: String) -> void:
	var stream: AudioStream = main.bgm_router._player.stream
	if stream == null:
		_fail("Expected BGM router to have a loaded stream for %s." % expected_suffix)
		return
	var manifest: Dictionary = main.bgm_router._cue_manifest
	var cue_id: String = main.bgm_router.get_current_cue_id()
	var entry: Dictionary = manifest.get(cue_id, {})
	var asset_path := String(entry.get("asset_path", ""))
	if not asset_path.ends_with(expected_suffix):
		_fail("Expected asset suffix %s, got %s." % [expected_suffix, asset_path])


func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	call_deferred("_deferred_fail_quit")


func _deferred_fail_quit() -> void:
	await _cleanup_and_quit(1)


func _cleanup_and_quit(exit_code: int) -> void:
	if _main_instance != null and is_instance_valid(_main_instance):
		_main_instance.queue_free()
		_main_instance = null
		await process_frame
		await process_frame
	quit(exit_code)
