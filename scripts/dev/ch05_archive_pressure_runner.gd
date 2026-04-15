extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH05_ARCHIVE_PRESSURE_STAGE = preload("res://data/stages/ch05_03_stage.tres")

const EXPECTED_OBJECTIVE_TEXTS := [
	"Vent the western pressure valve and release the upper stack seal to stabilize the Burning Stair. (0/2)",
	"One archive-pressure control is resolved. Release the remaining seal. (1/2)",
	"Archive pressure broken. The Burning Stair is stabilized. (2/2)"
]

const EXPECTED_STATE_IDS := [
	&"archive_pressure_locked",
	&"archive_pressure_partial",
	&"archive_pressure_released"
]

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(CH05_ARCHIVE_PRESSURE_STAGE)

	await process_frame
	await process_frame

	_assert_equal(String(CH05_ARCHIVE_PRESSURE_STAGE.win_condition), "resolve_all_interactions", "CH05 archive pressure stage should use interaction-based victory.")
	if _failed:
		return

	_assert_equal(battle.interactive_objects.size(), 2, "CH05 archive pressure stage should author two pressure controls.")
	if _failed:
		return

	_assert_objective_state(battle, 0)
	if _failed:
		return

	var ally = battle.ally_units[0]
	for index in range(battle.interactive_objects.size()):
		battle._resolve_interaction(ally, battle.interactive_objects[index])
		await process_frame
		_assert_objective_state(battle, index + 1)
		if _failed:
			return

	if not battle._check_battle_end():
		_fail("Resolving both archive-pressure controls should satisfy the CH05_03 win condition.")
		return

	if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
		_fail("CH05 archive pressure stage should finish in BattlePhase.VICTORY after the final control resolves.")
		return

	print("[PASS] CH05 archive pressure runner validated objective progression and victory state.")
	quit(0)

func _assert_objective_state(battle, resolved_count: int) -> void:
	if battle.hud.objective_label.text != "Objective: %s" % EXPECTED_OBJECTIVE_TEXTS[resolved_count]:
		_fail("Unexpected CH05 archive pressure objective label at %d interactions: %s" % [
			resolved_count,
			battle.hud.objective_label.text
		])
		return

	var snapshot: Dictionary = battle.get_objective_state_snapshot()
	_assert_equal(int(snapshot.get("resolved_interactions", -1)), resolved_count, "Resolved interaction count drifted.")
	if _failed:
		return
	_assert_equal(int(snapshot.get("required_interactions", -1)), 2, "CH05 archive pressure should require both authored controls.")
	if _failed:
		return
	_assert_equal(StringName(snapshot.get("state_id", &"")), EXPECTED_STATE_IDS[resolved_count], "Unexpected objective state id.")

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
