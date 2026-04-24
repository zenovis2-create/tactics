extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const EndingResolver = preload("res://scripts/battle/ending_resolver.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")

const SANDBOX_SAVE_SLOTS := [0, 1, 2, SaveService.AUTOSAVE_SLOT]

var _save_slot_backup: Dictionary = {}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_begin_save_sandbox()
	if not await _assert_postgame_title_surface():
		return
	if not await _assert_postgame_criteria_surface():
		return
	if not await _assert_credits_overlay_surface():
		return
	_restore_save_sandbox()
	print("[PASS] postgame_surface_runner: all assertions passed.")
	quit(0)

func _assert_postgame_title_surface() -> bool:
	var svc := SaveService.new()
	root.add_child(svc)
	await process_frame
	for slot in 3:
		svc.delete_slot(slot)
	svc.delete_slot(SaveService.AUTOSAVE_SLOT)
	var data := ProgressionData.new()
	data.ng_plus_available = true
	data.last_completed_ending = EndingResolver.ENDING_TRUE
	svc.save_progression(data, 0, {"autosave_reason": "CH10 최종 결말"})

	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var snapshot: Dictionary = main.title_screen.get_layout_snapshot()
	if not bool(snapshot.get("postgame_summary_visible", false)):
		return _fail("Title screen should expose a postgame summary when NG+ is available.")
	if String(snapshot.get("last_completed_ending", "")) != "true_ending":
		return _fail("Title screen snapshot should expose the last completed ending.")
	if String(snapshot.get("postgame_source_label", "")) == "":
		return _fail("Title screen snapshot should expose which save source drives the postgame summary.")
	if main.title_screen.postgame_summary_label.text.find("진엔딩") == -1:
		return _fail("Title screen postgame summary should mention the latest ending tier.")
	if main.title_screen.postgame_summary_label.text.find("공명") == -1:
		return _fail("Title screen postgame summary should mention ending criteria progress.")
	if main.title_screen.postgame_summary_label.text.find("기준 저장") == -1:
		return _fail("Title screen postgame summary should mention whether autosave or manual save is the source.")
	if main.title_screen.get_layout_snapshot().get("postgame_source_reason", "") == "":
		return _fail("Title screen snapshot should expose the checkpoint reason for the postgame source.")

	main.queue_free()
	svc.delete_slot(0)
	svc.queue_free()
	await process_frame
	return true

func _assert_postgame_criteria_surface() -> bool:
	var svc := SaveService.new()
	root.add_child(svc)
	await process_frame
	for slot in 3:
		svc.delete_slot(slot)
	svc.delete_slot(SaveService.AUTOSAVE_SLOT)
	var data := ProgressionData.new()
	data.ng_plus_available = true
	data.last_completed_ending = EndingResolver.ENDING_TRUE
	for flag_id in EndingResolver.REQUIRED_RESONANCE_FLAGS:
		data.flags[String(flag_id)] = true
	data.flags[String(EndingResolver.REQUIRED_NAME_ANCHOR_FLAG)] = true
	data.flags[String(EndingResolver.REQUIRED_NAME_CALL_FLAG)] = true
	svc.save_progression(data, 0)

	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var summary_text: String = String(main.title_screen.postgame_summary_label.text)
	if summary_text.find("공명 인장") == -1:
		return _fail("Postgame title summary should expose resonance seal status.")
	if summary_text.find("이름 앵커") == -1:
		return _fail("Postgame title summary should expose name-anchor status.")
	if summary_text.find("이름 부름") == -1:
		return _fail("Postgame title summary should expose name-call status.")

	main.queue_free()
	svc.delete_slot(0)
	svc.queue_free()
	await process_frame
	return true

