extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH09B_ROOT_GATE_STAGE = preload("res://data/stages/ch09b_01_stage.tres")
const CH09B_ERASED_SHELVES_STAGE = preload("res://data/stages/ch09b_02_stage.tres")
const CH09B_LAST_KEEPER_STAGE = preload("res://data/stages/ch09b_03_stage.tres")
const CH09B_REVISION_CORE_STAGE = preload("res://data/stages/ch09b_04_stage.tres")

const ROOT_GATE_EXPECTED_OBJECTS := [
	&"ch09b_01_west_root_seal",
	&"ch09b_01_east_root_index"
]

const ROOT_GATE_EXPECTED_TEXTS := [
	"Break the west root seal and secure the east root index to open the archive gate. (0/2)",
	"One root-gate control is secured. Resolve the remaining archive lock. (1/2)",
	"Root gate opened. The first archive-core route is secured. (2/2)"
]

const ROOT_GATE_EXPECTED_STATES := [
	&"root_gate_locked",
	&"root_gate_partial",
	&"root_gate_open"
]

const ERASED_SHELVES_EXPECTED_OBJECTS := [
	&"ch09b_02_west_erased_shelf",
	&"ch09b_02_east_revision_shelf"
]

const ERASED_SHELVES_EXPECTED_TEXTS := [
	"Survey the west erased shelf and seize the east revision shelf to trace the missing names. (0/2)",
	"One erased shelf is decoded. Secure the remaining revised record. (1/2)",
	"Erased shelf route decoded. The missing-name path is exposed. (2/2)"
]

const ERASED_SHELVES_EXPECTED_STATES := [
	&"erased_shelves_hidden",
	&"erased_shelves_partial",
	&"erased_shelves_exposed"
]

const LAST_KEEPER_EXPECTED_OBJECTS := [
	&"ch09b_03_west_keeper_latch",
	&"ch09b_03_center_memory_lattice",
	&"ch09b_03_east_keeper_record"
]

const LAST_KEEPER_EXPECTED_TEXTS := [
	"Release the keeper latch, stabilize the memory lattice, and recover the final keeper record. (0/3)",
	"One keeper route point is secured. Continue stabilizing the inner archive path. (1/3)",
	"Two keeper route points are secured. Recover the final keeper record. (2/3)",
	"Keeper route stabilized. Noah's handoff path is open. (3/3)"
]

const LAST_KEEPER_EXPECTED_STATES := [
	&"keeper_route_sealed",
	&"keeper_route_partial",
	&"keeper_route_aligned",
	&"keeper_route_open"
]

const REVISION_CORE_EXPECTED_OBJECTS := [
	&"ch09b_04_west_revision_core",
	&"ch09b_04_center_red_annotation_pillar",
	&"ch09b_04_east_revision_core"
]

const REVISION_CORE_EXPECTED_TEXTS := [
	"Break both revision cores and erase the red annotation pillar to stop the battlefield rewrite. (0/3)",
	"One revision anchor is broken. Tear down the remaining rewrite points. (1/3)",
	"Two revision anchors are broken. Erase the final rewrite point. (2/3)",
	"Revision chain broken. The battlefield stops rewriting itself. (3/3)"
]

const REVISION_CORE_EXPECTED_STATES := [
	&"revision_chain_locked",
	&"revision_chain_partial",
	&"revision_chain_destabilized",
	&"revision_chain_broken"
]

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_stage_progression(
		CH09B_ROOT_GATE_STAGE,
		ROOT_GATE_EXPECTED_OBJECTS,
		ROOT_GATE_EXPECTED_TEXTS,
		ROOT_GATE_EXPECTED_STATES,
		-1
	)
	if _failed:
		return

	await _assert_stage_progression(
		CH09B_ERASED_SHELVES_STAGE,
		ERASED_SHELVES_EXPECTED_OBJECTS,
		ERASED_SHELVES_EXPECTED_TEXTS,
		ERASED_SHELVES_EXPECTED_STATES,
		-1
	)
	if _failed:
		return

	await _assert_stage_progression(
		CH09B_LAST_KEEPER_STAGE,
		LAST_KEEPER_EXPECTED_OBJECTS,
		LAST_KEEPER_EXPECTED_TEXTS,
		LAST_KEEPER_EXPECTED_STATES,
		-1
	)
	if _failed:
		return

	await _assert_stage_progression(
		CH09B_REVISION_CORE_STAGE,
		REVISION_CORE_EXPECTED_OBJECTS,
		REVISION_CORE_EXPECTED_TEXTS,
		REVISION_CORE_EXPECTED_STATES,
		-1
	)
	if _failed:
		return

	print("[PASS] CH09B revision runner validated root-gate, erased-shelf, keeper-route, and revision-core objectives.")
	quit(0)

func _assert_stage_progression(stage_data, expected_object_ids: Array, expected_texts: Array, expected_states: Array, gate_index: int) -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(stage_data)

	await process_frame
	await process_frame

	_assert_equal(String(stage_data.win_condition), "resolve_all_interactions", "%s should use interaction-based victory." % stage_data.stage_id)
	if _failed:
		return

	_assert_equal(battle.interactive_objects.size(), expected_object_ids.size(), "%s should author the expected interaction count." % stage_data.stage_id)
	if _failed:
		return

	for index in range(expected_object_ids.size()):
		var object_actor = battle.interactive_objects[index]
		_assert_equal(StringName(object_actor.object_data.object_id), expected_object_ids[index], "%s object order drifted." % stage_data.stage_id)
		if _failed:
			return

	var gate_actor = null
	if gate_index >= 0:
		gate_actor = battle.interactive_objects[gate_index]
		_assert_equal(gate_actor.blocks_movement(), true, "%s should begin with its gate sealed." % stage_data.stage_id)
		if _failed:
			return

	_assert_objective_state(battle, 0, expected_texts, expected_states)
	if _failed:
		return

	var ally = battle.ally_units[0]
	for index in range(battle.interactive_objects.size()):
		battle._resolve_interaction(ally, battle.interactive_objects[index])
		await process_frame
		_assert_objective_state(battle, index + 1, expected_texts, expected_states)
		if _failed:
			return

	if gate_actor != null:
		_assert_equal(gate_actor.blocks_movement(), false, "%s should open its gate after the final interaction resolves." % stage_data.stage_id)
		if _failed:
			return

	if not battle._check_battle_end():
		_fail("%s should finish once its authored objective conditions are satisfied." % stage_data.stage_id)
		return

	if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
		_fail("%s should end in victory after the final objective requirement resolves." % stage_data.stage_id)
		return

	battle.queue_free()
	await process_frame

func _assert_objective_state(battle, resolved_count: int, expected_texts: Array, expected_states: Array) -> void:
	var expected_label := "Objective: %s" % expected_texts[resolved_count]
	_assert_equal(battle.hud.objective_label.text, expected_label, "Unexpected CH09B objective label at %d resolved interactions." % resolved_count)
	if _failed:
		return

	var snapshot: Dictionary = battle.get_objective_state_snapshot()
	_assert_equal(int(snapshot.get("resolved_interactions", -1)), resolved_count, "Resolved interaction count drifted.")
	if _failed:
		return
	_assert_equal(int(snapshot.get("required_interactions", -1)), expected_states.size() - 1, "Required interaction count drifted.")
	if _failed:
		return
	_assert_equal(StringName(snapshot.get("state_id", &"")), expected_states[resolved_count], "Unexpected CH09B objective state id.")

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
