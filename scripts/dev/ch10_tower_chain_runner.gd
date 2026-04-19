extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH10_ECLIPSE_EVE = preload("res://data/stages/ch10_01_stage.tres")
const CH10_TOWER_CREST = preload("res://data/stages/ch10_02_stage.tres")
const CH10_NAMELESS_CORRIDOR = preload("res://data/stages/ch10_03_stage.tres")

const STAGE_CASES := [
	{
		"stage": CH10_ECLIPSE_EVE,
		"required_interactions": 2,
		"objective_texts": [
			"Read the eclipse tablet and release the lift latch to open the first ascent route. (0/2)",
			"One ascent control is secured. Release the remaining tower latch. (1/2)",
			"Both ascent controls are secured. The first tower route is open. (2/2)"
		],
		"state_ids": [
			&"tower_ascent_locked",
			&"tower_ascent_partial",
			&"tower_ascent_open"
		]
	},
	{
		"stage": CH10_TOWER_CREST,
		"required_interactions": 2,
		"objective_texts": [
			"Break both resonance crest controls to collapse the outer tower ring. (0/2)",
			"One crest control is down. Collapse the remaining outer tower crest. (1/2)",
			"Both crest controls are down. The outer tower ring is broken. (2/2)"
		],
		"state_ids": [
			&"tower_crest_locked",
			&"tower_crest_partial",
			&"tower_crest_broken"
		]
	},
	{
		"stage": CH10_NAMELESS_CORRIDOR,
		"required_interactions": 2,
		"objective_texts": [
			"Break both corridor anchors to force the nameless corridor open. (0/2)",
			"One corridor anchor is broken. Break the remaining anchor. (1/2)",
			"Both corridor anchors are broken. The nameless corridor is forced open. (2/2)"
		],
		"state_ids": [
			&"corridor_locked",
			&"corridor_partial",
			&"corridor_open"
		]
	},
	{
		"stage": preload("res://data/stages/ch10_04_stage.tres"),
		"required_interactions": 3,
		"win_condition": "resolve_all_interactions_and_defeat_all_enemies",
		"objective_text": "Break the three decree anchors, then defeat Karon's first phase and the remaining enemy line to open the royal hall.",
		"object_ids": [
			&"ch10_04_west_decree_anchor",
			&"ch10_04_center_edict_anchor",
			&"ch10_04_east_decree_anchor"
		],
		"objective_texts": [
			"Break the three decree anchors, then defeat Karon's first phase and the remaining enemy line to open the royal hall. (0/3)",
			"One decree anchor is shattered. Break the remaining edict anchors. (1/3)",
			"Two decree anchors are shattered. Break the final edict anchor. (2/3)",
			"The decree chain is broken. Defeat Karon's first phase and the remaining enemy line to open the royal hall. (3/3)"
		],
		"state_ids": [
			&"decree_chain_locked",
			&"decree_chain_partial",
			&"decree_chain_fractured",
			&"decree_chain_broken"
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

	print("[PASS] CH10 tower chain runner validated ascent, crest, and corridor objective chains.")
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

	_assert_equal(battle.interactive_objects.size(), int(case_data["required_interactions"]), "%s should author the expected tower-chain controls." % case_data["stage"].stage_id)
	if _failed:
		return

	if case_data.has("object_ids"):
		for index in range(case_data["object_ids"].size()):
			_assert_equal(StringName(battle.interactive_objects[index].object_data.object_id), case_data["object_ids"][index], "%s object order drifted." % case_data["stage"].stage_id)
			if _failed:
				return

	if case_data.has("objective_text"):
		_assert_equal(String(case_data["stage"].objective_text).strip_edges(), String(case_data["objective_text"]), "%s should author the decree objective text." % case_data["stage"].stage_id)
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

	if String(case_data.get("win_condition", "resolve_all_interactions")) == "resolve_all_interactions_and_defeat_all_enemies":
		if battle._check_battle_end():
			_fail("%s should not enter victory until the enemy line is also defeated." % case_data["stage"].stage_id)
			return
		battle.enemy_units.clear()
		if not battle._check_battle_end():
			_fail("%s should enter victory after controls are resolved and the enemy line is cleared." % case_data["stage"].stage_id)
			return
	else:
		if not battle._check_battle_end():
			_fail("%s should enter victory when all tower-chain controls are resolved." % case_data["stage"].stage_id)
			return

	if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
		_fail("%s should finish in BattlePhase.VICTORY after the final control resolves." % case_data["stage"].stage_id)
		return

	battle.queue_free()
	await process_frame

func _assert_objective_state(battle, case_data: Dictionary, resolved_count: int) -> void:
	var expected_text: String = case_data["objective_texts"][resolved_count]
	if battle.hud.objective_label.text != "Objective: %s" % expected_text:
		_fail("Unexpected CH10 objective label at %d interactions: %s" % [resolved_count, battle.hud.objective_label.text])
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
