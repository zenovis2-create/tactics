extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH10_FINALE_STAGE = preload("res://data/stages/ch10_05_stage.tres")
const BondService = preload("res://scripts/battle/bond_service.gd")
const SupportConversations = preload("res://scripts/data/support_conversations.gd")

var _failed: bool = false
var _pass_count: int = 0
var _fail_count: int = 0
var _finalized: bool = false
var _support_conversations := SupportConversations.new()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_choice_panel_appears_and_counts_down()
	await _test_accept_path_uses_s_rank_name_call()
	await _test_reject_path_uses_b_rank_variant_and_sets_pending()
	await _test_timeout_auto_accepts()
	_finalize()

func _test_choice_panel_appears_and_counts_down() -> void:
	var battle = await _spawn_finale_battle()
	if battle == null:
		return
	if not battle.hud.has_method("get_namecall_choice_snapshot"):
		_fail("BattleHUD is missing get_namecall_choice_snapshot() for the Name Call overlay.")
		battle.queue_free()
		await process_frame
		return
	await _seed_serin_a_rank(battle)
	_trigger_namecall(battle, &"ally_serin")
	await process_frame
	var initial_snapshot: Dictionary = battle.hud.get_namecall_choice_snapshot()
	_assert(bool(initial_snapshot.get("visible", false)), "Name Call choice panel appears when the trigger fires")
	_assert(String(initial_snapshot.get("prompt", "")).find("그 이름") != -1, "Name Call prompt uses the authored Korean copy")
	var initial_time_left: float = float(initial_snapshot.get("time_left", 0.0))
	await create_timer(1.2).timeout
	await process_frame
	var countdown_snapshot: Dictionary = battle.hud.get_namecall_choice_snapshot()
	_assert(float(countdown_snapshot.get("time_left", 0.0)) < initial_time_left, "Name Call timer counts down from 3 seconds")
	battle.queue_free()
	await process_frame

func _test_accept_path_uses_s_rank_name_call() -> void:
	var battle = await _spawn_finale_battle()
	if battle == null:
		return
	if not _support_conversations.has_method("get_name_call_choice_line"):
		_fail("SupportConversations is missing get_name_call_choice_line() for the choice-specific Name Call text.")
		battle.queue_free()
		await process_frame
		return
	if not battle.hud.has_method("select_namecall_choice"):
		_fail("BattleHUD is missing select_namecall_choice() for confirming the Name Call overlay.")
		battle.queue_free()
		await process_frame
		return
	await _seed_serin_a_rank(battle)
	_trigger_namecall(battle, &"ally_serin")
	await process_frame
	battle.hud.select_namecall_choice("accept")
	await process_frame
	await process_frame
	var finale_snapshot: Dictionary = battle.get_finale_result_snapshot()
	var fired_name_call_lines: Dictionary = finale_snapshot.get("fired_name_call_lines", {})
	var expected_line: String = String(_support_conversations.call("get_name_call_choice_line", "ally_serin", BondService.SUPPORT_S_RANK, true))
	_assert(String(fired_name_call_lines.get("ally_serin", "")) == expected_line, "'응' resolves to the S-rank Name Call line")
	_assert(not bool(battle.get("namecall_pending")), "Accepting the Name Call clears the pending retry state")
	battle.queue_free()
	await process_frame

func _test_reject_path_uses_b_rank_variant_and_sets_pending() -> void:
	var battle = await _spawn_finale_battle()
	if battle == null:
		return
	if not _support_conversations.has_method("get_name_call_choice_line"):
		_fail("SupportConversations is missing get_name_call_choice_line() for the choice-specific Name Call text.")
		battle.queue_free()
		await process_frame
		return
	if not battle.hud.has_method("select_namecall_choice"):
		_fail("BattleHUD is missing select_namecall_choice() for rejecting the Name Call overlay.")
		battle.queue_free()
		await process_frame
		return
	await _seed_serin_a_rank(battle)
	_trigger_namecall(battle, &"ally_serin")
	await process_frame
	battle.hud.select_namecall_choice("defer")
	await process_frame
	await process_frame
	var finale_snapshot: Dictionary = battle.get_finale_result_snapshot()
	var fired_name_call_lines: Dictionary = finale_snapshot.get("fired_name_call_lines", {})
	var expected_line: String = String(_support_conversations.call("get_name_call_choice_line", "ally_serin", BondService.SUPPORT_B_RANK, false))
	_assert(String(fired_name_call_lines.get("ally_serin", "")) == expected_line, "'아직이다' uses the B-rank Name Call variant")
	_assert(bool(battle.get("namecall_pending")), "Rejecting the Name Call keeps the retry pending flag active")
	var progression = battle.progression_service.get_data()
	_assert(int(progression.get("namecall_rejected_count")) == 1, "Rejecting the Name Call increments progression_data.namecall_rejected_count")
	battle.queue_free()
	await process_frame

