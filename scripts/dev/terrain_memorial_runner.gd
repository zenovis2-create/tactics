extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const CH07_MEMORIAL_STAGE: Resource = preload("res://data/stages/ch07_05_stage.tres")
const CH09A_MEMORIAL_STAGE: Resource = preload("res://data/stages/ch09a_04_stage.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main := await _boot_main()
	if main == null:
		return

	var progression := ProgressionData.new()
	progression.upsert_stage_memorial("CH07_05", "미라의 기록이 잠들어 있던 성소", "flower", 7)
	progression.upsert_stage_memorial("CH09A_04", "중앙 승강기와 버려진 장교들의 퇴로", "medal", 9)
	if progression.get_stage_memorial_snapshot().size() != 2:
		_fail(main, "Stage memorial seeding should store two completed optional-objective memorials.")
		return

	progression.reset_for_new_campaign()
	if progression.get_stage_memorial_snapshot().size() != 2:
		_fail(main, "Stage memorials should persist into the next playthrough.")
		return

	main.battle_controller.progression_service.load_data(progression)
	main.battle_controller.set_stage(CH09A_MEMORIAL_STAGE)
	await process_frame
	await process_frame

	var hud_snapshot: Dictionary = main.battle_controller.hud.get_stage_memorial_snapshot()
	if not bool(hud_snapshot.get("visible", false)):
		_fail(main, "Battle HUD should render the saved terrain memorial marker on stage entry.")
		return
	if String(hud_snapshot.get("icon", "")) != "🏅":
		_fail(main, "CH09A_04 memorial marker should use the valor medal icon.")
		return
	if String(hud_snapshot.get("tooltip", "")).find("중앙 승강기") == -1:
		_fail(main, "Battle HUD memorial tooltip should mention the saved objective details.")
		return

	main.campaign_controller.debug_seed_chapter_camp(&"CH09A", 3, CH09A_MEMORIAL_STAGE)
	await process_frame
	await process_frame

	var panel_snapshot: Dictionary = main.campaign_panel.get_snapshot()
	if String(panel_snapshot.get("body", "")).find("이 땅은 당신의 선택을 기억합니다") == -1:
		_fail(main, "Camp summary should mention that the land remembers the player's choice.")
		return
	if not _lines_contain(panel_snapshot.get("dialogue_entries", []), "이 자리에서 당신은 중앙 승강기와 버려진 장교들의 퇴로 지켰습니다"):
		_fail(main, "Camp dialogue should mention what was protected on this stage.")
		return

	main.encyclopedia_panel.show_context(main.campaign_controller.get_encyclopedia_context())
	await process_frame
	main.encyclopedia_panel.select_tab("atlas")
	await process_frame
	var atlas_snapshot: Dictionary = main.encyclopedia_panel.get_snapshot()
	var atlas_text := String(atlas_snapshot.get("atlas_text", ""))
	if atlas_text.find("Terrain Remembers") == -1:
		_fail(main, "Atlas tab should render the Terrain Remembers memorial section.")
		return
	if atlas_text.find("Broken Standard (CH09A_04)") == -1 or atlas_text.find("Ellyor (CH07_05)") == -1:
		_fail(main, "Atlas tab should list each stored memorial location.")
		return

	print("[PASS] terrain_memorial_runner: all assertions passed.")
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
	return main

func _teardown_main(main: Node) -> void:
	if main == null:
		return
	main.queue_free()
	await process_frame
	await process_frame

func _lines_contain(lines: Array, needle: String) -> bool:
	for line in lines:
		if String(line).find(needle) != -1:
			return true
	return false

func _fail(main: Node, message: String) -> void:
	print("[FAIL] %s" % message)
	await _teardown_main(main)
	quit(1)
