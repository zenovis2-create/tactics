extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const StageData = preload("res://scripts/data/stage_data.gd")
const SupportConversations = preload("res://scripts/data/support_conversations.gd")
const CH10_FINALE_STAGE = preload("res://data/stages/ch10_05_stage.tres")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var campaign = main.campaign_controller
	var battle = main.battle_controller
	if campaign == null or battle == null or battle.bond_service == null or battle.progression_service == null:
		_fail("Runner could not resolve campaign and battle controllers.")
		_finalize()
		return

	var progression = battle.progression_service.get_data()
	progression.reset_for_new_campaign()
	battle.bond_service.reset()

	var support_signal_events: Array[Dictionary] = []
	battle.bond_service.support_progress_updated.connect(func(pair_id: String, new_rank: int) -> void:
		support_signal_events.append({"pair": pair_id, "rank": new_rank})
	)

	_seed_campaign_context(campaign, &"CH04", &"CH04_05")
	_repeat_support_progress(battle, 3)
	await process_frame

	var pair_id := SupportConversations.normalize_pair_id("ally_rian:ally_serin")
	var checkpoint_1: bool = battle.bond_service.get_support_rank(&"ally_rian", &"ally_serin") == 3
	_report_checkpoint(1, checkpoint_1, "Serin reaches C-rank after 3 shared battles")

	var checkpoint_2: bool = _has_rank_signal(support_signal_events, pair_id, 3)
	_report_checkpoint(2, checkpoint_2, "support_progress_updated emitted for the C-rank increase")

	var checkpoint_3: bool = progression.support_history.size() == 1
	_report_checkpoint(3, checkpoint_3, "support_history records exactly one timeline entry at first rank-up")

	_seed_campaign_context(campaign, &"CH06", &"CH06_05")
	_repeat_support_progress(battle, 3)
	_seed_campaign_context(campaign, &"CH09A", &"CH09A_04")
	_repeat_support_progress(battle, 4)
	_seed_campaign_context(campaign, &"CH10", &"CH10_05")
	battle.set_stage(CH10_FINALE_STAGE)
	await process_frame
	await process_frame
	battle.bond_service.promote_name_call_support(&"ally_rian", &"ally_serin")
	battle.record_finale_name_call_fired(&"ally_serin")
	await process_frame

	var checkpoint_4: bool = battle.bond_service.get_support_rank(&"ally_rian", &"ally_serin") >= 6 \
		and _has_rank_signal(support_signal_events, pair_id, 4) \
		and _has_rank_signal(support_signal_events, pair_id, 5) \
		and _has_rank_signal(support_signal_events, pair_id, 6)
	_report_checkpoint(4, checkpoint_4, "The support chain advances through B, A, and S-rank")

	var finale_snapshot: Dictionary = battle.get_finale_result_snapshot()
	var fired_name_call_lines: Dictionary = finale_snapshot.get("fired_name_call_lines", {})
	var expected_s_rank_line := SupportConversations.get_name_call_line("ally_serin", 6)
	var checkpoint_5: bool = String(fired_name_call_lines.get("ally_serin", "")) == expected_s_rank_line
	_report_checkpoint(5, checkpoint_5, "CH10 finale uses Serin's S-rank Name Call line")

	campaign._recruit_unit(&"ally_rian")
	campaign._recruit_unit(&"ally_serin")
	campaign._sync_support_rank_entries()
	main.encyclopedia_panel.show_context(campaign.get_encyclopedia_context())
	await process_frame
	main.encyclopedia_panel._support_history_expanded = true
	main.encyclopedia_panel.select_codex_entry("ally_serin")
	await process_frame
	var history_text := String(main.encyclopedia_panel.get_snapshot().get("support_history_text", ""))
	var checkpoint_6: bool = main.encyclopedia_panel._support_history_toggle != null \
		and main.encyclopedia_panel._support_history_toggle.visible \
		and progression.support_history.size() >= 3 \
		and history_text.find("CH04") != -1
	_report_checkpoint(6, checkpoint_6, "Serin's Codex entry exposes Support History with 3+ timeline beats")

	battle.last_result_summary = {
		"title": "Victory",
		"objective": "Break the bell.",
		"progression_data": progression,
		"stage_id": "CH10_05"
	}
	campaign._enter_chapter_ten_resolution()
	await process_frame
	var result_body := String(battle.hud.result_screen.body_label.text)
	var checkpoint_7: bool = result_body.find("Your closest bond was Serin — S support") != -1
	_report_checkpoint(7, checkpoint_7, "Final result summary highlights Serin as the closest bond")

	_finalize()

func _repeat_support_progress(battle, count: int) -> void:
	for _i in range(count):
		battle.bond_service.register_support_progress(&"ally_rian", &"ally_serin")

func _seed_campaign_context(campaign, chapter_id: StringName, stage_id: StringName) -> void:
	campaign._active_chapter_id = chapter_id
	var stage := StageData.new()
	stage.stage_id = stage_id
	campaign._current_stage = stage

func _has_rank_signal(events: Array[Dictionary], pair_id: String, rank: int) -> bool:
	for event in events:
		if String(event.get("pair", "")) == pair_id and int(event.get("rank", 0)) == rank:
			return true
	return false

func _report_checkpoint(index: int, passed: bool, description: String) -> void:
	print("[RESULT] Checkpoint %d: %s — %s" % [index, "PASS" if passed else "FAIL", description])
	if not passed:
		_failed = true

func _fail(message: String) -> void:
	print("[FAIL] %s" % message)
	_failed = true

func _finalize() -> void:
	if _failed:
		quit(1)
		return
	print("[PASS] cross_system_pipeline_runner: all 7 checkpoints passed.")
	quit(0)
