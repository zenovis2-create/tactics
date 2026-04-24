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
	live_data.burden = 4
	live_data.trust = 9
	live_data.gold = 654
	live_data.flags["flag_resonance_tia"] = true

	main.campaign_controller.debug_seed_chapter_camp(&"CH08", 4, CH08_FINAL_STAGE)
	await process_frame
	await process_frame

	var camp_snapshot: Dictionary = main.get_campaign_state_snapshot()
	if String(camp_snapshot.get("mode", "")) != "camp":
		return _fail("Campaign save panel runner expected to start from camp mode.")
	if not bool(main.campaign_panel.get_snapshot().get("visible", false)):
		return _fail("Campaign panel should remain visible before opening the save panel.")

	main.campaign_panel._on_save_pressed()
	await process_frame

	var panel_snapshot: Dictionary = main.save_load_panel.get_layout_snapshot()
	if not bool(main.save_load_panel.visible):
		return _fail("CampaignPanel save button should open the shared SaveLoadPanel.")
	if String(panel_snapshot.get("mode", "")) != "save":
		return _fail("CampaignPanel save button should open SaveLoadPanel in save mode.")

	main.save_load_panel._on_save_pressed(0)
	await process_frame

	var saved_data: ProgressionData = main._save_service.load_progression(0)
	if saved_data == null:
		return _fail("Campaign save panel roundtrip should persist a loadable manual slot.")
	if saved_data.burden != 4 or saved_data.trust != 9 or saved_data.gold != 654:
		return _fail("Campaign save panel roundtrip should preserve live burden/trust/gold values.")
	if not bool(saved_data.flags.get("flag_resonance_tia", false)):
		return _fail("Campaign save panel roundtrip should preserve live progression flags.")

	var slot_info: Dictionary = main._save_service.peek_slot(0)
	if not bool(slot_info.get("exists", false)):
		return _fail("Campaign save panel roundtrip should expose saved slot metadata.")
	if String(slot_info.get("slot_label", "")) != "슬롯 0":
		return _fail("Campaign save panel roundtrip should preserve manual slot metadata.")

	main.save_load_panel.close()
	await process_frame

	var after_snapshot: Dictionary = main.get_campaign_state_snapshot()
	if String(after_snapshot.get("mode", "")) != "camp":
		return _fail("Closing SaveLoadPanel after a camp save should keep campaign mode in camp.")
	if not bool(main.campaign_panel.get_snapshot().get("visible", false)):
		return _fail("Campaign panel should remain visible after closing the save panel.")

	print("[PASS] campaign_save_panel_roundtrip_runner: CampaignPanel save button opens SaveLoadPanel, saves manual slot, and returns to camp state.")
	quit(0)

func _fail(message: String) -> bool:
	if _failed:
		return false
	_failed = true
	push_error(message)
	quit(1)
	return false

