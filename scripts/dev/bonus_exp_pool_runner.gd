extends SceneTree

const ProgressionService = preload("res://scripts/battle/progression_service.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var svc := ProgressionService.new()
	root.add_child(svc)
	await process_frame

	var data = svc.get_data()
	data.set_unit_progress(&"ally_rian", 5, 0)
	data.set_unit_progress(&"ally_serin", 1, 0)
	data.set_unit_progress(&"ally_kyle", 1, 0)

	if not svc.has_method("grant_bonus_exp_pool"):
		return _fail("ProgressionService must expose grant_bonus_exp_pool().")

	var result: Dictionary = svc.grant_bonus_exp_pool(
		[&"ally_rian", &"ally_serin", &"ally_kyle"],
		{"ally_rian": 3, "ally_serin": 0, "ally_kyle": 1},
		&"CH01_05"
	)
	if int(result.get("pool", 0)) <= 0:
		return _fail("Bonus EXP pool should be positive when units participate in battle.")
	var results: Array = result.get("results", [])
	if results.size() != 3:
		return _fail("Bonus EXP pool should return one entry per unit.")
	var exp_by_unit := {}
	for entry in results:
		exp_by_unit[String(entry.get("unit_id", ""))] = int(entry.get("exp_gain", -1))
	if int(exp_by_unit.get("ally_serin", -1)) <= int(exp_by_unit.get("ally_rian", -1)):
		return _fail("Lower-level low-contribution unit should receive more bonus EXP than the overleveled contributor.")
	if data.bonus_exp_history.is_empty():
		return _fail("Bonus EXP distribution should append a history entry for persistence.")

	print("[PASS] bonus_exp_pool_runner: all assertions passed.")
	quit(0)

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
