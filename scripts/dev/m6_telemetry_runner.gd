extends SceneTree

## M6 telemetry acceptance gate.
## SYS-021~024: metric emission, session report, balance report.

const TelemetryService = preload("res://scripts/battle/telemetry_service.gd")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var svc := TelemetryService.new()
	root.add_child(svc)
	await process_frame

	if not _assert_battle_start_resets_session(svc): return
	if not _assert_record_ally_death(svc): return
	if not _assert_record_enemy_death(svc): return
	if not _assert_oblivion_counts(svc): return
	if not _assert_command_usage(svc): return
	if not _assert_battle_end_emits_complete_payload(svc): return
	if not _assert_balance_report_top_causes(svc): return

	print("[PASS] M6 telemetry runner: all assertions passed.")
	quit(0)

func _assert_battle_start_resets_session(svc: TelemetryService) -> bool:
	svc.record_battle_start(&"tutorial_stage")
	var snap := svc.get_session_snapshot()
	if snap.get(TelemetryService.KEY_STAGE_ID) != "tutorial_stage":
		return _fail("Session stage_id should match after record_battle_start")
	if int(snap.get(TelemetryService.KEY_ALLY_DEATHS, -1)) != 0:
		return _fail("ally_deaths should be 0 at battle start")
	return true

func _assert_record_ally_death(svc: TelemetryService) -> bool:
	svc.record_battle_start(&"ch01")
	svc.record_ally_death("boss_charge")
	var snap := svc.get_session_snapshot()
	if int(snap.get(TelemetryService.KEY_ALLY_DEATHS, 0)) != 1:
		return _fail("ally_deaths should be 1 after one ally death")
	var causes: Array = snap.get(TelemetryService.KEY_FAILURE_CAUSES, [])
	if not causes.has("boss_charge"):
		return _fail("failure_causes should include 'boss_charge'")
	return true

func _assert_record_enemy_death(svc: TelemetryService) -> bool:
	svc.record_battle_start(&"ch01")
	svc.record_enemy_death()
	svc.record_enemy_death()
	var snap := svc.get_session_snapshot()
	if int(snap.get(TelemetryService.KEY_ENEMY_DEATHS, 0)) != 2:
		return _fail("enemy_deaths should be 2 after two enemy deaths")
	return true

func _assert_oblivion_counts(svc: TelemetryService) -> bool:
	svc.record_battle_start(&"ch02")
	svc.record_oblivion_applied(2)
	svc.record_oblivion_applied(1)
	svc.record_oblivion_cleansed(1)
	var snap := svc.get_session_snapshot()
	if int(snap.get(TelemetryService.KEY_OBLIVION_APPLIED, 0)) != 3:
		return _fail("oblivion_applied should be 3")
	if int(snap.get(TelemetryService.KEY_OBLIVION_CLEANSED, 0)) != 1:
		return _fail("oblivion_cleansed should be 1")
	return true

func _assert_command_usage(svc: TelemetryService) -> bool:
	svc.record_battle_start(&"ch03")
	svc.record_command_use(&"tactical_shift")
	svc.record_command_use(&"tactical_shift")
	svc.record_command_use(&"cover_advance")
	var snap := svc.get_session_snapshot()
	var usage: Dictionary = snap.get(TelemetryService.KEY_COMMAND_USAGE, {})
	if int(usage.get("tactical_shift", 0)) != 2:
		return _fail("tactical_shift should have 2 uses")
	if int(usage.get("cover_advance", 0)) != 1:
		return _fail("cover_advance should have 1 use")
	return true

func _assert_battle_end_emits_complete_payload(svc: TelemetryService) -> bool:
	svc.record_battle_start(&"ch04")
	svc.record_ally_death("oblivion_sealed")
	svc.record_oblivion_applied(3)
	svc.record_round_complete(4)
	var payload := svc.record_battle_end(&"victory", 4)

	var required_keys := [
		TelemetryService.KEY_STAGE_ID,
		TelemetryService.KEY_RESULT,
		TelemetryService.KEY_ROUNDS,
		TelemetryService.KEY_OBLIVION_APPLIED,
		TelemetryService.KEY_OBLIVION_CLEANSED,
		TelemetryService.KEY_ALLY_DEATHS,
		TelemetryService.KEY_ENEMY_DEATHS,
		TelemetryService.KEY_COMMAND_USAGE,
		TelemetryService.KEY_FAILURE_CAUSES,
		TelemetryService.KEY_STARTED_AT,
		TelemetryService.KEY_ENDED_AT,
	]
	for k in required_keys:
		if not payload.has(k):
			return _fail("Battle end payload missing key: %s" % k)
	if payload.get(TelemetryService.KEY_RESULT) != "victory":
		return _fail("result should be 'victory'")
	return true

func _assert_balance_report_top_causes(svc: TelemetryService) -> bool:
	var fresh := TelemetryService.new()
	root.add_child(fresh)

	# Simulate 3 battles with known failure causes.
	for i in range(3):
		fresh.record_battle_start(&"ch05")
		fresh.record_ally_death("boss_charge")
		fresh.record_ally_death("boss_charge")
		fresh.record_ally_death("oblivion_stack")
		fresh.record_battle_end(&"defeat", 3)

	var report := fresh.get_balance_report()
	if int(report.get("total_battles", 0)) != 3:
		return _fail("Balance report should count 3 battles")
	var top: Array = report.get("top_failure_causes", [])
	if top.is_empty():
		return _fail("Balance report should have top failure causes")
	if top[0].get("cause") != "boss_charge":
		return _fail("Top failure cause should be 'boss_charge' (appeared 6 times), got: %s" % str(top[0]))

	fresh.queue_free()
	return true

func _fail(msg: String) -> bool:
	print("[FAIL] ", msg)
	_failed = true
	quit(1)
	return false
