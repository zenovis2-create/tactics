extends SceneTree

const ProgressionService = preload("res://scripts/battle/progression_service.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var svc := ProgressionService.new()
	root.add_child(svc)
	await process_frame

	var initial: Dictionary = svc.get_unit_progress(&"ally_rian")
	if int(initial.get("level", 0)) != 1 or int(initial.get("exp", -1)) != 0:
		return _fail("Default unit progression should start at level 1 exp 0.")

	var gain: Dictionary = svc.grant_unit_exp(&"ally_rian", 15, "runner")
	if int(gain.get("level_after", 0)) != 2 or int(gain.get("exp_after", -1)) != 3:
		return _fail("grant_unit_exp should carry over EXP after a level-up.")
	if not bool(gain.get("leveled_up", false)):
		return _fail("grant_unit_exp should mark leveled_up when a threshold is crossed.")

	var victory_results: Array = svc.grant_victory_exp([&"ally_rian", &"ally_serin"])
	if victory_results.size() != 2:
		return _fail("grant_victory_exp should return one result per ally.")
	var serin: Dictionary = svc.get_unit_progress(&"ally_serin")
	if int(serin.get("level", 0)) != 1 or int(serin.get("exp", -1)) != 8:
		return _fail("Victory EXP tuning should move a fresh ally forward without forcing an immediate level-up.")
	var post_victory_rian: Dictionary = svc.get_unit_progress(&"ally_rian")
	if int(post_victory_rian.get("level", 0)) != 2 or int(post_victory_rian.get("exp", -1)) != 11:
		return _fail("Victory EXP should preserve carry-over pacing for already-leveled units.")

	var data := svc.get_data()
	if data.burden != 0 or data.trust != 0:
		return _fail("Unit EXP progression must not modify burden or trust.")

	print("[PASS] s7_unit_progression_runner: all assertions passed.")
	quit(0)

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
