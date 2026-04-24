extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const EndingResolver = preload("res://scripts/battle/ending_resolver.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_resolution_panel_criteria_surface():
		return
	print("[PASS] ending_criteria_ui_runner: all assertions passed.")
	quit(0)

func _assert_resolution_panel_criteria_surface() -> bool:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var data := ProgressionData.new()
	for flag_id in EndingResolver.REQUIRED_RESONANCE_FLAGS:
		data.flags[String(flag_id)] = true
	data.flags[String(EndingResolver.REQUIRED_NAME_ANCHOR_FLAG)] = true
	main.battle_controller.progression_service.load_data(data)
	main.battle_controller.bond_service.load_from_progression(data)
	main.campaign_controller._active_chapter_id = main.campaign_controller.CHAPTER_CH10
	main.campaign_controller._enter_chapter_ten_resolution()
	await process_frame
	await process_frame

	var snapshot: Dictionary = main.campaign_panel.get_snapshot()
	var body_text: String = String(snapshot.get("body", ""))
	if body_text.find("공명 인장 6/6") == -1:
		return _fail("CH10 resolution body should expose resonance completion count.")
	if body_text.find("이름 앵커 유지") == -1:
		return _fail("CH10 resolution body should expose name-anchor requirement status.")
	if body_text.find("이름 부름 미완") == -1:
		return _fail("CH10 resolution body should expose name-call requirement status when criteria are still incomplete.")
	if body_text.find("현재 판정: 일반 엔딩") == -1:
		return _fail("CH10 resolution body should expose the current ending verdict alongside the criteria checklist.")
	var cards: Array = snapshot.get("presentation_cards", [])
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if String(card.get("title", "")) == "최종 진엔딩 기준":
			var progress_rows: Array = card.get("progress_rows", [])
			if progress_rows.size() < 3:
				return _fail("Ending criteria card should expose progress rows for resonance, anchors, and name calls.")
			var first_row: Dictionary = progress_rows[0] if progress_rows[0] is Dictionary else {}
			if String(first_row.get("icon", "")).is_empty() or String(first_row.get("hint", "")).is_empty():
				return _fail("Ending criteria progress rows should expose icon and hint metadata for richer UI polish.")
			main.queue_free()
			await process_frame
			return true
	return _fail("CH10 resolution should surface a dedicated ending criteria card.")

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
