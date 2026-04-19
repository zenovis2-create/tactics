extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH09A_OUTER_LINE = preload("res://data/stages/ch09a_01_stage.tres")
const CH09A_BANNERS = preload("res://data/stages/ch09a_02_stage.tres")
const CH09A_OATH_HALL = preload("res://data/stages/ch09a_03_stage.tres")
const CH09A_ABANDONED_OFFICERS = preload("res://data/stages/ch09a_04_stage.tres")
const CH09A_BROKEN_STANDARD = preload("res://data/stages/ch09a_05_stage.tres")

const STAGE_CASES := [
	{
		"stage": CH09A_OUTER_LINE,
		"required_interactions": 2,
		"objective_texts": [
			"Recover the defense tablet and cut the signal standard to break the outer line. (0/2)",
			"One defense-line control is secured. Break the remaining route point. (1/2)",
			"Both defense-line controls are secured. The outer line is broken. (2/2)"
		],
		"state_ids": [
			&"outer_line_locked",
			&"outer_line_partial",
			&"outer_line_broken"
		]
	},
	{
		"stage": CH09A_BANNERS,
		"required_interactions": 2,
		"objective_texts": [
			"Seize the bridge ledger and break the oath pike post to clear Karl's bridge lane. (0/2)",
			"One bridge control is secured. Resolve the remaining oath-route point. (1/2)",
			"Both bridge controls are secured. The banner bridge is broken open. (2/2)"
		],
		"state_ids": [
			&"bridge_line_locked",
			&"bridge_line_partial",
			&"bridge_line_broken"
		]
	},
	{
		"stage": CH09A_OATH_HALL,
		"required_interactions": 2,
		"win_condition": "resolve_all_interactions",
		"objective_texts": [
			"Recover the oath roll and inspect the censor mark to expose the discarded-officer route. (0/2)",
			"One oath-hall clue is secured. Find the remaining officer-trail proof. (1/2)",
			"Both oath-hall clues are secured. The discarded-officer route is confirmed. (2/2)"
		],
		"state_ids": [
			&"oath_hall_unread",
			&"oath_hall_partial",
			&"oath_hall_confirmed"
		]
	},
	{
		"stage": CH09A_ABANDONED_OFFICERS,
		"authored_interactions": 1,
		"required_interactions": 1,
		"win_condition": "rescue_quota",
		"resolution_order_ids": [
			&"ch09a_04_central_officer_release_point"
		],
		"expected_object_ids": [
			&"ch09a_04_central_officer_release_point"
		],
		"objective_texts": [
			"Secure the central lift, then hold it through the next round. (0/1)",
			"The central lift is secured. Hold until the next round begins. (1/2)",
			"The central lift held through the counterpush. Varten's inner censor line is exposed. (2/2)"
		],
		"state_ids": [
			&"central_lift_unsecured",
			&"central_lift_holding",
			&"central_lift_secured"
		]
	},
	{
		"stage": CH09A_BROKEN_STANDARD,
		"required_interactions": 3,
		"win_condition": "resolve_all_interactions_and_defeat_all_enemies",
		"objective_texts": [
			"Break all three censor seals, then defeat Varten's remaining censor line. (0/3)",
			"One censor seal is broken. Cut the remaining censor anchors. (1/3)",
			"Two censor seals are broken. Collapse the final censor route. (2/3)",
			"All censor seals are broken. Defeat Varten and the remaining censor line. (3/3)"
		],
		"state_ids": [
			&"censor_seals_intact",
			&"censor_seals_partial",
			&"censor_seals_pressured",
			&"censor_seals_broken"
		]
	}
]

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for case_data in STAGE_CASES:
		_run_stage_case(case_data)
		if _failed:
			return

	print("[PASS] CH09A broken standard runner validated stage objectives and interaction-driven victories.")
	quit(0)

