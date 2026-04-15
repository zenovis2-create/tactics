extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH03_LOST_FOREST = preload("res://data/stages/ch03_01_stage.tres")
const CH03_SNARE_LINE = preload("res://data/stages/ch03_02_stage.tres")
const CH03_REFUGEE_COLUMN = preload("res://data/stages/ch03_03_stage.tres")

const STAGE_CASES := [
	{
		"stage": CH03_LOST_FOREST,
		"required_interactions": 2,
		"objective_texts": [
			"Survey both forest trail markers to map a safe Greenwood route. (0/2)",
			"One forest trail marker is surveyed. Check the remaining marker. (1/2)",
			"Both forest trail markers are surveyed. The Lost Forest route is mapped. (2/2)"
		],
		"state_ids": [
			&"greenwood_route_unmapped",
			&"greenwood_route_partial",
			&"greenwood_route_mapped"
		]
	},
	{
		"stage": CH03_SNARE_LINE,
		"required_interactions": 2,
		"objective_texts": [
			"Read the refugee sign and cut the snare post to secure the lower trail. (0/2)",
			"One route point is secured. Resolve the remaining trail hazard. (1/2)",
			"Both route points are secured. The refugee trail is stabilized. (2/2)"
		],
		"state_ids": [
			&"refugee_trail_unsecured",
			&"refugee_trail_partial",
			&"refugee_trail_stabilized"
		]
	},
	{
		"stage": CH03_REFUGEE_COLUMN,
		"required_interactions": 2,
		"objective_texts": [
			"Open the route cache and inspect the wildfire residue to guide the refugee column. (0/2)",
			"One refugee-column clue is secured. Find the remaining clue. (1/2)",
			"Both refugee-column clues are secured. The basin route is confirmed. (2/2)"
		],
		"state_ids": [
			&"refugee_column_unread",
			&"refugee_column_partial",
			&"refugee_column_confirmed"
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

	print("[PASS] CH03 forest investigation runner validated stage objectives and interaction-driven victories.")
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

	_assert_equal(battle.interactive_objects.size(), int(case_data["required_interactions"]), "%s should author the expected investigation points." % case_data["stage"].stage_id)
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
		_fail("%s should enter victory when all investigation points are resolved." % case_data["stage"].stage_id)
		return

	if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
		_fail("%s should finish in BattlePhase.VICTORY after the last investigation point resolves." % case_data["stage"].stage_id)
		return

	battle.queue_free()
	await process_frame

func _assert_objective_state(battle, case_data: Dictionary, resolved_count: int) -> void:
	var expected_text: String = case_data["objective_texts"][resolved_count]
	if battle.hud.objective_label.text != "Objective: %s" % expected_text:
		_fail("Unexpected CH03 objective label at %d interactions: %s" % [resolved_count, battle.hud.objective_label.text])
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