func _assert_credits_overlay_surface() -> bool:
	var companion_scene = CutsceneCatalog.get_cutscene(&"ch10_true_companion_scene")
	if companion_scene == null:
		return _fail("True ending should register a dedicated companion scene cutscene before credits.")
	if companion_scene.beats.size() < 6:
		return _fail("True ending companion scene should contain multiple companion beats, not a single cosmetic card.")
	if String(companion_scene.beats[1].get("speaker", "")) != "세린" or String(companion_scene.beats[1].get("text", "")).find("이제 내려가자") == -1:
		return _fail("True ending companion scene should open with a group handoff line from Serin.")
	if String(companion_scene.beats[2].get("speaker", "")) != "브란" or String(companion_scene.beats[2].get("text", "")).find("방패는 이제 뒤가 아니라 옆에 선 사람들을 위해 든다") == -1:
		return _fail("True ending companion scene should include Bran's distinct companion follow-up line.")
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var normal_sections: Array[String] = main._build_end_credits_sections(EndingResolver.ENDING_NORMAL)
	if normal_sections.size() < 4:
		return _fail("Normal credits roll should provide at least four ending sections after the cinematic.")
	if String(normal_sections[2]).find("리안은 마지막 공명을 혼자 받아낸다") == -1:
		return _fail("Normal credits roll should surface the Rian sacrifice aftermath in its third section.")
	var sections: Array[String] = main._build_end_credits_sections(EndingResolver.ENDING_TRUE)
	if sections.size() < 4:
		return _fail("Credits roll should provide at least four ending sections after the cinematic.")
	if String(sections[0]).find("진엔딩 후일담") == -1:
		return _fail("Credits roll should expose an ending-specific heading in the opening section.")
	if String(sections[1]).find("남은 이름들") == -1:
		return _fail("Credits roll second section should surface the surviving-name roll.")
	if String(sections[2]).find("다음 시대") == -1:
		return _fail("True ending credits should include a future-facing section.")
	if String(sections[3]).find("기억을 남긴 사람들") == -1:
		return _fail("Credits roll should end on the witness/legacy section.")
	if main.get_node_or_null("UILayer/CreditsOverlay/Center/CreditsStack/CreditsEyebrow") == null:
		return _fail("Credits overlay should expose a dedicated eyebrow label for the section context.")
	if main.get_node_or_null("UILayer/CreditsOverlay/Center/CreditsStack/CreditsProgressLabel") == null:
		return _fail("Credits overlay should expose a dedicated progress label for the current section.")
	if main.get_node_or_null("UILayer/CreditsOverlay/Center/CreditsStack/CreditsPipRow") == null:
		return _fail("Credits overlay should expose a pip row for section progression.")
	if main.get_node_or_null("UILayer/CreditsOverlay/CreditsAfterglow") == null:
		return _fail("Credits overlay should expose an afterglow layer for credits transition residue.")
	if main.get_node_or_null("UILayer/CreditsOverlay/Center/CreditsStack/CreditsMemoryRail") == null:
		return _fail("Credits overlay should expose a dedicated memory rail for section progression.")
	if main.get_node_or_null("UILayer/CreditsOverlay/Center/CreditsStack/CreditsPhaseLabel") == null:
		return _fail("Credits overlay should expose a dedicated phase label for the active credits transition.")
	if main.get_node_or_null("UILayer/CreditsOverlay/Center/CreditsStack/CreditsTierLabel") == null:
		return _fail("Credits overlay should expose a dedicated tier label for the active credits roll.")
	if main.get_node_or_null("UILayer/CreditsOverlay/Center/CreditsStack/CreditsSourceStampLabel") == null:
		return _fail("Credits overlay should expose a dedicated source stamp label for the current credits memory source.")
	if main.get_node_or_null("UILayer/CreditsOverlay/Center/CreditsStack/CreditsRowLabel") == null:
		return _fail("Credits overlay should expose a dedicated row label for the credits completion track.")
	if main.get_node_or_null("UILayer/CreditsOverlay/Center/CreditsStack/CreditsOutcomeLabel") == null:
		return _fail("Credits overlay should expose a dedicated outcome label for the active credits section.")
	await main._show_end_credits(EndingResolver.ENDING_TRUE)
	var eyebrow = main.get_node("UILayer/CreditsOverlay/Center/CreditsStack/CreditsEyebrow")
	if String(eyebrow.text).find("기억을 남긴 사람들") == -1:
		return _fail("Credits overlay eyebrow should track the active credits section heading through the final section.")
	var progress = main.get_node("UILayer/CreditsOverlay/Center/CreditsStack/CreditsProgressLabel")
	if String(progress.text).find("4/4") == -1:
		return _fail("Credits overlay should track the current section index through the final section.")
	var phase = main.get_node("UILayer/CreditsOverlay/Center/CreditsStack/CreditsPhaseLabel")
	if String(phase.text).find("증언 보존") == -1:
		return _fail("Credits overlay should surface a dedicated phase label for the final witness/legacy section.")
	var tier_label = main.get_node("UILayer/CreditsOverlay/Center/CreditsStack/CreditsTierLabel")
	if String(tier_label.text).find("True Ending Roll") == -1:
		return _fail("Credits overlay should surface a dedicated tier label for the active credits roll.")
	var source_stamp = main.get_node("UILayer/CreditsOverlay/Center/CreditsStack/CreditsSourceStampLabel")
	if String(source_stamp.text).find("TRUE / Witness Roll") == -1:
		return _fail("Credits overlay should surface a dedicated source stamp for the final credits section.")
	var row_label = main.get_node("UILayer/CreditsOverlay/Center/CreditsStack/CreditsRowLabel")
	if String(row_label.text).find("ROW 4/4") == -1:
		return _fail("Credits overlay should surface a dedicated row label for the final credits section.")
	var outcome_label = main.get_node("UILayer/CreditsOverlay/Center/CreditsStack/CreditsOutcomeLabel")
	if String(outcome_label.text).find("증언이 다음 기록으로 남는다") == -1:
		return _fail("Credits overlay should surface a dedicated outcome label for the final witness section.")
	var accent = main.get_node("UILayer/CreditsOverlay/Center/CreditsStack/CreditsAccent")
	if accent.color.r < 0.85:
		return _fail("Credits overlay final section should tint the accent bar toward the brighter witness/legacy palette.")
	var fade = main.get_node("UILayer/CreditsOverlay/Fade")
	if fade.color.r < 0.08:
		return _fail("Credits overlay final section should also tint the full-screen fade toward the witness/legacy palette.")
	var afterglow = main.get_node("UILayer/CreditsOverlay/CreditsAfterglow")
	if afterglow.color.r < 0.12:
		return _fail("Credits overlay should tint the afterglow layer toward the active final-section palette.")
	var pip_row = main.get_node("UILayer/CreditsOverlay/Center/CreditsStack/CreditsPipRow")
	if pip_row.get_child_count() < 4:
		return _fail("Credits overlay pip row should contain at least four pips.")
	var final_pip = pip_row.get_child(3)
	if final_pip.color.r < 0.85:
		return _fail("Credits overlay should light the final pip at the final section.")
	var memory_rail = main.get_node("UILayer/CreditsOverlay/Center/CreditsStack/CreditsMemoryRail")
	if memory_rail.color.r < 0.85:
		return _fail("Credits overlay should tint the memory rail toward the active final-section palette.")
	var visual_stack: Array = main.get_credits_visual_stack()
	if not visual_stack.has("rail:3") or not visual_stack.has("outcome:3") or not visual_stack.has("afterglow:3"):
		return _fail("Credits visual stack should summarize final-section rail, outcome, and afterglow layers.")
	main.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	_restore_save_sandbox()
	push_error(message)
	quit(1)
	return false

