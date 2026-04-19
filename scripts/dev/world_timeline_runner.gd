extends SceneTree

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const CampaignShellDialogueCatalog = preload("res://scripts/campaign/campaign_shell_dialogue_catalog.gd")
const CampaignPanel = preload("res://scripts/campaign/campaign_panel.gd")
const BattleResultScreen = preload("res://scripts/battle/battle_result_screen.gd")

const CONTROLLER_PATH := "res://scripts/campaign/campaign_controller.gd"
const BATTLE_CONTROLLER_PATH := "res://scripts/battle/battle_controller.gd"
const TIMELINE_B_LINE := "진실을 모르기에 평화롭습니다."
const WARNING_LINE := "!경고: 세계관이 변경됩니다"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var progression := ProgressionData.new()
	if progression.world_timeline_id != "A":
		_fail("ProgressionData should default world_timeline_id to A.")
		return

	progression.world_timeline_id = "B"
	progression.reset_for_new_campaign()
	if progression.world_timeline_id != "A":
		_fail("reset_for_new_campaign() should restore world_timeline_id to A.")
		return

	var controller_source := _read_text(CONTROLLER_PATH)
	if controller_source.is_empty():
		_fail("Could not read campaign_controller.gd for world timeline verification.")
		return

	if controller_source.find("progression.world_timeline_id = \"B\"") == -1:
		_fail("campaign_controller.gd does not author the CH05 destroy/reject route to timeline B.")
		return

	if controller_source.find("ch05_save_enoch") == -1:
		_fail("campaign_controller.gd should explicitly recognize the CH05 ledger-destroy option.")
		return

	if controller_source.find("contains(\"destroy\")") == -1 or controller_source.find("contains(\"reject\")") == -1:
		_fail("campaign_controller.gd should recognize destroy/reject choice ids for the world timeline branch.")
		return

	var battle_controller_source := _read_text(BATTLE_CONTROLLER_PATH)
	if battle_controller_source.find("\"world_timeline_id\"") == -1 or battle_controller_source.find("\"world_timeline_text\"") == -1:
		_fail("battle_controller.gd should record world_timeline_id and world_timeline_text in the result summary.")
		return

	var timeline_b_dialogue := CampaignShellDialogueCatalog.get_interlude_dialogue(&"CH06", "B")
	if not timeline_b_dialogue.has(TIMELINE_B_LINE):
		_fail("CH06 camp dialogue should expose the timeline B variation line.")
		return

	var timeline_a_dialogue := CampaignShellDialogueCatalog.get_interlude_dialogue(&"CH06", "A")
	if timeline_a_dialogue.has(TIMELINE_B_LINE):
		_fail("CH06 camp dialogue should keep the B line out of the A route.")
		return

	var panel := CampaignPanel.new()
	var tooltip := panel._build_choice_tooltip_text({
		"id": "ch05_save_enoch",
		"hint": "Enoch stays fully operational, but only 2 research ledgers survive the fire."
	})
	if tooltip.find(WARNING_LINE) == -1:
		_fail("campaign_panel.gd should surface the world-timeline warning tooltip for the ledger-destroy option.")
		return
	panel.free()

	var result_screen := BattleResultScreen.new()
	root.add_child(result_screen)
	await process_frame
	result_screen.show_result({
		"title": "Victory",
		"progression_data": ProgressionData.new(),
		"world_timeline_id": "B",
		"world_timeline_text": TIMELINE_B_LINE
	})
	var result_body := result_screen.body_label.text if result_screen.body_label != null else ""
	if result_body.find("World Timeline") == -1 or result_body.find(TIMELINE_B_LINE) == -1:
		_fail("BattleResultScreen should surface the world timeline summary text.")
		return
	result_screen.queue_free()
	await process_frame

	print("[PASS] world_timeline_runner verified progression defaults/reset, CH05 timeline-B authoring, CH06 B dialogue resolution, and the warning tooltip.")
	quit(0)

func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
