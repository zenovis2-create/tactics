extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH04_FLOODGATE_STAGE = preload("res://data/stages/ch04_03_stage.tres")
const CH04_RELIQUARY_STAGE = preload("res://data/stages/ch04_04_stage.tres")

const FLOODGATE_EXPECTED_OBJECTS := [
    &"ch04_03_west_sluice_wheel",
    &"ch04_03_east_sluice_wheel"
]

const FLOODGATE_EXPECTED_TEXTS := [
    "Stabilize the monastery flood route by aligning both sluice wheels. (0/2)",
    "One sluice wheel is aligned. Stabilize the remaining channel. (1/2)",
    "Both sluice wheels are aligned. The relic vault route is stable. (2/2)"
]

const FLOODGATE_EXPECTED_STATES := [
    &"monastery_flood_route_locked",
    &"monastery_flood_route_partial",
    &"monastery_flood_route_stable"
]

const RELIQUARY_EXPECTED_OBJECTS := [
    &"ch04_04_north_reliquary_seal",
    &"ch04_04_south_reliquary_seal"
]

const RELIQUARY_EXPECTED_TEXTS := [
    "Restore both reliquary seals to purify the chamber. (0/2)",
    "One reliquary seal is restored. Purify the final ward. (1/2)",
    "Both reliquary seals are restored. Basil's sanctuary stands exposed. (2/2)"
]

const RELIQUARY_EXPECTED_STATES := [
    &"monastery_reliquary_unpurified",
    &"monastery_reliquary_partial",
    &"monastery_reliquary_purified"
]

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    await _assert_stage_progression(
        CH04_FLOODGATE_STAGE,
        FLOODGATE_EXPECTED_OBJECTS,
        FLOODGATE_EXPECTED_TEXTS,
        FLOODGATE_EXPECTED_STATES
    )
    if _failed:
        return

    await _assert_stage_progression(
        CH04_RELIQUARY_STAGE,
        RELIQUARY_EXPECTED_OBJECTS,
        RELIQUARY_EXPECTED_TEXTS,
        RELIQUARY_EXPECTED_STATES
    )
    if _failed:
        return

    print("[PASS] CH04 flood route runner validated authored floodgate and reliquary objective progression.")
    quit(0)

func _assert_stage_progression(stage_data, expected_object_ids: Array, expected_texts: Array, expected_states: Array) -> void:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    battle.set_stage(stage_data)

    await process_frame
    await process_frame

    _assert_equal(battle.interactive_objects.size(), expected_object_ids.size(), "%s should author the expected interaction count." % stage_data.stage_id)
    if _failed:
        return

    for index in range(expected_object_ids.size()):
        var object_actor = battle.interactive_objects[index]
        _assert_equal(StringName(object_actor.object_data.object_id), expected_object_ids[index], "%s object order drifted." % stage_data.stage_id)
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

    if not battle._check_battle_end():
        _fail("%s should finish once all authored interactions resolve." % stage_data.stage_id)
        return

    if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
        _fail("%s should end in victory after the final interaction resolves." % stage_data.stage_id)
        return

    battle.queue_free()
    await process_frame

func _assert_objective_state(battle, resolved_count: int, expected_texts: Array, expected_states: Array) -> void:
    var expected_label := "Objective: %s" % expected_texts[resolved_count]
    _assert_equal(battle.hud.objective_label.text, expected_label, "Unexpected CH04 objective label at %d resolved interactions." % resolved_count)
    if _failed:
        return

    var snapshot: Dictionary = battle.get_objective_state_snapshot()
    _assert_equal(int(snapshot.get("resolved_interactions", -1)), resolved_count, "Resolved interaction count drifted.")
    if _failed:
        return
    _assert_equal(int(snapshot.get("required_interactions", -1)), expected_states.size() - 1, "Required interaction count drifted.")
    if _failed:
        return
    _assert_equal(StringName(snapshot.get("state_id", &"")), expected_states[resolved_count], "Unexpected CH04 objective state id.")

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