func _begin_save_sandbox() -> void:
	_save_slot_backup.clear()
	DirAccess.make_dir_recursive_absolute(SaveService.SAVE_DIR)
	for slot: int in SANDBOX_SAVE_SLOTS:
		_save_slot_backup[slot] = {
			"save": _read_file_bytes(_slot_path(slot, SaveService.SLOT_EXT)),
			"sidecar": _read_file_bytes(_slot_path(slot, SaveService.SIDECAR_EXT))
		}

func _restore_save_sandbox() -> void:
	if _save_slot_backup.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(SaveService.SAVE_DIR)
	for slot: int in SANDBOX_SAVE_SLOTS:
		var snapshot: Dictionary = _save_slot_backup.get(slot, {})
		_write_or_remove_file(_slot_path(slot, SaveService.SLOT_EXT), snapshot.get("save", PackedByteArray()))
		_write_or_remove_file(_slot_path(slot, SaveService.SIDECAR_EXT), snapshot.get("sidecar", PackedByteArray()))
	_save_slot_backup.clear()

func _slot_path(slot: int, ext: String) -> String:
	return SaveService.SAVE_DIR + SaveService.SLOT_PREFIX + str(slot) + ext

func _read_file_bytes(path: String) -> PackedByteArray:
	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		return PackedByteArray()
	var file := FileAccess.open(absolute_path, FileAccess.READ)
	if file == null:
		return PackedByteArray()
	var bytes := file.get_buffer(file.get_length())
	file.close()
	return bytes

func _write_or_remove_file(path: String, bytes: PackedByteArray) -> void:
	var absolute_path := ProjectSettings.globalize_path(path)
	if bytes.is_empty():
		if FileAccess.file_exists(absolute_path):
			DirAccess.remove_absolute(absolute_path)
		return
	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	if file == null:
		push_warning("Could not restore sandboxed save file %s" % path)
		return
	file.store_buffer(bytes)
	file.close()
