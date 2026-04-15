extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH08_AMBUSH_STAGE = preload("res://data/stages/ch08_02_stage.tres")
const CH08_RUIN_VENT_STAGE = preload("res://data/stages/ch08_03_stage.tres")
const CH08_BLACK_MARK_STAGE = preload("res://data/stages/ch08_04_stage.tres")

const AMBUSH_EXPECTED_OBJECTS := [
    &"ch08_02_west_moon_scent_post",
    &"ch08_02_east_split_line_cache"
]

const AMBUSH_EXPECTED_TEXTS := [
    "Break the black-hound route pressure by surveying the moon-scent post and seizing the split-line cache. (0/2)",
    "One ambush route point is secured. Resolve the remaining black-hound signal. (1/2)",
    "Black-hound route pressure is broken. The ambush lane is charted. (2/2)"
]

const AMBUSH_EXPECTED_STATES := [
    &"black_hound_route_locked",
    &"black_hound_route_partial",
    &"black_hound_route_broken"
]

const RUIN_VENT_EXPECTED_OBJECTS := [
    &"ch08_03_west_vent_capstan",
    &"ch08_03_center_holding_gate",
    &"ch08_03_east_cell_record_case"
]

const RUIN_VENT_EXPECTED_TEXTS := [
    "Release the vent line, break the holding gate, and seize the cell records to expose the lower ruin route. (0/3)",
    "One ruin-control point is secured. Release the remaining vent-line controls. (1/3)",
    "Two ruin-control points are secured. Seize the final holding-cell record. (2/3)",
    "Ruin vent broken. The holding cells are exposed. (3/3)"
]

const RUIN_VENT_EXPECTED_STATES := [
    &"ruin_vent_sealed",
    &"ruin_vent_partial",
    &"ruin_vent_pressured",
    &"ruin_vent_open"
]

const BLACK_MARK_EXPECTED_OBJECTS := [
    &"ch08_04_west_control_brand",
    &"ch08_04_east_control_brand"
]

const BLACK_MARK_EXPECTED_TEXTS := [
    "Erase both black-mark control brands to open Lete's hunting route. (0/2)",
    "One black-mark control is erased. Break the remaining brand. (1/2)",
    "The black-mark controls are erased. Lete's signal route is open. (2/2)"
]

const BLACK_MARK_EXPECTED_STATES := [
    &"black_mark_control_locked",
    &"black_mark_control_partial",
    &"black_mark_control_open"
]

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    await _assert_stage_progression(
        CH08_AMBUSH_STAGE,
        AMBUSH_EXPECTED_OBJECTS,
        AMBUSH_EXPECTED_TEXTS,
        AMBUSH_EXPECTED_STATES,
        -1
    )
    if _failed:
        return

    await _assert_stage_progression(
        CH08_RUIN_VENT_STAGE,
        RUIN_VENT_EXPECTED_OBJECTS,
        RUIN_VENT_EXPECTED_TEXTS,
        RUIN_VENT_EXPECTED_STATES,
        1
    )
    if _failed:
        return

    await _assert_stage_progression(
        CH08_BLACK_MARK_STAGE,
        BLACK_MARK_EXPECTED_OBJECTS,
        BLACK_MARK_EXPECTED_TEXTS,
        BLACK_MARK_EXPECTED_STATES,
        -1
    )
    if _failed:
        return

    print("[PASS] CH08 production runner validated black-hound route pressure, ruin vent progression, and black-mark controls.")
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
        _assert_equal(gate_actor.blocks_movement(), true, "%s should begin with its holding gate sealed." % stage_data.stage_id)
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
        _assert_equal(gate_actor.blocks_movement(), false, "%s should open its holding gate after the final interaction resolves." % stage_data.stage_id)
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
    _assert_equal(battle.hud.objective_label.text, expected_label, "Unexpected CH08 objective label at %d resolved interactions." % resolved_count)
    if _failed:
        return

    var snapshot: Dictionary = battle.get_objective_state_snapshot()
    _assert_equal(int(snapshot.get("resolved_interactions", -1)), resolved_count, "Resolved interaction count drifted.")
    if _failed:
        return
    _assert_equal(int(snapshot.get("required_interactions", -1)), expected_states.size() - 1, "Required interaction count drifted.")
    if _failed:
        return
    _assert_equal(StringName(snapshot.get("state_id", &"")), expected_states[resolved_count], "Unexpected CH08 objective state id.")

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
