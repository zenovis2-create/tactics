extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const EndingResolver = preload("res://scripts/battle/ending_resolver.gd")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var true_data := _build_true_ending_progression()
	main.battle_controller.progression_service.load_data(true_data)
	main.battle_controller.bond_service.load_from_progression(true_data)
	main.campaign_controller._active_chapter_id = main.campaign_controller.CHAPTER_CH10
	main.campaign_controller._enter_chapter_ten_resolution()
	await process_frame
	await process_frame

	var snapshot: Dictionary = main.get_campaign_state_snapshot()
	var body_text: String = String(snapshot.get("panel_body", ""))
	if body_text.find("진엔딩 도달") == -1:
		return _fail("True ending resolution body should expose 진엔딩 도달.")
	if body_text.find("다음 시대") == -1 and body_text.find("다시 시작") == -1:
		return _fail("True ending resolution body should mention the future beyond the tower.")

	var cards: Array = main.campaign_panel.get_snapshot().get("presentation_cards", [])
	if cards.size() < 3:
		return _fail("True ending should expose expanded presentation cards.")
	if String(cards[0].get("eyebrow", "")) != "진엔딩":
		return _fail("True ending presentation card should surface the 진엔딩 eyebrow.")
	if String(cards[0].get("title", "")).find("모두의 이름") == -1:
		return _fail("True ending presentation card should mention all names remaining.")

	main.campaign_controller._on_advance_requested()
	await process_frame
	await process_frame
	if main.ending_cutscene_overlay == null or not main.ending_cutscene_overlay.visible:
		return _fail("True ending should play the ending cutscene overlay before the final title card.")
	if not await _wait_for_overlay_text(main.ending_cutscene_overlay, "지워지지 않았어"):
		return _fail("True ending cutscene overlay should expose the all-names-remain cinematic line.")
	if not await _wait_for_overlay_meta(main.ending_cutscene_overlay, "리안", "공동 결말 선언"):
		return _fail("True ending cutscene overlay should expose speaker/mood metadata for the shared-ending declaration beat.")
	var resolution_snapshot: Dictionary = main.ending_cutscene_overlay.get_snapshot()
	if String(resolution_snapshot.get("header", "")).find("ENDING / TRUE") == -1 and String(resolution_snapshot.get("header", "")).find("PHASE") == -1:
		return _fail("True ending cutscene overlay should expose a dedicated header line for the active resolution beat.")

	await create_timer(2.0).timeout
	if not main.ending_overlay.visible:
		return _fail("True ending should show the ending overlay after the cinematic cutscene.")
	if main.ending_label == null or main.ending_label.text.find("True End") == -1:
		return _fail("True ending overlay should expose the True End label.")

	await create_timer(3.05).timeout
	if main.ending_cutscene_overlay == null or not main.ending_cutscene_overlay.visible:
		return _fail("True ending should surface a dedicated companion scene after the ending overlay and before credits.")
	var companion_snapshot: Dictionary = main.ending_cutscene_overlay.get_snapshot()
	if String(companion_snapshot.get("cutscene_id", "")) != "ch10_true_companion_scene":
		return _fail("True ending companion scene should run as its own dedicated cutscene, not as part of the existing resolution cinematic.")
	if String(companion_snapshot.get("header", "")).find("COMPANION") == -1:
		return _fail("True ending companion scene should expose a companion-specific cinematic header.")
	if not await _wait_for_any_overlay_meta(main.ending_cutscene_overlay, PackedStringArray(["행군", "공동", "측면", "기록", "서문"])):
		return _fail("True ending companion scene should expose per-beat mood metadata during the companion roll.")
	if int(companion_snapshot.get("beat_total", 0)) < 6:
		return _fail("True ending companion scene should expose a multi-beat group sequence before credits.")
	if int(companion_snapshot.get("beat_index", -1)) < 0:
		return _fail("True ending companion scene should already be advancing through its own beats when surfaced.")

	await create_timer(2.8).timeout
	if not main.title_screen.visible:
		return _fail("True ending flow should still return to the title screen after the overlay.")

	print("[PASS] true_ending_runner: true ending resolution surface and overlay checks passed.")
	quit(0)

func _build_true_ending_progression() -> ProgressionData:
	var data := ProgressionData.new()
	for flag_id in EndingResolver.REQUIRED_RESONANCE_FLAGS:
		data.flags[String(flag_id)] = true
	data.flags[String(EndingResolver.REQUIRED_NAME_ANCHOR_FLAG)] = true
	data.flags[String(EndingResolver.REQUIRED_NAME_CALL_FLAG)] = true
	return data

func _wait_for_overlay_text(overlay, needle: String, attempts: int = 8, interval: float = 0.3) -> bool:
	for _i in range(attempts):
		if String(overlay.get_snapshot().get("text", "")).find(needle) != -1:
			return true
		await create_timer(interval).timeout
	return false

func _wait_for_overlay_meta(overlay, speaker: String, mood: String, attempts: int = 8, interval: float = 0.3) -> bool:
	for _i in range(attempts):
		var snapshot: Dictionary = overlay.get_snapshot()
		var meta_text := String(snapshot.get("meta", ""))
		if meta_text.find(speaker) != -1 and meta_text.find(mood) != -1:
			return true
		await create_timer(interval).timeout
	return false

func _wait_for_any_overlay_meta(overlay, moods: PackedStringArray, attempts: int = 8, interval: float = 0.3) -> bool:
	for _i in range(attempts):
		var snapshot: Dictionary = overlay.get_snapshot()
		var meta_text := String(snapshot.get("meta", ""))
		for mood in moods:
			if meta_text.find(mood) != -1:
				return true
		await create_timer(interval).timeout
	return false

func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	quit(1)
