extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const EndingResolver = preload("res://scripts/battle/ending_resolver.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_normal_ending_cinematic():
		return
	if not await _assert_true_ending_cinematic():
		return
	print("[PASS] ending_cinematic_runner: all assertions passed.")
	quit(0)

func _assert_normal_ending_cinematic() -> bool:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var data := ProgressionData.new()
	data.burden = 4
	data.trust = 4
	main.battle_controller.progression_service.load_data(data)
	main.battle_controller.bond_service.load_from_progression(data)
	main.campaign_controller._active_chapter_id = main.campaign_controller.CHAPTER_CH10
	main.campaign_controller._enter_chapter_ten_resolution()
	await process_frame
	await process_frame

	main.campaign_controller._on_advance_requested()
	await process_frame
	await process_frame
	if main.ending_cutscene_overlay == null or not main.ending_cutscene_overlay.visible:
		return _fail("Normal ending should also play the cinematic cutscene overlay before title return.")
	if not await _wait_for_overlay_text(main.ending_cutscene_overlay, "내가 대신 안고 내려갈게"):
		return _fail("Normal ending cinematic should expose the Rian sacrifice beat where he takes the bell's remaining burden himself.")
	if not await _wait_for_overlay_meta(main.ending_cutscene_overlay, "리안", "희생 수락"):
		return _fail("Normal ending cinematic should expose per-beat speaker/mood metadata for Rian's sacrifice beat.")
	if not await _wait_for_overlay_text(main.ending_cutscene_overlay, "네 얼굴과 이름부터 먼저 지워질 거야"):
		return _fail("Normal ending cinematic should expose Serin warning that Rian will lose faces and names first.")
	var normal_snapshot: Dictionary = main.ending_cutscene_overlay.get_snapshot()
	if String(normal_snapshot.get("header", "")).find("PHASE") == -1 and String(normal_snapshot.get("header", "")).find("ENDING") == -1:
		return _fail("Normal ending cinematic should expose a header line for the active cinematic phase.")
	if main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingSubtitleLabel") == null:
		return _fail("Ending overlay should expose a dedicated subtitle label for ending-specific mood text.")
	if main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingSigilLabel") == null:
		return _fail("Ending overlay should expose a dedicated sigil label for ending tier emphasis.")
	var ending_accent = main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingAccent")
	if ending_accent == null:
		return _fail("Ending overlay should expose an accent bar for ending-specific tinting.")
	if main.get_node_or_null("UILayer/EndingOverlay/EndingAfterglow") == null:
		return _fail("Ending overlay should expose an afterglow layer for ending-specific transition residue.")
	if main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingPipRow") == null:
		return _fail("Ending overlay should expose a pip row for ending progression.")
	if main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingMemoryRail") == null:
		return _fail("Ending overlay should expose a memory rail for ending progression.")
	if main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingPhaseLabel") == null:
		return _fail("Ending overlay should expose a dedicated phase label for the active ending stage.")
	if main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingEyebrowLabel") == null:
		return _fail("Ending overlay should expose an eyebrow label for the ending tier.")
	if main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingSourceStampLabel") == null:
		return _fail("Ending overlay should expose a source stamp label for the ending source memory.")
	if main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingProgressLabel") == null:
		return _fail("Ending overlay should expose a progress label for the ending completion track.")
	if main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingOutcomeLabel") == null:
		return _fail("Ending overlay should expose an outcome label for the ending result surface.")

	await _drain_ending_flow(main)
	main.queue_free()
	await process_frame
	return true

func _assert_true_ending_cinematic() -> bool:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var data := ProgressionData.new()
	data.last_completed_ending = EndingResolver.ENDING_TRUE
	for flag_id in EndingResolver.REQUIRED_RESONANCE_FLAGS:
		data.flags[String(flag_id)] = true
	data.flags[String(EndingResolver.REQUIRED_NAME_ANCHOR_FLAG)] = true
	data.flags[String(EndingResolver.REQUIRED_NAME_CALL_FLAG)] = true
	main.battle_controller.progression_service.load_data(data)
	main.battle_controller.bond_service.load_from_progression(data)
	main.campaign_controller._active_chapter_id = main.campaign_controller.CHAPTER_CH10
	main.campaign_controller._enter_chapter_ten_resolution()
	await process_frame
	await process_frame

	main.campaign_controller._on_advance_requested()
	await process_frame
	await process_frame
	if main.ending_cutscene_overlay == null or not main.ending_cutscene_overlay.visible:
		return _fail("True ending should also play the cinematic cutscene overlay before title return.")
	if not await _wait_for_overlay_text(main.ending_cutscene_overlay, "모든 이름은 다음 사람에게 건네진다"):
		return _fail("True ending cinematic should expose the handoff line about all names remaining.")
	if not await _wait_for_overlay_meta(main.ending_cutscene_overlay, "노아", "인계 선언"):
		return _fail("True ending cinematic should expose per-beat speaker/mood metadata for the name handoff beat.")
	var true_snapshot: Dictionary = main.ending_cutscene_overlay.get_snapshot()
	if String(true_snapshot.get("header", "")).find("PHASE 03 / NAME HANDOFF") == -1:
		return _fail("True ending cinematic should expose a dedicated header line for the name handoff phase.")
	var subtitle_label = main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingSubtitleLabel")
	if subtitle_label == null or String(subtitle_label.text).find("모든 이름이 남았다") == -1:
		return _fail("True ending overlay should expose a dedicated subtitle line about all names remaining.")
	var sigil_label = main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingSigilLabel")
	if sigil_label == null or String(sigil_label.text).find("ALL NAMES REMAIN") == -1:
		return _fail("True ending overlay should expose a stronger sigil line for the ending tier.")
	var ending_accent = main.get_node("UILayer/EndingOverlay/Center/EndingStack/EndingAccent")
	if ending_accent.color.b < 0.85:
		return _fail("True ending overlay should tint the accent bar toward the cooler true-ending palette.")
	var ending_fade = main.get_node("UILayer/EndingOverlay/Fade")
	if ending_fade.color.b < 0.12:
		return _fail("True ending overlay should also cool the full-screen fade tint.")
	var ending_afterglow = main.get_node("UILayer/EndingOverlay/EndingAfterglow")
	if ending_afterglow.color.b < 0.16:
		return _fail("True ending overlay should tint the afterglow layer toward the cooler true-ending palette.")
	var pip_row = main.get_node("UILayer/EndingOverlay/Center/EndingStack/EndingPipRow")
	if pip_row.get_child_count() < 2:
		return _fail("Ending overlay pip row should contain at least two pips.")
	var second_pip = pip_row.get_child(1)
	if second_pip.color.b < 0.85:
		return _fail("True ending should light the second ending pip.")
	var memory_rail = main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingMemoryRail")
	if memory_rail == null or memory_rail.color.b < 0.85:
		return _fail("True ending overlay should tint the memory rail toward the active ending palette.")
	var phase_label = main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingPhaseLabel")
	if phase_label == null or String(phase_label.text).find("이름 인계") == -1:
		return _fail("True ending overlay should expose a dedicated phase label about the name handoff stage.")
	var eyebrow_label = main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingEyebrowLabel")
	if eyebrow_label == null or String(eyebrow_label.text).find("True Ending") == -1:
		return _fail("True ending overlay should expose an eyebrow label for the ending tier.")
	var source_stamp = main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingSourceStampLabel")
	if source_stamp == null or String(source_stamp.text).find("TRUE / CH10 Resolution") == -1:
		return _fail("True ending overlay should expose a source stamp label for the ending source memory.")
	var progress_label = main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingProgressLabel")
	if progress_label == null or String(progress_label.text).find("2/2") == -1:
		return _fail("True ending overlay should expose a completed ending progress label.")
	var outcome_label = main.get_node_or_null("UILayer/EndingOverlay/Center/EndingStack/EndingOutcomeLabel")
	if outcome_label == null or String(outcome_label.text).find("공동의 미래") == -1:
		return _fail("True ending overlay should expose a dedicated outcome label about the shared future it leaves behind.")
	var visual_stack: Array = main.get_ending_visual_stack()
	if not visual_stack.has("rail:true_ending") or not visual_stack.has("outcome:true_ending") or not visual_stack.has("afterglow:true_ending"):
		return _fail("True ending visual stack should summarize rail, outcome, and afterglow layers.")

	await _drain_ending_flow(main)
	main.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false

func _wait_for_overlay_text(overlay, needle: String, attempts: int = 8) -> bool:
	for _i in range(attempts):
		if String(overlay.get_snapshot().get("text", "")).find(needle) != -1:
			return true
		await create_timer(0.3).timeout
	return false

func _wait_for_overlay_meta(overlay, speaker: String, mood: String, attempts: int = 8) -> bool:
	for _i in range(attempts):
		var snapshot: Dictionary = overlay.get_snapshot()
		var meta_text := String(snapshot.get("meta", ""))
		if meta_text.find(speaker) != -1 and meta_text.find(mood) != -1:
			return true
		await create_timer(0.3).timeout
	return false

func _drain_ending_flow(main: Node, attempts: int = 40) -> void:
	for _i in range(attempts):
		if main == null or not is_instance_valid(main):
			return
		if main.ending_cutscene_overlay != null and main.ending_cutscene_overlay.is_playing():
			main.ending_cutscene_overlay.advance_immediate()
		await create_timer(0.25).timeout