func _run_stage_case(case_data: Dictionary) -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(case_data["stage"])

	await process_frame
	await process_frame

	_assert_equal(String(case_data["stage"].win_condition), String(case_data.get("win_condition", "resolve_all_interactions")), "%s should use the authored objective rule." % case_data["stage"].stage_id)
	if _failed:
		return

	_assert_equal(battle.interactive_objects.size(), int(case_data.get("authored_interactions", case_data["required_interactions"])), "%s should author the expected broken-standard controls." % case_data["stage"].stage_id)
	if _failed:
		return

	for expected_object_id in case_data.get("expected_object_ids", []):
		if _find_object_by_id(battle, expected_object_id) == null:
			_fail("%s should author objective point %s." % [case_data["stage"].stage_id, expected_object_id])
			return

	if String(case_data.get("win_condition", "")) == "rescue_quota":
		_assert_equal(StringName(case_data["stage"].rescue_objective_id), &"central_lift_access", "%s rescue objective id drifted." % case_data["stage"].stage_id)
		if _failed:
			return
		_assert_equal(int(case_data["stage"].rescue_objective_required_count), int(case_data["required_interactions"]), "%s rescue quota drifted." % case_data["stage"].stage_id)
		if _failed:
			return
		_assert_equal(case_data["stage"].rescue_objective_object_ids, case_data.get("expected_object_ids", []), "%s rescue target ids drifted." % case_data["stage"].stage_id)
		if _failed:
			return
		_assert_equal(int(case_data["stage"].hold_objective_required_turns), 1, "%s hold-turn count drifted." % case_data["stage"].stage_id)
		if _failed:
			return

	_assert_objective_state(battle, case_data, 0)
	if _failed:
		return

	if String(case_data.get("win_condition", "resolve_all_interactions")) == "resolve_all_interactions_and_defeat_all_enemies":
		var enemy_first_battle = BATTLE_SCENE.instantiate()
		root.add_child(enemy_first_battle)
		enemy_first_battle.set_stage(case_data["stage"])
		await process_frame
		await process_frame
		enemy_first_battle.enemy_units.clear()
		if enemy_first_battle._check_battle_end():
			_fail("%s should not enter victory if enemies fall before the censor seals are resolved." % case_data["stage"].stage_id)
			return
		enemy_first_battle.queue_free()
		await process_frame

	var ally = battle.ally_units[0]
	var interaction_targets: Array = []
	for object_id in case_data.get("resolution_order_ids", []):
		var target = _find_object_by_id(battle, object_id)
		if target == null:
			_fail("%s could not find authored objective point %s." % [case_data["stage"].stage_id, object_id])
			return
		interaction_targets.append(target)
	if interaction_targets.is_empty():
		interaction_targets = battle.interactive_objects

	for index in range(interaction_targets.size()):
		battle._resolve_interaction(ally, interaction_targets[index])
		await process_frame
		_assert_objective_state(battle, case_data, index + 1)
		if _failed:
			return

	if String(case_data.get("win_condition", "resolve_all_interactions")) == "resolve_all_interactions_and_defeat_all_enemies":
		if battle._check_battle_end():
			_fail("%s should still require enemy defeat after the final control resolves." % case_data["stage"].stage_id)
			return
		battle.enemy_units.clear()
		if not battle._check_battle_end():
			_fail("%s should enter victory after objectives are resolved and the enemy line is cleared." % case_data["stage"].stage_id)
			return
	elif String(case_data.get("win_condition", "")) == "rescue_quota":
		if battle._check_battle_end():
			_fail("%s should not enter victory immediately after securing the lift anchor." % case_data["stage"].stage_id)
			return
		battle.enemy_units.clear()
		battle._on_end_turn_requested()
		await process_frame
		await process_frame
		await process_frame
		_assert_objective_state(battle, case_data, 2)
		if _failed:
			return
		if not battle._check_battle_end():
			_fail("%s should enter victory after surviving to the next round with the lift secured." % case_data["stage"].stage_id)
			return
	else:
		if not battle._check_battle_end():
			_fail("%s should enter victory when all broken-standard controls are resolved." % case_data["stage"].stage_id)
			return

	if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
		_fail("%s should finish in BattlePhase.VICTORY after the final control resolves." % case_data["stage"].stage_id)
		return

	battle.queue_free()
	await process_frame

func _assert_objective_state(battle, case_data: Dictionary, resolved_count: int) -> void:
	var expected_text: String = case_data["objective_texts"][resolved_count]
	if battle.hud.objective_label.text != "Objective: %s" % expected_text:
		_fail("Unexpected CH09A objective label at %d interactions: %s" % [resolved_count, battle.hud.objective_label.text])
		return

	var snapshot: Dictionary = battle.get_objective_state_snapshot()
	_assert_equal(int(snapshot.get("resolved_interactions", -1)), resolved_count, "Resolved interaction count drifted.")
	if _failed:
		return
	_assert_equal(int(snapshot.get("required_interactions", -1)), int(case_data["required_interactions"]), "Required interaction count drifted.")
	if _failed:
		return
	_assert_equal(StringName(snapshot.get("state_id", &"")), case_data["state_ids"][resolved_count], "Unexpected objective state id.")

func _assert_equal(actual, expected, message: String) -> void:
	if actual == expected:
		return
	_fail("%s Expected %s, got %s." % [message, str(expected), str(actual)])

func _find_object_by_id(battle, object_id: StringName):
	for object_actor in battle.interactive_objects:
		if object_actor != null and is_instance_valid(object_actor) and object_actor.object_data != null and StringName(object_actor.object_data.object_id) == object_id:
			return object_actor
	return null

func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	quit(1)
