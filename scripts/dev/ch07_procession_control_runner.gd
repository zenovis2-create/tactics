extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH07_MARKET = preload("res://data/stages/ch07_01_stage.tres")
const CH07_SQUARE = preload("res://data/stages/ch07_02_stage.tres")
const CH07_PROCESSION = preload("res://data/stages/ch07_03_stage.tres")

const STAGE_CASES := [
	{
		"stage": CH07_MARKET,
		"required_interactions": 2,
		"objective_texts": [
			"Read the market route board and silence the queue bell to open the square. (0/2)",
			"One procession control point is secured. Resolve the remaining route control. (1/2)",
			"Both market controls are secured. The silence-square route is open. (2/2)"
		],
		"state_ids": [
			&"market_route_locked",
			&"market_route_partial",
			&"market_route_open"
		]
	},
	{
		"stage": CH07_SQUARE,
		"required_interactions": 2,
		"objective_texts": [
			"Read the silence plaque and cut the queue release post to break the square. (0/2)",
			"One square control is secured. Resolve the remaining queue control. (1/2)",
			"Both square controls are secured. The procession line is broken. (2/2)"
		],
		"state_ids": [
			&"silence_square_locked",
			&"silence_square_partial",
			&"silence_square_broken"
		]
	},
	{
		"stage": CH07_PROCESSION,
		"required_interactions": 2,
		"objective_texts": [
			"Recover the procession roll and witness mark to trace the cathedral route. (0/2)",
			"One procession clue is secured. Find the remaining witness point. (1/2)",
			"Both procession clues are secured. The cathedral route is confirmed. (2/2)"
		],
		"state_ids": [
			&"procession_route_unread",
			&"procession_route_partial",
			&"procession_route_confirmed"
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

	print("[PASS] CH07 procession control runner validated stage objectives and interaction-driven victories.")
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

	_assert_equal(battle.interactive_objects.size(), int(case_data["required_interactions"]), "%s should author the expected procession control points." % case_data["stage"].stage_id)
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
		_fail("%s should enter victory when all procession controls are resolved." % case_data["stage"].stage_id)
		return

	if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
		_fail("%s should finish in BattlePhase.VICTORY after the final control resolves." % case_data["stage"].stage_id)
		return

	battle.queue_free()
	await process_frame

func _assert_objective_state(battle, case_data: Dictionary, resolved_count: int) -> void:
	var expected_text: String = case_data["objective_texts"][resolved_count]
	if battle.hud.objective_label.text != "Objective: %s" % expected_text:
		_fail("Unexpected CH07 objective label at %d interactions: %s" % [resolved_count, battle.hud.objective_label.text])
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
