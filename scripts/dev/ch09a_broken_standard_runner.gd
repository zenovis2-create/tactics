extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH09A_OUTER_LINE = preload("res://data/stages/ch09a_01_stage.tres")
const CH09A_BANNERS = preload("res://data/stages/ch09a_02_stage.tres")
const CH09A_OATH_HALL = preload("res://data/stages/ch09a_03_stage.tres")

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

	_assert_equal(String(case_data["stage"].win_condition), "resolve_all_interactions", "%s should use interaction-based victory." % case_data["stage"].stage_id)
	if _failed:
		return

	_assert_equal(battle.interactive_objects.size(), int(case_data["required_interactions"]), "%s should author the expected broken-standard controls." % case_data["stage"].stage_id)
	if _failed:
		return

	_assert_objective_state(battle, case_data, 0)
	if _failed:
		return

	var ally = battle.ally_units[0]
	for index in range(battle.interactive_objects.size()):
		battle._resolve_interaction(ally, battle.interactive_objects[index])
		await process_frame
		_assert_objective_state(battle, case_data, index + 1)
		if _failed:
			return

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

func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	quit(1)
