extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const StageData = preload("res://scripts/data/stage_data.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main := await _boot_main()
	if main == null:
		return
	var battle = main.battle_controller
	var campaign = main.campaign_controller
	var panel = main.campaign_panel
	var progression: ProgressionData = battle.progression_service.get_data()
	var stage := _build_stage(&"CH05_02")
	progression.upsert_encyclopedia_entry(&"ally_enoch", {
		"name": "Enoch",
		"type": "Ally",
		"chapter_introduced": 5,
		"stats": {"hp": 11, "attack": 4, "defense": 1, "movement": 3, "range": 1},
		"quote": "",
		"support_rank": 0
	})
	progression.add_sacrificed_unit("ally_enoch", "Enoch", "나는後悔ない")
	progression.add_memorial_record("ally_enoch", "Enoch", "나는後悔ない", "CH05", "CH05_02")
	progression.set_unit_quote("ally_enoch", "나는後悔ない")

	campaign.debug_seed_chapter_camp(&"CH05", 0, stage)
	await process_frame
	await process_frame
	campaign._show_memorial_scene("ally_enoch")
	await process_frame
	await process_frame

	var memorial_snapshot: Dictionary = panel.get_snapshot()
	if not bool(memorial_snapshot.get("memorial_visible", false)):
		_fail(main, "Memorial panel should be visible after triggering the scene.")
		return
	if String(memorial_snapshot.get("memorial_unit_name", "")).find("Enoch") == -1:
		_fail(main, "Memorial panel should engrave Enoch's name.")
		return
	if String(memorial_snapshot.get("memorial_quote", "")).find("나는後悔ない") == -1:
		_fail(main, "Memorial panel should render the seeded epitaph.")
		return

	var marker := progression.get_first_memorial_marker()
	if String(marker.get("unit_name", "")) != "Enoch" or String(marker.get("stage_id", "")) != "CH05_02":
		_fail(main, "Progression should store the memorial marker for Enoch at CH05_02.")
		return
	main.battle_controller.hud.set_selection_summary("Enoch", "11/11", 3, 1, 4, 1, 0, "Plain", 0, progression.get_unit_quote("ally_enoch"))
	await process_frame
	var quote_label: RichTextLabel = main.battle_controller.hud.get_node("BottomPanel/Margin/Content/SelectionCard/Padding/Stack/QuoteLabel")
	if quote_label == null or not quote_label.visible or String(quote_label.text).find("나는後悔ない") == -1:
		_fail(main, "Battle HUD should surface the registered memorial combat quote.")
		return

	panel.skip_memorial_scene()
	await process_frame
	await process_frame
	var camp_snapshot: Dictionary = panel.get_snapshot()
	var honor_entries: Array = camp_snapshot.get("honor_entries", [])
	if not _lines_contain(honor_entries, "Enoch"):
		_fail(main, "Camp party screen should list Enoch in the Seat of Honor.")
		return

	main.encyclopedia_panel.show_context(campaign.get_encyclopedia_context())
	await process_frame
	main.encyclopedia_panel.select_tab("atlas")
	var atlas_snapshot: Dictionary = main.encyclopedia_panel.get_snapshot()
	if String(atlas_snapshot.get("atlas_memorial_marker", "")).find("Enoch") == -1:
		_fail(main, "Atlas tab should include the memorial marker for Enoch.")
		return
	if String(atlas_snapshot.get("atlas_text", "")).find("Saria Archive") == -1:
		_fail(main, "Atlas memorial marker should resolve the CH05 location name.")
		return

	print("[PASS] memorial_scene_runner: all assertions passed.")
	await _teardown_main(main)
	quit(0)

func _boot_main() -> Node:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.start_game_direct()
	await process_frame
	await process_frame
	if main.battle_controller != null and main.battle_controller.progression_service != null:
		main.battle_controller.progression_service.load_data(ProgressionData.new())
	return main

func _teardown_main(main: Node) -> void:
	if main == null:
		return
	main.queue_free()
	await process_frame
	await process_frame

func _build_stage(stage_id: StringName) -> StageData:
	var stage := StageData.new()
	stage.stage_id = stage_id
	stage.stage_title = String(stage_id)
	stage.grid_size = Vector2i(6, 6)
	stage.cell_size = Vector2i(64, 64)
	return stage

func _lines_contain(lines: Array, needle: String) -> bool:
	for line in lines:
		if String(line).find(needle) != -1:
			return true
	return false

func _fail(main: Node, message: String) -> void:
	print("[FAIL] %s" % message)
	await _teardown_main(main)
	quit(1)