func _test_timeout_auto_accepts() -> void:
	var battle = await _spawn_finale_battle()
	if battle == null:
		return
	if not _support_conversations.has_method("get_name_call_choice_line"):
		_fail("SupportConversations is missing get_name_call_choice_line() for the choice-specific Name Call text.")
		battle.queue_free()
		await process_frame
		return
	if not battle.hud.has_method("get_namecall_choice_snapshot"):
		_fail("BattleHUD is missing get_namecall_choice_snapshot() for timeout verification.")
		battle.queue_free()
		await process_frame
		return
	await _seed_serin_a_rank(battle)
	_trigger_namecall(battle, &"ally_serin")
	await create_timer(3.3).timeout
	await process_frame
	await process_frame
	var snapshot: Dictionary = battle.hud.get_namecall_choice_snapshot()
	var finale_snapshot: Dictionary = battle.get_finale_result_snapshot()
	var fired_name_call_lines: Dictionary = finale_snapshot.get("fired_name_call_lines", {})
	var expected_line: String = String(_support_conversations.call("get_name_call_choice_line", "ally_serin", BondService.SUPPORT_S_RANK, true))
	_assert(not bool(snapshot.get("visible", true)), "Name Call overlay closes after the timeout path resolves")
	_assert(String(fired_name_call_lines.get("ally_serin", "")) == expected_line, "The 3-second timeout auto-selects the S-rank Name Call")
	battle.queue_free()
	await process_frame

func _spawn_finale_battle():
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(CH10_FINALE_STAGE)
	await process_frame
	await process_frame
	if battle.hud == null or battle.bond_service == null or battle.progression_service == null:
		_fail("Name Call runner could not resolve BattleHUD, BondService, and ProgressionService.")
		return null
	return battle

func _seed_serin_a_rank(battle) -> void:
	battle.progression_service.get_data().reset_for_new_campaign()
	battle.bond_service.reset()
	for _i in range(10):
		battle.bond_service.register_support_progress(&"ally_rian", &"ally_serin", &"CH10", &"CH10_05")
	await process_frame

func _trigger_namecall(battle, companion_id: StringName) -> void:
	var unit = _find_ally(battle, companion_id)
	if unit == null and not battle.ally_units.is_empty():
		unit = battle.ally_units[0]
	if unit == null:
		_fail("Runner could not find an ally actor to trigger the CH10 Name Call flow.")
		return
	battle.selected_unit = unit
	battle.current_phase = int(battle.BattlePhase.PLAYER_ACTION_COMMIT)
	battle._complete_selected_unit_action("namecall_choice_runner")

func _find_ally(battle, companion_id: StringName):
	for unit in battle.ally_units:
		if unit != null and is_instance_valid(unit) and unit.unit_data != null and unit.unit_data.unit_id == companion_id:
			return unit
	return null

func _assert(condition: bool, description: String) -> void:
	if condition:
		_pass_count += 1
		print("[PASS] %s" % description)
		return
	_fail(description)

func _fail(message: String) -> void:
	_fail_count += 1
	_failed = true
	push_error(message)

func _finalize() -> void:
	if _finalized:
		return
	_finalized = true
	if _failed:
		push_error("namecall_choice_runner: %d passed, %d failed" % [_pass_count, _fail_count])
		quit(1)
		return
	print("[PASS] namecall_choice_runner: all %d assertions passed." % _pass_count)
	quit(0)
