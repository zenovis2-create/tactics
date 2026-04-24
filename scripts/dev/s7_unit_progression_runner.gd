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
	if int(gain.get("level_after", 0)) != 2 or int(gain.get("exp_after", -1)) != 5:
		return _fail("grant_unit_exp should carry over EXP after a level-up.")
	if not bool(gain.get("leveled_up", false)):
		return _fail("grant_unit_exp should mark leveled_up when a threshold is crossed.")

	var victory_results: Array = svc.grant_victory_exp([&"ally_rian", &"ally_serin"])
	if victory_results.size() != 2:
		return _fail("grant_victory_exp should return one result per ally.")
	var bonus_result: Dictionary = svc.grant_bonus_exp_pool([&"ally_rian", &"ally_serin"], {"ally_rian": 2, "ally_serin": 0}, &"CH01_05")
	if int(bonus_result.get("pool", 0)) <= 0:
		return _fail("grant_bonus_exp_pool should return a positive pool for participating allies.")
	var bonus_results: Array = bonus_result.get("results", [])
	if bonus_results.size() != 2:
		return _fail("grant_bonus_exp_pool should return one result per ally.")
	var serin: Dictionary = svc.get_unit_progress(&"ally_serin")
	if int(serin.get("level", 0)) != 2 or int(serin.get("exp", -1)) <= 0:
		return _fail("Bonus EXP should increase a fresh ally beyond the flat victory reward.")
	if svc.get_data().bonus_exp_history.is_empty():
		return _fail("Bonus EXP distribution should be persisted into bonus_exp_history.")

	var data := svc.get_data()
	if data.burden != 0 or data.trust != 0:
		return _fail("Unit EXP progression must not modify burden or trust.")

	print("[PASS] s7_unit_progression_runner: all assertions passed.")
	quit(0)

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
