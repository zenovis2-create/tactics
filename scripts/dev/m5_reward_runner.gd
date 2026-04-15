extends SceneTree

## M5 reward integrity acceptance gate.
## SYS-017~020: policy validator, deterministic seed, safety valve.

const RewardService = preload("res://scripts/battle/reward_service.gd")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var svc := RewardService.new()
	root.add_child(svc)
	await process_frame

	if not _assert_drop_seed_deterministic(svc): return
	if not _assert_policy_valid_batch(svc): return
	if not _assert_policy_rejects_no_counter_tool(svc): return
	if not _assert_policy_rejects_stat_overflow(svc): return
	if not _assert_pick_rewards_deterministic(svc): return
	if not _assert_safety_valve_injects(svc): return
	if not _assert_safety_valve_skips_when_powered(svc): return
	if not _assert_attempt_counter(svc): return

	print("[PASS] M5 reward runner: all assertions passed.")
	quit(0)

func _assert_drop_seed_deterministic(svc: RewardService) -> bool:
	var s1 := svc.generate_drop_seed(&"tutorial_stage", 1)
	var s2 := svc.generate_drop_seed(&"tutorial_stage", 1)
	var s3 := svc.generate_drop_seed(&"tutorial_stage", 2)
	if s1 != s2:
		return _fail("Same stage+attempt must produce same seed")
	if s1 == s3:
		return _fail("Different attempt should produce different seed")
	return true

func _assert_policy_valid_batch(svc: RewardService) -> bool:
	var batch := [
		{"id": "counter_herb", "category": RewardService.CAT_COUNTER_TOOL, "stat_bonus": 0},
		{"id": "vitality_shard", "category": RewardService.CAT_STAT_BOOST, "stat_bonus": 3},
		{"id": "echo_rune", "category": RewardService.CAT_CONSUMABLE, "stat_bonus": 0},
		{"id": "memory_sliver", "category": RewardService.CAT_STORY, "stat_bonus": 0},
	]
	var result := svc.validate_reward_policy(batch)
	if not bool(result.get("valid", false)):
		return _fail("Valid batch should pass policy. Violations: %s" % str(result.get("violations", [])))
	return true

func _assert_policy_rejects_no_counter_tool(svc: RewardService) -> bool:
	var batch := [
		{"id": "sword_plus", "category": RewardService.CAT_STAT_BOOST, "stat_bonus": 2},
		{"id": "shield_plus", "category": RewardService.CAT_STAT_BOOST, "stat_bonus": 2},
		{"id": "ring_plus", "category": RewardService.CAT_STAT_BOOST, "stat_bonus": 2},
	]
	var result := svc.validate_reward_policy(batch)
	if bool(result.get("valid", true)):
		return _fail("Batch with no counter-tools should fail policy (ratio too low)")
	return true

func _assert_policy_rejects_stat_overflow(svc: RewardService) -> bool:
	var batch := [
		{"id": "overpowered_ring", "category": RewardService.CAT_COUNTER_TOOL, "stat_bonus": 99},
	]
	var result := svc.validate_reward_policy(batch)
	if bool(result.get("valid", true)):
		return _fail("Reward exceeding max stat bonus should fail policy")
	return true

func _assert_pick_rewards_deterministic(svc: RewardService) -> bool:
	var pool := [
		{"id": "a"}, {"id": "b"}, {"id": "c"}, {"id": "d"}, {"id": "e"}
	]
	var seed := svc.generate_drop_seed(&"ch01_stage", 1)
	var pick1 := svc.pick_rewards(pool, seed, 2)
	var pick2 := svc.pick_rewards(pool, seed, 2)
	if pick1.size() != 2:
		return _fail("pick_rewards should return exactly 2 items")
	if pick1[0].get("id") != pick2[0].get("id") or pick1[1].get("id") != pick2[1].get("id"):
		return _fail("pick_rewards must be deterministic for same seed")
	return true

func _assert_safety_valve_injects(svc: RewardService) -> bool:
	var batch := [
		{"id": "sword_plus", "category": RewardService.CAT_STAT_BOOST, "stat_bonus": 1},
	]
	var fallback := {"id": "clarity_herb", "category": RewardService.CAT_COUNTER_TOOL, "stat_bonus": 0}
	var result := svc.apply_underpowered_safety(batch, 3.0, 5.0, fallback)
	var has_counter := false
	for r in result:
		if r.get("category") == RewardService.CAT_COUNTER_TOOL:
			has_counter = true
	if not has_counter:
		return _fail("Safety valve should inject counter_tool when squad is underpowered")
	return true

func _assert_safety_valve_skips_when_powered(svc: RewardService) -> bool:
	var batch := [
		{"id": "sword_plus", "category": RewardService.CAT_STAT_BOOST, "stat_bonus": 1},
	]
	var fallback := {"id": "clarity_herb", "category": RewardService.CAT_COUNTER_TOOL, "stat_bonus": 0}
	var result := svc.apply_underpowered_safety(batch, 8.0, 5.0, fallback)
	if result.size() != batch.size():
		return _fail("Safety valve should not modify batch when squad is at or above threshold")
	return true

func _assert_attempt_counter(svc: RewardService) -> bool:
	var fresh := RewardService.new()
	root.add_child(fresh)
	if fresh.get_attempt_count(&"ch02") != 0:
		return _fail("Initial attempt count should be 0")
	fresh.record_stage_entry(&"ch02")
	fresh.record_stage_entry(&"ch02")
	if fresh.get_attempt_count(&"ch02") != 2:
		return _fail("Attempt count should be 2 after two entries")
	var s1 := fresh.generate_drop_seed(&"ch02", 1)
	var s2 := fresh.generate_drop_seed(&"ch02", 2)
	if s1 == s2:
		return _fail("Different attempt counts should yield different seeds")
	fresh.queue_free()
	return true

func _fail(msg: String) -> bool:
	print("[FAIL] ", msg)
	_failed = true
	quit(1)
	return false
