extends SceneTree

## SYS-013~016 acceptance gate.
## Validates ProgressionService: burden/trust band effects, fragment unlock gates,
## ending tendency thresholds, and event log emission.

const ProgressionService = preload("res://scripts/battle/progression_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var svc := ProgressionService.new()
	root.add_child(svc)

	await process_frame

	if not _assert_initial_state(svc): return
	if not _assert_burden_band_clamping(svc): return
	if not _assert_trust_band_clamping(svc): return
	if not _assert_fragment_command_unlock(svc): return
	if not _assert_duplicate_fragment_idempotent(svc): return
	if not _assert_ending_tendency_true(svc): return
	if not _assert_ending_tendency_bad(svc): return
	if not _assert_event_log_non_empty(svc): return
	if not _assert_burden_effect_keys(svc): return
	if not _assert_trust_effect_keys(svc): return

	print("[PASS] M4 progression runner: all assertions passed.")
	quit(0)

# --- Assertions ---

func _assert_initial_state(svc: ProgressionService) -> bool:
	var d := svc.get_data()
	if d.burden != 0:
		return _fail("Initial burden should be 0, got %d" % d.burden)
	if d.trust != 0:
		return _fail("Initial trust should be 0, got %d" % d.trust)
	if d.ending_tendency != &"undetermined":
		return _fail("Initial ending_tendency should be undetermined, got %s" % d.ending_tendency)
	return true

func _assert_burden_band_clamping(svc: ProgressionService) -> bool:
	var fresh := ProgressionService.new()
	root.add_child(fresh)
	fresh.apply_burden_delta(100, "clamp_test")
	if fresh.get_data().burden != 9:
		return _fail("Burden should clamp at 9, got %d" % fresh.get_data().burden)
	fresh.apply_burden_delta(-100, "clamp_test")
	if fresh.get_data().burden != 0:
		return _fail("Burden should clamp at 0, got %d" % fresh.get_data().burden)
	fresh.queue_free()
	return true

func _assert_trust_band_clamping(svc: ProgressionService) -> bool:
	var fresh := ProgressionService.new()
	root.add_child(fresh)
	fresh.apply_trust_delta(100, "clamp_test")
	if fresh.get_data().trust != 9:
		return _fail("Trust should clamp at 9, got %d" % fresh.get_data().trust)
	fresh.apply_trust_delta(-100, "clamp_test")
	if fresh.get_data().trust != 0:
		return _fail("Trust should clamp at 0, got %d" % fresh.get_data().trust)
	fresh.queue_free()
	return true

func _assert_fragment_command_unlock(svc: ProgressionService) -> bool:
	var fresh := ProgressionService.new()
	root.add_child(fresh)
	var result := fresh.recover_fragment(&"ch01_fragment")
	if bool(result.get("already_known", true)):
		return _fail("ch01_fragment should be new on first recovery")
	if result.get("command_unlocked") != "tactical_shift":
		return _fail("ch01_fragment should unlock tactical_shift, got: %s" % str(result.get("command_unlocked")))
	if not fresh.get_data().has_command(&"tactical_shift"):
		return _fail("tactical_shift should be present in unlocked_commands after fragment recovery")
	fresh.queue_free()
	return true

func _assert_duplicate_fragment_idempotent(svc: ProgressionService) -> bool:
	var fresh := ProgressionService.new()
	root.add_child(fresh)
	fresh.recover_fragment(&"ch02_fragment")
	var result := fresh.recover_fragment(&"ch02_fragment")
	if not bool(result.get("already_known", false)):
		return _fail("Second recovery of same fragment should return already_known=true")
	fresh.queue_free()
	return true

func _assert_ending_tendency_true(svc: ProgressionService) -> bool:
	var fresh := ProgressionService.new()
	root.add_child(fresh)
	# trust >= 7, burden <= 6 => true_ending
	fresh.apply_trust_delta(7, "test")
	fresh.apply_burden_delta(5, "test")
	if fresh.get_data().ending_tendency != &"true_ending":
		return _fail("Ending should be true_ending with trust=7 burden=5, got: %s" % fresh.get_data().ending_tendency)
	fresh.queue_free()
	return true

func _assert_ending_tendency_bad(svc: ProgressionService) -> bool:
	var fresh := ProgressionService.new()
	root.add_child(fresh)
	# burden >= 7 => bad_ending
	fresh.apply_burden_delta(7, "test")
	if fresh.get_data().ending_tendency != &"bad_ending":
		return _fail("Ending should be bad_ending with burden=7 trust=0, got: %s" % fresh.get_data().ending_tendency)
	fresh.queue_free()
	return true

func _assert_event_log_non_empty(svc: ProgressionService) -> bool:
	var fresh := ProgressionService.new()
	root.add_child(fresh)
	fresh.apply_burden_delta(1, "test")
	var log := fresh.get_event_log()
	if log.is_empty():
		return _fail("Event log should be non-empty after an update")
	var events := log.map(func(e): return e.get("event", ""))
	if not events.has("burden_changed"):
		return _fail("Event log should contain 'burden_changed' after apply_burden_delta")
	fresh.queue_free()
	return true

func _assert_burden_effect_keys(svc: ProgressionService) -> bool:
	var fresh := ProgressionService.new()
	root.add_child(fresh)
	# At band 0 effect dict must be valid (possibly empty)
	var effect := fresh.get_burden_effect()
	if not effect is Dictionary:
		return _fail("get_burden_effect() must return a Dictionary")
	# At band 9 effect must have accuracy_mod
	fresh.apply_burden_delta(9, "test")
	var heavy := fresh.get_burden_effect()
	if not heavy.has("accuracy_mod"):
		return _fail("Band 9 burden effect must include accuracy_mod")
	fresh.queue_free()
	return true

func _assert_trust_effect_keys(svc: ProgressionService) -> bool:
	var fresh := ProgressionService.new()
	root.add_child(fresh)
	var effect := fresh.get_trust_effect()
	if not effect is Dictionary:
		return _fail("get_trust_effect() must return a Dictionary")
	fresh.apply_trust_delta(9, "test")
	var max_effect := fresh.get_trust_effect()
	if not max_effect.has("support_range_bonus"):
		return _fail("Band 9 trust effect must include support_range_bonus")
	fresh.queue_free()
	return true

# --- Helpers ---

func _fail(msg: String) -> bool:
	print("[FAIL] ", msg)
	_failed = true
	quit(1)
	return false
