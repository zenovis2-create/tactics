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

	if not await _assert_autosave_recommended_when_newer(main):
		return
	if not await _assert_manual_recommended_when_newer(main):
		return

	print("[PASS] ng_plus_recommended_load_runner: SaveLoadPanel picks the freshest recommended load target while NG+ source metadata remains visible.")
	quit(0)

func _reset_slots(main: Node) -> void:
	var svc: SaveService = main._save_service
	for slot in SaveService.MANUAL_SLOT_COUNT:
		svc.delete_slot(slot)
	svc.delete_slot(SaveService.AUTOSAVE_SLOT)

func _assert_autosave_recommended_when_newer(main: Node) -> bool:
	_reset_slots(main)
	_seed_manual_ng_plus_source(main, "2026-04-21T08:00:00")
	_seed_autosave(main, "2026-04-21T09:00:00")
	main.title_screen.setup_save_service(main._save_service)
	main._show_title()
	await process_frame
	await process_frame

	var title_snapshot: Dictionary = main.title_screen.get_layout_snapshot()
	if not bool(title_snapshot.get("ng_plus_available", false)):
		return _fail("Autosave-newer case should still expose NG+ availability on title.")

	main.title_screen._on_load_pressed()
	await process_frame
	var panel_snapshot: Dictionary = main.save_load_panel.get_layout_snapshot()
	if not bool(panel_snapshot.get("recommended_load_is_autosave", false)):
		return _fail("SaveLoadPanel should recommend autosave when it is the freshest save, even with NG+ source metadata visible.")
	if int(panel_snapshot.get("recommended_load_slot", -1)) != SaveService.AUTOSAVE_SLOT:
		return _fail("SaveLoadPanel should point the recommendation to the autosave slot when it is freshest.")
	main.save_load_panel.close()
	return true

func _assert_manual_recommended_when_newer(main: Node) -> bool:
	_reset_slots(main)
	_seed_manual_ng_plus_source(main, "2026-04-21T10:00:00")
	_seed_autosave(main, "2026-04-21T09:00:00")
	main.title_screen.setup_save_service(main._save_service)
	main._show_title()
	await process_frame
	await process_frame

	var title_snapshot: Dictionary = main.title_screen.get_layout_snapshot()
	if not bool(title_snapshot.get("ng_plus_available", false)):
		return _fail("Manual-newer case should still expose NG+ availability on title.")

	main.title_screen._on_load_pressed()
	await process_frame
	var panel_snapshot: Dictionary = main.save_load_panel.get_layout_snapshot()
	if bool(panel_snapshot.get("recommended_load_is_autosave", true)):
		return _fail("SaveLoadPanel should prefer the manual NG+ source slot when it is freshest.")
	if int(panel_snapshot.get("recommended_load_slot", -1)) != 0:
		return _fail("SaveLoadPanel should point the recommendation to manual slot 0 when it is freshest.")
	main.save_load_panel.close()
	return true

func _seed_manual_ng_plus_source(main: Node, saved_at: String) -> void:
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
	main._save_service.save_progression(data, 0, {
		"autosave_reason": "CH10 최종 결말",
		"saved_at": saved_at
	})

func _seed_autosave(main: Node, saved_at: String) -> void:
	var data := ProgressionData.new()
	data.burden = 1
	data.trust = 8
	data.gold = 999
	data.flags["flag_resonance_noah"] = true
	main._save_service.save_progression(data, SaveService.AUTOSAVE_SLOT, {
		"autosave_reason": "타이틀 통합 로드 체크포인트",
		"saved_at": saved_at
	})

func _fail(message: String) -> bool:
	if _failed:
		return false
	_failed = true
	push_error(message)
	quit(1)
	return false
