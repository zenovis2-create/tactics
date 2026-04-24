extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH06_BATTERY_LINE_STAGE = preload("res://data/stages/ch06_02_stage.tres")
const CH06_OATH_HALL_STAGE = preload("res://data/stages/ch06_04_stage.tres")

const BATTERY_EXPECTED_OBJECTS := [
    &"ch06_02_west_battery_winch",
    &"ch06_02_center_chain_lift_gate",
    &"ch06_02_east_battery_winch"
]

const BATTERY_EXPECTED_TEXTS := [
    "양측 윈치를 무너뜨리고 중앙 사슬 승강문을 해제해 발토르 포대선을 끊는다. (0/3)",
    "전선 제어점 하나를 확보했다. 남은 포대 제어점을 무너뜨린다. (1/3)",
    "전선 제어점 두 곳을 확보했다. 마지막 사슬 승강문 제어를 해제한다. (2/3)",
    "포대선이 무너졌다. 사슬 승강문이 열렸다. (3/3)"
]

const BATTERY_EXPECTED_STATES := [
    &"valtor_line_control_locked",
    &"valtor_line_control_partial",
    &"valtor_line_control_pressured",
    &"valtor_line_control_open"
]

const BATTERY_TEMPLATE_ID := &"valtor_line_control"
const OATH_HALL_TEMPLATE_ID := &"oath_hall_records"

const OATH_HALL_EXPECTED_OBJECTS := [
    &"ch06_04_west_archive_case",
    &"ch06_04_ceremonial_seal",
    &"ch06_04_east_archive_case"
]

const OATH_HALL_EXPECTED_TEXTS := [
    "두 개의 맹세 기록고를 확보하고 의식 봉인을 파괴해 발가르의 경사로를 드러낸다. (0/3)",
    "맹세 전당 기록 지점 하나를 확보했다. 남은 기록고 제어점을 장악한다. (1/3)",
    "맹세 전당 기록 지점 둘을 확보했다. 의식 봉인을 파괴한다. (2/3)",
    "맹세 전당 기록을 모두 확보했다. 의식 봉인이 파괴되었다. (3/3)"
]

const OATH_HALL_EXPECTED_STATES := [
    &"oath_hall_records_locked",
    &"oath_hall_records_partial",
    &"oath_hall_records_aligned",
    &"oath_hall_records_exposed"
]

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    await _assert_stage_progression(
        CH06_BATTERY_LINE_STAGE,
        BATTERY_EXPECTED_OBJECTS,
        BATTERY_EXPECTED_TEXTS,
        BATTERY_EXPECTED_STATES,
        false
    )
    if _failed:
        return

    await _assert_stage_progression(
        CH06_OATH_HALL_STAGE,
        OATH_HALL_EXPECTED_OBJECTS,
        OATH_HALL_EXPECTED_TEXTS,
        OATH_HALL_EXPECTED_STATES,
        false
    )
    if _failed:
        return

    print("[PASS] CH06 line-control runner validated authored battery-line and oath-hall objective progression.")
    quit(0)

func _assert_stage_progression(stage_data, expected_object_ids: Array, expected_texts: Array, expected_states: Array, requires_enemy_clear: bool) -> void:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    battle.set_stage(stage_data)

    await process_frame
    await process_frame

    _assert_equal(StringName(stage_data.rule_template_id), BATTERY_TEMPLATE_ID if StringName(stage_data.stage_id) == &"CH06_02" else OATH_HALL_TEMPLATE_ID, "%s should declare the expected rule template." % stage_data.stage_id)
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

    if StringName(stage_data.stage_id) == &"CH06_02":
        _assert_equal(String(battle.interactive_objects[0].object_data.object_type), "battery", "%s west battery control should route through the battery family." % stage_data.stage_id)
        if _failed:
            return
        _assert_equal(String(battle.interactive_objects[2].object_data.object_type), "battery", "%s east battery control should route through the battery family." % stage_data.stage_id)
        if _failed:
            return

    var central_gate = battle.interactive_objects[1]
    _assert_equal(central_gate.blocks_movement(), true, "%s should begin with its central gate sealed." % stage_data.stage_id)
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

    _assert_equal(central_gate.blocks_movement(), false, "%s should open its central gate after the final interaction resolves." % stage_data.stage_id)
    if _failed:
        return

    if requires_enemy_clear:
        if battle._check_battle_end():
            _fail("%s should still require enemy defeat after the line controls resolve." % stage_data.stage_id)
            return
        battle.enemy_units.clear()

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
    _assert_equal(battle.hud.objective_label.text, expected_label, "Unexpected CH06 objective label at %d resolved interactions." % resolved_count)
    if _failed:
        return

    var snapshot: Dictionary = battle.get_objective_state_snapshot()
    _assert_equal(int(snapshot.get("resolved_interactions", -1)), resolved_count, "Resolved interaction count drifted.")
    if _failed:
        return
    _assert_equal(int(snapshot.get("required_interactions", -1)), expected_states.size() - 1, "Required interaction count drifted.")
    if _failed:
        return
    _assert_equal(StringName(snapshot.get("state_id", &"")), expected_states[resolved_count], "Unexpected CH06 objective state id.")

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
