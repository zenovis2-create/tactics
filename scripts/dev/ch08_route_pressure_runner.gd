extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH08_VANISHED_TRAIL = preload("res://data/stages/ch08_01_stage.tres")
const CH08_MOONLIT_AMBUSH = preload("res://data/stages/ch08_02_stage.tres")
const CH08_RUIN_VENT = preload("res://data/stages/ch08_03_stage.tres")

const STAGE_CASES := [
	{
		"stage": CH08_VANISHED_TRAIL,
		"required_interactions": 2,
		"objective_texts": [
			"Trace the hound sign and cut the signal post to collapse the false pursuit forks. (0/2)",
			"One false fork is down. Collapse the remaining pursuit split. (1/2)",
			"The pursuit forks collapse into one lane. The vanished trail is fixed. (2/2)"
		],
		"state_ids": [
			&"hound_route_split",
			&"hound_route_partial",
			&"hound_route_narrowed"
		]
	},
	{
		"stage": CH08_MOONLIT_AMBUSH,
		"required_interactions": 2,
		"objective_texts": [
			"Survey the moon-scent post and seize the split-line cache to map the moonlit kill lane. (0/2)",
			"One ambush control point is secured. Chart the remaining kill-lane route. (1/2)",
			"The moonlit kill lane is mapped. The descent into the lower ruins is exposed. (2/2)"
		],
		"state_ids": [
			&"black_hound_route_locked",
			&"black_hound_route_partial",
			&"black_hound_route_broken"
		]
	},
	{
		"stage": CH08_RUIN_VENT,
		"required_interactions": 3,
		"objective_texts": [
			"Open the vent line, break the holding gate, and seize the cell records to expose the lower-cell route. (0/3)",
			"One lower-cell control point is secured. Release the remaining ruin controls. (1/3)",
			"Two lower-cell control points are secured. Seize the last holding record. (2/3)",
			"The lower cells are exposed. The ruin holding route is charted. (3/3)"
		],
		"state_ids": [
			&"ruin_vent_sealed",
			&"ruin_vent_partial",
			&"ruin_vent_pressured",
			&"ruin_vent_open"
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

	print("[PASS] CH08 route pressure runner validated stage objectives and interaction-driven victories.")
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

	_assert_equal(battle.interactive_objects.size(), int(case_data["required_interactions"]), "%s should author the expected route-pressure controls." % case_data["stage"].stage_id)
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
		_fail("%s should enter victory when all route-pressure controls are resolved." % case_data["stage"].stage_id)
		return

	if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
		_fail("%s should finish in BattlePhase.VICTORY after the final control resolves." % case_data["stage"].stage_id)
		return

	battle.queue_free()
	await process_frame

func _assert_objective_state(battle, case_data: Dictionary, resolved_count: int) -> void:
	var expected_text: String = case_data["objective_texts"][resolved_count]
	if battle.hud.objective_label.text != "Objective: %s" % expected_text:
		_fail("Unexpected CH08 objective label at %d interactions: %s" % [resolved_count, battle.hud.objective_label.text])
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
