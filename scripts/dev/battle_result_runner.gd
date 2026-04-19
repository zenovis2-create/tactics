extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH01_STAGE = preload("res://data/stages/ch01_05_stage.tres")
const CH10_FINALE_STAGE = preload("res://data/stages/ch10_05_stage.tres")

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
	for key: String in [
		"outcome",
		"objective",
		"reward_entries",
		"unit_exp_results",
		"memory_entries",
		"evidence_entries",
		"letter_entries",
		"fragment_id",
		"command_unlocked",
		"burden_delta",
		"trust_delta"
	]:
		if not summary.has(key):
			return _fail("Result summary missing key: %s" % key)

	if String(summary.get("outcome", "")) != "victory":
		return _fail("Result summary outcome should be victory.")
	if String(summary.get("fragment_id", "")) != "ch01_fragment":
		return _fail("Result summary should expose ch01_fragment.")
	if String(summary.get("command_unlocked", "")) != "tactical_shift":
		return _fail("Result summary should expose tactical_shift unlock.")
	if (summary.get("memory_entries", []) as Array).is_empty():
		return _fail("Result summary should expose at least one memory entry for CH01_05.")
	if (summary.get("evidence_entries", []) as Array).is_empty():
		return _fail("Result summary should expose at least one evidence entry for CH01_05.")
	if (summary.get("letter_entries", []) as Array).is_empty():
		return _fail("Result summary should expose at least one letter entry for CH01_05.")
	var unit_exp_results: Array = summary.get("unit_exp_results", [])
	if unit_exp_results.is_empty():
		return _fail("Result summary should expose unit EXP results after victory.")
	var first_exp: Dictionary = unit_exp_results[0]
	for key: String in ["unit_id", "display_name", "level_before", "exp_before", "exp_gain", "level_after", "exp_after", "leveled_up"]:
		if not first_exp.has(key):
			return _fail("Unit EXP result is missing key: %s" % key)

	var dialog_text := String(battle.hud.result_popup.dialog_text)
	if String(battle.hud.result_popup.title) != "Victory":
		return _fail("Battle result popup title should promote the victory outcome heading.")
	for token in [
		"Objective:",
		"Rewards:",
		"Memory Fragment: ch01_fragment",
		"Command Unlocked: tactical_shift",
		"Unit EXP:",
		"Memory:",
		"Evidence:",
		"Letters:"
	]:
		if dialog_text.find(token) == -1:
			return _fail("Battle result dialog should include '%s'." % token)

	var finale_battle = BATTLE_SCENE.instantiate()
	root.add_child(finale_battle)
	await process_frame
	await process_frame

	finale_battle.set_stage(CH10_FINALE_STAGE)
	await process_frame
	await process_frame

	finale_battle.enemy_units.clear()
	if not finale_battle._check_battle_end():
		return _fail("Expected CH10_05 forced victory check to resolve the finale battle.")

	await process_frame

	var finale_summary: Dictionary = finale_battle.get_last_result_summary()
	if not finale_summary.has("finale_result"):
		return _fail("CH10_05 result summary should expose finale_result.")

	var finale_result: Dictionary = finale_summary.get("finale_result", {})
	for key: String in [
		"name_anchor_total",
		"name_anchors_remaining",
		"name_call_moments_fired",
		"required_name_call_count",
		"minimum_anchor_condition_met",
		"minimum_name_anchors_required",
		"remaining_name_anchor_ids",
		"fired_name_call_ids"
	]:
		if not finale_result.has(key):
			return _fail("CH10_05 finale_result missing key: %s" % key)

	if int(finale_result.get("name_anchor_total", 0)) != 4:
		return _fail("CH10_05 finale_result should report four total anchors.")
	if int(finale_result.get("minimum_name_anchors_required", 0)) != 2:
		return _fail("CH10_05 finale_result should report a minimum of two anchors.")
	if int(finale_result.get("required_name_call_count", 0)) != 6:
		return _fail("CH10_05 finale_result should report six required name-call moments for the true route.")
	if int(finale_result.get("name_call_moments_fired", -1)) < 0:
		return _fail("CH10_05 finale_result should expose a non-negative name-call count.")

	print("[PASS] battle_result_runner: battle result summary exposes objective, records, and progression unlocks.")
	quit(0)

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
