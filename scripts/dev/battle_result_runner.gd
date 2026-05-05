extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH01_STAGE = preload("res://data/stages/ch01_05_stage.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)

	await process_frame
	await process_frame

	battle.set_stage(CH01_STAGE)
	await process_frame
	await process_frame

	battle.enemy_units.clear()
	if not battle._check_battle_end():
		return _fail("Expected forced victory check to resolve the battle.")

	await process_frame

	var summary: Dictionary = battle.get_last_result_summary()
	if not _assert_summary_shape(summary):
		return
	if not _assert_summary_identity_and_objectives(summary):
		return
	if not _assert_progression_arrays(summary):
		return
	if not _assert_exp_payload(summary):
		return
	if not _assert_telemetry_payload(summary):
		return
	if not _assert_result_dialog(battle):
		return
	if not _assert_result_screen(battle):
		return

	print("[PASS] battle_result_runner: battle result summary exposes objective, records, EXP, telemetry, and result UI.")
	quit(0)


func _assert_summary_shape(summary: Dictionary) -> bool:
	for key: String in [
		"stage_id",
		"title",
		"outcome",
		"objective",
		"stars_earned",
		"turn_limit_met",
		"optional_objectives_completed",
		"optional_objectives_failed",
		"reward_entries",
		"unit_exp_results",
		"bonus_exp_pool",
		"bonus_exp_results",
		"result_tags",
		"bonus_recommendation_line",
		"memory_entries",
		"evidence_entries",
		"letter_entries",
		"fragment_id",
		"command_unlocked",
		"recovered_fragment_ids",
		"unlocked_command_ids",
		"telemetry",
		"telemetry_summary",
		"burden_delta",
		"trust_delta"
	]:
		if not summary.has(key):
			return _fail("Result summary missing key: %s" % key)
	return true


func _assert_summary_identity_and_objectives(summary: Dictionary) -> bool:
	if String(summary.get("stage_id", "")) != "CH01_05":
		return _fail("Result summary should expose CH01_05 stage_id.")
	if String(summary.get("title", "")) != "Victory":
		return _fail("Result summary title should be Victory.")
	if String(summary.get("outcome", "")) != "victory":
		return _fail("Result summary outcome should be victory.")
	if int(summary.get("stars_earned", 0)) != 2:
		return _fail("Forced CH01_05 victory should earn 2 stars: clear plus turn limit.")
	if not bool(summary.get("turn_limit_met", false)):
		return _fail("Forced CH01_05 victory should meet the turn limit.")
	var completed_optional: Array = summary.get("optional_objectives_completed", [])
	var failed_optional: Array = summary.get("optional_objectives_failed", [])
	if not completed_optional.has("no_ally_casualties"):
		return _fail("CH01_05 result should complete no_ally_casualties.")
	if not failed_optional.has("serin_defeats_enemy_commander"):
		return _fail("CH01_05 result should fail serin_defeats_enemy_commander when enemies are force-cleared.")
	return true


func _assert_progression_arrays(summary: Dictionary) -> bool:
	if String(summary.get("fragment_id", "")) != "ch01_fragment":
		return _fail("Result summary should expose ch01_fragment.")
	if String(summary.get("command_unlocked", "")) != "tactical_shift":
		return _fail("Result summary should expose tactical_shift unlock.")
	var recovered_fragment_ids: Array = summary.get("recovered_fragment_ids", [])
	if not recovered_fragment_ids.has("ch01_fragment"):
		return _fail("Result summary should include ch01_fragment in recovered_fragment_ids.")
	var unlocked_command_ids: Array = summary.get("unlocked_command_ids", [])
	if not unlocked_command_ids.has("tactical_shift"):
		return _fail("Result summary should include tactical_shift in unlocked_command_ids.")
	if (summary.get("memory_entries", []) as Array).is_empty():
		return _fail("Result summary should expose at least one memory entry for CH01_05.")
	if (summary.get("evidence_entries", []) as Array).is_empty():
		return _fail("Result summary should expose at least one evidence entry for CH01_05.")
	if (summary.get("letter_entries", []) as Array).is_empty():
		return _fail("Result summary should expose at least one letter entry for CH01_05.")
	return true


func _assert_exp_payload(summary: Dictionary) -> bool:
	var unit_exp_results: Array = summary.get("unit_exp_results", [])
	if unit_exp_results.is_empty():
		return _fail("Result summary should expose unit EXP results after victory.")
	if unit_exp_results.size() != 2:
		return _fail("CH01_05 should grant victory EXP to both allied participants.")
	var seen_exp_units: Array[String] = []
	for entry in unit_exp_results:
		var exp_entry: Dictionary = entry
		for key: String in ["unit_id", "display_name", "level_before", "exp_before", "exp_gain", "level_after", "exp_after", "leveled_up"]:
			if not exp_entry.has(key):
				return _fail("Unit EXP result is missing key: %s" % key)
		seen_exp_units.append(String(exp_entry.get("unit_id", "")))
	if not seen_exp_units.has("ally_vanguard") or not seen_exp_units.has("ally_scout"):
		return _fail("Unit EXP results should cover ally_vanguard and ally_scout.")

	if int(summary.get("bonus_exp_pool", 0)) != 8:
		return _fail("CH01_05 forced victory should expose an 8 point bonus EXP pool.")
	var bonus_exp_results: Array = summary.get("bonus_exp_results", [])
	if bonus_exp_results.size() != 2:
		return _fail("Bonus EXP should be distributed to both CH01_05 allies.")
	var bonus_total := 0
	for entry in bonus_exp_results:
		var bonus_entry: Dictionary = entry
		bonus_total += int(bonus_entry.get("exp_gain", 0))
	if bonus_total != int(summary.get("bonus_exp_pool", 0)):
		return _fail("Distributed bonus EXP should equal bonus_exp_pool.")

	var result_tags: Array = summary.get("result_tags", [])
	if result_tags.is_empty():
		return _fail("Result summary should expose tactical result tags.")
	if not _has_tag_prefix(result_tags, "MVP"):
		return _fail("Result summary should expose an MVP result tag.")
	var bonus_recommendation_line: String = String(summary.get("bonus_recommendation_line", "")).strip_edges()
	if bonus_recommendation_line.find("추천 보너스 대상") == -1:
		return _fail("Result summary should expose recommended bonus target copy.")
	return true


func _assert_telemetry_payload(summary: Dictionary) -> bool:
	var telemetry: Dictionary = summary.get("telemetry", {})
	if telemetry.is_empty():
		return _fail("Result summary should expose telemetry payload.")
	if String(telemetry.get("stage_id", "")) != "CH01_05":
		return _fail("Telemetry payload should retain CH01_05 stage_id.")
	if String(telemetry.get("result", "")) != "victory":
		return _fail("Telemetry payload should record victory result.")
	if int(telemetry.get("rounds", 0)) != 1:
		return _fail("Forced CH01_05 victory telemetry should clear in round 1.")
	if int(telemetry.get("optional_objectives_completed", -1)) != 1:
		return _fail("Telemetry should count one completed optional objective.")
	if int(telemetry.get("optional_objectives_total", -1)) != 2:
		return _fail("Telemetry should count two total optional objectives.")
	if absf(float(telemetry.get("objective_completion_rate", -1.0)) - 0.5) > 0.001:
		return _fail("Telemetry objective_completion_rate should be 0.5 for CH01_05 forced victory.")
	var telemetry_summary: Array = summary.get("telemetry_summary", [])
	if telemetry_summary.is_empty():
		return _fail("Result summary should expose telemetry_summary lines.")
	return true


func _assert_result_dialog(battle: Node) -> bool:
	var dialog_text := String(battle.hud.result_popup.dialog_text)
	if String(battle.hud.result_popup.title) != "Victory":
		return _fail("Battle result popup title should promote the victory outcome heading.")
	for token in [
		"Objective:",
		"Stars Earned:",
		"Turn Limit:",
		"Optional Objectives Completed:",
		"no_ally_casualties",
		"Rewards:",
		"Unit EXP:",
		"Bonus EXP:",
		"Result Tags:",
		"MVP",
		"추천 보너스 대상",
		"Telemetry:",
		"Recovered Fragments:",
		"Unlocked Commands:",
		"Status Counts:",
		"Memory:",
		"Evidence:",
		"Letters:"
	]:
		if dialog_text.find(token) == -1:
			return _fail("Battle result dialog should include '%s'." % token)
	return true


func _assert_result_screen(battle: Node) -> bool:
	if battle.hud.result_screen == null:
		return _fail("Battle HUD should instantiate BattleResultScreen.")
	var result_screen_snapshot: Dictionary = battle.hud.result_screen.get_result_snapshot()
	if not bool(result_screen_snapshot.get("visible", false)):
		return _fail("BattleResultScreen should be visible after victory.")
	if String(result_screen_snapshot.get("title", "")) != "Victory":
		return _fail("BattleResultScreen title should be Victory.")
	if not bool(result_screen_snapshot.get("has_confirm_button", false)):
		return _fail("BattleResultScreen should expose a confirm button.")
	if int(result_screen_snapshot.get("body_lines_count", 0)) < 10:
		return _fail("BattleResultScreen should render a multi-section result body.")

	var screen_body := ""
	if battle.hud.result_screen.body_label != null:
		screen_body = String(battle.hud.result_screen.body_label.text)
	for token in [
		"[b]Objective:[/b]",
		"[b]Unit EXP:[/b]",
		"[b]Bonus EXP:[/b]",
		"[b]Result Tags:[/b]",
		"추천 보너스 대상",
		"[b]Memory Fragment:[/b] ch01_fragment",
		"[b]해금:[/b] tactical_shift",
		"[b]Memory:[/b]",
		"[b]Evidence:[/b]",
		"[b]Letters:[/b]",
		"[b]Telemetry:[/b]"
	]:
		if screen_body.find(token) == -1:
			return _fail("BattleResultScreen body should include '%s'." % token)
	return true


func _has_tag_prefix(tags: Array, prefix: String) -> bool:
	for tag in tags:
		if String(tag).begins_with(prefix):
			return true
	return false

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
