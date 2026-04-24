extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH05_ARCHIVE_PRESSURE_STAGE = preload("res://data/stages/ch05_03_stage.tres")

const EXPECTED_OBJECTIVE_TEXTS := [
	"서쪽 압력 밸브를 열고 상층 서고 봉인을 해제해 불타는 계단을 안정시킨다. (0/2)",
	"기록보관소 압력 제어점 하나를 해결했다. 남은 봉인을 해제한다. (1/2)",
	"기록보관소 압력이 해소되었다. 불타는 계단이 안정되었다. (2/2)"
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

	var found_evidence := false
	for object_actor in battle.interactive_objects:
		if StringName(object_actor.object_data.object_id) == &"ch05_03_upper_stack_seal":
			found_evidence = true
			_assert_equal(String(object_actor.object_data.object_type), "evidence", "CH05 upper stack seal should route through the evidence family.")
			if _failed:
				return
	if not found_evidence:
		_fail("CH05 archive pressure stage should include the upper stack seal object.")
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
